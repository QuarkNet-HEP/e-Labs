<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="o" uri="http://www.i2u2.org/jsp/ogretl" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="ogre-setup.jspf" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<e:analysis name="analysis" type="I2U2.CMS::OGRE" parameterTransformer="gov.fnal.elab.cms.OGREParameterTransformer">
	<%
		ElabAnalysis a = (ElabAnalysis) request.getAttribute("analysis");
		String type = (String) a.getParameter("type");
		if (type != null) {
			a.setParameterDefault("output", "output." + type);
			a.setParameterDefault("thumbnail", "output_thm." + type);
		}
	%>
	<e:trdefault name="xmlfile" value="${rxmlfile}"/>
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-ogre/output.jsp&onError=../analysis-ogre"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>
<html>
	<META HTTP-EQUIV="Pragma" content="no-cache">
	<head>
		<title>OGRE CMS HCAL TB04 Page</title>
		<script language="JavaScript" type="Text/JavaScript" src="../analysis-ogre/utilities.js"></script>
	</head>
	<body>
		<center>
			<img src="../analysis-ogre/ogre.png"></img>
			<font color="red"><h2>OGRE is an Online Graphical ROOT Environment</font></h2>
			Visit the <a href="http://root.cern.ch" target=_blank>Root</a> Homepage. (Creates a new window.)
		</center>
    	<hr />

		<center>
			<!-- CGI Program in default location ./WEB-INF/cgi/ -->
			<form method="GET" name="getData" action="../analysis-ogre/ogre.jsp">
			
			<!-- Store some basic bootstrap data for ogre.pl -->
			<c:set var="rxmlfile" value="xml/${elab.properties.xmlfile}" scope="session"/>
			<c:set var="xmlfile" value="${elab.realPaths[rxmlfile]}" scope="session"/>
			<e:trinput type="hidden" name="dataset" value="${elab.properties.dataset}"/>

			<h2>CMS HCal Testbeam '04 Data</h2>
			
			<table border="5" cellpadding="1">
				<!-- Put up the table header -->
				<tr align="center" valign="baseline">
					<th>Variable</th>
					<!-- <th>Selection</th> -->
					<th>Color</th>
				</tr>

<!------------------------------------------ Begin JSP Table Builder ----------------------------------->
				<o:build-plots-table/>
<!------------------------------------------- End JSP Table Builder ------------------------------------>

				<h2>Graphics Options</h2>
				<table border="5" cellpadding="5">
					<tr align="center" valign="baseline">
						<th>Graphics Size</th>
						<th>Output Graphics Type</th>
						<th>All Plots on One Histogram</th>
					</tr>
					<tr>
						<td>
							Width &nbsp;&nbsp;<e:trinput type="text" default="800" name="gWidth" size="4" onBlur="javascript:checkgSize(this);" />
							Height &nbsp;&nbsp;<e:trinput type="text" default="600" name="gHeight" size="4" onBlur="javascript:checkgSize(this);" />
						</td>
						<td>
							<e:trradio name="type" valueList="png, jpg, eps" labelList="PNG, JPG, EPS"/>
						</td>
						<td align="center"><e:trinput type="checkbox" name="allonone" value="1"/>&nbsp;Yes</td>
	    			</tr>
				</table>

<!------------------------------------------ Build Available Run List ---------------------------------->
				<div class="hidden_table" id="table1" style="display:none">
         			<table border="5" cellpadding="1">
	    				<tr>
	      					<td>
								<c:choose>
									<c:when test="${usedb}">
										<o:data-select.sql/>
									</c:when>
									<c:otherwise>
										<o:data-select.xml/>
									</c:otherwise>
								</c:choose>
							</td>
						</tr>
					</table>
				</div>

<!---------------------------------------- End Build Available Run List -------------------------------->


				<br />
				<input type="button" value="Data Selection" 
					onclick="javascript:dataPage=popWindow('../analysis-ogre/data-selection.jsp','dataPage', 650, 300);">

				<input type="submit" name="submit" value="Plot">&nbsp;&nbsp;

				<input type="button" value="Previous Results" 
					onclick="javascript:previousResults=popWindow('./results/','previousResults',500,600);">

				<input type="reset"  value="Reset Values">&nbsp;&nbsp;

				<input type="button" value="Close Popups" onclick="javascript:closePopUps();">
				
				<input type="hidden" name="provider" value="swift" />
				<input type="hidden" name="runMode" value="local" />

			</form>

		</center>

		<hr />

		<address><a href="mailto:karmgard.1@nd.edu">Bug the OGRE</a></address>
	</body>
</html>
	</e:ifAnalysisIsNotOk>
</e:analysis>