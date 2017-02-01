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
	String channelsRequire = (String) analysis.getParameter("singleChannel_require");
	String channelsVeto = (String) analysis.getParameter("singleChannel_veto");
	if (channelsRequire == null) {
		channelsRequire = "";
	}
	if (channelsVeto == null) {
		channelsVeto = "";
	}
	TreeMap<String,String> channelsRequireInfo = new TreeMap<String,String>();
	TreeMap<String,String> channelsVetoInfo = new TreeMap<String,String>();
	for (Iterator it= availableChannels.iterator(); it.hasNext();) {
		String chan = it.next().toString();
		if (channelsRequire.indexOf(chan) != -1) {
			channelsRequireInfo.put(chan, "checked");
		} else {
			channelsRequireInfo.put(chan, "");
		}
		if (channelsVeto.indexOf(chan) != -1) {
			channelsVetoInfo.put(chan, "checked");
		} else {
			channelsVetoInfo.put(chan, "");
		}
	}
	
	request.setAttribute("availableChannelsSize", availableChannels.size());
	request.setAttribute("validChannelsRequire", channelsRequireInfo);
	request.setAttribute("validChannelsVeto", channelsVetoInfo);
	
%>
<script type="text/javascript" src="../include/jquery/flot083/jquery.js"></script>		
<script type="text/javascript" src="../analysis-timeofflight/controls.js"></script>		
<script type="text/javascript" src="../include/elab.js"></script>	

<c:choose>
	<c:when test="${availableChannelsSize > 1 }">
	<div id="analysis-controls">
		<form method="post" action="../analysis-timeofflight/analysis.jsp">
			<e:trinput type="hidden" name="rawData"/>
			<e:trinput type="hidden" name="eventNum" default="0"/>
		
			<p>Click <strong>Analyze</strong> to use the default parameters. 
			Control the analysis by expanding the options below.</p>
			<p>
				<e:tr name="I2U2.Cosmic::TimeOfFlight">
					<e:vswitch revert="true">
						<e:visible>
							<strong>Analysis Controls</strong> 
						</e:visible>
						<e:hidden>
							<strong>Analysis Controls</strong>
							<table>
								<tr>
									<td class="form-label">
										<e:trlabel for="zeroZeroZeroID" name="Center of graph view">Location:</e:trlabel>
									</td>
									<td class="form-control">
										<e:trselect name="zeroZeroZeroID" 
											valueList="<%= detectors.keySet() %>" labelList="<%= detectors.values() %>"/>
									</td>
								</tr>
								<tr>
									<td class="form-label">
										<e:trlabel for="gate" name="Event Gate">Event Gate (ns):</e:trlabel>
									</td>
									<td class="form-control">
										<e:trinput type="text" name="gate" size="8" default="500"
											onError="Must be an integer"/>
									</td>
								</tr>
								<tr>
									<td class="form-label">
										<e:trlabel for="channelCoincidence" name="Channel Coincidence">Channel Coincidence:</e:trlabel>
									</td>
									<td class="form-control">
										<e:trinput type="text" name="channelCoincidence" size="8" default="2"
											onError="Must be a positive integer"/>
									</td>
								</tr>
								<tr>
								   <td><a href="javascript:glossary('soft_triggers',350)"><img src="../graphics/question.gif"></a>Define Soft Triggers</td>
								<%-- 
									<td class="form-label">
										<e:trlabel for="softTriggers" name="Soft Triggers">Define Soft Triggers?</e:trlabel>
									</td>
								--%>	
									<td></td>
								
								</tr>
								<tr>
									
									<td class="form-label">
										<label for="softTriggersRequireControls" name="RequireChannelLabel">Require Channels:</label>
									</td>
									<td>
										<div id="softTriggersRequireControls" style="text-align: left;">
											<c:forEach items="${validChannelsRequire }" var="vcr">
												${vcr.key} <input type="checkbox" name="singleChannel_require${vcr.key}" id="require${vcr.key}" ${vcr.value }>											
											</c:forEach>
										</div>
									</td>
								</tr>
								<tr>
									<td class="form-label">
										<label for="softTriggersVetoControls" name="VetoChannelLabel">Veto Channels:</label>
									</td>
									<td>
										<div id="softTriggersVetoControls" style="text-align: left;">
											<c:forEach items="${validChannelsVeto }" var="vcv">
												${vcv.key}  <input type="checkbox" name="singleChannel_veto${vcv.key}" id="veto${vcv.key}" ${vcv.value }>											
											</c:forEach>
										</div>
									</td>
								</tr>
								<input type="hidden" name="detectorCoincidence" size="8" value="1" />
								<input type="hidden" name="eventCoincidence" size="8" value="1" />
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
										<label for="plot_title">Plot Title:</label>
									</td>
									<td class="form-control">
										<e:trinput type="text" name="plot_title" size="40" maxlength="100"
											default="Time of Flight Study"/>
									</td>
								</tr>
								<tr>
									<td class="form-label">
										<label for="plot_caption">Figure caption:</label>
									</td>
									<td class="form-control">
										<e:trtextarea name="plot_caption" rows="5" cols="30">
										<e:default>
	<%= DataTools.getFigureCaption(elab, ((ElabAnalysis) request.getAttribute("analysis")).getParameterValues("rawData")) %>
	<e:analysisParamLabel name="zeroZeroZeroID"/>
	<e:analysisParamLabel name="gate"/>
	<e:analysisParamLabel name="channelCoincidence"/>
										</e:default>										
										</e:trtextarea>
									</td>
								</tr>
							</table>
						</e:hidden>
					</e:vswitch>
				</e:tr>
			</p>
			<input type="hidden" name="provider" value="swift"/>
			<table id="swift-run-mode" width="100%" align="center" >
				<tr>
					<td align="left" style="display: none;">
						<input type="radio" name="runMode" value="local" checked/> Local 
					</td>
				</tr>


				<tr>
					<td>
						<!-- this MUST be used if all the elab:tr* stuff is to work                      -->
						<!-- it ensures that the name of the submit button is the right thing ("submit") -->
						<e:trsubmit/>					
					</td>
				</tr>
			</table>
	
		</form>
	</div>
	<div id="message"></div>
</c:when>
<c:otherwise>
	<div>
		<h1>This split file does not have multiple channels on. <br />For the time of flight study we need at least two channels on.</h1>
	</div>
</c:otherwise>
</c:choose>
