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
%>
<script type="text/javascript" src="../analysis-shower-hybrid/controls.js"></script>		
<div id="analysis-controls">
	<form method="post" action="../analysis-shower-hybrid/analysis.jsp">
		<e:trinput type="hidden" name="rawData"/>
	
		<p>Click <strong>Analyze</strong> to use the default parameters. 
		Control the analysis by expanding the options below.</p>
					
		<p>
			<e:tr name="I2U2.Cosmic::ShowerLifetimeHybridStudy">
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
									<e:trlabel for="hybrid_gatewidth" name="Gate Width (seconds)">Gate width (seconds):</e:trlabel>
								</td>
								<td class="form-control">
									<e:trinput type="text" name="hybrid_gatewidth" size="8" default="2e-5"
										onError="Must be an integer or number of the form (2e-5)"/>
								</td>
							</tr>
							<tr>
								<td class="form-label">
									<e:trlabel for="channel_coincidence" name="Channel Coincidence">Channel Coincidence:</e:trlabel>
								</td>
								<td class="form-control">
									<e:trselect name="channel_coincidence" 
										valueList="1, 2, 3, 4" labelList="1, 2, 3, 4" default="2"/>
								</td>
							</tr>						</table>
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