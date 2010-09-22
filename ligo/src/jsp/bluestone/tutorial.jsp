<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Bluestone Tutorial - Screenshots</title>
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
	int slideNo=10;
	int max=17;
	int min=11;
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
		String linkSize = "<a href=\'tutorial.jsp?slide="+ slideNo + "&size=large\'>Larger Screenshots</a>";
		if (size.equals("large")) { append=""; paramSize="&size=large"; linkSize = "<a href=\'tutorial.jsp?slide="+ slideNo + "&size=small\'>Smaller Screenshots</a>";}
		String prevText = "";
		int prevSlide=slideNo - 1;
	if (slideNo > min) { prevText="<a href=\'tutorial.jsp?slide="+ prevSlide + paramSize +"\'><< Prev</a>";}
		String nextText = "";
		int nextSlide=slideNo + 1;
	if (slideNo < max) { nextText="<a href=\'tutorial.jsp?slide="+ nextSlide + paramSize +"\'>Next>></a>";}
	
    String imageText = "<img src=\'../graphics/bluestone"+ append+ "/screen_"+ slideNo + ".png'>";
%>
<h2>Bluestone Tutorial - Screenshots</h2>
<div style="width: 750px;text-align:center;margin-top:12px;">
<a href="?slide=11<%= paramSize %>">Access Bluestone</a> | <a href="?slide=12<%= paramSize %>">Plot</a> | <a href="?slide=13<%= paramSize %>">Log Scale</a> | <a href="?slide=14<%= paramSize %>">Date Ranges</a> | <a href="?slide=15<%= paramSize %>">Select Data</a> | <a href="?slide=16<%= paramSize %>">Select Ranges</a> | <a href="?slide=17<%= paramSize %>">Save Plot</a><br />
</div>
<%
    if (slideNo==10) {
     %>
<div style="width: 750px;text-align:left">
			<p><b>Bluestone</b> is the analysis tool for the  LIGO e-Lab.   It provides a web-based interface which lets you select which LIGO data you will process and how you want to view it.    
</p>
<p>This tutorial gives you step-by-step instructions on how to perform an analysis using <a href="index.jsp">Bluestone</a>.   Each page shows you an image of the screen you should see and tells you what to do and why. Be sure to read the text in red.  You may have to scroll down to see it. Use the <i>Next</i> and <i>Prev</i> buttons to move through the steps, or use the index above to jump into the topic that interests you.  You can also watch a <a href="../video/intro-bluestone.html" target="video">screencast</a> that has sound.
</p>

<p><a href="tutorial.jsp?slide=<%= min %>">Start the Tutorial...</a></p>
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
<table width="800">
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
		
    
