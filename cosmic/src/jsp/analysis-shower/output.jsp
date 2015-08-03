<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	
	String showerId = request.getParameter("showerId");
	AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
	request.setAttribute("showerResults", showerResults);

	String es = (String) request.getParameter("eventStart");
	int eventStart;
	if (es == null || es.equals("")) {
		eventStart = 1;
	}
	else {
		eventStart = Integer.parseInt(es);
	}
	
	String sc = request.getParameter("sort");
	int sortCol = 0;
	if (sc != null) {
	    sortCol = Integer.parseInt(sc);
	}
	if (sortCol < 0) {
	    sortCol = 0;
	}
	if (sortCol > 3) {
	    sortCol = 3;
	}
	request.setAttribute("sort", new Integer(sortCol));
	String eventNum = (String) analysis.getParameter("eventNum");
	if ("0".equals(eventNum)) {
		eventNum = null;
	}
	int lineNo = 1;
	int csc = sortCol;
	
	int dir;
	if (request.getParameter("dir") == null) {
		dir = EventCandidates.defDir[csc];
	}
	else {
		dir = "a".equals(request.getParameter("dir")) ? 1 : -1;
	}
	
	File ecFile = new File((String) analysis.getParameter("eventCandidates"));
	String ecPath = ecFile.getAbsolutePath();
	File multiplicitySummary = new File(showerResults.getOutputDir() + "/multiplicitySummary");
	EventCandidates ec = EventCandidates.read(ecFile, multiplicitySummary, csc, dir, eventStart, eventNum);
	
	Collection rows = ec.getRows();
	String message = ec.getUserFeedback();

	String mFilter = request.getParameter("mFilter");
	String displayMultiplicity = "none";
	if (mFilter != null && !mFilter.equals("") && !mFilter.equals("0")) {
		rows = ec.filterByMuliplicity(Integer.valueOf(mFilter));
		displayMultiplicity = "block";
	} else {
		if (mFilter != null && mFilter.equals("0")) {
			displayMultiplicity = "block";
		} else {
			mFilter = (String) analysis.getAttribute("mFilter");
			if (!mFilter.equals("") && !mFilter.equals("0")) {
				rows = ec.filterByMuliplicity(Integer.valueOf(mFilter));
				displayMultiplicity = "block";
			}
		}
	}
	request.setAttribute("message", message);
	request.setAttribute("eventDir", ecPath);
	request.setAttribute("rows", rows);
	request.setAttribute("eventNum", eventNum);
	request.setAttribute("crtEventRow", ec.getCurrentRow());		
	request.setAttribute("multiplicityFilter", ec.getMultiplicityFilter());		
	request.setAttribute("mFilter", mFilter);
	request.setAttribute("displayMultiplicity", displayMultiplicity);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>			
		<script>
		$(document).ready(function(){
			$("#viewAdvanced").bind("change", function() {
				var $req = $(this);
				var table = document.getElementById("shower-events");
				var rows = table.getElementsByTagName("tr");
				var display = "none";
				var newLoc = "";
				if ($req.prop("checked")) {
					display = "block";
				} else {
					display = "none";
				 	location = document.getElementById("restoreOutput").value;
				}
				for (var row=0; row < rows.length; row++) {
					var advanced = rows[row].cells[rows[row].cells.length - 1];
					advanced.style.display = display;
				}
			});
		});			
		function addMultiplicityOption(link) {
			var viewMultiplicity = document.getElementById("viewAdvanced");
			console.log(viewMultiplicity);
			if (viewMultiplicity.checked) {
				link.href += "&viewAdvanced=yes"
			}
		}		
		</script>
	</head>
	
	<body id="shower-study-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
<c:choose>
<c:when test="${not empty rows}">
<h1>Shower study candidates (<%= rows.size() %>) <a href="tutorial4.jsp?id=${param.id}&showerId=${param.showerId}" style="font-size: small; font-style: italic;">Event List References</a></h1>
<c:if test='${message != "" }'>
	<div>${message }</div>
