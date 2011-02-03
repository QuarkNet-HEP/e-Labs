<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<title>Data Selection - Detector Exploration Studies</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<link href="../include/jeegoocontext/skins/cm_blue/style.css" rel="Stylesheet" type="text/css" />
	</head>
	
	<body class="data" onload="initialize();">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<script type="text/javascript" src="../include/jeegoocontext/jquery.jeegoocontext.min.js"></script>	
			<div id="content">
<a class="help-icon" href="#" onclick="openPopup(event, 'help')">Help <img src="../graphics/help.png" /></a>
<h1>Dataset Selection - Detector Exploration Studies</h1>
<script>
	initlog();
	log("<span class='red'>dataset: ${param.dataset}</span>");
	log("<span class='red'>runs: ${param.runs}</span>");
	log("<span class='red'>expr: ${param.expr}</span>");
	log("<span class='red'>plots: ${param.plots}</span>");
	log("<span class='red'>commbine: ${param.combine}</span>");
</script>

<p>You can use this tool to explore CMS data. Like CMS physicists, you can determine that the
CMS detector is working properly by confirming measurements (such as mass) of  
well-known particles. Start by confirming the masses of the J/Psi and Z particles using data with two muons (dimuons). Do the events in these runs confirm the detector's ability to  
make accurate measurements? What kind of results do you get when you look at dimuons with the opposite signs (&mu;+&mu;-) and same sign (&mu;-&mu;- and/or &mu;+&mu;+)?</p>
<%-- 
<p>What other studies can you do? Do the measurements drift over time?  
Find out.</p>
 --%>

<form action="../analysis-exploration/data-selection.jsp">
	<e:trinput type="hidden" name="plots"/>
	<e:trinput type="hidden" name="combine"/>
	<e:trinput type="hidden" name="analysisName" default="Detector Exploration Studies"/>
	<e:trinput type="hidden" name="analysis" default="exploration"/>
	<table border="0" id="main">
		<tr>
			<td>
				<div id="simple-form">
					<select id="dataset" name="dataset">
						<option value="none" id="nothing-selected">Choose dataset...</option>
						<option value="mc09">Monte Carlo Simulation</option>
						<option value="jpsi11">J/Psi (J/&Psi;) Data (LHC 2010)</option>
						<option value="zmumu11">Zmumu (Z&rarr;&mu;&mu;) Data (LHC 2010)</option>
					</select>
					<script>
						function datasetSelected(obj) {
							var expr = $('select option:selected').attr('value');
							if (expr == "none") {
								disableNext();
							}
							else {
								enableNext();
							}
						}

						function initialize() {
							var expr = "${param.dataset}";
							var sl = document.getElementById("dataset");
							var any = false;
							disableNext();
							for (var i = 0; i < sl.childNodes.length; i++) {
								var option = sl.childNodes[i];
								if (option.nodeType == NODETYPE_TEXT) {
									continue;
								}
								if (option.value == expr) {
									any = true;
									option.selected = true;
									if (expr != "none") {
										enableNext();			
									} 
								}
								else {
									option.selected = false;
								}
							}
							if (!any) {
								document.getElementById("nothing-selected").selected = true;
							}						
						}

						function disableNext() {
							$("#data-selection-button").attr("disabled", true);
						}

						function enableNext() {
							$("#data-selection-button").removeAttr("disabled");
						}

						$('#dataset').change(datasetSelected);
					</script>
				</div>
				
				<table id="step-buttons" border="0" width="100%">
					<tr>
						<td width="100%">
						</td>
						<td>
							<div>
								<input id="data-selection-button" type="submit" value="Data Selection >" />
							</div>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>

<div id="help" class="help">
	<table>
		<tr>
			<td class="title">Dataset Selection Help<a href="#" onclick="closeHelp('help');"><img src="../graphics/close.png" /></a></td>
		</tr>
		<tr>
			<td class="content">
				<p>Need help with dataset selection? Try these links:</p>
				<ul>
<%-- 
					<li>
						<e:popup href="../library/ref-studies.jsp" target="tryit" width="520" height="600">Calibration Studies Background</e:popup>
					</li>
--%>

<li>
						<e:popup href="../video/demos-exploration.html?video=dataset-selection" target="tryit" width="800" height="800">Screencast Demo</e:popup>
 - how to select datasets.
					</li>
<%-- 
					<li>
						<a href="javascript:reference('cms data selection',450)">Milestone</a> associated with data selection.
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
