<%@ tag import="gov.fnal.elab.*" %>
<%@ tag language="java" import="java.sql.*" import="javax.servlet.*" import="java.util.*"%>

<%
	Elab elab = (Elab) request.getAttribute("elab");
	String dataSet = elab.getProperty("dataset");
	String DRIVER = "com.mysql.jdbc.Driver";
	Class.forName(DRIVER).newInstance();

	Connection con=null;
	ResultSet rst=null;
	Statement stmt=null;

	String host     = "leptoquark.hep.nd.edu";
	String database = "ogredb";
	String table    = "rundb";
	String dbuser   = "ogre";

	String column = "runtype";
	String cut = " where " + column + " is not NULL and dataset=\"" + dataSet + "\"";
	String query = "desc " + table;
	String fieldList = "";

	String url = "jdbc:mysql://" + host + "/" + database + "?user=" + dbuser;

	try{
		con = DriverManager.getConnection(url);
		stmt = con.createStatement();
		rst = stmt.executeQuery(query);
		System.out.println("FS: " + rst.getFetchSize());

		while (rst.next()) {
			fieldList = fieldList + "," + rst.getString("Field");
 			%>
				<td><FONT color="blue"><H4><%=rst.getString("Field")%></H4></FONT></td>
			<%
		}
	} 
	catch (Exception e) {
		throw new ElabJspException(e);
	}

	%>
		</tr>
	<%
	if (request.getQueryString() != null) {
		String [] run_numbers = request.getParameter("run").split(",");
		int i = 0;
		String [] Fields = fieldList.split(",");

		while (i < run_numbers.length) {
			query = "SELECT * from " + table + " where dataset=\"" + dataSet + "\" and run=" + run_numbers[i];
			int j = 1;

			try {
				rst = stmt.executeQuery(query);
				rst.next();
				out.print("<tr>\n");
				while (j < Fields.length) {
					out.print("<td>"+rst.getString(Fields[j])+"</td>\n");
					j++;
				}
				out.print("</tr>\n");
			} 
			catch(Exception e) {
				throw new ElabJspException(e);
			}
			i++;
		}
	}

	rst.close();
	stmt.close();
	con.close();
%>
