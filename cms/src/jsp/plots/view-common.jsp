<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%
	String filename = request.getParameter("filename");
	if(filename == null){
	    throw new ElabJspException("Please choose a file to view");
	}
	
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	if (entry == null) {
		throw new ElabJspException("No entry found in the data catalog for " + filename + ".");
	}
	
	ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));
	String url = plotUser.getDirURL("plots") + '/' + filename;
	
	String type = (String) entry.getTupleValue("type");  
	String name = (String) entry.getTupleValue("name"); 

	String params = "dataset=" + entry.getTupleValue("dataset") + "&runs=" + entry.getTupleValue("runs") + 
		"&plots=" + entry.getTupleValue("_plots") + "&analysis=" + entry.getTupleValue("analysis");
	
	boolean isRasterImage = false; 
	
	if (type.equals("uploadedimage") || StringUtils.endsWithIgnoreCase(filename, ".png") || 
			StringUtils.endsWithIgnoreCase(filename, ".jpg") || StringUtils.endsWithIgnoreCase(filename, ".gif")) {
		isRasterImage = true; 
	}
	
	request.setAttribute("params", params);
	request.setAttribute("name", name);
	request.setAttribute("url", url);
	request.setAttribute("rasterized", isRasterImage); 
%>

<h2>
	<c:choose>
		<c:when test="${name != null}">
			${name}
		</c:when>
		<c:otherwise>
			${param.filename}
		</c:otherwise>
	</c:choose>
</h2>

<br/>


<c:choose>
	<c:when test="${rasterized}">
		<img src="${url}"/>
		<br/>
		<a href="../data/view-metadata.jsp?filename=${param.filename}&menu=${param.menu}">Show details (metadata)</a>
	</c:when>
	<c:otherwise>		
		<a href="../data/view-metadata.jsp?filename=${param.filename}&menu=${param.menu}">Show details (metadata)</a>&nbsp;|&nbsp;
		<a href="../data/plot.jsp?${params}&combine=on">Edit this plot</a>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.min.js"></script>
		<script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script>
		<script language="javascript" type="text/javascript" src="../data/plot.js"></script>
		<script language="javascript" type="text/javascript" src="../include/jquery.flot.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script>
			initlog();
			log("start");	
		</script>
		
		<img class="flotifiable" src="../data/plot-image.jsp?${params}" />
		<div id="plot-template" style="display: none">
			<div class="frame" style="position: relative;">
				<div class="placeholder" style="width:768px;height:380px; margin-bottom: 16px; margin-left: 16px;"></div>
				<div class="xlabel" style="position: absolute; left: 400px; bottom: -24px;"></div>
				<div class="ylabel" style="position: absolute; left: -60px; top: 200px;writing-mode: tb-rl; filter: flipV flipH; -webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);"></div>
			</div>
		</div>
		<script>
			flotify();
		</script>
		<br />
	</c:otherwise>
</c:choose>