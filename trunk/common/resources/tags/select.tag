<%@ tag body-content="tagdependent" dynamic-attributes="attrs" %>
<%@ tag import="java.util.*" %>
<%@ tag import="gov.fnal.elab.tags.*" %>
<%@ tag import="gov.fnal.elab.util.*" %>
<%@ attribute name="labelList" required="true" %>
<%@ attribute name="valueList" required="true" %>
<%@ attribute name="selected" required="false" %>
<%@ attribute name="name" required="true" %>

<%
	Map attrs = (Map) jspContext.getAttribute("attrs");
	if (name != null && selected == null) {
	    selected = request.getParameter(name);
	    if (selected == null) {
	        selected = (String) attrs.get("default");
	    }
	}
	
	out.write("<select");
	DynamicAttributesSupport.writeAttribute(out, "name", name);
	DynamicAttributesSupport.writeAttributes(out, attrs);
	out.write(">");
	ElabUtil.optionSet(out, valueList, labelList, selected);
%>
<jsp:doBody/>
</select>

    