<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>

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
					<td align="right">
						<select name="datetype">
						    <option value="startdate" selected>Start Date</option>
						    <option value="creationdate">Upload Date</option>
						</select>
					</td>
					<td>
						<input name="date1" size="10" maxlength="15" value="${param.date1}" />
						to
						<input name="date2" size="10" maxlength="15" value="${param.date2}" />
					</td>
				</tr>
				<tr>
					<td align="right">
						<e:select name="sortDirection" valueList="sortAsc, sortDesc" labelList="Sort Ascending, Sort Descending"/>
					</td>
					<td>
						by
						<e:select name="sortField" valueList="city, state, stacked, blessed, group, year, detectorid, creationdate, chan1, chan2, chan3, chan4"
							labelList="City, State, Geometry, Blessed, Group, Academic Year, Detector ID, Upload Date, Cahnnel 1 events, Channel 2 events, Channel 3 events, Channel 4 events"/>
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
		if (key == null) key="name";
		String value = request.getParameter("value");
		if (value == null) value="";
		String date1 = request.getParameter("date1");
		if (date1 == null || date1.equals("")) date1="1/1/2004";
		String date2 = request.getParameter("date2");
		if (date2 == null || date2.equals("")) date2="12/30/2050";
		String sortDirection = request.getParameter("sortDirection");
		if (sortDirection == null) sortDirection = "sortAsc";
		String order = request.getParameter("sortField");
		if ((order == null) || (order.equals(""))){
		    order = "startdate";
		}
		String stacked = request.getParameter("stacked");
		String blessed = request.getParameter("blessed");
		boolean submit = request.getParameter("submit") != null;
		
		ResultSet searchResults = null;
		StructuredResultSet searchResultsStructured = null;
		if (submit) {
		    long start = System.currentTimeMillis();
		    
		    And and = new And();
			if ("within".equals(request.getParameter("searchIn"))) {
				and.add((QueryElement) session.getAttribute("previousSearch"));
			}
			if (!"all".equals(key)) {
			    and.add(new Equals(key, value));
			}
		    
		    String datetype = request.getParameter("datetype");
		    if ("startdate".equals(datetype) || "creationdate".equals(datetype)) {
		        and.add(new Between(datetype, new Date(date1), new Date(date2 + " 23:59:59")));
		    }
		    
		    if ("yes".equals(blessed)) {
		    	and.add(new Equals("blessed", "t"));
		    }
		    if ("no".equals(blessed)) {
		    	and.add(new Equals("blessed", "f"));
		    }
		    
		    if ("yes".equals(stacked)) {
		    	and.add(new Equals("stacked", "t"));
		    }
		    if ("no".equals(stacked)) {
		    	and.add(new Equals("stacked", "f"));
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
			%>
			<p>
				<%
					DataCatalogProvider dcp = elab.getDataCatalogProvider();
					int fileCount = dcp.getUniqueCategoryCount("split");
					int schoolCount = dcp.getUniqueCategoryCount("school");
					int stateCount = dcp.getUniqueCategoryCount("state");
				%>
		 		Searching <%= fileCount %> data files from <%= schoolCount %> schools in 
				<%= stateCount %> states.
			</p>
			<%
		}
		request.setAttribute("searchResults", searchResults);
		request.setAttribute("searchResultsStructured", searchResultsStructured);
	%>
</form>

