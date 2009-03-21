<%@ include file="common.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Delete file</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%@ include file="include/javascript.jsp" %>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType="Library";
%>
<%@ include file="include/navbar_common.jsp" %>


<%

		  String referenceType=request.getParameter("type");
          if (referenceType==null) referenceType="reference";
          String referenceText="Reference";
          if (referenceType.equals("glossary")) {referenceText="Glossary Item";}
 String[] filenames = request.getParameterValues("filename");
if(filenames == null){
%>
    <tr><td align="center"><b>Please <a href="searchReference.jsp?type=delete&t=<%=referenceType%>">choose</a> <%=referenceText%>s to delete.</td><tr>
    </table></body></html>
<%
    return;
} //no files selected
%>
<div align="center">
<TABLE WIDTH=700 CELLPADDING=4>

		  <TR><TD class="library_header">
         Delete your <%=referenceText%>s.
   </TD>
</TR>
<%

String role = (String)session.getAttribute("role");

String submit = request.getParameter("submit");
if(submit == null){
%>
    <form>
    <table width=50% colspace=4>
    <tr><td colspan="<%=filenames.length%>" align="center">Are you sure you want to delete <b>all</b> these <%=referenceText%>s from the Quarknet database?</td></tr>
<%
    for (int i=0; i<filenames.length; i++){
        String file = filenames[i];
        %>
        <tr><tr align="center"><A HREF="addReference.jsp?t=<%=referenceType%>&referenceName=<%=file%>"><%=file%></A><BR>
<input type="hidden" name="filename" value="<%=file%>"></td></tr>
<%
    } //for
%>
    </TABLE>

    <P>
    <TABLE BORDER=0 WIDTH=150 CELLPADDING=4>
            <tr>
                <input type="hidden" name="type" value="<%=referenceType%>">
                <td align="center"><input type="submit" name="submit" value="Yes"></td>
                <td align="center"><input type="submit" name="submit" value="No"></td>
            </tr>
        </form>
    </TABLE>
<%
} //submit==null
else if(submit.equals("Yes")){
    //delete the files
%>
    <table width=50% border=0>
<%
    for (int i=0; i<filenames.length; i++){
        boolean modified = deleteLFNMeta(filenames[i]);
        if(modified){
%>
                <tr>
                    <td align="center">
                        <b><%=filenames[i]%></b> deleted from the Quarknet database.
                    </td>
                </tr>
<%
        }  //if modified
        else{
%>
            <tr>
                <td align="center">
                    Error while trying to delete <b><%=filenames[i]%></b> from the Quarknet database!
                </td>
            </tr>
<%
        } // not modified
      } // for loop
    } // submit has value
%>
</table>


<center><a href="searchReference.jsp?t=<%=referenceType%>&f=view">View <%=referenceText%>s</a> - <a href="searchReference.jsp?t=<%=referenceType%>&f=delete">Delete <%=referenceText%>s</a></center><br>

</div>
</BODY>
</HTML>
