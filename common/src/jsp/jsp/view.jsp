<%
	String filename = request.getParameter("filename");
	String menu = request.getParameter("menu");
	String type = request.getParameter("type");
	String get = request.getParameter("get");
	
	if (filename != null) {
		if ("meta".equals(get)) {
			response.sendRedirect("../data/view-metadata.jsp?filename=" + filename + (menu == null ? "" : "&menu=" + menu));
			return; 	
		}
		else if ("data".equals(get)) {
			if ("data".equals(type)) {
				response.sendRedirect("../data/view.jsp?filename=" + filename + (menu == null ? "" : "&menu=" + menu));
				return;
			}
			else if ("plot".equals(type)) {
				response.sendRedirect("../plots/view.jsp?filename=" + filename + (menu == null ? "" : "&menu=" + menu));
				return;
			}
		}
	}
%>

<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<html>
<head>
    <title>View Data</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->

<%

if (menu==null) menu="yes";
if (menu.equals("yes")){
//be sure to set this before including the navbar
String headerType = "Data";
if(type != null && type.equals("uploadedimage")){
    headerType = "Posters";
}
%>
<%@ include file="include/navbar_common.jsp" %>

<%
}
if(filename == null){
%>
    <center><b>Please choose a file to view.</b></center>
<%
    return;
}

if(type == null){
%>
    <center>
    <b>Choose the type of this file.</b><br>
    <a href="view.jsp?filename=<%=filename%>&type=data">Raw Data</a><br>
    <a href="view.jsp?filename=<%=filename%>&type=plot">Plot</a><br>
<%
    return;
}

//get either the metadata or the plot

if(get == null){
%>
    <center>
    <b>View either:</b><br>
        <a href="view.jsp?filename=<%=filename%>&type=<%=type%>&get=data">Datafile</a> for file: <%=filename%><br>
        <a href="view.jsp?filename=<%=filename%>&type=<%=type%>&get=meta">Metadata</a> for file: <%=filename%><br>
<%
    return;
}

//to highlight or not to highlight (a specific line)
String highlight = request.getParameter("highlight");
if(highlight == null){
    highlight = "no";
}

java.util.List meta = null;
String content = "";        //metadata, plot, or datafile
%>
<center>
    <%=content%>
</center>

</body>
</html>
