<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>

<div id="analysis-controls">
	<form method="post" action="../analysis-lifetime/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
		<p>
			<e:tr name="Quarknet.Cosmic::LifetimeStudy">
				<e:vswitch revert="true">
					<e:visible>
						<strong>Analysis Controls</strong> 
					</e:visible>
					<e:hidden>
						<strong>Analysis Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_coincidence" name="Coincidence level">Coincidence level:</e:trlabel>
								</td>
								<td class="form-control">
									
									<e:trselect name="lifetime_coincidence" 
										valueList="1, 2, 3, 4" labelList="1, 2, 3, 4" default="1"/>
								</td>
							</tr>
							<e:trinput type="hidden" name="lifetime_energyCheck" value="0"/>
							<!-- 
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_energyCheck" name="Check Energy of Second Pulse">Check energy of 2<sup>nd</sup> pulse</e:trlabel>
								</td>
								<td class="form-control">
									<e:trselect name="lifetime_energyCheck" valueList="0, 1" labelList="No, Yes"
										default="1"/>
								</td>
							</tr>
							-->
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_gatewidth" name="Gate Width (seconds)">Gate width (seconds):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="lifetime_gatewidth" size="8" default="1e-5"
										onError="Must be an integer or number of the form (1e-5)"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="freq_binValue" name="Number of Bins">Number of Bins:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="freq_binValue" size="8" default="40"
										onError="Must be an integer"/>
								</td>
							</tr>
						</table>
					</e:hidden>
				</e:vswitch>
			</e:tr>
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
										default="Lifetime Study"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_caption">Figure caption:</label>
								</td>
								<td class="form-control">
									<e:trtextarea name="plot_caption" rows="5" cols="30"><e:default>
<%= DataTools.getFigureCaption(elab, ((ElabAnalysis) request.getAttribute("analysis")).getParameterValues("rawData")) %>
<e:analysisParamLabel name="lifetime_coincidence"/>
									</e:default></e:trtextarea>									

								</td>
							</tr>
						</table>
					</e:hidden>
				</e:vswitch>
			</e:tr>
			<e:tr name="Quarknet.Cosmic::LifetimeStudy">
				<e:vswitch revert="${param.submit == 'Change'}">
					<e:visible>
						<strong>Fit Controls</strong>
					</e:visible>
					<e:hidden>
						<strong>Fit Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_turnedOn" name="Fitting Turned On">Fitting Turned On:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trselect name="extraFun_turnedOn" valueList="1, 0" labelList="Yes, No"
										default="0"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_minX" name="X-min of fit">X-min of fit:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="extraFun_minX" size="8" maxlength="10"
										default=".1" onError="Must be a decimal number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_maxX" name="X-max of fit">X-max of fit:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="extraFun_maxX" size="8" maxlength="10"
										default="10" onError="Must be a decimal number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_alpha_variate" name="Fit Y-intercept">Fit Y-intercept:</e:trlabel>
									<e:trselect name="extraFun_alpha_variate" valueList="yes, no" labelList="Yes, No"
										default="yes"/>
								</td>
								<td class="form-control">
									<e:trlabel for="extraFun_alpha_guess" name="Alpha">Alpha:</e:trlabel>
									<e:trinput type="text" name="extraFun_alpha_guess" size="8" default=""
										onError="Must be a decimal number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_lifetime_variate" name="Fit Lifetime">Fit Lifetime:</e:trlabel>
									<e:trselect name="extraFun_lifetime_variate" valueList="yes, no" labelList="Yes, No" 
										default="yes"/>
								</td>
								<td class="form-control">
									<e:trlabel for="extraFun_lifetime_guess" name="Lifetime">Lifetime:</e:trlabel>
									<e:trinput type="text" name="extraFun_lifetime_guess" size="8" default=""
										onError="Must be a decimal number"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="extraFun_constant_variate" name="Fit Background">Fit Background:</e:trlabel>
									<e:trselect name="extraFun_constant_variate" valueList="yes, no" labelList="Yes, No"
										default="yes"/>
								</td>
								<td class="form-control">
									<e:trlabel for="extraFun_constant_guess" name="Background">Background:</e:trlabel>
									<e:trinput type="text" name="extraFun_constant_guess" size="8" default=""
										onEror="Must be a decimal number"/>
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