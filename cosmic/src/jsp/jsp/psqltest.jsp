<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%
//Checking if Driver is registered with DriverManager.

try {
    Class.forName("org.postgresql.Driver");
} catch (ClassNotFoundException cnfe) {
    out.write("Couldn't find the driver!");
    out.write("Let's print a stack trace, and exit.");
    cnfe.printStackTrace();
    return;
}
  
out.println("Registered the driver ok, so let's make a connection.");
  
Connection conn = null;

try {
    // The second and third arguments are the username and password,
    // respectively. They should be whatever is necessary to connect
    // to the database.
    String userdb = System.getProperty("user.db");
    String userdb_username = System.getProperty("userdb_username");
    String userdb_password = System.getProperty("userdb_password");
    conn = DriverManager.getConnection("jdbc:postgresql:" + userdb, userdb_username, userdb_password);
} catch (SQLException se) {
    out.println("Couldn't connect: print out a stack trace and exit.");
    se.printStackTrace();
    return;
}

if (conn != null)
    out.println("Hooray! We connected to the database!");
else
    out.println("We should never get here.");

Statement s = null;
try {
    s = c.createStatement();
} catch (SQLException se) {
    out.println("We got an exception while creating a statement:" +
            "that probably means we're no longer connected.");
    se.printStackTrace();
    return;
}

s.executeUpdate("DELETE FROM ptest WHERE id = currval('ptest_id_seq')");

int m=0;
try{
    m = s.executeUpdate("INSERT INTO ptest (name, location) VALUES ('Paul', 'Spencer\\'s Office')");
} catch (SQLException se){
    out.write("Error while executing our query.");
    se.printStackTrace();
    return;
}
out.print("Modified " +m+ " rows in the table.");

ResultSet rs = null;
try {
    rs = s.executeQuery("SELECT * FROM ptest");
} catch (SQLException se) {
    out.println("We got an exception while executing our query:" +
            "that probably means our SQL is invalid");
    se.printStackTrace();
    return;
}

int index = 0;

try {
    while (rs.next()) {
        out.println("<br>Here's the result of row " + index++ + ":");
        out.println(rs.getInt("id"));
        out.println(rs.getString("name"));
        out.println(rs.getString("location"));
    }
} catch (SQLException se) {
    out.println("We got an exception while getting a result:this " +
            "shouldn't happen: we've done something really bad.");
    se.printStackTrace();
    return;
}
%>
