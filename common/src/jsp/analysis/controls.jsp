<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<p>
	<e:vswitch>
		<e:visible>
			<strong>Execution Controls</strong> <a href="javascript:showRefLink('../library/ref-exec-choices.jsp',820,700)"><img src="../graphics/question.gif"></a>
		</e:visible>
		<e:hidden>
			<strong>Execution Controls</strong> <a href="javascript:showRefLink('../library/ref-exec-choices.jsp',820,700)"><img src="../graphics/question.gif"></a>
			<table width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						Run with:
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<input id="vds-radio" type="radio" name="provider" value="vds" checked="true" onChange="update()" /> 
						<a href="http://vds.uchicago.edu" target="vds">VDS</a><br />
						<input type="radio" name="provider" value="swift" onChange="update()" /> 
						<a href="http://www.ci.uchicago.edu/swift" target="swift">Swift</a><br />
					</td>
				</tr>
			</table>
			<table id="swift-run-mode" width="100%" align="center">
				<tr>
					<td align="center" width="40%" valign="top">
						Swift run mode:
					</td>
				</tr>
				<tr>
					<td width="40%">&nbsp;</td>
					<td align="left">
						<optgroup>
							<input id="r0" type="radio" name="runMode" value="local" /> Local<br />
							<input id="r1" type="radio" name="runMode" value="grid" /> Grid<br />
							<input id="r2" type="radio" name="runMode" value="i2u2" /> I2U2 Cluster<br />
							<input id="r3" checked="true" type="radio" name="runMode" value="mixed" /> Automatic<br />
						</optgroup>
					</td>
				</tr>
			</table>
			<script language="javascript">
				function update() {
					var disabled = false;
					var color = "black";
					if (document.getElementById("vds-radio").checked) {
						disabled = true;
						var color = "gray";
					}
					for (i = 0; i < 16; i++) {
						var el = document.getElementById("r" + i);
						if (el) {
							el.disabled = disabled;
						}
					}
					document.getElementById("swift-run-mode").style.color = color;
				}
				
				update();
			</script>
		</e:hidden>
	</e:vswitch>
</p>