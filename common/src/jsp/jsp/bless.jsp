<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Bless Data</TITLE>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
</HEAD>
<BODY>
<FONT face=ARIAL>
<CENTER>
<TABLE width="100%" cellpadding="0" cellspacing="0" align=center>

<%
boolean error = false;
String blessFiles[] = request.getParameterValues("filename");

if ( blessFiles == null) {
    error = true;
%>
    <TR><TD>Error: Bless files not specified! Close window and try again.<TD></TR>
<%
}
else{
    //add blessed metadata for this LFN
    ArrayList meta = new ArrayList();
    meta.add("blessed boolean true");

    boolean metaUpdated = true;
    for (int i = 0; i < blessFiles.length; i++) {
        try{
            metaUpdated &= setMeta(blessFiles[i], meta);
        } catch(ElabException e){
            out.println("<font color=red>" + e + "</font><!--" + blessFiles[i] + "--><br>");
            metaUpdated = false;
        }
    }

    if(metaUpdated){
%>
        <TR><TD>You have successfully blessed your data.<TD></TR>
<%
    }
    else{
%>
        <TR><TD><font color="red">Error saving blessing your data.</TD></TR>
<%
    }
}   //bless files not null
%>
</TABLE>
<a href=# onclick="window.close()">Close</A>
</CENTER>
</FONT>
</BODY>
</HTML>
