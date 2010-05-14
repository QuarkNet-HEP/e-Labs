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
dataset: ${param.dataset}, runs: ${param.runs}, expr: ${param.expr}, plots: ${param.plots}

<div id="cursor" style="position: absolute; z-index: 10; display: none;"><span id="cursorValue"></span> <span id="cursorUnit"></span></div>
<div id="frame" style="position: relative;">
	<div id="placeholder" style="width:800px;height:400px"></div>
	<div id="selection" style="position: absolute; top: 40px; z-index: 10;"></div>
</div>
<table id="toolbox">
	<tr>
		<td>
			<div class="toolbox-group">
				<span class="group-title">Selection:</span>
				<input type="button" id="apply-selection" value="Apply" disabled="true" />
				<input type="button" id="reset-selection" value="Reset" />
			</div>
		</td>
		<td>
			<div class="toolbox-group">
				<e:vswitch id="animation-panel" title="Animation Controls" titleclass="group-title">
					<e:visible image="../graphics/plus.png">
					</e:visible>
					<e:hidden image="../graphics/minus.png">
						<a id="anim-bskip" class="tbutton" href="#"><img src="../graphics/bskip.png"></a>
						<a id="anim-playpause" class="tbutton" href="#"><img src="../graphics/play.png"></a>
						<a id="anim-fstep" class="tbutton disabled" href="#"><img src="../graphics/fstep.png"></a>
						<a id="anim-fskip" class="tbutton disabled" href="#"><img src="../graphics/fskip.png"></a>
						<span id="crtevent"></span>/<span id="totalevents"></span>
						Speed: <span id="crtspeed">1</span>
						<a id="anim-incspeed" class="tbutton" href="#"><img src="../graphics/plus.png"></a>
						<a id="anim-decspeed" class="tbutton" href="#"><img src="../graphics/minus.png"></a>
					</e:hidden>
				</e:vswitch>
			</div>
		</td>
	</tr>
</table>
<div id="log">
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
	    legend: { noColumns: 2 },
	    xaxis: { tickDecimals: 0 },
	    yaxis: { autoscaleMargin: 0.1 },
	    y2axis: { autoscaleMargin: 0.1 },
	    crosshair: { mode: "x" },
	    selection: { mode: "x", color: "yellow" }
	};


	var placeholder = $("#placeholder");

	placeholder.bind("plotselected", function (event, ranges) {
		$("#selection").css("display", "block");
		var scale = document.plot.getAxes().xaxis.scale;
		var pos = ranges.xaxis.from;
		var client = document.plot.getAxes().xaxis.p2c(pos);
		$("#selection").text(ranges.xaxis.from.toFixed(1) + " - " + ranges.xaxis.to.toFixed(1));
		$("#selection").css("left", (client + 30) + "px");
		$("#apply-selection").attr("disabled", false);
	});

	plotUnselected = function(event) {
		$("#selection").css("display", "none");
    	$("#selection").text("none");
    	$("#apply-selection").attr("disabled", true);
	};
	
	placeholder.bind("plotunselected", plotUnselected);
	
	placeholder.bind("plothover", function(event, pos, item) {
		var crs = document.getElementById("cursor");
		var crsVal = document.getElementById("cursorValue");
		crs.style.left = (pos.pageX + 6) + "px";
		crs.style.top = (pos.pageY - 20) + "px";
		crsVal.innerHTML = Math.round(pos.x * 10) / 10;
	});
	placeholder.bind("mouseenter", function() {
		var crs = document.getElementById("cursor");
		crs.style.display = "block";
	});
	placeholder.bind("mouseleave", function() {
		var crs = document.getElementById("cursor");
		crs.style.display = "none";
	});

	$("#apply-selection").bind("click", function() {
		var r = document.plot.getSelection();
		document.plot = $.plot(placeholder, document.data,
                $.extend(true, {}, options, {
                    xaxis: { min: r.xaxis.from, max: r.xaxis.to }
                }));
    	plotUnselected();
	});

	$("#reset-selection").bind("click", function() {
		document.plot = $.plot(placeholder, document.data, options);
		plotUnselected();
	});

	document.plot = $.plot(placeholder, data, options);

	getData("${param.dataset}", "${param.runs}", "${param.plots}");

	$("#anim-bskip").bind("click", animationBSkip);
	$("#anim-playpause").bind("click", animationPlayPause);
	$("#anim-fstep").bind("click", animationFStep);
	$("#anim-fskip").bind("click", animationFSkip);
	$("#anim-incspeed").bind("click", animationIncSpeed);
	$("#anim-decspeed").bind("click", animationDecSpeed);
	document.animSpeed = 1;	
</script>

			</div>
			<!-- end content -->	
			
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
