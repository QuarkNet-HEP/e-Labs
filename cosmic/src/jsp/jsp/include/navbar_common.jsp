<%
	request.setAttribute("headerType", headerType.toLowerCase());
%>

		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/${headerType}.css"/>
	</head>	
	<body class="${headerType}">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../../include/nav.jsp" %>
						<div id="subnav">
							<jsp:include page="../include/nav-${headerType}.jsp"/>
						</div>
					</div>
				</div>
			</div>
