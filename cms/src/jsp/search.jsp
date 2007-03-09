<%@ page buffer="1000kb" %>
<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Cosmics Data Interface</TITLE>
<%@ include file="include/javascript.jsp" %>
<!-- include css style file -->
<%
String ua = request.getHeader("User-Agent");
boolean isMSIE = (ua != null && ua.indexOf("MSIE") != -1);
response.setHeader("Vary", "User-Agent");

// I am sorry that we have to do this.
if (isMSIE) {
%>
<%@ include file="include/style-ie.css" %>
<%
} else {
%>
<%@ include file="include/style.css" %>    
<%
}

//type of search the user chose
String searchType = request.getParameter("t");
%>
</HEAD>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Data";
if(searchType != null && searchType.equals("poster")){
    headerType = "Posters";
}
%>
<%@ include file="include/navbar_common-new.jsp" %>

<%
//what is this?:
//String singQ="\'";
//String schoolQuery = "type="+singQ+"split"+singQ+" AND project="+singQ+ eLab+singQ+" AND school=" + singQ+groupSchool +singQ+" AND city="+singQ+groupCity + singQ;

//pre-defined searches
String groupQuery = "type=\'" + searchType + "\' AND project=\'" + eLab + "\' AND group=\'" + groupName + "\'";
String teacherQuery = "type=\'" + searchType + "\' AND project=\'" + eLab + "\' AND teacher=\'" + groupTeacher + "\'";
String schoolQuery = "type=\'" + searchType + "\' AND project=\'"+eLab+"\' AND school=\'" +groupSchool +"\' AND city=\'"+ groupCity + "\'";
String cityQuery = "type=\'" + searchType + "\' AND project=\'"+eLab+"\' AND city=\'"+ groupCity + "\'";
String stateQuery = "type=\'" + searchType + "\' AND project=\'"+eLab+"\' AND state=\'"+ groupState + "\'";
String allQuery = "type=\'" + searchType + "\' AND project=\'" + eLab + "\'";

//include the instructions/search options and table listing based on the searchType
if(searchType == null){
    //default instructions/options
%>
    <%@ include file="include/search_default.jsp" %>
<%
}
else if(searchType.equals("split")){
%>
    <%@ include file="include/search_split.jsp" %>
<%
}
else if(searchType.equals("plot")){
%>
    <%@ include file="include/search_plot.jsp" %>
<%
}
else if(searchType.equals("poster")){
%>
    <%@ include file="include/search_poster.jsp" %>
<%
}
%>

</body>
</html>
