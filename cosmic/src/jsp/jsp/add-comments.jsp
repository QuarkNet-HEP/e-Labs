<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ page import="org.apache.regexp.*" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="common.jsp" %>
<html>
<head>
	<title>Poster Comments</title>
<SCRIPT language=JavaScript>
function checkBlank()
 {


    return true;
 }
</SCRIPT>

<%
String fileType=request.getParameter("t");
%>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Data";
String barStyle = "addComment_bar_color_default";
if(fileType != null && fileType.equals("poster")){
    barStyle="addComment_bar_color_poster";
    headerType = "Posters";
}
%>
<%@ include file="include/navbar_common.jsp" %>

<%
String dateString=new String();
dateString="";

        boolean metaSuccess = false;
          String fileName=request.getParameter("fileName");
          String lfn = fileName;
          String comments="";
          String commentsNew="";
          java.util.List meta = null;
//          ArrayList meta = null;
          String fileTitle=request.getParameter("title");
          if (fileTitle==null || fileTitle.equals("")) fileTitle = lfn; //default to this if nothing is in the metadata for title

          if (fileName==null || fileName.length()==0)
           {
 %>
           <FONT color="red">Illegal call to add Comments.  No file name supplied.</font>
<%          
           }
           else // proceed, file name supplied, check if it exists

           {
                         	            // Lookup entry to rc.data for this file
        	 boolean c_rc = false;
	         String pfn = user.getDir("data") + File.separator + lfn;

              if ( pfn==null || pfn.length()<1) 
             {
 %>
           <FONT color="red">Illegal call to add Comments.  File does not exist.</font>
<%          
             }
             else // proceed, poster name supplied
             {
           
           
           // read comments and optional title from metadata
              meta = getMeta(lfn);
              if(meta != null){
                  for(Iterator i=meta.iterator(); i.hasNext(); ){
                      Tuple t = (Tuple)i.next();
                     if ((t.getKey()).equals("title")) {fileTitle = (String) t.getValue(); }
                     if ((t.getKey()).equals("plotTitle")) {fileTitle = (String) t.getValue(); }
                      if ((t.getKey()).equals("comments")) { comments= (String) t.getValue(); }
                       }
                       if (fileTitle.equals("")) fileTitle=lfn;
                  }
                  else
                  {
                  out.write("No metadata for "+lfn);
                  }
            %>
		  <P><TABLE WIDTH=800 CELLPADDING=4>
		  <TR><TD class="<%=barStyle%>">
		  <FONT FACE=ARIAL COLOR=000000><B>Comments for file <%=fileName%></B></FONT>
		   </TD></TR>
		   <center>
           <tr><td>
		  <ul>
		   <li> Add your comments in the New Comments field.
		  <li> Click <b>Add Comments</b>.
		  </UL> </td></tr></table>
		  <%
		  String reqType = request.getParameter("button");

          // If "Add Comments" request, copy data from form fields to put in metadata
		   String breakString="";

           if (reqType != null && reqType.equals("Add Comments")) 
                
                 {
		          GregorianCalendar calendar = new GregorianCalendar();
		          Date currentDate=new Date();
		          calendar.setTime(currentDate);
		          dateString=(calendar.get(Calendar.MONTH)+1)+"-";
		          dateString += calendar.get(Calendar.DATE)+"-";
		          dateString += calendar.get(Calendar.YEAR)+" ";
		          dateString += calendar.get(Calendar.HOUR);
		           String minuteString=":"+calendar.get(Calendar.MINUTE);
		     	  if (minuteString.length()==2 ) 
		          {
		             minuteString =":0"+minuteString.substring(1);
		          }
			          dateString += minuteString;
   		          if (comments.length() > 0) {breakString="<BR>";}
		          String commenter=request.getParameter("commenter");
		          commentsNew=request.getParameter("commentsNew");
  		        // add combined new and old comments to metadata if new comments
	              if (commentsNew.length()>1)
                  {
                     comments=comments+breakString+dateString;
                     comments += " "+commenter+"- "+commentsNew;
		             commentsNew="";
                     ArrayList metaAdd = null;
                     metaAdd = new ArrayList();
                     metaAdd.add("comments string "+ comments);
                     metaSuccess = setMeta(lfn, metaAdd);
                     if (!metaSuccess) out.write("Problem entering comments in database.");
		          }
		    } // done with Add Comments button
                // Make form for comments
              %>
              <form method=get name="commentAdd">
              <table cellspacing="2" cellpadding="2" border=1>
                            
             
              <tr><td align="right"><input type="hidden" name="fileName" value="<%=fileName%>">
              <input type="hidden" name="t" value="<%=fileType%>">
              <input type="hidden" name="title" value="<%=fileTitle%>">Title:</td><td><%=fileTitle%></td></tr>
             <tr><td align="right" valign="top">Current Comments:</td><td width="500"><%=comments%></td></tr>
            <tr><td valign="top" align="right">Your Group:</td><td><%=groupName%><input type="hidden" name="commenter" value="<%=groupName%>" size="40"> </td></tr>

            <tr><td valign="top" align="right">Add Your Comments:</td><td><textarea name="commentsNew" cols="80" rows="10"> </textarea></td></tr>
            <tr><td colspan="2" align="center"><INPUT type="submit" name="button" value="Add Comments" onClick="javascript:checkBlank()"></td></tr>
            </table>
            </form>
		  
		    <%
		  
		  
		  
		  
  	     } //file exists tests
		  
              }    ///file name supplied test
           %>
</center>
</body>
</html>
