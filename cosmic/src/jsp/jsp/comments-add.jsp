<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ page import="org.apache.regexp.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<!-- EPeronja-07/22/2013: 556- Cosmic data search: requests from fellows 07/10/2013 replaced add-comments.jsp, lots of spaghetti code -->
<html>
<head>
	<title>Comments</title>
	<link rel="stylesheet" type="text/css" href="../include/style.css"/>
	<script>
		function goBackAndRefresh() {
			var referer = document.getElementById("referer");
			if (referer.value != null) {
			    window.location = referer.value;
			} 
		}
	</script>
</head>
<body>
<%
		String fileType=request.getParameter("t");
		String referer = request.getParameter("referer");
		if (referer == null) {
			referer = request.getHeader("Referer");
		}
		request.setAttribute("referer",referer);
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
		DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
        boolean metaSuccess = false;
        String fileName=request.getParameter("fileName");
        String lfn = fileName;
        String comments="";
        String commentsNew="";
        String groupName = "";
        String fileTitle=request.getParameter("title");
        String errorMessage = "";
        if (fileTitle==null || fileTitle.equals("")) fileTitle = lfn; //default to this if nothing is in the metadata for title

        if (fileName==null || fileName.length()==0) {
        	errorMessage = "Illegal call to add Comments.  No file name supplied.";
        } else { // proceed, file name supplied, check if it exists    
            // Lookup entry to rc.data for this file
       	 	boolean c_rc = false;
         	String pfn = user.getDir("data") + File.separator + lfn;
            if ( pfn==null || pfn.length()<1) {
            	errorMessage = "Illegal call to add Comments.  File does not exist.";
            } else { // proceed, poster name supplied
           	  	// read comments and optional title from metadata
           	  	CatalogEntry e = dcp.getEntry(fileName);
              	if(e != null){
					if (e.getTupleValue("title") != null) {
						  fileTitle = (String) e.getTupleValue("title");
				  	}
				  	if (e.getTupleValue("plotTitle") != null) {
						  fileTitle = (String) e.getTupleValue("plotTitle");
					}
				  	if (e.getTupleValue("comments") != null) {
						  comments = (String) e.getTupleValue("comments");
				   	}
                  	if (fileTitle.equals("")) fileTitle=lfn;	
                  	groupName = (String) e.getTupleValue("group");
              	} else {
              		errorMessage = "No metadata for "+lfn;
              	}

		   String reqType = request.getParameter("button");

          // If "Add Comments" request, copy data from form fields to put in metadata
		   String breakString="";

           if (reqType != null && reqType.equals("Add Comments")) {
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
        			 CatalogEntry entry = dcp.getEntry(fileName);
        			 entry.setTupleValue("comments", comments);
        			 dcp.insert(entry);                     
		          }
		    } // done with Add Comments button
  	     } //file exists test
  	 }    ///file name supplied test
	request.setAttribute("errorMessage", errorMessage);

	%>
<c:choose> 
  <c:when test="${empty errorMessage}" >       
	<table width="800px" style="cellpadding: 4px">
		  <tr>
		  	<td><a href="javascript:goBackAndRefresh();">Go Back</a></td>
		  </tr>
		  <tr><td class="<%=barStyle%>"><font FACE=ARIAL COLOR=000000><strong>Comments for file <%=fileName%></strong></font></td></tr>
          <tr><td>
			  <ul>
				   <li> Add your comments in the New Comments field.
		 		   <li> Click <b>Add Comments</b>.
			  </ul> 
	      </td></tr>	
	</table>
    <form method=get name="commentAdd">
        <table cellspacing="2" cellpadding="2" border=1>
	        <tr><td align="right"><input type="hidden" name="fileName" value="<%=fileName%>">
	          <input type="hidden" name="t" value="<%=fileType%>">
       		  <input type="hidden" name="title" value="<%=fileTitle%>">Title:</td><td><%=fileTitle%></td></tr>
			  <input type="hidden" name="referer" id="referer" value="${referer}" >
        	<tr><td align="right" valign="top">Current Comments:</td><td width="500"><%=comments%></td></tr>
    	   	<tr><td valign="top" align="right">Your Group:</td><td><%=groupName%><input type="hidden" name="commenter" value="<%=groupName%>" size="40"> </td></tr>
	       	<tr><td valign="top" align="right">Add Your Comments:</td><td><textarea name="commentsNew" cols="80" rows="10"> </textarea></td></tr>
    	   	<tr><td colspan="2" align="center"><INPUT type="submit" name="button" value="Add Comments" onClick="javascript:checkBlank()"></td></tr>
       </table>
   </form>
  </c:when>
  <c:otherwise>
  	<p>${errorMessage}</p>
  </c:otherwise>
</c:choose>
</body>
</html>
