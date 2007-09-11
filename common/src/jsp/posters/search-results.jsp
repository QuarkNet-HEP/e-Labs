<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>


<c:if test="${!empty searchResults}">
	<table id="search-results">
		<tr>
			<th>Title</th>
			<th>Date</th>
			<th>Group</th>
			<th>Teacher</th>
			<th>School</th>
			<th>City</th>
			<th>State</th>
			<th>Year</th>
			<th></th>
			<th></th>
			<th></th>	
		</tr>
		<c:forEach items="${searchResults}" var="poster">
			<c:set var="tuples" value="${poster.tupleMap}"/>
			<tr>
				<td>
					<e:popup href="../posters/display.jsp?name=${tuples.name}" target="poster" width="700" height="900">${tuples.title}</e:popup>
				</td>
				<td><e:format type="date" format="MMMMMMMMM dd, yyyy" value="${tuples.date}"/></td>
				<td>${tuples.group}</td>
				<td>${tuples.teacher}</td>
				<td>${tuples.school}</td>
				<td>${tuples.city}</td>
				<td>${tuples.state}</td>
				<td>${tuples.year}</td>
				<td><a href="../jsp/add-comments.jsp?t=poster&fileName=${tuples.name}">View/Add Comments</a></td>
				<td><a href="../posters/display.jsp?type=paper&name=${tuples.name}">View as Paper</a></td>
				<td><a href="../data/view-metadata.jsp?filename=${poster.LFN}">View Metadata</a></td>
			</tr>
		</c:forEach>
	</table>
</c:if>
