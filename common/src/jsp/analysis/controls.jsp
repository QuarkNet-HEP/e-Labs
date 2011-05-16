<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.tags.*" %>
<%@ page import="gov.fnal.elab.estimation.*" %>

<%
	Estimator localEstimator = AnalysisRunTimeEstimator.getEstimator(elab, "swift", "local", analysis.getType());
	request.setAttribute("localRunTime", localEstimator.estimate(elab, analysis));
	request.setAttribute("maxLocalRunTime", elab.getProperties().getMaxAllowedLocalRunTime());
	request.setAttribute("maxLocalRunTimeFormatted", elab.getProperties().getMaxAllowedLocalRunTimeFormatted());  
%>
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
					<td width="80%" align="left">
							<c:set var="checked" value="checked=\"true\""/>
							<c:set var="notchecked" value=""/>
							<c:choose>
								<c:when test="${localRunTime < maxLocalRunTime}">
									<input type="radio" name="runMode" value="local" ${empty param.runMode || param.runMode == 'local' ? checked : notchecked}/> Local 
										(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="local"/>)<br />
								</c:when>
								<c:otherwise>
									<span style="color: gray">
										<input type="radio" disabled="true" name="runMode" value="local" notchecked/> Local 
											(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="local"/> - too large; 
											max allowed: ${maxLocalRunTimeFormatted})<br />
									</span>
								</c:otherwise>
							</c:choose>
							<input type="radio" name="runMode" value="i2u2" ${param.runMode == 'i2u2' ? checked : notchecked}/> I2U2 Cluster
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="i2u2"/>)<br />
							<input type="radio" name="runMode" value="mixed" ${param.runMode == 'mixed' ? checked : notchecked}/> Automatic
								(estimated time: <e:analysisRunTimeEstimator engine="swift" mode="mixed"/>)<br />
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</p>