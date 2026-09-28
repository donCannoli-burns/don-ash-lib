package ash

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const defaultBaseURL = "http://127.0.0.1:60080"

// PasswordProvider supplies the current KoLmafia pwd/session hash at call time.
// Keeping it callback-based prevents the library from persisting session material.
type PasswordProvider func(context.Context) (string, error)

// CallPolicy can structurally reject ASH runtime calls before transport.
// Return nil to allow the call.
type CallPolicy func(name string, args []any) error

// Options configures an ASH client.
type Options struct {
	BaseURL          string
	HTTPClient       *http.Client
	PasswordProvider PasswordProvider
	Policy           CallPolicy
}

// Client calls KoLmafia's Browser JSON API.
type Client struct {
	baseURL          string
	httpClient       *http.Client
	passwordProvider PasswordProvider
	policy           CallPolicy
}

func NewClient(opts Options) (*Client, error) {
	base := strings.TrimRight(opts.BaseURL, "/")
	if base == "" {
		base = defaultBaseURL
	}
	parsed, err := url.Parse(base)
	if err != nil || parsed.Scheme == "" || parsed.Host == "" {
		return nil, fmt.Errorf("ash: invalid base URL %q", base)
	}
	if opts.PasswordProvider == nil {
		return nil, errors.New("ash: PasswordProvider is required")
	}
	hc := opts.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: 15 * time.Second}
	}
	return &Client{
		baseURL:          base,
		httpClient:       hc,
		passwordProvider: opts.PasswordProvider,
		policy:           opts.Policy,
	}, nil
}

// FunctionCall describes one Browser JSON API function invocation.
type FunctionCall struct {
	Name string `json:"name"`
	Args []any  `json:"args"`
}

// BatchRequest can mix preference reads and ASH runtime calls in one request.
type BatchRequest struct {
	Properties []string       `json:"properties,omitempty"`
	Functions  []FunctionCall `json:"functions,omitempty"`
}

type wireResponse struct {
	Error      string            `json:"error,omitempty"`
	Properties []json.RawMessage `json:"properties,omitempty"`
	Functions  []json.RawMessage `json:"functions,omitempty"`
}

// BatchResult preserves request order exactly as returned by KoLmafia.
type BatchResult struct {
	Properties []Value
	Functions  []Value
}

func (c *Client) Batch(ctx context.Context, request BatchRequest) (BatchResult, error) {
	if len(request.Properties) == 0 && len(request.Functions) == 0 {
		return BatchResult{}, errors.New("ash: empty batch request")
	}
	for _, fn := range request.Functions {
		if strings.TrimSpace(fn.Name) == "" {
			return BatchResult{}, errors.New("ash: function name cannot be empty")
		}
		if c.policy != nil {
			if err := c.policy(fn.Name, fn.Args); err != nil {
				return BatchResult{}, fmt.Errorf("ash: call %s rejected by policy: %w", fn.Name, err)
			}
		}
	}

	pwd, err := c.passwordProvider(ctx)
	if err != nil {
		return BatchResult{}, fmt.Errorf("ash: obtain pwd: %w", err)
	}
	if pwd == "" {
		return BatchResult{}, errors.New("ash: PasswordProvider returned an empty pwd")
	}

	bodyJSON, err := json.Marshal(request)
	if err != nil {
		return BatchResult{}, fmt.Errorf("ash: encode request: %w", err)
	}

	form := url.Values{}
	form.Set("pwd", pwd)
	form.Set("body", string(bodyJSON))

	httpReq, err := http.NewRequestWithContext(
		ctx,
		http.MethodPost,
		c.baseURL+"/KoLmafia/jsonApi",
		strings.NewReader(form.Encode()),
	)
	if err != nil {
		return BatchResult{}, fmt.Errorf("ash: build request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	httpReq.Header.Set("Accept", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return BatchResult{}, fmt.Errorf("ash: request failed: %w", err)
	}
	defer resp.Body.Close()

	payload, err := io.ReadAll(io.LimitReader(resp.Body, 16<<20))
	if err != nil {
		return BatchResult{}, fmt.Errorf("ash: read response: %w", err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return BatchResult{}, fmt.Errorf("ash: KoLmafia returned HTTP %d: %s", resp.StatusCode, compact(payload))
	}

	var wire wireResponse
	decoder := json.NewDecoder(bytes.NewReader(payload))
	decoder.UseNumber()
	if err := decoder.Decode(&wire); err != nil {
		return BatchResult{}, fmt.Errorf("ash: decode response: %w", err)
	}
	if wire.Error != "" {
		return BatchResult{}, fmt.Errorf("ash: KoLmafia error: %s", wire.Error)
	}

	out := BatchResult{
		Properties: make([]Value, len(wire.Properties)),
		Functions:  make([]Value, len(wire.Functions)),
	}
	for i, raw := range wire.Properties {
		out.Properties[i] = newValue(raw)
	}
	for i, raw := range wire.Functions {
		out.Functions[i] = newValue(raw)
	}
	return out, nil
}

func compact(b []byte) string {
	const max = 512
	b = bytes.TrimSpace(b)
	if len(b) > max {
		return string(b[:max]) + "…"
	}
	return string(b)
}

// Call invokes one camelCase ASH runtime function.
func (c *Client) Call(ctx context.Context, name string, args ...any) (Value, error) {
	result, err := c.Batch(ctx, BatchRequest{
		Functions: []FunctionCall{{Name: name, Args: args}},
	})
	if err != nil {
		return Value{}, err
	}
	if len(result.Functions) != 1 {
		return Value{}, fmt.Errorf("ash: expected 1 function result, got %d", len(result.Functions))
	}
	return result.Functions[0], nil
}

// CallInto invokes one ASH runtime function and decodes its JSON result into dst.
func (c *Client) CallInto(ctx context.Context, dst any, name string, args ...any) error {
	value, err := c.Call(ctx, name, args...)
	if err != nil {
		return err
	}
	return value.Decode(dst)
}

// Property reads one KoLmafia preference/property through the same endpoint.
func (c *Client) Property(ctx context.Context, name string) (Value, error) {
	result, err := c.Batch(ctx, BatchRequest{Properties: []string{name}})
	if err != nil {
		return Value{}, err
	}
	if len(result.Properties) != 1 {
		return Value{}, fmt.Errorf("ash: expected 1 property result, got %d", len(result.Properties))
	}
	return result.Properties[0], nil
}

// AllowOnly returns a policy that permits only the supplied function names.
func AllowOnly(names ...string) CallPolicy {
	allowed := make(map[string]struct{}, len(names))
	for _, name := range names {
		allowed[name] = struct{}{}
	}
	return func(name string, _ []any) error {
		if _, ok := allowed[name]; !ok {
			return fmt.Errorf("%q is not allowlisted", name)
		}
		return nil
	}
}

// Deny returns a policy that blocks the supplied function names.
func Deny(names ...string) CallPolicy {
	denied := make(map[string]struct{}, len(names))
	for _, name := range names {
		denied[name] = struct{}{}
	}
	return func(name string, _ []any) error {
		if _, ok := denied[name]; ok {
			return fmt.Errorf("%q is denied", name)
		}
		return nil
	}
}
