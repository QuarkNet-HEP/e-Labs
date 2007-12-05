<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<ul id="nav-tutorial">
	<c:forEach begin="1" end="12" var="i">
		<li><a href="../data/tutorial${i}.jsp">${i}</a></li>
	</c:forEach>
</ul>