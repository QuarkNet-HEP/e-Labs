<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/three-column.css"/>
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<c:if test="${user != null}">
							<%@ include file="../include/nav.jsp" %>
						</c:if>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Join a national collaboration of high school students to study CMS test beam data.</h1>

<!-- there is no way to do this without tables unfortunately -->
<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<img src="../graphics/final_animation_small.gif" alt="Collision" />
			</div>
		</td>
		<td>
			<div id="center">
				<h2>How small?</h2>

				<ul>
					<li>How small is so small that we can get no smaller?</li>
					<li>Why do objects have mass?</li>
					<li>How do scientists "see" particles much smaller than an atom?</li>
					<li>Understand how a 12,000 ton detector &quot;sees&quot; electrons, muons and other particles.</li>
				</ul>

				<h2>Who are we?</h2>
				<p>We're a collaboration of high school students and teachers analyzing data
        		from the <emph>Compact Muon Solenoid Collaboration,</emph> CMS, experiment at 
        		CERN in Geneva, Switzerland to answer some of these questions. We're working 
        		with computer scientists to provide cutting edge tools that use <strong>grid techniques</strong>
        		to help you share data, graphs, and posters and collaborate with other students nationwide.</p>


				<h2>Who can join?</h2>
				<p><strong>You</strong>! Think about steps you'd take to investigate particle 
				collisions at the highest accelerator energies. How would you get started? 
				What do you need to know? Can you analyze data?</p>

			</div>
		</td>
		<td>
			<div id="right">
				<%@ include file="../include/newsbox.jsp" %>
				<jsp:include page="../login/login-control.jsp">
					<jsp:param name="prevPage" value="../home/login-redir.jsp"/>
				</jsp:include>
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