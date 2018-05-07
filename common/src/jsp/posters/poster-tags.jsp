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
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
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
		
		function validateTagName(objectId) {
			var tagName = document.getElementById(objectId);
			var divMsg = document.getElementById("errorMsg");
			var message = "";
			if (! /^[a-zA-Z0-9_-]+$/.test(tagName.value)) {
				var message = "Tag Name contains invalid characters. Use any alphanumeric combination, dashes or underscores.";
				divMsg.innerHTML = "<i>* "+message+"</i>";
			    return false;
			}
			divMsg.innerHTML = "";
			return true;
		}
		function validateAllTags() {
			var allTags = document.getElementsByName("newTag");
			if (allTags != null) {
				for (var i = 0; i < allTags.length; i++) {
					if (!validateTagName(allTags[i].id)) {
						return false;
					}
				}
			}
			return true;
		}
		function saveAndAdd() {
			var checked = true;
			checked = validateAllTags();
			if (checked) {
				document.getElementById('submitButton').click();
			}
			return checked;
		}
	</script>
	<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>		
	<script>
		$(document).ready(function() {
			addTag("newTags", "text", "", "", "div");
		});	
	</script>
    <body>	
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
				<h1>Poster Tags: Maintenance</h1>
				<ul>
					<li>Poster tags could be any alphanumeric combination, dashes and/or underscores. No spaces or special characters.</li>
				</ul>
		    	<form name="poster-tags" id="poster-tags" method="post">
		    	   <table>
		    	   		<tr>
		    	   			<td style="text-align:center;"><strong> Delete? </strong></td>
		    	   			<td><strong>Tag Name</strong></td>
		    	   			<td><input type="button" name="add" id="add" value="+" onclick='saveAndAdd();'></input>
		    	   			</td>
		    	   		</tr>
						<c:forEach items="${posterTags}" var="posterTags">
							<tr>
								<td style="text-align:center;"><input type="checkbox" name="removeTag" id="${posterTags}" value="${posterTags }"></input></td>
								<td><input type="text" name="existingTag" id="${posterTags}" value="${posterTags}" onChange='return validateTagName("${posterTags}");'></input></td>
								<td></td>
							</tr>
						</c:forEach>
		    	   		<tr>
							<td></td>
		    	   			<td colspan="2"><div id="newTags">
								</div></td>
		    	   		</tr>
		    	   		<tr>
		    	   			<td colspan="3" style="text-align: center;"><input type="submit" name="submitButton" id="submitButton" value="Save Changes" onclick='return validateAllTags();'></input>
		    	   					    	   							<input type="submit" name="remove" id="remove" value="Cancel"></input>
		    	   			</td>
		    	   		</tr>
		    	   </table>
		    	   <div id="errorMsg"></div>
				</form>
			</div>
		</div>
	</body>
</html>
