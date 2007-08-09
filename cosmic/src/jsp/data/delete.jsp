<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="delete-data" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Search and delete uploaded data.</h1>

<table border="0" id="main">
	<tr>
		<td id="center">
			<div id="left">
				<%@ include file="../include/delete.jsp" %>
				<jsp:include page="../data/search-control.jsp"/>
				<form action="delete.jsp" method="get" id="results-form">
					<%
						StructuredResultSetDisplayer srsd = new StructuredResultSetDisplayer(){
					    	private int count = 0;
							public void displayMonthContents(JspWriter out, Month month) throws IOException {
							    if (month.getFileCount() > 1) {
							        out.write("<input type=\"checkbox\" id=\"cb" + count + "\" name=\"selectall\" onClick=\"selectAll(" + count + ", " + count + month.getFileCount() + 1 + ")\"/>");
							        out.write("select all " + month.getFileCount() + " files");
							        count++;
							    }
							    super.displayMonthContents(out, month);
							}
					    
					    	public void displayFileContents(JspWriter out, File file)
					            throws IOException {
					    	    %>
					    	    	<input type="checkbox" name="file" 
					    	    		id="<%= "cb" + count %>" value="<%= file.getLFN() %>"/>
					    	    <%
					    	    count++;
					    	    super.displayFileContents(out, file);
					    	}
						};
						request.setAttribute("searchResultsDisplayer", srsd);
						
					%>
					<div class="search-results">
						<jsp:include page="../data/search-results.jsp"/>
					</div>
					<!-- this kind of nesting is an interesting problem -->
					<div id="right">
						<%@ include file="delete-help.jsp" %>
						<div id="analyze" class="study-right">
							<h2>Analyze</h2>
							<input type="submit" value="Delete selected data"/>
						</div>
						<%@ include file="../data/legend.jsp" %>
					</div>
				</form>
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
