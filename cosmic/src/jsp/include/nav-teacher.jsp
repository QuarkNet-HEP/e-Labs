<ul>
	<li><a href="../teacher" id="nav1">Teacher Home</a></li>
	<li><a href="../teacher/community.jsp" id="nav2">Share Ideas</a></li>
	<li><a href="../teacher/standards.jsp" id="nav3">Standards</a></li>
	<li><a href="../teacher/site-map.jsp" id="nav4">Site Index</a></li>
	<li><a href="../teacher/registration.jsp" id="nav5">Registration</a></li>
	<li><a href="../teacher/publish-posters.jsp" id="nav6">Publish Posters</a></li>
	<li><a href="/" id="nav7">I2U2 Home</a></li>
	<li><a href="../home/project.jsp" id="nav8">Project Home</a></li>
	<li><a href="../home" id="nav9">Student Home</a></li>
	<c:if test='${user.name == "admin" }'>
		<li><a href="../admin" id="nav10">Admin Home</a></li>
	</c:if>
</ul>
