<%@ page import="java.io.*, java.util.*" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.apache.regexp.*" %>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<html>
<head>
<title>Edit Posters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Posters";
%>
<%@ include file="include/navbar_common.jsp" %>

<P>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#408C66">
<FONT SIZE=+1 FACE=ARIAL color=black><B>Click on a poster to edit it.</B>
</TD></TR>
</TABLE>

<center>
<FONT FACE="ARIAL">

<P>
<TABLE WIDTH=800 CELLPADDING=4 Border="2">
                <tr> <th width="58%">Poster Title to Edit</th><th width="38%">Poster File Name</th></tr>

            <%	
         File dir = new File(posterDir);
  		 String[] list = dir.list();
 		// if (list != null)  // This seemed to cause error!
          for (int i=0; i<list.length; i++) {
             String item = list[i];
             File fi = new File(posterDir + item); 
             if (fi.isFile()) {
                String itemLC=item.toLowerCase();
                 if (itemLC.endsWith(".data") && !(itemLC.startsWith("template")))
                {
                int indData=itemLC.lastIndexOf(".data");
                String posterName=itemLC.substring(0,indData);
                // get title of the poster.  This could come from metadata or from looking for <title>Poster's title</title> 
                // and using Poster's Title for the link.
                
                        // Read the data file associated with poster.
                 File pdataFi = new File(posterDir + posterName +".data"); 
   		         String pdata="";
   		          try {
   			       FileReader fr = new FileReader(pdataFi);
  			       int count = 0;
   			       char buf[] = new char[100000];
  			       count=fr.read(buf, 0, 100000);
    		       fr.close();
          			pdata = String.valueOf(buf,0,count);
       				 }
       			 catch (Exception e) {
      			    out.println(" EXCEPTION! reading poster data" + " " + e.getMessage() );
      			  }
              
               
                RE re = new RE("%WORDS:TITLE%\\n(.*?\\n)%END%");
                re.setMatchFlags(RE.MATCH_SINGLELINE);

                re.match(pdata);
                String title = re.getParen(1);

                      %>  
                <tr> <td><A href="makePoster.jsp?posterName=<%=posterName%>" ><%=title%></A></td><td><%=posterName%></td></tr>

              <%
               }
              } //if


              }  //for
        //   } //if null


  %>


    




    	</table>  
    	
    	<hr>
</CENTER>
</center>
 
 </body>
</html>


