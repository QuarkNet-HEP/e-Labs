<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%@ include file="../data/jump.jspf" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Plot Selection - ${param.analysisName}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<link href="../include/jeegoocontext/skins/cm_blue/style.css" rel="Stylesheet" type="text/css" />
	</head>
	
	<body id="search_default" class="data" onload="initializeFromPlotParams();">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<script type="text/javascript" src="../include/jeegoocontext/jquery.jeegoocontext.min.js"></script>	
		    <script type="text/javascript" src="../analysis/plot-params.js"></script>
			<div id="content">
			
<a class="help-icon" href="#" onclick="openPopup(event, 'help');">Help <img src="../graphics/help.png" /></a>
<h1>Plot selection - ${param.analysisName}</h1>
<script>
	initlog();
	log("<span class='red'>dataset: ${param.dataset}</span>");
	log("<span class='red'>runs: ${param.runs}</span>");
	log("<span class='red'>expr: ${param.expr}</span>");
	log("<span class='red'>plots: ${param.plots}</span>");
	log("<span class='red'>combine: ${param.combine}</span>");
</script>

<%@ include file="../data/dataset.jsp" %>
 
<form action="../data/plot.jsp">
<e:trinput type="hidden" name="plots" id="plots-input" />
<e:trinput type="hidden" name="dataset"/>
<e:trinput type="hidden" name="runs"/>
<e:trinput type="hidden" name="expr"/>
<e:trinput type="hidden" name="analysisName"/>
<e:trinput type="hidden" name="analysis"/>
<table border="0" id="main">
	<tr>
		<td>
			<div id="simple-form">
				<select id="simplified-plots">
					<option value="none">Choose plot...</option>
					<option class="separator" disabled="disabled">----------------</option>
					<c:forEach var="leaf" items="${dataset.simplePlots}">
						<option value="${leaf.id}">${leaf.title}</option>
					</c:forEach>
					<option class="separator" disabled="disabled">----------------</option>
					<option id="advanced" value="advanced">Advanced</option>
				</select>
				<script>
					function updatePlots(obj) {
						var val = $('select option:selected').attr("value");
						var label = $('select option:selected').html();
						if (val == "advanced") {
							vSwitchShow("advanced-plot-panel");	
						}
						else if (val == "none") {
							clearPlots();
						}
						else {
							updatePlotsFromValue(val, label);
						}
					}
					
					$('#simplified-plots').change(updatePlots);
				</script>
			</div>
			
			<table border="0" width="100%" id="step-buttons">
				<tr>
					<td>
						<input type="submit" name="goto1" value="&lt; Dataset Selection" />
					</td>
					<td>
						<input type="submit" name="goto2" value="&lt; Data Selection" />
					</td>
					<td width="100%">
					</td>
					<td>
						<input id="plot-submit" type="submit" name="forward" value="Plot &gt;" disabled />
					</td>
				</tr>
			</table>
			
	<e:vswitch id="advanced-plot-panel" title="Advanced Plot Selection" titleclass="panel-title">
		<e:visible image="../graphics/plus.png">
		</e:visible>
		<e:hidden image="../graphics/minus.png">
			<table id="controls">
				<tr id="global-plot-options">
					<td>
						<e:trinput type="checkbox" name="combine" /> Combine plots that have the same units
					</td>
				</tr>
				<tr>
					<td>
						
<table border="0" id="plotlist">
	<tr>
		<th>#</th>
		<th>Plot Content</th>
		<th>Color</th>
		<th>Remove</th>
	</tr>
	<tr>
		<td id="addplotcell" colspan="3">
			<div style="width: 24px;">
				<a class="tbutton addplot" id="addplot" href="#"><img class="buttonicon" src="../graphics/plus.png" /></a>
			</div>
		</td>
	</tr>
</table>
					</td>
				</tr>				
	
			</table>
		</e:hidden>
	</e:vswitch>				
</td>
</tr>
</table>
</form>

<%@ include file="../data/plot-variables-menu.jspf" %>

<ul id="color-list" class="jeegoocontext cm_blue">
	<c:forEach var="color" items="Black,Red,Green,Blue,Cyan,Magenta,Orange">
		<li value="${color}"><img style="background-color: ${color}" class="colorbox" src="../graphics/colorbox.png" />${color}</li>
	</c:forEach>
</ul>

<div id="param-template" class="template">
	<a class="tbutton addparam" href="#" style="display: inline"><img class="buttonicon" src="../graphics/plus.png" /></a>
</div>

<table>
	<tr id="plot-template" class="template">
		<td class="plot-index">0</td>
		<td class="active-label" width="100%"></td>
		<td class="color">
			<a class="tbutton colorbutton" href="#"><img class="colorbox" src="../graphics/colorbox.png" /></a>
		</td>
		<td class="remove">
			<a class="tbutton" href="#"><img src="../graphics/minus.png" /></a>
		</td>
	</tr>
</table>

<div id="help" class="help">
	<table>
		<tr>
			<td class="title">Plot Selection Help<a href="#" onclick="closeHelp('help');"><img src="../graphics/close.png" /></a></td>
		</tr>		
		<tr>
			<td class="content">
				<p>Need help with plot selection? Try these links:</p>
				<ul>
<%-- 
					<li>
						<e:popup href="../library/ref-studies.jsp" target="tryit" width="520" height="600">Calibration Studies Background</e:popup>
					</li>
--%>
					<li>
						<e:popup href="../video/demos-exploration.html?video=plot-selection" target="tryit" width="800" height="800">Screencast Demo</e:popup>
 - how to select plots.
					</li>
<%-- 
					<li>
						<a href="javascript:reference('cms analysis',450)">Milestone</a> associated with plot selection.
					</li>
--%>
					<li>
						<e:popup href="/library/kiwi.php?title=CMS_FAQ" target="faq" width="500" height="300">FAQs</e:popup>
					</li>
				</ul>
			</td>
		</tr>
		<tr>
			<td align="right"><button name="close" onclick="closePopup('help');">Close</button></td>
		</tr>
	</table>
</div>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
