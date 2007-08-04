<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<ul>
	<li><a href="../posters/new.jsp" id="nav1">New Poster</a></li>
	<li><a href="../posters/edit.jsp" id="nav2">Edit Posters</a></li>
	<li><a href="../posters/view.jsp" id="nav3">View Posters</a></li>
	<li><a href="../posters/delete.jsp" id="nav4">Delete Poster</a></li>
	<c:choose>
		<c:when test="${user != null}">
			<li><a href="../plots?submit=true&key=group&value=${user.name}" id="nav5">View Plots</a></li>
		</c:when>
		<c:otherwise>
			<li><a href="../plots" id="nav5">View Plots</a></li>
		</c:otherwise>
	</c:choose>
	<li><a href="../jsp/uploadImage.jsp" id="nav6">Upload Image</a></li>
</ul>