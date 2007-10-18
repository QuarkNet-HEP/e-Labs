<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
	CatalogEntry e = elab.getDataCatalogProvider().getEntry("News_" + elab.getName() + "_status");
	if (e != null) {
		request.setAttribute("e", e.getTupleMap());
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
		sdf.setTimeZone(TimeZone.getTimeZone("America/Chicago"));
		request.setAttribute("now", new Date());
		if (e.getTupleValue("time") != null) {
			request.setAttribute("start", sdf.parse((String) e.getTupleValue("time")));
		}
		if (e.getTupleValue("expire") != null) {
			request.setAttribute("end", sdf.parse((String) e.getTupleValue("expire")));
		}
	}
%>

<c:if test="${(now > start) && (now < end)}">
	<div id="news-box">
		<div id="news-box-header">
			News Alert
		</div>
		<div id="news-box-contents">
			${e.description}
		</div>
		<div id="news-box-footer">
			Published ${start} 
		</div>
	</div>
</c:if>
	