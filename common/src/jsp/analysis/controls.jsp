<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<p>
	<e:vswitch>
		<e:visible>
			<strong>Execution Controls</strong>
		</e:visible>
		<e:hidden>
			<strong>Execution Controls</strong>
			<table width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						Run with:
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<input type="radio" name="provider" value="vds" checked="true" /> VDS<br>
						<input type="radio" name="provider" value="swift" /> Swift<br>
					</td>
				</tr>
			</table>
			<table width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						Run mode (if you chose "Swift" above):
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<input type="radio" name="workflowRunMode" value="local" /> Local<br>
						<input checked="true" type="radio" name="workflowRunMode" value="mixed" /> Local and Grid<br>
						<input type="radio" name="workflowRunMode" value="grid" /> Grid<br>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</p>