<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<%-- Must specify the action so that get parameters are not mixed with the post ones --%>
	<form method="post" action="../analysis-performance/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below. Be sure to click the question icon next to "Bin width (ns)."</p>
		<p>
			<e:vswitch revert="true">
				<e:visible>
					<strong>Analysis Controls</strong> 
				</e:visible>
				<e:hidden>
					<strong>Analysis Controls</strong>
					<table>
						<tr>
							<td class="form-label">
								<label>Channels:</label>
							</td>
							<td class="form-control">
								<table>
									<tr>
								<%
									Set valid = (Set) request.getAttribute("validChannels");
									ElabAnalysis a = (ElabAnalysis) request.getAttribute("analysis");
									for (int i = 1; i <= 4; i++) {
										String channel = String.valueOf(i);
										if (valid.contains(channel)) {
											out.write("<td>");
											out.write(channel + "<input type=\"checkbox\" name=\"" + channel + "\" ");
											if (((String) a.getParameter("singlechannel_channel")).indexOf(channel) != -1) {
												out.write("checked=\"true\"");
											}
											out.write("/></td>");
										}
									}  
								%>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td class="form-label">
								<e:trlabel for="freq_binValue" name="Bin Width">Bin width (ns):</e:trlabel>
							</td>
							<td class="form-control">
								<e:trinput type="text" name="freq_binValue" size="8" default="2"
									onError="Use either a positive number or an expression (e.g. 60*60)"/>
							</td>
						</tr>
					</table>
				</e:hidden>
			</e:vswitch>
		</p>
		<p>
			<e:tr name="Quarknet.Cosmic::Plot">
				<e:vswitch revert="${param.submit == 'Change'}">
					<e:visible>
						<strong>Plot Controls</strong>
					</e:visible>
					<e:hidden>
						<strong>Plot Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_lowX" name="X-min">X-min:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_lowX" size="8" maxlength="8"
										onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_highX" name="X-max">X-max:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_highX" size="8" maxlength="8"
										onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_lowY" name="Y-min">Y-min:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_lowY" size="8" maxlength="8"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_highY" name="Y-max">Y-max:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_highY" size="8" maxlength="8"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_size">Plot Size:</label>
								</td>
								<td class="form-control">
									<e:trselect valueList="300, 600, 800" labelList="Small, Medium, Large"
										name="plot_size" default="600"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_title">Plot Title:</label>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_title" size="40" maxlength="100"
										default="Performance Study"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_caption">Figure caption:</label>
								</td>
								<td class="form-control">
									<e:trtextarea name="plot_caption" rows="5" cols="30"
										default="<%= DataTools.getFigureCaption(elab, ((ElabAnalysis) request.getAttribute("analysis")).getParameterValues("rawData")) %>"/>
								</td>
							</tr>
						</table>
					</e:hidden>
				</e:vswitch>
			</e:tr>
		</p>
		<%@ include file="../analysis/controls.jsp" %>
		<p>
			<!-- this MUST be used if all the elab:tr* stuff is to work                      -->
			<!-- it ensures that the name of the submit button is the right thing ("submit") -->
			<e:trsubmit/>
		</p>
	</form>
</div>