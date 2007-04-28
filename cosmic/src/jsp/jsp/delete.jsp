<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Delete file</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<%
String fileType=request.getParameter("type");
%>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Data";
String barColor = "4382BB";
if(fileType != null && fileType.equals("poster")){
    barColor="408C66"; //green for posters
    headerType = "Posters";
}
%>
<%@ include file="include/navbar_common.jsp" %>

<TABLE WIDTH=700 CELLPADDING=4>

<TR>
   <TD height="26" BGCOLOR=<%=barColor%> > <FONT COLOR=black><B>Delete your data.
   </B></FONT></TD>
</TR>

<%
String[] filenames = request.getParameterValues("filename");
if(filenames == null){
%>
    <tr><td align="center"><b>Please <a href="search.jsp?type=delete">choose</a> a file to delete.</td><tr>
    </table></body></html>
<%
    return;
}

String role = (String)session.getAttribute("role");
for (int i=0; i<filenames.length; i++){
    String file = filenames[i];
    String pfn = getPFN(file);
    if(pfn == null){
%>
        <tr><td align="center"><b>The file: <%=file%></b> no longer exists on the system.</td><tr>
        <tr><td align="center"><font size="-1">(no pfn associated with this lfn)</td></tr>
        </table></body></html>
<%
    return;
    }
    else{
        //bypass permission checking if role == admin
        if(!role.equals("admin")){
            Tuple t = getMetaKey(filenames[i], "group");
            if(t != null){
                //check to see if this group has permission to delete these files
                if(!groupName.equals((String)t.getValue())){
%>
                    <tr><td align="center"><b>Cannot delete: <%=filenames[i]%>.</b> You do not own the file.</td><tr>
                    </table></body></html>
<%
                    return;
                }
            }
            else{
%>
                <tr><td align="center"><b>There is no group associated with the file: <%=filenames[i]%>.</b> Since ownership is determined by group name, you do not have permission to delete this file.</td><tr>
                </table></body></html>
<%
                return;
            }
        }   //if admin
    }   //if pfn == null
}   //filename loop

String submit = request.getParameter("submit");
if(submit == null){
%>
    <form>
    <table width=50% colspace=4>
    <tr><td colspan="<%=filenames.length%>" align="center">Are you sure you want to delete <b>all</b> these files from the Quarknet database?</td></tr>
<%
    for (int i=0; i<filenames.length; i++){
        String file = filenames[i];
        out.println("<tr><td align=\"center\"><a href=\"view.jsp?filename=" + file + "&type=" + fileType + "&get=data\">" + file + "</a></td>");
        out.println("<input type=\"hidden\" name=\"filename\" value=\"" + file + "\"><tr>");
    }
%>
    </TABLE>

    <P>
    <TABLE BORDER=0 WIDTH=150 CELLPADDING=4>
            <tr>
                <input type="hidden" name="type" value="<%=fileType%>">
                <td align="center"><input type="submit" name="submit" value="Yes"></td>
                <td align="center"><input type="submit" name="submit" value="No"></td>
            </tr>
        </form>
    </TABLE>
<%
}
else if(submit.equals("Yes")){
    //delete the files
%>
    <table width=50% border=0>
<%
    for (int i=0; i<filenames.length; i++){
        String ret = "<b>" + filenames[i] + "</b> deleted from the Quarknet database.";
        try{
            deleteLFN(filenames[i]);
        }
        catch(ElabException e){
            ret = e.getMessage();
        }
%>
        <tr>
            <td align="center">
                <%=ret%>
            </td>
        </tr>
<%
    }
%>
    <tr>
        <td align="center">
            <a href="search.jsp?t=<%=fileType%>&f=delete">Delete more files</a>
            OR
            <a href=home.jsp>Go home</a>
        </td>
    </tr>
<%
}
else if(submit.equals("No")){
    response.sendRedirect("search.jsp?t=" + fileType + "&f=delete");
}
%>
</table>

</BODY>
</HTML>
