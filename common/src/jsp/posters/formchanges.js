/*
 * EPeronja-02/15/2013: Bug499- Implement autosave for posters
 * 					 
 * FormChanges(string FormID | DOMelement FormNode)
 * Returns an array of changed form elements.
 * An empty array indicates no changes have been made.
 * NULL indicates that the form does not exist.
 * 
 * 
 */
function FormChanges(form) {
	// get form
	if (typeof form == "string") form = document.getElementById(form);
	if (!form || !form.nodeName || form.nodeName.toLowerCase() != "form") return null;
	
	// find changed elements
	var changed = [], item, changedFlag, def, o, ol, opt;
	
	for (var e = 0, el = form.elements.length; e < el; e++) {
		item = form.elements[e];
		changedFlag = false;
		switch (item.nodeName.toLowerCase()) {
			case "select":
				def = 0;
				for (o = 0, ol = item.options.length; o < ol; o++) {
					opt = item.options[o];
					changedFlag = changedFlag || (opt.selected != opt.defaultSelected);
					if (opt.defaultSelected) def = o;
				}
				if (changedFlag && !item.multiple) changedFlag = (def != item.selectedIndex);
				break;
			case "textarea":
				alert("it gets here 1");
				if (tinyMCE.get(item.id).getContent() == '') {
					alert("it gets here 2");
					changedFlag = false;
				} else {
					alert("it gets here 3");
					changedFlag = tinyMCE.getInstanceById(item.id).isDirty;
				}
				break;				
			case "input":
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
