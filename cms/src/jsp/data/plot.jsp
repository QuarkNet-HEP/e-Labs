<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<c:if test="${!empty param.back}">
	<jsp:forward page="../analysis-${param.analysis}/index.jsp">
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
		<title>Plot</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<link href="../include/jeegoocontext/skins/cm_default/style.css" rel="Stylesheet" type="text/css" />
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
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.js"></script>
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.selection.js"></script>
		    <script language="javascript" type="text/javascript" src="../include/jquery.flot.crosshair.js"></script>
			<div id="content">
				
<h1>Z Mass Study</h1>
<script>
	initlog();
	log("<span class='red'>dataset: ${param.dataset}</span>");
	log("<span class='red'>runs: ${param.runs}</span>");
	log("<span class='red'>expr: ${param.expr}</span>");
	log("<span class='red'>plots: ${param.plots}</span>");
	log("<span class='red'>commbine: ${param.combine}</span>");
</script>

<div id="plot-container">
</div>

<div id="plot-template" style="display: none">
	<table class="toolbox">
		<tr>
			<td>
				<div class="toolbox-group">
					<span class="group-title">Selection:</span>
					<input type="button" class="apply-selection" value="Apply" disabled="true" />
					<input type="button" class="reset-selection" value="Reset" />
				</div>
			</td>
			<td>
				<div class="toolbox-group">
					<e:vswitch id="animation-panel" title="Animation" titleclass="group-title">
						<e:visible image="../graphics/plus.png">
						</e:visible>
						<e:hidden image="../graphics/minus.png">
							<a class="anim-bskip tbutton" href="#"><img src="../graphics/bskip.png"></a>
							<a class="anim-playpause tbutton" href="#"><img src="../graphics/play.png"></a>
							<a class="anim-fstep tbutton disabled" href="#"><img src="../graphics/fstep.png"></a>
							<a class="anim-fskip tbutton disabled" href="#"><img src="../graphics/fskip.png"></a>
							<span class="crtevent"></span>/<span class="totalevents"></span>
							Speed: <span class="crtspeed">1</span>
							<a class="anim-incspeed tbutton" href="#"><img src="../graphics/plus.png"></a>
							<a class="anim-decspeed tbutton" href="#"><img src="../graphics/minus.png"></a>
						</e:hidden>
					</e:vswitch>
				</div>
			</td>
		</tr>
	</table>
	<div class="cursor" style="position: absolute; z-index: 10; display: none;"><span class="cursorValue"></span> <span class="cursorUnit"></span></div>
	<div class="frame" style="position: relative;">
		<div class="placeholder" style="width:768px;height:380px; margin-bottom: 16px; margin-left: 16px;"></div>
		<div class="selection" style="position: absolute; top: 40px; z-index: 10;"></div>
		<div class="xlabel" style="position: absolute; left: 400px; bottom: -14px;"></div>
		<div class="ylabel" style="position: absolute; left: -50px; top: 200px;writing-mode: tb-rl; filter: flipV flipH; -webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);"></div>
	</div>
</div>

<script>
	d = new Array();
	var data = [
	    {
	        data: d
	    }
	];
	
	var options = {
	    lines: { show: true, fill: false, lineWidth: 1.2 },
	    grid: { hoverable: true, autoHighlight: false },
	    points: { show: false },
	    legend: { noColumns: 1 },
	    xaxis: { tickDecimals: 0 },
	    yaxis: { autoscaleMargin: 0.1 },
	    y2axis: { autoscaleMargin: 0.1 },
	    crosshair: { mode: "x" },
	    selection: { mode: "x", color: "yellow" }
	};

	getData("${param.dataset}", "${param.runs}", "${param.plots}", "${param.combine}");	
</script>

			</div>
			<!-- end content -->	
			
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
