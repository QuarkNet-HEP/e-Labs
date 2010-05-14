<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Z Mass Study</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<link href="../include/jeegoocontext/skins/cm_default/style.css" rel="Stylesheet" type="text/css" />
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
		    <script type="text/javascript" src="../analysis-zmass/plot-params.js"></script>
			<div id="content">
				
<h1>Z Mass Study</h1>
dataset: ${param.dataset}, runs: ${param.runs}, expr: ${param.expr}, plots: ${param.plots} 
<form action="../data/plot.jsp">
<e:trinput type="hidden" name="plots" id="plots-input" />
<e:trinput type="hidden" name="dataset"/>
<e:trinput type="hidden" name="runs"/>
<e:trinput type="hidden" name="expr"/>
<input type="hidden" name="analysis" value="zmass"/>
<table border="0" id="main">
	<tr>
		<td>
			<div id="simple-form">
				<select id="simplified-plots">
					<option value="none">Choose plot...</option>
					<option value="recoCompositeCandidates_ZtoAMuonAMuon__PAT.obj.mass_">&mu;+&mu;+ mass</option>
					<option value="recoCompositeCandidates_ZtoMuonMuon__PAT.obj.mass_">&mu;-&mu;- mass</option>
					<option value="recoCompositeCandidates_ZtoMuonAMuon__PAT.obj.mass_">&mu;-&mu;+ mass</option>
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
			
	<e:vswitch id="advanced-plot-panel" title="Advanced Plot Selection" titleclass="panel-title">
		<e:visible image="../graphics/plus.png">
		</e:visible>
		<e:hidden image="../graphics/minus.png">
			<table id="controls">
				<tr id="global-plot-options">
					<td>
						<input type="checkbox" /> Log X
						<input type="checkbox" /> Log Y
					</td>
					<td>
						Plot size:
						<select>
							<option>1600x1200</option>
							<option>1280x1024</option>
							<option>1024x768</option>
							<option selected="true">800x600</option>
							<option>640x480</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						
<table border="0" id="plots">
	<tr>
		<th>#</th>
		<th>Color</th>
		<th>Plot Content</th>
		<th></th>
	</tr>
	<tr>
		<td id="addplotcell" colspan="3">
			<div style="width: 24px;">
				<a class="tbutton addplot" id="addplot" href="#"><img class="buttonicon" src="../graphics/plus.png"></a>
			</div>
		</td>
	</tr>
</table>				
					</td>
				</tr>				
	
			</table>
		</e:hidden>
	</e:vswitch>
				<table border="0" width="100%" id="step-buttons">
					<tr>
						<td>
							<input type="submit" name="back" value="&lt; Data Selection" />
						</td>
						<td width="100%">
						</td>
						<td>
							<input type="submit" name="forward" value="Plot >" />
						</td>
					</tr>
				</table>
</td>
</tr>
</table>

<ul id="plot-list" class="jeegoocontext cm_blue">
	<c:choose>
		<c:when test="${param.dataset == 'tb04'}">
			<jsp:include page="../data/tb04/plots.jspf"/>
		</c:when>
		<c:when test="${param.dataset == 'mc09'}">
			<jsp:include page="../data/mc09/plots.jspf"/>
		</c:when>
	</c:choose>
</ul>


<ul id="color-list" class="jeegoocontext cm_blue">
	<c:forEach var="color" items="Black,Red,Green,Blue,Gold,Pink,Purple,Orange">
		<li value="${color}"><img style="background-color: ${color}" class="colorbox" src="../graphics/colorbox.png">${color}</li>
	</c:forEach>
</ul>

<div id="param-template" class="template">
	<a class="tbutton addparam" href="#" style="display: inline"><img class="buttonicon" src="../graphics/plus.png"></a>
</div>

<div id="log">
</div>


<table>
	<tr id="plot-template" class="template">
		<td class="plot-index">0</td>
		<td class="color">
			<a class="tbutton colorbutton" href="#"><img class="colorbox" src="../graphics/colorbox.png"></a>
		</td>
		<td class="active-label" width="100%"></td>
		<td class="remove">
			<a class="tbutton" href="#"><img src="../graphics/minus.png"></a>
		</td>
	</tr>
</table>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
