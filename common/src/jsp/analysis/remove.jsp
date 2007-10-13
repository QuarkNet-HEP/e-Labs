<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%
	String[] ids = request.getParameterValues("id");
	if (ids != null) {
		for (int i = 0; i < ids.length; i++) {
			AnalysisManager.removeAnalysisRun(elab, user, ids[i]);
		}
	}
%>

<jsp:include page="../analysis/list.jsp"/>