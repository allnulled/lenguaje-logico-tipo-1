class IncongruenciaDeAsignacion extends Error {
	constructor(mensaje) {
		super();
		this.name = IncongruenciaDeAsignacion;
		this.message = mensaje;
	}
}

class Memoria {

	static removeDuplicates(list) {
		const unique = {};
		list.forEach(function(i) {
			if (!unique[i]) {
				unique[i] = true;
			}
		});
		return Object.keys(unique);
	}

	constructor() {
		this.objetos = {};
		this.eventos = {};
	}

	getObjeto(objeto) {
		const id = objeto.texto;
		if (!(id in this.objetos)) {
			this.objetos[id] = undefined;
		}
		return this.objetos[id];
	}

	addEvento(evento) {
		this.eventos[evento.texto] = evento;
		this.objetos.forEach(objeto => {
			if (!objeto.eventos) {
				objeto.eventos = [];
			}
			if (objeto.eventos.indexOf(evento.texto) === -1) {
				objeto.eventos.push(evento.texto);
			}
		});
		return evento.texto;
	}

	assignObjeto(objeto, estado) {
		const idObjeto = objeto.texto;
		if (idObjeto in this.objetos) {
			if (this.objetos[idObjeto] === estado) {
				// redundant
			} else if (typeof this.objetos[idObjeto] === "undefined") {
				this.objetos[idObjeto] = estado;
			} else {
				throw new IncongruenciaDeAsignacion("Error de incongruencia de asignación cerca de [" + objeto.localizacion.start.line + ":" + objeto.localizacion.start.column + "]: " + objeto.texto);
			}
		} else {
			this.objetos[idObjeto] = estado;
		}
		return this.runEventosParaObjetos([objeto.texto]);
	}

	runEventosParaObjetos(idsObjetos) {
		let allEventos = {};
		idsObjetos.forEach(idObjeto => {
			if (this.objetos[idObjeto].eventos) {
				this.objetos[idObjeto].eventos.forEach(idEvento => {
					if (!allEventos[idEvento]) {
						allEventos[idEvento] = true;
					}
				});
			}
		});
		return allEventos.map(idEvento => {
			this.runEvento(idEvento);
		});
	}

	runEvento(idEvento) {
		const evento = this.eventos[idEvento];
		if (evento.tipo === "causalidad") {
			return this.runEventoCausalidad(evento);
		} else if (evento.tipo === "pregunta") {
			return this.runEventoPregunta(evento);
		}
	}

	runEventoCausalidad(evento) {
		const {
			causa,
			consecuencia,
			localizacion
		} = evento;
		const resultadoCausa = this.evaluateSucesos(causa);
		if (resultadoCausa) {
			this.assignObjeto(consecuencia, consecuencia.negacion % 2);
		}
		return resultadoCausa;
	}

	runEventoPregunta(evento) {
		const {
			subtipo,
			suceso = false,
			localizacion
		} = evento;
		// @TODO
	}

	evaluateSucesos(idsEventos) {
		return idsEventos.map(idEvento => {
			return this.evaluateSuceso(idEvento);
		});
	}

	evaluateSuceso(idEvento) {
		const evento = this.eventos[idEvento];
		if (evento.tipo === "suceso puro") {
			return this.getObjeto(evento.texto);
		} else if (evento.tipo === "suceso agrupado") {
			return this.evaluateEventoAgrupado(evento.concatenacion);
		}
	}

	evaluateEventoAgrupado(concatenacion) {
		let resultado = undefined;
		concatenacion.forEach((suceso, indice) => {
			if (indice === 0) {
				resultado = this.evaluateSuceso(suceso);
			} else if (suceso.operador === "y") {
				resultado = resultado && this.evaluateSuceso(suceso);
			} else if (suceso.operador === "o") {
				resultado = resultado || this.evaluateSuceso(suceso);
			}
		});
		return resultado;
	}

	executeAfirmacion(sentencia) {
		// no registrar evento
		this.assignObjeto(sentencia.suceso, sentencia.negacion % 2);
	}

	executeCausalidad(sentencia) {
		// registrar evento
		this.addEvento(sentencia);
		const result = this.runEvento(sentencia.texto);
		console.log(result);
	}

	executePregunta(sentencia) {
		// registrar evento
		this.addEvento(sentencia);
		this.runEvento(sentencia.texto);
	}

	executeSentencia(sentencia) {
		if (sentencia.tipo === "afirmación") {
			return this.executeAfirmacion(sentencia);
		} else if (sentencia.tipo === "pregunta") {
			return this.executePregunta(sentencia);
		} else if (sentencia.tipo === "causalidad") {
			return this.executeCausalidad(sentencia);
		}
	}

	askAbout(objeto, estado = true) {
		const id = objeto.texto;
	}

	askWhy(objeto, estado = true) {
		const id = objeto.texto;

	}

}

const m = new Memoria();