</c:if>
<table id="shower-results">
	<tr>
		<td valign="top" width="70%">
			<table id="shower-events">
				<tr>
					<th width="40%">
						<a href="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${mFilter}&sort=0&dir=${(param.sort == '0' && param.dir == 'a') ? 'd' : 'a' }" >Event Date</a>
					</th>
					<th width="10%">
						<a href="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${mFilter}&sort=1&dir=${(param.sort == '1' && param.dir == 'd') ? 'a' : 'd' }" >Event Coincidence</a>
					</th>
					<th width="40%">
						<a href="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${mFilter}&sort=2&dir=${(param.sort == '2' && param.dir == 'd') ? 'a' : 'd' }" >Detector Coincidence<br /></a>[Counter Multiplicity]			
					</th>
					<th width="10%" style="display: ${displayMultiplicity};" name="advanced">					
						<a href="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${mFilter}&sort=3&dir=${(param.sort == '3' && param.dir == 'd') ? 'a' : 'd' }" >Multiplicity Totals</a> 
					</th>
				</tr>
				<tr>
					<td colspan="2"></td>
					<td>
					 	<input type="hidden" name="restoreOutput" id="restoreOutput" value="output.jsp?id=${param.id}&showerId=${param.showerId}"></input>
						<c:choose>
							<c:when test='${mFilter != null && mFilter != "" }'>
								<input type="checkbox" name="viewAdvanced" id="viewAdvanced" checked> View Multiplicity Totals</input>
							</c:when>
							<c:otherwise>
								<input type="checkbox" name="viewAdvanced" id="viewAdvanced" > View Multiplicity Totals</input>
							</c:otherwise>
						</c:choose>					
					</td>
					<td style="display: ${displayMultiplicity};" name="advanced">
						<c:if test='${not empty multiplicityFilter }'>
							<select name="mFilter" id="mFilter" onchange="location = this.options[this.selectedIndex].value;">
								<c:choose>
									<c:when test='${mFilter != null && mFilter== "" }'>
										<option value="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=0" selected>All</option>
									</c:when>
									<c:otherwise>
										<option value="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=0">All</option>
									</c:otherwise>
								</c:choose>
								<c:forEach items="${multiplicityFilter }" var="filter">
									<c:choose>
										<c:when test='${mFilter != null && mFilter == filter}'>
											<option value="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${filter }" selected>${filter }</option>
										</c:when>
										<c:otherwise>
											<option value="output.jsp?id=${param.id}&showerId=${param.showerId}&mFilter=${filter }">${filter }</option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</c:if>					
					</td>
				</tr>
				<c:choose>
					<c:when test="${param.start != null}">
						<c:set var="start" value="${param.start}"/>
						<c:set var="end" value="${param.start + 30}"/>
					</c:when>
					<c:otherwise>
						<c:set var="start" value="0"/>
						<c:set var="end" value="30"/>
					</c:otherwise>
				</c:choose>
				<c:forEach items="${rows}" begin="${start}" end="${end}" var="row" varStatus="li">
					<tr bgcolor="${row.eventNum == eventNum ? '#aaaafc' : (li.count % 2 == 0 ? '#e7eefc' : '#ffffff')}">
						<td>
							<c:if test="${row.eventNum == eventNum}">
								<img src="../graphics/Tright.gif"></img>
							</c:if>
							<a href="../analysis-shower/event-choice.jsp?id=${param.showerId}&eventNum=${row.eventNum}&mFilter=${mFilter}&eventDir=${eventDir}&eventDateTime=${row.dateF}&submit=true">${row.dateF}</a>
						</td>
						<td>
							${row.eventCoincidence}
						</td>
						<td>
							${row.numDetectors}
								(<c:forEach items="${row.idsMult}" var="detectorId"> <e:popup href="../data/detector-info.jsp?id=${detectorId.key}" target="new" width="460" height="160">${detectorId.key}</e:popup>[${detectorId.value }]</c:forEach>)
						</td>
						<td style="display: ${displayMultiplicity};" name="advanced">
							${row.multiplicityCount }
						</td>
					</tr>
				</c:forEach>
				<tr>
					<td colspan="3">
						<e:pagelinks pageSize="30" start="${start}" totalSize="${rows}" name="event" names="events"/>
					</td>
					<td style="display: ${displayMultiplicity};" name="advanced"></td>
				</tr>
			</table>
		</td>
		<td align="center" valign="top">
			<p>
				Click on image for a larger view
			</p>
			<e:popup href="../analysis-shower/show-plot.jsp?showerId=${showerResults.id}&id=${results.id}&eventDir=${eventDir}" target="showerPopup" width="650" height="750">
				<img src="${results.outputDirURL}/plot_thm.png"/>
			</e:popup>
			<p>
				View raw data or geometry for ${crtEventRow.dateF} for detector ID 
				<c:forEach items="${crtEventRow.ids}" var="detectorId">
					<a href="../analysis-shower/find-data.jsp?detectorId=${detectorId}&time=${crtEventRow.date.time}">${detectorId}</a>
				</c:forEach>
			</p>
			<%@ include file="events-table.jspf" %>
		</td>
	</tr>
</table>
<p>
	Analysis run time: ${showerResults.formattedRunTime}; estimated: ${showerResults.formattedEstimatedRunTime}
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${showerResults.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">shower analysis directory</e:popup> or <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">event plot analysis directory</e:popup> 
</p>
<p>
	<e:rerun type="shower" id="${showerResults.id}" label="Change"/> your parameters
</p>
<% if (!user.isGuest()) { %>
	<p><b>OR</b></p>
	<%@ include file="save-form.jspf" %>
<% } %>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
</c:when>
<c:otherwise>
	${message }
</c:otherwise>
</c:choose>
		<!-- end container -->
	</body>
</html>
