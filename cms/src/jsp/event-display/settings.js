document.settings = {
	invertColors: false,
	showFPS: false, 
	calorimeterTowers: false,
	globalCaloEnergyCutEnabled: true,
	globalCaloEnergyLowCut: 0.75,
	lastDir: "",
};

function saveSettingsToCookie() {
	var cstr = "edsettings=";
	var first = true;
	for (var k in document.settings) {
		var value = document.settings[k];
		if (first) {
			first = false;
		}
		else {
			cstr += ",";
		}
		cstr += k + ":";
		if (typeof value == "boolean") {
			 cstr += value ? "true" : "false";
		}
		else {
			// would need escaping for general stuff
			cstr += value;
		}
	}
	var expires = new Date();
	expires.setDate(expires.getDate() + 3650);
	cstr += "; expires=" + expires.toUTCString();
	cstr += "; path=/";
	document.cookie = cstr;
}

function restoreSettingsFromCookie() {
	var cookies = document.cookie;
	var cv = cookies.split(";");
	for (var i = 0; i < cv.length; i++) {
		var kv = cv[i].split("=", 2);
		var cname = jQuery.trim(kv[0]);
		if (cname == "edsettings") {
			var sv = kv[1].split(",");
			for (var j = 0; j < sv.length; j++) {
				var kv2 = sv[j].split(":");
				var name = kv2[0];
				var value = kv2[1];
				if (document.settings[name] !== null) {
					if (typeof document.settings[name] == "boolean") {
						document.settings[name] = value == "true";
					}
					else if (typeof document.settings[name] == "number") {
						document.settings[name] = parseFloat(value);
					}
					else {
						document.settings[name] = value;
					}
				}
			}
		}
	}
}

function showSettings() {
	centerElement("settings");
	var settings = $("#settings");
	setCheckbox("setting-invert-colors", document.settings.invertColors);
	setCheckbox("setting-show-fps", document.settings.showFPS);
	setRadio("calorimeter-display", document.settings.calorimeterTowers ? "towers" : "opacity");
	setCheckbox("setting-global-cut", document.settings.globalCaloEnergyCutEnabled);
	setInputEnabled("settings-global-low-cut-percentage", document.settings.globalCaloEnergyCutEnabled);
	$("#settings-global-low-cut-percentage").attr("value", Math.round((1 - document.settings.globalCaloEnergyLowCut) * 100));
	settings.show();
}

function saveAndHideSettings() {
	saveSettingsToCookie();
	$("#settings").hide();
	$("#speed-test-window").hide();
}

function toggleFPS() {
	document.settings.showFPS = !document.settings.showFPS;
	document.draw();
}

function toggleGlobalCut() {
	document.settings.globalCaloEnergyCutEnabled = !document.settings.globalCaloEnergyCutEnabled;
	setInputEnabled("settings-global-low-cut-percentage", document.settings.globalCaloEnergyCutEnabled);
	document.draw();
}
