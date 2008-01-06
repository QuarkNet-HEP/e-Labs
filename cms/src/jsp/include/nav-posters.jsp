<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<table cellpadding="0" cellspacing="0">
	<tr>
		<td><a href="../posters/new.jsp">New Poster</a></td>
		<td><a href="../posters/edit.jsp">Edit Posters</a></td>
		<td><a href="../posters/view.jsp">View Posters</a></td>
		<td><a href="../posters/delete.jsp">Delete Poster</a></td>
		<c:choose>
			<c:when test="${user != null}">
				<td><a href="../plots?submit=true&key=group&value=${user.name}&uploaded=true">View Plots</a></td>
			</c:when>
			<c:otherwise>
				<td><a href="../plots">View Plots</a></td>
			</c:otherwise>
		</c:choose>
		<td><a href="../jsp/uploadImage.jsp">Upload Image</a></td>
	</tr>
</table>
<script type="text/javascript" src="../include/text-shadow.js"></script>