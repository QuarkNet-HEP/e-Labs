<%
	headerType = headerType.toLowerCase();
	if (headerType.equals("resources")) {
	    headerType = "library";
	}
	request.setAttribute("headerType", headerType);
%>

		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/${headerType}.css"/>
		<style type="text/css">
			body {
				text-align: center;
			}
			body > * {
				margin-left: auto;
				margin-right: auto;
			}
			body > p > table, body > form > table {
				margin-left: auto;
				margin-right: auto;
			}
		</style>
	</head>	
	<body class="${headerType}">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../../include/header.jsp" %>
					<div id="nav">
						<c:if test="${headerType != 'teacher'}">
							<%@ include file="../../include/nav.jsp" %>
						</c:if>
						<div id="subnav">
							<jsp:include page="../include/nav-${headerType}.jsp"/>
						</div>
					</div>
				</div>
			</div>
		</div>
