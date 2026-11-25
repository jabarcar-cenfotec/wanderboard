/// Presentation deck for the E2EE proof of concept, served at /admin/flujo.
/// One slide per step: a route map (phone → server → phone) where a sealed
/// packet travels, with real AES-256-GCM output computed in the browser via
/// WebCrypto and live records from this server. A lab slide lets the audience
/// encrypt, tamper and share keys live.
/// Self-contained: no external scripts or fonts, so it works offline.
const flowPage = r'''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Backend E2EE · Flujo del proceso</title>
<style>
  :root {
    --ink: #0d1a3a; --ink2: #142a5e; --line: #2c4488; --paper: #eef1f6; --muted: #9db0d9;
    --seal: #ffc93c; --clear: #35e0a1; --alarm: #ff5a4e; --server: #7c9bff; --amber: #f0a35e;
    --sans: "Bahnschrift", "Segoe UI Variable Display", "Segoe UI", system-ui, sans-serif;
    --mono: "Cascadia Mono", Consolas, "SF Mono", monospace;
  }
  * { box-sizing: border-box; }
  html, body { height: 100%; margin: 0; }
  body { font-family: var(--sans); color: var(--paper); background-color: var(--ink);
         background-image: radial-gradient(#ffffff14 1px, transparent 1px); background-size: 26px 26px; overflow: hidden; }
  button { font-family: inherit; }
  code { font-family: var(--mono); font-size: .88em; background: #ffffff18; padding: 1px 6px; border-radius: 4px; }

  .deck { height: 100vh; display: grid; grid-template-rows: auto 1fr auto; }
  .top { display: flex; align-items: center; gap: 20px; padding: 14px 32px; border-bottom: 1px solid #ffffff1f; }
  .brand { font-weight: 600; font-size: 18px; letter-spacing: .01em; white-space: nowrap; }
  .tabs { display: flex; gap: 6px; flex: 1; overflow-x: auto; }
  .tabs button { background: none; border: 1px solid transparent; color: var(--muted); padding: 6px 11px; border-radius: 999px; font-size: 14px; cursor: pointer; white-space: nowrap; }
  .tabs button:hover { color: var(--paper); }
  .tabs button.active { color: var(--ink); background: var(--paper); font-weight: 600; }
  .links a { color: var(--muted); font-size: 14px; margin-left: 14px; text-decoration: none; }
  .links a.active { color: var(--paper); border-bottom: 1px solid var(--paper); }
  button:focus-visible, a:focus-visible { outline: 3px solid var(--seal); outline-offset: 2px; }

  #view { min-height: 0; overflow: auto; padding: 0 5vw; display: flex; flex-direction: column; }

  /* ----- route map ----- */
  .stage { flex: 0 0 auto; padding-top: clamp(24px, 6vh, 70px); }
  .route { position: relative; height: clamp(185px, 30vh, 260px); }
  .track { position: absolute; top: 41px; height: 0; border-top: 3px dashed #ffffff3d; }
  .seg { position: absolute; top: 40px; height: 5px; border-radius: 3px; background: var(--seal); transform-origin: left center; z-index: 1; }
  .seg.rtl { transform-origin: right center; }
  .seg.blocked { background: var(--alarm); }
  .seg.anim { animation: draw 1.1s ease-in-out both; }
  @keyframes draw { from { transform: scaleX(0); } to { transform: scaleX(1); } }
  .st { position: absolute; top: 0; z-index: 2; width: 220px; margin-left: -110px; text-align: center; transition: opacity .3s; }
  .st.dim { opacity: .45; }
  .orb { width: 86px; height: 86px; margin: 0 auto; border-radius: 50%; display: grid; place-items: center; font-size: 36px;
         background: var(--ink2); border: 3px solid var(--c); transition: transform .3s, box-shadow .3s; }
  .st.device { --c: var(--clear); } .st.server { --c: var(--server); } .st.other { --c: var(--amber); } .st.bad { --c: var(--alarm); }
  .st.on .orb { transform: scale(1.1); box-shadow: 0 0 0 8px color-mix(in srgb, var(--c) 28%, transparent); }
  .st.arrive .orb { animation: arrive .5s 1.05s both; }
  @keyframes arrive { from { transform: scale(1); box-shadow: 0 0 0 0 transparent; } to { transform: scale(1.1); box-shadow: 0 0 0 8px color-mix(in srgb, var(--c) 28%, transparent); } }
  .st .nm { margin-top: 12px; font-size: clamp(16px, 1.5vw, 22px); font-weight: 600; }
  .st .sb { color: var(--muted); font-size: clamp(12px, 1vw, 15px); margin-top: 2px; }
  .packet { position: absolute; top: 19px; width: 48px; height: 48px; margin-left: -24px; border-radius: 50%; display: grid; place-items: center;
            font-size: 22px; background: var(--seal); color: var(--ink); box-shadow: 0 0 0 5px #ffc93c33, 0 6px 18px #0008; z-index: 3; left: var(--to); }
  .packet.blocked { background: var(--alarm); color: #fff; font-weight: 700; }
  .packet.anim { animation: travel 1.1s ease-in-out both; }
  .packet.blocked.anim { animation: bounce 1.3s ease-in both; }
  @keyframes travel { from { left: var(--from); } to { left: var(--to); } }
  @keyframes bounce { 0% { left: var(--from); } 62% { left: var(--stop); } 72% { left: calc(var(--stop) - 1.4%); } 82% { left: var(--stop); } 100% { left: var(--stop); } }
  .edgelabel { position: absolute; top: 150px; transform: translateX(-50%); font-family: var(--mono); font-size: clamp(11px, .95vw, 14px); color: var(--seal); white-space: nowrap; }
  .edgelabel.blocked { color: var(--alarm); }

  /* ----- caption + panel ----- */
  .lower { flex: 1 0 auto; display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 4vw; align-items: start; padding: 4vh 0 3vh; }
  .lower.solo { grid-template-columns: minmax(0, 52rem); }
  .cap h2 { margin: 0 0 14px; font-size: clamp(30px, 4vw, 58px); line-height: 1.05; font-weight: 600; font-variation-settings: "wdth" 88; letter-spacing: -.01em; }
  .cap p { margin: 0; font-size: clamp(17px, 1.7vw, 25px); line-height: 1.45; color: #dbe3f5; max-width: 34em; }
  .panel { background: #07102b; border: 1px solid var(--line); border-radius: 14px; padding: 18px 22px; }
  .panel h3 { margin: 0 0 12px; font-size: 16px; font-weight: 600; color: var(--muted); }
  .fld { margin-top: 12px; }
  .fld:first-of-type { margin-top: 0; }
  .fld .k { color: var(--muted); font-size: 14px; margin-bottom: 3px; }
  .fld .v { font-family: var(--mono); font-size: clamp(12px, 1.05vw, 16px); line-height: 1.5; word-break: break-all; }
  .v.clear { color: var(--clear); font-weight: 700; }
  .v.cipher { color: var(--seal); }
  .v.small { font-size: 12px; color: var(--muted); }
  .note { color: var(--muted); font-size: 14px; }

  /* ----- nav ----- */
  .nav { display: flex; align-items: center; gap: 12px; padding: 12px 32px; border-top: 1px solid #ffffff1f; }
  .nav button.ctl { background: #ffffff14; color: var(--paper); border: 1px solid #ffffff26; padding: 10px 18px; font-size: 16px; border-radius: 10px; cursor: pointer; }
  .nav button.ctl:hover { background: #ffffff26; }
  .nav button.ctl.on { background: var(--clear); color: var(--ink); border-color: var(--clear); }
  .dots { flex: 1; display: flex; gap: 8px; justify-content: center; align-items: center; }
  .dot { width: 12px; height: 12px; border-radius: 50%; border: 2px solid var(--muted); background: none; padding: 0; cursor: pointer; }
  .dot.past { background: var(--muted); } .dot.on { background: var(--seal); border-color: var(--seal); transform: scale(1.35); }
  .count { color: var(--muted); font-size: 14px; min-width: 70px; text-align: right; }

  /* ----- summary + lab ----- */
  .summary { flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 3vw; align-content: center; padding: 4vh 0; }
  .summary > div { background: #07102b; border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px; }
  .summary h2 { margin: 0 0 18px; font-size: clamp(26px, 3vw, 42px); font-weight: 600; font-variation-settings: "wdth" 88; }
  .summary .yes h2 { color: var(--seal); } .summary .no h2 { color: var(--clear); }
  .summary ul { margin: 0; padding-left: 1.1em; font-size: clamp(16px, 1.6vw, 24px); line-height: 1.6; }
  .lab { display: grid; gap: 14px; padding: 3vh 0; }
  .lab h2 { margin: 0; font-size: clamp(26px, 3vw, 42px); font-weight: 600; font-variation-settings: "wdth" 88; }
  .lab .lead { color: #dbe3f5; font-size: 17px; max-width: 60rem; margin: 0; }
  .lab .card { background: #07102b; border: 1px solid var(--line); border-radius: 14px; padding: 18px 22px; }
  .lab .card h3 { margin: 0 0 10px; font-size: 20px; font-weight: 600; }
  .lab textarea { width: 100%; font: 16px var(--sans); padding: 10px; border: 1px solid var(--line); border-radius: 8px; background: var(--ink2); color: var(--paper); }
  .lab .btns { display: flex; gap: 8px; flex-wrap: wrap; margin: 10px 0; }
  .lab .btns button { background: #ffffff14; color: var(--paper); border: 1px solid #ffffff2e; padding: 9px 15px; font-size: 15px; border-radius: 9px; cursor: pointer; }
  .lab .btns button:hover { background: #ffffff2a; }
  .lab .btns button.primary { background: var(--seal); color: var(--ink); border-color: var(--seal); font-weight: 600; }
  .lab .row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .lab .box { border-radius: 10px; padding: 12px 14px; border-left: 5px solid; font-size: 14px; background: #ffffff0d; word-break: break-all; }
  .lab .box.device { border-color: var(--clear); } .lab .box.server { border-color: var(--server); }
  .lab .box.good { border-color: var(--clear); background: #35e0a11a; } .lab .box.bad { border-color: var(--alarm); background: #ff5a4e1f; }
  .lab .box .t { font-weight: 600; margin-bottom: 4px; font-size: 15px; }
  .lab .mono { font-family: var(--mono); font-size: 12px; }
  .lab .diff { color: var(--alarm); font-weight: 700; }
  /* ----- live demo: real app next to the server ----- */
  .demo { flex: 1; min-height: 0; display: grid; grid-template-columns: auto minmax(0, 1fr); gap: 3vw; padding: 2.5vh 0; align-items: start; }
  .phone { border: 10px solid #2b2b2b; border-radius: 40px; overflow: hidden; background: #000; width: 410px; height: calc(100vh - 175px); min-height: 520px;
           box-shadow: 0 0 0 2px #ffffff22, 0 20px 50px #0009; }
  .phone iframe { width: 100%; height: 100%; border: 0; display: block; background: #f7f1e8; }
  .feed { display: grid; gap: 14px; min-width: 0; }
  .feed h2 { margin: 0; font-size: clamp(24px, 2.6vw, 38px); font-weight: 600; font-variation-settings: "wdth" 88; }
  .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
  .stat { background: #07102b; border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; }
  .stat b { display: block; font-size: clamp(30px, 3.2vw, 48px); font-weight: 600; font-variation-settings: "wdth" 88; color: var(--seal); line-height: 1.05; }
  .stat span { color: var(--muted); font-size: 14px; }
  .stat.bump b { animation: bump .8s; }
  @keyframes bump { 0% { transform: scale(1); } 30% { transform: scale(1.4); color: var(--clear); } 100% { transform: scale(1); } }
  .feed input { width: 100%; font: 16px var(--sans); padding: 9px 12px; border: 1px solid var(--line); border-radius: 8px; background: var(--ink2); color: var(--paper); }
  .feed .row { display: flex; gap: 8px; }
  .feed button { background: var(--seal); color: var(--ink); border: 0; padding: 9px 16px; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; white-space: nowrap; }
  .verdict { margin-top: 10px; font-size: clamp(16px, 1.5vw, 22px); font-weight: 600; }
  .verdict.ok { color: var(--clear); } .verdict.bad { color: var(--alarm); }
  .feed ol { margin: 0; padding-left: 1.2em; line-height: 1.7; font-size: 15px; color: #dbe3f5; }
  /* ----- two phones: sender, server and receiver side by side ----- */
  .two { flex: 1; min-height: 0; display: grid; grid-template-columns: auto minmax(320px, 1fr) auto; gap: 2vw; padding: 2vh 0; align-items: start; }
  .two .phone { width: 360px; height: calc(100vh - 205px); min-height: 480px; }
  .pbox h3 { margin: 0 0 8px; font-size: 15px; font-weight: 600; color: var(--muted); text-align: center; }
  .two .stats { grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); }
  .two .stat b { font-size: clamp(26px, 2.6vw, 40px); }
  .tl { list-style: none; margin: 0; padding: 0; display: grid; gap: 6px; }
  .tl li { display: flex; gap: 10px; font-size: 15px; line-height: 1.4; color: #dbe3f5; animation: tlin .5s; }
  .tl time { font-family: var(--mono); font-size: 13px; color: var(--muted); flex: none; padding-top: 1px; }
  @keyframes tlin { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: none; } }
  @media (max-width: 1100px) { .two { grid-template-columns: 1fr; } .two .phone { width: 100%; max-width: 360px; margin: 0 auto; } }
  @media (prefers-reduced-motion: reduce) { .stat.bump b, .tl li { animation: none; } }
  @media (max-width: 1000px) { .demo { grid-template-columns: 1fr; } .phone { width: 100%; max-width: 410px; } .stats { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 860px) { .lower, .summary, .lab .row2 { grid-template-columns: 1fr; } .links { display: none; } }
  @media (prefers-reduced-motion: reduce) { .packet.anim, .seg.anim, .st.arrive .orb { animation-duration: .01s; animation-delay: 0s; } }
</style>
</head>
<body>
<div class="deck">
  <header class="top">
    <span class="brand">Backend E2EE</span>
    <nav class="tabs" id="tabs" aria-label="Secciones"></nav>
    <span class="links"><a href="/admin">Panel de datos</a><a href="/admin/flujo" class="active">Flujo del proceso</a></span>
  </header>
  <main id="view"></main>
  <footer class="nav" id="nav">
    <button class="ctl" onclick="go(-1)" aria-label="Paso anterior">‹ Anterior</button>
    <button class="ctl" onclick="go(1)" aria-label="Siguiente paso">Siguiente ›</button>
    <div class="dots" id="dots"></div>
    <span class="count" id="count"></span>
    <button class="ctl" id="playBtn" onclick="togglePlay()">▶ Reproducir</button>
    <button class="ctl" onclick="fullscreen()" aria-label="Pantalla completa">⛶</button>
  </footer>
</div>
<script>
// [kind, name, subtitle, glyph]
const LANES = {
  me: ['device', 'Tu teléfono', 'tiene tus llaves', '📱'],
  server: ['server', 'Servidor', 'sin llaves: solo guarda', '🖥️'],
  sofia: ['other', 'Teléfono de Sofía', 'cuenta invitada', '📱'],
  intruder: ['bad', 'Cuenta no autorizada', 'sin invitación', '🕵️'],
  newPhone: ['other', 'Teléfono nuevo', 'aún sin llaves', '📲'],
};

// `crypt` marks steps that show real encryption output (computed in the browser);
// `live` marks steps that show a real record stored by this server.
const FLOWS = [
  {
    id: 'general', tab: 'Visión general', title: 'Un mensaje, de extremo a extremo', lanes: ['me', 'server', 'sofia'],
    intro: 'El contenido se cifra en un extremo y solo se descifra en otro extremo autorizado. En el medio, la red y el servidor solo manejan cajas cerradas.',
    steps: [
      { lane: 'me', title: 'Escribes en tu diario', detail: 'Lugar, nota, valoración y fotos, en texto claro, solo dentro de tu teléfono.' },
      { lane: 'me', title: 'Se cierra la caja', detail: 'El teléfono cifra todo con una llave que nunca sale de él.', crypt: 'encrypt', send: { to: 'server', label: 'HTTPS · solo texto cifrado' } },
      { lane: 'server', title: 'El servidor guarda la caja cerrada', detail: 'Puede almacenarla, respaldarla y entregarla, pero no abrirla.', live: true },
      { lane: 'server', title: 'Entrega la caja a quien autorizaste', detail: 'Solo si compartiste la colección con esa persona.', send: { to: 'sofia', label: 'caja + sobre con la llave' } },
      { lane: 'sofia', title: 'Solo el destino autorizado la abre', detail: 'El teléfono de Sofía usa su llave privada para abrir el sobre y descifrar.', crypt: 'decrypt' },
    ],
  },
  {
    id: 'guardar', tab: '1 · Guardar', title: 'Guardar en el diario', lanes: ['me', 'server'],
    intro: 'POC-1, datos privados. Cada lugar se cifra en el teléfono con AES-256-GCM antes de sincronizarse. El servidor no recibe la llave.',
    steps: [
      { lane: 'me', title: 'Guardas un lugar', detail: 'Ej.: “Catarata del Toro” con la nota “ir temprano y con zapatos para barro”.' },
      { lane: 'me', title: 'Se convierte en datos y se cifra', detail: 'Llave de datos de 256 bits (solo en el teléfono) + nonce aleatorio → <code>AES-256-GCM</code>. El resultado incluye una etiqueta (<code>mac</code>) que detecta cualquier alteración.', crypt: 'encrypt' },
      { lane: 'me', title: 'Se calcula un id opaco', detail: 'HMAC del id del lugar: el servidor no puede saber qué lugar es.', send: { to: 'server', label: 'PUT /records · cipherText, nonce, mac' } },
      { lane: 'server', title: 'El servidor almacena', detail: 'Lo guarda en <code>data.json</code> tal cual llegó. Así se ve un registro real.', live: true },
      { lane: 'server', title: 'Al leer, devuelve la caja', detail: 'No puede “ayudar” a descifrarla: no tiene la llave.', send: { to: 'me', label: 'GET /records · texto cifrado' } },
      { lane: 'me', title: 'Tu teléfono descifra', detail: 'Verifica la etiqueta y recupera exactamente el texto original. Si alguien cambió un solo byte, falla (pruébalo en el Laboratorio).', crypt: 'decrypt' },
    ],
  },
  {
    id: 'compartir', tab: '2 · Compartir', title: 'Compartir una colección', lanes: ['me', 'server', 'sofia', 'intruder'],
    intro: 'POC-2, contenido compartido. Una llave nueva por colección; esa llave viaja dentro de un “sobre” que solo la llave privada de cada invitado puede abrir (X25519 + HKDF).',
    steps: [
      { lane: 'sofia', title: 'Sofía publica su llave pública', detail: 'Su llave privada se queda en su teléfono.', send: { to: 'server', label: 'PUT /keys · llave pública', icon: '🔑' } },
      { lane: 'me', title: 'Eliges qué compartir', detail: 'Una colección, por ejemplo “Rincones de café”. Tus notas privadas solo van si activas el interruptor.' },
      { lane: 'me', title: 'Llave nueva + contenido cifrado', detail: 'Se genera una llave solo para esta colección y se cifra su contenido.', crypt: 'encrypt' },
      { lane: 'server', title: 'El servidor entrega la llave pública', detail: 'Es pública: no sirve para descifrar.', send: { to: 'me', label: 'GET /keys/sofia', icon: '🔑' } },
      { lane: 'me', title: 'Se prepara un sobre para Sofía', detail: 'La llave de la colección se cifra con la llave pública de Sofía.', send: { to: 'server', label: 'PUT /collections · contenido + sobres', icon: '✉️' } },
      { lane: 'server', title: 'Guarda contenido y sobres', detail: 'Todo cifrado. Ni el título de la colección es visible.', live: 'collection' },
      { lane: 'server', title: 'Sofía pide su sobre', detail: 'El servidor solo se lo da a quien fue invitado.', send: { to: 'sofia', label: 'GET sobre de Sofía', icon: '✉️' } },
      { lane: 'sofia', title: 'Sofía abre y lee', detail: 'Su llave privada abre el sobre, obtiene la llave y descifra la colección.', crypt: 'decrypt' },
      { lane: 'intruder', title: 'Otra cuenta lo intenta', detail: 'Pide un sobre para su cuenta.', send: { to: 'server', label: 'GET sobre', blocked: true } },
      { lane: 'server', title: 'No hay sobre para esa cuenta', detail: 'Responde 404. Y aunque robara el sobre de Sofía, sin la llave privada de Sofía no lo puede abrir.', send: { to: 'intruder', label: '404 · sin acceso', blocked: true } },
    ],
  },
  {
    id: 'revocar', tab: '3 · Revocar', title: 'Revocar un acceso', lanes: ['me', 'server', 'sofia'],
    intro: 'Revocar es rotar la llave. Se impide el acceso futuro; lo que Sofía ya vio o copió no se puede borrar de su teléfono.',
    steps: [
      { lane: 'me', title: 'Revocas el acceso de Sofía', detail: 'Tu teléfono abre la colección con tu propio sobre.' },
      { lane: 'me', title: 'Nueva llave, nuevo cifrado', detail: 'Se genera otra llave y se vuelve a cifrar el contenido.', crypt: 'encrypt' },
      { lane: 'me', title: 'Sobres solo para quienes siguen', detail: 'Sofía ya no recibe sobre.', send: { to: 'server', label: 'PUT /collections · llave nueva', icon: '✉️' } },
      { lane: 'server', title: 'Reemplaza la versión anterior', detail: 'Cambia el <code>keyId</code> de la colección.' },
      { lane: 'sofia', title: 'Sofía intenta abrirla', detail: 'Ya no existe un sobre para ella.', send: { to: 'server', label: 'GET sobre', blocked: true } },
      { lane: 'server', title: 'Sin acceso', detail: 'Responde 404. Lo que descifró antes sigue en su teléfono: por eso la app lo advierte.', send: { to: 'sofia', label: '404 · revocado', blocked: true } },
    ],
  },
  {
    id: 'recuperar', tab: '4 · Recuperación', title: 'Recuperar tus llaves', lanes: ['me', 'server', 'newPhone'],
    intro: 'Si el servidor no tiene tus llaves, no puede restaurarlas. Por eso existe la frase de recuperación, que deriva una llave con PBKDF2-HMAC-SHA256 (600 000 iteraciones).',
    steps: [
      { lane: 'me', title: 'Creas tu frase de recuperación', detail: 'Ej.: <code>XSFV-4146-V88S-H21T-6VT4-18W6</code>. Solo tú la guardas.' },
      { lane: 'me', title: 'La frase se convierte en llave', detail: 'PBKDF2 con 600 000 iteraciones: probar frases al azar es muy costoso.' },
      { lane: 'me', title: 'Se cifran las llaves del teléfono', detail: 'Tu llave de datos y tu llave privada quedan dentro de un respaldo cifrado.', send: { to: 'server', label: 'PUT /recovery · respaldo cifrado' } },
      { lane: 'server', title: 'Guarda el respaldo', detail: 'Ve salt e iteraciones, nunca la frase ni las llaves.', live: 'backup' },
      { lane: 'newPhone', title: 'Cambias de teléfono', detail: 'Escribes tu frase en el teléfono nuevo.', send: { to: 'server', label: 'GET /recovery' } },
      { lane: 'server', title: 'Entrega el respaldo cifrado', detail: 'Lo entregaría a cualquiera: sin la frase es inútil.', send: { to: 'newPhone', label: 'respaldo cifrado' } },
      { lane: 'newPhone', title: 'Frase correcta, llaves recuperadas', detail: 'Descarga el diario y lo descifra. Con una frase incorrecta, la etiqueta GCM falla y no se obtiene nada.' },
    ],
  },
  { id: 'demo', tab: '▶ Demo en vivo', demo: true },
  { id: 'dos', tab: '▶ Dos teléfonos', two: true },
  { id: 'resumen', tab: 'Qué ve el servidor', summary: true },
  { id: 'lab', tab: '🧪 Laboratorio', lab: true },
];

let flow = FLOWS[0], cur = 0, animate = true, live = null, liveJson = '', playTimer = null;

function esc(s) { return String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
const cut = (s, n) => { s = String(s ?? ''); return s.length > n ? s.slice(0, n) + '…' : s; };
const enc = new TextEncoder(), dec = new TextDecoder();
const hex = u => [...u].map(b => b.toString(16).padStart(2, '0')).join('');
const rnd = n => hex(crypto.getRandomValues(new Uint8Array(Math.ceil(n / 2)))).slice(0, n);
const slides = f => (f.steps ? f.steps.length + 1 : 1);

// ---------- real encryption sample (WebCrypto) ----------
const PLAIN = 'Catarata del Toro · ir temprano y con zapatos para barro';
let demo = null;
async function makeDemo() {
  try {
    const key = await crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, true, ['encrypt']);
    const nonce = crypto.getRandomValues(new Uint8Array(12));
    const out = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, key, enc.encode(PLAIN)));
    const raw = new Uint8Array(await crypto.subtle.exportKey('raw', key));
    demo = { plain: PLAIN, key: hex(raw), nonce: hex(nonce), ct: hex(out.slice(0, -16)), tag: hex(out.slice(-16)) };
  } catch (_) { demo = null; }
  render();
}

function fld(k, v, cls) { return `<div class="fld"><div class="k">${k}</div><div class="v ${cls || ''}">${v}</div></div>`; }

function cryptBlock(kind) {
  if (!demo) return '<div class="note">El cifrado de muestra requiere abrir la página desde localhost (WebCrypto).</div>';
  const scr = (final, from, cls, k) => `<div class="fld"><div class="k">${k}</div><div class="v ${cls} scr" data-final="${esc(final)}" data-animate="${animate ? 1 : 0}">${esc(animate ? from : final)}</div></div>`;
  if (kind === 'encrypt') {
    return fld('Texto claro, solo en el teléfono', esc(demo.plain), 'clear') +
      scr(demo.ct, demo.plain, 'cipher', 'Lo que sale hacia el servidor (AES-256-GCM)') +
      fld('nonce y mac', `nonce ${demo.nonce}<br>mac ${demo.tag}`, 'small') +
      fld('Llave (nunca sale del teléfono)', demo.key.slice(0, 20) + '…', 'small');
  }
  return fld('Llega cifrado', esc(demo.ct), 'cipher') +
    scr(demo.plain, demo.ct, 'clear', 'Se abre con la llave correcta y la etiqueta coincide');
}

function liveSample(kind) {
  if (!live) return '<div class="note">Inicia el backend y usa la app para ver datos reales aquí.</div>';
  if (kind === 'collection') {
    const c = Object.values(live.collections)[0];
    if (!c) return '<div class="note">Aún no hay colecciones compartidas.</div>';
    return fld('Colección guardada en el servidor', `{ "id": "${esc(c.id)}", "keyId": "${esc(c.keyId)}",<br>&nbsp;&nbsp;"content": { "cipherText": "${esc(cut(c.content.cipherText, 60))}" },<br>&nbsp;&nbsp;"grants": [${c.grants.map(g => '"' + esc(g.recipientId) + '"').join(', ')}] }`, 'cipher');
  }
  if (kind === 'backup') {
    const [acct, b] = Object.entries(live.recoveryBackups)[0] || [];
    if (!b) return '<div class="note">Aún no hay respaldos de recuperación.</div>';
    return fld('Respaldo guardado en el servidor', `{ "account": "${esc(acct)}", "kdf": "${esc(b.kdf)}", "iterations": ${b.iterations},<br>&nbsp;&nbsp;"salt": "${esc(b.salt)}", "cipherText": "${esc(cut(b.cipherText, 60))}" }`, 'cipher');
  }
  const r = Object.values(live.records).flatMap(x => Object.values(x))[0];
  if (!r) return '<div class="note">Aún no hay registros: abre la app y guarda un lugar.</div>';
  return fld('Registro guardado en el servidor', `{ "id": "${esc(r.id)}", "cryptoVersion": "${esc(r.cryptoVersion)}",<br>&nbsp;&nbsp;"nonce": "${esc(r.nonce)}", "mac": "${esc(r.mac)}",<br>&nbsp;&nbsp;"cipherText": "${esc(cut(r.cipherText, 70))}" }`, 'cipher');
}

const packetIcon = send => send.blocked ? '✖' : (send.icon || '🔒');

function routeHtml(step) {
  const lanes = flow.lanes, n = lanes.length, idx = id => lanes.indexOf(id);
  const x = i => ((i + 0.5) / n) * 100;
  let html = `<div class="route"><div class="track" style="left:${x(0)}%;width:${x(n - 1) - x(0)}%"></div>`;
  const send = step && step.send;
  const from = step ? idx(step.lane) : -1, to = send ? idx(send.to) : -1;
  lanes.forEach((l, i) => {
    const [kind, name, sub, glyph] = LANES[l];
    const active = step && (i === from && !send || i === from);
    const arrive = send && i === to && animate;
    const lit = step ? (i === from || (send && i === to && !animate)) : false;
    html += `<div class="st ${kind}${lit || (active && !arrive) ? ' on' : ''}${arrive ? ' arrive' : ''}${step && !active && i !== to ? ' dim' : ''}" style="left:${x(i)}%">` +
      `<div class="orb">${glyph}</div><div class="nm">${name}</div><div class="sb">${sub}</div></div>`;
  });
  if (send) {
    const a = Math.min(from, to), b = Math.max(from, to), ltr = to > from;
    const l0 = x(a), w = x(b) - x(a), start = ltr ? l0 : l0 + w, end = ltr ? l0 + w : l0;
    const stop = start + (end - start) * 0.82, an = animate ? ' anim' : '', bl = send.blocked ? ' blocked' : '';
    html += `<div class="seg${ltr ? '' : ' rtl'}${bl}${an}" style="left:${l0}%;width:${w}%"></div>` +
      `<div class="edgelabel${bl}" style="left:${l0 + w / 2}%">${send.label}</div>` +
      `<div class="packet${bl}${an}" style="--from:${start}%;--to:${send.blocked ? stop : end}%;--stop:${stop}%">${packetIcon(send)}</div>`;
  }
  return html + '</div>';
}

function render() {
  document.getElementById('tabs').innerHTML = FLOWS.map((f, i) =>
    `<button class="${f === flow ? 'active' : ''}" onclick="pick('${f.id}')" title="Tecla ${i + 1}">${f.tab}</button>`).join('');
  const view = document.getElementById('view');
  const showNav = !flow.lab && !flow.summary && !flow.demo && !flow.two;
  document.getElementById('nav').style.display = showNav ? '' : 'none';
  if (flow.lab) { renderLab(); return; }
  if (flow.demo) { renderDemo(); return; }
  if (flow.two) { renderTwo(); return; }
  if (flow.summary) {
    view.innerHTML = `<div class="summary"><div class="yes"><h2>Lo que el servidor sí ve</h2><ul>
      <li>Texto cifrado (<code>cipherText</code>), <code>nonce</code> y etiqueta de autenticidad (<code>mac</code>)</li>
      <li>Ids opacos, versión del cifrado y qué cuenta tiene acceso a qué</li>
      <li>Llaves públicas y llaves de colección ya envueltas</li>
      <li>Metadatos: tamaño, hora, cuentas involucradas</li></ul></div>
      <div class="no"><h2>Lo que el servidor no ve</h2><ul>
      <li>Nombres de lugares, notas, valoraciones, fotos</li>
      <li>Títulos de las colecciones compartidas</li>
      <li>Llaves privadas, llaves de datos ni la frase de recuperación</li>
      <li>Por eso no puede leer, modificar sin ser detectado ni restaurar tus datos</li></ul></div></div>`;
    return;
  }

  const step = cur > 0 ? flow.steps[cur - 1] : null;
  const title = step ? step.title : flow.title;
  const detail = step ? step.detail : flow.intro;
  let panel = '';
  if (step && (step.crypt || step.live)) {
    const who = step.lane === 'server' ? 'Lo que ve el servidor' : `En ${LANES[step.lane][1].toLowerCase()}`;
    panel = `<aside class="panel"><h3>${who}</h3>${step.live ? liveSample(step.live) : ''}${step.crypt ? cryptBlock(step.crypt) : ''}</aside>`;
  }
  view.innerHTML = `<div class="stage">${routeHtml(step)}</div>` +
    `<div class="lower${panel ? '' : ' solo'}"><div class="cap"><h2>${title}</h2><p>${detail}</p></div>${panel}</div>`;

  const total = slides(flow);
  document.getElementById('dots').innerHTML = Array.from({ length: total }, (_, i) =>
    `<button class="dot${i === cur ? ' on' : i < cur ? ' past' : ''}" onclick="jump(${i})" aria-label="Ir al paso ${i}"></button>`).join('');
  document.getElementById('count').textContent = cur === 0 ? 'Inicio' : `${cur} de ${total - 1}`;
  runScramble();
}

// The ciphertext "forms" on screen: characters settle one by one into the final text.
function runScramble() {
  document.querySelectorAll('.scr[data-animate="1"]').forEach(el => {
    const fin = el.dataset.final, t0 = performance.now(), dur = 1300;
    const tick = now => {
      const p = Math.min(1, (now - t0) / dur), k = Math.floor(p * fin.length);
      el.textContent = fin.slice(0, k) + rnd(fin.length - k);
      if (p < 1) requestAnimationFrame(tick); else el.textContent = fin;
    };
    requestAnimationFrame(tick);
  });
}

function stopPlay() {
  if (playTimer) { clearInterval(playTimer); playTimer = null; }
  const b = document.getElementById('playBtn');
  if (b) { b.classList.remove('on'); b.textContent = '▶ Reproducir'; }
}
function togglePlay() {
  if (playTimer) { stopPlay(); return; }
  if (cur >= slides(flow) - 1) { cur = 0; animate = true; render(); }
  const b = document.getElementById('playBtn');
  b.classList.add('on'); b.textContent = '⏸ Pausar';
  playTimer = setInterval(() => { if (cur >= slides(flow) - 1) stopPlay(); else go(1); }, 4200);
}
function pick(id) { stopPlay(); flow = FLOWS.find(f => f.id === id); cur = 0; animate = true; render(); }
function jump(i) { animate = i > cur; cur = i; render(); }
function go(d) {
  const next = Math.max(0, Math.min(slides(flow) - 1, cur + d));
  if (next === cur) return;
  animate = d > 0; cur = next; render();
}
function fullscreen() {
  if (document.fullscreenElement) document.exitFullscreen(); else document.documentElement.requestFullscreen();
}
document.addEventListener('keydown', e => {
  if (/^(INPUT|TEXTAREA)$/.test(e.target.tagName)) return;
  if (/^[1-9]$/.test(e.key) && FLOWS[+e.key - 1]) { pick(FLOWS[+e.key - 1].id); return; }
  if (e.key === 'f' || e.key === 'F') { fullscreen(); return; }
  if (flow.lab || flow.summary || flow.demo || flow.two) return;
  if (['ArrowRight', ' ', 'PageDown'].includes(e.key)) { e.preventDefault(); go(1); }
  if (['ArrowLeft', 'PageUp'].includes(e.key)) go(-1);
});

// ---------- laboratory ----------
let L = null, S = null;   // L: AES-GCM lab state, S: key-sharing lab state
const aesKey = () => crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, true, ['encrypt', 'decrypt']);

async function labEncrypt() {
  const plain = document.getElementById('labText').value || ' ';
  const key = await aesKey();
  const nonce = crypto.getRandomValues(new Uint8Array(12));
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, key, enc.encode(plain)));
  L = { plain, key, keyHex: hex(new Uint8Array(await crypto.subtle.exportKey('raw', key))), nonce, ct, result: null };
  renderLab();
}
async function labDecrypt(mode) {
  let ct = L.ct, key = L.key;
  if (mode === 'tamper') { ct = ct.slice(); ct[0] ^= 1; }
  if (mode === 'otherkey') key = await aesKey();
  try {
    const p = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: L.nonce }, key, ct);
    L.result = { ok: true, mode, text: dec.decode(p), ct };
  } catch (_) { L.result = { ok: false, mode, ct }; }
  renderLab();
}

async function curve() {
  try { await crypto.subtle.generateKey({ name: 'X25519' }, true, ['deriveBits']); return { name: 'X25519' }; }
  catch (_) { return { name: 'ECDH', namedCurve: 'P-256' }; }
}
async function wrapKey(priv, pub, algo) {
  const bits = await crypto.subtle.deriveBits({ name: algo.name, public: pub }, priv, 256);
  const base = await crypto.subtle.importKey('raw', bits, 'HKDF', false, ['deriveKey']);
  return crypto.subtle.deriveKey({ name: 'HKDF', hash: 'SHA-256', salt: new Uint8Array(32), info: enc.encode('wanderboard-envelope') },
    base, { name: 'AES-GCM', length: 256 }, true, ['encrypt', 'decrypt']);
}
async function labShare() {
  const algo = await curve();
  const gen = () => crypto.subtle.generateKey(algo, true, ['deriveBits']);
  const [me, sofia, intruder] = [await gen(), await gen(), await gen()];
  const pubHex = async k => hex(new Uint8Array(await crypto.subtle.exportKey('raw', k.publicKey)));
  const collKey = crypto.getRandomValues(new Uint8Array(32));
  const nonce = crypto.getRandomValues(new Uint8Array(12));
  const envelope = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, await wrapKey(me.privateKey, sofia.publicKey, algo), collKey));
  const open = async priv => {
    try { return new Uint8Array(await crypto.subtle.decrypt({ name: 'AES-GCM', iv: nonce }, await wrapKey(priv, me.publicKey, algo), envelope)); }
    catch (_) { return null; }
  };
  const s = await open(sofia.privateKey), i = await open(intruder.privateKey);
  S = { algo: algo.name === 'X25519' ? 'X25519' : 'ECDH P-256 (este navegador no trae X25519)',
        pubMe: await pubHex(me), pubSofia: await pubHex(sofia), pubIntruder: await pubHex(intruder),
        coll: hex(collKey), envelope: hex(envelope), sofiaOk: !!s && hex(s) === hex(collKey), intruderOk: !!i };
  renderLab();
}

function renderLab() {
  const mono = t => `<span class="mono">${esc(t)}</span>`;
  let a = `<div class="card"><h3>1 · Cifrar y alterar un mensaje (AES-256-GCM)</h3>
    <textarea id="labText" rows="2">${esc(L ? L.plain : PLAIN)}</textarea>
    <div class="btns"><button class="primary" onclick="labEncrypt()">🔒 Cifrar</button>`;
  if (L) a += `<button onclick="labDecrypt('ok')">🔓 Descifrar con la llave correcta</button>
      <button onclick="labDecrypt('tamper')">✏️ Alterar 1 byte y descifrar</button>
      <button onclick="labDecrypt('otherkey')">🗝️ Descifrar con otra llave</button>`;
  a += '</div>';
  if (L) {
    const ctHex = hex(L.ct);
    a += `<div class="row2"><div class="box device"><div class="t">📱 Tu teléfono (tiene la llave)</div>
        <div>Texto: ${mono(L.plain)}</div><div>Llave: ${mono(L.keyHex)}</div></div>
      <div class="box server"><div class="t">🖥️ Lo que ve el servidor</div>
        <div>nonce: ${mono(hex(L.nonce))}</div><div>cipherText + mac: ${mono(ctHex)}</div>
        <div class="note">Sin llave: no hay forma de leerlo.</div></div></div>`;
    if (L.result) {
      const r = L.result;
      const tamperedHex = r.mode === 'tamper' ? `<span class="diff">${hex(r.ct.slice(0, 1))}</span>${hex(r.ct.slice(1))}` : '';
      const label = { ok: 'Llave correcta', tamper: 'Se alteró el primer byte del texto cifrado (en rojo)', otherkey: 'Llave distinta' }[r.mode];
      a += r.ok
        ? `<div class="box good" style="margin-top:10px"><div class="t">✅ ${label}: se descifra</div>${mono(r.text)}</div>`
        : `<div class="box bad" style="margin-top:10px"><div class="t">⛔ ${label}: el descifrado falla</div>
            ${tamperedHex ? '<div class="mono">' + tamperedHex + '</div>' : ''}
            <div>La etiqueta de autenticidad (mac) no coincide, así que no se obtiene ningún texto. El servidor tampoco puede modificar datos sin que se note.</div></div>`;
    }
  }
  a += '</div>';

  let b = `<div class="card"><h3>2 · Compartir una llave con Sofía (sobre cifrado)</h3>
    <div class="note">Cada teléfono tiene un par de llaves. Con la llave privada de uno y la pública del otro se obtiene el mismo secreto, se pasa por HKDF y con eso se cierra el sobre que contiene la llave de la colección.</div>
    <div class="btns"><button class="primary" onclick="labShare()">✉️ Generar y compartir</button></div>`;
  if (S) {
    b += `<div class="row2"><div class="box server"><div class="t">🖥️ Lo que ve el servidor (${esc(S.algo)})</div>
        <div>llave pública (tú): ${mono(S.pubMe)}</div><div>llave pública (Sofía): ${mono(S.pubSofia)}</div>
        <div>sobre cifrado: ${mono(S.envelope)}</div></div>
      <div class="box device"><div class="t">🔑 Llave de la colección (secreta)</div>${mono(S.coll)}</div></div>
      <div class="row2" style="margin-top:10px">
      <div class="box ${S.sofiaOk ? 'good' : 'bad'}"><div class="t">${S.sofiaOk ? '✅ Sofía abre el sobre y obtiene la misma llave' : '⛔ Error inesperado con Sofía'}</div></div>
      <div class="box ${S.intruderOk ? 'bad' : 'good'}"><div class="t">${S.intruderOk ? '⚠️ La cuenta no autorizada lo abrió' : '✅ Una cuenta no autorizada no puede abrirlo'}</div>
        <div class="note">Aunque copie el sobre, su llave privada deriva otro secreto y el descifrado falla.</div></div></div>`;
  }
  b += '</div>';
  const textArea = document.getElementById('labText');
  const keep = textArea ? textArea.value : null;
  document.getElementById('view').innerHTML = `<div class="lab"><h2>Laboratorio en vivo</h2>
    <p class="lead">Cifrado real con WebCrypto en este navegador: las mismas primitivas que usa la app (AES-256-GCM, X25519, HKDF). Sirve para ver qué pasa si alguien altera el mensaje o intenta abrir algo que no es suyo.</p>${a}${b}</div>`;
  if (keep !== null) document.getElementById('labText').value = keep;
}

// ---------- live demo: the real app next to what the server stores ----------
let prevCounts = null;
function renderDemo() {
  const app = new URLSearchParams(location.search).get('app') || 'http://localhost:8097/';
  document.getElementById('view').innerHTML = `<div class="demo">
    <div class="phone"><iframe src="${esc(app)}" title="App Spotly"></iframe></div>
    <div class="feed">
      <h2>Lo que el servidor guarda ahora</h2>
      <div id="demoStats"></div>
      <div class="panel"><h3>¿Puede el servidor leer tu diario? Búscalo en todo lo que guarda</h3>
        <div class="row"><input id="demoQ" value="Costa Rica" aria-label="Texto a buscar"><button onclick="demoSearch()">Buscar</button></div>
        <div id="demoVerdict"></div></div>
      <div class="panel"><h3>Qué hacer en la app</h3><ol>
        <li>Perfil › Privacidad y cifrado: los lugares se cifran y suben solos.</li>
        <li>Elige una colección y pulsa “Compartir con Sofía”.</li>
        <li>Pulsa “Abrir como Sofía” (abre) y “Abrir como cuenta no autorizada” (no abre).</li></ol></div>
    </div></div>`;
  prevCounts = null;
  updateDemo();
}
function updateDemo() {
  const el = document.getElementById('demoStats');
  if (!el) return;
  if (!live) { el.innerHTML = '<div class="note">Sin conexión con el servidor.</div>'; return; }
  const recs = Object.values(live.records).flatMap(x => Object.values(x));
  const grants = Object.values(live.collections).reduce((n, c) => n + c.grants.length, 0);
  const c = { rec: recs.length, col: Object.keys(live.collections).length, key: Object.keys(live.publicKeys).length, grant: grants };
  const stat = (id, label) => `<div class="stat${prevCounts && c[id] > prevCounts[id] ? ' bump' : ''}"><b>${c[id]}</b><span>${label}</span></div>`;
  const last = recs[recs.length - 1];
  el.innerHTML = `<div class="stats">${stat('rec', 'lugares cifrados')}${stat('col', 'colecciones')}${stat('key', 'llaves públicas')}${stat('grant', 'sobres con llave')}</div>` +
    `<div class="panel" style="margin-top:10px"><h3>Último registro recibido</h3>${last
      ? fld('cipherText (lo único que llega)', esc(cut(last.cipherText, 110)), 'cipher') + fld('nonce · mac', `${esc(last.nonce)} · ${esc(last.mac)}`, 'small')
      : '<div class="note">Aún no hay registros: abre “Privacidad y cifrado” en la app.</div>'}</div>`;
  prevCounts = c;
}
const demoSearch = () => runSearch('demoQ', 'demoVerdict');
async function runSearch(inputId, outId) {
  const q = document.getElementById(inputId).value.trim(), out = document.getElementById(outId);
  if (!q) return;
  try {
    const r = await (await fetch('/admin/search?q=' + encodeURIComponent(q))).json();
    out.className = 'verdict ' + (r.matches === 0 ? 'ok' : 'bad');
    out.textContent = r.matches === 0 ? `0 coincidencias de “${q}”: el servidor no tiene ese texto en ningún lado.` : `${r.matches} coincidencias de “${q}”.`;
  } catch (_) { out.className = 'verdict bad'; out.textContent = 'No se pudo consultar el servidor.'; }
}

// ---------- two phones: sender and receiver around the server ----------
let prevTwo = null, twoSnap = null, twoEvents = [];
const liveCounts = d => {
  const recs = Object.values(d.records).flatMap(x => Object.values(x));
  return { recs, rec: recs.length, col: Object.keys(d.collections).length, key: Object.keys(d.publicKeys).length,
           grant: Object.values(d.collections).reduce((n, c) => n + c.grants.length, 0) };
};
function renderTwo() {
  const q = new URLSearchParams(location.search);
  const appA = q.get('appA') || 'http://localhost:8097/?rol=emisor', appB = q.get('appB') || 'http://localhost:8097/?rol=sofia';
  document.getElementById('view').innerHTML = `<div class="two">
    <div class="pbox"><h3>Teléfono de Ana (emisor)</h3><div class="phone"><iframe src="${esc(appA)}" title="Teléfono de Ana (emisor)"></iframe></div></div>
    <div class="feed">
      <h2>Servidor: solo ve cajas cerradas</h2>
      <div id="twoStats"></div>
      <div class="panel"><h3>Qué llegó, en orden</h3><ul class="tl" id="twoTimeline"></ul></div>
      <div class="panel"><h3>¿Puede el servidor leer el diario? Búscalo en todo lo que guarda</h3>
        <div class="row"><input id="twoQ" value="Costa Rica" aria-label="Texto a buscar"><button onclick="runSearch('twoQ', 'twoVerdict')">Buscar</button></div>
        <div id="twoVerdict"></div></div>
      <div class="panel"><h3>Qué hacer</h3><ol>
        <li>En el teléfono de Ana: Perfil › Privacidad y cifrado.</li>
        <li>Elige una colección y pulsa “Compartir con Sofía”.</li>
        <li>En el teléfono de Sofía aparece “Te compartieron una colección”: pulsa “Abrir”.</li>
        <li>En el de Ana, “Revocar acceso de Sofía”: el servidor retira el sobre.</li></ol></div>
    </div>
    <div class="pbox"><h3>Teléfono de Sofía (receptor)</h3><div class="phone"><iframe src="${esc(appB)}" title="Teléfono de Sofía (receptor)"></iframe></div></div>
  </div>`;
  prevTwo = null; twoSnap = null; twoEvents = [];
  updateTwo();
}
function twoDiff(a, b) {
  const out = [];
  Object.keys(b.publicKeys).filter(k => !(k in a.publicKeys)).forEach(k => out.push(`🔑 Llegó la llave pública de ${esc(k)}`));
  Object.values(b.collections).forEach(c => {
    const old = a.collections[c.id];
    if (!old) { out.push(`📦 Llegó una colección cifrada ${esc(cut(c.id, 6))} con ${c.grants.length} sobres`); return; }
    const had = new Set(old.grants.map(g => g.recipientId)), has = new Set(c.grants.map(g => g.recipientId));
    c.grants.filter(g => !had.has(g.recipientId)).forEach(g => out.push(`✉️ Se agregó un sobre para ${esc(g.recipientId)}`));
    old.grants.filter(g => !has.has(g.recipientId)).forEach(g => out.push(`⛔ Se retiró el sobre de ${esc(g.recipientId)}`));
  });
  const n = liveCounts(b).rec - liveCounts(a).rec;
  if (n > 0) out.push((n === 1 ? '🔒 Llegó 1 registro cifrado' : `🔒 Llegaron ${n} registros cifrados`));
  return out;
}
function updateTwo() {
  const el = document.getElementById('twoStats');
  if (!el) return;
  if (!live) { el.innerHTML = '<div class="note">Sin conexión con el servidor.</div>'; return; }
  if (twoSnap) {
    const t = new Date(), p = n => String(n).padStart(2, '0'), time = `${p(t.getHours())}:${p(t.getMinutes())}:${p(t.getSeconds())}`;
    twoDiff(twoSnap, live).forEach(text => twoEvents.unshift({ time, text }));
    twoEvents = twoEvents.slice(0, 8);
  }
  twoSnap = live;
  const tl = document.getElementById('twoTimeline');
  tl.innerHTML = twoEvents.length ? twoEvents.map(e => `<li><time>${e.time}</time><span>${e.text}</span></li>`).join('')
    : '<li class="note">Esperando actividad de los teléfonos…</li>';
  const c = liveCounts(live);
  const stat = (id, label) => `<div class="stat${prevTwo && c[id] > prevTwo[id] ? ' bump' : ''}"><b>${c[id]}</b><span>${label}</span></div>`;
  const last = c.recs[c.recs.length - 1];
  el.innerHTML = `<div class="stats">${stat('rec', 'lugares cifrados')}${stat('col', 'colecciones')}${stat('key', 'llaves públicas')}${stat('grant', 'sobres con llave')}</div>` +
    `<div class="panel" style="margin-top:10px"><h3>Último registro recibido</h3>${last
      ? fld('cipherText (lo único que llega)', esc(cut(last.cipherText, 110)), 'cipher') + fld('nonce · mac', `${esc(last.nonce)} · ${esc(last.mac)}`, 'small')
      : '<div class="note">Aún no hay registros.</div>'}</div>`;
  prevTwo = c;
}

async function refresh() {
  try {
    const json = JSON.stringify((await (await fetch('/admin/data')).json()).data);
    if (json === liveJson) return;
    liveJson = json; live = JSON.parse(json);
  } catch (_) { if (liveJson === '') return; liveJson = ''; live = null; }
  if (flow.demo) { updateDemo(); return; }
  if (flow.two) { updateTwo(); return; }
  if (!flow.lab) { const keep = animate; animate = false; render(); animate = keep; }
}
render();
makeDemo();
refresh();
setInterval(refresh, 1500);
</script>
</body>
</html>
''';
