<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
	String tt = (String) user.getGroup().getTeacher();
	if (tt != null) {
		q.add(new Equals("teacher", tt));
	}
	request.setAttribute("tt", tt);
	//q.add(new Equals("group", user.getGroup().getName()));
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
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>
		<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />
		<script type="text/javascript">
		$(document).ready(function() { 
			if ($("#status-results").find("tbody").find("tr").size() > 0) {
				$.tablesorter.addParser({
					id: "posterDate", 
					is: function(s) { return false; },
					format: function(s) { 
						return $.tablesorter.formatFloat(new Date(s + " 00:00").getTime()); 
					    },
					type: "numeric"
				});
				$("#status-results").tablesorter({ sortList: [[0,0]] },{ headers: {2:{sorter:'posterDate'}, 4:{sorter:false} }} );
			}
		}); 
		</script>				
			<h1>Publish Posters</h1>
			<li><ul><a href="../assessment/rubric-p.html">Poster</a> Rubrics.</ul></li>
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
									<th></th>
								</tr>
							</thead>
							<tbody>
								<c:forEach items="${posters}" var="posters">
									<tr>
										<td>
											<input type="hidden" value="${posters.value.tupleMap.status }"></input>
							    			<select id="select_${posters.key}" name="setStatus" >
							    				<option value="none"></option>
							    				<c:choose>
								    				<c:when test='${posters.value.tupleMap.status == "unpublished" }'>
									    				<option value="unpublished" selected="true">Unpublished</option>
								    				</c:when>
								    				<c:otherwise>
									    				<option value="unpublished">Unpublished</option>
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
											<br /><e:format type="date" format="MMMM d, yyyy" value="${posters.value.tupleMap.date}"/>
										</td>
										<td><fmt:formatDate pattern="yyyy-MM-dd" value="${posters.value.tupleMap.date}" /></td>
										<td>${posters.value.tupleMap.group}</td>
										<td><a href="../data/view-metadata.jsp?filename=${posters.key}">View Metadata</a>
										<input type="hidden" name="posterName" id="hidden_${posters.key}" value="${posters.key}"></input></td>
									</tr>
								</c:forEach>
								</tbody>
							</table>	
							<input type="submit" name="submitButton" id="submitButton" value="Save Status" />
						</form>
					</c:otherwise>
				</c:choose>
