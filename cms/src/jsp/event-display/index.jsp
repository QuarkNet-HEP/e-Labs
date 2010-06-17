<html>
	<head>

		<title>CMS 3D Event Display</title>

		<link href="scrollbar.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		
		<link href="settings.css" rel="stylesheet" type="text/css" />
		<link href="range-selection.css" rel="stylesheet" type="text/css" />
		<link href="event-browser.css" rel="stylesheet" type="text/css" />
		<link href="speed-test.css" rel="stylesheet" type="text/css" />
		
		<script src="../include/elab.js"></script>
		<script>
			initlog(false);
		</script>
		<script src="utils.js"></script>
		<script src="../include/flexcroll.js"></script>
		<script src="../include/jquery/js/jquery-1.4.min.js"></script>
		<script src="../include/pre3d.js"></script>
		<script src="../include/pre3d_shape_utils.js"></script>
		<script src="../include/base64.js"></script>
		<script src="../include/canvas2image.js"></script>
		<script src="demo_utils.js"></script>
		<script src="object-conversion.js"></script>
		<script src="detector-model-gen.js"></script>
		<script src="data-description.js"></script>
		<script src="save.js"></script>
	</head>
	<body class="black">

<table>
	<tr height="24px">
		<td class="bordered">
			<%@ include file="toolbar.jspf" %>
		</td>
		<td class="bordered">
			<div id="title"></div>
		</td>
	</tr>
	<tr>
		<td width="280px" class="bordered">
			<div id="switches-div" style="overflow: auto; height: 600px;" class="flexcroll">
				<table id="switches" width="266px">
				</table>
			</div>
		</td>
		<td class="bordered">
			<canvas id="canvas" width="800" height="600">
  				Sorry, this requires a web browser which supports HTML5 canvas.
			</canvas>
		</td>
	</tr>
	<tr>
		<td class="bordered">
			<%@ include file="controls-help.jspf" %>
		</td>
		<td class="bordered">
		</td>
	</tr>
</table>
<script src="eventdisplay.js"></script>

<%@ include file="settings.jspf" %>
<%@ include file="range-selection.jspf" %>
<%@ include file="event-browser.jspf" %>
<%@ include file="speed-test.jspf" %>

	</body>
</html>
