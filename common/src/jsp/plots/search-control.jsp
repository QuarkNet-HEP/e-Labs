<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>

<div class="plot-search-control"> 
	<div class="search-quick-links">
		Quick Searches:&nbsp; 
		<e:quicksearch key="group" value="${user.name}" suffix="&uploaded=${param.uploaded}"/>
		<e:quicksearch key="teacher" value="<%= user.getTeacher() %>" suffix="&uploaded=${param.uploaded}"/>
		<e:quicksearch key="school" value="${user.school}" suffix="&uploaded=${param.uploaded}"/>
		<e:quicksearch key="city" value="${user.city}" suffix="&uploaded=${param.uploaded}"/>
		<e:quicksearch key="state" value="${user.state}" suffix="&uploaded=${param.uploaded}"/>
		<e:quicksearch key="all" value="" label="All" suffix="&uploaded=${param.uploaded}"/>
	</div>
	
	<form name="search" method="get">
		<e:select name="key" valueList="group, name, school, city, state, teacher"
					labelList="Group, Name, School, City, State, Teacher"
					default="${param.key}"/>
		<input name="value" size="40" maxlength="40" value="${param.value}"/>
		<input type="submit" name="submit" value="Search Data"/>
		<br />
		<input type="hidden" name="uploaded" value="${param.uploaded}"/>
		<label for="date1">(Optional) Date:</label>
		<e:trinput type="text" size="10" maxlength="15" name="date1" default="1/1/2004"/>
		<label for="date2">to</label>
		<e:trinput type="text" size="10" maxlength="15" name="date2" default="12/30/2050"/>
		<p>
			States include provinces and foreign countries. Use the 
			<e:popup href="../jsp/showStates.jsp" target="states" width="400" height="700">abbreviation</e:popup>
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
			    if ("true".equals(request.getParameter("uploaded"))) {
			        Or or = new Or();
			        or.add(new Equals("type", "plot"));
			        or.add(new Equals("type", "uploadedimage"));
			        and.add(or);
			    }
			    else {
				    and.add(new Equals("type", "plot"));
			    }
				if (!"all".equals(key)) {
					value = value.replace('*', '%'); // Allow asterisk
				    and.add(new Like(key, value));
				}
				    
		        and.add(new Between("creationdate", new Date(date1), new Date(date2 + " 23:59:59")));
	
				searchResults = elab.getDataCatalogProvider().runQuery(and);
			}
			request.setAttribute("searchResults", searchResults);
		%>
			
	</form>
</div>