// Ctrl-T editor bridge. vimb reads/writes `vimb_input_mode_element.value`, which
// fails on contenteditable, React-controlled fields and shadow DOM. vimb runs
// `var vimb_input_mode_element = document.activeElement` in this (main) world;
// a pre-existing accessor survives that `var`, so we hand vimb a wrapper whose
// value setter edits the field like real typing (execCommand -> input events).
(() => {
  const editable = (t) => t && (t.tagName === 'TEXTAREA' || t.tagName === 'INPUT' || t.isContentEditable);

  // Follow focus into open shadow roots and same-origin iframes.
  // ponytail: cross-origin iframes unreachable from here (vimb evals in top frame only).
  const deep = (el) => {
    for (;;) {
      const next = el?.shadowRoot?.activeElement
        ?? (/^I?FRAME$/.test(el?.tagName) ? el.contentDocument?.activeElement : null);
      if (!next) return el;
      el = next;
    }
  };

  const fill = (t, v) => {
    v = v.replace(/\n$/, ''); // nvim appends EOL
    const doc = t.ownerDocument;
    t.focus();
    if (t.isContentEditable) {
      const r = doc.createRange();
      r.selectNodeContents(t);
      const s = doc.getSelection();
      s.removeAllRanges();
      s.addRange(r);
    } else {
      t.select();
    }
    if (doc.execCommand('insertText', false, v)) return;
    if (t.isContentEditable) t.innerText = v;
    else Object.getOwnPropertyDescriptor(Object.getPrototypeOf(t), 'value').set.call(t, v);
    t.dispatchEvent(new InputEvent('input', { bubbles: true, composed: true, inputType: 'insertText', data: v }));
  };

  const wrap = (t) => ({
    id: '', // forces vimb's editor-map path, so the write comes back through us
    get value() { return t.isContentEditable ? t.innerText : t.value; },
    set value(v) { fill(t, v); },
    set disabled(_) {},
    focus: () => t.focus(),
    blur: () => t.blur(),
  });

  // vimb sets this only when *entering* input mode, so after moving to another field
  // while already in input mode it would still point at the first one. Resolve the
  // focused field on every read instead (Ctrl-T reads it first, then reuses that
  // wrapper for the write-back); fall back to what vimb last stored.
  let last = null;
  Object.defineProperty(window, 'vimb_input_mode_element', {
    configurable: true,
    get: () => {
      const t = deep(document.activeElement);
      return editable(t) ? (last = wrap(t)) : last;
    },
    set: (el) => { const t = deep(el); last = editable(t) ? wrap(t) : el; },
  });

  // vimb's focus tracker sees the retargeted shadow host, not the inner field,
  // so it never enters input mode there. Report the real target (runs after vimb's).
  document.addEventListener('focusin', (e) => {
    if (!editable(e.target) && editable(e.composedPath()[0])) {
      window.webkit?.messageHandlers?.focus?.postMessage({ isEditable: true });
    }
  });
})();
