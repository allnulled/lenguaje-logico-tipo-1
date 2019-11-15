(() => {

	// Register pegeditor grammars:
	const registerGrammars = () => {
		jQuery.registerPegeditorGrammar("porque", PorqueParser.parse.bind(PorqueParser));
	}

	let editor1, editor2;

	const createEditors = () => {
		jQuery("#e1").pegeditor({
			options: {
				showLineNumbers: true
			},
			onSuccess: (output) => {
				if(editor2) {
					let out = "";
					Object.keys(output).forEach(indice => {
						//out += "(" + indice + ")\n";
						out += "" + ("(Tú:) " + output[indice].pregunta.replace(/\{|\}/g, "").replace(/\¿ /g, "¿").replace(/ \?/g, "?") + "\n").replace(/ +/g, " ");
						out += "      " + ("" + output[indice].respuesta.replace(/\{|\}/g, "") + "\n").replace(/ +/g, " ");
					})
					editor2.instance.setValue(out);
				}
			},
			onInitialized: (editor) => {
				console.log("initialized", editor);
				editor1 = editor;
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