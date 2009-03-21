<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<%@ page import="java.io.*, java.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.apache.regexp.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Add Reference</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="add-reference" class="library">
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
<%
 
	String projectMeta = "";   // projectMeta holds the value of the project metadata for the reference
	String projectSelected = "";
	String referenceType = request.getParameter("t");
	if (referenceType == null) {
		referenceType = "reference";
	}
	String referencePrefix = "Reference_";
	String referenceText = "Reference";
	if (referenceType.equals("glossary")) {
		referencePrefix = "Glossary_"; 
		referenceText = "Glossary Item";
	}
	if (referenceType.equals("FAQ")) { 
		referencePrefix = "FAQ_"; 
		referenceText = "FAQ Item";
	}
	if (referenceType.equals("news")) {
		referenceText = "News Item";
		referencePrefix = "News_"; 
	}

	String referenceName = request.getParameter("referenceName");
	if (referenceName == null) {
		referenceName = "";
	}
	
	String html = "";
	String errorMessage = "";
	if (referenceName.length() > 1) {
		if ((referenceName.startsWith(" "))) {
			referenceName = referenceName.substring(1, referenceName.length());
		}
		if (!(referenceName.startsWith(referencePrefix))) {
			referenceName = referencePrefix + referenceName;
		}
	}
	String lfn = referenceName.replaceAll(" ", "_");
          
	String time = request.getParameter("referenceTime");
	if (time == null || time.equals("")) {
		SimpleDateFormat bartDateFormat =
			new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
		time = bartDateFormat.format(new Date());
	}
	String expire_time = request.getParameter("expireTime");
	if (expire_time == null || expire_time.equals("")) {
		SimpleDateFormat bartDateFormat =
			new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
		Date oneWeek = new Date();
		oneWeek.setDate(oneWeek.getDate() + 7);
		expire_time = bartDateFormat.format(oneWeek);
	}
          
	List meta = null;
	boolean metaSuccess = false;

		%>
			<form action="../jsp/searchReference.jsp" name="action_form" method="get">
				<e:trselect name="f" 
					valueList="view, delete, upload, download, add" 
					labelList="View, Delete, Upload, Download, Add"/>
				<e:trselect name="t"
					valueList="reference, glossary, FAQ, news"
					labelList="Reference, Glossary, FAQ, News"/>
				Item(s).<br />
				<input type="submit" name="submit" value="Go!" />
			</form>
			<table width="723" cellpadding="4">
				<tr>
					<td class="library_header">Add <%=referenceText%>s</td>
				</tr>
				<tr>
					<td>
						<font face="arial" size="-1">
		  					<ul>
		   						<li>Enter the <%=referenceType%> name; start it with <b><%=referencePrefix%></b>.</li>
								<li> Click <b>Get html for <%=referenceText%></b> to get current html in database</li>
								<li> Add or Edit your html in the html field.</li>
								<li> Click <b>Add html</b> to add or edit html</li>
		  						<li> Remember to use javascript:showRefLink('your_url') for your links</li>
		  						<li> You can use javascript:showRefLink('your_url', width, height) if you want to change the default width and height</li>
		  						<li> If you can't see the whole reference, change the height of the reference. Click <b>Add html</b> for it to work.</li>
		  					</ul>
		  				</font> 
		  			</td>
		  		</tr>
		  	</table>
			<%
				String reqType = request.getParameter("button");
				// If "Add html" request, copy data from form fields to referenceName.html file

				if (reqType != null && reqType.equals("Add html")) {
					html = request.getParameter("html");
		            if (html == null) {
		            	html = " ";
		            }
					projectSelected = request.getParameter("project");
					if (projectSelected == null) {
						projectSelected = elab.getName();
					}
					String condensedHtml = html.replaceAll("\r\n*", " ");
					//set metadata with new html
					List metaAdd = new ArrayList();
					metaAdd.add("name string " + lfn);
					metaAdd.add("type string " + referenceType);
					metaAdd.add("project string " + projectSelected);
					metaAdd.add("description string " + condensedHtml); 
					if (referenceType.equals("news")) {
						metaAdd.add("expire string " + expire_time);
						metaAdd.add("time string " + time);
					}
					CatalogEntry e = DataTools.buildCatalogEntry(lfn, metaAdd);
					elab.getDataCatalogProvider().insert(e);
				}
				else {// not an add so we have to read information from html file or else start with empty fields.
					// Look for html metadata for referenceName
					// get metadata
					html = "";
					if (referenceName.length() > 1) {
						CatalogEntry e = elab.getDataCatalogProvider().getEntry(lfn);
						if (e != null) {
	                    	html = (String) e.getTupleValue("description");
	                    	projectMeta = (String) e.getTupleValue("project");
	                    	if (referenceType.equals("news")) {
	                    		time = (String) e.getTupleValue("time");
	                    		expire_time = (String) e.getTupleValue("expire");
	                    	}
						} //meta test
	                    else {
							errorMessage="No meta entered for this reference";
	                    }
					} //referenceName
				}// check for Add button
                if (!errorMessage.equals("")) {
                	out.write(errorMessage);
				}
				request.setAttribute("referenceType", referenceType);
				request.setAttribute("referenceName", referenceName);
				request.setAttribute("referenceText", referenceText);
			%>
            
			<form method="get" name="reference">
				<table cellspacing="2" cellpadding="2" border="1">
					<c:choose>
						<c:when test="${referenceName == ''}">
            				<tr>
            					<td align="right">${referenceText} name:</td>
            					<td>
            						<input type="text" name="referenceName" value="" size="40" />(e.g. <%=referencePrefix%>proposed_research)
            					</td>
            				</tr>
            				<c:if test="${referenceType == 'news'}">
            					<tr>
            						<td align="right">Time (do not change unless necessary):</td>
            						<td><input type="text" name="referenceTime" value="<%=time%>" size="40" /></td>
            					</tr>
            					<tr>
            						<td align="right">Expiration Date:</td>
            						<td><input type="text" name="expireTime" value="<%=expire_time%>" size="40" /></td>
            					</tr>
            				</c:if>
            				<tr>
            					<td valign="top" align="right">Edit your html:</td>
            					<td><textarea name="html" cols="80" rows="10"> </textarea></td>
            				</tr>
						</c:when>
						<c:otherwise>
							<tr>
								<td align="right">${referenceText} name:</td>
								<td><input type="text" name="referenceName" value="<%=lfn%>" size="40" />(e.g. <%=referencePrefix%>proposed_research)</td>
							</tr>
							<c:if test="${referenceType == 'news'}">
            					<tr>
            						<td align="right">Time (do not change unless necessary):</td>
            						<td><input type="text" name="referenceTime" value="<%=time%>" size="40" /></td>
            					</tr>
            					<tr>
            						<td align="right">Expiration Date:</td>
            						<td><input type="text" name="expireTime" value="<%=expire_time%>" size="40" /></td>
            					</tr>
            				</c:if>
            				<tr>
            					<td valign="top" align="right">Add or Edit your html:</td>
            					<td><textarea name="html" cols="80" rows="10"><%=html%></textarea></td>
            				</tr>
            			</c:otherwise>
            		</c:choose>
            		<%
            			if (projectMeta.equals("")) {
            				projectMeta = projectSelected;
            			}
					%>
            
					<tr>
						<td align="right">Project</td>
						<td align="left">
							<e:trselect name="project" 
								valueList="${elab.name}, all"
								labelList="${elab.name}, all (reference used by all projects)"/>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="center">
							<input type="submit" name="button" value="Get html for ${referenceText}" /> 
							<input type="submit" name="button" value="Add html" />
							<input type="hidden" name="t" value="${referenceType}">
						</td>
					</tr>
            	</table>
			</form>
			<%
            	if (referenceName.length() > 0) {
            		String simpleName = lfn.substring(referencePrefix.length());
            		if (referenceType.equals("reference") || referenceType.equals("glossary")) {
					%>
						<a href="javascript:${referenceType}('<%=simpleName%>')">Preview ${referenceText}</a>
            		<%
            		}
            		else {
            		%>
                		<a href="${referenceType}.jsp">Preview ${referenceType} page</a>
            		<%
            		}
            		%> 
            		<br />
            		<br />
					<table border="1" cellpadding="5" width="400">
						<tr>
							<th>Rendered as html</th>
						</tr>
						<tr>
							<td><%=html%></td>
						</tr>
					</table>
            	<%
            	}
            	%>
			</div>
		</div>
	</body>
</html>