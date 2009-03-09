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
%>

<link type="text/css" href="../../js/jquery/css/themename/jquery-ui-1.7.custom.css" rel="Stylesheet" />	
<script type="text/javascript" src="../../js/jquery/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="../../js/jquery/js/jquery-ui-1.7.custom.min.js"></script>

<div class="search-quick-links">
	<e:quicksearch key="school" value="${user.group.school}"/>
	<e:quicksearch key="city" value="${user.group.city}"/>
	<e:quicksearch key="state" value="${user.group.state}"/>
	<e:quicksearch key="all" value="" label="All"/>
</div>

<form name="search" method="get">
	<e:select name="key" onChange="javascript:if (this.form.aname1.options[this.form.aname1.selectedIndex].value == 'blessed' || 
		    this.form.aname1.options[this.form.aname1.selectedIndex].value == 'stacked') {
		    this.form.input1.value = 'yes';
		} else {
		    if (this.form.input1.value == 'yes') {
		        this.form.input1.value = '';
		    }
		}" valueList="city, group, school, state, teacher, detectorid"
		        labelList="City, Group, School, State, Teacher, Detector ID"
		        default="${param.key}"/>
	<input name="value" size="40" maxlength="40" value="${param.value}" />
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
					You may leave one or both date fields blank.
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
						<e:trinput name="date1" size="10" maxlength="15" />
						to
						<e:trinput name="date2" size="10" maxlength="15" />
					</td>
				</tr>
				<!-- Sort field and search-within-data don't work. 
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
				<tr>
					<td align="right" valign="middle">
					    Search:
					</td>
					<td>
				    	<input type="radio" name="searchIn" value="all" checked="true" />All data
					    <input type="radio" name="searchIn" value="within"/ >Within results
					</td>
				</tr>
				-->
				<tr>
					<td>
						Stacked:
						<e:select name="stacked" valueList="all, yes, no" labelList="All, Yes, No"/>
					</td>
					<td>
						Blessed:
						<e:select name="blessed" valueList="all, yes, no" labelList="All, Yes, No"/>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
	
	<%
		//variables used in metadata searches:
		String key = request.getParameter("key");
		String value = request.getParameter("value");
		String date1 = request.getParameter("date1");
		String date2 = request.getParameter("date2");
		String stacked = request.getParameter("stacked");
		String blessed = request.getParameter("blessed");
		boolean submit = StringUtils.isNotBlank(request.getParameter("submit"));
		
		if (StringUtils.isBlank(key)) key="all";
		
		/* Data sortation is never even used? 
		   String sortDirection = request.getParameter("sortDirection");
		   String order = request.getParameter("sortField");
		   if (StringUtils.isBlank(order)) order = "startdate"; 
		   if (StringUtils.isBlank(sortDirection)) sortDirection = "sortAsc";
		*/
		
		ResultSet searchResults = null;
		StructuredResultSet searchResultsStructured = null;
		if (submit) {
		    long start = System.currentTimeMillis();
		    
		    And and = new And();
		    
		    /* This parameter is never set 
			   if ("within".equals(request.getParameter("searchIn"))) {
				   and.add((QueryElement) session.getAttribute("previousSearch"));
			}
		    */
			
			// Allow use of asterisk wildcards, remove leading/trailing whitespace 
			if (StringUtils.isNotBlank(value) && !key.equals("all")) {
				value = value.replace('*', '%').trim();
				and.add(new Like(key, value)); 
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
					    
		    if ("yes".equals(blessed)) {
		    	and.add(new Equals("blessed", Boolean.TRUE));
		    }
		    if ("no".equals(blessed)) {
		    	and.add(new Equals("blessed", Boolean.FALSE));
		    }
		    
		    if ("yes".equals(stacked)) {
		    	and.add(new Equals("stacked", Boolean.TRUE));
		    }
		    if ("no".equals(stacked)) {
		    	and.add(new Equals("stacked", Boolean.FALSE));
		    }
		    
		    and.add(new Equals("type", "split"));
		    and.add(new Equals("project", elab.getName()));
		    
			searchResults = elab.getDataCatalogProvider().runQuery(and);
			searchResultsStructured = DataTools.organizeSearchResults(searchResults);
			searchResultsStructured.setKey(key);
			searchResultsStructured.setValue(value);
			long end = System.currentTimeMillis();
			String time = ElabUtil.formatTime(end - start);
			searchResultsStructured.setTime(time);
		}
		else {
		    session.setAttribute("previousSearch", null);
		    DataCatalogProvider dcp = elab.getDataCatalogProvider();
			int fileCount = dcp.getUniqueCategoryCount("split");
			int schoolCount = dcp.getUniqueCategoryCount("school");
			int stateCount = dcp.getUniqueCategoryCount("state");
			%>
			<p>
		 		Searching <%= fileCount %> data files from <%= schoolCount %> schools in 
				<%= stateCount %> states.
			</p>
			<%
		}
		request.setAttribute("searchResults", searchResults);
		request.setAttribute("searchResultsStructured", searchResultsStructured);
	%>
</form>

