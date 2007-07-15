<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.apache.regexp.*" %>
<%@ include file="common.jsp" %>
 <html>
<head>
	<title>Add a Reference</title>
<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<BR>
<div align="center">

<%
 

//LQ - see if admin will work here instead or else someone with admin role. July 28, 2006
//Permission to access this page restricted to development team
if (!(session.getAttribute("UserName").equals(elabRefMaker)))
{
    warn(out, "<br>You do not have premission to access this page!");
}
else
{
            String projectMeta="";   // projectMeta holds the value of the project metadata for the reference
			String projectSelected="";
			String referenceType=request.getParameter("t");
          if (referenceType==null) referenceType="reference";
          String referencePrefix="Reference_";
          String referenceText="Reference";
          if (referenceType.equals("glossary")) {
              referencePrefix="Glossary_"; 
              referenceText="Glossary Item";
          }
          if (referenceType.equals("FAQ")) { 
              referencePrefix="FAQ_"; 
              referenceText="FAQ Item";
          }
          if (referenceType.equals("news")) {
              referenceText="News Item";
              referencePrefix="News_"; 
          }

          String referenceName=request.getParameter("referenceName");
          if (referenceName==null) referenceName="";
          String html="";
          String errorMessage="";
          if (referenceName.length()>1)
          {
          if ((referenceName.startsWith(" "))) referenceName=referenceName.substring(1,referenceName.length());
          if (!(referenceName.startsWith(referencePrefix))) referenceName=referencePrefix+referenceName;
          }
		  String lfn=referenceName.replaceAll(" ","_");
          

          String time=request.getParameter("referenceTime");
          if (time == null || time.equals("")) {
            SimpleDateFormat bartDateFormat =
                            new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
            time = bartDateFormat.format(new Date());
          }
          String expire_time = request.getParameter("expireTime");
          if (expire_time == null || expire_time.equals("")) {
            SimpleDateFormat bartDateFormat =
                            new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
            Date OneWeek = new Date();
            OneWeek.setDate(OneWeek.getDate() + 7);
            expire_time = bartDateFormat.format(OneWeek);
          }
          
          java.util.List meta = null;
//          ArrayList meta = null;
          boolean metaSuccess = false;

           %>
<form action='searchReference.jsp' name='action_form' method=get>
<select name="f">
<option value="view">View
<option value="delete">Delete
<option value="upload">Upload
<option value="download">Download
<option value="add" selected>Add
</select>
<select name="t">
<option value="reference"<%if (referenceType.equals("reference")) out.print(" selected"); %>>Reference
<option value="glossary"<%if (referenceType.equals("glossary")) out.print(" selected"); %>>Glossary
<option value="FAQ"<%if (referenceType.equals("FAQ")) out.print(" selected"); %>>FAQ 
<option value="news"<%if (referenceType.equals("news")) out.print(" selected"); %>>News
</select>
Item(s).<br>
<input type='submit' name='submit' value='Go!'>
</form>
		  <TABLE WIDTH=723 CELLPADDING=4>
		  <TR><TD class="library_header">Add <%=referenceText%>s
		   </TD></TR>
           <tr><td><font face=arial size="-1">
		  <ul>
		   <LI>Enter the <%=referenceType%> name; start it with <b><%=referencePrefix%></b>.
		   <LI> Click <b>Get html for <%=referenceText%></b> to get current html in database
		   <li> Add or Edit your html in the html field.
		  <li> Click <b>Add html</b> to add or edit html
		  <LI> Remember to use javascript:showRefLink('your_url') for your links
		  <LI> You can use javascript:showRefLink('your_url',width,height) if you want to change the default width and height
		  <LI> If you can't see the whole reference, change the height of the reference. Click <b>Add html</b> for it to work.
		  </UL> </td></tr></table>
		  <%
		            String reqType = request.getParameter("button");

		            // If "Add html" request, copy data from form fields to referenceName.html file

		              if (reqType != null && reqType.equals("Add html")  ) 
		                  
		                   {
		                   // Note: eLab is defined in common.jsp
		  		         
		  		          html=request.getParameter("html");
		  		          if (html==null) {html=" ";}
		  		          projectSelected=request.getParameter("project");
		  		          if (projectSelected==null) {projectSelected=eLab;}
		  		          String condensedHtml = html.replaceAll("\r\n*"," ");
		  		          //set metadata with new html
		                    ArrayList metaAdd = null;
		                    metaAdd = new ArrayList();
		                    metaAdd.add("name string "+lfn);
		                    metaAdd.add("type string "+referenceType);
		                    metaAdd.add("project string "+ projectSelected);
		                    metaAdd.add("description string "+ condensedHtml); 
		                    if (referenceType.equals("news")) {
		                          metaAdd.add("expire string " + expire_time);
		                          metaAdd.add("time string " + time);
		                    }
		                    metaSuccess = setMeta(lfn, metaAdd);
		                     if (!metaSuccess) errorMessage="Problem entering html in database.";
		         
		                       
		           
		                }
		                else // not an add so we have to read information from html file or else start with empty fields.
		  		      {
		  		    //  Look for html metadata for referenceName
		               //get metadata
		                      html="";
		                      if (referenceName.length()>1) {
		                      meta = getMeta(lfn);
		                      if (meta != null) {
		                           for(Iterator i=meta.iterator(); i.hasNext(); ){
		                           Tuple t = (Tuple)i.next();
		                           if ((t.getKey()).equals("description")) html= (String) t.getValue();
		                           if ((t.getKey()).equals("project")) projectMeta = (String) t.getValue();
		                           
		                           if (referenceType.equals("news")) {
		                              if ((t.getKey()).equals("time")) time = (String) t.getValue();
		                              if ((t.getKey()).equals("expire")) expire_time = (String) t.getValue();
		                           }
		                               
		                           } // for
		                       } //meta test
		                      else
		                      {
		                      errorMessage="No meta entered for this reference";
		                      }//test on meta!=null
		                    } //referenceName
		                  }// check for Add button
		                  if (!errorMessage.equals(""))
		                  {
		  %>
                <%=errorMessage%>
                <%
                }
              %>
              
              <form method=get name="reference">
              <table cellspacing="2" cellpadding="2" border=1>
                            
            <% if (referenceName.equals(""))
            {
            %>
            <tr><td align="right"><%=referenceText%> name:</td><td><input type="text" name="referenceName" value="" size="40">(e.g. <%=referencePrefix%>proposed_research)</td></tr>
<% if (referenceType.equals("news")) 
            {%>
            <tr><td align="right">Time (do not change unless necessary):</td><td><input type="text" name="referenceTime" value="<%=time%>" size="40">
            <tr><td align="right">Expiration Date:</td><td><input type="text" name="expireTime" value="<%=expire_time%>" size="40">
            <%}%>
            <tr><td valign="top" align="right">Edit your html:</td><td><textarea name="html" cols="80" rows="10"> </textarea></td></tr>
            <%
            }
            else
            {
            %>
            <tr><td align="right"><%=referenceText%> name:</td><td><input type="text" name="referenceName" value="<%=lfn%>" size="40">(e.g. <%=referencePrefix%>proposed_research)</td></tr>
            <% if (referenceType.equals("news")) 
            {%>
            <tr><td align="right">Time (do not change unless necessary):</td><td><input type="text" name="referenceTime" value="<%=time%>" size="40">
            <tr><td align="right">Expiration Date:</td><td><input type="text" name="expireTime" value="<%=expire_time%>" size="40">
            <%}%>
            <tr><td valign="top" align="right">Add or Edit your html:</td><td><textarea name="html" cols="80" rows="10"><%=html%></textarea></td></tr>
            <%
            }
            if (projectMeta.equals("")) projectMeta=projectSelected;
            %>
            
            <tr><td align="right">Project</td><td align="left">
            <select name="project">
<option value="<%=eLab%>" <% if (projectMeta.equals(eLab)) { out.write("selected");}%> ><%=eLab%>
<option value="all" <% if (projectMeta.equals("all")) { out.write("selected");}%>>all (reference used by all projects)
</select></td></tr>

            <tr><td colspan="2" align="center"><INPUT type="submit" name="button" value="Get html for <%=referenceText%>"> <INPUT type="submit" name="button" value="Add html"></td></tr>
            <tr><td colspan="2"><input type="hidden" name=t value="<%=referenceType%>"></td></tr></table>
            </form>
             <%
            if (referenceName.length()>0 )
            {
            String simpleName=lfn.substring(referencePrefix.length());

            if (referenceType.equals("reference") || referenceType.equals("glossary"))
            {%>
                <A HREF="javascript:<%=referenceType%>('<%=simpleName%>')">Preview <%=referenceText%></A>
            <%}
            else
            {%>
                <A HREF="<%=referenceType%>.jsp">Preview <%=referenceType%> page</A>
            <%}%> 
            <BR><BR>
           <table border="1" cellpadding="5" width="400">
            <tr><th>Rendered as html</th></tr>
            <tr><td><%=html%></td></tr>
            </table>
            <%
            }
}
            %>
		  
</div>
</body>
</html>
