/// Flow diagrams for presenting the E2EE proof of concept. Each flow is a
/// swimlane that can be revealed step by step (buttons or arrow keys).
/// Self-contained: no external scripts, so it works offline.
const flowPage = r'''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Backend E2EE · Flujo del proceso</title>
<style>
  :root { --device: #2e7d5b; --device-bg: #e7f4ee; --server: #55606e; --server-bg: #eceff2;
          --other: #8a5a14; --other-bg: #fbf1e1; --bad: #b3261e; --bad-bg: #fde8e7; }
  * { box-sizing: border-box; }
  body { font-family: system-ui, sans-serif; margin: 0; background: #f4f1ec; color: #222; }
  header { background: #2f3e4e; color: #fff; padding: 14px 24px; display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
  header h1 { margin: 0; font-size: 20px; }
  nav a { color: #fff; opacity: .75; margin-right: 16px; text-decoration: none; }
  nav a.active { opacity: 1; border-bottom: 2px solid #fff; }
  main { padding: 16px 24px; max-width: 1200px; margin: 0 auto; }
  .tabs { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
  .tabs button { padding: 10px 16px; font-size: 15px; border: 1px solid #ccc; border-radius: 20px; background: #fff; cursor: pointer; }
  .tabs button.active { background: #2f3e4e; color: #fff; border-color: #2f3e4e; }
  .intro { background: #fff; border-radius: 10px; padding: 14px 18px; box-shadow: 0 1px 3px #0002; margin-bottom: 12px; font-size: 16px; line-height: 1.45; }
  .controls { display: flex; gap: 8px; align-items: center; margin-bottom: 12px; }
  .controls button { padding: 8px 14px; font-size: 14px; cursor: pointer; border-radius: 6px; border: 1px solid #bbb; background: #fff; }
  .controls .counter { margin-left: 8px; color: #555; }
  .board { background: #fff; border-radius: 10px; padding: 12px; box-shadow: 0 1px 3px #0002; }
  .lanes, .row { display: grid; gap: 0 16px; }
  .lane-head { text-align: center; padding: 10px; border-radius: 8px; font-weight: 700; }
  .lane-head small { display: block; font-weight: 400; font-size: 12px; margin-top: 2px; }
  .lane-head.device { background: var(--device-bg); color: var(--device); }
  .lane-head.server { background: var(--server-bg); color: var(--server); }
  .lane-head.other { background: var(--other-bg); color: var(--other); }
  .lane-head.bad { background: var(--bad-bg); color: var(--bad); }
  .step { margin: 10px 0 0; padding: 10px 12px; border-radius: 8px; border-left: 5px solid; background: #fafafa; transition: opacity .3s, transform .3s; }
  .step b.num { display: inline-block; min-width: 22px; height: 22px; border-radius: 11px; color: #fff; text-align: center; font-size: 12px; line-height: 22px; margin-right: 6px; }
  .step.device { border-color: var(--device); background: var(--device-bg); } .step.device b.num { background: var(--device); }
  .step.server { border-color: var(--server); background: var(--server-bg); } .step.server b.num { background: var(--server); }
  .step.other { border-color: var(--other); background: var(--other-bg); } .step.other b.num { background: var(--other); }
  .step.bad { border-color: var(--bad); background: var(--bad-bg); } .step.bad b.num { background: var(--bad); }
  .step .title { font-weight: 700; }
  .step .detail { font-size: 14px; margin-top: 4px; line-height: 1.4; }
  .step code, .sample { font-family: Consolas, monospace; font-size: 12px; word-break: break-all; }
  .sample { display: block; background: #fff; border: 1px dashed #999; padding: 6px; margin-top: 6px; border-radius: 4px; }
  .arrow { position: relative; height: 38px; margin-top: 4px; }
  .arrow .line { position: absolute; top: 18px; height: 3px; background: #2f3e4e; }
  .arrow .line::after { content: ''; position: absolute; top: -6px; border: 7.5px solid transparent; }
  .arrow.right .line::after { right: -12px; border-left: 12px solid #2f3e4e; }
  .arrow.left .line::after { left: -12px; border-right: 12px solid #2f3e4e; }
  .arrow .label { position: absolute; top: 0; left: 50%; transform: translateX(-50%); font-size: 12px; background: #fff; padding: 0 6px; white-space: nowrap; color: #2f3e4e; font-weight: 600; }
  .arrow.blocked .line { background: var(--bad); } .arrow.blocked .label { color: var(--bad); }
  .arrow.blocked.right .line::after { border-left-color: var(--bad); }
  .arrow.blocked.left .line::after { border-right-color: var(--bad); }
  .hidden { opacity: 0; transform: translateY(6px); pointer-events: none; }
  .legend { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 12px; }
  .legend div { background: #fff; border-radius: 10px; padding: 12px 16px; box-shadow: 0 1px 3px #0002; font-size: 14px; }
  .legend h3 { margin: 0 0 6px; font-size: 15px; }
  .legend ul { margin: 0; padding-left: 18px; }
  @media (max-width: 800px) { .legend { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<header>
  <h1>Backend E2EE</h1>
  <nav><a href="/admin">Panel de datos</a><a href="/admin/flujo" class="active">Flujo del proceso</a></nav>
</header>
<main>
  <div class="tabs" id="tabs"></div>
  <div class="intro" id="intro"></div>
  <div class="controls">
    <button onclick="go(-1)">◀ Paso anterior</button>
    <button onclick="go(1)">Siguiente paso ▶</button>
    <button onclick="showAll()">Mostrar todo</button>
    <button onclick="reset()">Reiniciar</button>
    <span class="counter" id="counter"></span>
  </div>
  <div class="board" id="board"></div>
  <div class="legend">
    <div><h3>✅ Lo que el servidor SÍ ve</h3><ul>
      <li>Texto cifrado (<code>cipherText</code>), <code>nonce</code> y etiqueta de autenticidad (<code>mac</code>)</li>
      <li>Ids opacos, versión del cifrado y qué cuenta tiene acceso a qué</li>
      <li>Llaves <b>públicas</b> y llaves de colección ya envueltas (cifradas)</li>
      <li>Metadatos: tamaño, hora, cuentas involucradas</li></ul></div>
    <div><h3>⛔ Lo que el servidor NO ve</h3><ul>
      <li>Nombres de lugares, notas, valoraciones, fotos</li>
      <li>Títulos de las colecciones compartidas</li>
      <li>Llaves privadas, llaves de datos ni la frase de recuperación</li>
      <li>Por eso no puede leer, modificar sin ser detectado ni restaurar tus datos</li></ul></div>
  </div>
</main>
<script>
const LANES = {
  me: ['device', 'Tu teléfono', 'tiene tus llaves'],
  server: ['server', 'Servidor', 'sin llaves: solo guarda'],
  sofia: ['other', 'Teléfono de Sofía', 'cuenta invitada'],
  intruder: ['bad', 'Cuenta no autorizada', 'sin invitación'],
  newPhone: ['other', 'Teléfono nuevo', 'aún sin llaves'],
};

const FLOWS = [
  {
    id: 'general', tab: 'Visión general', lanes: ['me', 'server', 'sofia'],
    intro: '<b>Cifrado de extremo a extremo:</b> el contenido se cifra en un extremo y solo se descifra en otro extremo autorizado. En el medio, la red y el servidor solo manejan cajas cerradas.',
    steps: [
      { lane: 'me', title: 'Escribes en tu diario', detail: 'Lugar, nota, valoración y fotos, en texto claro, solo dentro de tu teléfono.' },
      { lane: 'me', title: 'Se cierra la caja', detail: 'El teléfono cifra todo con una llave que nunca sale de él.', send: { to: 'server', label: 'HTTPS · solo texto cifrado' } },
      { lane: 'server', title: 'El servidor guarda la caja cerrada', detail: 'Puede almacenarla, respaldarla y entregarla, pero no abrirla.', live: true },
      { lane: 'server', title: 'Entrega la caja a quien tú autorizaste', detail: 'Solo si compartiste la colección con esa persona.', send: { to: 'sofia', label: 'caja + sobre con la llave' } },
      { lane: 'sofia', title: 'Solo el destino autorizado la abre', detail: 'El teléfono de Sofía usa su llave privada para abrir el sobre y descifrar.' },
    ],
  },
  {
    id: 'guardar', tab: '1. Guardar en el diario', lanes: ['me', 'server'],
    intro: '<b>POC-1 · Datos privados.</b> Cada lugar se cifra en el teléfono con <b>AES-256-GCM</b> antes de sincronizarse. El servidor no recibe la llave.',
    steps: [
      { lane: 'me', title: 'Guardas un lugar', detail: 'Ej.: “Catarata del Toro” con la nota “ir temprano y con zapatos para barro”.' },
      { lane: 'me', title: 'Se convierte en datos y se cifra', detail: 'Llave de datos de 256 bits (solo en el teléfono) + nonce aleatorio → <code>AES-256-GCM</code>. El resultado incluye una etiqueta (<code>mac</code>) que detecta cualquier alteración.' },
      { lane: 'me', title: 'Se calcula un id opaco', detail: 'HMAC del id del lugar: el servidor no puede saber qué lugar es.', send: { to: 'server', label: 'PUT /records · cipherText, nonce, mac' } },
      { lane: 'server', title: 'El servidor almacena', detail: 'Lo guarda en <code>data.json</code> tal cual llegó. Así se ve un registro real:', live: true },
      { lane: 'server', title: 'Al leer, devuelve la caja', detail: 'No puede “ayudar” a descifrarla: no tiene la llave.', send: { to: 'me', label: 'GET /records · texto cifrado' } },
      { lane: 'me', title: 'Tu teléfono descifra', detail: 'Verifica la etiqueta y recupera exactamente el texto original. Si alguien cambió un solo byte, falla.' },
    ],
  },
  {
    id: 'compartir', tab: '2. Compartir colección', lanes: ['me', 'server', 'sofia', 'intruder'],
    intro: '<b>POC-2 · Contenido compartido.</b> Una llave nueva por colección; esa llave viaja dentro de un “sobre” que solo la llave privada de cada invitado puede abrir (<b>X25519 + HKDF</b>).',
    steps: [
      { lane: 'sofia', title: 'Sofía publica su llave pública', detail: 'Su llave privada se queda en su teléfono.', send: { to: 'server', label: 'PUT /keys · llave pública' } },
      { lane: 'me', title: 'Eliges qué compartir', detail: 'Una colección, por ejemplo “Rincones de café”. Tus notas privadas solo van si activas el interruptor.' },
      { lane: 'me', title: 'Llave nueva + contenido cifrado', detail: 'Se genera una llave solo para esta colección y se cifra su contenido.' },
      { lane: 'server', title: 'El servidor entrega la llave pública', detail: 'Es pública: no sirve para descifrar.', send: { to: 'me', label: 'GET /keys/sofia' } },
      { lane: 'me', title: 'Se prepara un sobre para Sofía', detail: 'La llave de la colección se cifra con la llave pública de Sofía.', send: { to: 'server', label: 'PUT /collections · contenido + sobres' } },
      { lane: 'server', title: 'Guarda contenido y sobres', detail: 'Todo cifrado. Ni el título de la colección es visible.', live: 'collection' },
      { lane: 'server', title: 'Sofía pide su sobre', detail: 'El servidor solo se lo da a quien fue invitado.', send: { to: 'sofia', label: 'GET sobre de Sofía' } },
      { lane: 'sofia', title: 'Sofía abre y lee', detail: 'Su llave privada abre el sobre → obtiene la llave → descifra la colección.' },
      { lane: 'intruder', title: 'Otra cuenta lo intenta', detail: 'Pide un sobre para su cuenta.', send: { to: 'server', label: 'GET sobre', blocked: true } },
      { lane: 'server', title: 'No hay sobre para esa cuenta', detail: 'Responde 404. Y aunque robara el sobre de Sofía, sin la llave privada de Sofía no lo puede abrir.', send: { to: 'intruder', label: '404 · sin acceso', blocked: true } },
    ],
  },
  {
    id: 'revocar', tab: '3. Revocar acceso', lanes: ['me', 'server', 'sofia'],
    intro: '<b>Revocar = rotar la llave.</b> Se impide el acceso futuro; lo que Sofía ya vio o copió no se puede borrar de su teléfono.',
    steps: [
      { lane: 'me', title: 'Revocas el acceso de Sofía', detail: 'Tu teléfono abre la colección con tu propio sobre.' },
      { lane: 'me', title: 'Nueva llave, nuevo cifrado', detail: 'Se genera otra llave y se vuelve a cifrar el contenido.' },
      { lane: 'me', title: 'Sobres solo para quienes siguen', detail: 'Sofía ya no recibe sobre.', send: { to: 'server', label: 'PUT /collections · llave nueva' } },
      { lane: 'server', title: 'Reemplaza la versión anterior', detail: 'Cambia el <code>keyId</code> de la colección.' },
      { lane: 'sofia', title: 'Sofía intenta abrirla', detail: 'Ya no existe un sobre para ella.', send: { to: 'server', label: 'GET sobre', blocked: true } },
      { lane: 'server', title: 'Sin acceso', detail: 'Responde 404. Lo que descifró antes sigue en su teléfono: por eso la app lo advierte.', send: { to: 'sofia', label: '404 · revocado', blocked: true } },
    ],
  },
  {
    id: 'recuperar', tab: '4. Recuperación', lanes: ['me', 'server', 'newPhone'],
    intro: '<b>Si el servidor no tiene tus llaves, no puede restaurarlas.</b> Por eso existe la frase de recuperación: deriva una llave con <b>PBKDF2-HMAC-SHA256 (600 000 iteraciones)</b>.',
    steps: [
      { lane: 'me', title: 'Creas tu frase de recuperación', detail: 'Ej.: <code>XSFV-4146-V88S-H21T-6VT4-18W6</code>. Solo tú la guardas.' },
      { lane: 'me', title: 'La frase se convierte en llave', detail: 'PBKDF2 con 600 000 iteraciones: probar frases al azar es muy costoso.' },
      { lane: 'me', title: 'Se cifran las llaves del teléfono', detail: 'Tu llave de datos y tu llave privada quedan dentro de un respaldo cifrado.', send: { to: 'server', label: 'PUT /recovery · respaldo cifrado' } },
      { lane: 'server', title: 'Guarda el respaldo', detail: 'Ve salt e iteraciones, nunca la frase ni las llaves.', live: 'backup' },
      { lane: 'newPhone', title: 'Cambias de teléfono', detail: 'Escribes tu frase en el teléfono nuevo.', send: { to: 'server', label: 'GET /recovery' } },
      { lane: 'server', title: 'Entrega el respaldo cifrado', detail: 'Lo entregaría a cualquiera: sin la frase es inútil.', send: { to: 'newPhone', label: 'respaldo cifrado' } },
      { lane: 'newPhone', title: 'Frase correcta → llaves recuperadas', detail: 'Descarga el diario y lo descifra. Con una frase incorrecta, la etiqueta GCM falla y no se obtiene nada.' },
    ],
  },
];

let flow = FLOWS[0], shown = 1, live = null;

function esc(s) { return String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
const cut = (s, n) => { s = String(s ?? ''); return s.length > n ? s.slice(0, n) + '…' : s; };

function liveSample(kind) {
  if (!live) return '<span class="sample">(inicia el backend y usa la app para ver datos reales)</span>';
  if (kind === 'collection') {
    const c = Object.values(live.collections)[0];
    if (!c) return '<span class="sample">Aún no hay colecciones compartidas.</span>';
    return `<span class="sample">{ "id": "${esc(c.id)}", "keyId": "${esc(c.keyId)}",<br>  "content": { "cipherText": "${esc(cut(c.content.cipherText, 60))}" },<br>  "grants": [${c.grants.map(g => '"' + esc(g.recipientId) + '"').join(', ')}] }</span>`;
  }
  if (kind === 'backup') {
    const [acct, b] = Object.entries(live.recoveryBackups)[0] || [];
    if (!b) return '<span class="sample">Aún no hay respaldos de recuperación.</span>';
    return `<span class="sample">{ "account": "${esc(acct)}", "kdf": "${esc(b.kdf)}", "iterations": ${b.iterations},<br>  "salt": "${esc(b.salt)}", "cipherText": "${esc(cut(b.cipherText, 60))}" }</span>`;
  }
  const r = Object.values(live.records).flatMap(x => Object.values(x))[0];
  if (!r) return '<span class="sample">Aún no hay registros: abre la app.</span>';
  return `<span class="sample">{ "id": "${esc(r.id)}", "cryptoVersion": "${esc(r.cryptoVersion)}",<br>  "nonce": "${esc(r.nonce)}", "mac": "${esc(r.mac)}",<br>  "cipherText": "${esc(cut(r.cipherText, 70))}" }</span>`;
}

function render() {
  const cols = `repeat(${flow.lanes.length}, 1fr)`;
  const idx = id => flow.lanes.indexOf(id);
  let html = `<div class="lanes" style="grid-template-columns:${cols}">` +
    flow.lanes.map(l => `<div class="lane-head ${LANES[l][0]}">${LANES[l][1]}<small>${LANES[l][2]}</small></div>`).join('') + '</div>';
  flow.steps.forEach((s, i) => {
    const hidden = i >= shown ? ' hidden' : '';
    const col = idx(s.lane) + 1;
    const extra = s.live ? liveSample(s.live) : '';
    html += `<div class="row${hidden}" style="grid-template-columns:${cols}"><div class="step ${LANES[s.lane][0]}" style="grid-column:${col}">` +
      `<div class="title"><b class="num">${i + 1}</b>${s.title}</div><div class="detail">${s.detail}${extra}</div></div></div>`;
    if (s.send) {
      const from = idx(s.lane), to = idx(s.send.to), n = flow.lanes.length;
      const a = Math.min(from, to), b = Math.max(from, to);
      const left = ((a + 0.5) / n) * 100, width = ((b - a) / n) * 100;
      html += `<div class="arrow ${to > from ? 'right' : 'left'}${s.send.blocked ? ' blocked' : ''}${hidden}">` +
        `<div class="line" style="left:${left}%;width:${width}%"></div>` +
        `<div class="label" style="left:${left + width / 2}%">${s.send.label}</div></div>`;
    }
  });
  document.getElementById('board').innerHTML = html;
  document.getElementById('intro').innerHTML = flow.intro;
  document.getElementById('counter').textContent = `Paso ${Math.min(shown, flow.steps.length)} de ${flow.steps.length}`;
  document.getElementById('tabs').innerHTML = FLOWS.map(f =>
    `<button class="${f === flow ? 'active' : ''}" onclick="pick('${f.id}')">${f.tab}</button>`).join('');
}

function pick(id) { flow = FLOWS.find(f => f.id === id); shown = 1; render(); }
function go(d) { shown = Math.max(1, Math.min(flow.steps.length, shown + d)); render(); }
function showAll() { shown = flow.steps.length; render(); }
function reset() { shown = 1; render(); }
document.addEventListener('keydown', e => {
  if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); go(1); }
  if (e.key === 'ArrowLeft') go(-1);
});

async function refresh() {
  try { live = (await (await fetch('/admin/data')).json()).data; } catch (_) { live = null; }
  render();
}
render();
refresh();
setInterval(refresh, 3000);
</script>
</body>
</html>
''';
