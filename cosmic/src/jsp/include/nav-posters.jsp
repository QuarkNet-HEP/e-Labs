<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<ul>
	<li><a href="../posters/new.jsp">New Poster</a></li>
	<li><a href="../posters/edit.jsp">Edit Posters</a></li>
	<li><a href="../posters/view.jsp">View Posters</a></li>
	<li><a href="../posters/delete.jsp">Delete Poster</a></li>
	<c:choose>
		<c:when test="${user != null}">
			<li><a href="../plots?submit=true&key=group&value=${user.name}&uploaded=true">View Plots</a></li>
		</c:when>
		<c:otherwise>
			<li><a href="../plots">View Plots</a></li>
		</c:otherwise>
	</c:choose>
	<li><a href="../jsp/uploadImage.jsp">Upload Image</a></li>
</ul>