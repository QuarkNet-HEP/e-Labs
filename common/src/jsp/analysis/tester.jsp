<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis Generator</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
		<style>
			.panel {padding: 16px;}
			.panel {background-color: #e0e0e0; vertical-align: top;}
			#form th {background-color: #c0c0c0;}
			.help-item {display: none;}
		</style>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">			
			<div id="content">
				<h1>Analysis generator</h1>
				<form method="post" action="tester2.jsp">
					<table id="form">
						<tr>
							<th>Analysis type</th>
							<th>Workload</th>
							<th>Run mode</th>
							<th>Misc</th>
						</tr>
						<tr>
							<td class="panel">
								<p class="help"><input name="I2U2.Cosmic::PerformanceStudy" type="checkbox" checked="true"/>Performance</p>
								<p class="help"><input name="I2U2.Cosmic::FluxStudy" type="checkbox" checked="true"/>Flux</p>
								<p class="help"><input name="I2U2.Cosmic::ShowerStudy" type="checkbox" checked="true"/>Shower</p>
								<p class="help"><input name="I2U2.Cosmic::LifetimeStudy" type="checkbox" checked="true"/>Lifetime</p>
							</td>
							<td class="panel">
								<p><table>
									<tr class="help">
										<td>Number of analyses:</td><td><input size="10" type="text" name="count" value="10"/></td>
									</tr>
									<tr class="help">
										<td>Min events/analysis:</td><td><input size="10" type="text" name="eventmin" value="100"/></td>
									</tr>
									<tr class="help">
										<td>Max events/analysis:</td><td><input size="10" type="text" name="eventmax" value="1000000"/></td>
									</tr>
									<tr class="help">
										<td>Min files/analysis:</td><td><input size="10" type="text" name="filemin" value="1"/></td>
									</tr>
									<tr class="help">
										<td>Max files/analysis:</td><td><input size="10" type="text" name="filemax" value="100"/></td>
									</tr>
									<tr class="help">
										<td>Priority:</td>
										<td>
											<select name="feprio">
												<option selected="true">Events</option>
												<option>Files</option>
											</select>
										</td>
									</tr>
								</table></p>
							</td>
							<td class="panel">
								<p class="help"><input name="local" type="checkbox" checked="true"/>Local</p>
								<p class="help"><input name="i2u2" type="checkbox" checked="true"/>Cluster</p>
								<p class="help"><input name="mixed" type="checkbox" checked="true"/>Auto</p>
								<hr/>
								<p class="help"><input name="ignore-constraints" type="checkbox"/>Ignore time constraints</p>
							</td>
							<td class="panel">
								<p><table>
									<tr class="help">
										<td>Mean start delay (s)</td><td><input size="10" type="text" name="delay" value="10"/></td>
									</tr>
									<tr>
										<td><hr/></td>
									</tr>
									<tr class="help">
										<td>Random seed</td><td><input size="10" type="text" name="seed" value="0"/></td>
									</tr>
								</table></p>
							</td>
						</tr>
					</table>
					<input type="submit" value="Build workload"/>
				</form>
				<div id="help">
				</div>
				<div class="help-item" id="I2U2.Cosmic::PerformanceStudy">
					Enables/disables performance analyses in the generated set
				</div>
				<div class="help-item" id="I2U2.Cosmic::FluxStudy">
					Enables/disables flux analyses in the generated set
				</div>
				<div class="help-item" id="I2U2.Cosmic::ShowerStudy">
					Enables/disables shower analyses in the generated set
				</div>
				<div class="help-item" id="I2U2.Cosmic::LifetimeStudy">
					Enables/disables lifetime analyses in the generated set
				</div>
				<div class="help-item" id="count">
					The total number of analyses to be included in the set
				</div>
				<div class="help-item" id="eventmin">
					If priority is set to "Events", this will indicate the minimum total amount of events in selected
					input files for each analysis. The actual amount of events will be chosen randomly between the minimum
					and maximum.
				</div>
				<div class="help-item" id="eventmax">
					If priority is set to "Events", this will indicate the maximum total amount of events in selected
					input files for each analysis. The actual amount of events will be chosen randomly between the minimum
					and maximum.
				</div>
				<div class="help-item" id="filemin">
					If priority is set to "Files", this will indicate the minimum amount of files each analysis
					The actual amount of files will be chosen randomly between the minimum and maximum.
				</div>
				<div class="help-item" id="filemax">
					If priority is set to "Files", this will indicate the maximum amount of files each analysis
					The actual amount of files will be chosen randomly between the minimum and maximum.
				</div>
				<div class="help-item" id="feprio">
					Selects whether the input files are chose based on the number of events or simply by the
					number of files
				</div>
				<div class="help-item" id="local">
					Enables/disables local analysis run mode
				</div>
				<div class="help-item" id="i2u2">
					Enables/disables i2u2 cluster analysis run mode
				</div>
				<div class="help-item" id="mixed">
					Enables/disables automatic analysis run mode
				</div>
				<div class="help-item" id="ignore-constraints">
					If enabled, then analysis time limits for local mode will be ignored
				</div>
				<div class="help-item" id="delay">
					Indicates the mean delay (in seconds) between analyses start times. The actual start times
					are generated randomly using a Poisson distribution with lambda = mean delay. 
				</div>
				<div class="help-item" id="seed">
					Allows chosing a random seed for the random number generator used to generate the workload.
					If set to 0, this feature is disabled.
				</div>
		 	</div>
		</div>
		<script>
function getInputName(el) {
	if (el.nodeName == "INPUT" || el.nodeName == "SELECT") {
		return el.name;
	}
	for (var i = 0; i < el.childNodes.length; i++) {
		var name = getInputName(el.childNodes[i]);
		if (name != null) {
			return name;
		}
	}
	return null;
}
		
$(".help").hover(
	function() {
		$(this).css("background-color", "#efefef");
		var name = getInputName($(this).get()[0]);
		$("#help").html($("#" + name + ".help-item").html());
	},
	
	function() {
		$(this).css("background-color", "#e0e0e0");
		$("#help").html("");
	}
)
		</script>
	</body>
</html>