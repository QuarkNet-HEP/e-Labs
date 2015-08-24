<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%
	String primary = request.getParameter("tr");
	String secondary = request.getParameter("arg");
	String op = request.getParameter("op");
	String text = request.getParameter("text");
	String message = "";
	
	if (op == null) {
		op = "";
	}
	if (op.equals("Show")) {
		if (primary == null || secondary == null) {
			message= "<i>*Missing transformation and/or argument name</i>";
		}
		else {
			String schemaName = ChimeraProperties.instance().getVDCSchemaName();
			Connect connect = new Connect();
			DatabaseSchema dbschema = connect.connectDatabase(schemaName);
			Annotation annotation = null;

			if (! (dbschema instanceof Annotation)) {
				message= "<i>*The VDC does not support annotation</i>";
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
					message= "<i>*"+e.getMessage()+"</i>";
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
			message= "<i>*Missing transformation and/or argument name</i>";
		}
		else {
			String schemaName = ChimeraProperties.instance().getVDCSchemaName();
			Connect connect = new Connect();
			DatabaseSchema dbschema = connect.connectDatabase(schemaName);
			Annotation annotation = null;

			if (! (dbschema instanceof Annotation)) {
				message= "<i>*The VDC does not support annotations</i>";
			} 
			else {
				try {
					annotation = (Annotation) dbschema;
					Tuple t = new TupleString("description", text);
					annotation.saveAnnotation(primary, secondary, Annotation.CLASS_DECLARE, t, true);
					message= "<i>*Description updated successfully</i>";
				}
				catch (Exception e) {
					message= "<i>*"+ e.getMessage() + "</i>";
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
	request.setAttribute("message", message);
	
	%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Edit Descriptions</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet"  href="include/styletut.css" type="text/css">
		<script>
			function clearAll() {
				document.getElementById("tr").value = "";
				document.getElementById("arg").value = "";
				document.getElementById("text").value = "";			
			}
		</script>
	</head>
	
	<body id="administration" class="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content"> 
     
				<form>
					<p>
						<label for="tr">Transformation</label>
						<input type="text" name="tr" id="tr" size="40" value="${param.tr}"/>
					</p>
					<p>
						<label for="arg">Argument name</label>
						<input type="text" name="arg" id="arg" size="40" value="${param.arg}"/>
					</p>
					<p>
						<textarea name="text" cols="80" id="text" rows="25">${text}</textarea>
					</p>
					<p>
						<input type="submit" name="op" value="Show"/>
						<input type="submit" name="op" value="Update"/>
						<input type="button" name="op" value="Clear" onclick="clearAll();"/>
					</p>
				</form>
			</div>
			<!-- end content -->	
			<c:if test="${not empty message }">
				<div>${message}</div>
			</c:if>
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
</body>
</html>
