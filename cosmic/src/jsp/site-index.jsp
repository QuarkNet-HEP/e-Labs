<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Site Index</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/site-index.css") %>
		<%= elab.css(request, "css/six-column.css") %>
	</head>
		
	<body id="site-index" class="site-index">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="include/header.jsp" %>
					<div id="nav">
						<%@ include file="include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="include/nav_site-index.jsp" %>
						</div>
					</div>
				</div>
			</div>

<div id="content">
<h1>Lost? You can go to any of the pages on this site from this list.</h1>


<table border="0" id="main">
<tr><td id="col1">
<SPAN class="indent1"><A HREF="home.jsp" >Home</A></SPAN><BR><BR>
<SPAN class="indent2"><A HREF="first.jsp" >The Big Picture</A></SPAN>
<SPAN class="indent2"><A HREF="first_web.jsp" >The Website</A></SPAN>
</td>

<TD VALIGN=TOP id="col2">
<SPAN class="indent1"><A HREF="library.jsp" >Library</A></SPAN><BR><BR>
<SPAN class="indent2"><A HREF="milestones_map.jsp" >Study Guide</A> and <A HREF="milestones.jsp"><B>text version</B></A></SPAN><BR>
<SPAN class="indent3"><a href="showReferences.jsp?t=reference&f=peruse">View Resources for Study Guide</a><BR>
<SPAN class="indent3"><a href="showReferences.jsp?t=glossary&f=peruse">View Glossary</a></BR>
<SPAN class="indent2"><A HREF="resources.jsp" >Resources</A></SPAN><BR>
<SPAN class="indent2">Online Links</A></SPAN><BR>
<SPAN class="indent3">Contacts</A></SPAN><BR>
<SPAN class="indent4"><A HREF="students.jsp" >Students</A></SPAN><BR>
<SPAN class="indent3">Tutorials</SPAN><BR>
<SPAN class="indent4"><A HREF="dpstutorial.jsp" >Performance Study Background</A></SPAN><BR>
<SPAN class="indent4"><A HREF="tryit_performance.jsp" >Step-by-Step Instructions: Performance</A></SPAN><BR>
<SPAN class="indent4"><A HREF="ltimetutorial.jsp" >Lifetime Study Background</A></SPAN><BR>
<SPAN class="indent4"><A HREF="tryit_performance.jsp" >Step-by-Step Instructions: Lifetime</A></SPAN><BR>
<SPAN class="indent4"><A HREF="fluxtutorial.jsp" >Flux Study Background</A></SPAN><BR>
<SPAN class="indent4"><A HREF="tryit_performance.jsp" >Step-by-Step Instructions: Flux</A></SPAN><BR>
<SPAN class="indent4"><A HREF="eshtutorial.jsp" >Shower Study Tutorial</A></SPAN><BR>
<SPAN class="indent4"><A HREF="tryit_shower.jsp" >Step-by-Step Instructions: Shower</A></SPAN><BR>
<SPAN class="indent4"><A HREF="geoInstructions.jsp" >Updating Geometry Tutorial</A></SPAN><BR>   


<SPAN class="indent3">Animations</SPAN><BR>
<SPAN class="indent4"><A HREF="flash/daq_only_standalone.html" >Classroom Cosmic Ray Detector</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/daq_portal_rays.html" >Sending Data to Grid Portal</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/analysis.html" >Analysis</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/collaboration.html" >Collaboration</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/SC2003.html" >Loop</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/griphyn-animate_sc2003.html" >CMS vs. QuarkNet</A></SPAN><BR>
<SPAN class="indent4"><A HREF="flash/DAQII.html" >DAQII</A></SPAN><BR>
</td>
<TD VALIGN=TOP id="col3">
   
<SPAN class="indent1"><A HREF="upload.jsp" >Upload</A></SPAN><BR><BR>
   
<SPAN class="indent2"><A HREF="upload.jsp" >Upload Data</A></SPAN><BR>
<SPAN class="indent2"><A HREF="geo.jsp" >Upload Geometry</A></SPAN><BR>
</td>
<TD VALIGN=TOP id="col4">
<SPAN class="indent1"><A HREF="search.jsp" >Data</A></SPAN><BR><BR>

<SPAN class="indent2"><B>Analysis</B></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=analyze&s=performance" >Performance Study</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=analyze&s=lifetime" >Lifetime Study</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=analyze&s=flux" >Flux Study</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=analyze&s=shower" >Shower  Study</A></SPAN><BR>
<SPAN class="indent2"><B>View</B></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=view" >Data Files</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=plot&f=view" >Plots</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=poster&f=view" >Posters</A></SPAN><BR>
<SPAN class="indent2"><B>Delete</B></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=split&f=delete" >Data Files</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=plot&f=delete" >Plots</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=poster&f=delete" >Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view">View My Plots</A></SPAN>
</td>
<TD VALIGN=TOP id="col5">
<SPAN class="indent1"><A HREF="poster.jsp" >Posters</A></SPAN><BR><BR>

<SPAN class="indent2"><A HREF="makePoster.jsp" >New Poster</A></SPAN><BR>
<SPAN class="indent2"><A HREF="editPosters.jsp" >Edit Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=poster&f=view" >View Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=poster&f=delete" >Delete Posters</A></SPAN>

<%        // No better way...we parse...userArea...sad...
        String groupName2 = null;
        String userArea2 = (String) session.getAttribute("userArea");
        String eLab2 = (String) session.getAttribute("appName");
        if (userArea2 != null){
            String[] sp2 = userArea2.split("/");
            groupName2 = sp2[5];
            String query="type='plot'+AND+project='"+eLab2+"'+AND+group+CONTAINS+'"+groupName2+"'";
            %>
            
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view&q=<%=query%>" >View My Plots</A></SPAN><BR>
<%

        }
        else
        {
        %>
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view">View My Plots</A></SPAN><BR>
        <%
        }
        %>





</td>
<td valign="top" id="col6">
<SPAN class="indent1"><A HREF="rubric.html">Assessment</A></SPAN><BR><BR>
</td>
</td></tr>
</table>








			</div>
<!-- end content -->	

			<div id="footer"> </div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
