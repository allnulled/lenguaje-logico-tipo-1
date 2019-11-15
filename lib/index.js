(() => {

	const createEditors = () => {
		jQuery("#e1").pegeditor({
			options: {
				showLineNumbers: true
			}
		});
		jQuery("#e2").pegeditor();
		jQuery("#e3").pegeditor();
	};

	const addEvents = () => {
		
	}

	const initializeIndexPage = () => {
		createEditors();
		addEvents();
	}

	window.addEventListener("load", initializeIndexPage);

})();