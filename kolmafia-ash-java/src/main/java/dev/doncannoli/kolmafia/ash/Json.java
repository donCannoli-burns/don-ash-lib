package dev.doncannoli.kolmafia.ash;

import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

final class Json {
    private Json() {}

    static String stringify(Object value) {
        StringBuilder out = new StringBuilder();
        write(normalize(value), out);
        return out.toString();
    }

    static Object normalize(Object value) {
        if (value == null || value instanceof String || value instanceof Boolean || value instanceof Number) return value;
        if (value instanceof AshArgument arg) return normalize(arg.toJsonValue());
        if (value instanceof Map<?, ?> map) {
            Map<String, Object> out = new LinkedHashMap<>();
            for (var e : map.entrySet()) out.put(String.valueOf(e.getKey()), normalize(e.getValue()));
            return out;
        }
        if (value instanceof Iterable<?> iterable) {
            List<Object> out = new ArrayList<>();
            for (Object v : iterable) out.add(normalize(v));
            return out;
        }
        if (value.getClass().isArray()) {
            List<Object> out = new ArrayList<>();
            int n = Array.getLength(value);
            for (int i = 0; i < n; i++) out.add(normalize(Array.get(value, i)));
            return out;
        }
        throw new IllegalArgumentException("unsupported JSON value: " + value.getClass().getName());
    }

    private static void write(Object value, StringBuilder out) {
        if (value == null) { out.append("null"); return; }
        if (value instanceof String s) { quote(s, out); return; }
        if (value instanceof Boolean || value instanceof Number) { out.append(value); return; }
        if (value instanceof Map<?, ?> map) {
            out.append('{'); boolean first = true;
            for (var e : map.entrySet()) {
                if (!first) out.append(','); first = false;
                quote(String.valueOf(e.getKey()), out); out.append(':'); write(e.getValue(), out);
            }
            out.append('}'); return;
        }
        if (value instanceof Iterable<?> iterable) {
            out.append('['); boolean first = true;
            for (Object v : iterable) {
                if (!first) out.append(','); first = false; write(v, out);
            }
            out.append(']'); return;
        }
        throw new IllegalArgumentException("unsupported normalized JSON value: " + value.getClass().getName());
    }

    private static void quote(String s, StringBuilder out) {
        out.append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"' -> out.append("\\\"");
                case '\\' -> out.append("\\\\");
                case '\b' -> out.append("\\b");
                case '\f' -> out.append("\\f");
                case '\n' -> out.append("\\n");
                case '\r' -> out.append("\\r");
                case '\t' -> out.append("\\t");
                default -> {
                    if (c < 0x20) out.append(String.format("\\u%04x", (int)c));
                    else out.append(c);
                }
            }
        }
        out.append('"');
    }

    static Object parse(String input) {
        Parser p = new Parser(input);
        Object value = p.value();
        p.ws();
        if (!p.end()) throw p.error("trailing data");
        return value;
    }

    private static final class Parser {
        final String s; int i;
        Parser(String s) { this.s = s; }
        boolean end() { return i >= s.length(); }
        AshException error(String msg) { return new AshException("invalid JSON at " + i + ": " + msg); }
        void ws() { while (!end() && Character.isWhitespace(s.charAt(i))) i++; }
        Object value() {
            ws(); if (end()) throw error("unexpected end");
            return switch (s.charAt(i)) {
                case '{' -> object(); case '[' -> array(); case '"' -> string();
                case 't' -> literal("true", true); case 'f' -> literal("false", false); case 'n' -> literal("null", null);
                default -> number();
            };
        }
        Object literal(String token, Object value) {
            if (!s.startsWith(token, i)) throw error("expected " + token); i += token.length(); return value;
        }
        Map<String,Object> object() {
            i++; ws(); Map<String,Object> m = new LinkedHashMap<>();
            if (!end() && s.charAt(i)=='}') { i++; return m; }
            while (true) {
                ws(); if (end() || s.charAt(i)!='"') throw error("expected object key");
                String k = string(); ws(); if (end() || s.charAt(i++)!=':') throw error("expected ':'");
                m.put(k, value()); ws(); if (end()) throw error("unterminated object");
                char c=s.charAt(i++); if (c=='}') return m; if (c!=',') throw error("expected ',' or '}'");
            }
        }
        List<Object> array() {
            i++; ws(); List<Object> a = new ArrayList<>();
            if (!end() && s.charAt(i)==']') { i++; return a; }
            while (true) {
                a.add(value()); ws(); if (end()) throw error("unterminated array");
                char c=s.charAt(i++); if (c==']') return a; if (c!=',') throw error("expected ',' or ']'");
            }
        }
        String string() {
            if (s.charAt(i++)!='"') throw error("expected string"); StringBuilder o=new StringBuilder();
            while (!end()) {
                char c=s.charAt(i++); if (c=='"') return o.toString();
                if (c!='\\') { o.append(c); continue; }
                if (end()) throw error("bad escape"); char e=s.charAt(i++);
                switch(e) {
                    case '"','\\','/' -> o.append(e); case 'b' -> o.append('\b'); case 'f' -> o.append('\f');
                    case 'n' -> o.append('\n'); case 'r' -> o.append('\r'); case 't' -> o.append('\t');
                    case 'u' -> { if (i+4>s.length()) throw error("bad unicode escape"); o.append((char)Integer.parseInt(s.substring(i,i+4),16)); i+=4; }
                    default -> throw error("bad escape");
                }
            }
            throw error("unterminated string");
        }
        Number number() {
            int start=i;
            if (!end() && s.charAt(i)=='-') i++;
            while (!end() && Character.isDigit(s.charAt(i))) i++;
            boolean decimal=false;
            if (!end() && s.charAt(i)=='.') { decimal=true; i++; while(!end()&&Character.isDigit(s.charAt(i))) i++; }
            if (!end() && (s.charAt(i)=='e'||s.charAt(i)=='E')) { decimal=true; i++; if(!end()&&(s.charAt(i)=='+'||s.charAt(i)=='-')) i++; while(!end()&&Character.isDigit(s.charAt(i))) i++; }
            if (start==i) throw error("expected value");
            String n=s.substring(start,i);
            try { return decimal ? new BigDecimal(n) : Long.valueOf(n); } catch(NumberFormatException e) { throw error("bad number"); }
        }
    }
}
