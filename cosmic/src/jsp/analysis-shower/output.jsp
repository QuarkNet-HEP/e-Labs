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


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-study-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	String es = (String) request.getParameter("eventStart");
	int eventStart;
	if (es == null || es.equals("")) {
		eventStart = 1;
	}
	else {
		eventStart = Integer.parseInt(es);
	}
	String sc = request.getParameter("sort");
	int sortCol = 1;
	if (sc != null) {
	    sortCol = Integer.parseInt(sc);
	}
	if (sortCol < 0) {
	    sortCol = 0;
	}
	if (sortCol > 2) {
	    sortCol = 2;
	}
	request.setAttribute("sort", new Integer(sortCol));
	String eventNum = (String) analysis.getParameter("eventNum");
	if ("1".equals(eventNum)) {
		eventNum = null;
	}
	int lineNo = 1;
	final int csc = sortCol;
	final String[] colNames = new String[] {"date", "eventCoincidence", "numDetectors"};
	final int[] defDir = new int[] {1, -1, -1};
	final int dir;
	if (request.getParameter("dir") == null) {
		dir = defDir[csc];
	}
	else {
		dir = "a".equals(request.getParameter("dir")) ? 1 : -1;
	}
	Set rows = new TreeSet(new Comparator() {
		public int compare(Object o1, Object o2) {
		    Map m1 = (Map) o1;
		    Map m2 = (Map) o2;
		    int c = ((Comparable) m1.get(colNames[csc])).compareTo(m2.get(colNames[csc]));
		    if (c == 0) {
		    	return ((Integer) m1.get("line")).compareTo(m2.get("line"));
		    }
		    else {
		        return dir * c;
		    }
		}
	});
	Set allIds = new HashSet();
	DateFormat df = new SimpleDateFormat("MMM d, yyyy HH:mm:ss z");
	df.setTimeZone(TimeZone.getTimeZone("UTC"));
	
	File ecFile = new File(results.getOutputDir(), (String) analysis.getParameter("eventCandidates"));
	BufferedReader br = new BufferedReader(new FileReader(ecFile));
	String line = br.readLine();
	while(line != null) {
	    //ignore comments in the file
	    if(!line.matches("^.*#.*")) {
	    	lineNo++;
    		if(lineNo >= eventStart) {
		    	Map row = new HashMap();
		    	String[] arr = line.split("\\s");
				row.put("eventCoincidence", Integer.valueOf(arr[1]));
				row.put("numDetectors", Integer.valueOf(arr[2]));
				row.put("eventNum", Integer.valueOf(arr[0]));
				row.put("line", Integer.valueOf(lineNo));
				if (eventNum == null) {
					eventNum = arr[0];
				}
				
				Set ids = new HashSet();
				for(int i = 3; i < arr.length; i += 3){
		        	String[] idchan = arr[i].split("\\.");
		        	ids.add(idchan[0]);
		        	allIds.add(idchan[0]);
				}
				row.put("ids", ids);
				
				String jd = arr[4];
				String partial = arr[5];
				
				//get the date and time of the shower
				NanoDate nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), Double.parseDouble(partial));
				row.put("date", nd);
				row.put("dateF", df.format(nd));
				rows.add(row);
				if (eventNum.equals(arr[0])) {
				    request.setAttribute("crtEventRow", row);
				}
    		}
	    }
		line = br.readLine();
    }
	request.setAttribute("rows", rows);
	request.setAttribute("eventNum", eventNum);
%>

<h1>Shower study candidates (<%= rows.size() %>)</h1>

<table id="shower-results">
	<tr>
		<td valign="top" width="70%">
			<table id="shower-events">
				<tr>
					<th width="98%">
						<a href="output.jsp?id=${param.id}&sort=0&dir=${(param.sort == '0' && param.dir == 'a') ? 'd' : 'a' }">Event Date</a>
					</th>
					<th width="1%">
						<a href="output.jsp?id=${param.id}&sort=1&dir=${(param.sort == '1' && param.dir == 'd') ? 'a' : 'd' }">Event Coincidence</a>
					</th>
					<th width="1%">
						<a href="output.jsp?id=${param.id}&sort=2&dir=${(param.sort == '2' && param.dir == 'd') ? 'a' : 'd' }">Detector Coincidence</a>
					</th>
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
							<e:rerun type="shower" analysis="${results.analysis}" label="${row.dateF}">
								<e:param name="eventNum" value="${row.eventNum}"/>
								<e:param name="submit" value="true"/>
							</e:rerun>
						</td>
						<td>
							${row.eventCoincidence}
						</td>
						<td>
							${row.numDetectors}
								(<c:forEach items="${row.ids}" var="detectorId"> <e:popup href="../data/detector-info.jsp?id=${detectorId}" target="new" width="460" height="160">${detectorId}</e:popup> </c:forEach>)
						</td>
					</tr>
				</c:forEach>
				<tr>
					<td colspan="3" align="right">
						<e:pagelinks pageSize="30" start="${start}" totalSize="${rows}" name="event" names="events"/>
					</td>
				</tr>
			</table>
		</td>
		<td align="center" valign="top">
			<p>
				Click on image for a larger view
			</p>
			<e:popup href="../analysis-shower/show-plot.jsp?id=${results.id}" target="showerPopup" width="650" height="750">
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
	Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysis-dir" 
		width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>
<p>
	<e:rerun type="shower" analysis="${results.analysis}" label="Change"/> your parameters
</p>
<p><b>OR</b></p>
<%@ include file="save-form.jspf" %>


			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
