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
        return this.frase("no lo sabía");
      } else if(this.sucesos[idSuceso] === valor) {
        this.sucesos[idSuceso] = valor; // redundancia!
        return this.frase("lo sé");
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
        return "La premisa es indeterminada todavía";
      }
    }
    cuestionar(sentencia) {
      const { operador, suceso = null, texto, localizacion } = sentencia;
      const { texto: idSuceso = null } = suceso;
      if(operador === "¿?") {
        if(typeof this.sucesos[suceso.texto] === "boolean") {
          if(this.sucesos[suceso.texto] === true) {
            return `Respuesta: que ${suceso.texto} es verdad.`;
          } else if(this.sucesos[suceso.texto] === false) {
            return `Respuesta: que ${suceso.texto} es falso.`;
          }
        } else {
          return `Respuesta: que ${suceso.texto} no se sabe todavía.`;
        }
      } else if(operador === "¿por qué?") {
        return `Respuesta: no puedo dar porqués todavía.`;
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
Sentencia = s:( sentencia_es_cierto_que / sentencia_pregunta / sentencia_pregunta_por_que / sentencia_porque ) {return {...s, todosLosSucesos: listarSucesosDeSentencia(s), texto: text(), localizacion: location()}}
sentencia_pregunta_por_que = op:( "¿por qué " ) suceso:suceso_puro "?" {return {tipo:"pregunta",suceso, operador: op.trim() + "?"}}
sentencia_pregunta = op:( "¿" ) suceso:suceso "?" {return {tipo:"pregunta",suceso, operador: op.trim() + "?"}}
sentencia_es_cierto_que = subtipo:( "es cierto que " / "es falso que " ) suceso:suceso_grupal "."  {return {tipo:"afirmación",subtipo:subtipo.trim(),suceso}}
sentencia_porque = sentencia_porque_1 / sentencia_porque_2 / sentencia_porque_3
sentencia_porque_1 = consecuencia:suceso_grupal ( " porque " / " en tanto que " ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_2 = "si " causa:suceso ( " entonces " ) consecuencia:suceso_grupal "."  {return {tipo:"causalidad",causa,consecuencia}}
sentencia_porque_3 = "si " consecuencia:suceso_grupal ( " es porque " ) causa:suceso "."  {return {tipo:"causalidad",causa,consecuencia}}
suceso = s:(suceso_concatenado / suceso_grupal) {return s}
suceso_concatenado = suceso:suceso_grupal concatenaciones:suceso_concatenaciones {return {tipo:"suceso concatenado",concatenaciones: [suceso].concat(concatenaciones), texto: text(), localizacion: location()}}
suceso_concatenaciones = suceso_concatenacion+
suceso_concatenacion = op:( " y " / " o " ) suceso:suceso {return {operador:op.trim(), ...suceso}}
suceso_grupal = suceso_agrupado / suceso_no_agrupado
suceso_agrupado = n:negacion* "(" s:suceso ")" {return {...s,negacion:n?n.length:0}}
suceso_no_agrupado = suceso_negado
suceso_negado = n:negacion* s:suceso_puro {return {...s,negacion:n?n.length:0}}
negacion = "no "
suceso_puro = "{" [^\}]+ "}" {return {tipo:"suceso puro",texto:text().substr(1, text().length-2).trim()}}
EOL = "\n" / "\r\n"
EOS = (EOL* / !.)