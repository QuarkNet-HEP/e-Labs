<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%
	ArrayList<String> plotNames = DataTools.getPlotNamesByGroup(elab, user.getName(), elab.getName());
	request.setAttribute("plotNames",plotNames);

%>
<select id="existingPlotNames" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
	<option></option>
	<c:forEach items="${ plotNames}" var="plotName">
		<option>${plotName }</option>
	</c:forEach>
</select>