<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<%
	String[] f = (String[]) request.getParameterValues("f");
	ResultSet rs = elab.getDataCatalogProvider().getEntries(f);
%>
<div id="analyzing-ist">
<table colspace=4 border="0">
	<tbody>
		<tr>
			<td align="center">You're analyzing...</td>
			<td align="center">Chan1 events</td>
			<td align="center">Chan2 events</td>
			<td align="center">Chan3 events</td>
			<td align="center">Chan4 events</td>
			<td colspan="2" align="center">Raw Data</td>
			<c:if test="${rawdata.length > 1}">
				<td align="center">Remove from analysis</td>
			</c:if>
		</tr>
		<%
			//variables provided for the page including this file
			HashSet detectorIDs = new HashSet();
			boolean[] validChans = new boolean[4];
			Date startdate = null;
			Date enddate = null;
			
			//strings that are used for information on the plots
			String rawDataString = "Data: ";
			String detectorIDString = "Detector(s): ";
			String queryFilenames = "";
			int chan1total = 0;
			int chan2total = 0;
			int chan3total = 0;
			int chan4total = 0;
			
			//for using with other analysis pages
			String filenames_str = "";
			
			//number of files. Initially display the top 10
			int num_files = 0;
			SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy H:m:s z");
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			SimpleDateFormat sef = new SimpleDateFormat("MM/dd/yyyy H:mm");
			//Since we're using Java classes and don't know what class instance to call,
			// some kind of common variable needs to be setup for this page to reference.
			// Since we're listing raw data files, use the variable "rawData".
			for (Iterator i=rs.iterator(); i.hasNext(); ){
			    CatalogEntry e = (CatalogEntry) i.next();
			    String lfn = e.getLFN();
			
			    if(e.getTuples().size() == 0){
			        %> 
			        	<tr><td><span class="error">(database problem) No file associated with: <%= lfn %></span></td></tr>
			        <%
			        continue;
			    }
			
			    //create a string of the date for the file and find start and end date
			    Date fileStartDate = (Date) e.getTupleValue("startdate");
			    Date fileEndDate = (Date) e.getTupleValue("enddate");
			    String filedate = sdf.format(fileStartDate);
			    
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
			    validChans[0] = ((Long) e.getTupleValue("chan1")).intValue() > 0 || validChans[0] ? true : false;
			    validChans[1] = ((Long) e.getTupleValue("chan2")).intValue() > 0 || validChans[1] ? true : false;
			    validChans[2] = ((Long) e.getTupleValue("chan3")).intValue() > 0 || validChans[2] ? true : false;
			    validChans[3] = ((Long) e.getTupleValue("chan4")).intValue() > 0 || validChans[3] ? true : false;
			
			    //set variables from metadata
			    String city = (String) e.getTupleValue("city");
			    String school = (String) e.getTupleValue("school");
			    String group = (String) e.getTupleValue("group");
			    String detector = (String) e.getTupleValue("detectorid");
			    String title = city + ", " + group + ", Detector: " + detector;
			    int chan1 = ((Long) e.getTupleValue("chan1")).intValue();
			    int chan2 = ((Long) e.getTupleValue("chan2")).intValue();
			    int chan3 = ((Long) e.getTupleValue("chan3")).intValue();
			    int chan4 = ((Long) e.getTupleValue("chan4")).intValue();
			    chan1total += chan1;
			    chan2total += chan2;
			    chan3total += chan3;
			    chan4total += chan4;
			
			    if(num_files == 10){
			        out.println("</tbody><tbody id=\"tog2\" style=\"display:none\">");
			    }
			
			    //row classes
			    String r_class = "";
			    if(num_files%2 == 0){
			        r_class = "even";
			    }
			    else{
			        r_class = "odd";
			    }
			
			    num_files++;    //add a count
			
				%>
				    <tr class="<%=r_class%>">
				        <td align="center">
				            <%=school%> <%=filedate%>
				        </td>
				        <td align=center><%=chan1%></td>
				        <td align=center><%=chan2%></td>
				        <td align=center><%=chan3%></td>
				        <td align=center><%=chan4%></td>
				        <td bgcolor="#EFEFFF" align=center><a title="<%=title%>" href="view.jsp?filename=<%=lfn%>&type=data&get=meta">View</a>&nbsp</td>
				        <td bgcolor="#EFFEDE" align=center><a href="rawanalyze-output.jsp?filename=<%=lfn%>">Statistics</a></td>
				        <c:if test="${rawData.size > 1}">
				            <td align=center><input name="remfile" type="checkbox" value="<%=lfn%>"></td>
				        </c:if>
				    </tr>
				<%
			}
			request.setAttribute("startDate", sef.format(startdate));
			request.setAttribute("endDate", sef.format(enddate));
			//trim off extra ", " in Strings
			rawDataString = rawDataString.substring(0, rawDataString.length()-2);
			detectorIDString = detectorIDString.substring(0, detectorIDString.length() - 2);
			//trim off last "&"
			if (queryFilenames.length() > 0) {
				queryFilenames = queryFilenames.substring(0, queryFilenames.length() - 1);
			}
			//get total events in all chans
			int allchantotal = chan1total + chan2total + chan3total + chan4total;;
			
			//only show "show more files" link if there's more files to show...
			if(num_files > 10){
				%>
	</tbody>
	<tbody>
		<tr>
		    <td colspan="1" align="center">
			    <a href="#" id="tog1" onclick="toggle('tog1', 'tog2', '...show more files', 'show less files...')">...show more files</a></td>
		    <td colspan="8"></td>
		</tr>
				<%
			}
				%>
		<tr>
		    <td align="center">
		        <font color="grey">Total (<%=num_files%> files <%=allchantotal%> events)</font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chan1total%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chan2total%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chan3total%></font>
		    </td>
		    <td align="center">
		        <font color="grey"><%=chan4total%></font>
		    </td>
		    <td colspan="2" align="center">
	    	    <a href="rawanalyze-multiple.jsp?<%=queryFilenames%>">Compare files</a>
		    </td>
		    <c:if test="${rs.size > 1}">
			    <!--  allow removal of files if analyzing more than one -->
	        	<td colspan="7" align="center">
	            	<input name="submit" type="submit" value="remove">
		        </td>
			</c:if>
		</tr>
	<tbody>
</table>
</div>