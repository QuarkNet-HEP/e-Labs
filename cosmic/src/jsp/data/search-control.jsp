<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<% 
SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
DATEFORMAT.setLenient(false);
String msg = (String) request.getAttribute("msg");
boolean allowAllDataAccess = false;
if (!user.getName().equals("guest")) {
	int teacherId = user.getTeacherId();
	allowAllDataAccess = elab.getUserManagementProvider().getDataAccessPermission(teacherId);
	if (user.isAdmin()) {
		allowAllDataAccess = true;
	}
}
allowAllDataAccess = true;

//set the calendar to a month prior by default 
//the criteria to retrieve datafiles will probably change but we need some type of range otherwise
//we will be retrieving all the files.
Calendar cal = Calendar.getInstance();
  cal.setTime(new Date());
  cal.add(Calendar.DATE, 1);    
Calendar fromMonth = Calendar.getInstance();
fromMonth.add(Calendar.MONTH,-3);       
request.setAttribute("fromMonth", fromMonth);
request.setAttribute("allowAllDataAccess", allowAllDataAccess);
%>
<script type="text/javascript">
$(function() {
	var calendarParam = {
			showOn: 'button', 
			buttonImage: '../graphics/calendar-blue.png',
			buttonImageOnly: true, 
			changeMonth: true,
			changeYear: true, 
			showButtonPanel: true,
			minDate: new Date(2000, 11-1, 30), // Earliest known date of data - probably should progamatically find. 
			maxDate: new Date() // Should not look later than today
	};
	$('.datepicker').datepicker(calendarParam);
	$("#data1").datepicker('option', 'buttonText', 'Choose start date.');
	$("#data2").datepicker('option', 'buttonText', 'Choose start date.');
	$('img.ui-datepicker-trigger').css('vertical-align', 'text-bottom'); 
});
$(window).scroll(function(){
	$('#right').animate({top:$(window).scrollTop()+"px" },{queue: false, duration: 0});
});

</script>

<div class="search-quick-links">Quick Searches (last 3 months):
  <a href="?submit=true&key=group&value=${user.name}&date1=<%=DATEFORMAT.format(fromMonth.getTime())%>">${user.name}</a>,
  <a href="?submit=true&key=teacher&value=<%= user.getTeacher() %>&date1=<%=DATEFORMAT.format(fromMonth.getTime())%>"><%= user.getTeacher() %></a>,
  <a href="?submit=true&key=school&value=${user.group.school}&date1=<%=DATEFORMAT.format(fromMonth.getTime())%>">${user.group.school}</a>,
  <a href="?submit=true&key=city&value=${user.group.city}&date1=<%=DATEFORMAT.format(fromMonth.getTime())%>">${user.group.city}</a>,
  <a href="?submit=true&key=state&value=${user.group.state}&date1=<%=DATEFORMAT.format(fromMonth.getTime())%>">${user.group.state}</a>
</div>

