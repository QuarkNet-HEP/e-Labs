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

<%SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
DATEFORMAT.setLenient(false); 
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

<div class="search-quick-links">Quick Searches: 
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="group" />
		<input type="hidden" name="value" value="${user.name}" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="${user.name}" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'>${user.name}</a>,
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="teacher" />
		<input type="hidden" name="value" value="<%= user.getTeacher() %>" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="<%= user.getTeacher() %>" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'><%= user.getTeacher() %></a>,
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="school" />
		<input type="hidden" name="value" value="${user.group.school}" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="${user.group.school}" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'>${user.group.school}</a>,
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="city" />
		<input type="hidden" name="value" value="${user.group.city}" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="${user.group.city}" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'>${user.group.city}</a>,
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="state" />
		<input type="hidden" name="value" value="${user.group.state}" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="${user.group.state}" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'>${user.group.state}</a>,
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="all" />
		<input type="hidden" name="action" value="Search Data" />
		<!-- 
		<input type="submit" value="All" />
		-->
		<a href="#" onclick='$(this).closest("form").submit()'>All</a>
	</form>
</div>

<form action="controller.jsp" name="search" method="post">
	<e:select name="key" id="selectOptions" valueList="city, group, school, state, teacher, detectorid"
		        labelList="City, Group, School, State/Country, Teacher, Detector ID"
		        default="${key}"/>
	<input name="value" id="name" size="40" maxlength="40" value="${value}"  />
	<input type="submit" name="action" value="Search Data" />
	
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
						<e:trinput name="date1" id="date1" size="10" maxlength="15" class="datepicker" value="${date1}"/>
						to
						<e:trinput name="date2" id="date2" size="10" maxlength="15" class="datepicker" value="${date2}"/>
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
					    <input type="radio" name="searchIn" value="within"/ >Within results
					</td>
				</tr>
				<tr>
					<td>
						Stacked:
						<e:select name="stacked" valueList="all, yes, no" selected="${stacked}" labelList="All, Yes, No"/>
					</td>
					<td>
						Blessed:
						<e:select name="blessed" valueList="all, yes, no" labelList="All, Yes, No" selected="${blessed}"/>
					</td>
				</tr>
			</table>
		</e:hidden>
	</e:vswitch>
</form>

