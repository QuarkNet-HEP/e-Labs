<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<div class="left">
	<div id="placeholder<%= request.getParameter("chartIndex")%>" class="graph-placeholder" style="width:250px; height:250px;"></div>
	<br />
	<div class="tofDetails" id="tofDetails" style="display: inline-block;" >View Controls
		<span class="tofControls" id="tofControls">
		<div id="refit" style="border: 1px dotted black;">
			<div id="xrefit<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="xrefit<%= request.getParameter("chartIndex")%>Table">
					<tr>
						<td><strong>Refit X Values: </strong><input type="button" value="Reset" id="resetFitXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:resetPlotFitX(<%= request.getParameter("chartIndex")%>);' /></td>
					</tr>
					<tr>
						<td style="background-color: lightGray" nowrap>
							Min X: <input type="text" size="3" id="minFitX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="minFitXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotFitX(<%= request.getParameter("chartIndex")%>, minFitX<%= request.getParameter("chartIndex")%>.value, "min");' />
							Max X: <input type="text" size="3" id="maxFitX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="maxFitXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotFitX(<%= request.getParameter("chartIndex")%>, maxFitX<%= request.getParameter("chartIndex")%>.value, "max");' />
						</td>
					</tr>
				</table>
			</div>	
			<div id="mean<%= request.getParameter("chartIndex") %>" style="font-size: x-small;"></div>
			<div id="stddev<%= request.getParameter("chartIndex") %>" style="font-size: x-small;"></div>
		</div>
		<div id="scale" style="border: 1px dotted black;">
			<div id="xaxis<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="xaxis<%= request.getParameter("chartIndex")%>Table">
					<tr>
						<td><strong>X-axis scale: </strong><input type="button" value="Reset" id="resetXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:resetPlotX(<%= request.getParameter("chartIndex")%>);' /></td>
					</tr>
					<tr>
						<td style="background-color: lightGray" nowrap>
							Min X: <input type="text" size="3" id="minX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="minXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, minX<%= request.getParameter("chartIndex")%>.value, "min");' />
							Max X: <input type="text" size="3" id="maxX<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="maxXButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotX(<%= request.getParameter("chartIndex")%>, maxX<%= request.getParameter("chartIndex")%>.value, "max");' />
						</td>
					</tr>
				</table>
			</div>
			<div id="yaxis<%= request.getParameter("chartIndex") %>" style="width:245px;">
				<table id="yaxis<%= request.getParameter("chartIndex")%>Table" >
					<tr>
						<td><strong>Y-axis scale: </strong><input type="button" value="Reset" id="ResetYButton<%= request.getParameter("chartIndex")%>" onclick='javascript:resetPlotY(<%= request.getParameter("chartIndex")%>);' /></td>
					</tr>
					<tr>
						<td style="background-color: lightGray" nowrap>
							Min Y: <input type="text" size="3" id="minY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMinButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,minY<%= request.getParameter("chartIndex")%>.value, "min");' />
							Max Y: <input type="text" size="3" id="maxY<%= request.getParameter("chartIndex")%>" /><input type="button" value="Set" id="YMaxButton<%= request.getParameter("chartIndex")%>" onclick='javascript:redrawPlotY(<%= request.getParameter("chartIndex")%>,maxY<%= request.getParameter("chartIndex")%>.value, "max");' />
						</td>
					</tr>
				</table>
			</div>	
		</div>	
		<div id="binning" style="border: 1px dotted black">			
			<div id="incdec<%= request.getParameter("chartIndex") %>" style="width:245px;">Bin Width
		   		<input type="number" name="binWidth<%= request.getParameter("chartIndex") %>" id="binWidth<%= request.getParameter("chartIndex") %>" min="0.5" style="width: 60px;"/>
			</div>
			<div class="slider" style="width:245px;">
		    	<input id="range<%= request.getParameter("chartIndex") %>" type="range" min="0.5" style="width: 240px;"></input>
		    </div>
		    <br />
		</span>
		</div>
<% if (!user.isGuest()) { %>		
		<div style="text-align:center; width: 100%;">
			Filename <input type="text" name="chartName<%= request.getParameter("chartIndex")%>" id="chartName<%= request.getParameter("chartIndex")%>" value="">
			<br / >
			</input><input type="button" name="save" onclick='return saveChart(onOffPlot<%= request.getParameter("chartIndex")%>, "chartName<%= request.getParameter("chartIndex")%>", "msg<%= request.getParameter("chartIndex")%>", <%= request.getParameter("runId") %>);' value="Save Chart"></input>     
			<br / >
			<div id="msg<%= request.getParameter("chartIndex")%>">&nbsp;</div>  
		</div>
<% } %>
	</div>		
</div>
