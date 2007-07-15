<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<ul>
	<!-- unfortunately ie6 doesn't recognize :first-child -->
	<li><a href="../home" id="nav1">Home</a></li>
	<li><a href="../library" id="nav2">Library</a></li>
	<c:if test="${user.upload}">
		<li><a href="../data/upload.jsp" id="nav-upload">Upload</a></li>
	</c:if>
	<li><a href="../data" id="nav3">Data</a></li>
	<li><a href="../posters" id="nav4">Posters</a></li>
	<li><a href="../site-index" id="nav5">Site Index</a></li>
	<li><a href="../assessment/index.jsp" id="nav6">Assessment</a></li>
</ul>