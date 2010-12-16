<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Site Help</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/site-index.css"/>
	</head>
		
	<body id="site-index" class="site-index">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>

			<div id="content">


<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">


<h1>Site Index: Lost? Go to any of the pages <i>on this site</i> from here.</h1>
<br /><br />

<table border="0" id="main">
	<tr>
		<th class="home"><a href="../home">Project Map</a></th>
		<th class="library"><a href="../library"  class="library">Library</a></th>
		<th class="data"><a href="../data">Data</a></th>
		<th class="posters"><a href="../posters">Posters</a></th>
		<th class="assessments"><a href="../assessment">Assessment</a></th>
	</tr>
	<tr>
		<td class="home">
			<ul>
				<li>
			    Project Map - <a href="../library/milestones.jsp">text version</a></il>
				<li><a href="../home/cool-science.jsp"><b>Cool Science</b></a></li>
				<li><a href="../site-index/site-map-anno.jsp"><b>Explore!</b></a></li>
				<li><a href="../home/about-us.jsp"><b>About Us</b></a></li>
				<li>e-Lab Intro:<br /><e:popup href="../video/intro-interface.html" target="tryit" width="800" height="659">Screencast (with Sound)</e:popup></li> or <e:popup href="../library/intro-tutorial.jsp?slide=-1" target="tryit" width="900" height="659">Screenshots</e:popup></li>
				
			</ul>
		</td>
		<td class="library">
			<ul>
				<li><a href="/library/kiwi.php?title=Category:LIGOGLOSSARY" target="glossary"><b>Glossary</b></a></li>
				<li><a href="../library/resources.jsp"><b>Resources</B></a></li>
					<ul>
						<li>
							<b>Contacts</b>
							<ul>
								<li><a href="../library/students.jsp">Students</a></li>
							</ul>
						</li>
					</ul>
						
						
					<li><a href="../library/big-picture.jsp"><b>The Big Picture</b></a></li>
					<li><a href="<a href="#" onclick="javascript:window.open('\/library\/kiwi.php\/LIGO_FAQ', 'faq', 'width=500,height=300, resizable=1, scrollbars=1');return false;">FAQs</a></li>				</li>
			<li><a href="../library/site-tips.jsp"><b>Site Tips</b></a></li>
			</ul>
		</td>
		<td class="data">
			<ul>
				<li>
					<strong>Analysis</strong>
					<ul>
						<li><a href="../data">Data</a></li>
						<li>Tutorials:<br /><e:popup href="../video/intro-bluestone.html" target="tryit" width="800" height="659">Screencast (with Sound)</e:popup></li> or <e:popup href="../bluestone/tutorial.jsp" target="tryit" width="900" height="659">Screenshots</e:popup></li>
						<li><a href="../bluestone/">Bluestone</a></li>
						<li><a href="../plots/">View Plots</a></li>
						<li><a href="../analysis/list.jsp">Analyses</a></li>
					</ul>
				</li>
				<li>
					<strong>View</strong>
					<ul>
						<li><a href="../plots/">View Plots</a></li>
					</ul>
				</li>
				<li>
					<strong>Delete</strong>
					<ul>
						<li><a href="../plots/delete.jsp">Plots</a></li>
					</ul>
				</li>
			</ul>
		</td>
		<td class="posters">
			<ul>
				<li><a href="../posters/new.jsp"><b>New Poster</b></a></li>
				<li><a href="../posters/edit.jsp"><b>Edit Posters</b></a></li>
				<li><a href="../posters/search.jsp"><b>View Posters</b></a></li>
				<li><a href="../posters/delete.jsp"><b>Delete Posters</b></a></li>
				<li><a href="../plots/my-plots.jsp"><b>View My Plots</b></a></li>
				<li><a href="../jsp/uploadImage.jsp"><b>Upload Images</b></a></li>
			</ul>
		</td>
		<td class="assessments">
			&nbsp; 
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
