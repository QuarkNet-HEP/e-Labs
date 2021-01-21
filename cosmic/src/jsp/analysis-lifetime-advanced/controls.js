$(document).ready(function(){
    $("#lifetime_muon_gate" ).change(function() {
    	var mindelay = $('#lifetime_minimum_delay').val();
    	var muongate = $('#lifetime_muon_gate').val();
    	if (mindelay <= muongate) {
    		$('#lifetime_muon_gate').val("250");
    		$('#lifetime_minimum_delay').val("300");    		
    		alert("Minimum delay has to be larger than the muon gate");
    	}
    });
    //$("#lifetime_electron_gate" ).change(function() {
  	//  alert( "Handler for lifetime_electron_gate called." );
    //});
    $("#lifetime_minimum_delay" ).change(function() {
    	var mindelay = $('#lifetime_minimum_delay').val();
    	var muongate = $('#lifetime_muon_gate').val();
    	if (mindelay <= muongate) {
    		$('#lifetime_muon_gate').val("250");
    		$('#lifetime_minimum_delay').val("300");    		
    		alert("Minimum delay has to be larger than the muon gate");
    	}
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
	});		
});
function setMessage(message) {
	var msg = document.getElementById("message");
	msg.innerHTML = "<i>*"+message+"</>";
}
