<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>
<%
	//build set of detector id locations
	ResultSet rs = elab.getDataCatalogProvider().getEntries(analysis.getParameterValues("rawData"));
	Map detectors = new TreeMap();
	Iterator i = rs.iterator();
	while (i.hasNext()) {
	    CatalogEntry e = (CatalogEntry) i.next();
	    String did = (String) e.getTupleValue("detectorid");
	    detectors.put(did, e.getTupleValue("school") + ", " + e.getTupleValue("city") + ", " 
	            + e.getTupleValue("state") + " (" + did + ")");
	}
	Collection availableChannels = AnalysisParameterTools.getValidChannels(elab, rawData);
	String lifetime_muon_singleChannel_require = (String) analysis.getParameter("lifetime_muon_singleChannel_require");
	String lifetime_muon_singleChannel_veto = (String) analysis.getParameter("lifetime_muon_singleChannel_veto");
	String lifetime_electron_singleChannel_require = (String) analysis.getParameter("lifetime_electron_singleChannel_require");
	String lifetime_electron_singleChannel_veto = (String) analysis.getParameter("lifetime_electron_singleChannel_veto");
	if (lifetime_muon_singleChannel_require == null) {
		lifetime_muon_singleChannel_require = "";
	}
	if (lifetime_muon_singleChannel_veto == null) {
		lifetime_muon_singleChannel_veto = "";
	}
	if (lifetime_electron_singleChannel_require == null) {
		lifetime_electron_singleChannel_require = "";
	}
	if (lifetime_electron_singleChannel_veto == null) {
		lifetime_electron_singleChannel_veto = "";
	}
	TreeMap<String,String> muon_channelsRequireInfo = new TreeMap<String,String>();
	TreeMap<String,String> muon_channelsVetoInfo = new TreeMap<String,String>();
	TreeMap<String,String> electron_channelsRequireInfo = new TreeMap<String,String>();
	TreeMap<String,String> electron_channelsVetoInfo = new TreeMap<String,String>();
	boolean electronEnabled = false;
	for (Iterator it= availableChannels.iterator(); it.hasNext();) {
		String chan = it.next().toString();
		if (lifetime_muon_singleChannel_require.indexOf(chan) != -1) {
			muon_channelsRequireInfo.put(chan, "checked");
		} else {
			muon_channelsRequireInfo.put(chan, "");
		}
		if (lifetime_muon_singleChannel_veto.indexOf(chan) != -1) {
			muon_channelsVetoInfo.put(chan, "checked");
		} else {
			muon_channelsVetoInfo.put(chan, "");
		}
		if (lifetime_electron_singleChannel_require.indexOf(chan) != -1) {
			electron_channelsRequireInfo.put(chan, "checked");
			electronEnabled = true;
		} else {
			electron_channelsRequireInfo.put(chan, "");
		}
		if (lifetime_electron_singleChannel_veto.indexOf(chan) != -1) {
			electron_channelsVetoInfo.put(chan, "checked");
		} else {
			electron_channelsVetoInfo.put(chan, "");
		}		
	}
	request.setAttribute("availableChannelsSize", availableChannels.size());
	request.setAttribute("muon_validChannelsRequire", muon_channelsRequireInfo);
	request.setAttribute("muon_validChannelsVeto", muon_channelsVetoInfo);
	request.setAttribute("electron_validChannelsRequire", electron_channelsRequireInfo);
	request.setAttribute("electron_validChannelsVeto", electron_channelsVetoInfo);
	
