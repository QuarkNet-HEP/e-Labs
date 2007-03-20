<%@ include file="../../include/elab.jsp" %>
<%@ include file="../../modules/login/loginrequired.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/data.css") %>
		<%= elab.css(request, "css/two-column.css") %>
		<%= elab.css(request, "css/funny-borders.css") %>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../../include/nav_data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Search and view uploaded data.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="search_quick_links">
					<a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=schoolQuery%>&aname1=school&input1=<%=groupSchool%>"><%=groupSchool%></a>
					<a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=cityQuery%>&aname1=city&input1=<%=groupCity%>"><%=groupCity%></a>
					<a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=stateQuery%>&aname1=state&input1=<%=groupState%>"><%=groupState%></a>
					<a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=allQuery%>">Everyone</a>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
				<%@ include file="../studyhelp.jsp" %>
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
