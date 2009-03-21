<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<p>
	<e:vswitch revert="true">
		<e:visible>
			<strong>Execution Mode</strong> <a href="javascript:showRefLink('../library/ref-exec-choices.jsp',820,700)"><img src="../graphics/question.gif"></a>
		</e:visible>
		<e:hidden>
			<strong>Execution Mode</strong> <a href="javascript:showRefLink('../library/ref-exec-choices.jsp',820,700)"><img src="../graphics/question.gif"></a>
			<input type="hidden" name="provider" value="swift"/>
			<table id="swift-run-mode" width="100%" align="center">
				<tr>
					<td width="20%">&nbsp;</td>
					<td align="left">
						<optgroup>
							<input type="radio" name="runMode" value="local" checked="checked"/> Local 
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="local"/>)<br />
							<input type="radio" name="runMode" value="i2u2" /> I2U2 Cluster
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="i2u2"/>)<br />
							<input type="radio" name="runMode" value="grid" /> Grid
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="grid"/>)<br />
							<input type="radio" name="runMode" value="mixed" /> Automatic
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="mixed"/>)<br />
							<input type="radio" name="runMode" value="coasters" /> Coasters (experimental)
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="coasters"/>)<br />
						</optgroup>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</p>