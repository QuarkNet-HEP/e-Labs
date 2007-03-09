<%@ page import="java.sql.*" %>
<%
//JDBC connection:
try {
    Class.forName("org.postgresql.Driver");
} catch (ClassNotFoundException cnfe) {
    out.write("Couldn't find the postgres driver!");
    out.write("Let's print a stack trace, and exit.");
    cnfe.printStackTrace();
    return;
}

Connection conn = null;
String userdb = (String)System.getProperty("user.db");
String userdb_username = (String)System.getProperty("userdb.username");
String userdb_password = (String)System.getProperty("userdb.password");
try {
    // The second and third arguments are the username and password respectively
    conn = DriverManager.getConnection("jdbc:postgresql:" + userdb, userdb_username, userdb_password);
} catch (SQLException se) {
    out.println("Couldn't connect to the postgres database: print out a stack trace and exit.");
    se.printStackTrace();
    out.println("<br>userdb: " + userdb + " username: " + userdb_username);
    out.println("<br>Exception message: " + se.getMessage());
    return;
}
if (conn == null){
    out.write("There was an error in the postgres connection code.");
    return;
}
Statement s = null;
try {
    s = conn.createStatement();
} catch (SQLException se) {
    out.println("We got an exception while creating a statement:" +
            "that probably means we're no longer connected to the postgres database.");
    se.printStackTrace();
    return;
}
ResultSet rs = null;

%>
