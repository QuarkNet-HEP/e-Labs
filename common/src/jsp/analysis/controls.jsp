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
							<input type="radio" name="runMode" value="local" checked="${param.runMode == null || param.runMode == 'local'}"/> Local 
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="local"/>)<br />
							<input type="radio" name="runMode" value="i2u2" checked="${param.runMode == 'i2u2'}"/> I2U2 Cluster
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="i2u2"/>)<br />
							<input type="radio" name="runMode" value="grid" checked="${param.runMode == 'grid'}"/> Grid
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="grid"/>)<br />
							<input type="radio" name="runMode" value="mixed" checked="${param.runMode == 'mixed'}"/> Automatic
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="mixed"/>)<br />
						</optgroup>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</p>