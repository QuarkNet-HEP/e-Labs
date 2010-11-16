<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

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
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">



<h1>Posters: Post your results. Compare results. Draw conclusions!</h1>


<table border="0" id="main">
	<tr>
		<td>
			<div id="left">

				<div class="tab">
					<span class="tab-title">Posters</span>
					<div class="tab-contents">
						<p>
							Congratulations! Your team developed a research question and planned and conducted 
							an investigation. 
						</p>
						<p>
							How do your results stack up against those of other research groups? Will they 
							stand the test of time and peer review?
						</p>
						<p>
							Submit a poster summarizing your work. 
						</p>
						<p>
							Your work is not over yet! Study the results from other investigations. Look 
							critically and logically at relationships between the data and the explanations. 
							Doubt results, challenge ideas, replicate investigations, propose and analyze 
							alternative explanations. These are all part of doing science. 
						</p>
					</div>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab">
					<span class="tab-title">Pro Posters</span>
					<div class="tab-contents">
						<p>
							<img src="../graphics/postera.jpg"/>
							<img src="../graphics/posterc.JPG"/>
						</p>
					</div>
				</div>
			</div>
		</td>
	</tr>
</table>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
