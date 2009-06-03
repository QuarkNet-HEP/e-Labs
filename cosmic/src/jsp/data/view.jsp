<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="java.io.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-data" class="data">
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
		<td id="center">
<%
	String filename = request.getParameter("filename");
	if (filename == null) {
	    throw new ElabJspException("Please choose a file to view");
	}
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	if (entry == null) {
	    throw new ElabJspException("No metadata about " + filename + " found.");
	}
	request.setAttribute("e", entry);
	
	String highlight = request.getParameter("highlight");

	String pfn = RawDataFileResolver.getDefault().resolve(elab, filename);
	BufferedReader br; 
	
	try {
		br = new BufferedReader(new FileReader(pfn));
	}
	catch (FileNotFoundException ex) {
		throw new ElabJspException("Could not find file: " + filename);
	}
%> 
		<h2>${param.filename}</h2><br/>
		<a href="../data/view-metadata.jsp?filename=${param.filename}">Show metadata</a> |
		<c:if test="${e.tupleMap.detectorid != null}">
			<a href="../geometry/view.jsp?filename=${param.filename}">Show Geometry</a> |
		</c:if>
		<a href="../data/download?filename=${param.filename}&elab=${elab.name}&type=split">Download</a>
		<br/>
		<br/>
		<form method="get" action="../data/view.jsp">
			Go to time<br/>
			Hours: <e:trinput type="text" name="h" size="2" maxlength="2"/>
			Minutes: <e:trinput type="text" name="m" size="2" maxlength="2"/>
			Seconds: <e:trinput type="text" name="s" size="2" maxlength="2"/>
			
			<e:trinput type="hidden" name="filename"/>
			<e:trinput type="hidden" name="highlight"/>
			
			<input type="submit" value="Go"/>
		</form>
		<table border="0" cellpadding="0" cellspacing="0">
			<%
				String str = null;
				int count=0;
	
				//seek to a specific time in the raw file
				String hour = request.getParameter("h");
				String dataLine = request.getParameter("line");
				
				if (hour != null) {
					String minute = request.getParameter("m");
					String second = request.getParameter("s");
					int h, m, s, thisSec, startSec;
					int startLine = -1;
					//String[] time_arr = data_time.split(":");
					h = Integer.parseInt(hour);
					m = (minute == null || minute.equals("")) ? 0 : Integer.parseInt(minute);
					s = (second == null || second.equals("")) ? 0 : Integer.parseInt(second);
					startSec = h*3600 + m*60 + s;
					while ((str = br.readLine()) != null) {
						count++;
						h = Integer.parseInt(str.substring(42, 44));
						m = Integer.parseInt(str.substring(44, 46));
						s = Integer.parseInt(str.substring(46, 48));
						thisSec = h*3600 + m*60 + s;
					
						if ((thisSec + Integer.parseInt(str.substring(68, 71))/1000) >= 3599*24) {
							continue;   //skip over times which are the previous day
							            //but are rounded to the next day
						}
					
						if(thisSec >= startSec){
							//record starting line
							if(startLine == -1){
								startLine = count;
							}
							%> 
								<tr>
									<td class="hex-data-address"><%= count %>: </td>
									<td class="hex-data-data"><%= str %></td>
								</tr>
							<%
							if ((count - startLine) >= 100) {
								break;
							}
						}
					}//while
				}//if (hour != null)
				else if (dataLine != null && !dataLine.equals("") && Integer.parseInt(dataLine) > 0) {
					int line = Integer.parseInt(dataLine);
					while ((str = br.readLine()) != null) {
						count++;
						int startShowing = line;
						//show 10 previous lines as well (if highlight=yes)
						if (highlight.equals("yes")) {
							startShowing = line - 10;
						}
						if (count >= startShowing) {
						    %>
						    	<tr>
						    		<td class="hex-data-address"><%= count %>: </td>
									<%
										if (count == line && highlight.equals("yes")) {
										    %>
										    	<td class="hex-data-data-highlight"><%= str %></td>
										    <%
										}
										else {
										    %>
										    	<td class="hex-data-data"><%= str %></td>
										    <%
										}
									%>
						    	</tr>
						    <%

							if ((count - line) >= 100) {
								break;
							}
						}
					}
				}
				else {
					//else simply display from the beginning of the file
					while ((str = br.readLine()) != null) {
						count++;
						
						%>
							<tr>
								<td class="hex-data-address"><%= count %>: </td>
								<td class="hex-data-data"><%= str %></td>
							</tr>
						<%
						if(count == 100){
							break;
						}
					}
				}

				//find out if there are more lines
				boolean moreLines = false;
				if ((str = br.readLine()) != null) {
					moreLines = true;
				}
				br.close();
			%> 
		</table>
		<%
			if(moreLines){
			    request.setAttribute("count", String.valueOf(count));
			    %>
			    	<a href="?filename=${param.filename}&highlight=${param.highlight}&line=${count}">Next 100 lines...</a>
			    <%
			}
		%>
	<%
%>
		</td>
	</tr>
</table>
			</div>
		</div>
	</body>
</html>