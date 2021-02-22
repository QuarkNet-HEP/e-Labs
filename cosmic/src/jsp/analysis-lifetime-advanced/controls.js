$(document).ready(function(){
	var original_caption = document.getElementById("plot_caption").value;
	setCaption(original_caption);
	$("#lifetime_muon_coincidence").change(function() {
		setCaption(original_caption);
	});
    $("#lifetime_muon_gate" ).change(function() {
    	var mindelay = $('#lifetime_minimum_delay').val();
    	var muongate = $('#lifetime_muon_gate').val();
    	if (parseInt(mindelay) < parseInt(muongate)) {
    		$('#lifetime_muon_gate').val("250");
    		$('#lifetime_minimum_delay').val("300");    		
    		alert("Minimum delay has to be larger than the muon gate");
    	}
    	setCaption(original_caption);
    });
    $("#lifetime_minimum_delay" ).change(function() {
    	var mindelay = $('#lifetime_minimum_delay').val();
    	var muongate = $('#lifetime_muon_gate').val();
    	if (parseInt(mindelay) < parseInt(muongate)) {
    		$('#lifetime_muon_gate').val("250");
    		$('#lifetime_minimum_delay').val("300");    		
    		alert("Minimum delay has to be larger than the muon gate");
    	}
    	setCaption(original_caption);
    });
	$("#lifetime_electron_coincidence").change(function() {
		setCaption(original_caption);
	});
	$("#lifetime_electron_gate").change(function() {
		setCaption(original_caption);
	});
	var msg1 = "You cannot require and veto the same channel";
	var msg2 = "You cannot veto and require the same channel";
	$("#lifetime_muon_require1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_veto1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_muon_veto1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_require1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_muon_require2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_veto2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_muon_veto2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_require2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_muon_require3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_veto3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_muon_veto3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_require3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_muon_require4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_veto4");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_muon_veto4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_muon_require4");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_electron_require1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_veto1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_electron_veto1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_require1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_electron_require2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_veto2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_electron_veto2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_require2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_electron_require3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_veto3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_electron_veto3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_require3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});	
	$("#lifetime_electron_require4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_veto4");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
		setCaption(original_caption);
	});
	$("#lifetime_electron_veto4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#lifetime_electron_require4");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
		setCaption(original_caption);
	});		
});

function setCaption(original_caption) {
	var plot_caption = original_caption;
	var muon_coincidence = document.getElementById("lifetime_muon_coincidence").value;
	var muon_gate = document.getElementById("lifetime_muon_gate").value;
	var muon_require = "";
	for (var i=1; i<5; i++) {
		if (document.getElementById("lifetime_muon_require"+i).checked) {
			muon_require = muon_require + i;
		}
	}
	if (muon_require == "") {
		muon_require = "0";
	}
	var muon_veto = "";
	for (var i=1; i<5; i++) {
		if (document.getElementById("lifetime_muon_veto"+i).checked) {
			muon_veto = muon_veto + i;
		}
	}
	if (muon_veto == "") {
		muon_veto = "0";
	}
	var electron_require = "";
	for (var i=1; i<5; i++) {
		if (document.getElementById("lifetime_electron_require"+i).checked) {
			electron_require = electron_require + i;
		}
	}
	if (electron_require == "") {
		electron_require = "0";
	}
	var electron_veto = "";
	for (var i=1; i<5; i++) {
		if (document.getElementById("lifetime_electron_veto"+i).checked) {
			electron_veto = electron_veto + i;
		}
	}
	if (electron_veto == "") {
		electron_veto = "0";
	}
	var electron_coincidence = document.getElementById("lifetime_electron_coincidence").value;
	var electron_gate = document.getElementById("lifetime_electron_gate").value;
	var minimum_delay = document.getElementById("lifetime_minimum_delay").value;
	var added_caption = "\nInputs: muon "+muon_coincidence+" hits "+muon_gate+"ns R"+muon_require+" V"+muon_veto;
	added_caption = added_caption +"; electron "+ electron_coincidence+" hit "+electron_gate+"ns delay "+minimum_delay+"ns R"+electron_require+" V"+electron_veto+"\n";
	var new_caption = plot_caption + added_caption;
	document.getElementById("plot_caption").value = new_caption;
}
function setMessage(message) {
	var msg = document.getElementById("message");
	msg.innerHTML = "<i>*"+message+"</>";
}
