(() => {

	// Register pegeditor grammars:
	const registerGrammars = () => {
		jQuery.registerPegeditorGrammar("porque", PorqueParser.parse.bind(PorqueParser));
	}

	let editor1, editor2;

	const getStringOutput = function(output) {
		let out = "";
		Object.keys(output).forEach(indice => {
			//out += "(" + indice + ")\n";
			out += "" + ("(Tú:) " + output[indice].pregunta.replace(/\{|\}/g, "").replace(/\¿ /g, "¿").replace(/ \?/g, "?") + "\n").replace(/ +/g, " ");
			out += "      " + ("" + output[indice].respuesta.replace(/\{|\}/g, "") + "\n").replace(/ +/g, " ");
		});
		return out;
	};

	const createEditors = () => {
		jQuery("#e1").pegeditor({
			options: {
				showLineNumbers: true
			},
			onSuccess: (output) => {
				if(editor2) {
					const out = getStringOutput(output);
					localStorage.__EL_LENGUAJE_DE_LOS_PORQUES__ = editor1.instance.getValue();
					editor2.instance.setValue(out);
				}
			},
			onInitialized: (editor) => {
				console.log("initialized", editor);
				editor1 = editor;
				if(localStorage.__EL_LENGUAJE_DE_LOS_PORQUES__) {
					const input = localStorage.__EL_LENGUAJE_DE_LOS_PORQUES__;
					editor1.instance.setValue(input);
				}
			}
		});
		jQuery("#e2").pegeditor({
			onInitialized: (editor) => {
				console.log("initialized", editor);
				editor2 = editor;
			},
			grammar: () => true
		});
	};

	const addEvents = () => {
		
	}

	const initializeIndexPage = () => {
		registerGrammars();
		createEditors();
		addEvents();
	}

	window.addEventListener("load", initializeIndexPage);

})();