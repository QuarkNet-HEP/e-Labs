<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Frequently Asked Questions</title>
		<%= elab.css("css/style2.css") %>
		<%= elab.css("css/library.css") %>
		<%= elab.css("css/one-column.css") %>
	</head>
	
	<body id="faq" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top"
				<div id="header">
					<%@ include file="include/header.jsp" %>
				</div>
				<div id="nav">
					<%@ include file="include/nav.jsp" %>
					<div id="subnav">
						<%@ include file="include/nav_library.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<div id="content-header">
	Frequently Asked Questions
</div>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<!-- nothing here -->
			</div>
		</td>
		<td>
			<div id="center">
				<%
					ElabFAQ faq = elab.getFAQ();
					if (faq.isEmpty()) {
						%>
							<span class="warning">There are no FAQs in the database!</span>
						<%
					}
					else {
						%>
							<p>
						<%
						Iterator i = faq.entries().iterator();
						while (i.hasNext()) {
							ElabFAQ.Entry e = (ElabFAQ.Entry) i.next();
							out.write(e.toString());	
						}
						%>
							</p>
						<%
					}
				%>
			</div>
		</td>
		<td>
			<div id="right">
				<!-- nothing here either -->
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
				<a href="milestones.jsp">Milestones (text version)</a>
				 - 
				<a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a>
				 - 
				<a href="showReferences.jsp?t=reference&f=peruse">All References for Study Guide</a>
				<a href="showReferences.jsp?t=reference&f=peruse">
					<img src="graphics/ref.gif">
				</a>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
