; extends
;
; Broken method chains — the one case nvim-treesitter's ecma indents.scm does not
; cover, and the one you hit constantly in React code:
;
;   const filtered = items
;     .filter((i) => i.label.includes(query))   <- wants base+2, used to get base+0
;     .map((i) => i.label)
;     .slice(0, 10);
;
; ecma/indents.scm deliberately excludes a `call_expression` value from
; `(variable_declarator ... ) @indent.begin`, because for the ordinary
; `const x = fn(arg)` shape the `(arguments)` node already supplies the indent.
; That exclusion also swallows the chain case, where nothing else supplies it.
;
; The `#not-same-line?` guard is what keeps this narrow. It fires only when the
; chain is actually broken across lines (object and property on different rows):
;
;   const x = items.map((i) => {   <- object `items` and property `map` share a
;     return i;                       row, so this rule does NOT apply and the
;   });                               callback body keeps its single indent
;
; Without that guard every callback body in the codebase gains a phantom level.
(variable_declarator
  value: (call_expression
    function: (member_expression
      object: (_) @_object
      property: (_) @_property)) @indent.begin
  (#not-same-line? @_object @_property))
