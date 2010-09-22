<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>e-Lab Intro Tutorial - Screenshots</title>
		<%@ page import="java.util.*" %>
		<%@ page import="java.lang.*"  %>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		</head>
    <body id="super-bluestone" class="data">
		<!-- entire page container -->
		<div id="container">
			
			<div id="content">
<div align="center">

						
<%
	int slideNo=0;
	int max=10;
	int min=0;
		try {
			slideNo = Integer.parseInt(request.getParameter("slide"));
		}
		catch(NumberFormatException nfe) { 
			// don't care, use default. 
		}
		String size = request.getParameter("size");
		if (size == null) {size="small";}
		String append="-smaller";
		String paramSize="&size=small";
		String linkSize = "<a href=\'intro-tutorial.jsp?slide="+ slideNo + "&size=large\'>Larger Screenshots</a>";
		if (size.equals("large")) { append=""; paramSize="&size=large"; linkSize = "<a href=\'intro-tutorial.jsp?slide="+ slideNo + "&size=small\'>Smaller Screenshots</a>";}
		String prevText = "";
		int prevSlide=slideNo - 1;
	if (slideNo > min) { prevText="<a href=\'intro-tutorial.jsp?slide="+ prevSlide + paramSize +"\'><< Prev</a>";}
		String nextText = "";
		int nextSlide=slideNo + 1;
	if (slideNo < max) { nextText="<a href=\'intro-tutorial.jsp?slide="+ nextSlide + paramSize +"\'>Next>></a>";}
	
    String imageText = "<img src=\'../graphics/interface"+ append+ "/screen_"+ slideNo + ".png'>";
%>
<h2>e-Lab Intro Tutorial</h2>



<div style="width: 750px;text-align:center;margin-top:12px;">
<a href="?slide=0<%= paramSize %>">Intro</a> | <a href="?slide=1<%= paramSize %>">Project Map</a> | <a href="?slide=2<%= paramSize %>">Milestone Dots</a> | <a href="?slide=3<%= paramSize %>">Milestones</a> | <a href="?slide=4<%= paramSize %>">Logbook</a> | <a href="?slide=5<%= paramSize %>">Figure It Out-Tell Others</a> | <a href="?slide=6<%= paramSize %>">Milestone Seminars</a> | <a href="?slide=7<%= paramSize %>">Library-Resources</a> | <a href="?slide=8<%= paramSize %>">Posters-View Plots</a> | <a href="?slide=9<%= paramSize %>">Make Poster</a> | <a href="?slide=10<%= paramSize %>">View Poster</a> 
</div>
<%
    if (slideNo==-1) {
     %>
<div style="width: 750px;text-align:left">
<p>This tutorial gives you an overview of the e-Lab including the project map, milestones and their references, the logbook and navigation through the e-Lab.  Users who cannot watch the <a href="../video/intro-interface.html">e-Lab Intro Screencast</a> because they don't have sound will find this helpful. Be sure
to scroll down to the bottom of each screenshot to see the information in the red boxes.
</p>

<p><a href="intro-tutorial.jsp?slide=<%= min %>">Start the Tutorial...</a></p>
</div>
<%
}
else
{
%>
     
<table width="800">
<tr><td width="75"><%= prevText %></td><td width="650" align="center"><%= linkSize %></td><td width="75"><%= nextText %></td></tr>
</table>
	<%= imageText %>
<table width="750">
<tr><td width="75"><%= prevText %></td><td width="650" align="center"><%= linkSize %></td><td width="75"><%= nextText %></td></tr>
</table>
<%
}
%>	
</div>

</div>
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
</div>
</body>
</html>
		
    
