/*
 * EPeronja-02/15/2013: Bug499- Implement autosave for posters
 * 					 
 * FormChanges(string FormID | DOMelement FormNode)
 * Returns an array of changed form elements.
 * An empty array indicates no changes have been made.
 * NULL indicates that the form does not exist.
 * 
 * SetNotDirty()
 * Resets dirty flag for tinyMCE textareas
 * 
 */
function FormChanges(form) {
	// get form
	alert("line 1");
	if (typeof form == "string") form = document.getElementById(form);
	if (!form || !form.nodeName || form.nodeName.toLowerCase() != "form") return null;
	alert("line 2");
	
	// find changed elements
	var changed = [], item, changedFlag, def, o, ol, opt;
	
	for (var e = 0, el = form.elements.length; e < el; e++) {
		alert("for loop 1");
		item = form.elements[e];
		changedFlag = false;
		switch (item.nodeName.toLowerCase()) {
			case "select":
				alert("switch select");
				def = 0;
				for (o = 0, ol = item.options.length; o < ol; o++) {
					opt = item.options[o];
					changedFlag = changedFlag || (opt.selected != opt.defaultSelected);
					if (opt.defaultSelected) def = o;
				}
				if (changedFlag && !item.multiple) changedFlag = (def != item.selectedIndex);
				break;
			case "textarea":
				alert("switch textarea");
				if (tinyMCE.get(item.id).getContent().trim() == '') {
					changedFlag = false;
				} else {
					changedFlag = tinyMCE.getInstanceById(item.id).isDirty;
				}
				break;
			case "input":
				alert("switch input");
				changedFlag = (item.value != item.defaultValue);
			    break;
			default:
				changedFlag = (item.value != item.defaultValue);
		    break;				
		}
		if (changedFlag) changed.push(item);
	}
	return changed;
}

//EPeronja-02/15/2013: Bug499- tinyMCE textareas are different from regular textareas
function SetNotDirty() {
	// get form
	if (typeof form == "string") form = document.getElementById(form);
	if (!form || !form.nodeName || form.nodeName.toLowerCase() != "form") return null;
	
	for (var e = 0, el = form.elements.length; e < el; e++) {
		var n = form.elements[e];
		switch (n.nodeName.toLowerCase()) {
			case "textarea":
				var notDirty = tinyMCE.get(n.id).getContent();
				notDirty.isNotDirty = true;
				break;
		}
	}
}
