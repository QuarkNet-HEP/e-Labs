<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>  
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.io.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%
	
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	
	String detector = request.getParameter("detector");
	String sinceDate = request.getParameter("sinceDate");
	request.setAttribute("sinceDate", sinceDate);
	
	boolean success = false;
	Date startDate = null; 
	
	if (StringUtils.isNotBlank(sinceDate)) {
		if (StringUtils.isNotBlank(sinceDate)) {
			startDate = DATEFORMAT.parse(sinceDate); 
		}
	}
	
	ResultSet rs = Benchmark.getBenchmarkCandidates(elab, Integer.parseInt(detector), startDate);

	if (rs != null) {
		String[] filenames = rs.getLfnArray();
		request.setAttribute("filenames", filenames);
		
		String reqType = request.getParameter("submitGolden");
		if ("Add Golden File".equals(reqType)){
			String golden = request.getParameter("golden");
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			if (!golden.equals("")) {
				//first make all prior golden files not default
				ResultSet rsDefault = Benchmark.getBenchmarkFileName(elab, Integer.parseInt(detector));
	            String[] defaultGolden = rsDefault.getLfnArray();
			    for (int i = 0; i < defaultGolden.length; i++) {
			    	CatalogEntry ce = dcp.getEntry(defaultGolden[i]);
			    	ce.setTupleValue("goldendefault", false);
			    	dcp.insert(ce);
			    }
			    //set new golden and make it default
				CatalogEntry entry = dcp.getEntry(golden);
				ArrayList meta = new ArrayList();
				meta.add("goldenfile boolean true");
				meta.add("goldendefault boolean true");
				dcp.insert(DataTools.buildCatalogEntry(golden, meta));	
				success = true;
			}//end of setting/removing default golden file
		}
	} 
	request.setAttribute("success", success);
	request.setAttribute("detector", detector);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Golden File</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>		
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
		<script type="text/javascript" src="../include/excanvas.min.js"></script>
		<script type="text/javascript" src="../analysis-blessing/blessing.js"></script>				
		<script>
		    console.log("it tries to load");
			window.onunload = function() {
			    if (window.opener && !window.opener.closed) {
			        window.opener.popUpClosed();
			    }
			};		
			function showCharts(filename){
				var chartDiv = document.getElementById("chartsDiv");
				chartDiv.style.visibility = 'visible';
				var datafile = document.getElementById("datafile");
				datafile.innerHTML = "<strong>Bless Charts for "+filename+"</strong>";
				$.ajax({
					url: "../analysis-blessing/get-data.jsp?file="+filename,
					processData: false,
					dataType: "json",
					type: "GET",
					success: onDataLoad1
				});				
			}
		</script>
	</head>
	<body>
		<div id="container">
			<div id="content">
			  <form name="addGoldenFileForm" method="post">
				<h1>Select golden files for detector: <%=detector%></h1>
				<input type="hidden" name="detector" value="<%=detector%>" ></input>
				<table>
				  <tr style="cellpadding: 4px;">
				    <td style="vertical-align: top;">
        				<c:choose>
        				  <c:when test="${not empty filenames}">
							<table>
								<c:forEach items="${filenames}" var="filename" begin="0" end="9">
									<tr>
										<td><input type="radio" name="golden" id="golden" value="${filename}"></input></td>
										<td><a href="#charts" onclick='javascript:showCharts("${filename}");'>${filename}</a></td>
									</tr>
								</c:forEach>
							</table>
						  </c:when>
						  <c:otherwise>
						     <strong>There are no .bless files for this detector since ${sinceDate}.</strong> 
						  </c:otherwise>
						</c:choose>
					</td>
					<td>
						<div id="chartsDiv" style="visibility: hidden; text-align: center;">
							<h2 id="datafile"></h2>
							<h2>Rates</h2>
							<div id="channels" style="background-color:#FFFFFF;">
								<div id="channelChart" style="width:550px; height:200px; text-align: left;"></div>
								<div id="channelChartLegend" style="width: 550px;"></div>        
							</div>
						
							<h2>Trigger Rate</h2>
							<div id ="triggerChart" style="width:550px; height:200px; text-align: left;"></div>
						
						</div>
					</td>
				  </tr>
				</table>
				<input type="submit" name="submitGolden" id="submitGolden" value="Add Golden File"></input>
			  </form>
			  <% if (success) { %>
			  	<a href=# onclick="window.close();">Close</a>
			  <% } %>
			</div>
		</div>
	</body>
</html>