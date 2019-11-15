(() => {

	// Register pegeditor grammars:
	const registerGrammars = () => {
		jQuery.registerPegeditorGrammar("porque", PorqueParser.parse.bind(PorqueParser));
	}

	let editor1, editor2;

	const capitalize = (text) => {
		const index = text.search("[A-Za-z]");
		if(index !== -1) {
			return text.substr(0,index+1).toUpperCase() + text.substr(index+1);
		} else {
			return text;
		}
	}

	const getStringOutput = function(output) {
		let out = "";
		Object.keys(output).forEach(indice => {
			//out += "(" + indice + ")\n";
			const p1 = "" + (" - " + capitalize(output[indice].pregunta).replace(/\{|\}/g, i=>"").replace(/\¿ /g, "¿").replace(/ \?/g, "?") + " - dijo el humano." + "\n").replace(/ +/g, " ");
			const p2 = " - " + ("" + capitalize(output[indice].respuesta).replace(/\{|\}/g, i=>"").replace(/ +/g, " ").replace(/\n+ */g, "\n   ") + " - respondió el universo lógico." + "\n");
			out += p1 + p2;
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