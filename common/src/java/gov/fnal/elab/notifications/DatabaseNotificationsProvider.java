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
import java.util.Collections;
import java.util.List;

public class DatabaseNotificationsProvider implements ElabNotificationsProvider {
	private static final List<Integer> EMPTY_PROJECT_LIST = Collections.emptyList();
    private static final List<ElabGroup> EMPTY_GROUP_LIST = Collections.emptyList();
    
    private Elab elab; 
    
    public void addUserNotification(List<ElabGroup> groupList, Notification n) throws ElabException {
    	addNotification(groupList, EMPTY_PROJECT_LIST, n);
    }
    
    public void addProjectNotification(List<Integer> projectList, Notification n) throws ElabException {
    	addNotification(EMPTY_GROUP_LIST, projectList, n);
    }
    
    public void addNotification(ElabGroup eg, Notification n) throws ElabException {
    	List<ElabGroup> l = new ArrayList();
    	l.add(eg);
    	addNotification(l, EMPTY_PROJECT_LIST, n);
    }

    public void addNotification(List<ElabGroup> groupList, List<Integer> projectList, Notification n) throws ElabException {
    	Connection conn = null;
        PreparedStatement psMessage = null, psState = null, psProject = null; 
        try {
            // TODO proper handling of time zones
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
//            psMessage = conn.prepareStatement(
//            		"INSERT INTO notifications.message (time, expiration, message, type, creator_research_group_id) " +
//                    "VALUES (?, ?, ?, ?, ?) RETURNING id;"); 
             		
            psMessage = conn.prepareStatement(
            		"INSERT INTO notifications.message (time, expiration, message, type) " +
                    "VALUES (?, ?, ?, ?) RETURNING id;"); 
            psState = conn.prepareStatement(
            		"INSERT INTO notifications.state (message_id, research_group_id) " +
            		"VALUES (?, ?);");
            psProject = conn.prepareStatement(
            		"INSERT INTO notifications.project_broadcast (message_id, project_id) " +
            		"VALUES (?, ?);"); 
            try {
                conn.setAutoCommit(false);
                
                psMessage.setTimestamp(1, new Timestamp(n.getCreationDate())); 
                psMessage.setTimestamp(2, new Timestamp(n.getExpirationDate())); 
                psMessage.setString(3, n.getMessage());
                psMessage.setInt(4, n.getType().getDBCode());
                //psMessage.setInt(5, n.getCreatorGroupId());
                
                ResultSet rs = psMessage.executeQuery(); 
                if (rs.next()) {
                	n.setId(rs.getInt(1));
                }
                else {
                	throw new SQLException(); 
                }
                
                if (n.isBroadcast()) {
                	//For messages that broadcast to all groups associated with a project
                	for (int projectId : projectList) {
                		psProject.setInt(1, projectId);
                		psProject.setInt(2, n.getId());
                		psProject.addBatch();
                	}
                	psProject.executeBatch(); 
                }
                
                else {
                	//For messages that are specific to a user 
                	for (ElabGroup eg : groupList) {
                		psState.setInt(1, n.getId());
                		psState.setInt(2, eg.getId());
                		psState.addBatch();
                	}
                	psState.executeBatch();
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
                DatabaseConnectionManager.close(conn, psMessage, psState);
            }
        }
        */
    }
    
    public void removeNotification(ElabGroup admin, int id) throws ElabException {
        if (!admin.isAdmin()) {
            throw new ElabException("User " + admin + " is not allowed to remove notifications");
        }
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            // Magic of FKs should automatically delete referencing rows 
            ps = conn.prepareStatement("DELETE FROM notifications.message WHERE id = ?"); 
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
                
                ps = conn.prepareStatement(
                        "SELECT COUNT(id) FROM notifications.message AS m " + 
                        "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? AND pb.message_id = ? " + 
                        "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id AND s.research_group_id = ? AND s.message_id = ? " +
                        "WHERE (pb.message_id IS NOT NULL AND s.message_id IS NULL) OR (pb.message_id IS NULL AND s.message_id IS NOT NULL) ");
                		
                ps.setInt(1, elab.getId());
                ps.setInt(2, id);
                ps.setInt(3, user.getId());
                ps.setInt(4, id);

                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                	ps = conn.prepareStatement("UPDATE notifications.state SET deleted = TRUE, read = TRUE WHERE message_id = ? AND research_group_id = ?;");
        			ps.setInt(1, id);
        			ps.setInt(2, user.getId());
        			int rows = ps.executeUpdate();
        			if (rows == 0) {
        				ps = conn.prepareStatement("INSERT into notifications.state (message_id, research_group_id, read, deleted) VALUES (?, ?, ?, ?);");
		            	ps.setInt(1, id);
		            	ps.setInt(2, user.getId());
		            	ps.setBoolean(3, true);
		            	ps.setBoolean(4, true);
		            	ps.executeUpdate();
        			}
                }
                else {
                    throw new ElabException("No such notification id \"" + id + "\" + for user " + user.getName());
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
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    public void markAsRead(ElabGroup user, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
            try {
                conn.setAutoCommit(false);
                
                ps = conn.prepareStatement(
                        "SELECT COUNT(id) FROM notifications.message AS m " + 
                        "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? AND pb.message_id = ? " + 
                        "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id AND s.research_group_id = ? AND s.message_id = ? " +
                        "WHERE (pb.message_id IS NOT NULL AND s.message_id IS NULL) OR (pb.message_id IS NULL AND s.message_id IS NOT NULL) ");
                		
                ps.setInt(1, elab.getId());
                ps.setInt(2, id);
                ps.setInt(3, user.getId());
                ps.setInt(4, id);

                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                	ps = conn.prepareStatement("UPDATE notifications.state SET read = TRUE WHERE message_id = ? AND research_group_id = ?;");
        			ps.setInt(1, id);
        			ps.setInt(2, user.getId());
        			int rows = ps.executeUpdate();
        			if (rows == 0) {
        				ps = conn.prepareStatement("INSERT into notifications.state (message_id, research_group_id, read) VALUES (?, ?, ?);");
		            	ps.setInt(1, id);
		            	ps.setInt(2, user.getId());
		            	ps.setBoolean(3, true);
		            	ps.executeUpdate();
        			}
                }
                else {
                    throw new ElabException("No such notification id \"" + id + "\" + for user " + user.getName());
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
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    public long getUnreadNotificationsCount(ElabGroup group) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(
                "SELECT COUNT(id) FROM notifications.message AS m " + 
                "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? " + 
                "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id AND s.research_group_id = ? " +
                "WHERE (pb.message_id IS NOT NULL AND pb.project_id IS NOT NULL AND s.read IS NOT TRUE);");
            ps.setInt(1, elab.getId());
            ps.setInt(2, group.getId());
            
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
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    private List<Notification> getNotifications(int groupId, int count, int elabId, boolean includeRead)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        final String WHERE_UNREAD = "WHERE (pb.message_id IS NOT NULL AND pb.project_id IS NOT NULL AND s.read IS NOT TRUE) ";
        final String WHERE_ALL  = "WHERE (pb.message_id IS NOT NULL AND s.message_id IS NULL) OR (pb.message_id IS NULL AND s.message_id IS NOT NULL) ";
        
        String sql = 
            "SELECT * FROM notifications.message AS m " + 
            "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? " + 
            "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id AND s.research_group_id = ? ";
        if (includeRead) {
        	sql += WHERE_ALL;
        }
        else { 
        	sql += WHERE_UNREAD; 
        }
        
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = conn.prepareStatement(sql); 
            ps.setInt(1, elab.getId());
            ps.setInt(2, groupId);
            ResultSet rs = ps.executeQuery();
            
            List<Notification> l = new ArrayList<Notification>();
            while (rs.next()) {
                boolean read = rs.getObject("read") == null ? false : (Boolean) rs.getObject("read");
                boolean deleted = rs.getObject("deleted") == null ? false : (Boolean) rs.getObject("deleted");
            	Notification n = new Notification(rs.getInt("id"), rs.getString("message"), groupId, 
            			rs.getTimestamp("time").getTime(), rs.getTimestamp("expiration").getTime(),
            			rs.getInt("type"), read, deleted); 
            	l.add(n);
            }
            return l;
            
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    @Override
    public void setElab(Elab elab) {
        this.elab = elab;
    }

	@Override
	public List<Notification> getNotifications(ElabGroup group, int max)
			throws ElabException {
		return getNotifications(group.getId(), max, elab.getId(), false);
	}

	@Override
	public List<Notification> getNotifications(ElabGroup group, int max,
			boolean includeOld) throws ElabException {
		return getNotifications(group.getId(), max, elab.getId(), includeOld);
	}

	@Override
	public void markAsRead(Notification notification) {
		// TODO Auto-generated method stub
		//notification.setRead(true);
		
		Connection conn = null;
        PreparedStatement ps = null;
        boolean read = notification.isRead();
        try {
        	conn = DatabaseConnectionManager.getConnection(elab.getProperties());
        	ps = conn.prepareStatement("UPDATE notifications.state SET read = TRUE WHERE message_id = ?;");
        	ps.setInt(1, notification.getId());
        	ps.executeUpdate();
        	notification.setRead(true);
        }
        catch (SQLException e) {
        	notification.setRead(read);
        }
        finally {
        	DatabaseConnectionManager.close(conn, ps);
        }
	}

	@Override
	public List<Notification> getSystemNotifications(int count) throws ElabException {
		final List<Notification> toBeImplemented = Collections.emptyList();  
		return toBeImplemented;
	}


}
