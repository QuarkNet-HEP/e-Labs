function glossary(name, H) {
	if (!H) {
		H = 400;
	}
	name=name.substring(0,1).toUpperCase()+name.substring(1,name.length);
	while (name.indexOf(" ") > 0) {
	    j=name.indexOf(" ");
	    name=name.substring(0,j-1) + "_" +  name.substring(j).toUpperCase()+name.substring(j+1,name.length);
	}
	var url = "/library/kiwi.php/" + name;
    var winPref = "width=400,height=" + H + ",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "_blank", winPref);
}


