import { toNetscape, isLoggedIn } from './netscape.js';

const msg = document.getElementById('msg');
const btn = document.getElementById('export');
const say = (text, cls = '') => { msg.textContent = text; msg.className = cls; };

// Export from the cookie store of the window the popup was opened in (normal or private).
async function currentStoreId() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  const stores = await chrome.cookies.getAllCookieStores();
  return stores.find((s) => s.tabIds.includes(tab?.id))?.id ?? stores[0]?.id;
}

btn.addEventListener('click', async () => {
  btn.disabled = true;
  try {
    const storeId = await currentStoreId();
    const cookies = await chrome.cookies.getAll({ domain: 'youtube.com', storeId });
    if (!isLoggedIn(cookies)) {
      say('Not logged in to YouTube in this window. Log in first.', 'err');
      return;
    }
    const url = 'data:text/plain;charset=utf-8,' + encodeURIComponent(toNetscape(cookies));
    await chrome.downloads.download({ url, filename: 'remtube-cookies.txt', saveAs: true });
    say(`Exported ${cookies.length} cookies. Save as ~/.config/mpvtube/cookies.txt, then close this private window.`, 'ok');
  } catch (e) {
    say(`Export failed: ${e.message}`, 'err');
  } finally {
    btn.disabled = false;
  }
});
