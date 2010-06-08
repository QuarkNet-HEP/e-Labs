<%
	String filename = request.getParameter("filename");
	if(filename == null){
	    throw new ElabJspException("Please choose a file to view");
	}
	
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	if (entry == null) {
		throw new ElabJspException("No entry found in the data catalog for " + filename + ".");
	}

	String params = "dataset=" + entry.getTupleValue("dataset") + "&runs=" + entry.getTupleValue("runs") + 
		"&plots=" + entry.getTupleValue("_plots") + "&analysis=" + entry.getTupleValue("analysis");
	request.setAttribute("params", params);
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
</h2><br/>

<a href="../data/view-metadata.jsp?filename=${param.filename}&menu=${param.menu}">Show details (metadata)</a>&nbsp;|&nbsp;
<a href="../data/plot.jsp?${params}">Edit this plot</a>
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