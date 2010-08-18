<style type="text/css">
.importantNote {
	width:740px;
	background-color: #fceae2;
	color: #000000;
	font-family:Arial;
	font-size:1em;
	border:2px solid #ec5b1c;
	padding:4pt;
	margin: auto;
	text-align:left;
	margin-top: 10px;
	margin-bottom: 10px;
}
</style>	
<%
	// Check if on teacher page
		StringBuffer currentURL = request.getRequestURL();
		String requestedURL = currentURL.toString();
		String jsMessage = "Ask your teacher if you need help.";
	
		if (requestedURL.indexOf("teacher") != -1) {
		jsMessage = "Read the section on e-Lab Technology Requirements at the bottom of the Teacher Home page.";
		}		
%>
<noscript>
			<div class="importantNote"><b>Javascript is Turned Off or Not Supported in Your Browser.</b>
			<hr size="1" noshade>Turn on Javascript to enable all eLab features. Also make sure <b>plug-ins</b> are enabled so you can see the Flash movie on the home page before logging in. <%= jsMessage %> </div>
</noscript>
