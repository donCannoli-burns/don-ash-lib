package dev.doncannoli.kolmafia.ashrefgen;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class Main {
    private static final Pattern SIG = Pattern.compile("^\\s*([\\w ?\\[\\]]+)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*\\((.*)\\)\\s*$");
    private static final Map<String,String> ENUMS = Map.ofEntries(
        Map.entry("item","Item"), Map.entry("familiar","Familiar"), Map.entry("skill","Skill"),
        Map.entry("effect","Effect"), Map.entry("monster","Monster"), Map.entry("location","Location"),
        Map.entry("slot","Slot"), Map.entry("stat","Stat"), Map.entry("path","Path"),
        Map.entry("class","AscensionClass"), Map.entry("element","Element"), Map.entry("phylum","Phylum"),
        Map.entry("thrall","Thrall"), Map.entry("servant","Servant"), Map.entry("coinmaster","Coinmaster"),
        Map.entry("modifier","Modifier")
    );

    public static void main(String[] args) throws Exception {
        if (args.length < 2 || args.length > 3) {
            System.err.println("usage: ashrefgen <ashref.txt> <GeneratedAsh.java> [package]");
            System.exit(2);
        }
        String pkg = args.length == 3 ? args[2] : "dev.doncannoli.kolmafia.ash.generated";
        List<String> lines = Files.readAllLines(Path.of(args[0]));
        String generated = generate(lines, pkg);
        Path out = Path.of(args[1]);
        if (out.getParent() != null) Files.createDirectories(out.getParent());
        Files.writeString(out, generated);
    }

    static String generate(List<String> lines, String pkg) {
        List<Signature> parsed = new ArrayList<>();
        Map<String,Integer> names = new HashMap<>();
        for (String line : lines) {
            Signature s = parse(line);
            if (s != null) { parsed.add(s); names.merge(s.ashName, 1, Integer::sum); }
        }
        StringBuilder out = new StringBuilder();
        out.append("package ").append(pkg).append(";\n\n")
           .append("import dev.doncannoli.kolmafia.ash.*;\n")
           .append("import dev.doncannoli.kolmafia.ash.types.*;\n\n")
           .append("/** Generated from KoLmafia ashref output. */\n")
           .append("public final class GeneratedAsh {\n")
           .append("  private final AshClient client;\n")
           .append("  public GeneratedAsh(AshClient client) { this.client = client; }\n\n");
        int ok=0, skipped=0;
        for (Signature s : parsed) {
            if (names.getOrDefault(s.ashName,0) > 1 || s.unsupported()) { skipped++; continue; }
            out.append(s.emit()); ok++;
        }
        out.append("}\n");
        System.err.println("generated="+ok+" skipped="+skipped);
        return out.toString();
    }

    private static Signature parse(String line) {
        Matcher m=SIG.matcher(line);
        if(!m.matches()) return null;
        String ret=m.group(1).trim(), name=m.group(2).trim(), params=m.group(3).trim();
        List<String> p = params.isBlank()?List.of():splitParams(params);
        return new Signature(ret,name,p);
    }

    private static List<String> splitParams(String text) {
        List<String> out=new ArrayList<>();
        for(String p:text.split(",")) out.add(p.trim());
        return out;
    }

    private record Signature(String ret, String ashName, List<String> params) {
        boolean unsupported() {
            if (type(ret, true)==null) return true;
            for(String p:params) if(type(p,false)==null) return true;
            return false;
        }
        String emit() {
            String javaName=camel(ashName);
            String rt=type(ret,true);
            StringBuilder b=new StringBuilder("  public ").append(rt).append(' ').append(javaName).append('(');
            for(int i=0;i<params.size();i++) { if(i>0)b.append(", "); b.append(type(params.get(i),false)).append(" arg").append(i); }
            b.append(") {\n    var v = client.call(\"").append(javaName).append("\"");
            for(int i=0;i<params.size();i++) b.append(", arg").append(i);
            b.append(");\n    ");
            b.append(returnExpr(rt));
            b.append("\n  }\n\n");
            return b.toString();
        }
    }

    private static String type(String ash, boolean ret) {
        String s=ash.trim().toLowerCase(Locale.ROOT).replace("?", "").trim();
        if (s.startsWith("[") || s.contains("[") || s.equals("aggregate") || s.equals("buffer")) return null;
        return switch(s) {
            case "void" -> ret ? "void" : null;
            case "boolean" -> "boolean";
            case "int" -> "long";
            case "float" -> "double";
            case "string" -> "String";
            default -> ENUMS.get(s);
        };
    }

    private static String returnExpr(String rt) {
        return switch(rt) {
            case "void" -> "return;";
            case "boolean" -> "return v.booleanValue();";
            case "long" -> "return v.longValue();";
            case "double" -> "return v.doubleValue();";
            case "String" -> "return v.stringValue();";
            default -> "var o = v.objectValue(); return o.get(\"identifierNumber\") instanceof Number n ? new " + rt + "(n.longValue()) : new " + rt + "((String)o.get(\"identifierString\"));";
        };
    }

    private static String camel(String s) {
        StringBuilder b=new StringBuilder(); boolean up=false;
        for(char c:s.toCharArray()) { if(c=='_'){up=true;continue;} b.append(up?Character.toUpperCase(c):c); up=false; }
        return b.toString();
    }
}
