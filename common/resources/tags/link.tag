<%@ tag body-content="tagdependent" dynamic-attributes="attrs" description="Generates a link, while passing all attributes (besides href) as CGI parameters. The important aspect is that arrays/collections get passed correctly, as multiple cgi parameters." %>
<%@ tag import="java.util.*" %>
<%@ attribute name="href" required="true" %>

<%
	Map attrs = (Map) jspContext.getAttribute("attrs");
	out.write("<a href=\"" + href);
	if (!attrs.isEmpty()) {
		out.write("?");
		Iterator i = attrs.entrySet().iterator();
		while (i.hasNext()) {
			Map.Entry e = (Map.Entry) i.next();
			String name = (String) e.getKey();
			Object value = e.getValue();
			if (value.getClass().isArray()) {
				Object[] o = (Object[]) value;
				for (int j = 0; j < o.length; j++) {
					out.write(name + "=" + o[j]);
					if (j < o.length - 1) {
						out.write("&");
					}
				}
			}
			else if (value instanceof Collection) {
				Iterator j = ((Collection) value).iterator();
				while (j.hasNext()) {
					out.write(name + "=" + j.next());
					if (j.hasNext()) {
						out.write("&");
					}
				}
			}
			else {
				out.write(name + "=" + value);
			}
			if (i.hasNext()) {
				out.write("&");
			}
		}
	}
	out.write("\">");
%><jsp:doBody/></a>