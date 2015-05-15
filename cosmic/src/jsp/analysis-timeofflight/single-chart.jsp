<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="left">
	<div id="placeholder<%= request.getParameter("chartIndex")%>" class="graph-placeholder" style="width:250px; height:250px;"></div>
	<br />
	<div id="xaxis<%= request.getParameter("chartIndex") %>">
		<table id="xaxis<%= request.getParameter("chartIndex")%>Table">
			<tr>
				<td><strong>X-axis scale: </strong><input type="button" value="Reset" id="resetXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:resetPlotX(<%= request.getParameter("chartIndex")%>);' /></td>
			</tr>
			<tr>
				<td style="background-color: lightGray" nowrap>
					Min X: <input type="text" size="5" id="minX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="minXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, minX<%= request.getParameter("chartIndex")%>.value, "min");' />
					Max X: <input type="text" size="5" id="maxX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="maxXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, maxX<%= request.getParameter("chartIndex")%>.value, "max");' />
				</td>
			</tr>
		</table>
	</div>
	<div id="yaxis<%= request.getParameter("chartIndex") %>" >
		<table id="yaxis<%= request.getParameter("chartIndex")%>Table" >
			<tr>
				<td><strong>Y-axis scale: </strong><input type="button" value="Reset" id="ResetYButton<%= request.getParameter("chartIndex")%>" onclick='javascript:resetPlotY(<%= request.getParameter("chartIndex")%>);' /></td>
			</tr>
			<tr>
				<td style="background-color: lightGray" nowrap>
					Min Y: <input type="text" size="5" id="minY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMinButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,minY<%= request.getParameter("chartIndex")%>.value, "min");' />
					Max Y: <input type="text" size="5" id="maxY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMaxButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,maxY<%= request.getParameter("chartIndex")%>.value, "max");' />
				</td>
			</tr>
		</table>
	</div>	
				
	<div id="incdec<%= request.getParameter("chartIndex") %>">Bin Width
   		<input type="number" name="binWidth<%= request.getParameter("chartIndex") %>" id="binWidth<%= request.getParameter("chartIndex") %>" step="2.0" min="1.0" style="width: 60px;"/>
	</div>
	<div class="slider">
    	<input id="range<%= request.getParameter("chartIndex") %>" type="range" step="2.0" min="1.0" style="width: 250px;"></input>
    </div>
    <br />
	<div style="text-align:center; width: 100%;">
		Filename <input type="text" name="chartName<%= request.getParameter("chartIndex")%>" id="chartName<%= request.getParameter("chartIndex")%>" value=""></input><input type="button" name="save" onclick='return saveChart(onOffPlot<%= request.getParameter("chartIndex")%>, "chartName<%= request.getParameter("chartIndex")%>", "msg<%= request.getParameter("chartIndex")%>", <%= request.getParameter("runId") %>);' value="Save Chart"></input>     
		<div id="msg<%= request.getParameter("chartIndex")%>">&nbsp;</div>  
	</div>
</div>
