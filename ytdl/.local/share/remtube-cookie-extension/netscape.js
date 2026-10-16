// Turn chrome.cookies.Cookie objects into a Netscape cookies.txt (the format yt-dlp reads).
// Columns: domain, include-subdomains, path, secure, expiry (0 = session), name, value.
export function toNetscape(cookies) {
  const lines = ['# Netscape HTTP Cookie File', '# Exported by ytdl cookie export. Keep this file private (chmod 600).', ''];
  for (const c of cookies) {
    const domain = (c.httpOnly ? '#HttpOnly_' : '') + c.domain;
    const sub = c.domain.startsWith('.') ? 'TRUE' : 'FALSE';
    const expiry = c.session ? 0 : Math.floor(c.expirationDate ?? 0);
    lines.push([domain, sub, c.path, c.secure ? 'TRUE' : 'FALSE', expiry, c.name, c.value].join('\t'));
  }
  return lines.join('\n') + '\n';
}

// SAPISID (or its __Secure- twin) is what signs logged-in InnerTube requests.
export const isLoggedIn = (cookies) => cookies.some((c) => c.name === 'SAPISID' || c.name === '__Secure-3PAPISID');
