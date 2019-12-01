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
		return JSON.stringify(output, null, 2);
		let out = "";
		Object.keys(output).forEach(indice => {
			//out += "(" + indice + ")\n";
			const p1 = "" + ("YO: " + capitalize(output[indice].pregunta).replace(/\{|\}/g, i=>"").replace(/\¿ /g, "¿").replace(/ \?/g, "?") + "\n").replace(/ +/g, " ");
			const p2 = "" + ("PC: " + capitalize(output[indice].respuesta).replace(/\{|\}/g, i=>"").replace(/ +/g, " ").replace(/\n+ */g, "\n   ") + "\n");
			out += p1 + p2;
		});
		return out;
	};

	const createEditors = () => {
		jQuery("#e1").pegeditor({
			options: {
				showLineNumbers: true,
				mode: "porque"
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
			}
		});
		jQuery("#e2").pegeditor({
			onInitialized: (editor) => {
				console.log("initialized", editor);
				editor2 = editor;
				if(localStorage.__EL_LENGUAJE_DE_LOS_PORQUES__) {
					const input = localStorage.__EL_LENGUAJE_DE_LOS_PORQUES__;
					editor1.instance.setValue(input);
				}
				initializeStateFromUrlParameters();
			},
			grammar: () => true
		});
	};

	const addEvents = () => {
		jQuery(".change-download-button").on("click", function() {
			var searchParams = new URLSearchParams(window.location.search);
			searchParams.set("code", editor1.instance.getValue());
			editor2.instance.setValue("Usa este link para compartir este esquema lógico por internet:\n\n" + window.location.protocol + "//" + window.location.host + window.location.pathname + window.location.hash + "?" + searchParams.toString() + "\n\nPara recuperar el contenido escribe algo en el editor superior.");
		});
		jQuery(".change-view-button").on("click", function() {
			const jWrapper = jQuery("body > .wrapper");
			const isHorizontal = jWrapper.hasClass("horizontal-rows");
			if(isHorizontal) {
				jWrapper.removeClass("horizontal-rows");
				jWrapper.addClass("vertical-rows");
			} else {
				jWrapper.removeClass("vertical-rows");
				jWrapper.addClass("horizontal-rows");
			}
		});
	}

	const initializeIndexPage = () => {
		registerGrammars();
		createEditors();
		addEvents();
	}

	const initializeStateFromUrlParameters = () => {
		const urlParams = new URLSearchParams(window.location.search);
		const code = urlParams.get("code");
		if(code) {
			editor1.instance.setValue(code);
		}
	};

	window.addEventListener("load", initializeIndexPage);

})();