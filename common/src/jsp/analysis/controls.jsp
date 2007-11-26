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
						<input type="radio" name="provider" value="vds" checked="true" /> 
						<a href="http://vds.uchicago.edu" target="vds">VDS</a><br />
						<input type="radio" name="provider" value="swift" /> 
						<a href="http://www.ci.uchicago.edu/swift" target="swift">Swift</a><br />
					</td>
				</tr>
			</table>
			<table width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						Swift run mode:
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<input type="radio" name="runMode" value="local" /> Local<br />
						<input type="radio" name="runMode" value="grid" /> Grid<br />
						<input type="radio" name="runMode" value="i2u2" /> I2U2 Cluster<br />
						<input checked="true" type="radio" name="runMode" value="mixed" /> Automatic<br />
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</p>