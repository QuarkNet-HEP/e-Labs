<%@ include file="../include/elab.jsp" %>
<%@ page import="java.util.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Frequently Asked Questions</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
	
	<body id="faq" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<table id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">

<e:transclude
 url="http://${elab.properties['elab.host']}/elab/ligo/teacher/library/body.php/LIGO_FAQ"
     start="<!-- start content -->"
     end="<div class=\"printfooter\">"
/>


<!-- 
 <h1>FAQs: e-Lab Questions and Answers</h1> 

  <P></P>

Several resources are available to get answers to questions, or to ask for
help from other LIGO e-Lab participants:

<UL>
<LI> Use <a href="/library/kiwi.php/Category:LIGO">the Glossary</a> to 
     look up technical terms or to read articles about LIGO components and
     systems.</LI>

</UL>

<P></P>
 -->


<!-- 
<h2>Still under development...</h2>
<P></P>
<UL>
<LI> Visit the <a href='/forum_forum.php?id=47'>
     Gladstone Room</a> for discussions with other participants about the
     LIGO e-Lab.</LI>

<LI> Post a question directly to the <a href='/forum_forum.php?id=58'>
     LIGO Help Desk</a></LI>
 -->




		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
