<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.io.IOException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>

<%
	//publish posters when submitting
	String reqType = request.getParameter("submitButton");
	DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);

	if ("Save Status".equals(reqType)) {
		String[] posterNames = request.getParameterValues("posterName");
		String[] statusPosters = request.getParameterValues("setStatus");
		if (posterNames != null) {
			for (int i = 0; i < posterNames.length; i++) {
		    	CatalogEntry ce = dcp.getEntry(posterNames[i]);
				if (ce != null) {
					String status = (String) ce.getTupleValue("status");
					if (status != null) {
				    	ce.setTupleValue("status", statusPosters[i]);
				    	dcp.insert(ce);
					} else {
				    	ArrayList meta = new ArrayList();
						meta.add("status string " + statusPosters[i]);				
						dcp.insert(DataTools.buildCatalogEntry(posterNames[i], meta));	
					}						
				}
			}
		}
	}
	TreeMap<String, CatalogEntry> posters = new TreeMap<String, CatalogEntry>();
	And q = new And();
	q.add(new Equals("type", "poster"));
	q.add(new Equals("project", elab.getName()));
	q.add(new Equals("group", user.getGroup().getName()));
	ResultSet rs = elab.getDataCatalogProvider().runQuery(q);
	String[] filenames = rs.getLfnArray();
	for (int i = 0; i < filenames.length; i++){
		CatalogEntry e = (CatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
		if (e != null) {
				posters.put(filenames[i], e);
		}
	}	

	request.setAttribute("posters", posters);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Publish Posters.</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>
		<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />
		<script type="text/javascript">
		$(document).ready(function() { 
			$.tablesorter.addParser({
				id: "MMMM dd yyyy", 
				is: function(s) { return false; },
				format: function(s) { return $.tablesorter.formatFloat(new Date(s + " 00:00").getTime()); },
				type: "numeric"
			});
			$("#status-results").tablesorter({ sortList: [[0,0]] },{ headers: {2:{sorter:'MMMM dd yyyy'}, 4:{sorter:false}} } );
		}); 
		</script>		
	</head>
	
	<body id="publish-posters" >
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			<div id="content">
				
			<h1>Publish Posters</h1>
			<c:choose>
					<c:when test="${empty posters}">
						<h2>No posters found</h2>
					</c:when>
					<c:otherwise>
					  	<form id="publish-poster-form">
							<table style="text-align: center; width: 100%;" id="status-results" class="tablesorter">
							<thead>
								<tr>
									<th>Status</th>
									<th>Title</th>
									<th>Date</th>
									<th>Group</th>
									<th> </th>
								</tr>
							</thead>
							<tbody>
								</tr>
								<c:forEach items="${posters}" var="posters">
									<tr>
										<td>
											<input type="hidden" value="${posters.value.tupleMap.status }"></input>
							    			<select id="select_${posters.key}" name="setStatus" >
							    				<option value="none"></option>
							    				<c:choose>
								    				<c:when test='${posters.value.tupleMap.status == "reviewed" }'>
									    				<option value="reviewed" selected="true">Reviewed</option>
								    				</c:when>
								    				<c:otherwise>
									    				<option value="reviewed">Reviewed</option>
								    				</c:otherwise>
												</c:choose>
												<c:choose>
								    				<c:when test='${posters.value.tupleMap.status == "published" }'>
									    				<option value="published" selected="true">Published</option>
								    				</c:when>
								    				<c:otherwise>
									    				<option value="published">Published</option>
								    				</c:otherwise>
								    			</c:choose>
							    			</select>								
										</td>
										<td style="text-align: left;">
											<e:popup href="../posters/display.jsp?name=${posters.key}" target="poster" width="700" height="900">${posters.value.tupleMap.title }</e:popup>
											(<a href="../posters/display.jsp?type=paper&name=${posters.key}">View as Paper</a>)
										</td>
										<td><e:format type="date" format="MMMM d, yyyy" value="${posters.value.tupleMap.date}"/></td>
										<td>${posters.value.tupleMap.group}</td>
										<td><a href="../data/view-metadata.jsp?filename=${posters.key}">View Metadata</a>
										<input type="hidden" name="posterName" id="hidden_${posters.key}" value="${posters.key}"></input></td>
									</tr>
								</c:forEach>
								<tr>
									<td colspan="6"><input type="submit" name="submitButton" id="submitButton" value="Save Status" /></td>
								</tr>
								</tbody>
							</table>	

						</form>
					</c:otherwise>
				</c:choose>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
