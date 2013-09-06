<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>
<%
request.setAttribute("project", elab.getName());
%>
<c:if test="${!empty searchResults}">
	You can sort the results by clicking on the header. 
	<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>
	<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />
	<script type="text/javascript">
	$(document).ready(function() { 
		$.tablesorter.addParser({
			id: "MMMM dd yyyy", 
			is: function(s) { return false; },
			format: function(s) { return $.tablesorter.formatFloat(new Date(s + " 00:00").getTime()); },
			type: "numeric"
		});
		$("#search-results").tablesorter({sortList: [[1,0]]}, {headers: {2:{sorter:'MMMM dd yyyy'}, 9:{sorter:false}}});
	}); 
	</script>

	<table id="search-results" class="tablesorter">
	   	<colgroup>
       		<col span="1" style="width: 20%;">
       		<col span="1" style="width: 5%;">       		
       		<col span="1" style="width: 10%;">
       		<col span="1" style="width: 10%;">
       		<col span="1" style="width: 10%;">
       		<col span="1" style="width: 10%;">
       		<col span="1" style="width: 10%;">
       		<col span="1" style="width: 5%;">
       		<col span="1" style="width: 5%;">
       		<col span="1" style="width: 15%;">
    	</colgroup>
		<thead>
			<tr>
				<th>Title</th>
				<th>Status</th>
				<th>Date</th>
				<th>Group</th>
				<th>Teacher</th>
				<th>School</th>
				<th>City</th>
				<th>State</th>
				<th>Year</th>
				<c:choose>
					<c:when test='${project == "cms" }'>
						<th>Printing papers? Select landscape in your printer options.</th>
					</c:when>
					<c:otherwise>
						<th>&nbsp;</th>
					</c:otherwise>
				</c:choose>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${searchResults}" var="poster">
				<c:set var="tuples" value="${poster.tupleMap}"/>
				<%
					Map map = (Map) pageContext.getAttribute("tuples"); 
					String filename = (String) map.get("name");
					String encodedFilename = java.net.URLEncoder.encode(filename, "UTF-8"); 
					pageContext.setAttribute("encodedLFN", encodedFilename);
				%>
				<tr>
					<td>
						<e:popup href="../posters/display.jsp?name=${encodedLFN}" target="poster" width="700" height="900">${tuples.title}</e:popup>
					</td>
					<td>
						<c:choose>
							<c:when test='${not empty tuples.status && tuples.status != "none"}'>
								${tuples.status}
							</c:when>
							<c:otherwise>
								unpublished
							</c:otherwise>
						</c:choose>
					</td>
					<td><e:format type="date" format="MMMM d, yyyy" value="${tuples.date}"/></td>
					<td>${tuples.group}</td>
					<td>${tuples.teacher}</td>
					<td>${tuples.school}</td>
					<td>${tuples.city}</td>
					<td>${tuples.state}</td>
					<td>${tuples.year}</td>
					<td>
						<ul>
							<li><a href="../jsp/add-comments.jsp?t=poster&fileName=${encodedLFN}">View or Add Comments</a></li>
							<li><a href="../posters/display.jsp?type=paper&name=${encodedLFN}">View as Paper</a></li>
							<li><a href="../data/view-metadata.jsp?filename=${encodedLFN}">View Metadata</a></li>
						</ul>
					</td>
				</tr>
			</c:forEach>
		</tbody>
	</table>
</c:if>
