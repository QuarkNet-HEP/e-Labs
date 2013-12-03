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
            psMessage = conn.prepareStatement(
            		"INSERT INTO notifications.message (time, expiration, message, type, creator_research_group_id) " +
                    "VALUES (?, ?, ?, ?, ?) RETURNING id;"); 
            psState = conn.prepareStatement(
            		"INSERT INTO notifications.state (research_group_id, message_id) " +
            		"VALUES (?, ?);");
            psProject = conn.prepareStatement(
            		"INSERT INTO notifications.project_broadcast (project_id, message_id) " +
            		"VALUES (?, ?);"); 
            try {
                conn.setAutoCommit(false);
                
                psMessage.setTimestamp(1, new Timestamp(n.getCreationDate())); 
                psMessage.setTimestamp(2, new Timestamp(n.getExpirationDate())); 
                psMessage.setString(3, n.getMessage());
                psMessage.setInt(4, n.getType().getDBCode());
                psMessage.setInt(5, n.getCreatorGroupId());
                
                ResultSet rs = psMessage.executeQuery(); 
                if (rs.next()) {
                	n.setId(rs.getInt(1));
                }
                else {
                	throw new SQLException(); 
                }
                
                if (n.isBroadcast()) {
                	/* For messages that broadcast to all groups associated with a project */
                	for (int projectId : projectList) {
                		psProject.setInt(1, projectId);
                		psProject.setInt(2, n.getId());
                		psProject.execute();
                		//psProject.addBatch();
                	}
                	//psProject.executeBatch(); 
                }
                
                else {
                	/* For messages that are specific to a user */ 
                	for (ElabGroup eg : groupList) {
                		psState.setInt(1, eg.getId());
                		psState.setInt(2, n.getId());
                		psState.execute();
                		//psState.addBatch();
                	}
                	//psState.executeBatch();
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
    	/*
        Connection conn = null;
        PreparedStatement ps = null;
        try {
        	String WHERE_ADMIN = "WHERE s.read IS NOT TRUE AND  m.expiration > now();";
        	String WHERE = "WHERE s.read IS NOT TRUE AND  m.expiration > now() AND s.research_group_id = ? ;";
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            String sql = 
                    "SELECT COUNT(id) FROM notifications.message AS m " + 
                    "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? " + 
                    "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id ";
                    //"WHERE (pb.message_id IS NOT NULL AND pb.project_id IS NOT NULL AND s.read IS NOT TRUE) AND  m.expiration > now();");
            		//"WHERE s.read IS NOT TRUE AND  m.expiration > now();");
                if (group.getId() == 23) {
                	sql += WHERE_ADMIN;
                } else {
                	sql += WHERE;
                }
            	ps = conn.prepareStatement(sql);
                ps.setInt(1, elab.getId());
                if (group.getId() != 23) {
                    ps.setInt(2, group.getId());            
                }

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
        */
    	long notificationCount = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        //SQL for notification that have been broadcast
        String sql = getNotificationSQL(group.getId(), false, true);

        //SQL for notifications that are just for this group
        String sqlGroup = getNotificationSQLGroup(group.getId(), false, true);
            
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = conn.prepareStatement(sql); 
            ps.setInt(1, elab.getId());
            ps.setInt(2, group.getId());
            if (group.getId() == 23) {
            	ps.setInt(3, group.getId());
            }
            ResultSet rs = ps.executeQuery();
            
            List<Notification> l = new ArrayList<Notification>();
            while (rs.next()) {
            	notificationCount++;
            }
            
            ps = conn.prepareStatement(sqlGroup); 
           	ps.setInt(1, group.getId());
            ResultSet rsGroup = ps.executeQuery();
            while (rsGroup.next()) {
            	notificationCount++;
            }           
            return notificationCount;
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
        //SQL for notification that have been broadcast
        String sql = getNotificationSQL(groupId, includeRead, false);
        //SQL for notifications that are just for this group
        String sqlGroup = getNotificationSQLGroup(groupId, includeRead, false);
        
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
                int creatorGroupId = rs.getInt("creator_research_group_id");
                int addresseeId = rs.getInt("research_group_id");
            	Notification n = new Notification(rs.getInt("id"), rs.getString("message"), groupId, 
            			rs.getTimestamp("time").getTime(), rs.getTimestamp("expiration").getTime(),
            			rs.getInt("type"), read, deleted); 
            	if (creatorGroupId > 0) {
            		n.setSender(getSender(creatorGroupId));
            	}
           		l.add(n);
            }
            
            ps = conn.prepareStatement(sqlGroup); 
            if (groupId != 23) {
            	ps.setInt(1, groupId);
            }
            ResultSet rsGroup = ps.executeQuery();
            while (rsGroup.next()) {
                boolean read = rsGroup.getObject("read") == null ? false : (Boolean) rsGroup.getObject("read");
                boolean deleted = rsGroup.getObject("deleted") == null ? false : (Boolean) rsGroup.getObject("deleted");
                int creatorGroupId = rsGroup.getInt("creator_research_group_id");
                int addresseeId = rsGroup.getInt("research_group_id");
                Notification n = new Notification(rsGroup.getInt("id"), rsGroup.getString("message"), groupId, 
            			rsGroup.getTimestamp("time").getTime(), rsGroup.getTimestamp("expiration").getTime(),
            			rsGroup.getInt("type"), read, deleted); 
            	if (creatorGroupId > 0) {
            		n.setSender(getSender(creatorGroupId));
            	}
            	if (!exists(l,n)) {
            		l.add(n);
            	}
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
   
    protected boolean exists(List<Notification> nList, Notification n) {
    	boolean exists = false;
    	for (Notification notification: nList) {
    		if (notification.getId() == n.getId()) {
    			exists = true;
    		}
    	}
    	return exists;
    }//end of exists
    
    private String getNotificationSQL(int groupId, boolean includeRead, boolean forCount) {
        final String WHERE_UNREAD = "WHERE m.type = 0 and (pb.message_id IS NOT NULL AND pb.project_id IS NOT NULL and s.read IS NOT TRUE and s.deleted is not TRUE) ";
        final String WHERE_ALL  = "WHERE m.type = 0 and (pb.message_id IS NOT NULL AND s.message_id IS NULL) OR (pb.message_id IS NULL AND s.message_id IS NOT NULL and s.deleted is not TRUE) ";
        String WHERE_UNREAD_ADMIN = "WHERE (pb.message_id IS NOT NULL AND pb.project_id IS NOT NULL and s.read IS NOT TRUE) ";
        String WHERE_ALL_ADMIN = "WHERE (pb.message_id IS NOT NULL AND s.message_id IS NULL) OR (pb.message_id IS NULL AND s.message_id IS NOT NULL) ";
        if (forCount) {
        	WHERE_UNREAD_ADMIN += "AND s.research_group_id = ? ";
        }
        //SQL for notification that have been broadcast
        String sql = "";
        sql = "SELECT * FROM notifications.message AS m " + 
              "LEFT OUTER JOIN notifications.project_broadcast AS pb ON m.id = pb.message_id AND project_id = ? " + 
              "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id AND s.research_group_id = ? ";
        if (includeRead) {
        	if (groupId == 23) {
        		sql += WHERE_ALL_ADMIN;
        	} else {
        		sql += WHERE_ALL;
        	}
        }
        else {
        	if (groupId == 23) {
        		sql += WHERE_UNREAD_ADMIN; 
        	} else {
        		sql += WHERE_UNREAD;
        	}
        }

    	sql += "AND  m.expiration > now() ";
    	return sql;
    }// end of getNotificationSQL
    
    private String getNotificationSQLGroup(int groupId, boolean includeRead, boolean forCount) {   	
    	final String WHEREUNREAD = "WHERE m.type = 0 and (s.read IS NOT TRUE and s.deleted is not TRUE AND s.research_group_id = ? ) ";
        final String WHEREALL  = "WHERE m.type = 0 and (s.message_id IS NULL and s.deleted is not TRUE AND s.research_group_id = ?) ";        
        String WHEREUNREAD_ADMIN = "WHERE (s.read IS NOT TRUE ) ";
        String WHEREALL_ADMIN  = "WHERE (s.message_id IS NOT NULL ) ";     	
        if (forCount) {
        	WHEREUNREAD_ADMIN += "AND s.research_group_id = ? ";
        }
        //SQL for notifications that are just for this group
        String sqlGroup = "";
        sqlGroup = "SELECT * FROM notifications.message AS m " + 
        		   "LEFT OUTER JOIN notifications.state AS s ON m.id = s.message_id  ";
        	if (includeRead) {
        		if (groupId == 23) {
        			sqlGroup += WHEREALL_ADMIN;
        		} else {
        			sqlGroup += WHEREALL;
        		}
            }
            else { 
            	if (groupId == 23) {
            		sqlGroup += WHEREUNREAD_ADMIN; 
            	} else {
            		sqlGroup += WHEREUNREAD;
            	}
            }
            sqlGroup += "AND  m.expiration > now() " +
            			"ORDER BY m.time DESC ";
            return sqlGroup;
    }//end of getNotificationSQLGroup

    
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
	public void markAsRead(String notificationId) {
		// TODO Auto-generated method stub
		//notification.setRead(true);
		
		Connection conn = null;
        PreparedStatement ps = null;
        Notification n = getNotificationById(Integer.valueOf(notificationId));
        boolean read = n.isRead();
        try {
        	conn = DatabaseConnectionManager.getConnection(elab.getProperties());
        	ps = conn.prepareStatement("UPDATE notifications.state SET read = TRUE WHERE message_id = ?;");
        	ps.setInt(1, Integer.valueOf(notificationId));
        	ps.executeUpdate();
        	n.setRead(true);
        }
        catch (SQLException e) {
        	n.setRead(read);
        }
        finally {
        	DatabaseConnectionManager.close(conn, ps);
        }
	}
	
	@Override
	public Notification getNotificationById(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        Notification l = new Notification();
        
        String sql = 
            "SELECT * FROM notifications.message "+
        	"WHERE message.id = ? ;" ;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = conn.prepareStatement(sql); 
        	ps.setInt(1, Integer.valueOf(id));
            ResultSet rs = ps.executeQuery();
            

            while (rs.next()) {
                int creatorGroupId = rs.getInt("creator_research_group_id");
            	Notification n = new Notification(rs.getInt("id"), rs.getString("message"), rs.getInt("creator_research_group_id"), 
            			rs.getTimestamp("time").getTime(), rs.getTimestamp("expiration").getTime(),
            			rs.getInt("type"), false, false);
            	if (creatorGroupId > 0) {
            		n.setSender(getSender(creatorGroupId));
            	}
            	l = n;
            }
            
        }
        catch (SQLException e) {
            String message = e.toString();
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }	
        return l;
		
	}
	
	@Override
	public List<Notification> getSystemNotifications() throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
       
        String sql = 
            "SELECT * FROM notifications.message AS n " + 
            "INNER JOIN notifications.project_broadcast AS np ON n.id = np.message_id AND project_id = ? " + 
            "LEFT OUTER JOIN notifications.state AS s ON n.id = s.message_id " +
        	"WHERE n.type = 1 " +
        	"AND n.expiration > now() ";
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = conn.prepareStatement(sql); 
            ps.setInt(1, elab.getId());
            ResultSet rs = ps.executeQuery();
            
            List<Notification> l = new ArrayList<Notification>();
            while (rs.next()) {
                int creatorGroupId = rs.getInt("creator_research_group_id");
            	Notification n = new Notification(rs.getInt("id"), rs.getString("message"), creatorGroupId, 
            			rs.getTimestamp("time").getTime(), rs.getTimestamp("expiration").getTime(),
            			rs.getInt("type"), false, false); 
            	if (creatorGroupId > 0) {
            		n.setSender(getSender(creatorGroupId));
            	}
            	if (!exists(l,n)) {
            		l.add(n);
            	}
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
	public List<Notification> getSystemNotifications(int count) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
       
        String sql = 
            "SELECT * FROM notifications.message AS n " + 
            "LEFT OUTER JOIN notifications.project_broadcast AS np ON n.id = np.message_id AND project_id = ? " + 
            "LEFT OUTER JOIN notifications.state AS s ON n.id = s.message_id " +
        	"WHERE n.type = 1 " +
            "ORDER BY n.time DESC ";
        	if (count > -1) {
        		sql += "LIMIT " + String.valueOf(count);
        	} else {
        		sql += "LIMIT 50";
        	}
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = conn.prepareStatement(sql); 
            ps.setInt(1, elab.getId());
            ResultSet rs = ps.executeQuery();
            
            List<Notification> l = new ArrayList<Notification>();
            while (rs.next()) {
                int creatorGroupId = rs.getInt("creator_research_group_id");
            	Notification n = new Notification(rs.getInt("id"), rs.getString("message"), creatorGroupId, 
            			rs.getTimestamp("time").getTime(), rs.getTimestamp("expiration").getTime(),
            			rs.getInt("type"), false, false); 
            	if (creatorGroupId > 0) {
            		n.setSender(getSender(creatorGroupId));
            	}
            	if (!exists(l,n)) {
            		l.add(n);
            	}
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
    public String getSender(int creatorId) {
		String creatorName = "";
        Connection conn = null;
        PreparedStatement ps = null;
       
        String sql = "SELECT name " +
        			"   FROM research_group " +
        			"  WHERE id = ? ";
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(sql); 
            ps.setInt(1, creatorId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
            	creatorName = rs.getString("name");
            }
            
        }
        catch (SQLException e) {
            String message = e.toString();
            System.out.println("Exception in getSender(): "+message);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }	
		
		return creatorName;
	}

}
