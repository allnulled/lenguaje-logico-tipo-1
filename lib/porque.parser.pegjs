{

  class Incongruencia extends Error {
    constructor(message) {
      super();
      this.name = "IncongruencyError";
      this.message = message;
    }
  }
  class Memoria {
    constructor() {
      this.sucesos = {};
      this.relaciones = {};
      this.relacionesPorSuceso = {};
    }
    procesar(pSentencias = []) {
      try {
        const sentencias = [].concat(pSentencias);
        return sentencias.map(sentencia => {
          if(sentencia.tipo === "afirmación") {
            return this.asignar(sentencia.suceso, sentencia.subtipo, sentencia);
          } else if(sentencia.tipo === "pregunta") {
            return this.cuestionar(sentencia);
          } else if(sentencia.tipo === "causalidad") {
            return this.causalizar(sentencia);
          }
        }).map((resultado, indiceSentencia) => {
          const sentencia = typeof sentencias[indiceSentencia].texto === "string" ? sentencias[indiceSentencia].texto.replace(/\.$/g, "") : sentencias[indiceSentencia].texto;
          return {pregunta:sentencia, respuesta:resultado};
        });
      } catch(error) {
        throw error;
      }
    }
    asignar(suceso, subtipo = "es cierto que", sentencia) {
      const { texto, localizacion, negacion } = suceso;
      const idSuceso = suceso.texto;
      const valor = (subtipo === "es cierto que") ? negacion % 2 === 0 : negacion % 2 !== 0;
      if((!(idSuceso in this.sucesos)) || (this.sucesos[idSuceso] === undefined)) {
        this.sucesos[idSuceso] = valor;
        this.propagar(suceso);
        return "De acuerdo, esto es nueva información para mí";
      } else if(this.sucesos[idSuceso] === valor) {
        this.sucesos[idSuceso] = valor; // redundancia!
        return "De acuerdo, aunque esto ya lo sabía";
      } else if(this.sucesos[idSuceso] !== valor) {
        return "Error de incongruencia: " + "el suceso " + idSuceso + " no puede ser reasignado a " + valor + " cuando ya era " +  this.sucesos[idSuceso]  + ". Error [" + sentencia.localizacion.start.line + ":" + sentencia.localizacion.start.column + "]. Sentencia: " + sentencia.texto + "";
        // throw new Incongruencia("Suceso " + idSuceso + " no puede ser reasignado a " + valor + " cuando ya era " +  this.sucesos[idSuceso]  + ". Error [" + localizacion.start.line + ":" + localizacion.start.column + "]. Sentencia: " + sentencia.texto + "");
      }
      throw new Error("Esto es un error del programador/diseñador...");
    }
    causalizar(sentencia) {
      const { causa, consecuencia, texto, localizacion } = sentencia;
      const resultadoCausa = this.resolver(causa);
      this.relaciones[sentencia.texto] = sentencia; // registramos la relación
      if(resultadoCausa === true) {
        return this.asignar(consecuencia, "es cierto que", sentencia);
      } else if(resultadoCausa === false) {
        return this.asignar(consecuencia, "es falso que", sentencia);
      } else {
        return "De acuerdo, aunque todavía no podemos demostrarlo.";
      }
    }
    cuestionar(sentencia) {
      const { operador, suceso = null, texto, localizacion } = sentencia;
      const { texto: idSuceso = null } = suceso;
      if(operador === "¿?") {
        const resultadoSuceso = this.resolver(suceso);
        const esNegacion = suceso.negacion % 2 === 0 ? "" : " no"
        if(resultadoSuceso === true) {
          return `Correcto, es verdad que${esNegacion} ${suceso.texto}.`;
        } else if(resultadoSuceso === false) {
          return `Incorrecto, es falso que${esNegacion} ${suceso.texto}.`;
        } else {
          return `Todavía no se sabe si${esNegacion} ${suceso.texto}.`;
        }
      } else if(operador === "¿por qué?") {
        const resultadoSuceso = this.resolver(suceso);
        if(typeof resultadoSuceso === "boolean") {
          if(resultadoSuceso === true) {
            // La aseveración es correcta:
            let porques = "";
            let haEmpezado = false;
            Object.keys(this.relaciones).forEach(idRelacion => {
              const relacion = this.relaciones[idRelacion];
              const contieneSuceso = relacion.todosLosSucesos.indexOf(suceso.texto) !== -1;
              if(contieneSuceso) {
                const resultados = this.procesar(relacion);
                if(haEmpezado) {
                  porques += "\n...y porque " + resultados.map(resultado => resultado.pregunta).join("\n...y porque");
                } else {
                  haEmpezado = true;
                  porques += "Porque, como ya has dicho, " + resultados.map(resultado => resultado.pregunta).join("\n...y porque");
                }
                return porques;
              }
            });
            return porques;
          } else if(resultadoSuceso === false) {
            // La aseveración es incorrecta:
            return `Erras al afirmar que ${suceso.texto} es ${suceso.negacion % 2 === 0 ? "verdad" : "falso"} porque en realidad es ${this.sucesos[suceso.texto] ? "verdad" : "falso"}.`;
          }
        } else {
          // La aseveración es indeterminada:
          return `Tu pregunta parte de una premisa indeterminada porque todavía no se sabe si ${suceso.texto} o no.`
        }
      }
      return operador;
    }
    resolver(suceso) {
      if(suceso.tipo === "suceso puro") {
        const esNegacion = suceso.negacion % 2 !== 0;
        const estaResuelto = typeof this.sucesos[suceso.texto] === "boolean";
        if(estaResuelto) {
          if(esNegacion) {
            return this.sucesos[suceso.texto] === false;
          } else {
            return this.sucesos[suceso.texto] === true;
          }
        } else {
          return undefined;
        }
      } else if(suceso.tipo === "suceso concatenado") {
        let resultado = true;
        suceso.concatenaciones.forEach((concatenacion, indiceConcatenacion) => {
          if(indiceConcatenacion !== 0)  {
            const resultadoConcatenacion = this.resolver(concatenacion);
            const estaResueltaConcatenacion = typeof resultadoConcatenacion === "boolean";
            const estaResueltoResultado = typeof resultado === "boolean";
            // DET Y|O DET
            if(estaResueltoResultado && estaResueltaConcatenacion) {
              if(concatenacion.operador === "y") {
                resultado = resultado && resultadoConcatenacion;
              } else if(concatenacion.operador === "o") {
                resultado = resultado || resultadoConcatenacion;
              }
            // DET Y UNDET | UNDET Y DET | UNDET Y UNDET
            } else if(suceso.operador === "y" && (!(estaResueltoResultado && estaResueltaConcatenacion))) {
              resultado = undefined;
            // DET O UNDET | UNDET O DET | UNDET O UNDET
            } else if(suceso.operador === "o" && (!(estaResueltoResultado && estaResueltaConcatenacion))) {
              resultado = resultado || resultadoConcatenacion;
            }
          } else {
            resultado = resultado && this.resolver(concatenacion);
          }
        });
        return resultado;
      }
    }
    propagar(suceso) {
      // Coger todas las relaciones que tengan a este suceso en todosLosSucesos
      return Object.keys(this.relaciones).filter(relacion => {
        return this.relaciones[relacion].todosLosSucesos.indexOf(suceso.texto) !== -1;
      }).map(relacion => {
        return this.procesar(this.relaciones[relacion]);
      });
    }
    get frases() {
      return {
        "no lo sabía": ["Perfecto, no lo sabía."],
        "lo sé": ["Sí, es cierto."]
      }
    }
    frase(mensaje) {
      return this.frases[mensaje][0];
    }
  }
  const listarSucesosDeSuceso = function(suceso) {
    const sucesos = [];
    const insertarSuceso = function(suceso) {
      if(suceso.tipo === "suceso puro" && sucesos.indexOf(suceso.texto) === -1) {
        sucesos.push(suceso.texto);
      }
      if(suceso.concatenaciones) {
        insertarSucesosDeConcatenaciones(suceso.concatenaciones);
      }
    };
    const insertarSucesosDeConcatenaciones = function(concatenaciones) {
      concatenaciones.forEach(function(concatenacion) {
        insertarSuceso(concatenacion);
      });
    };
    insertarSuceso(suceso);
    return sucesos;
  };
  const listarSucesosDeSentencia = function(sentencia) {
      if(sentencia.tipo === "afirmación") {
        let { suceso } = sentencia;
        return listarSucesosDeSuceso(suceso);
      } else if(sentencia.tipo === "pregunta") {
        let { suceso } = sentencia;
        return listarSucesosDeSuceso(suceso);
      } else if(sentencia.tipo === "causalidad") {
        let { causa, consecuencia } = sentencia;
        causa = {...causa, todosLosSucesos: listarSucesosDeSuceso(causa) };
        consecuencia = {...consecuencia, todosLosSucesos: listarSucesosDeSuceso(consecuencia) };
        let result = [];
        causa.todosLosSucesos.forEach(s => result.indexOf(s) === -1 && result.push(s));
        consecuencia.todosLosSucesos.forEach(s => result.indexOf(s) === -1 && result.push(s));
        return result;
      }
  };
  const sucesos = {};
  const relaciones = {};
}
Lenguaje = s:Sentencia_completa* {return Object.assign({}, new Memoria().procesar(s));}
Sentencia_completa = s:Sentencia EOS {return s}
Sentencia = s:( sentencia_es_cierto_que / sentencia_pregunta_por_que / sentencia_pregunta / sentencia_porque ) {return {...s, todosLosSucesos: listarSucesosDeSentencia(s), texto: text(), localizacion: location()}}
sentencia_pregunta_por_que = op:( "¿por qué" _ ) suceso:suceso_no_agrupado "?" {return {tipo:"pregunta",suceso, operador: op[0].trim() + "?"}}
sentencia_pregunta = op:( "¿" _? ) suceso:suceso _? "?" {return {tipo:"pregunta",suceso, operador: op[0] + "?"}}
sentencia_es_cierto_que = subtipo:( "es cierto que " / "es falso que " ) suceso:suceso_grupal "."  {return {tipo:"afirmación",subtipo:subtipo.trim(),suceso}}
sentencia_porque = sentencia_porque_nucleo
sentencia_porque_nucleo = sentencia_porque_1 / sentencia_porque_2 / sentencia_porque_3
sentencia_porque_1 = consecuencia:suceso_grupal ( _ ("porque" / "en tanto que") _ ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_2 = "si" _ causa:suceso ( _ "entonces" _ ) consecuencia:suceso_grupal "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_3 = "si" _ consecuencia:suceso_grupal ( _ "es porque" _ ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
suceso = s:(suceso_concatenado / suceso_grupal) {return s}
suceso_concatenado = suceso:suceso_grupal concatenaciones:suceso_concatenaciones {return {tipo:"suceso concatenado",concatenaciones: [suceso].concat(concatenaciones), texto: text(), localizacion: location()}}
suceso_concatenaciones = suceso_concatenacion+
suceso_concatenacion = op:( _ ("y" / "o") _ ) suceso:suceso {return {operador:op[1], ...suceso}}
suceso_grupal = suceso_agrupado / suceso_no_agrupado
suceso_agrupado = n:negacion* "(" _? s:suceso _? ")" {return {...s,negacion:n?n.length:0}}
suceso_no_agrupado = suceso_negado
suceso_negado = n:negacion* s:suceso_puro {return {...s,negacion:n?n.length:0}}
negacion = "no" _
_ = [\t\r\n ]+
suceso_puro = "{" [^\}]+ "}" {return {tipo:"suceso puro",texto:text().substr(1, text().length-2).trim()}}
EOL = "\n" / "\r\n"
EOS = (EOL* / !.)