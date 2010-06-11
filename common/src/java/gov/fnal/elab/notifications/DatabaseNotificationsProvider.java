/*
 * Created on Feb 26, 2010
 */
package gov.fnal.elab.notifications;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProperties;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DatabaseNotificationsProvider implements ElabNotificationsProvider {
    private Elab elab;

    public DatabaseNotificationsProvider() {
    }

    public void addNotification(ElabGroup group, Notification n) throws ElabException {
        Connection conn = null;
        try {
            // TODO proper handling of time zones
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
            try {
                conn.setAutoCommit(false);
                PreparedStatement ps;
                int shift;
                if (n.getExpires() == 0) {
                    ps = conn
                        .prepareStatement("INSERT INTO notifications (id, time, expires, recipientid, projectid, message, priority) "
                                + "VALUES (nextval('notifications_id_seq'), NOW(), NOW() + interval '1 year', ?, ?, ?, ?); SELECT currval('notifications_id_seq')");
                    shift = 0;
                }
                else {
                    ps = conn
                        .prepareStatement("INSERT INTO notifications (id, time, expires, recipientid, projectid, message, priority) "
                                + "VALUES (nextval('notifications_id_seq'), NOW(), ?, ?, ?, ?, ?); SELECT currval('notifications_id_seq')");
                    ps.setTimestamp(1, new Timestamp(n.getExpires()));
                    shift = 1;
                }
                ps.setInt(shift + 1, n.getGroupId());
                ps.setInt(shift + 2, n.getProjectId());
                ps.setString(shift + 3, n.getMessage());
                ps.setInt(shift + 4, n.getPriority());
                ps.execute();
                ps.getMoreResults();
                ResultSet rs = ps.getResultSet();
                if (rs.next()) {
                    n.setId(rs.getInt(1));
                    conn.commit();
                }
                else {
                    conn.rollback();
                    throw new ElabException("This should not be happening");
                }
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            finally {
                conn.setAutoCommit(ac);
            }
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }
    }
    
    public void removeNotification(ElabGroup admin, int id) throws ElabException {
        if (!admin.isAdmin()) {
            throw new ElabException("User " + admin + " is not allowed to remove notifications");
        }
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("DELETE FROM notifications WHERE id = ?"); 
            ps.setInt(1, id);
            ps.execute();
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    public void markAsDeleted(ElabGroup user, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
            try {
                conn.setAutoCommit(false);
                // while notification ids are globally unique, the user id
                // serves to
                // prevent accidental deletion of other user's messages
                ps = conn.prepareStatement(
                    "SELECT recipientid, deleted IS NOT NULL FROM notifications " +
                        "LEFT OUTER JOIN notifications_state ON id = notification_id AND group_id = ? " +
                        "WHERE id = ?");
                ps.setInt(1, user.getId());
                ps.setInt(2, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    Integer recipientid = (Integer) rs.getObject("recipientid");
                    boolean deletedPresent = rs.getBoolean("deleted");
                    if (recipientid == null) {
                        // broadcast; insert deletion state
                        if (deletedPresent) {
                            ps = conn.prepareStatement("UPDATE notifications_state SET deleted = TRUE " +
                                    "WHERE notification_id = ? AND group_id = ?");
                        }
                        else {
                            ps = conn
                                .prepareStatement("INSERT INTO notifications_state (notification_id, group_id, deleted) " +
                                        "VALUES (?, ?, TRUE)");
                        }
                    }
                    else if (recipientid == user.getId()) {
                        // individual notification; delete
                        ps = conn.prepareStatement("DELETE FROM notifications WHERE id = ? AND recipientid = ?");
                    }
                    else {
                        throw new ElabException("Cannot delete notification; you are not the owner");
                    }
                }
                else {
                    throw new ElabException("No such notification id: " + id);
                }
                ps.setInt(1, id);
                ps.setInt(2, user.getId());
                ps.execute();
                conn.commit();
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            finally {
                conn.setAutoCommit(ac);
            }
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }
    }

    public void markAsRead(ElabGroup group, int nid) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
            try {
            	int updateRows = 0, insertRows = 0; 
                conn.setAutoCommit(false);
                ps = conn.prepareStatement("UPDATE notifications_state SET \"read\" = TRUE " +
                		"WHERE notification_id = ? AND group_id = ?;"); 
                ps.setInt(1, nid);
                ps.setInt(2, group.getId());
                updateRows = ps.executeUpdate(); 
                if (updateRows == 0) { // Not found 
                	ps = conn.prepareStatement("INSERT INTO notifications_state (notification_id, group_id, \"read\") " +
                			"VALUES (?, ?, TRUE);");
                	ps.setInt(1, nid);
                    ps.setInt(2, group.getId());
                    insertRows = ps.executeUpdate(); 
                    if (insertRows == 0) { // Something's gone wrong 
                    	throw new SQLException("Cannot mark notification ID " + nid + " for group " + group.getName() + " as read.");
                    }
                }
                conn.commit();
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            finally {
                conn.setAutoCommit(ac);
            }
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn, ps);
            }
        }
    }

    public long getUnreadNotificationsCount(ElabGroup group) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(id) FROM notifications " +
                    "LEFT OUTER JOIN notifications_state ON id = notification_id AND group_id = ?" +
                    "WHERE (recipientid=? OR recipientid IS NULL) " +
                    "AND (projectid=? OR projectid IS NULL) " +
                    "AND expires > NOW() " +
                    "AND (\"read\" IS NOT TRUE) " +
                    "AND (deleted IS NOT TRUE)");
            ps.setInt(1, group.getId());
            ps.setInt(2, group.getId());
            ps.setInt(3, elab.getId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getLong(1);
            }
            else {
                throw new ElabException("Cannot get unread notification count for group " + group.getName());
            }
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }
    }

    public List<Notification> getNotifications(ElabGroup group, int count) throws ElabException {
        return getNotifications(group, count, false);
    }

    public List<Notification> getNotifications(ElabGroup group, int count, boolean includeRead) throws ElabException {
        return getNotifications(group.getId(), true, elab.getId(), count, includeRead);
    }

    public List<Notification> getSystemNotifications() throws ElabException {
    	Connection conn = null; 
    	PreparedStatement ps = null; 
    	try {
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());
    		ps = conn.prepareStatement(
				"SELECT id, message, time, expires, priority, \"read\" FROM notifications " + 
				"LEFT OUTER JOIN notifications_state ON id = notification_id " + 
				"WHERE (recipientid IS NULL) AND (projectid IS NULL) AND (\"read\" IS NOT TRUE) AND (deleted IS NOT TRUE) AND (expires > NOW()) " +
				"ORDER BY time;");
    		ResultSet rs = ps.executeQuery();
    		List<Notification> l = new ArrayList<Notification>();
            while (rs.next()) {
                l.add(new Notification(rs.getInt("id"), rs.getString("message"), Notification.USER_EVERYONE, Notification.USER_EVERYONE, rs.getTimestamp("time").getTime(),
                    rs.getTimestamp("expires").getTime(), rs.getInt("priority"), rs.getBoolean("read")));
            }
            return l;
    	}
    	catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn, ps);
            }
        }
    }

    private List<Notification> getNotifications(int groupid, boolean intersect, Integer elabid, int count, boolean includeRead)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            // I declare a recipientid/projectid of NULL to mean "all"
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id, message, time, expires, priority, \"read\" "
                    + "FROM notifications "
                    + "LEFT OUTER JOIN notifications_state ON id = notification_id AND group_id = ? "
                    + "WHERE ((recipientid=? OR recipientid IS NULL) "
                    + (intersect ? "AND" : "OR") + " (projectid=? OR projectid IS NULL)) "
                    + (includeRead ? "" : " AND (\"read\" IS NOT TRUE) ")
                    + "AND (deleted IS NOT TRUE) "
                    + "AND expires > NOW() "
                    + "ORDER BY time" + (count > 0 ? " LIMIT " + count : ""));
            List<Notification> l = new ArrayList<Notification>();
            ps.setInt(1, groupid);
            ps.setInt(2, groupid);
            ps.setInt(3, elabid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                l.add(new Notification(rs.getInt(1), rs.getString(2), groupid, elabid, rs.getTimestamp(3).getTime(),
                    rs.getTimestamp(4).getTime(), rs.getInt(5), rs.getBoolean(6)));
            }
            return l;
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn, ps);
            }
        }
    }

    public void markAsRead(Notification notification) {
    }

    @Override
    public void setElab(Elab elab) {
        this.elab = elab;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            if (!tableExists(conn)) {
                createTable(conn);
            }
        }
        catch (SQLException e) {
            throw new RuntimeException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }
    }

    private boolean tableExists(Connection conn) throws SQLException {
    	ResultSet rs = null;
    	Statement s = null; 
        try {
        	s  = conn.createStatement();
            rs = s.executeQuery("SELECT tablename FROM pg_tables WHERE tablename = 'notifications'");
            if (rs.next()) {
            	return true; 
            }
            return false;
        }
        catch (SQLException e) {
            return false; 
        }
        finally {
            if (s != null) {
            	s.close();
            }
        }
    }

    private void createTable(Connection conn) throws SQLException {
        synchronized (DatabaseNotificationsProvider.class) {
            Statement s = conn.createStatement();
            s.execute(
                "CREATE TABLE notifications (" +
                    "  id serial NOT NULL, " +
                    "  \"time\" timestamp with time zone NOT NULL, " +
                    "  message character varying, " +
                    "  recipientid integer, " +
                    "  projectid integer, " +
                    "  priority integer NOT NULL DEFAULT 0, " +
                    "  expires timestamp with time zone, " +
                    "  CONSTRAINT pkey PRIMARY KEY (id) " +
                    // currently the special value for projectid and recipientid
                    // of NULL means "all", 
                    /*
                     * "  CONSTRAINT project_id FOREIGN KEY (projectid) " +
                     * "    REFERENCES project (id) MATCH SIMPLE " +
                     * "    ON UPDATE NO ACTION ON DELETE NO ACTION, " +
                     * "  CONSTRAINT recipient_group FOREIGN KEY (recipientid) "
                     * + "    REFERENCES research_group (id) MATCH SIMPLE " +
                     * "    ON UPDATE NO ACTION ON DELETE CASCADE " +
                     */
                    ") " +
                    "WITHOUT OIDS;" +
                    "ALTER TABLE notifications OWNER TO "
                    + elab.getProperties().getProperty(ElabProperties.PROP_USERDB_USERNAME));
            s.execute(
                "CREATE TABLE notifications_state (" +
                    "  notification_id integer NOT NULL, " +
                    "  group_id integer NOT NULL, " +
                    "  \"read\" boolean NOT NULL DEFAULT false, " +
                    "  deleted boolean NOT NULL DEFAULT false, " +
                    "  CONSTRAINT notifications_state_pkey PRIMARY KEY (notification_id, group_id), " +
                    "  CONSTRAINT group_id FOREIGN KEY (group_id) " +
                    "    REFERENCES research_group (id) MATCH SIMPLE " +
                    "    ON UPDATE NO ACTION ON DELETE CASCADE, " +
                    "  CONSTRAINT notification_id FOREIGN KEY (notification_id) " +
                    "    REFERENCES notifications (id) MATCH SIMPLE " +
                    "    ON UPDATE NO ACTION ON DELETE CASCADE " +
                    ") " +
                    "WITHOUT OIDS;" +
                    "ALTER TABLE notifications_state OWNER TO "
                    + elab.getProperties().getProperty(ElabProperties.PROP_USERDB_USERNAME));
            s.execute(
                "CREATE INDEX notifications_state_index ON notifications_state " +
                    "  USING btree (notification_id, group_id);");
            // created automatically; though it may be better to create it
            // manually
            // since it is referenced manually
            /*
             * s.execute("CREATE SEQUENCE notifications_id_seq INCREMENT 1 MINVALUE 1 "
             * + "MAXVALUE 9223372036854775807 START 1 CACHE 1");
             */
        }
    }
}
