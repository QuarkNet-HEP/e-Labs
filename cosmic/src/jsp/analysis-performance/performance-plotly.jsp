<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>   
<%@ include file="../analysis/results.jsp" %>

<%
	TreeMap<String,String> uploadeddata = new TreeMap<String,String>();
	ResultSet rs = null;
	In and = new In();
	and.add(new Equals("project","cosmic"));
	and.add(new Equals("type", "uploadeddata"));
	and.add(new Equals("group", user.getGroup().getName()));
	rs = elab.getDataCatalogProvider().runQuery(and);
	if (rs != null) {
 		String[] filenames = rs.getLfnArray();
 		for (int i = 0; i < filenames.length; i++){
 			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
			if (e != null && !e.getTupleValue("name").equals("")) {
				uploadeddata.put(filenames[i], (String) e.getTupleValue("name"));
			}
		}//end for loop

	}

request.setAttribute("list",uploadeddata);
%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Performance Plot</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body class="performancePlot" style="text-align: center;">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<link rel="stylesheet" type="text/css" href="../include/plotly/dependencies/css/tipsy.css" />
				<link rel="stylesheet" type="text/css" href="../include/plotly/demo-dependencies/prettify.css" />
				<link rel="stylesheet" type="text/css" href="../include/plotly/demo-dependencies/font-awesome.css" />
				<link rel="stylesheet" type="text/css" href="../include/plotly/plotly.min.css" />
				<script type="text/javascript" src="../include/plotly/dependencies/jquery-latest.js"></script>
				<script type="text/javascript" src="../include/plotly/dependencies/jquery.tipsy.js"></script>
				<script type="text/javascript" src="../include/plotly/dependencies/png.js"></script>
				<script type="text/javascript" src="../include/plotly/dependencies/tinycolor.js"></script>
				<script type="text/javascript" src="../include/plotly/dependencies/typedarray.js"></script>
				<script type="text/javascript" src="../include/plotly/dependencies/d3.v3.min.js"></script>
				<script type="text/javascript" src="../include/plotly/demo_dependencies/prettify.min.js"></script>
				<script type="text/javascript" src="../include/plotly/demo_dependencies/underscore.js"></script>
				<script type="text/javascript" src="../include/plotly/plotly.min.js"></script>
				<script type="text/javascript" src="performance-plotly.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "performance-get-data-plotly.jsp?id=<%=id%>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoad
					});
				}); 	
				
				</script>
				<div class="graph-container-plotly">
					<div id="placeholder" class="graph-placeholder" style="float:left; width:600px; height:600px;"></div>
				</div>

		 	</div>
		</div>

<p>
	Analysis run time: ${results.formattedRunTime}; estimated: ${results.formattedEstimatedRunTime}
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>
<p>
	<e:rerun type="performance" id="${results.id}" label="Change"/> your parameters	
</p>
				
	<div id="footer"></div>		
	</body>
</html>