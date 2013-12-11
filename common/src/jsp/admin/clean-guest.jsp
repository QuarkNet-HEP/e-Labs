<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%
	String submit = request.getParameter("submit");
	String messages = "";
	In and = new In();
	int totalFileCount = 0;
	
	and.add(new Equals("type", "split"));
	and.add(new Equals("group", "guest"));
	ResultSet rsSplits = elab.getDataCatalogProvider().runQuery(and);
	if (rsSplits != null) {
		totalFileCount += rsSplits.size();
	}
	request.setAttribute("splits", rsSplits.size());

	and = null;
	and = new In();
	and.add(new Equals("type", "plot"));
	and.add(new Equals("group", "guest"));
	ResultSet rsPlots = elab.getDataCatalogProvider().runQuery(and);
	if (rsPlots != null) {
		totalFileCount += rsPlots.size();
	}
	request.setAttribute("plots", rsPlots.size());

	and = null;
	and = new In();
	and.add(new Equals("type", "poster"));
	and.add(new Equals("group", "guest"));
	ResultSet rsPosters = elab.getDataCatalogProvider().runQuery(and);
	if (rsPosters != null) {
		totalFileCount += rsPosters.size();
	}
	request.setAttribute("posters", rsPosters.size());

	and = null;
	and = new In();
	and.add(new Equals("type", "uploadedimage"));
	and.add(new Equals("group", "guest"));
	ResultSet rsUploadedImages = elab.getDataCatalogProvider().runQuery(and);
	if (rsUploadedImages != null) {
		totalFileCount += rsUploadedImages.size();
	}
	request.setAttribute("uploadedimages", rsUploadedImages.size());	
	
	if (totalFileCount == 0 ) {
		messages = "There are no files to be deleted at this time.<br />";
	}
	if ("Remove All".equals(submit)) {
		//delete posters
		String[] posterLFNs = rsPosters.getLfnArray();
		for (int i = 0; i < posterLFNs.length; i++) {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(posterLFNs[i]);
			try {
				elab.getDataCatalogProvider().delete(entry);
				ElabUtil.deletePhysicalFiles(elab, entry.getLFN(), entry, user);	
			}
			catch (Exception e) {
				messages += "Could not delete " + entry.getLFN() + ": " + e.getMessage() + "<br />";
			}
		}
		//delete plots
		String[] plotLFNs = rsPlots.getLfnArray();
		for (int i = 0; i < plotLFNs.length; i++) {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(plotLFNs[i]);
			try {
				elab.getDataCatalogProvider().delete(entry);
				ElabUtil.deletePhysicalFiles(elab, entry.getLFN(), entry, user);	
			}
			catch (Exception e) {
				messages += "Could not delete " + entry.getLFN() + ": " + e.getMessage() + "<br />";
			}
		}
		//delete uploadedimages
		String[] uploadedimageLFNs = rsUploadedImages.getLfnArray();
		for (int i = 0; i < uploadedimageLFNs.length; i++) {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(uploadedimageLFNs[i]);
			try {
				elab.getDataCatalogProvider().delete(entry);
				ElabUtil.deletePhysicalFiles(elab, entry.getLFN(), entry, user);	
			}
			catch (Exception e) {
				messages += "Could not delete " + entry.getLFN() + ": " + e.getMessage() + "<br />";
			}
		}
		//delete all cosmic data files
		String[] splitLFNs = rsSplits.getLfnArray();
		for (int i = 0; i < splitLFNs.length; i++) {
			int count = DataTools.checkFileDependency(elab, splitLFNs[i]);
			if (count > 0) {
				String[] plots = DataTools.getFileDependency(elab, splitLFNs[i]);
				StringBuilder sb = new StringBuilder();
					if (plots != null) {
						sb.append("Files:");
						for(int y = 0; y < plots.length; y++) {
							sb.append("-"+plots[y]);
						}
					}
				messages += splitLFNs[i] + " is being used in a plot/analysis. Cannot be deleted " + sb.toString() + "<br />";
				continue;							
			}
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splitLFNs[i]);
			try {
				elab.getDataCatalogProvider().delete(entry);
				ElabUtil.deletePhysicalFiles(elab, entry.getLFN(), entry, user);	
			}
			catch (Exception e) {
				messages += "Could not delete " + entry.getLFN() + ": " + e.getMessage() + "<br />";
			}
		}
	}//end of submit

	if (totalFileCount == 0) {
		messages = "All files for the guest user have been removed<br />";
	}
	request.setAttribute("messages", messages);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Remove guest data, plots and posters</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="cleanGuest" class="teacher">
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
			<c:choose>
				<c:when test="${not empty messages}">
					<div style="width: 100%; text-align:center;">${messages}</div>
				</c:when>
				<c:otherwise>
					<form id="cleanGuestUser" method="post">
						<table cellpadding="10" cellspacing="10" border="1" align="center">
							<tr><th>Total number of files created/uploaded by guest</th></tr>
							<tr><td style="text-align: center;">${splits} split files</td></tr>
							<tr><td style="text-align: center;">${plots} plots</td></tr>
							<tr><td style="text-align: center;">${uploadedimages} images</td></tr>
							<tr><td style="text-align: center;">${posters} posters</td></tr>
						</table>
						<div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Remove All"/></div>
						<div style="width: 100%; text-align:center;"><i>* This may take a while depending on the number of files to delete.</i></div>
					</form>
				</c:otherwise>
			</c:choose>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>