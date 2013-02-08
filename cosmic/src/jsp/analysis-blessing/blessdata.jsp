<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<script type="text/javascript">
	window.onunload = function() {
	    if (window.opener && !window.opener.closed) {
	        window.opener.popUpClosed();
	    }
	};
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Blessing/Unblessing data...</title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
		<table width="100%" cellpadding="0" cellspacing="0" align="center">
			<%	
			String blessed = request.getParameter("blessed");
			boolean blessedIt = (blessed.equals("true") ? false: true);
			String filename = request.getParameter("filename");
			String newvalue = (blessed.equals("true") ? "unblessed": "blessed");
			
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			CatalogEntry entry = dcp.getEntry(filename);
			entry.setTupleValue("blessed", blessedIt);
			dcp.insert(entry);

			%>
			<TR><TD>You have successfully <%= newvalue %> your data.<TD></TR>
		</table>			
		<a href=# onclick="window.close();">Close</A>
	</body>
</html>
