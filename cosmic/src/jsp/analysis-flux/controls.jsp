<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<form method="post" action="../analysis-flux/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
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
								<e:trlabel for="singlechannel_channel" name="Channel Number">Channel Number:</e:trlabel>
							</td>
							<td class="form-control">
								<e:trselect name="singlechannel_channel" labelList="${channels}" 
									valueList="${channels}" default="${channels[0]}"/>
							</td>
						</tr>
						<tr>
							<td class="form-label">
								<e:trlabel for="flux_binWidth" name="Bin Width (seconds)">Bin Width (seconds):</e:trlabel>
							</td>
							<td class="form-control">
								<e:trinput type="text" name="flux_binWidth" size="8" default="600"
									onChange="{plot_ylabel.value='Flux (events/m^2/' + flux_binWidth.value + ') seconds';}"/>
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
									<e:trinput type="text" name="plot_lowX" size="19" maxlength="19"
										default="${startDate}" onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_highX" name="X-max">X-max:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_highX" size="19" maxlength="19"
										default="${endDate}" onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_lowY" name="Y-min">Y-min:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_lowY" size="8" maxlength="8"
										default="0" onError="Must be an integer"/>
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
										default="Flux Study"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_caption">Figure caption:</label>
								</td>
								<td class="form-control">
									<e:trtextarea name="plot_caption" rows="5" cols="30"><e:default>
<%= DataTools.getFigureCaption(elab, ((ElabAnalysis) request.getAttribute("analysis")).getParameterValues("rawData")) %>
<e:analysisParamLabel name="singlechannel_channel"/>											
									</e:default></e:trtextarea>
								</td>
							</tr>
						</table>
					</e:hidden>
				</e:vswitch>
			</e:tr>
		</p>
		<%@ include file="../analysis/controls.jsp" %>
		<p>
			<!-- this MUST be used if all the e:tr* stuff is to work                      -->
			<!-- it ensures that the name of the submit button is the right thing ("submit") -->
			<e:trsubmit/>
		</p>
	</form>
</div>