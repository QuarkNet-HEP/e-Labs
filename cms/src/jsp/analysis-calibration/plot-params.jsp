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
<h1>Plot Selection - Calibration</h1>
<script>
	initlog();
	log("<span class='red'>dataset: ${param.dataset}</span>");
	log("<span class='red'>runs: ${param.runs}</span>");
	log("<span class='red'>expr: ${param.expr}</span>");
	log("<span class='red'>plots: ${param.plots}</span>");
	log("<span class='red'>commbine: ${param.combine}</span>");
</script>
 
<p>An important part of the early scientific activity at CMS is calibrating the new detector.  In this process, physicists use the detector to confirm measurements of properties (such as mass) of well-known particles.</p> 
<p>
The particles whose properties we want to confirm with CMS don't live long enough to be directly observed; we measure their properties indirectly by looking at their decay products (which in this case are pairs of muons.)  Below are similarly-charged (+,+ and -, - ) and oppositely charged (+,-) pairs of muons. You can use what you've learned about conservation rules to determine properties of some parent particles of these muon pairs.
</p>
<p>
First, a definition:  because almost all muons pass completely through the detector, the best sign of being a muon is to have been detected in every major subsystem: tracker, Ecal, Hcal, and muon systems. Those muons are called "global" muons; other muons are detected but not throughout the detector.  Select by checkbox datasets consisting of pairs of muons that are both global ("two global"), only one global, or neither global ("no global"), and opposite signed or like signed, from the options below.
</p>

 
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
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_OS.txt.gg.mass_" /></td>
		<td>&mu;<sup>-</sup>&mu;<sup>+</sup> / two global muons mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Black" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_OS.txt.gt.mass_" /></td>
		<td>&mu;<sup>-</sup>&mu;<sup>+</sup> / one global muon mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Red" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_OS.txt.tt.mass_" /></td>
		<td>&mu;<sup>-</sup>&mu;<sup>+</sup> / no global muon mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Green" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_LS.txt.gg.mass_" /></td>
		<td>&mu;<sup>+</sup>&mu;<sup>+</sup> / two global muons mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Black" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_LS.txt.gt.mass_" /></td>
		<td>&mu;<sup>+</sup>&mu;<sup>+</sup> / one global muon mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Red" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>
	<tr>
		<td><input class="plot" type="checkbox" value="dimuon_LS.txt.tt.mass_" /></td>
		<td>&mu;<sup>+</sup>&mu;<sup>+</sup> / no global muon mass</td>
		<td class="color"><a class="tbutton colorbutton" href="#"><img value="Green" class="colorbox" src="../graphics/colorbox.png"></a></td>
	</tr>

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
						&nbsp;
					</td>
					<td width="100%">
					</td>
					<td>
						<input id="plot-submit" type="submit" name="forward" value="Plot &rarr;" disabled="disabled" />
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
					<li><a href="javascript:showRefLink('../library/FAQ.jsp',700,700)">FAQs</a>
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
