window.CodeMirror.defineSimpleMode("contratos", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /si | es porque | porque | en tanto que | entonces |\./g,
      token: "suceso"
    },
    {
      regex: /class |file |extends |implements |uses packages |uses classes |uses processes |has |static property |static method |property |method |that receives |that modifies |that returns /g,
      token: "causalidad"
    },
    {
      regex: /described as .*/g,
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

window.CodeMirror.defineSimpleMode("contratos-reporte", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /YO\:.*/g,
      token: "yo"
    },
    {
      regex: /PC\:.*/g,
      token: "pc"
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