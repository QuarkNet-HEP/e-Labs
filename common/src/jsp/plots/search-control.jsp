<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<% 
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	String msg = (String) request.getParameter("msg");
	String project = elab.getName();
	TreeMap<String, String> studyOptions = new TreeMap<String, String>();
	studyOptions.put("flux", "Flux");
	studyOptions.put("lifetime", "Lifetime");
	studyOptions.put("performance", "Performance");
	studyOptions.put("shower", "Shower");
	studyOptions.put("blesschart", "Bless Charts");
	studyOptions.put("timeofflight", "Time Of Flight");
	TreeMap<String, String> sortByOptions = new TreeMap<String, String>();
	sortByOptions.put("creationdate", "Creation Date");
	sortByOptions.put("name", "Filename");
	request.setAttribute("project", project);
	request.setAttribute("studyOptions", studyOptions);
	request.setAttribute("sortByOptions", sortByOptions);

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
</script>
<script>
	function getStudyType(object) {
		if (object.value == "study") {
			$("#name")
		    .replaceWith('<select id="name" name="value">' +
		          	'<option></option>' +
					'<option name="flux" value="flux">Flux</option>' +
					'<option name="lifetime" value="lifetime">Lifetime</option>' +
					'<option name="performance" value="performance">Performance</option>' +					
					'<option name="shower" value="shower">Shower</option>' +
					'<option name="blesschart" value="blesschart">Bless Charts</option>' +
					'<option name="timeofflight" value="timeofflight">Time of Flight</option>' +
		          	'</select>');
		} else {
			$("#name")
		    .replaceWith('<input name="value" id="name" size="40" maxlength="40" value="${param.value}">');			
		}
	}
</script>

