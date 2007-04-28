<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<form method="get">
		<elab:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
		<p>
			<elab:tr name="Quarknet.Cosmic::PerformanceStudyNoThresh">
				<elab:vswitch revert="true">
					<elab:visible>
						<strong>Analysis Controls</strong> 
					</elab:visible>
					<elab:hidden>
						<strong>Analysis Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<elab:trlabel for="freq_binValue" name="Bin Width">Number of Bins:</elab:trlabel>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="freq_binValue" size="8" default="60"
										onError="Use either a positive number or an expression (e.g. 60*60)"/>
								</td>
							</tr>
						</table>
					</elab:hidden>
				</elab:vswitch>
			</elab:tr>
		</p>
		<p>
			<elab:tr name="Quarknet.Cosmic::Plot">
				<elab:vswitch revert="${param.submit == 'Change'}">
					<elab:visible>
						<strong>Plot Controls</strong>
					</elab:visible>
					<elab:hidden>
						<strong>Plot Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<elab:trlabel for="plot_lowX" name="X-min">X-min:</elab:trlabel>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="plot_lowX" size="8" maxlength="8"
										onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<elab:trlabel for="plot_highX" name="X-max">X-max:</elab:trlabel>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="plot_highX" size="8" maxlength="8"
										onError="Enter a positive number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<elab:trlabel for="plot_lowY" name="Y-min">Y-min:</elab:trlabel>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="plot_lowY" size="8" maxlength="8"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<elab:trlabel for="plot_highY" name="Y-max">Y-max:</elab:trlabel>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="plot_highY" size="8" maxlength="8"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_size">Plot Size:</label>
								</td>
								<td class="form-control">
									<%-- This is not linked to the TR. It's a parameter for the output page --%>
									<elab:trselect valueList="300, 600, 800" labelList="Small, Medium, Large"
										name="plot_size" default="600"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_title">Plot Title:</label>
								</td>
								<td class="form-control">
									<elab:trinput type="text" name="plot_title" size="40" maxlength="100"
										default="Performance Study"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_caption">Figure caption:</label>
								</td>
								<td class="form-control">
									<elab:trtextarea name="plot_caption" rows="5" cols="30"
										default="<%= DataTools.getFigureCaption(elab, request.getParameterValues("rawData")) %>"/>
								</td>
							</tr>
						</table>
					</elab:hidden>
				</elab:vswitch>
			</elab:tr>
		</p>
		<p>
			<!-- this MUST be used if all the elab:tr* stuff is to work                      -->
			<!-- it ensures that the name of the submit button is the right thing ("submit") -->
			<elab:trsubmit/>
		</p>
	</form>
</div>