%>
<script type="text/javascript" src="../analysis-lifetime-advanced/controls.js"></script>		
<div id="analysis-controls">
	<form method="post" action="../analysis-lifetime-advanced/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
					
		<p>
			<e:tr name="I2U2.Cosmic::LifetimeStudyAdvanced">
				<e:vswitch revert="true">
					<e:visible>
						<strong>Analysis Controls</strong> 
					</e:visible>
					<e:hidden>
						<strong>Analysis Controls</strong>
						<table>
							<tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_gatewidth" name="Gate Width (seconds)">Gate width (seconds):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="lifetime_gatewidth" size="8" default="1e-4"
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
			<e:tr name="I2U2.Cosmic::Plot">
						<table>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_semilog" name="Semi-log Plot">Semi-log Plot:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trselect name="plot_semilog" valueList="1, 0" labelList="Yes, No"
										default="0"/>								
								</td>
							</tr>
							</table>
			</e:tr>
			<e:tr name="I2U2.Cosmic::LifetimeStudyAdvanced">
					<e:vswitch revert="${param.submit == 'Change'}">
					<e:visible>
						<strong>Define the muon</strong> 
					</e:visible>
					<e:hidden>
						<strong>Define the muon</strong>					
						<table>						
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_muon_coincidence" name="Muon Channel Coincidence">Muon Channel Coincidence:</e:trlabel>
								</td>
								<td class="form-control">								
									<e:trselect name="lifetime_muon_coincidence" 
										valueList="1, 2, 3, 4" labelList="1, 2, 3, 4" default="2"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_muon_gate" name="Muon Event Gate">Muon Event Gate (ns):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="lifetime_muon_gate" id="lifetime_muon_gate" size="8" default="250"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_muon_softTriggers" name="Muon Soft Triggers">Muon Soft Triggers?</e:trlabel>
								</td>
								<td></td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="lifetime_muon_softTriggersRequireControls" name="Muon RequireChannelLabel">Muon Require Channels:</label>
								</td>
								<td>
									<div id="lifetime_muon_softTriggersRequireControls" style="text-align: left;">
										<c:forEach items="${muon_validChannelsRequire }" var="vcr">
											${vcr.key} <input type="checkbox" name="lifetime_muon_singleChannel_require${vcr.key}" id="lifetime_muon_require${vcr.key}" ${vcr.value }>											
										</c:forEach>
									</div>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="lifetime_muon_softTriggersVetoControls" name="Muon VetoChannelLabel">Muon Veto Channels:</label>
								</td>
								<td>
									<div id="lifetime_muon_softTriggersVetoControls" style="text-align: left;">
										<c:forEach items="${muon_validChannelsVeto }" var="vcv">
											${vcv.key}  <input type="checkbox" name="lifetime_muon_singleChannel_veto${vcv.key}" id="lifetime_muon_veto${vcv.key}" ${vcv.value }>											
										</c:forEach>
									</div>
								</td>
							</tr>
						</table>
					</e:hidden>
					</e:vswitch>
					<e:vswitch revert="${param.submit == 'Change'}">
					<e:visible>
						<strong>Define the electron</strong> 
					</e:visible>
					<e:hidden>
						<strong>Define the electron</strong>					
						<table>						
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_electron_coincidence" name="Electron Channel Coincidence">Electron Channel Coincidence:</e:trlabel>
								</td>
								<td class="form-control">								
									<e:trselect name="lifetime_electron_coincidence" 
										valueList="1, 2, 3, 4" labelList="1, 2, 3, 4" default="1"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_electron_gate" name="Electron Event Gate">Electron Event Gate (ns):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="lifetime_electron_gate" id="lifetime_electron_gate" size="8" default="100"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_electron_softTriggers" name="Electron Soft Triggers">Electron Soft Triggers?</e:trlabel>
								</td>
								<td></td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="lifetime_electron_softTriggersRequireControls" name="Electron RequireChannelLabel">Electron Enable Channels:</label>
								</td>
								<td>
									<div id="lifetime_electron_softTriggersRequireControls" style="text-align: left;">
										<c:forEach items="${electron_validChannelsRequire }" var="vcr">
											${vcr.key} <input type="checkbox" name="lifetime_electron_singleChannel_require${vcr.key}" id="lifetime_electron_require${vcr.key}" ${vcr.value }>											
										</c:forEach>
									</div>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="lifetime_electron_softTriggersVetoControls" name="Electron VetoChannelLabel">Electron Veto Channels:</label>
								</td>
								<td>
									<div id="lifetime_electron_softTriggersVetoControls" style="text-align: left;">
										<c:forEach items="${electron_validChannelsVeto }" var="vcv">
											${vcv.key}  <input type="checkbox" name="lifetime_electron_singleChannel_veto${vcv.key}" id="lifetime_electron_veto${vcv.key}" ${vcv.value }>											
										</c:forEach>
									</div>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="lifetime_minimum_delay" name="Minimum Delay">Minimum Delay (ns):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="lifetime_minimum_delay" id="lifetime_minimum_delay" size="8" default="300"
										onError="Must be an integer"/>
								</td>
							</tr>
						</table>
					</e:hidden>
					</e:vswitch>
			</e:tr>
		</p>
		<p>
			<e:tr name="I2U2.Cosmic::Plot">
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
									</e:default></e:trtextarea>									

								</td>
							</tr>
						</table>
					</e:hidden>
				</e:vswitch>
			</e:tr>
			<e:tr name="I2U2.Cosmic::LifetimeStudyAdvanced">
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
		<p>
      <!-- EPeronja-10/17/2013: THRESHOLD TEST only in this branch!!! for test purposes-->
      <div style="display:none;">
			 <input type="radio" name="thresholdfile" value="none">Recreate TT file.<br />
			 <input type="radio" name="thresholdfile" value="static" checked="true">Use Static TT file.<br />
		  </div>
		</p>	
		<%@ include file="../analysis/controls.jsp" %>
		<p>
			<!-- this MUST be used if all the elab:tr* stuff is to work                      -->
			<!-- it ensures that the name of the submit button is the right thing ("submit") -->
			<e:trsubmit/>
		</p>
	</form>
	<div id="message"></div>
</div>