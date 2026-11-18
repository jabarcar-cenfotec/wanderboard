/// Admin panel: shows the stored data exactly as the backend holds it.
const adminPage = r'''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Backend E2EE · Panel de administración</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 0; background: #f4f1ec; color: #222; }
  header { background: #2f3e4e; color: #fff; padding: 16px 24px; }
  header h1 { margin: 0; font-size: 20px; }
  header p { margin: 4px 0 0; opacity: .8; font-size: 14px; }
  main { padding: 16px 24px; max-width: 1200px; }
  .stats { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 16px; }
  .stat { background: #fff; border-radius: 8px; padding: 12px 16px; min-width: 140px; box-shadow: 0 1px 3px #0002; }
  .stat b { display: block; font-size: 24px; }
  .search { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 16px; box-shadow: 0 1px 3px #0002; }
  .search input { padding: 8px; width: 60%; font-size: 15px; }
  .search button, .actions button { padding: 8px 14px; font-size: 14px; cursor: pointer; }
  #searchResult { margin-top: 8px; font-weight: bold; }
  section { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 16px; box-shadow: 0 1px 3px #0002; }
  h2 { font-size: 16px; margin: 4px 0 10px; }
  table { border-collapse: collapse; width: 100%; font-size: 13px; }
  th, td { text-align: left; padding: 6px 8px; border-bottom: 1px solid #e5e0d8; vertical-align: top; }
  td.mono { font-family: Consolas, monospace; word-break: break-all; }
  .empty { color: #888; font-style: italic; }
  .actions { margin-bottom: 16px; display: flex; gap: 8px; align-items: center; }
  details pre { white-space: pre-wrap; word-break: break-all; font-size: 12px; background: #faf8f4; padding: 8px; }
</style>
</head>
<body>
<header>
  <h1>Backend E2EE · Panel de administración</h1>
  <p>Datos tal como los almacena el servidor. El servidor no tiene ninguna clave para descifrarlos.</p>
</header>
<main>
  <div class="actions">
    <span id="storage"></span>
    <button onclick="resetData()">Vaciar datos</button>
    <label><input type="checkbox" id="auto" checked> Actualizar cada 2 s</label>
  </div>
  <div class="stats" id="stats"></div>
  <div class="search">
    <b>Buscar texto en claro en todo el almacenamiento</b><br>
    <input id="q" placeholder="Ej.: nombre de un lugar o una frase de tus notas">
    <button onclick="search()">Buscar</button>
    <div id="searchResult"></div>
  </div>
  <section><h2>Registros privados del diario</h2><div id="records"></div></section>
  <section><h2>Colecciones compartidas</h2><div id="collections"></div></section>
  <section><h2>Llaves públicas (X25519)</h2><div id="keys"></div></section>
  <section><h2>Respaldos de recuperación</h2><div id="backups"></div></section>
  <section><details><summary>JSON completo almacenado</summary><pre id="raw"></pre></details></section>
</main>
<script>
const esc = s => String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const cut = (s, n = 64) => { s = String(s ?? ''); return s.length > n ? s.slice(0, n) + '…' : s; };
function table(headers, rows) {
  if (!rows.length) return '<p class="empty">Sin datos todavía.</p>';
  return '<table><tr>' + headers.map(h => `<th>${h}</th>`).join('') + '</tr>' +
    rows.map(r => '<tr>' + r.map(c => `<td class="mono">${esc(c)}</td>`).join('') + '</tr>').join('') + '</table>';
}
async function load() {
  const res = await fetch('/admin/data');
  const { storage, data } = await res.json();
  document.getElementById('storage').textContent = 'Almacenamiento: ' + storage;
  const records = Object.entries(data.records).flatMap(([owner, recs]) =>
    Object.values(recs).map(r => [owner, r.id, r.cryptoVersion, r.keyId, r.nonce, cut(r.cipherText, 90), r.mac]));
  const collections = Object.values(data.collections).map(c =>
    [c.id, c.ownerId, c.keyId, cut(c.content.cipherText, 90), c.grants.map(g => g.recipientId).join(', ')]);
  const keys = Object.entries(data.publicKeys).map(([acct, k]) => [acct, k.x25519]);
  const backups = Object.entries(data.recoveryBackups).map(([acct, b]) =>
    [acct, b.kdf, b.iterations, b.salt, cut(b.cipherText, 90)]);
  document.getElementById('stats').innerHTML = [
    ['Registros', records.length], ['Colecciones', collections.length],
    ['Cuentas con llave', keys.length], ['Respaldos', backups.length],
  ].map(([l, v]) => `<div class="stat"><b>${v}</b>${l}</div>`).join('');
  document.getElementById('records').innerHTML =
    table(['Cuenta', 'Id opaco', 'Versión', 'keyId', 'nonce', 'cipherText', 'mac (tag GCM)'], records);
  document.getElementById('collections').innerHTML =
    table(['Id', 'Propietario', 'keyId', 'Contenido cifrado', 'Cuentas con acceso'], collections);
  document.getElementById('keys').innerHTML = table(['Cuenta', 'Llave pública'], keys);
  document.getElementById('backups').innerHTML =
    table(['Cuenta', 'KDF', 'Iteraciones', 'Salt', 'Llaves cifradas'], backups);
  document.getElementById('raw').textContent = JSON.stringify(data, null, 2);
}
async function search() {
  const q = document.getElementById('q').value;
  const res = await fetch('/admin/search?q=' + encodeURIComponent(q));
  const { matches } = await res.json();
  document.getElementById('searchResult').textContent =
    `«${q}»: ${matches} coincidencia(s) en el almacenamiento del servidor.`;
}
async function resetData() {
  if (!confirm('¿Vaciar todos los datos del servidor?')) return;
  await fetch('/admin/reset', { method: 'POST' });
  load();
}
document.getElementById('q').addEventListener('keydown', e => { if (e.key === 'Enter') search(); });
load();
setInterval(() => { if (document.getElementById('auto').checked) load(); }, 2000);
</script>
</body>
</html>
''';
