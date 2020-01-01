window.pegeditors = {};

class PegEditor {

	constructor(originalElement, options = {}) {
		const defaultOptions = {
			lineNumbers: true,
			width: "100%",
			height: "100%"
		};
		this.htmlOriginal = originalElement;
		this.jOriginal = jQuery(originalElement);
		this.id = options.id || this.jOriginal.attr("data-pegeditor-id") || "";
		this.grammar = options.grammar || this.jOriginal.attr("data-pegeditor-grammar") || "";
		this.theme = options.theme || this.jOriginal.attr("data-pegeditor-theme") || "";
		this.settings = options.settings || this.jOriginal.attr("data-pegeditor-settings") || "";
		this.options = Object.assign({}, options.options || {}, defaultOptions, ((editor) => {
			try {
				return JSON.parse(editor.settings);
			} catch (error) {
				return {};
			}
		})(this));
		this.instance = CodeMirror.fromTextArea(this.htmlOriginal, this.options);
		this.htmlEditor = this.instance.getWrapperElement();
		this.jEditor = jQuery(this.htmlEditor);
		const htmlErrorMessage = jQuery("<div class='ErrorMessage'><div class='SuggestionsBox'></div><div class='MessageBox'></div></div>");
		this.jEditor.append(htmlErrorMessage);
		this.htmlErrorMessage = htmlErrorMessage;
		this.jErrorMessage = jQuery(this.htmlErrorMessage);
		this.textMarks = [];
		this.textSuggestions = [];
		this.instance.pegeditor = this;
	}

	addTextMark(textMark) {
		this.textMarks.push(textMark);
	}

	clearErrorMessage() {
		this.jErrorMessage.removeClass("active").find(".MessageBox").text("");
	}

	clearTextMarks() {
		this.textMarks.forEach(textMark => {
			textMark.clear();
		});
		this.textMarks = [];
	}

	clearSuggestions() {
		this.jErrorMessage.find(".SuggestionsBox").html("");
		this.textSuggestions = [];
	}

	setError(error) {
		if(typeof error === "object" && typeof error.location === "object" && typeof error.location.start === "object") {
			const doc = this.instance.getDoc();
			const startPoint = error.location.start;
			const endPoint = error.location.end;
			const textMark = doc.markText({line:startPoint.line-1,ch:startPoint.column-1}, {line:endPoint.line-1,ch:endPoint.column-1}, {className: "pegeditor-error"});
			this.textMarks.push(textMark);
			console.log(error);
			if(typeof error.expected === "object") {
				this.addSuggestions(error.expected, error);
			}
		}
		this.setErrorMessage(error);	
	}

	setErrorMessage(message) {
		this.jErrorMessage.addClass("active").find(".MessageBox").text(message);
	}

	clearError() {
		this.clearErrorMessage();
		this.clearTextMarks();
		this.clearSuggestions();
	}

	addSuggestions(suggestions, error) {
		this.clearSuggestions();
		this.textSuggestions = suggestions;
		const suggestionsBox = this.jErrorMessage.find(".SuggestionsBox");
		//suggestionsBox.append("<div class='LabelSuggestion'>Suggestions:</div>")
		this.textSuggestions.forEach(textSuggestion => {
			console.log(textSuggestion);
			switch(textSuggestion.type) {
				case "literal":
					if(!textSuggestion.text.match(/^[\n\t\r ]+$/g)) {
						this.addLiteralSuggestion(textSuggestion, error, suggestionsBox);
					}
					break;
				default:
					break;
			}
		});
	}

	addLiteralSuggestion(suggestion, error, suggestionsBox) {
		const htmlLiteralSuggestion = this.createLiteralSuggestion(suggestion, error);
		suggestionsBox.append(htmlLiteralSuggestion);
	}

	createLiteralSuggestion(suggestion, error) {
		const v = suggestion.text ? suggestion.text : suggestion.value ? suggestion.value : "-";
		return jQuery("<div class='ErrorSuggestion'>").text(v).on("click", () => {
			const text = this.instance.getValue();
			const finalText = text.slice(0, error.location.start.offset) + v + text.slice(error.location.start.offset);
			this.instance.setValue(finalText);
			this.instance.setCursor({line: error.location.start.line, ch: error.location.start.column + v.length})
			this.instance.focus();
		});
	}

	createOnChangeEvent(options = {}) {
		return (codemirrorInstance, selectedText) => {
			const value = codemirrorInstance.getValue();
			try {
				let parse = (typeof this.grammar === "function") ? this.grammar : jQuery.pegeditorGrammars[this.grammar];
				if(typeof parse !== "function") {
					console.log("Invalidated grammar: ", this.grammar);
					parse = s => s;
				}
				const output = parse(value, options.parseOptions || {});
				this.lastValidOutput = output;
				this.clearError();
				if(typeof options.onSuccess === "function") {
					options.onSuccess(output, options, this, this.instance, value);
				}
				return output;
			} catch(error) {
				this.setError(error);
				if(typeof options.onError === "function") {
					options.onError(error, options, this, this.instance, value);
				}
				console.log(error);
				throw error;
			}
		};
	}

}

jQuery.PegEditor = PegEditor;
jQuery.pegeditorGrammars = {};
jQuery.registerPegeditorGrammar = function(name, grammar) {
	jQuery.pegeditorGrammars[name] = grammar;
};

jQuery.registerPegeditorCallback = function(name, callback) {
	if(typeof jQuery.pegeditorCallbacks !== "object") {
		jQuery.pegeditorCallbacks = {};
	}
	jQuery.pegeditorCallbacks[name] = callback;
};

jQuery.fn.pegeditor = function(options = {}) {

	const createEditor = (originalElement, options) => {
		return new PegEditor(originalElement, options);
	};

	const assignEvents = (editor, options) => {
		editor.instance.on("change", editor.createOnChangeEvent(options));
	};

	const validateEditor = (editor, options) => {
		if(typeof editor.grammar !== "function") {
			if(typeof editor.grammar === "string") {
				if(!(editor.grammar in jQuery.pegeditorGrammars)) {
					throw new Error("[data-pegeditor-grammar] must be an existing jQuery.pegeditorGrammars property, but <" + editor.grammar + "> was not found in: <" + Object.keys(jQuery.pegeditorGrammars).join(", ") + ">")
				}
			} else throw new Error("[data-pegeditor-grammar] must be an existing jQuery.pegeditorGrammars property, but <" + editor.grammar + "> was not found in: <" + Object.keys(jQuery.pegeditorGrammars).join(", ") + ">")
		}
	}

	this.each(function() {
		const editor = createEditor(this, options);
		validateEditor(editor, options);
		assignEvents(editor, options);
		// This is the editors global registry:
		if(typeof options.onInitialized === "function") {
			options.onInitialized(editor, options);
		}
		window.pegeditors[editor.id] = editor;
	});


	return this;
};