<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- Control to set y axes -->
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
			<td style="background-color: lightGray">Min Y: <input type="text" id="<%= request.getParameter("chartName")%>MinY" /><input type="button" value="Set" id="<%= request.getParameter("chartName")%>YMinButton" onclick='javascript:redrawMinPlotY(<%= request.getParameter("chartName")%>MinY.value, "<%= request.getParameter("chartName")%>");' /></td>
			<td style="background-color: lightGray">Max Y: <input type="text" id="<%= request.getParameter("chartName")%>MaxY" /><input type="button" value="Set" id="<%= request.getParameter("chartName")%>YMaxButton" onclick='javascript:redrawMaxPlotY(<%= request.getParameter("chartName")%>MaxY.value, "<%= request.getParameter("chartName")%>");' /></td>
		</tr>
	</table>
</div>		