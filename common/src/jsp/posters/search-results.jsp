<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>


<c:if test="${!empty searchResults}">
	<table id="search-results">
		<tr>
			<th><e:sort key="title">Title</e:sort></th>
			<th><e:sort key="date">Date</e:sort></th>
			<th><e:sort key="group">Group</e:sort></th>
			<th><e:sort key="teacher">Teacher</e:sort></th>
			<th><e:sort key="school">School</e:sort></th>
			<th><e:sort key="city">City</e:sort></th>
			<th><e:sort key="state">State</e:sort></th>
			<th><e:sort key="year">Year</e:sort></th>
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
