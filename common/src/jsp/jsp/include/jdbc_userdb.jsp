<%@ page import="java.sql.*" %>
<%
//JDBC connection:

/** BENC -- this classloading block loads the postgres driver, which 
makes it available for the next bit where jdbc:postgresql: is loaded.

There must be a better way, though, rather than hard-coding class names 
in here? maybe the eventual property that will specify the jdbc 
URL should have another one alongside specifying the connector 
class name? what do vds and globus do?
*/
try {
    Class.forName("org.postgresql.Driver");
} catch (ClassNotFoundException cnfe) {
    warn(out, "Couldn't find the postgres driver!");
    warn(out, "Let's print a stack trace, and exit.");
    cnfe.printStackTrace();
    return;
}

Connection conn = null;
String userdb = elab.getProperty("userdb.db");
String userdb_username = elab.getProperty("userdb.username");
String userdb_password = elab.getProperty("userdb.password");
try {
    // The second and third arguments are the username and password respectively
    // (perhaps in the case of postgres, but I want this to me more
    //  generalised)
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
