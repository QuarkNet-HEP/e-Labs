<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ tag body-content="scriptless" description="Format text to break long lines but also preserve whitespace as much as possible" %>
<%@ attribute name="text" required="true" description="The text to be formatted" %>
<%@ tag import="gov.fnal.elab.util.ElabUtil" %>
<%
	out.write(ElabUtil.whitespaceAdjust(text));
%>