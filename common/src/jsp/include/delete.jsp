<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*" %>

<%
	if (!"Cancel".equals(request.getParameter("confirm"))) {
		List ok = new ArrayList();
		request.setAttribute("ok", ok);
		List notOk = new ArrayList();
		request.setAttribute("notOk", notOk);
		String[] files = request.getParameterValues("file");
		if (files != null) {
			for (int i = 0; i < files.length; i++) {
				String name = files[i];
				try {
					CatalogEntry entry = elab.getDataCatalogProvider().getEntry(name);
					//EPeronja-06/11/2013: 254 When deleting files, be sure there are not dependent files
					int figureCount = 10;
					if (entry != null) {
						for (int x = 0; x < figureCount; x++ ) {
							int figNo = x + 1;
							int count = DataTools.checkPlotDependency(elab, name, figNo);
							if (count > 0) {
							    throw new ElabJspException(name + " is being used either in a poster or logbook. Cannot be deleted.");								
							}
						}
					}//end of checking dependencies
					if (entry == null) {
					    throw new ElabJspException("not found in the catalog");
					}
					String posterUserName = (String) entry.getTupleValue("group");
					if (posterUserName == null) {
						    throw new ElabJspException("no user associated with the file");
						}
						ElabGroup posterUser = elab.getUserManagementProvider().getGroup(posterUserName);
						if (!user.getName().equals(posterUser.getName())) {
						    throw new ElabJspException("you are not the owner of the file");
						}
						ok.add(entry);
					}
				catch (Exception e) {
					notOk.add(name + " error: " + e.getMessage());
				}
			}
			if ("Delete".equals(request.getParameter("confirm"))) {
				Iterator i = ok.iterator();
				while (i.hasNext()) {
					CatalogEntry entry = (CatalogEntry) i.next();
					try {
						elab.getDataCatalogProvider().delete(entry);
					}
					catch (Exception e) {
						notOk.add("Could not delete " + entry.getLFN() + ": " + e.getMessage());
					}
				}
			}
			else if (!ok.isEmpty()) {
				request.setAttribute("inhibitPage", Boolean.TRUE);
			}
		}
	}
%>

<c:if test="${param.file != null && param.confirm != 'Cancel'}">
	<table id="deletion-results">
		<c:forEach items="${notOk}" var="m">
			<tr>
				<td>${m}</td>
			</tr>
		</c:forEach>
	</table>
	
	<c:if test="${param.confirm != 'Delete' && !empty ok}">
		<div style="border: 2px solid red;">
			<h2>Are you sure you want to delete the following files?</h2>
		
			<form method="get">
				 <table id="deletion-results">
					<c:forEach items="${ok}" var="m">
						<tr>
							<td>
								<c:choose>
									<c:when test="${m.tupleMap.name != null}">
										${m.tupleMap.name} (${m.LFN})
									</c:when>
									<c:otherwise>
										${m.LFN}
									</c:otherwise>
								</c:choose>
								<input type="hidden" name="file" value="${m.LFN}" />
							</td>
						</tr>
					</c:forEach>
					<tr>
						<td>
							<p align="center">
								<input type="submit" name="confirm" value="Cancel" />
								<input type="submit" name="confirm" value="Delete" />
							</p>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</c:if>
	<c:if test="${param.confirm == 'Delete'}">
		<table id="deletion-results">
			<c:forEach items="${ok}" var="m">
				<tr>
					<td>
						<c:choose>
							<c:when test="${m.tupleMap.name != null}">
								${m.tupleMap.name} (${m.LFN})
							</c:when>
							<c:otherwise>
								${m.LFN}
							</c:otherwise>
						</c:choose>
						deleted.
					</td>
				</tr>
			</c:forEach>
		</table>
	</c:if>
</c:if>