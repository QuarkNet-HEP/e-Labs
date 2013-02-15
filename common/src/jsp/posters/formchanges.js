function FormChanges(form) {
	// get form
	if (typeof form == "string") form = document.getElementById(form);
	if (!form || !form.nodeName || form.nodeName.toLowerCase() != "form") return null;
	// find changed elements
	var changed = [], n, c, def, o, ol, opt;
	
	for (var e = 0, el = form.elements.length; e < el; e++) {
		n = form.elements[e];
		c = false;
		switch (n.nodeName.toLowerCase()) {
			case "select":
				def = 0;
				for (o = 0, ol = n.options.length; o < ol; o++) {
					opt = n.options[o];
					c = c || (opt.selected != opt.defaultSelected);
					if (opt.defaultSelected) def = o;
				}
				if (c && !n.multiple) c = (def != n.selectedIndex);
				break;
			case "textarea":
				if (tinyMCE.get(n.id).getContent().trim() == '') {
					c = false;
				} else {
					c = tinyMCE.getInstanceById(n.id).isDirty;
				}
				break;
			case "input":
				c = (n.value != n.defaultValue);
			    break;
			default:
				c = (n.value != n.defaultValue);
		    break;				
		}
		if (c) changed.push(n);
	}
	return changed;
}

function SetNotDirty() {
	// get form
	if (typeof form == "string") form = document.getElementById(form);
	if (!form || !form.nodeName || form.nodeName.toLowerCase() != "form") return null;
	
	for (var e = 0, el = form.elements.length; e < el; e++) {
		n = form.elements[e];
		switch (n.nodeName.toLowerCase()) {
			case "textarea":
				var notDirty = tinyMCE.get(n.id).getContent();
				notDirty.isNotDirty = true;
				break;
		}
	}
}
