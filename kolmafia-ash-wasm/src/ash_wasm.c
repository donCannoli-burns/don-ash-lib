#include <stdint.h>
#include <stddef.h>

#define OUT_CAP 131072u
#define ARENA_CAP 65536u
#define POLICY_CAP 4096u
#define ERR_CAP 1024u

static unsigned char arena[ARENA_CAP];
static uint32_t arena_off = 0;
static char out_buf[OUT_CAP];
static uint32_t out_len = 0;
static char policy_buf[POLICY_CAP];
static uint32_t policy_len = 0;
static int32_t policy_mode = 0; /* 0 allow-all, 1 allowlist, 2 denylist */
static char err_buf[ERR_CAP];
static uint32_t err_len = 0;

static void clear_error(void) { err_len = 0; err_buf[0] = 0; }

static void set_error(const char *s) {
    uint32_t i = 0;
    while (s[i] && i + 1u < ERR_CAP) { err_buf[i] = s[i]; i++; }
    err_buf[i] = 0;
    err_len = i;
}

static int append_char(char c) {
    if (out_len + 1u >= OUT_CAP) { set_error("output buffer overflow"); return 0; }
    out_buf[out_len++] = c;
    out_buf[out_len] = 0;
    return 1;
}

static int append_bytes(const char *p, uint32_t n) {
    if (out_len + n >= OUT_CAP) { set_error("output buffer overflow"); return 0; }
    for (uint32_t i = 0; i < n; i++) out_buf[out_len++] = p[i];
    out_buf[out_len] = 0;
    return 1;
}

static int append_cstr(const char *s) {
    uint32_t n = 0;
    while (s[n]) n++;
    return append_bytes(s, n);
}

static int append_json_string(const char *p, uint32_t n) {
    if (!append_char('"')) return 0;
    static const char hex[] = "0123456789abcdef";
    for (uint32_t i = 0; i < n; i++) {
        unsigned char c = (unsigned char)p[i];
        switch (c) {
            case '"': if (!append_cstr("\\\"")) return 0; break;
            case '\\': if (!append_cstr("\\\\")) return 0; break;
            case '\b': if (!append_cstr("\\b")) return 0; break;
            case '\f': if (!append_cstr("\\f")) return 0; break;
            case '\n': if (!append_cstr("\\n")) return 0; break;
            case '\r': if (!append_cstr("\\r")) return 0; break;
            case '\t': if (!append_cstr("\\t")) return 0; break;
            default:
                if (c < 0x20u) {
                    if (!append_cstr("\\u00")) return 0;
                    if (!append_char(hex[(c >> 4) & 0xf])) return 0;
                    if (!append_char(hex[c & 0xf])) return 0;
                } else {
                    if (!append_char((char)c)) return 0;
                }
        }
    }
    return append_char('"');
}

static int token_match(const char *name, uint32_t nlen, const char *csv, uint32_t clen) {
    uint32_t start = 0;
    while (start < clen) {
        while (start < clen && (csv[start] == ',' || csv[start] == ' ' || csv[start] == '\n' || csv[start] == '\t' || csv[start] == '\r')) start++;
        uint32_t end = start;
        while (end < clen && csv[end] != ',') end++;
        uint32_t trim = end;
        while (trim > start && (csv[trim - 1] == ' ' || csv[trim - 1] == '\n' || csv[trim - 1] == '\t' || csv[trim - 1] == '\r')) trim--;
        uint32_t len = trim - start;
        if (len == nlen) {
            uint32_t i = 0;
            for (; i < len; i++) if (csv[start + i] != name[i]) break;
            if (i == len) return 1;
        }
        start = end + 1u;
    }
    return 0;
}

__attribute__((export_name("ash_version_major"))) int32_t ash_version_major(void) { return 0; }
__attribute__((export_name("ash_version_minor"))) int32_t ash_version_minor(void) { return 1; }
__attribute__((export_name("ash_version_patch"))) int32_t ash_version_patch(void) { return 0; }

__attribute__((export_name("ash_reset_arena"))) void ash_reset_arena(void) { arena_off = 0; }

__attribute__((export_name("ash_alloc"))) uint32_t ash_alloc(uint32_t n) {
    if (n == 0) n = 1;
    uint32_t aligned = (n + 7u) & ~7u;
    if (arena_off + aligned > ARENA_CAP) { set_error("arena exhausted"); return 0; }
    uint32_t p = (uint32_t)(uintptr_t)&arena[arena_off];
    arena_off += aligned;
    return p;
}

__attribute__((export_name("ash_out_ptr"))) uint32_t ash_out_ptr(void) { return (uint32_t)(uintptr_t)&out_buf[0]; }
__attribute__((export_name("ash_out_len"))) uint32_t ash_out_len(void) { return out_len; }
__attribute__((export_name("ash_error_ptr"))) uint32_t ash_error_ptr(void) { return (uint32_t)(uintptr_t)&err_buf[0]; }
__attribute__((export_name("ash_error_len"))) uint32_t ash_error_len(void) { return err_len; }

