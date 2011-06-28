<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>


<c:if test="${!empty searchResults}">
	You can sort the results by clicking on the header. 
	
	<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
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
		$("#search-results").tablesorter({headers: {1:{sorter:'MMMM dd yyyy'}, 8:{sorter:false}}});
	}); 
	</script>

	<table id="search-results" class="tablesorter">
		<thead>
			<tr>
				<th>Title</th>
				<th>Date</th>
				<th>Group</th>
				<th>Teacher</th>
				<th>School</th>
				<th>City</th>
				<th>State</th>
				<th>Year</th>
				<th>&nbsp;</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${searchResults}" var="poster">
				<c:set var="tuples" value="${poster.tupleMap}"/>
				<tr>
					<td>
						<e:popup href="../posters/display.jsp?name=${tuples.name}" target="poster" width="700" height="900">${tuples.title}</e:popup>
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
							<li><a href="../jsp/add-comments.jsp?t=poster&fileName=${tuples.name}">View or Add Comments</a></li>
							<li><a href="../posters/display.jsp?type=paper&name=${tuples.name}">View as Paper</a></li>
							<li><a href="../data/view-metadata.jsp?filename=${poster.LFN}">View Metadata</a></li>
						</ul>
					</td>
				</tr>
			</c:forEach>
		</tbody>
	</table>
</c:if>
