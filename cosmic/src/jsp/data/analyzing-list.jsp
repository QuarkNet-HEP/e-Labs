<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<%
	ElabAnalysis analysis = (ElabAnalysis) request.getAttribute(gov.fnal.elab.tags.Analysis.ATTR_ANALYSIS);
	Collection f = analysis.getParameterValues("rawData");
    //EPeronja-06/05/2013: Bug 316-Removing datafiles from analyses reset the bin width to the default
    //                     Not anymore.
	Collection bin_width = analysis.getParameterValues("flux_binWidth");
	
	if (request.getParameter("remove") != null) {
		String[] r = request.getParameterValues("remfile");
		request.setAttribute("remfiles", r);
		Set s = new HashSet();
		for (int i = 0; i < r.length; i++) {
			s.add(r[i]);
		}
		Iterator j = f.iterator();
		while (j.hasNext()) {
			String rf = (String) j.next();
			if (s.contains(rf)) {
				j.remove();
			}
		}
		ElabAnalysis newAnalysis = ElabFactory.newElabAnalysis(elab, null, null);
		newAnalysis.setType(analysis.getType());
		newAnalysis.setParameter("rawData", f);
		//EPeronja-06/05/2013: Bug 316-Keeping the bin width from the study
		newAnalysis.setParameter("flux_binWidth", bin_width);
		request.setAttribute(gov.fnal.elab.tags.Analysis.ATTR_ANALYSIS, newAnalysis);
		request.setAttribute("analysis", newAnalysis);
	}
	ResultSet rs = elab.getDataCatalogProvider().getEntries(f);
	request.setAttribute("count", new Integer(f.size()));
%>
<div id="analyzing-ist">
<form method="post" id="remove-form">
<c:forEach items="${remfiles}" var="r">
	<input type="hidden" name="remfile" value="${r}" />