<div class="plot-search-control"> 
	<div class="search-quick-links">
		Quick Searches:&nbsp; 
		<e:quicksearch key="group" value="${user.name}" suffix="&uploaded=${param.uploaded}" />,
		<e:quicksearch key="teacher" value="<%= user.getTeacher() %>" suffix="&uploaded=${param.uploaded}" />,
		<e:quicksearch key="school" value="${user.school}" suffix="&uploaded=${param.uploaded}" />,
		<e:quicksearch key="city" value="${user.city}" suffix="&uploaded=${param.uploaded}" />,
		<e:quicksearch key="state" value="${user.state}" suffix="&uploaded=${param.uploaded}" />
	</div>
	
	<form name="search" method="get">
	<c:choose>
		<c:when test='${project == "cosmic"}'>
			<e:select name="key" id="selectOptions" valueList="name, title, group, teacher, school, city, state, year, study"
				labelList="Filename, Title, Group, Teacher, School, City, State/Country, Academic Year, Study"
				default="${param.key}" onChange="getStudyType(this);" />
		</c:when>
		<c:otherwise>
			<e:select name="key" id="selectOptions" valueList="name, title, group, teacher, school, city, state, year"
				labelList="Filename, Title, Group, Teacher, School, City, State, Academic Year"
				default="${param.key}" />
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test='${param.key == "study"}'>
			<select id="name" name="value">
		          	<option></option>
		          	<c:forEach items="${studyOptions }" var="studyOptions">
		          		<c:choose>
		          			<c:when test="${studyOptions.key == param.value }">
								<option name="${studyOptions.key}" value="${studyOptions.key }" selected=true>${studyOptions.value }</option>
		          			</c:when>
		          			<c:otherwise>
								<option name="${studyOptions.key}" value="${studyOptions.key }" >${studyOptions.value }</option>
		          			</c:otherwise>
		          		</c:choose>
		          	</c:forEach>
		    </select>		
		</c:when>
		<c:otherwise>
			<input name="value" id="name" size="40" maxlength="40" value="${param.value}"  />
		</c:otherwise>		
	</c:choose>
	<input type="submit" name="submit" value="Search Data" />
		<e:vswitch>
			<e:visible image="../graphics/Tright.gif">
				Advanced Search 
			</e:visible>
			<e:hidden image="../graphics/Tdown.gif">
				Advanced Search
				<table class="form-controls" style="border: 1px dotted black; margin-left: auto; margin-right: auto; padding: 8px;">
				<tr><td>
					Please enter dates in MM/dd/yyyy format (e.g. <%= DATEFORMAT.format(new Date()) %>).<br />
					You may leave one or both date fields blank.<br />
					Date Range: &nbsp;&nbsp;&nbsp;From: 
					<e:trinput name="date1" id="date1" size="10" maxlength="15" class="datepicker" />
					to
					<e:trinput name="date2" id="date2" size="10" maxlength="15" class="datepicker" />
										
					</td></tr>
				<tr>
					<td>Sort By:
						<select name="sortBy" id="sortBy">
				          	<c:forEach items="${sortByOptions }" var="sortByOptions">
				          		<c:choose>
				          			<c:when test="${sortByOptions.key == param.sortBy }">
										<option name="${sortByOptions.key}" value="${sortByOptions.key }" selected=true>${sortByOptions.value }</option>
				          			</c:when>
				          			<c:otherwise>
										<option name="${sortByOptions.key}" value="${sortByOptions.key }" >${sortByOptions.value }</option>
				          			</c:otherwise>
				          		</c:choose>
				          	</c:forEach>							
						</select>
						<select name="order" id="order">
							<c:choose>
								<c:when test='${param.order == "asc" }'>
									<option value="desc" >Desc</option>
									<option value="asc" selected=true>Asc</option>
								</c:when>
								<c:otherwise>
									<option value="desc" selected=true>Desc</option>
									<option value="asc" >Asc</option>
								</c:otherwise>
							</c:choose>
						</select>
					</td>
				</tr>
				</table>
			</e:hidden>
		</e:vswitch>
		<p>
			States include provinces and foreign countries. Use the 
			<e:popup href="../jsp/showStates.jsp" target="states" width="400" height="700">abbreviation</e:popup>
		</p>
	
		<%
			//variables used in metadata searches:
			String errors = ""; 
			String key = request.getParameter("key");
			if (StringUtils.isBlank(key)) key="name";
			
			String value = request.getParameter("value");
			value = StringUtils.trimToEmpty(value);
			
			String date1 = request.getParameter("date1");
			String date2 = request.getParameter("date2");
	
			String sortBy = request.getParameter("sortBy");
			String order = request.getParameter("order");
			
			boolean submit = request.getParameter("submit") != null;
				
			ResultSet searchResults = null;
			if (submit) {
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
				
			    And and = new And();
			    and.add(new Equals("project", elab.getName()));
			    // EPeronja-05/13/2013: Bug 273 Need tool to delete/manage images
			    //  					Commented the if code out
			    //if ("true".equals(request.getParameter("uploaded"))) {
			        Or or = new Or();
			        or.add(new Equals("type", "plot"));
			        or.add(new Equals("type", "uploadedimage"));
			        and.add(or);
			    //}
			    //else {
				//    and.add(new Equals("type", "plot"));
			    //}
			    if (value.isEmpty()) {
			    	// do nothing
			    }
			    else if (!key.equals("year")) {
			    	// Automatically generate wildcard, make case-insensitive
			    	and.add(new ILike(key, "%" + value + "%"));
			    }
			    else {
			    	if (value.toUpperCase().startsWith("AY")) {
			    		and.add(new Equals(key, value.toUpperCase()));
			    	}
			    	else { 
			    		try {
			    			Integer.parseInt(value);
			    			and.add(new Equals(key, "AY" + value));
			    		}
			    		catch (NumberFormatException ex) {
			    			errors += "The system did not understand the academic year you typed in, please check what you typed. <br />";
			    		}
			    	}
			    }
				    
			//hmm. posters use "date" instead of "creationdate"
			// Probably should do this Cosmic-style 
		    if (StringUtils.isNotBlank(date1) || StringUtils.isNotBlank(date2)) {
				// In case someone makes their own search string and forgets the date type 
				
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
						and.add(new LessOrEqual("creationdate", endDate));
					}
					
					// End date undefined, therefore greater than or equal to the start date
					else if (StringUtils.isBlank(date2)) {
						and.add(new GreaterOrEqual("creationdate", startDate));
					}
					// Date range 
					else {
						and.add(new Between("creationdate", startDate, endDate));
					}
				}
				catch (Exception ex) {
					errors += "At least one of the dates you typed in was not understood. Please re-check the dates you typed in.";
				}
			}
	
			searchResults = elab.getDataCatalogProvider().runQuery(and);
			
			if (sortBy != null) {
				boolean direction = true;
				if (order != null && order.equals("asc")) {
					direction = false;
				}
				if (searchResults != null) {
					searchResults.sort(sortBy, direction);
				}
			}

			request.setAttribute("searchResults", searchResults);
			request.setAttribute("sortBy", sortBy);
			request.setAttribute("order", order);
			request.setAttribute("msg", msg);			
			}
			
		%>
	</form>
</div>
