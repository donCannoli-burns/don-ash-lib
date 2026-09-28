package ash_test

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"reflect"
	"testing"

	ash "github.com/doncannoli-burns/kolmafia-ash-go/ash"
)

func TestBatchTransportAndTypes(t *testing.T) {
	t.Helper()
	var gotPath string
	var gotContentType string
	var gotPwd string
	var gotRequest map[string]any

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotPath = r.URL.Path
		gotContentType = r.Header.Get("Content-Type")
		body, _ := io.ReadAll(r.Body)
		form, err := url.ParseQuery(string(body))
		if err != nil {
			t.Fatalf("parse form: %v", err)
		}
		gotPwd = form.Get("pwd")
		if err := json.Unmarshal([]byte(form.Get("body")), &gotRequest); err != nil {
			t.Fatalf("decode body: %v", err)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = io.WriteString(w, `{"properties":[true],"functions":[7,"Rick"]}`)
	}))
	defer server.Close()

	client, err := ash.NewClient(ash.Options{
		BaseURL:          server.URL,
		PasswordProvider: func(context.Context) (string, error) { return "p&=d", nil },
	})
	if err != nil {
		t.Fatal(err)
	}

	result, err := client.Batch(context.Background(), ash.BatchRequest{
		Properties: []string{"kingLiberated"},
		Functions: []ash.FunctionCall{
			{Name: "availableAmount", Args: []any{ash.NewItem("seal-clubbing club")}},
			{Name: "myName", Args: []any{}},
		},
	})
	if err != nil {
		t.Fatal(err)
	}

	if gotPath != "/KoLmafia/jsonApi" {
		t.Fatalf("path = %q", gotPath)
	}
	if gotContentType != "application/x-www-form-urlencoded" {
		t.Fatalf("content type = %q", gotContentType)
	}
	if gotPwd != "p&=d" {
		t.Fatalf("pwd encoding failed: %q", gotPwd)
	}
	if len(result.Properties) != 1 || len(result.Functions) != 2 {
		t.Fatalf("unexpected response sizes")
	}

	amount, err := result.Functions[0].Int64()
	if err != nil || amount != 7 {
		t.Fatalf("amount = %d, err=%v", amount, err)
	}
	name, err := result.Functions[1].String()
	if err != nil || name != "Rick" {
		t.Fatalf("name = %q, err=%v", name, err)
	}

	functions := gotRequest["functions"].([]any)
	first := functions[0].(map[string]any)
	args := first["args"].([]any)
	item := args[0].(map[string]any)
	wantItem := map[string]any{"objectType": "Item", "identifierString": "seal-clubbing club"}
	if !reflect.DeepEqual(item, wantItem) {
		t.Fatalf("item = %#v", item)
	}
}

func TestNumericIdentifierAndPolicy(t *testing.T) {
	item := ash.NewItemID(123)
	encoded, err := json.Marshal(item)
	if err != nil {
		t.Fatal(err)
	}
	if string(encoded) != `{"objectType":"Item","identifierNumber":123}` {
		t.Fatalf("encoded = %s", encoded)
	}

	policy := ash.Deny("cliExecute", "visitUrl")
	if err := policy("myName", nil); err != nil {
		t.Fatalf("myName rejected: %v", err)
	}
	if err := policy("cliExecute", nil); err == nil {
		t.Fatal("cliExecute should be rejected")
	}
}
