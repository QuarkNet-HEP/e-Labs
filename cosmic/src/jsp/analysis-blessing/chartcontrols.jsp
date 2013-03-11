<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- //EPeronja-02/10/2013: Bug472- Control to set y axes -->
<div id="<%= request.getParameter("chartName") %>" >
	<table id="<%= request.getParameter("chartName")%>Table" >
		<tr>
			<td>Custom 
			<c:choose>
				<c:when test="${param.chartName == 'channel' }" >
					Channel Rate 
				</c:when>
				<c:when test="${param.chartName == 'trigger' }" >
					Trigger Rate 
				</c:when>				
				<c:when test="${param.chartName == 'satellite' }" >
					Satellite 
				</c:when>	
				<c:when test="${param.chartName == 'voltage' }" >
					Voltage 
				</c:when>
				<c:when test="${param.chartName == 'temperature' }" >
					Temperature 
				</c:when>
				<c:when test="${param.chartName == 'pressure' }" >
					Pressure 
				</c:when>														
			</c:choose>
			Y axis scale: </td>
			<td style="background-color: lightGray">Min Y: <input type="text" id="<%= request.getParameter("chartName")%>MinY" /><input type="button" value="Set" id="<%= request.getParameter("chartName")%>YMinButton" onclick='javascript:redrawPlotY(<%= request.getParameter("chartName")%>MinY.value, "<%= request.getParameter("chartName")%>", "min");' /></td>
			<td style="background-color: lightGray">Max Y: <input type="text" id="<%= request.getParameter("chartName")%>MaxY" /><input type="button" value="Set" id="<%= request.getParameter("chartName")%>YMaxButton" onclick='javascript:redrawPlotY(<%= request.getParameter("chartName")%>MaxY.value, "<%= request.getParameter("chartName")%>", "max");' /></td>
			<td style="background-color: lightGray"><input type="button" value="Reset" id="<%= request.getParameter("chartName")%>ResetButton" onclick='javascript:resetPlotY("<%=request.getParameter("chartName")%>", "<%= request.getParameter("chartName")%>MinY", "<%= request.getParameter("chartName")%>MaxY");' /></td>
		</tr>
	</table>
</div>		