<%@ page import="java.io.*, java.util.*" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ include file="common.jsp" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Group <%=groupName%>'s Plots</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<FONT FACE="ARIAL">

<center><TABLE WIDTH=600 CELLPADDING=4>
<TR>
      
      <TD height="26" BGCOLOR="#408C66"> <FONT SIZE=+1 FACE="ARIAL" COLOR=black><B>Group <%=groupName%>'s Plots</B></FONT> 
      </FONT></TD>
    </TR>
</TABLE></center>
  <P>
  <center><table width="600" border="1" cellpadding="8">
 <tr><th align="center">Look for plots to use in your posters.</th></tr>

<%	
File dir = new File(plotDir);
String[] list = dir.list();
// if (list != null)  // This seemed to cause error!
for (int i=0; i<list.length; i++) {
    String item = list[i];
    File fi = new File(plotDir + item); 
    if (fi.isFile()) {
        String itemLC=item.toLowerCase();
        if (itemLC.endsWith(".gif") || itemLC.endsWith(".jpg") || itemLC.endsWith(".png") || itemLC.endsWith(".jpeg"))
        {
%>  
    <tr> 
            <td align="center"> 
              <font color=black size="+1" face="arial"> Plot name: <%=item%></font></A><br>
               <IMG SRC="<%=plotDirURL%><%=item%>"></td></tr>

<%
        }
    } //if


}  //for


%>
</table></body>
</html>
