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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<table id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">


 <h2>E-Lab Questions and Answers</h2> 

  <P></P>

Several resources are available to get answers to questions, or to ask for
help from other LIGO e-Lab participants:

<UL>
<LI> Use <a href="/glossary">the Glossary</a> to 
     look up technical terms or to read articles about LIGO components and
     systems.</LI>

<LI> News and current status may be available from the (prototype!) 
     <a href='/'>main portal page</a>, or posted to 
     <a href='/forum_forum.php?id=38'>The
     Bulletin Board</a>.</LI>

<LI> You can report a problem or make a request to the I2U2 Help Desk
     using the <a href='/HelpDeskRequest.php'>Help
     Desk Request Form</a>.</LI>

</UL>

<P></P>


<h2>Still under development...</h2>
<P></P>
<UL>
<LI> Visit the <a href='/forum_forum.php?id=47'>
     Gladstone Room</a> for discussions with other participants about the
     LIGO e-Lab.</LI>

<LI> Post a question directly to the <a href='/forum_forum.php?id=58'>
     LIGO Help Desk</a></LI>

<LI> Visit the other  
     <a href='/forum_index.php'>discussion forums</a> 
     to find out what is happening with other e-Labs, or have a look at the
     other <a href='/forum_help_desk.php'>Help Desks</a></LI>

</UL>



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
