$(document).ready(function(){
	var msg1 = "You cannot require and veto the same channel";
	var msg2 = "You cannot veto and require the same channel";
	$("#require1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#veto1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
	});
	$("#veto1").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#require1");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
	});	
	$("#require2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#veto2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
	});
	$("#veto2").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#require2");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
	});	
	$("#require3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#veto3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
	});
	$("#veto3").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#require3");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg2);
				return false;
			}
		}
	});	
	$("#require4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#veto4");
			if ($veto.prop("checked")) {
				$req.prop("checked", false);
				setMessage(msg1);
				return false;
			}
		}
	});
	$("#veto4").bind("change", function() {
		var $req = $(this);
		if ($req.prop("checked")) {
			var $veto = $("#require4");
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
