<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} Poster Session</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="posters" class="posters">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-posters.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h2>Poster Tools</h2>
			<p>
				Congratulations! You developed a research question and planned 
				and conducted an investigation.
			</p>
			<p>
				How will your explanations of your results hold up in discussions 
				with your classmates? Will your work stand the test of time and 
				peer review?
			</p>
			<p>
				Submit a poster summarizing your work. Use the menue of links 
				above to create, edit and view your poster.
			</p>
			<p>
				Your work is not over yet! Study the results from other 
				investigations. Look critically and logically at relationships 
				between the data and the explanations. Doubt results, challenge 
				ideas, replicate investigations, propose and analyze alternative 
				explanations. These are all part of doing science.
			<p>
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
