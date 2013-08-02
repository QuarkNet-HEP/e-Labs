<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%
	String[] newTags = request.getParameterValues("newTag");
	String[] existingTags = request.getParameterValues("existingTag");
	String[] removeTags = request.getParameterValues("removeTag");
	
	String reqType = request.getParameter("submitButton");
	if ("Save Changes".equals(reqType)){
		DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
		if (newTags != null) {
			if (newTags.length > 0) {
				DataTools.insertTags(elab, newTags);
			}
		}
		if (removeTags != null) {
			if (removeTags.length > 0) {
				DataTools.removePosterTags(elab, removeTags);
			}
		}
	}
	
	ResultSet searchResults = DataTools.retrieveTags(elab);

	//if there are already tags in the db
	if (searchResults != null) {
  		String[] posterTags = searchResults.getLfnArray();
  		request.setAttribute("posterTags", posterTags);
	}
%>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} Poster Tags</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<script type="text/javascript">
		var DefaultName = "newTag";
		var DefaultNameIncrementNumber = 0;
		function addTag(id, type, name, value, tag) {
			if(!document.getElementById && document.createElement) { return; }
			var inhere = document.getElementById(id);
			var formfield = document.createElement("input");
			if(name.length < 1) {
			   DefaultNameIncrementNumber++;
			   name = String(DefaultName + DefaultNameIncrementNumber);
			   }
			formfield.name = DefaultName;
			formfield.id = name;
			formfield.type = type;
			formfield.value = value;
		
			if(tag.length > 0) {
			   var thetag = document.createElement(tag);
			   thetag.appendChild(formfield);
			   inhere.appendChild(thetag);
			   }
			else { inhere.appendChild(formfield); }
		}
	</script>
    <body>	
    		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<h1>Poster Tags: Maintenance</h1>
		    	<form name="poster-tags" id="poster-tags" method="post">
		    	   <table>
		    	   		<tr>
		    	   			<td style="text-align:center;"><strong> Delete? </strong></td>
		    	   			<td><strong>Tag Name</strong></td>
		    	   			<td><input type="button" name="add" id="add" value="+" onclick='javascript:addTag("newTags", "text", "", "", "div");'></input></td>
		    	   		</tr>
						<c:forEach items="${posterTags}" var="posterTags">
							<tr>
								<td style="text-align:center;"><input type="checkbox" name="removeTag" id="${posterTags}" value="${posterTags }"></input></td>
								<td><input type="text" name="existingTag" id="${posterTags}" value="${posterTags}"></input></td>
								<td></td>
							</tr>
						</c:forEach>
		    	   		<tr>
							<td></td>
		    	   			<td colspan="2"><div id="newTags">
								</div></td>
		    	   		</tr>
		    	   		<tr>
		    	   			<td colspan="3" style="text-align: center;"><input type="submit" name="submitButton" id="submitButton" value="Save Changes"></input></td>
		    	   		</tr>
		    	   </table>
				</form>
			</div>
		</div>
	</body>
</html>
