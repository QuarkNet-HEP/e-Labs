<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<c:set var="dataset" scope="session" value="mc09"/>

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
	
	<body id="search_default" class="data" onload="initializeFromExpr();">
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

<h1>Z Mass Study</h1>
dataset: ${param.dataset}, runs: ${param.runs}, expr: ${param.expr}, plots: ${param.plots}
<form action="../analysis-zmass/plot-params.jsp">
	<e:trinput type="hidden" name="dataset" id="dataset-input" default="${dataset}"/>
	<e:trinput type="hidden" name="plots"/>
	<table border="0" id="main">
		<tr>
			<td>
				<div id="simple-form">
					<select id="simplified-triggers">
						<option value="none">Choose events...</option>
						<option value="uu">Muons</option>
						<option value="ee">Electrons</option>
						<option value="uu or ee">Muons or Electrons</option>
						<option id="advanced" value="advanced">Advanced</option>	
					</select>
					<script>
						function updateTriggers(obj) {
							var expr = $('select option:selected').attr('value');
							if (expr == "advanced") {
								vSwitchShow("selected-events-panel");
								vSwitchShow("data-selection-panel");	
							}
							else {
								updateFromSimpleExpr(expr);
							}
						}
						
						$('#simplified-triggers').change(updateTriggers);
					</script>
				</div>
				
				<e:vswitch id="selected-events-panel" title="Selected Events" titleclass="panel-title">
					<e:visible image="../graphics/plus.png">
					</e:visible>
					<e:hidden image="../graphics/minus.png">
						<div id="runs-header">
							<input type="checkbox" id="select-all" checked="true" onchange="selectAll();"/>All
							<e:trinput type="hidden" name="runs" id="runs-input" />
						</div>
						<div id="runs">
						</div>
						<div id="totals">
						</div>
					</e:hidden>
				</e:vswitch>
				
				<e:vswitch id="data-selection-panel" title="Data Selection" titleclass="panel-title">
					<e:visible image="../graphics/plus.png">
					</e:visible>
					<e:hidden image="../graphics/minus.png">
						<jsp:include page="../data/triggers.jsp">
							<jsp:param name="dataset" value="${dataset}"/>
						</jsp:include>
					</e:hidden>
				</e:vswitch>
				<table id="step-buttons" border="0" width="100%">
					<tr>
						<td width="100%">
						</td>
						<td>
							<input type="submit" value="Plot Parameters >" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>
<div id="log">
</div>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
