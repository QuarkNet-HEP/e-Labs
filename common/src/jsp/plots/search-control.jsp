<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>

<div class="search-quick-links">
	Show plots by:&nbsp; 
	<e:quicksearch key="group" value="${user.group.name}"/>
	<e:quicksearch key="teacher" value="${user.group.teacher}"/>
	<e:quicksearch key="school" value="${user.group.school}"/>
	<e:quicksearch key="city" value="${user.group.city}"/>
	<e:quicksearch key="state" value="${user.group.state}"/>
	<e:quicksearch key="all" value="" label="All"/>
</div>

<p>or search plots by</p>
<form name="search" method="get">
	<p>
		<e:select name="key" valueList="city, group, name, school, state, teacher"
					labelList="City, Group, Name, School, State, Teacher"
					default="${param.key}"/>
		<input name="value" size="40" maxlength="40" value="${param.value}"/>
		<input type="submit" name="submit" value="Search Data"/>
	</p>
	<p>
		States include provinces and foreign countries. Enter the 
		<e:popup href="../jsp/show-states.jsp" target="states" width="400" height="700">abbreviation</e:popup>
	</p>
	<p>
		(Optional) limit search by creation date:
	</p>
	<p>
		<label for="date1">Date:</label>
		<e:trinput type="text" size="10" maxlength="15" name="date1" default="1/1/2004"/>
		<label for="date2">to</label>
		<e:trinput type="text" size="10" maxlength="15" name="date2" default="12/30/2050"/>
	</p>
	<%
		//variables used in metadata searches:
		String key = request.getParameter("key");
		if (key == null) key="name";
		String value = request.getParameter("value");
		if (value == null) value="";
		String date1 = request.getParameter("date1");
		if (date1 == null) date1="1/1/2004";
		String date2 = request.getParameter("date2");
		if (date2 == null) date2="12/30/2050";

		boolean submit = request.getParameter("submit") != null;
		
		ResultSet searchResults = null;
		if (submit) {
		    And and = new And();
		    and.add(new Equals("project", elab.getName()));
		    and.add(new Equals("type", "plot"));
			if (!"all".equals(key)) {
			    and.add(new Equals(key, value));
			}
		    
	        and.add(new Between("creationdate", new Date(date1), new Date(date2 + " 23:59:59")));

			searchResults = elab.getDataCatalogProvider().runQuery(and);
		}
		request.setAttribute("searchResults", searchResults);
	%>
		
</form>
