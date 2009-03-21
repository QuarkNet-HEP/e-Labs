<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.statistics.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Statistics</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/admin.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="statistics-summary" class="admin">
	<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-admin.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<c:set var="start" value="${param.start != null ? param.start : '02/01/2005'}"/>
<jsp:useBean id="nowd" class="java.util.Date"/>
<c:set var="now">
	<fmt:formatDate pattern="MM/dd/yyyy" value="${nowd}"/>
</c:set>
<c:set var="end" value="${param.end != null ? param.end : now}"/>

<jsp:useBean id="stats" class="gov.fnal.elab.statistics.AnalysisStats"/>
<jsp:setProperty name="stats" property="start" value="${start}"/>
<jsp:setProperty name="stats" property="end" value="${end}"/> 

<h1>Analysis runs for ${elab.name} elab from ${start} to ${end}</h1>

<h2>Interval </h2>
<table border="0" width="100%">
	<tr>
		<td>
<form>
	<input type="text" name="start" maxlength="10" size="10" value="${start}" />
	to
	<input type="text" name="end" maxlength="10" size="10" value="${end}" />
	<input type="hidden" name="type" value="${type}" />
	<input type="submit" value="Update" />
</form>
		</td>
		<td style="text-align: right;">
			<jsp:include page="preset-intervals.jsp"/>
		</td>
	</tr>
</table>


<table border="0" id="main">
	<tr>
		<td id="left">

<h2>Per year</h2>

<c:set var="yearly" value="${stats.yearlyAnalysisCounts}"/>

<table border="0" id="yearly" class="lefty small">
	<tr>
		<th width="100px" style="vertical-align: bottom;">
			<div style="padding: 2px; background-color: #a0ff00;">${type} count</div>
		</th>
		<c:forEach var="e" items="${yearly}">
			<td style="vertical-align: bottom; padding-left: 10px;">
				${e.count}
				<table border="0" cellpadding="0" cellspacing="0" 
					style="background-color: #a0ff00; width: 40px; height: ${e.relativeSize * 100}px;">
					<tr><td></td></tr>
					<tr><td></td></tr>
				</table>
			</td>
		</c:forEach>
	</tr>
	<tr>
		<th>Year</th>
		<c:forEach var="e" items="${yearly}">
			<td style="padding-left: 10px;">${e.key}</td>
		</c:forEach>
	</tr> 
</table>

<h2>Run methods</h2>

<c:set var="rm" value="${stats.runMethods}"/>
<c:set var="c" value="${fn:split('ffc080, ff80c0, eff0c0, a0a0ff, 99f0a0', ', ')}"/>

<%{
		StringBuffer sb = new StringBuffer();
		Collection c = (Collection) pageContext.getAttribute("rm");
		Iterator i = c.iterator();
		while (i.hasNext()) {
			sb.append("&v=");
			sb.append(((Statistics.BarChartEntry) i.next()).getRelativeSize());
		}
		sb.append("&c=");
		request.setAttribute("rmpieparams", sb.toString());
}%>

<c:set var="rmpieparams" value="${rmpieparams}${fn:join(c, '&c=')}&width=150&height=150"/>

<table border="0" id="active" class="lefty small" width="100%">
	<tr>
		<th>Run Method</th>
		<th>Count</th>
		<th>%</th>
		<td rowspan="6" width="100%" style="text-align: right;">
			<img src="piechart.jsp?${rmpieparams}"/>
		</td>
	</tr>
	<c:forEach var="e" items="${rm}" varStatus="li">
		<tr style="background-color: #${c[li.count - 1]}">
			<td style="vertical-align: bottom;">${e.key}</td>
			<td style="vertical-align: bottom;">${e.count}</td>
			<td style="vertical-align: bottom;"><fmt:formatNumber pattern="###.##" value="${e.relativeSize}"/></td>
		</tr>
	</c:forEach>
</table>

<h2>Analysis Types (Swift only)</h2>

<c:set var="at" value="${stats.analysisTypes}"/>
<%{
		StringBuffer sb = new StringBuffer();
		Collection c = (Collection) pageContext.getAttribute("at");
		Iterator i = c.iterator();
		while (i.hasNext()) {
			sb.append("&v=");
			sb.append(((Statistics.BarChartEntry) i.next()).getRelativeSize());
		}
		sb.append("&c=");
		request.setAttribute("atpieparams", sb.toString());
}%>

<c:set var="atpieparams" value="${atpieparams}${fn:join(c, '&c=')}&width=150&height=150"/>

<table border="0" id="active" class="lefty small" width="100%">
	<tr>
		<th>Analysis Type</th>
		<th>Count</th>
		<th>%</th>
		<td rowspan="6" width="100%" style="text-align: right;">
			<img src="piechart.jsp?${atpieparams}"/>
		</td>
	</tr>
	<c:forEach var="e" items="${at}" varStatus="li">
		<tr style="background-color: #${c[li.count - 1]}">
			<td style="vertical-align: bottom;">${e.key}</td>
			<td style="vertical-align: bottom;">${e.count}</td>
			<td style="vertical-align: bottom;"><fmt:formatNumber pattern="###.##" value="${e.relativeSize}"/></td>
		</tr>
	</c:forEach>
</table>

<h2>Failures</h2>
<table border="0" id="active" class="lefty small">
	<tr>
		<th>VDS</th>
		<td>${stats.VDSFailures}</td>
	</tr>
	<tr>
		<th>Swift</th>
		<td>${stats.swiftFailures}</td>
	</tr>
</table>
		
		</td>
		<td id="right">

<h2>Per month</h2>
<table border="0" id="monthly" class="lefty small">
	<tr>
		<th>Month/Year</th>
		<th colspan="2">
			<span style="padding: 2px; background-color: #ffaf00;">${type} count</span>
		</th>
	</tr>
	<c:forEach var="e" items="${stats.monthlyAnalysisCounts}" varStatus="li">
		<tr style="background-color: ${li.count % 2 == 0 ? '#ffffff' : '#e0e0e0' }">
			<td>${e.key}</td>
			<td>${e.count}</td>
			<td style="vertical-align: middle; text-align: left;">
				<div style="background-color: #ffaf00; height: 10px; width: ${e.relativeSize * 200}px; margin-left: 0px;"></div>
			</td>
		</tr>
	</c:forEach> 
</table>

<h2>Raw data distribution</h2>
<p>This is the distribution of the raw data count used
in individual analyses.</p>
 
<table border="0" id="monthly" class="lefty small">
	<tr>
		<th>Raw Data Size</th>
		<th colspan="2">
			<span style="padding: 2px; background-color: #ffaf00;">${type} count</span>
		</th>
	</tr>
	<c:forEach var="e" items="${stats.rawDataDistribution}" varStatus="li">
		<tr style="background-color: ${li.count % 2 == 0 ? '#ffffff' : '#e0e0e0' }">
			<td>${e.key}</td>
			<td>${e.count}</td>
			<td style="vertical-align: middle; text-align: left;">
				<div style="background-color: #ffaf00; height: 10px; width: ${e.relativeSize * 200}px; margin-left: 0px;"></div>
			</td>
		</tr>
	</c:forEach> 
</table>


		</td>
	</tr>
</table>

			</div>
		</div>
	</body>
</html>
