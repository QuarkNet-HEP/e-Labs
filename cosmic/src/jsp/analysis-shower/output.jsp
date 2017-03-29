<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
	String outputDir = ecPath.replaceAll("eventCandidates", "");
	File multiplicitySummary = new File(outputDir + "multiplicitySummary");		
	EventCandidates ec = EventCandidates.read(ecFile, multiplicitySummary, csc, dir, eventStart, eventNum);
	
	Collection rows = ec.getRows();
	String message = ec.getUserFeedback();
	String mFilter = request.getParameter("mFilter");
	String restore = request.getParameter("restore");
	String displayMultiplicity = "none";
	if (mFilter != null && !mFilter.equals("") && !mFilter.equals("0")) {
		rows = ec.filterByMuliplicity(Integer.valueOf(mFilter));
		displayMultiplicity = "block";
	} else {
		if (mFilter != null && mFilter.equals("0")) {
			if (restore != null && restore.equals("yes")) {
				displayMultiplicity = "none";
				mFilter = "";
			} else {
				displayMultiplicity = "block";				
			}
		} else {
			mFilter = (String) analysis.getAttribute("mFilter");
			if (!mFilter.equals("") && !mFilter.equals("0")) {
				rows = ec.filterByMuliplicity(Integer.valueOf(mFilter));
				displayMultiplicity = "block";
			} else {
				if (sortCol == 3) {
					displayMultiplicity = "block";		
					if (mFilter.equals("")) {
						mFilter = "0";
					}
				}
			}
		}
	}
	//added to keep track of the page where the last event is
	int eventNdx = ec.getEventIndex();
	int pageLength = 30;
	if (mFilter != null && !mFilter.equals("") && !mFilter.equals("0")) {
		if (eventNdx > rows.size()) {
	    	Object[] filteredRows = rows.toArray();
	    	for (int i = 0; i < filteredRows.length; i++) {
	    		EventCandidates.Row r = (EventCandidates.Row) filteredRows[i];
	    		if (r.getEventNum() == Integer.parseInt(eventNum)) {
	    			eventNdx = i;
	    			break;
	    		}
	    	}		
		}
	}
	int	pageStart = (eventNdx / pageLength) * pageLength;
	int totalPages = rows.size() / 30;
	request.setAttribute("pageStart", pageStart);	
	request.setAttribute("totalPages", totalPages);	
	request.setAttribute("message", message);
	request.setAttribute("eventDir", ecPath);
	request.setAttribute("rows", rows);
	request.setAttribute("pageLength", pageLength);
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
					var newOutput = document.getElementById("restoreOutput").value+ "&mFilter=0&restore=yes";
					location = newOutput;
				}
				for (var row=0; row < rows.length; row++) {
					var advanced = rows[row].cells[rows[row].cells.length - 1];
					advanced.style.display = display;
				}
			});
		});			
		function addMultiplicityOption(link) {
			var viewMultiplicity = document.getElementById("viewAdvanced");
			//console.log(viewMultiplicity);
			if (viewMultiplicity.checked) {
				link.href += "&viewAdvanced=yes"
			}
		}		
		</script>
	</head>
	
	<body id="shower-study-output" class="data, analysis-output">
		<!-- entire page container -->
			Marker 1
			<div id="container">
			Marker 2
			<div id="top">
				Marker 3				
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			Marker 4
			<div id="content">
			Marker 5
<c:choose>
<c:when test="${not empty rows}">
		<p>Marker 6</p>
</c:when>
<c:otherwise>
	${message }
</c:otherwise>
</c:choose>
		<!-- end container -->
	</body>
</html>
