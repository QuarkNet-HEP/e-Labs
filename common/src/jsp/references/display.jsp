<%@ include file="../include/elab.jsp" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>


<%
	String title;
	String name = request.getParameter("name");  //label you want to show
	String type = request.getParameter("type");  //label you want to show
	String file;
	
	if ("glossary".equals(type)) {
		file = "Glossary_" + name;
	}
	else if ("reference".equals(type)) {
		file = "Reference_" + name;
	}
	else {
		throw new ElabJspException("Invalid reference type: " + type);
	}
	title = name.replaceAll("_"," ");
	file = file.replaceAll(" ", "_") + ".html";
	request.setAttribute("title", title);
	request.setAttribute("file", file);
%>
    
<html> 
	<head>
		<title>${title}</title>
		<script language="javascript">
			function getRefToDivMod(divID, oDoc) {
	        	if (!oDoc) {
	        		oDoc = document; 
	        	}
	        	if (document.layers) {
					if (oDoc.layers[divID]) {
						return oDoc.layers[divID]; 
					} 
					else {
						for (var x = 0, y; !y && x < oDoc.layers.length; x++) {
							y = getRefToDivNest(divID,oDoc.layers[x].document);
						}
						return y; 
					} 
				}
	        	if (document.getElementById) {
					return oDoc.getElementById(divID);
				}
				if (document.all) {
					return oDoc.all[divID];
				}
				return document[divID];
			}
			
			function resizeWinTo(oW, idOfDiv) {
	        	var oH = getRefToDivMod(idOfDiv); 
	        	if (!oH) {
					return false;
				}
				var oH = oH.clip ? oH.clip.height : oH.offsetHeight;
				if (!oH) {
					return false;
				}
				var x = window; 
				x.resizeTo(oW + 200, oH + 200);
				var myW = 0, myH = 0, d = x.document.documentElement, b = x.document.body;
				if (x.innerWidth) {
					myW = x.innerWidth;
					myH = x.innerHeight; 
				}
				else if (d && d.clientWidth) {
					myW = d.clientWidth;
					myH = d.clientHeight;
				}
				else if (b && b.clientWidth) {
					myW = b.clientWidth; myH = b.clientHeight;
				}
				if (window.opera && !document.childNodes) {
					myW += 16;
				}
				x.resizeTo(oW + ((oW + 200) - myW), oH + ((oH + 200) - myH));
				x.focus();
			}
		</script>
		<link rel="stylesheet"  href="../include/styletut.css" type="text/css">
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/elab-custom.js"></script>
	</head>
	<body onLoad="resizeWinTo(400,'txt');" background="../graphics/Quadrille.gif">
		<center>
			<div ID="txt" style="left:0px;top:0px;text-align:center;">
				<table align="center" width="340">
					<tr>
						<td>
							<jsp:include page="${file}"/>
						</td>
					</tr>
					<tr>
						<td align="right">
							<hr />
							<a href="javascript:window.close();">Close Window</a>
						</td>
					</tr>
				</table>
				<br />
			</div>
		</center>
	</body>
</html>
