/*
 * Created on Mar 6, 2007
 */
package gov.fnal.elab.util;

import gov.fnal.elab.ElabProperties;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseConnectionManager {

    public static Connection getConnection(ElabProperties properties)
            throws SQLException {
        String userdb = properties.getProperty(ElabProperties.PROP_USERDB_DB);
        String userdbUsername = properties
                .getProperty(ElabProperties.PROP_USERDB_USERNAME);
        String userdbPassword = properties
                .getProperty(ElabProperties.PROP_USERDB_PASSWORD);
        /*
         * Wicked. Don't remove the check below. It seems to cause jdbc to not
         * find the driver.
         */
        try {
            Class.forName("org.postgresql.Driver");
        }
        catch (ClassNotFoundException e) {
            throw new SQLException("Couldn't find the postgres driver!");
        }

        Connection conn = DriverManager.getConnection("jdbc:postgresql:"
                + userdb, userdbUsername, userdbPassword);
        if (conn == null) {
            throw new SQLException(
                    "Connection to database failed. The SQL driver manager "
                            + "did not return a valid connection");
        }
        return conn;
    }

    public static void close(Connection conn, Statement s) {
        try {
            if (s != null) {
                s.close();
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
        try {
            if (conn != null) {
                conn.close();
            }

        }
        catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
