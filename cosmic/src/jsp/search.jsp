<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/data.css") %>
		<%= elab.css(request, "css/two-column.css") %>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="include/header.jsp" %>
					<div id="nav">
						<%@ include file="include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="include/nav_data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>What can you learn? Choose data and conduct a study</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="tab">
					<span class="tabtitle">Analysis</span>
					<div class="tabcontents">
						<p>
							<a href="?t=split&amp;f=analyze&amp;s=performance">Performance Study</a>
							- Look at data from a detector. Can you trust the data?
						</p>
						<p>
							<a href="?t=split&amp;f=analyze&amp;s=lifetime">Lifetime Study</a>
							- Do you live in Newton's or Einstein's world?
						</p>
						<p>
							<a href="?t=split&amp;f=analyze&amp;s=flux">Flux Study</a>
							- The rain of particles has many interesting properties including its 
							<a href="javascript:glossary('flux')">flux</a>.
							Are there more in Colorado than there are in South Carolina?
						</p>
						<p>
							<a href="?t=split&amp;f=analyze&amp;s=shower">Shower Study</a>
							- You can detect an air shower using the four panels at your school. 
							Your colleagues at other schools will want to know when you detect one, 
							so they can check for coincident showers at their school. Contribute 
							to cutting-edge research on the origin of high-energy primary cosmic rays.
						</p>
					</div>
				</div>		
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab">
					<span class="tabtitle">Analysis</span>
					<div class="tabcontents">
						<h2>VIEW</h2>
						<p>
							<a href="?t=split&amp;f=view">Data Files</a>
							- See what data has been uploaded into the system.
						</p>
						<p> 
							<a href="?t=plot&amp;f=view">Plots</a>
							- Look at what you and other groups have found!
						</p>
						<p>
							<a href="?t=poster&amp;f=view">Posters</a>
							- View and create posters of your plots.
						</p>
						<h2>DELETE</h2>
						<p>
							<a href="?t=split&amp;f=delete">Data Files</a>
							- Delete data your group has uploaded.
						</p>
						<p>
							<a href="?t=plot&amp;f=delete">Plots</a>
							- Delete plots your group owns.
						</p>
						<p>
							<a href="?t=poster&amp;f=delete">Posters</a>
							- Delete posters your group has made.
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
