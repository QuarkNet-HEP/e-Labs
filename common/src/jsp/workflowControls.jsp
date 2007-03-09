<%@ include file="dhtmlutil.jsp" %>

<tr>
	<td align="left"> 
		<% visibilitySwitcher(out, "controlwf", "workflowParam0", "Execution Controls", false); %>
	</td>
</tr>
<tr>
	<td>
		<div id='workflowParam0' style="visibility:hidden;display:none">
			<table width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						<a href="javascript: describe('Elab.Elab::RunMode','??','???')"><IMG SRC="graphics/question.gif" border="0"></a>
						Run mode:
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<input type="radio" name="workflowRunMode" value="local"> Local<br>
						<input checked type="radio" name="workflowRunMode" value="mixed"> Local and Grid<br>
						<input type="radio" name="workflowRunMode" value="grid"> Grid<br>
					</td>
				</tr>
			</table>
		</div>
	</td>
</tr>