__attribute__((export_name("ash_policy_clear"))) void ash_policy_clear(void) {
    policy_mode = 0; policy_len = 0; policy_buf[0] = 0; clear_error();
}

__attribute__((export_name("ash_policy_set"))) int32_t ash_policy_set(int32_t mode, uint32_t ptr, uint32_t len) {
    clear_error();
    if (mode < 0 || mode > 2) { set_error("invalid policy mode"); return -1; }
    if (len >= POLICY_CAP) { set_error("policy list too large"); return -2; }
    const char *src = (const char *)(uintptr_t)ptr;
    for (uint32_t i = 0; i < len; i++) policy_buf[i] = src[i];
    policy_buf[len] = 0; policy_len = len; policy_mode = mode;
    return 0;
}

__attribute__((export_name("ash_policy_allowed"))) int32_t ash_policy_allowed(uint32_t ptr, uint32_t len) {
    const char *name = (const char *)(uintptr_t)ptr;
    if (policy_mode == 0) return 1;
    int match = token_match(name, len, policy_buf, policy_len);
    if (policy_mode == 1) return match ? 1 : 0;
    return match ? 0 : 1;
}

__attribute__((export_name("ash_build_enum_string"))) int32_t ash_build_enum_string(uint32_t tptr, uint32_t tlen, uint32_t iptr, uint32_t ilen) {
    clear_error(); out_len = 0;
    const char *type = (const char *)(uintptr_t)tptr;
    const char *id = (const char *)(uintptr_t)iptr;
    if (!append_cstr("{\"objectType\":")) return -1;
    if (!append_json_string(type, tlen)) return -1;
    if (!append_cstr(",\"identifierString\":")) return -1;
    if (!append_json_string(id, ilen)) return -1;
    if (!append_char('}')) return -1;
    return 0;
}

__attribute__((export_name("ash_build_enum_number"))) int32_t ash_build_enum_number(uint32_t tptr, uint32_t tlen, uint32_t nptr, uint32_t nlen) {
    clear_error(); out_len = 0;
    const char *type = (const char *)(uintptr_t)tptr;
    const char *num = (const char *)(uintptr_t)nptr;
    if (nlen == 0) { set_error("numeric identifier is empty"); return -1; }
    uint32_t i = 0;
    if (num[0] == '-') i = 1;
    if (i == nlen) { set_error("invalid numeric identifier"); return -2; }
    for (; i < nlen; i++) if (num[i] < '0' || num[i] > '9') { set_error("invalid numeric identifier"); return -2; }
    if (!append_cstr("{\"objectType\":")) return -3;
    if (!append_json_string(type, tlen)) return -3;
    if (!append_cstr(",\"identifierNumber\":")) return -3;
    if (!append_bytes(num, nlen)) return -3;
    if (!append_char('}')) return -3;
    return 0;
}

__attribute__((export_name("ash_build_function"))) int32_t ash_build_function(uint32_t nptr, uint32_t nlen, uint32_t aptr, uint32_t alen) {
    clear_error(); out_len = 0;
    const char *name = (const char *)(uintptr_t)nptr;
    const char *args = (const char *)(uintptr_t)aptr;
    if (!ash_policy_allowed(nptr, nlen)) { set_error("function rejected by policy"); return -10; }
    if (!append_cstr("{\"name\":")) return -1;
    if (!append_json_string(name, nlen)) return -1;
    if (!append_cstr(",\"args\":")) return -1;
    if (alen == 0) { if (!append_cstr("[]")) return -1; }
    else { if (!append_bytes(args, alen)) return -1; }
    if (!append_char('}')) return -1;
    return 0;
}

__attribute__((export_name("ash_build_batch"))) int32_t ash_build_batch(uint32_t pptr, uint32_t plen, uint32_t fptr, uint32_t flen) {
    clear_error(); out_len = 0;
    const char *props = (const char *)(uintptr_t)pptr;
    const char *funcs = (const char *)(uintptr_t)fptr;
    if (!append_char('{')) return -1;
    int wrote = 0;
    if (plen > 0) {
        if (!append_cstr("\"properties\":")) return -1;
        if (!append_bytes(props, plen)) return -1;
        wrote = 1;
    }
    if (flen > 0) {
        if (wrote && !append_char(',')) return -1;
        if (!append_cstr("\"functions\":")) return -1;
        if (!append_bytes(funcs, flen)) return -1;
        wrote = 1;
    }
    if (!wrote) { set_error("empty batch"); return -2; }
    if (!append_char('}')) return -1;
    return 0;
}
