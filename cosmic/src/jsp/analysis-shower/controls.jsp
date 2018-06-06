<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>
<script>
$(document).ready(function () {
	   $("input[name='deltaTIDs']").change(function () {
			var checkboxes = document.getElementsByName("deltaTIDs");
			var rightCount = 2;
			var cnt = $("input[name='deltaTIDs']:checked").length;
	      	if (cnt > rightCount) {
	      		$(this).prop("checked", "");
	      		alert("Please unselect a DAQ. Total selected should be 2.")
		    }
	  });
	});
</script>
<%
	//build set of detector id locations
	ResultSet rs = elab.getDataCatalogProvider().getEntries(analysis.getParameterValues("rawData"));
	Map detectors = new TreeMap();
	Map<String,String> deltaTIDs = new TreeMap<String,String>();
	Iterator i = rs.iterator();
    int ndx = 0;
	while (i.hasNext()) {
	    CatalogEntry e = (CatalogEntry) i.next();
	    String did = (String) e.getTupleValue("detectorid");
	    detectors.put(did, e.getTupleValue("school") + ", " + e.getTupleValue("city") + ", " 
	            + e.getTupleValue("state") + " (" + did + ")");
		if (ndx < 2) {
			deltaTIDs.put(did, "checked");
		} else {
			deltaTIDs.put(did, "");			
		}
		ndx++;
	}
	String[] analysisDT = (String[]) analysis.getAttribute("deltaTIDs");
   	if ( analysisDT != null) {
   		analysisDT = (String[]) analysis.getAttribute("deltaTIDs");
   	    	for(Map.Entry<String,String> entry : deltaTIDs.entrySet()) {
   	    		  if (entry.getKey().equals(analysisDT[0]) || entry.getKey().equals(analysisDT[1])) {
   	    			  entry.setValue("checked");
   	    		  } else {
   	    			  entry.setValue("");
   	    		  }
   	    	}
   	}
	request.setAttribute("deltaTIDs", deltaTIDs);
	request.setAttribute("detectors", detectors);
%>

<div id="analysis-controls">
	<form method="post" action="../analysis-shower/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
		<e:trinput type="hidden" name="eventNum" default="0"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
		<p>
			<e:tr name="I2U2.Cosmic::ShowerStudy">
				<e:vswitch revert="true">
					<e:visible>
						<strong>Analysis Controls</strong> 
					</e:visible>
					<e:hidden>
						<strong>Analysis Controls</strong>
						<table>
							<tr>
								<td class="form-label">
									<e:trlabel for="zeroZeroZeroID" name="Center of graph view">Center of graph view:</e:trlabel>
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
									<e:trinput type="text" name="gate" size="8" default="100"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="detectorCoincidence" name="Detector Coincidence">Detector Coincidence:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="detectorCoincidence" size="8" default="1"
										onError="Must be a positive integer"/>
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
								<td class="form-label">
									<e:trlabel for="eventCoincidence" name="Coincidence Level">Hit Coincidence:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="eventCoincidence" size="8" default="2"
										onError="Must be an integer"/>
								</td>
							</tr>
								<tr>
									<td class="form-label">
										<label for="deltaTIDs" name="deltaTIDs">Delta T DAQs:</label>
									</td>
									<td>
										<div id="deltaTdiv" style="text-align: left;">
											<c:forEach items="${deltaTIDs }" var="deltaTID">
												<c:choose>
													<c:when test='${deltaTID.value == "checked" }'>
														${deltaTID.key} <input type="checkbox" name="deltaTIDs" id="deltaT${deltaTID.key}" value="${deltaTID.key}" checked>
													</c:when>
													<c:otherwise>
														${deltaTID.key} <input type="checkbox" name="deltaTIDs" id="deltaT${deltaTID.key}" value="${deltaTID.key}">
													</c:otherwise>		
												</c:choose>									
											</c:forEach>
										</div>
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
									<e:trlabel for="plot_lowZ" name="Z-min">Z-min:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_lowZ" size="8" maxlength="8"
										onError="Must be an integer"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="plot_highZ" name="Z-max">Z-max:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="plot_highZ" size="8" maxlength="8"
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
										default="Shower Study"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<label for="plot_caption">Figure caption:</label>
								</td>
								<td class="form-control">
									<e:trtextarea name="plot_caption" rows="5" cols="30"><e:default>
<%= DataTools.getFigureCaption(elab, ((ElabAnalysis) request.getAttribute("analysis")).getParameterValues("rawData")) %>
<e:analysisParamLabel name="zeroZeroZeroID"/>
<e:analysisParamLabel name="detectorCoincidence"/>
<e:analysisParamLabel name="channelCoincidence" />
<e:analysisParamLabel name="eventCoincidence"/>
<e:analysisParamLabel name="gate"/>
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
			<!-- this MUST be used if all the elab:tr* stuff is to work                      -->
			<!-- it ensures that the name of the submit button is the right thing ("submit") -->
			<e:trsubmit/>
		</p>
	</form>
</div>