<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${!empty paramValues.file}">
	<table id="deletion-results">
		<c:forEach items="${paramValues.file}" var="file">
			<tr>
				<%
					try {
						String name = (String) pageContext.getAttribute("file");
						CatalogEntry entry = elab.getDataCatalogProvider().getEntry(name);
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
					    elab.getDataCatalogProvider().delete(entry);
					    %> <td class="success">${file} deleted successfully</td> <%
					}
					catch (Exception e) {
					    %> <td class="failure">Could not delete ${file}: <%= e.getMessage() %></td> <%
					}
				%>
			</tr>
		</c:forEach>
	</table>
</c:if>
