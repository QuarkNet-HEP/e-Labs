<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<html>
<head>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>
<%@ include file="include/jdbc_userdb.jsp" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<title>Frequently Asked Questions</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<BR>

</head>
<body>
<div align="center">
<TABLE WIDTH=794 CELLPADDING=10>
<TR><TD BGCOLOR=#00FF99>
<FONT FACE=ARIAL SIZE=+1><B>Frequently Asked Questions</B></FONT>
</TD></TR>
<%
//perform the metadata search
ArrayList lfnsmeta = null;
String q="";
String type = "";


                        
    try {
        q="type=\'FAQ\'and project=\'"+eLab+"\'";
        lfnsmeta = getLFNsAndMeta(out, q);
        
        if (lfnsmeta == null)
        {
            warn(out, "There are no FAQ in the database!");
        }
        else
        {
        for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
            ArrayList pair = (ArrayList)i.next();
            String lfn = (String)pair.get(0);
            ArrayList metaTuples = (ArrayList)pair.get(1);
            String info = " ";

            //create the HashMap of metadata Tuple values
            for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
                Tuple t = (Tuple)j.next();
                if ((t.getKey()).equals("description")) info= (String) t.getValue();
                //if ((t.getKey()).equals("height")) refHeight= (String) t.getValue();
 
            } // metaTuples, j

            out.write("<tr><td>");
            out.write(info);
            out.write("</td></tr>");

        } // lfnsmeta, i
    } 
    }
    catch (IOException e) {
   %> <font color='red'> ERROR! <%=e%></font> <%
       }
            %> 

</div>
</body>
</html>        
