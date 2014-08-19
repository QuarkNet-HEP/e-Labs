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
<%@ page import="gov.fnal.elab.util.*" %>

<%
	String submit = request.getParameter("submit");
	List ok = new ArrayList();
	request.setAttribute("ok", ok);
	List notOk = new ArrayList();
	request.setAttribute("notOk", notOk);

	if (submit != null && submit.equals("Delete")) {
		String[] files = request.getParameterValues("checkboxes");
		if (files != null) {
			for (int i = 0; i < files.length; i++) {
				String name = files[i];
				String fileName = name;
				try {
					VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(fileName);
					name = (String) entry.getTupleValue("name");
					if (entry != null) {
						//check the type
						if (entry.getTupleValue("type").equals("uploadeddata")) {
							int count = 0;//DataTools.checkPlotDependency(elab, name, figNo);
							if (count > 0) {
								throw new ElabJspException(" is being used either in a poster or logbook. Cannot be deleted.");								
							}
						}
						if (entry == null) {
						    throw new ElabJspException("not found in the catalog");
						}
					}
					ok.add(entry);
				 } catch (Exception e) {
					if (fileName != null) {
						notOk.add(fileName +"("+name+")"+ " error: " + e.getMessage());
					} else {
						notOk.add(name+ " error: " + e.getMessage());						
					}
				}
			}
		}
		Iterator i = ok.iterator();
		while (i.hasNext()) {
			VDSCatalogEntry entry = (VDSCatalogEntry) i.next();
			try {
				elab.getDataCatalogProvider().delete(entry);
				//EPeronja-07/23/2013 483: delete the physical files
				ElabUtil.deletePhysicalFiles(elab, entry.getLFN(), entry, user);
			}
			catch (Exception e) {
				notOk.add("Could not delete " + entry.getLFN() + ": " + e.getMessage());
			}
		}		
	}//end of submit
	
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
		<title>Delete External Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>
		<script>
		function checkSelection() {
			var checkedAtLeastOne = false;
			var checkboxs=document.getElementsByName("checkboxes");
		    for(var i=0,l=checkboxs.length;i<l;i++) {
		        if(checkboxs[i].checked) {
		        	checkedAtLeastOne=true;
		        }
		    }
		    if (!checkedAtLeastOne) {
		    	var msgDiv = document.getElementById("msg");
		    	msgDiv.innerHTML = "<i>* Please select something to delete.</i>"
		    }
			return checkedAtLeastOne;
		}
		</script>
	</head>
	<body class="deleteExternalData" style="text-align: center;">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<form name="deleteExternal" method="post">	
					<h1>Delete External Data</h1>		
		 			<c:choose>
			  			<c:when test="${not empty list }">
			 				<c:forEach items="${list}" var="filename">
				 				<input type="checkbox" name="checkboxes" id="${filename.key }" value="${filename.key }">${filename.value }</input><br />
					        </c:forEach>
					     </c:when>			
		 			</c:choose>

					<input type="submit" name="submit" value="Delete" onclick="return checkSelection();"/>
					<div id="msg"></div>
				</form>
				<c:choose>
					<c:when test="${not empty notOk }">
						<c:forEach items="${notOk }" var="notOk">
							<p>${notOk }</p>
						</c:forEach>
					</c:when>
				</c:choose>
		 	</div>
		</div>
				
	<div id="footer"></div>		
	</body>
</html>