import { toNetscape, isLoggedIn } from './netscape.js';

const msg = document.getElementById('msg');
const btn = document.getElementById('export');
const say = (text, cls = '') => { msg.textContent = text; msg.className = cls; };

// Same rules as `ytdl-run` (site key -> cookie file). domains = what to export.
const KNOWN = [
  { site: 'youtube', domains: ['youtube.com'], hosts: ['youtube.com', 'youtu.be', 'youtube-nocookie.com'] },
  { site: 'facebook', domains: ['facebook.com'], hosts: ['facebook.com', 'fb.watch', 'fb.com'] },
  { site: 'instagram', domains: ['instagram.com'], hosts: ['instagram.com'] },
  { site: 'x', domains: ['x.com', 'twitter.com'], hosts: ['x.com', 'twitter.com'] },
  { site: 'tiktok', domains: ['tiktok.com'], hosts: ['tiktok.com'] },
];
function siteOf(host) {
  host = host.replace(/^www\./, '');
  const hit = KNOWN.find((k) => k.hosts.some((h) => host === h || host.endsWith('.' + h)));
  if (hit) return hit;
  const p = host.split('.');
  const n = p.length;
  const reg = n >= 3 && /^(co|com|org|net|gov|ac)$/.test(p[n - 2]) && p[n - 1].length === 2 ? p.slice(-3).join('.') : p.slice(-2).join('.');
  return { site: reg.split('.')[0].replace(/[^a-z0-9-]/g, ''), domains: [reg] };
}
const savePath = (site) => (site === 'youtube' ? '~/.config/mpvtube/cookies.txt' : `~/.config/ytdl/cookies/${site}.txt`);

// Export from the cookie store of the window the popup was opened in (normal or private).
async function current() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  const stores = await chrome.cookies.getAllCookieStores();
  const storeId = stores.find((s) => s.tabIds.includes(tab?.id))?.id ?? stores[0]?.id;
  let host = '';
  try { host = new URL(tab.url).hostname; } catch {}
  return { host, storeId };
}

let target;
(async () => {
  const { host } = await current();
  if (!host || !host.includes('.')) { btn.disabled = true; say('Open the site you want (and log in) in this window first.', 'err'); return; }
  target = siteOf(host);
  btn.textContent = `Export ${target.domains.join(' + ')} cookies`;
  say(`Saves to ${savePath(target.site)}. Use a private window, then close it.`);
})();

btn.addEventListener('click', async () => {
  if (!target) return;
  btn.disabled = true;
  try {
    // one-time prompt per site: the extension only gets cookie access to sites you export
    const origins = target.domains.map((d) => `*://*.${d}/*`);
    if (!(await chrome.permissions.request({ origins }))) { say('Permission declined: cookies of this site were not exported.', 'err'); return; }
    const { storeId } = await current();
    const cookies = (await Promise.all(target.domains.map((domain) => chrome.cookies.getAll({ domain, storeId })))).flat();
    if (cookies.length === 0 || (target.site === 'youtube' && !isLoggedIn(cookies))) {
      say(`Not logged in to ${target.domains[0]} in this window. Log in first.`, 'err');
      return;
    }
    const url = 'data:text/plain;charset=utf-8,' + encodeURIComponent(toNetscape(cookies));
    const filename = target.site === 'youtube' ? 'remtube-cookies.txt' : `ytdl-${target.site}.txt`;
    await chrome.downloads.download({ url, filename, saveAs: true });
    say(`Exported ${cookies.length} cookies. Save as ${savePath(target.site)}, then close this private window.`, 'ok');
  } catch (e) {
    say(`Export failed: ${e.message}`, 'err');
  } finally {
    btn.disabled = false;
  }
});
