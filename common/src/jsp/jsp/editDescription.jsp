<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>

<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
     
<head>
	<title>Edit descriptions</title>
	<link rel="stylesheet"  href="include/styletut.css" type="text/css">
</head>

<%
	String primary = request.getParameter("tr");
	String secondary = request.getParameter("arg");
	String op = request.getParameter("op");
	String text = request.getParameter("text");
	  
	if (op == null) {
		op = "Show";
	}
	if (op.equals("Show")) {
		if (primary == null || secondary == null) {
			%> <div class="error">Missing transformation and/or argument name</div> <%
		}
		else {
			String schemaName = ChimeraProperties.instance().getVDCSchemaName();
			Connect connect = new Connect();
			DatabaseSchema dbschema = connect.connectDatabase(schemaName);
			Annotation annotation = null;

			if (! (dbschema instanceof Annotation)) {
            	%> <div class="error">The VDC does not support annotations</div><%
			} 
			else {
				try {
					annotation = (Annotation) dbschema;
					List list = annotation.loadAnnotation(primary, secondary, Annotation.CLASS_DECLARE);
					
					if (list != null) {
						for (Iterator i = list.iterator(); i.hasNext();) {
							Tuple tuple = (Tuple) i.next(); 
							if ((tuple.getKey()).equals("description")) {
								text = String.valueOf(tuple.getValue());
							}
						}
					}
				}
				catch (Exception e) {
					out.write("<div class=\"error\">" + e.getMessage() + "</div>");
				}
			}
			if (dbschema != null) {
				dbschema.close();
			}
			if (annotation != null) {
				((DatabaseSchema) annotation).close();
			}
		}
	}
	else if (op.equals("Update")) {
		if (primary == null || secondary == null) {
			%> <div class="error">Missing transformation and/or argument name</div> <%
		}
		else {
			String schemaName = ChimeraProperties.instance().getVDCSchemaName();
			Connect connect = new Connect();
			DatabaseSchema dbschema = connect.connectDatabase(schemaName);
			Annotation annotation = null;

			if (! (dbschema instanceof Annotation)) {
            	%> <div class="error">The VDC does not support annotations</div> <%
			} 
			else {
				try {
					annotation = (Annotation) dbschema;
					Tuple t = new TupleString("description", text);
					annotation.saveAnnotation(primary, secondary, Annotation.CLASS_DECLARE, t, true);
					out.write("<div class=\"message\">Description updated successfully</div>");
				}
				catch (Exception e) {
					out.write("<div class=\"error\">" + e.getMessage() + "</div>");
				}
			}
			if (dbschema != null) {
				dbschema.close();
			}
			if (annotation != null) {
				((DatabaseSchema)annotation).close();
			}
		}
	}
	pageContext.setAttribute("text", text);
	%>
		<form>
			<p>
				<label for="tr">Transformation</label>
				<input type="text" name="tr" size="40" value="${param.tr}"/>
			</p>
			<p>
				<label for="arg">Argument name</label>
				<input type="text" name="arg" size="40" value="${param.arg}"/>
			</p>
			<p>
				<textarea name="text" cols="80" rows="25">${text}</textarea>
			</p>
			<p>
				<input type="submit" name="op" value="Show"/>
				<input type="submit" name="op" value="Update"/>
			</p>
		</form>
	<%
%>
</font>
</body>
</html>
