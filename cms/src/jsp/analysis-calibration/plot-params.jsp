<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

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
		    <script type="text/javascript" src="../analysis-calibration/plot-params.js"></script>
			<div id="content">
			
<a class="help-icon" href="#" onclick="openPopup(event, 'help');">Help <img src="../graphics/help.png" /></a>
<h1>Plot selection - ${param.analysisName}</h1>
<script>
	initlog();
	log("<span class='red'>dataset: ${param.dataset}</span>");
	log("<span class='red'>runs: ${param.runs}</span>");
	log("<span class='red'>expr: ${param.expr}</span>");
	log("<span class='red'>plots: ${param.plots}</span>");
	log("<span class='red'>commbine: ${param.combine}</span>");
</script>
 
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
			<div id="simple-form" style="text-align: left">
				<div class="panel-title">Plot Selection</div>
				
				<table id="controls">
					<tr id="global-plot-options">
						<td>
							<e:trinput type="checkbox" name="combine" /> Stack plots
						</td>
					</tr>
					<tr>
						<td>
						
<table border="0" id="plotlist">
	<tr>
		<th width="20px"></th>
		<th>Plot Content</th>
		<th width="32px">Color</th>
	</tr>
	<c:if test="${fn:contains(param.expr, 'uu')}">
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoMuonAMuon__PAT.obj.mass_" /></td>
			<td>&mu;<sup>-</sup>&mu;<sup>+</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Black" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoMuonMuon__PAT.obj.mass_" /></td>
			<td>&mu;<sup>-</sup>&mu;<sup>-</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Red" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoAMuonAMuon__PAT.obj.mass_" /></td>
			<td>&mu;<sup>+</sup>&mu;<sup>+</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Green" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
	</c:if>
	<c:if test="${fn:contains(param.expr, 'ee')}">
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoAEleEle__PAT.obj.mass_" /></td>
			<td>e<sup>-</sup>e<sup>+</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Blue" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoEleEle__PAT.obj.mass_" /></td>
			<td>e<sup>-</sup>e<sup>-</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Cyan" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
		<tr>
			<td><input class="plot" type="checkbox" value="recoCompositeCandidates_ZtoAEleAEle__PAT.obj.mass_" /></td>
			<td>e<sup>+</sup>e<sup>+</sup> mass</td>
			<td class="color"><a class="tbutton colorbutton" href="#"><img value="Magenta" class="colorbox" src="../graphics/colorbox.png"></a></td>
		</tr>
	</c:if>
</table>
						</td>
					</tr>
				</table>
				<script>
					function updatePlots(obj) {
						updatePlotsFromValue(val, label);
					}
					
					$('.colorbutton img').each(function(i, e) {
						$(this).css("background-color", $(this).attr('value'));
					});
				</script>
			</div>
			
			<table border="0" width="100%" id="step-buttons">
				<tr>
					<td>
						<input type="submit" name="back" value="&lt; Data Selection" />
					</td>
					<td width="100%">
					</td>
					<td>
						<input id="plot-submit" type="submit" name="forward" value="Plot >" disabled="true" />
					</td>
				</tr>
			</table>			
				
		</td>
	</tr>
</table>
</form>

<ul id="color-list" class="jeegoocontext cm_blue">
	<c:forEach var="color" items="Black,Red,Green,Blue,Cyan,Magenta,Orange">
		<li value="${color}"><img style="background-color: ${color}" class="colorbox" src="../graphics/colorbox.png" />${color}</li>
	</c:forEach>
</ul>


<div id="help" class="help">
	<table>
		<tr>
			<td class="title">Plot Selection Help<a href="#" onclick="closeHelp('help');"><img src="../graphics/close.png" /></a></td>
		</tr>		
		<tr>
			<td class="content">
				<p>Need help with plot selection? Try these links:</p>
				<ul>
					<li>
						<e:popup href="../library/ref-studies.jsp" target="tryit" width="520" height="600">Calibration Studies Background</e:popup>
					</li>
					<li>
						<e:popup href="../video/demos-calibration.html?video=plot-selection" target="tryit" width="800" height="800">Screencast Demo</e:popup>
 - how to select plots.
					</li>
					<li>
						<a href="javascript:reference('cms analysis',450)">Milestone</a> associated with plot selection.
					</li>
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