</c:forEach>
<table colspace="4" border="0" width="100%">
	<tbody>
		<tr>
		    <td align="center">DAQ#</td>
			<td align="center">You're analyzing...</td>
			<td align="center">Chan1 events</td>
			<td align="center">Chan2 events</td>
			<td align="center">Chan3 events</td>
			<td align="center">Chan4 events</td>
			<td colspan="3" align="center">Raw Data</td>
			<c:if test="${count > 1}">
				<td align="center">Remove from analysis</td>
			</c:if>
		</tr>
		<c:forEach items="${missing}" var="m">
			<tr>
				<td>${m} not found</td>
			</tr> 
		</c:forEach>
		<%
			//variables provided for the page including this file
			HashSet detectorIDs = new HashSet();
			boolean[] validChans = new boolean[4];
			int chanTotal[] = new int[4];
			int allChanTotal = 0;
			Date startdate = null;
			Date enddate = null;
			
			//strings that are used for information on the plots
			String rawDataString = "Data: ";
			String detectorIDString = "Detector(s): ";
			String queryFilenames = "";
			
			//for using with other analysis pages
			String filenames_str = "";
			
			//number of files. Initially display the top 10
			int num_files = 0;
			SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy HH:mm:ss");
			//sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
			SimpleDateFormat sef = new SimpleDateFormat("MM/dd/yyyy H:mm");
			//Since we're using Java classes and don't know what class instance to call,
			// some kind of common variable needs to be setup for this page to reference.
			// Since we're listing raw data files, use the variable "rawData".
			for (Iterator i = rs.iterator(); i.hasNext(); ) {
			    CatalogEntry e = (CatalogEntry) i.next();
			    String lfn = e.getLFN();
			
			    if(e.getTuples().size() == 0){
			        %> 
			        	<tr><td><span class="error">Missing file: <%= lfn %></span></td></tr>
			        <%
			        continue;
			    }
			
			    //create a string of the date for the file and find start and end date
			    Date fileStartDate = (Date) e.getTupleValue("startdate");
			    Date fileEndDate = (Date) e.getTupleValue("enddate");
			    String filedate = sdf.format(fileStartDate);
			    filedate = filedate.replaceAll(" ", "&nbsp;");
			    
			    if(startdate == null || startdate.after(fileStartDate)){
			        startdate = fileStartDate;
			    }
			    if(enddate == null || enddate.before(fileEndDate)){
			        enddate = fileEndDate;
			    }
			
			    //create a string of filenames to send to rawanalyzeMultiple for comparison
			    queryFilenames += "f=" + lfn + "&";
			
			    //create a string of rawData files delimited by commas
			    rawDataString += filedate + ", ";
			
			    //raw data string for use in passing to other analysis pages
			    filenames_str += "&f=" + lfn;
			
			    //create a list of detector IDs delimited by commas
			    detectorIDString += e.getTupleValue("detectorid") + ", ";
			
			    //variables provided for calling page
			    detectorIDs.add(e.getTupleValue("detectorid"));
			    
			    //channel events
			    int chan[] = new int[4];
			    for (int j = 0; j < 4; j++) {
			    	Long l = (Long) e.getTupleValue("chan" + (j + 1));
			    	if (l == null) {
			    		chan[j] = 0;
			    	}
			    	else {
			    		chan[j] = l.intValue();
			    	}
			    	validChans[j] = chan[j] > 0 || validChans[j];
			    	chanTotal[j] += chan[j];
			    	allChanTotal += chan[j];
			    }
			
			    //set variables from metadata
			    String city = (String) e.getTupleValue("city");
			    String school = (String) e.getTupleValue("school");
			    school = school.replaceAll(" ", "&nbsp;");
			    String group = (String) e.getTupleValue("group");
			    String detector = (String) e.getTupleValue("detectorid");
			    String title = city + ", " + group + ", Detector: " + detector;
			
			    if (num_files == 10) {
			        out.println("</tbody><tbody id=\"tog2\" style=\"display:none\">");
			    }
			
			    //row classes
			    String r_class = "";
			    if (num_files%2 == 0) {
			        r_class = "even";
			    }
			    else{
			        r_class = "odd";
			    }
			
			    num_files++;    //add a count
			
				%>
				    <tr class="<%=r_class%>">
				    	<td align-"center"><%= detector %></td>
				        <td align="center">
				            <%= school %>&nbsp;<%= filedate %>&nbsp;UTC
				        </td>
				        <td align=center><%=chan[0]%></td>
				        <td align=center><%=chan[1]%></td>
				        <td align=center><%=chan[2]%></td>
				        <td align=center><%=chan[3]%></td>
				        <td bgcolor="#EFEFFF" align="center"><a title="<%=title%>" href="../data/view.jsp?filename=<%=lfn%>">View</a>&nbsp</td>
				        <td bgcolor="#EFFEDE" align="center"><a href="../analysis-raw-single/analysis.jsp?submit=true&filename=<%=lfn%>">Statistics</a></td>
				        <td bgcolor="#EFFEDE" align="center"><a href="../geometry/view.jsp?filename=<%=lfn%>">Geometry</a></td>
				        <c:if test="${count > 1}">
				            <td align=center><input name="remfile" type="checkbox" value="<%=lfn%>"></td>
				        </c:if>
				    </tr>
				<%
			}
			if (startdate != null) {
				request.setAttribute("startDate", sef.format(startdate));
				if (enddate == null) {
					enddate = startdate;
				}
				request.setAttribute("endDate", sef.format(enddate));
			}
			//trim off extra ", " in Strings
			rawDataString = rawDataString.substring(0, rawDataString.length()-2);
			detectorIDString = detectorIDString.substring(0, detectorIDString.length() - 2);
			//trim off last "&"
			if (queryFilenames.length() > 0) {
				queryFilenames = queryFilenames.substring(0, queryFilenames.length() - 1);
			}
			//get total events in all chans
			
			//only show "show more files" link if there's more files to show...
			if(num_files > 10){
				%>
		</tbody>
		<tbody>
		<tr>
			<td></td>
		    <td colspan="1" align="center">
			    <a href="#" id="tog1" onclick="toggle('tog1', 'tog2', '...show more files', 'show fewer files...')">...show more files</a></td>
		    <td colspan="8"></td>
		</tr>
				<%
			}
				%>
		<tr>
			<td></td>
		    <td align="center">
		        <font color="grey">Total (<%=num_files%> files <%=allChanTotal%> events)</font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chanTotal[0]%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chanTotal[1]%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chanTotal[2]%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chanTotal[3]%></font>
		    </td>
		    <td colspan="2" align="center">
	    	    <a href="../analysis-raw-multiple/analysis.jsp?submit=true&<%=queryFilenames%>">Compare files</a>
		    </td>
		    <c:if test="${count > 1}">
			    <!--  allow removal of files if analyzing more than one -->
	        	<td colspan="7" align="center">
	            	<input name="remove" type="submit" value="Remove" />
		        </td>
			</c:if>
		</tr>
	</tbody>
</table>
</form>
</div>