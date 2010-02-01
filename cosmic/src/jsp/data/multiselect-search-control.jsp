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
DATEFORMAT.setLenient(false); %>

<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
<script type="text/javascript" src="../include/jquery/js/jquery-1.4.min.js"></script>
<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript">
$(function() {
	$("#date1").datepicker({
		changeMonth: true,
		changeYear: true, 
		showButtonPanel: true
	});
	$("#date2").datepicker({
		changeMonth: true,
		changeYear: true, 
		showButtonPanel: true
	});
});
$(window).scroll(function(){
	$('#right').animate({top:$(window).scrollTop()+"px" },{queue: false, duration: 0});
});
</script>

<div class="search-quick-links">Quick Searches: 
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="school" />
		<input type="hidden" name="value" value="${user.group.school}" />
		<input type="hidden" name="action" value="Search Data" />
		<input type="submit" value="${user.group.school}" />
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="city" />
		<input type="hidden" name="value" value="${user.group.city}" />
		<input type="hidden" name="action" value="Search Data" />
		<input type="submit" value="${user.group.city}" />
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="state" />
		<input type="hidden" name="value" value="${user.group.state}" />
		<input type="hidden" name="action" value="Search Data" />
		<input type="submit" value="${user.group.state}" />
	</form>
	<form action="controller.jsp" name="search" method="post" style="display: inline;">
		<input type="hidden" name="key" value="all" />
		<input type="hidden" name="action" value="Search Data" />
		<input type="submit" value="All" />
	</form>
</div>

<form action="controller.jsp" name="search" method="post">
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
	<input name="value" id="name" size="40" maxlength="40" value="${param.value}" />
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
						<e:trinput name="date1" id="date1" size="10" maxlength="15" />
						to
						<e:trinput name="date2" id="date2" size="10" maxlength="15" />
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
</form>

