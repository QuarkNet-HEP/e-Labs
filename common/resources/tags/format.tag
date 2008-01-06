<%@ tag body-content="tagdependent" description="Formats a number or date" %>
<%@ attribute name="type" type="java.lang.String" 
	required="true" description="The type of format to use. Currently it can be one of 'decimal' and 'date'" %>
<%@ attribute name="format" type="java.lang.String" 
	required="true" description="The actual format. For numbers see the documentation of java.text.DecimalFormat and for dates see the documentation of java.text.SimpleDateFormat." %>
<%@ attribute name="value" type="java.lang.Object" 
	required="true" description="The value to be formatted." %>
<%@ tag import="java.text.*" %>

<%
	Format f;
	if ("decimal".equals(type)) {
	    f = new DecimalFormat(format);
	}
	else if ("date".equals(type)) {
	    f = new SimpleDateFormat(format);
	}
	else {
	    throw new JspException("Unsupported format type: " + type);
	}
	out.write(f.format(value));
%>