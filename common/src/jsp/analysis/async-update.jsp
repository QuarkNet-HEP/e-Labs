<script language="JavaScript">
	var INITIAL = 2000;
	var DELAY = 1000;
	
	function AsyncRequest(url, callback) {
		self.browser = navigator.appName;
		self.url = url;
		self.rcb = callback;
    
		if(browser == "Microsoft Internet Explorer") {
			self.ro = new ActiveXObject("Microsoft.XMLHTTP");
		}
		else {
			self.ro = new XMLHttpRequest();
		}
		
		self.handleResponse = function() {
			if(self.ro.readyState == 4){
				var response = self.ro.responseText;
				var update = new Array();
				if(response.indexOf('&' != -1)) {
					values = response.split('&');
					for (v in values) {
						var value = values[v];
						var i = value.indexOf("=");
						if (i == -1) {
							update[value] = "";
						}
						else {
							update[value.substr(0, i)] = value.substr(i+1);
						}
					}
				}
				self.rcb(update);
			}
		}
	}
	
	AsyncRequest.prototype.send = function() {
		self.ro.open('get', self.url);
		self.ro.onreadystatechange = self.handleResponse;
		self.ro.send(null);
	}
		
		
	function registerUpdate(url, callback) {
		self.setTimeout(tick, INITIAL);
		self.tcb = callback;
		self.done = false;
		
		function tick() {
			var request = new AsyncRequest(url, reply);
			request.send();
		}
		
		function reply(stuff) {
			self.tcb(stuff);
			if (!self.done) {
				self.setTimeout(tick, DELAY);
			}
		}
	}
	
	function stopUpdates() {
		self.done = true;
	}
	
</script>
