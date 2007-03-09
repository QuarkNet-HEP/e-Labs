<%@ page import="java.sql.*" %>
<%
//JDBC connection:
try {
    Class.forName("org.postgresql.Driver");
} catch (ClassNotFoundException cnfe) {
    warn(out, "Couldn't find the postgres driver!");
    warn(out, "Let's print a stack trace, and exit.");
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
    warn(out, "Couldn't connect to the user database." +
         "<br>userdb: " + userdb + " username: " + userdb_username +
         "<br>Exception message: " + se.getMessage());
    se.printStackTrace();
    return;
}
if (conn == null){
    warn(out, "There was an error in the user database connection code.");
    return;
}
Statement s = null;
try {
    s = conn.createStatement();
} catch (SQLException se) {
    warn(out, "We got an exception while creating a statement:" +
         "that probably means we're no longer connected to the user data database.");
    se.printStackTrace();
    return;
}
ResultSet rs = null;

%>
