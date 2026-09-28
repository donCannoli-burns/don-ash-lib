import <html5_bind.ash>;

void emit_api() {
    string op = form_field("op");
    string value = form_field("value");
    write(hb_dispatch(op, value));
}

void emit_app() {
    string theme = hb_theme();

    write("<!doctype html>");
    write("<html lang=\"en\" data-theme=\"" + hb_html(theme) + "\">");
    write("<head>");
    write("<meta charset=\"utf-8\">");
    write("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">");
    write("<title>KoLmafia ASH ↔ HTML5 binding</title>");
    write("<style>");
    write(":root{font-family:system-ui,sans-serif;color-scheme:light dark}");
    write("body{margin:0;min-height:100vh;background:Canvas;color:CanvasText}");
    write("main{max-width:900px;margin:auto;padding:2rem}");
    write(".grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px}");
    write(".card{border:1px solid color-mix(in srgb,CanvasText 20%,transparent);border-radius:12px;padding:1rem}");
    write("button,select{font:inherit;padding:.55rem .75rem;border-radius:8px}");
    write("pre{overflow:auto;padding:1rem;border-radius:10px;background:color-mix(in srgb,CanvasText 7%,Canvas)}");
    write("[data-theme='light']{color-scheme:light}[data-theme='dark']{color-scheme:dark}");
    write("</style>");
    write("</head><body><main>");
    write("<h1>KoLmafia ASH ↔ HTML5</h1>");
    write("<p>HTML5/JavaScript calls a bounded ASH dispatcher through the relay script.</p>");

    write("<div class=\"grid\" id=\"cards\">");
    write("<section class=\"card\"><strong>Player</strong><div id=\"player\">…</div></section>");
    write("<section class=\"card\"><strong>Level</strong><div id=\"level\">…</div></section>");
    write("<section class=\"card\"><strong>Adventures</strong><div id=\"adventures\">…</div></section>");
    write("<section class=\"card\"><strong>Meat</strong><div id=\"meat\">…</div></section>");
    write("<section class=\"card\"><strong>HP</strong><div id=\"hp\">…</div></section>");
    write("<section class=\"card\"><strong>MP</strong><div id=\"mp\">…</div></section>");
    write("</div>");

    write("<p><button id=\"refresh\" type=\"button\">Refresh ASH state</button> ");
    write("<label>Theme <select id=\"theme\">");
    write("<option value=\"system\">System</option>");
    write("<option value=\"light\">Light</option>");
    write("<option value=\"dark\">Dark</option>");
    write("</select></label></p>");

    write("<details><summary>Raw binding response</summary><pre id=\"raw\"></pre></details>");

    write("<script>");
    write("const endpoint=location.pathname;");
    write("async function ash(op,value=''){");
    write(" const body=new URLSearchParams({api:'1',op,value});");
    write(" const r=await fetch(endpoint,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body});");
    write(" const text=await r.text();");
    write(" try{return JSON.parse(text)}catch(e){throw new Error('ASH returned non-JSON: '+text.slice(0,200))}");
    write("}");
    write("function show(s){");
    write(" document.querySelector('#player').textContent=s.player;");
    write(" document.querySelector('#level').textContent=s.level;");
    write(" document.querySelector('#adventures').textContent=s.adventures;");
    write(" document.querySelector('#meat').textContent=s.meat;");
    write(" document.querySelector('#hp').textContent=s.hp+' / '+s.maxhp;");
    write(" document.querySelector('#mp').textContent=s.mp+' / '+s.maxmp;");
    write(" document.querySelector('#theme').value=s.theme;");
    write(" document.querySelector('#raw').textContent=JSON.stringify(s,null,2);");
    write("}");
    write("async function refresh(){show(await ash('state'))}");
    write("document.querySelector('#refresh').addEventListener('click',refresh);");
    write("document.querySelector('#theme').addEventListener('change',async e=>{");
    write(" const x=await ash('set_theme',e.target.value);");
    write(" if(x.ok){document.documentElement.dataset.theme=x.theme; await refresh()}");
    write("});");
    write("refresh().catch(e=>document.querySelector('#raw').textContent=String(e));");
    write("</script>");

    write("</main></body></html>");
}

void main() {
    if (form_field("api") == "1") {
        emit_api();
        return;
    }
    emit_app();
}
