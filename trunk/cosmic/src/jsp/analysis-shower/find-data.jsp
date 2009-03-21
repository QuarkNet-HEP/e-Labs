<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="java.io.IOException" %>

<%
	String detectorId = request.getParameter("detectorId");
	if (detectorId == null) {
		throw new ElabJspException("Missing detector id parameter");
	}
	String ptime = request.getParameter("time");
	if (ptime == null) {
		throw new ElabJspException("Missing time parameter");
	}

	//A horribly incorrect thing to allow finding data based on the
	//wrong timezone in the database. The database, at least 
	//when you deploy the portal in Chicago (and burbs), is
	//GMT - 5
	TimeZone localTZ = TimeZone.getDefault();
	Date time = new Date(Long.parseLong(ptime) - localTZ.getOffset(Long.parseLong(ptime)));
	And and = new And();
	and.add(new Equals("project", elab.getName()));
	and.add(new Equals("type", "split"));
	and.add(new Equals("detectorid", detectorId));
	and.add(new LessOrEqual("startdate", time));
	and.add(new GreaterOrEqual("enddate", time));
	ResultSet sr = elab.getDataCatalogProvider().runQuery(and);
	if (sr.size() == 0) {
		throw new ElabJspException("No data found for detector id " + detectorId + " at time " + time);
	}
	else if (sr.size() > 1) {
		throw new ElabJspException("Multiple data found for detector id " + detectorId + " at time " + time + ". This is obviously some kind of error");
	}
	else {
		request.setAttribute("filename", ((CatalogEntry) sr.iterator().next()).getLFN());
	}
	Calendar c = Calendar.getInstance();
	c.setTime(time);
	request.setAttribute("h", String.valueOf(c.get(Calendar.HOUR_OF_DAY)));
	request.setAttribute("m", String.valueOf(c.get(Calendar.MINUTE)));
	request.setAttribute("s", String.valueOf(c.get(Calendar.SECOND)));
%>

<jsp:include page="../data/view.jsp">
	<jsp:param name="filename" value="${filename}"/>
	<jsp:param name="h" value="${h}"/>
	<jsp:param name="m" value="${m}"/>
	<jsp:param name="s" value="${s}"/>
</jsp:include>
