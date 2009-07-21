function reference(name, W, H) {
	if (!H) {
		H = 250;
	}
	while (name.indexOf(" ") > 0) {
		name = name.replace(" ", "_");
	}
	var url="/library/kiwi.php/" + name;
	var winPref = "width=400,height=" + H + ",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "_blank", winPref);
}