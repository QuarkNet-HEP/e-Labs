<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>

		<title>CMS 3D Event Display</title>

		<link href="scrollbar.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		
		<link href="settings.css" rel="stylesheet" type="text/css" />
		<link href="range-selection.css" rel="stylesheet" type="text/css" />
		<link href="event-browser.css" rel="stylesheet" type="text/css" />
		<link href="speed-test.css" rel="stylesheet" type="text/css" />
		
		<script type="text/javascript" src="jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="jquery.jeegoocontext.min.js"></script>
		<script type="text/javascript" src="pre3d.js"></script>
		<script type="text/javascript" src="pre3d_shape_utils.js"></script>
		<script type="text/javascript" src="base64.js"></script>		
		<script type="text/javascript" src="elab.js"></script>
		<script type="text/javascript" src="utils.js"></script>
		<script type="text/javascript" src="flexcroll.js"></script>
		<script type="text/javascript" src="canvas2image.js"></script>
		<script type="text/javascript" src="demo_utils.js"></script>
		<script type="text/javascript" src="object-conversion.js"></script>
		<script type="text/javascript" src="detector-model-gen.js"></script>
		<script type="text/javascript" src="data-description.js"></script>
	</head>
	<body class="black">
	<script>
		initlog(false);
	</script>
<table>
	<tr>
		<td colspan="2" class="titlebar-plain bordered">
			<div id="title"></div>
		</td>
	</tr>
	<tr height="24px">
		<td colspan="2" class="bordered">
			<%@ include file="toolbar.jspf" %>
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
<%@ include file="about.jspf" %>
<%@ include file="detector-help.jspf" %>

	</body>
</html>
