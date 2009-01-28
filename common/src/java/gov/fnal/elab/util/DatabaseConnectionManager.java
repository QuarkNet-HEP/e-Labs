/*
 * Created on Mar 6, 2007
 */
package gov.fnal.elab.util;

import gov.fnal.elab.ElabProperties;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.Map;

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

        Connection conn = new Wrapper(DriverManager.getConnection("jdbc:postgresql:"
                + userdb, userdbUsername, userdbPassword));
        if (conn == null) {
            throw new SQLException(
                    "Connection to database failed. The SQL driver manager "
                            + "did not return a valid connection");
        }
        return conn;
    }
    
    private static class Wrapper implements Connection {
        private Connection delegate;
        
        public Wrapper(Connection delegate) {
            this.delegate = delegate;
        }

        public void clearWarnings() throws SQLException {
            delegate.clearWarnings();
        }

        public void close() throws SQLException {
            delegate.close();
        }

        public void commit() throws SQLException {
            delegate.commit();
        }

        public Statement createStatement() throws SQLException {
            return new StatementWrapper(delegate.createStatement());
        }

        public Statement createStatement(int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
            return delegate.createStatement(resultSetType, resultSetConcurrency, resultSetHoldability);
        }

        public Statement createStatement(int resultSetType, int resultSetConcurrency) throws SQLException {
            return delegate.createStatement(resultSetType, resultSetConcurrency);
        }

        public boolean getAutoCommit() throws SQLException {
            return delegate.getAutoCommit();
        }

        public String getCatalog() throws SQLException {
            return delegate.getCatalog();
        }

        public int getHoldability() throws SQLException {
            return delegate.getHoldability();
        }

        public DatabaseMetaData getMetaData() throws SQLException {
            return delegate.getMetaData();
        }

        public int getTransactionIsolation() throws SQLException {
            return delegate.getTransactionIsolation();
        }

        public Map getTypeMap() throws SQLException {
            return delegate.getTypeMap();
        }

        public SQLWarning getWarnings() throws SQLException {
            return delegate.getWarnings();
        }

        public boolean isClosed() throws SQLException {
            return delegate.isClosed();
        }

        public boolean isReadOnly() throws SQLException {
            return delegate.isReadOnly();
        }

        public String nativeSQL(String sql) throws SQLException {
            return delegate.nativeSQL(sql);
        }

        public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
            return delegate.prepareCall(sql, resultSetType, resultSetConcurrency, resultSetHoldability);
        }

        public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency) throws SQLException {
            return delegate.prepareCall(sql, resultSetType, resultSetConcurrency);
        }

        public CallableStatement prepareCall(String sql) throws SQLException {
            return delegate.prepareCall(sql);
        }

        public PreparedStatement prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
            return delegate.prepareStatement(sql, resultSetType, resultSetConcurrency, resultSetHoldability);
        }

        public PreparedStatement prepareStatement(String sql, int resultSetType, int resultSetConcurrency) throws SQLException {
            return delegate.prepareStatement(sql, resultSetType, resultSetConcurrency);
        }

        public PreparedStatement prepareStatement(String sql, int autoGeneratedKeys) throws SQLException {
            return delegate.prepareStatement(sql, autoGeneratedKeys);
        }

        public PreparedStatement prepareStatement(String sql, int[] columnIndexes) throws SQLException {
            return delegate.prepareStatement(sql, columnIndexes);
        }

        public PreparedStatement prepareStatement(String sql, String[] columnNames) throws SQLException {
            return delegate.prepareStatement(sql, columnNames);
        }

        public PreparedStatement prepareStatement(String sql) throws SQLException {
            return delegate.prepareStatement(sql);
        }

        public void releaseSavepoint(Savepoint savepoint) throws SQLException {
            delegate.releaseSavepoint(savepoint);
        }

        public void rollback() throws SQLException {
            delegate.rollback();
        }

        public void rollback(Savepoint savepoint) throws SQLException {
            delegate.rollback(savepoint);
        }

        public void setAutoCommit(boolean autoCommit) throws SQLException {
            delegate.setAutoCommit(autoCommit);
        }

        public void setCatalog(String catalog) throws SQLException {
            delegate.setCatalog(catalog);
        }

        public void setHoldability(int holdability) throws SQLException {
            delegate.setHoldability(holdability);
        }

        public void setReadOnly(boolean readOnly) throws SQLException {
            delegate.setReadOnly(readOnly);
        }

        public Savepoint setSavepoint() throws SQLException {
            return delegate.setSavepoint();
        }

        public Savepoint setSavepoint(String name) throws SQLException {
            return delegate.setSavepoint(name);
        }

        public void setTransactionIsolation(int level) throws SQLException {
            delegate.setTransactionIsolation(level);
        }

        public void setTypeMap(Map map) throws SQLException {
            delegate.setTypeMap(map);
        }
    }
    
    private static class StatementWrapper implements Statement {
        private Statement delegate;
        
        public StatementWrapper(Statement delegate) {
            this.delegate = delegate;
        }

        public void addBatch(String sql) throws SQLException {
            delegate.addBatch(sql);
        }

        public void cancel() throws SQLException {
            delegate.cancel();
        }

        public void clearBatch() throws SQLException {
            delegate.clearBatch();
        }

        public void clearWarnings() throws SQLException {
            delegate.clearWarnings();
        }

        public void close() throws SQLException {
            delegate.close();
        }

        public boolean execute(String sql, int autoGeneratedKeys) throws SQLException {
            return delegate.execute(sql, autoGeneratedKeys);
        }

        public boolean execute(String sql, int[] columnIndexes) throws SQLException {
            return delegate.execute(sql, columnIndexes);
        }

        public boolean execute(String sql, String[] columnNames) throws SQLException {
            return delegate.execute(sql, columnNames);
        }

        public boolean execute(String sql) throws SQLException {
            return delegate.execute(sql);
        }

        public int[] executeBatch() throws SQLException {
            return delegate.executeBatch();
        }

        public ResultSet executeQuery(String sql) throws SQLException {
            try {
                return delegate.executeQuery(sql);
            }
            catch (SQLException e) {
                throw new SQLException(e.getMessage() + "\nQuery was: " + sql);
            }
        }

        public int executeUpdate(String sql, int autoGeneratedKeys) throws SQLException {
            return delegate.executeUpdate(sql, autoGeneratedKeys);
        }

        public int executeUpdate(String sql, int[] columnIndexes) throws SQLException {
            return delegate.executeUpdate(sql, columnIndexes);
        }

        public int executeUpdate(String sql, String[] columnNames) throws SQLException {
            return delegate.executeUpdate(sql, columnNames);
        }

        public int executeUpdate(String sql) throws SQLException {
            try {
                return delegate.executeUpdate(sql);
            }
            catch (SQLException e) {
                throw new SQLException(e.getMessage() + "\nQuery was: " + sql);
            }
        }

        public Connection getConnection() throws SQLException {
            return delegate.getConnection();
        }

        public int getFetchDirection() throws SQLException {
            return delegate.getFetchDirection();
        }

        public int getFetchSize() throws SQLException {
            return delegate.getFetchSize();
        }

        public ResultSet getGeneratedKeys() throws SQLException {
            return delegate.getGeneratedKeys();
        }

        public int getMaxFieldSize() throws SQLException {
            return delegate.getMaxFieldSize();
        }

        public int getMaxRows() throws SQLException {
            return delegate.getMaxRows();
        }

        public boolean getMoreResults() throws SQLException {
            return delegate.getMoreResults();
        }

        public boolean getMoreResults(int current) throws SQLException {
            return delegate.getMoreResults(current);
        }

        public int getQueryTimeout() throws SQLException {
            return delegate.getQueryTimeout();
        }

        public ResultSet getResultSet() throws SQLException {
            return delegate.getResultSet();
        }

        public int getResultSetConcurrency() throws SQLException {
            return delegate.getResultSetConcurrency();
        }

        public int getResultSetHoldability() throws SQLException {
            return delegate.getResultSetHoldability();
        }

        public int getResultSetType() throws SQLException {
            return delegate.getResultSetType();
        }

        public int getUpdateCount() throws SQLException {
            return delegate.getUpdateCount();
        }

        public SQLWarning getWarnings() throws SQLException {
            return delegate.getWarnings();
        }

        public void setCursorName(String name) throws SQLException {
            delegate.setCursorName(name);
        }

        public void setEscapeProcessing(boolean enable) throws SQLException {
            delegate.setEscapeProcessing(enable);
        }

        public void setFetchDirection(int direction) throws SQLException {
            delegate.setFetchDirection(direction);
        }

        public void setFetchSize(int rows) throws SQLException {
            delegate.setFetchSize(rows);
        }

        public void setMaxFieldSize(int max) throws SQLException {
            delegate.setMaxFieldSize(max);
        }

        public void setMaxRows(int max) throws SQLException {
            delegate.setMaxRows(max);
        }

        public void setQueryTimeout(int seconds) throws SQLException {
            delegate.setQueryTimeout(seconds);
        }
        
        
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
    
    public static void close(Connection conn) {
        close(conn, null);
    }

}
