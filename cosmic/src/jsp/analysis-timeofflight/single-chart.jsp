<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<div class="left">
	<div id="chartTitle<%= request.getParameter("chartIndex")%>">&nbsp;</div>
	<div id="placeholder<%= request.getParameter("chartIndex")%>" class="graph-placeholder" style="width:250px; height:250px;"></div>
	<div>
	<% if (!user.isGuest()) { %>		
			<div style="text-align:center; width: 100%;">
				<div class="dropdown" style="text-align: left; width: 180px;">
				<input type="text" name="chartName<%= request.getParameter("chartIndex")%>" id="chartName<%= request.getParameter("chartIndex")%>" value="default!">

				<%@ include file="../plots/view-saved-plot-names.jsp" %>
			</div><br />(View your saved names)<br />
			<input type="button" name="save" onclick='return validatePlotName("chartName<%= request.getParameter("chartIndex")%>"); return saveToFChart(<%= request.getParameter("chartIndex")%>, "chartName<%= request.getParameter("chartIndex")%>", "msg<%= request.getParameter("chartIndex")%>", <%= request.getParameter("runId") %>);' value="Save Chart"></input>     

			<div id="msg<%= request.getParameter("chartIndex")%>">&nbsp;</div>  
	<% } %>
	</div>		
	<div class="tofDetails" id="tofDetails"  >Advanced Controls
		<span class="tofControls" id="tofControls">
		<div id="refit" style="border: 1px dotted black;">
			<br />
			<div id="xrefit<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="xrefit<%= request.getParameter("chartIndex")%>Table">
					<tr>
						<td nowrap><strong>Refit X Values:</strong> </td>
						<td nowrap>
							Min X: <input type="text" size="3" id="minFitX<%= request.getParameter("chartIndex")%>" />
							Max X: <input type="text" size="3" id="maxFitX<%= request.getParameter("chartIndex")%>" />
							<input type="button" value="Refit X" id="maxFitXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotFitX(<%= request.getParameter("chartIndex")%>, minFitX<%= request.getParameter("chartIndex")%>.value, maxFitX<%= request.getParameter("chartIndex")%>.value);' />
						</td>
					</tr>
				</table>
			</div>	
			<div id="mean<%= request.getParameter("chartIndex") %>" style="font-size: x-small;"></div>
			<div id="stddev<%= request.getParameter("chartIndex") %>" style="font-size: x-small;"></div>
		</div>
		<div id="scale" style="border: 1px dotted black;">
			<br />
			<div id="xaxis<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="xaxis<%= request.getParameter("chartIndex")%>Table">
					<tr>
						<td nowrap><strong>X-axis scale:</strong> </td>
						<td nowrap>
							Min X: <input type="text" size="3" id="minX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="minXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, minX<%= request.getParameter("chartIndex")%>.value, "min");' />
							Max X: <input type="text" size="3" id="maxX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="maxXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, maxX<%= request.getParameter("chartIndex")%>.value, "max");' />
						</td>
					</tr>
				</table>
			</div>
			<br />
			<div id="yaxis<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="yaxis<%= request.getParameter("chartIndex")%>Table" >
					<tr>
						<td nowrap><strong>Y-axis scale:</strong> </td>
						<td nowrap> 
							Min Y: <input type="text" size="3" id="minY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMinButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,minY<%= request.getParameter("chartIndex")%>.value, "min");' />
							Max Y: <input type="text" size="3" id="maxY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMaxButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,maxY<%= request.getParameter("chartIndex")%>.value, "max");' />
						</td>
					</tr>
				</table>
			</div>	
		</div>	
		<div id="binning" style="border: 1px dotted black">			
			<br />
			<div id="incdec<%= request.getParameter("chartIndex") %>" style="width:245px;"><strong>Bin Width</strong>
		   		<input type="number" name="binWidth<%= request.getParameter("chartIndex") %>" id="binWidth<%= request.getParameter("chartIndex") %>" min="0.5" style="width: 60px;"/>
			</div>
			<div class="slider" style="width:245px;">
		    	<input id="range<%= request.getParameter("chartIndex") %>" type="range" min="0.5" style="width: 240px;"></input>
		    </div>
		 </div>
		 <div id="reset" style="border: 1px dotted black">			
			<br />
			<input type="button" value="Reset All" id="ResetAll<%= request.getParameter("chartIndex")%>" onclick='javascript:resetAll(<%= request.getParameter("chartIndex")%>);' />
		 </div>
		</span>
	</div>
</div>
