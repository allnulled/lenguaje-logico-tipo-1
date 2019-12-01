window.CodeMirror.defineSimpleMode("porque", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /\{[^\}]+\}/g,
      token: "suceso"
    },
    {
      regex: /si | es porque | porque | en tanto que | entonces |\./g,
      token: "causalidad"
    },
    {
      regex: /\¿por qué |\¿|\?/g,
      token: "pregunta"
    },
    {
      regex: /es cierto que |es falso que/g,
      token: "asignacion"
    },
    {
      regex: /no /g,
      token: "negacion"
    },
  ],
  // The multi-line comment state.
  comment: [],
  // The meta property contains global information about the mode. It
  // can contain properties like lineComment, which are supported by
  // all modes, and also directives like dontIndentStates, which are
  // specific to simple modes.
  meta: {}
});

