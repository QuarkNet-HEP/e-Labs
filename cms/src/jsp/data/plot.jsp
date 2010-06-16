<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%
	session.setAttribute("cms.datasets", null);
%>
<c:if test="${!empty param.back}">
	<jsp:forward page="../analysis-${param.analysis}/index.jsp">
		<jsp:param name="dataset" value="${param.dataset}"/>
		<jsp:param name="runs" value="${param.runs}"/>
		<jsp:param name="expr" value="${param.expr}"/>
		<jsp:param name="plots" value="${param.plots}"/>
	</jsp:forward>
</c:if>
<c:if test="${!empty param.backhalf}">
	<jsp:forward page="../analysis-${param.analysis}/plot-params.jsp">
		<jsp:param name="dataset" value="${param.dataset}"/>
		<jsp:param name="runs" value="${param.runs}"/>
		<jsp:param name="expr" value="${param.expr}"/>
		<jsp:param name="plots" value="${param.plots}"/>
	</jsp:forward>
</c:if>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Plot - ${param.analysisName}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<link href="../include/jeegoocontext/skins/cm_blue/style.css" rel="Stylesheet" type="text/css" />
	</head>
	
	<body id="plot-page" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<script type="text/javascript" src="../include/jeegoocontext/jquery.jeegoocontext.min.js"></script>
			<script language="javascript" type="text/javascript" src="../data/plot.js"></script>	
			<script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script>
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.js"></script>
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.selection.js"></script>
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.crosshair.js"></script>
			<div id="content">
				
<a class="help-icon" href="#" onclick="openHelp(event, 'help');"><img src="../graphics/help.png" /></a>
<h1>Plot - ${param.analysisName}</h1>
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
	<e:trinput type="hidden" name="analysis"/>
	<e:trinput type="hidden" name="analysisName"/>
	<table border="0" width="100%" id="step-buttons">
		<tr>
			<td>
				<input type="submit" name="back" value="&lt; Data Selection" />
			</td>
			<td>
				<input type="submit" name="backhalf" value="&lt; Plot Selection" />
			</td>
			<td width="100%">
			</td>
		</tr>
	</table>
</form>

<div class="wait-on-data" style="width: 100%; height: 64px;">
</div>

<div id="plot-container">
</div>

<div id="plot-template" style="display: none">
	<table class="toolbox-set">
		<tr>
			<td class="toolbox-row">
				<table class="toolbox">
					<tr>
						<td class="group-title">
							Selection
						</td>
						<td class="toolbox-group">
							<input type="button" class="apply-selection" value="Apply" disabled="true" />
							<input type="button" class="reset-selection" value="Reset" />
						</td>
						<td class="group-title">
							Axes
						</td>
						<td class="toolbox-group">
							Max Y: <input type="text" class="maxy" size="6" /><input type="button" class="apply-maxy" value="Set" disabled="true" />
							<input type="checkbox" class="logx" />Log X
							<input type="checkbox" class="logy" />Log Y
						</td>
						<td class="group-title">
							Plot
						</td>
						<td class="toolbox-group">
							Bin Width: <input type="text" class="binwidth" size="6" /><input type="button" class="apply-binwidth" value="Set" disabled="true" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="toolbox-row">
				<table class="toolbox">
					<tr>
						<td class="group-title">
							Save
						</td>
						<td class="toolbox-group">
								<form name="savePlotFrom" id="save-plot-form" action="../analysis/save.jsp"  method="get" 
									target="saveWindow" onsubmit="window.open('',this.target,'width=500,height=200,resizable=1');">
									<e:trinput type="hidden" name="dataset"/>
									<e:trinput type="hidden" name="runs"/>
									<e:trinput type="hidden" name="expr"/>
									<e:trinput type="hidden" name="plots" class="plots-input"/>
									<e:trinput type="hidden" name="analysis"/>
									<input type="text" name="name" emptytext="plot name" class="plotname" size="10" />
									<input type="submit" class="save" value="Save Plot"/>
								</form>
							</div>
						</td>
						<td class="group-title">
							<a href="#" id="animation-panel" class="group-title" onclick="switchPanel(this);">
								<img src="../graphics/plus.png" /> Animation
							</a>
						</td>
						<td class="toolbox-group panel">
							<div id="animation-panel-v" style="display: none">
								<a class="anim-bskip tbutton" href="#"><img src="../graphics/bskip.png"></a>
								<a class="anim-playpause tbutton" href="#"><img src="../graphics/play.png"></a>
								<a class="anim-fstep tbutton disabled" href="#"><img src="../graphics/fstep.png"></a>
								<a class="anim-fskip tbutton disabled" href="#"><img src="../graphics/fskip.png"></a>
								<span class="crtevent"></span>/<span class="totalevents"></span>
								Speed: <span class="crtspeed">1</span>
								<a class="anim-incspeed tbutton" href="#"><img src="../graphics/plus.png"></a>
								<a class="anim-decspeed tbutton" href="#"><img src="../graphics/minus.png"></a>
							</div>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<div class="cursor" style="position: absolute; z-index: 10; display: none;"><span class="cursorValue"></span> <span class="cursorUnit"></span></div>
	<div class="frame" style="position: relative;">
		<div class="placeholder" style="width:758px;height:380px; margin-bottom: 26px; margin-left: 26px;"></div>
		<div class="selection" style="position: absolute; top: 40px; z-index: 10;"></div>
		<div class="xlabel" style="position: absolute; left: 400px; bottom: -24px;"></div>
		<div class="ylabel" style="position: absolute; left: -50px; top: 200px;writing-mode: tb-rl; filter: flipV flipH; -webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);"></div>
	</div>
</div>

<ul id="color-list" class="jeegoocontext cm_blue">
	<c:forEach var="color" items="Black,Red,Green,Blue,Cyan,Magenta,Orange">
		<li value="${color}"><img style="background-color: ${color}" class="colorbox" src="../graphics/colorbox.png">${color}</li>
	</c:forEach>
</ul>

<script>
	updatingStarted = function() {
		log("Updating started");
		spinnerOn(".wait-on-data");
	}
	
	updatingDone = function() {
		log("Updating done");
		spinnerOff(".wait-on-data");
		$(".wait-on-data").css("display", "none");
	}
	
	updatingFailed = function(status, statusText, content) {
		log("Updating failed");
		spinnerOff(".wait-on-data");
		$(".wait-on-data").html(content);
	}
	
	getData("${param.dataset}", "${param.runs}", "${param.plots}", "${param.combine}");	
</script>

<div id="help" class="help">
	<table>
		<tr>
			<td class="title">Plot Help<a href="#" onclick="closeHelp('help');"><img src="../graphics/close.png" /></a></td>
		</tr>		
		<tr>
			<td class="content">
				<p>Need help with plotting? Try these links:</p>
				<ul>
					<li>
						<e:popup href="../video/demos-calibration.html?video=plot" target="tryit" width="800" height="800">Screencast Demo</e:popup> - how to use the plotting tool
					</li>
					<li>
						<a href="javascript:reference('cms analysis',450)">Milestone</a> associated with plotting.
					</li>
					<li>
						<e:popup href="../library/ref-studies.jsp" target="tryit" width="520" height="600">Calibration Studies Background</e:popup>
					</li>
					<li>
						CMS Elab <a href="../library/FAQ.jsp">FAQ</a>
					</li>
				</ul>
			</td>
		</tr>
		<tr>
			<td align="right"><button name="close" onclick="closeHelp('help');">Close</button></td>
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
