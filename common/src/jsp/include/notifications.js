function updateHeader(data, error, elab) {
	var toolbar = document.getElementById("header-toolbar");
	if (toolbar == null) {
		return;
	}
	if (error != null) {
		var diverr = document.getElementById("toolbar-error-text");
		if (diverr != null) {
			diverr.innerHTML = error;
		}
	}
	else if (data["logged-in"] == "") {
		toolbar.style.display = "";
	}
	else {
		if (data["logged-in"] != null && toolbar.style.display == "") {
			toolbar.style.display = "block";
		}
		var notificationsIcon = document.getElementById("notifications-icon");
		if (notificationsIcon != null) {
			notificationsIcon.src = "../notifications/icon.jsp?elab=" + elab + "&dummy=" + Math.random();
		}
		updateInnerHTML("notifications-table-container", "../notifications/table.jsp?unread=false");
	}
}

function displayNotifications() {
	var icon = document.getElementById("notifications-icon");
	var popup = document.getElementById("notifications-popup");
	if (popup.style.display == "" || popup.style.display == "none") {
		popup.style.top = icon.offsetTop + icon.height + "px";
		popup.style.right = "0px";
		popup.style.display = "block";
		popup.onclick = ignoreEvent;
		document.getElementsByTagName("body")[0].onclick = closeNotifications;
	}
	else {
		popup.style.display = "";
	}
	document.inhibitNotificationClose = true;
}

function ignoreEvent(e) {
	document.inhibitNotificationClose = true;
	return true;
}

function closeNotifications(e) {
	if (!document.inhibitNotificationClose) {
		var popup = document.getElementById("notifications-popup");
		popup.style.display = "";
	}
	document.inhibitNotificationClose = false;
}

function newRequestObject() {
	browser = navigator.appName;
	if(browser == "Microsoft Internet Explorer") {
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
	else {
		return new XMLHttpRequest();
	}
}

function markAsDeleted(idprefix, id, elab) {
	removeNotification0(idprefix, id, elab, false);
}

function removeNotification(idprefix, id, elab) {
	removeNotification0(idprefix, id, elab, true);
}

function removeNotification0(idprefix, id, elab, hard) {
	var ro = newRequestObject();
	ro.open('get', "../notifications/remove.jsp?id=" + id + "&hard=" + hard);
	ro.onreadystatechange = function() {
		if (ro.readyState == 4 && ro.status == 200) {
			var row = document.getElementById(idprefix + id);
			row.style.display = "none";
			var notificationsIcon = document.getElementById("notifications-icon");
			notificationsIcon.src = "../notifications/icon.jsp?elab=" + elab + "&dummy=" + Math.random();
		}
	};
	ro.send(null);
}

function updateInnerHTML(id, url) {
	var ro = newRequestObject();
	ro.open('get', url);
	ro.onreadystatechange = function() {
		if (ro.readyState == 4 && ro.status == 200) {
			var obj = document.getElementById(id);
			if (obj != null) {
				obj.innerHTML = ro.responseText;
			}
		}
	};
	ro.send(null);
}
