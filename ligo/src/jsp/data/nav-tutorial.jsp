<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2>
  Software Tutorial: Learn How to Use 
		  <a target="_blank" href="/ligo/tla">Bluestone</a>
</h2>
<ul id="nav-tutorial">
	<c:forEach begin="1" end="12" var="i">
		<li><a href="../data/tutorial${i}.jsp">${i}</a></li>
	</c:forEach>
</ul>
