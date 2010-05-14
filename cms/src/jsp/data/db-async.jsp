<%@ include file="../include/elab.jsp" %><%@ include file="../login/login-required.jsp" %><%@
	page import="org.w3c.dom.*" 
		 import="java.util.*"
		 import="java.sql.*" 
		 import="gov.fnal.elab.*"
		 import="gov.fnal.elab.cms.triggerexpr.*" %>
<jsp:include page="../data/dataset-info.jsp">
	<jsp:param name="dataset" value="${param.dataset}"/>
</jsp:include><%

String db = elab.getProperties().getProperty("ogredb.database");
String dbuser = elab.getProperties().getProperty("ogredb.username");
String dbpass = elab.getProperties().getProperty("ogredb.password");

try {
	Class.forName("com.mysql.jdbc.Driver");
}
catch (ClassNotFoundException e) {
    throw new ElabJspException("Couldn't find the mysql driver!");
}

String texpr = request.getParameter("texpr");
if (texpr == null) {
    throw new ElabJspException("Missing trigger expression");  
}

String dataset = request.getParameter("dataset");
String table, columns;
if ("tb04".equals(dataset)) {
    table = "rundb";
    columns = "run, nevents, energy, beam, eta, phi";
}
else {
    table = "mcdb";
    dataset = "mc09";
    columns = "run, nevents, description";
}

Set<String> validTriggers = new HashSet<String>();
Document doc = (Document) request.getAttribute("currentDataset");
if (doc == null) {
    throw new ElabJspException("No current dataset");
}
NodeList triggers = doc.getElementsByTagName("trigger");
for (int i = 0; i < triggers.getLength(); i++) {
    NamedNodeMap attrs = triggers.item(i).getAttributes();
    if (attrs == null) {
        continue;
    }
    org.w3c.dom.Node fake = attrs.getNamedItem("fake");
    if (fake != null && "true".equals(fake.getNodeValue())) {
        continue;
    }
    validTriggers.add(attrs.getNamedItem("id").getNodeValue());
}

String whereclause;
try {
	gov.fnal.elab.cms.triggerexpr.Node parsed = new Parser(validTriggers).parse(texpr);
	whereclause = new SQLTransformer().transform(parsed);
}
catch (ParsingException e) {
    throw new ElabJspException("Invalid trigger expression", e);
}

String sql = "SELECT " + columns + " FROM " + table + " WHERE " + whereclause; 

Connection conn = DriverManager.getConnection("jdbc:mysql:" + db, dbuser, dbpass);
if (conn == null) {
    throw new SQLException(
        "Connection to database failed. The SQL driver manager "
            + "did not return a valid connection");
}
try {
	Statement s = conn.createStatement();
	ResultSet rs = s.executeQuery(sql);
	String[] cols = columns.split("[\\s,]+");
	out.write("dataset=" + dataset + "\n");
	while (rs.next()) {
	    for (int i = 0; i < cols.length; i++) {
	        out.write(cols[i] + "=" + rs.getString(i + 1) + "\n");
	    }
	}
}
finally {
    conn.close();
}


%>