<form name="search" method="get">
	<e:select name="key" id="selectOptions" valueList="city, group, school, state, teacher, detectorid"
		        labelList="City, Group, School, State/Country, Teacher, Detector ID"
		        default="${param.key}"/>
	<input name="value" id="name" size="40" maxlength="40" value="${param.value}" />
	<input type="submit" name="submit" value="Search Data" />

	<e:vswitch>
		<e:visible image="../graphics/Tright.gif">
			Advanced Search 
		</e:visible>
		<e:hidden image="../graphics/Tdown.gif">
			Advanced Search
			<table class="form-controls">
				<tr>
					<td colspan="2">
					Please enter dates in MM/dd/yyyy format (e.g. <%= DATEFORMAT.format(new Date()) %>).<br />
					You may leave one or both date fields blank.<br />
					</td>
				</tr>
				<tr>
					<td align="right">
						<select name="datetype">
						    <option value="startdate" selected>Start Date</option>
						    <option value="creationdate">Upload Date</option>
						</select>
					</td>
					<td>
					  <% if (request.getParameter("date1") == null)  {%>
  						 <e:trinput name="date1" id="date1" size="10" maxlength="15" class="datepicker" value="<%=DATEFORMAT.format(fromMonth.getTime()) %>"/>
  					<% } else { %>           
  					   <e:trinput name="date1" id="date1" size="10" maxlength="15" class="datepicker" />
  					<% } %>
						to
						<e:trinput name="date2" id="date2" size="10" maxlength="15" class="datepicker"/>
					</td>
				</tr>
				<!-- 
				<tr>
					<td align="right">
						<e:select name="sortDirection" valueList="sortAsc, sortDesc" labelList="Sort Ascending, Sort Descending"/>
					</td>
					<td>
						by
						<e:select name="sortField" valueList="city, state, stacked, blessed, group, year, detectorid, creationdate, chan1, chan2, chan3, chan4"
							labelList="City, State, Geometry, Blessed, Group, Academic Year, Detector ID, Upload Date, Channel 1 events, Channel 2 events, Channel 3 events, Channel 4 events"/>
					</td>
				</tr>
				-->
				<tr>
					<td align="right" valign="middle">
					    Search:
					</td>
					<td>
				    	<input type="radio" name="searchIn" value="all" checked="true" />All data
					    <input type="radio" name="searchIn" value="within"/ >Refine results with extra parameters
					</td>
				</tr>
				<tr>
					<td>
						Stacked:
						<e:select name="stacked" valueList="all, yes, no" labelList="All, Yes, No"/>
					</td>
					<td>
						<c:choose>
							<c:when test="${allowAllDataAccess == true}">
								Blessed:
								<e:select name="blessed" valueList="all, yes, no" labelList="All, Yes, No"/>
							</c:when>
						</c:choose>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
	<br />
	<a href="cosmic-data-map.jsp?submitToPage=search.jsp">
	 <img src="../graphics/world.png" height="25px" width="25px" /><br />
	 View and Search from detector map
	</a>
	<br /><br />
  <div><i>* To speed up searches by default we are retrieving the last 3 months worth of data for the criteria you chose.<br />
          You can modify your date range using the Advanced Search criteria.
      </i></div> 
	<div id="msg" name="msg">${msg}</div>	
	<br />
	<%
		//variables used in metadata searches:
		String key = request.getParameter("key");
		String value = request.getParameter("value");
		String date1 = request.getParameter("date1");
		String date2 = request.getParameter("date2");
		String stacked = request.getParameter("stacked");
		String blessed = request.getParameter("blessed");
		
		boolean submit = StringUtils.isNotBlank(request.getParameter("submit"));
		boolean submitFromMap = StringUtils.isNotBlank(request.getParameter("submitFromMap"));
		
		if (StringUtils.isBlank(key)) key="all";
		
		/* Data sortation is never even used? 
		   String sortDirection = request.getParameter("sortDirection");
		   String order = request.getParameter("sortField");
		   if (StringUtils.isBlank(order)) order = "startdate"; 
		   if (StringUtils.isBlank(sortDirection)) sortDirection = "sortAsc";
		*/
		
		ResultSet searchResults = null;
		StructuredResultSet searchResultsStructured = null;
		if (submit || submitFromMap) {
			
			//EPeronja-06/12/2013: 63: Data search by state requires 2-letter state abbreviation
			String abbreviation = "";
			if (key.equals("state")) {
				abbreviation = DataTools.checkStateSearch(elab, value);
				if (!abbreviation.equals("")) {
					value = abbreviation;
				} else {
					msg = "<i>*"+value+" does not exist. Please enter a valid state abbreviation (ie: Florida, FLORIDA, fl, FL)</i>";
				}
			}
		    long start = System.currentTimeMillis();
		    
		    /* For performance reasons, order of insertion into this In 
		     * predicate matters. Elements should be added in order of decreasing
		     * set size 
		     */ 
		     
		    In and = new In();
		    
		    and.add(new Equals("project", elab.getName()));
		    and.add(new Equals("type", "split"));
		    //EPeronja-08/05/2013 284: Data search within results don't have any hooks --> fixed
			if ("within".equals(request.getParameter("searchIn"))) {
				MultiQueryElement ql = (MultiQueryElement) session.getAttribute("previousSearch");
				Collection elements =  ql.getAll();
				Iterator iterator = elements.iterator();
				while (iterator.hasNext()) {
					and.add((QueryElement) iterator.next());
				}
			}
			
			if ("yes".equals(stacked)) {
		    	and.add(new Equals("stacked", Boolean.TRUE));
		    }
		    if ("no".equals(stacked)) {
		    	and.add(new Equals("stacked", Boolean.FALSE));
		    }
					    		    
		 	// Date bounds are only needed if specified   
		    String datetype = request.getParameter("datetype");
			if (StringUtils.isNotBlank(date1) || StringUtils.isNotBlank(date2)) {
				// In case someone makes their own search string and forgets the date type 
				if (StringUtils.isBlank(datetype)) datetype = "startdate"; 
				
				try {
					Date startDate = null, endDate = null; 
					
					if (StringUtils.isNotBlank(date1)) {
						startDate = DATEFORMAT.parse(date1); 
					}
					if (StringUtils.isNotBlank(date2)) {
						endDate = DATEFORMAT.parse(date2);
						endDate.setHours(23); 
						endDate.setMinutes(59);
						endDate.setSeconds(59);
					}
				
					// Start date undefined, therefore less or equal to the end date just before midnight
					if (StringUtils.isBlank(date1)) {
						and.add(new LessOrEqual(datetype, endDate));
					}
					
					// End date undefined, therefore greater than or equal to the start date
					else if (StringUtils.isBlank(date2)) {
						and.add(new GreaterOrEqual(datetype, startDate));
					}
					// Date range 
					else {
						and.add(new Between(datetype, startDate, endDate));
					}
				}
				catch (Exception ex) {
					%> 
					<h3>At least one of the dates you typed in was not understood. Please re-check the dates you typed in.</h3>
					<%
					return; 
				}
			}
		    
		 	// Allow use of asterisk wildcards, remove leading/trailing whitespace 
			if (StringUtils.isNotBlank(value) && !key.equals("all")) {
				value = value.replace('*', '%').trim();
				and.add(new Like(key, value)); 
			}
		    //EPeronja-21/11/2013: Benchmark, default search retrieves all owner's data + others' blessed data
			String benchmarksearch = "default";		    
		    if ("yes".equals(blessed)) {
		    	and.add(new Equals("blessed", Boolean.TRUE));
				benchmarksearch = "";
		    }
		    if ("no".equals(blessed)) {
		    	and.add(new Equals("blessed", Boolean.FALSE));
				benchmarksearch = "";
		    }
			if ("all".equals(blessed)) {
				benchmarksearch = "";
			}		 	
			searchResults = elab.getDataCatalogProvider().runQuery(and);
			session.setAttribute("previousSearch", and);
			searchResultsStructured = DataTools.organizeSearchResults(searchResults, benchmarksearch, user.getName(), user.getGroup().getTeacher());
			searchResultsStructured.setKey(key);
			searchResultsStructured.setValue(value);
			long end = System.currentTimeMillis();
			String time = ElabUtil.formatTime(end - start);
			searchResultsStructured.setTime(time);
			
		}
		else {
			session.setAttribute("previousSearch", null);
		    //DataCatalogProvider dcp = elab.getDataCatalogProvider();
			//int fileCount = dcp.getUniqueCategoryCount("split");
			//int schoolCount = dcp.getUniqueCategoryCount("school");
			//int stateCount = dcp.getUniqueCategoryCount("state");
			String fileCount = (String) session.getAttribute("cosmicFileCount");
			String schoolCount = (String) session.getAttribute("cosmicSchoolCount");
			String stateCount = (String) session.getAttribute("cosmicStateCount");
	
			%>
			<p>
		 		Searching <%= fileCount %> data files from <%= schoolCount %> schools in 
				<%= stateCount %> states.
			</p>
			<%
		}
		request.setAttribute("msg", msg);			
		request.setAttribute("searchResults", searchResults);
		request.setAttribute("searchResultsStructured", searchResultsStructured);
	%>
</form>

