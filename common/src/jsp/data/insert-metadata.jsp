<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Insert Metadata</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
<%
	String filename = request.getParameter("filename");
	String message = "";
	String submitButton = request.getParameter("submitMetadata");
	String project = elab.getName();
	
	//then look for the filename handle to insert metadata
	if (filename != null && submitButton.equals("Search")) {
		VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
		if (entry == null) {
		    message = "No metadata about " + filename + " found.";
		}
		if (!entry.getTupleValue("project").toString().equals(project)) {
			message = "This entry does not belong to this project.";
		}
		request.setAttribute("entry", entry);
	} 
	if (filename != null && submitButton.equals("Insert")) {
		String metadatalabel = request.getParameter("metadatalabel");
		String metadatavalue = request.getParameter("metadatavalue");
		String metadatatype = request.getParameter("metadatatype");
		if (metadatalabel != null && metadatavalue != null && !metadatalabel.equals("") && !metadatavalue.equals("")) {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			//need to check if label exists so we update
			if (entry.getTupleValue(metadatalabel) != null) {
				try {
					entry.setTupleValue(metadatalabel, metadatalabel);
			    	dcp.insert(entry);
					message = "Metadata updated successfully.";
					VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
					request.setAttribute("entry", e);			    	
				} catch (Exception e) {
					message = e.toString();
				}
			} else {
				//or we insert a brand new one
				ArrayList meta = new ArrayList();
				meta.add(metadatalabel +" "+ metadatatype +" "+ metadatavalue);
				try {
					dcp.insert(DataTools.buildCatalogEntry(filename, meta));			
					message = "Metadata updated.";
					VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
					request.setAttribute("entry", e);			    	
				} catch (Exception e) {
					message = e.toString();
				}
			}

		} else {
			message = "The label and/or the value are not correct. Cannot insert them.";
		}
	}
	request.setAttribute("filename", filename);
	request.setAttribute("message", message);
	
		%>
	<body id="insert-metadata" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			<form name="insertmetadata">
				<c:choose>
					<c:when test="${empty filename}">
						<table>
							<tr>
								<td>Metadata File Name Handle<input type="text" name="filename" id="filename"></input></td>
							</tr>
							<tr>
								<td style="text-align: center;"><input type="submit" name="submitMetadata" value="Search"></input></td>
							</tr>
							<tr>
								<td>${message}</td>
							</tr>
						</table>
					</c:when>
					<c:otherwise>
						<input type="hidden" name="filename" value="${filename}"></input>
						<table>
							<c:forEach items="${entry.tupleIterator}" var="entry">
								<tr>
									<td style="text-align: right;"><strong>${entry.key }:</strong></td>
									<td style="text-align: left;" colspan="2">${entry.value }</td>
								</tr>											
							</c:forEach>
							<tr>
								<td style="text-align: right;"><strong>New Label</strong></td>
								<td style="text-align: left;" colspan="2"><strong>New Value</strong></td>
							</tr>
							<tr>
								<td><input type="text" name="metadatalabel"></input></td>
								<td><input type="text" name="metadatavalue"></input></td>
								<td><select name="metadatatype">
									<option value="boolean">true or false</option>
									<option value="date">date (2013-01-25 10:10:10.0)</option>
									<option value="float">number with decimals (3.500)</option>
									<option value="int">integer (2)</option>
									<option value="string">text (this is a comment)</option>
								</select></td>
							</tr>
							<tr>
								<td colspan="3" style="text-align: center;"><input type="submit" name="submitMetadata" value="Insert"></input></td>
							</tr>
							<tr>
								<td colspan="3">${message}</td>
							</tr>
							<tr>
								<td colspan="3"><a href="insert-metadata.jsp?filename=&submitMetadata=">Search for another file.</a></td>
							</tr>
						</table>
					</c:otherwise>
				</c:choose>
			</form>			
			</div>	
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>