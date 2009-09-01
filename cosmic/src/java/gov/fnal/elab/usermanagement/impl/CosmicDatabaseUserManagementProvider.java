/*
 * Created on Jun 28, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.CosmicElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class CosmicDatabaseUserManagementProvider extends
        DatabaseUserManagementProvider implements
        CosmicElabUserManagementProvider {

    public CosmicDatabaseUserManagementProvider() {
    }

    public ElabGroup authenticate(String username, String password)
            throws AuthenticationException {
        ElabGroup group = super.authenticate(username, password);
        try {
            group.setAttribute("cosmic:detectorIds", getDetectorIds(group));
        }
        catch (ElabException e) {
            throw new AuthenticationException(e);
        }
        return group;
    }

    protected String addStudent(Connection c, ElabGroup et, ElabStudent student,
            ElabGroup group) throws SQLException, ElabException {
        String pwd = super.addStudent(c, et, student, group);
        PreparedStatement ps = c.prepareStatement(
        		"SELECT id FROM research_group WHERE name = ?;");
        ps.setString(1, student.getGroup().getName());
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new ElabException("Error retrieving the student's group from the database.");
        }
        int groupId = rs.getInt("id");
        if ("cosmic".equals(elab.getName())) {
            // Connect the detector id from the teacher with the group
            // if it exists.
        	ps = c.prepareStatement(
        			"INSERT INTO research_group_detectorid (research_group_id, detectorid) "
                    + "(SELECT ?, detectorid FROM research_group_detectorid WHERE research_group_id = ?);");
        	ps.setInt(1, groupId);
        	ps.setInt(2, et.getId());
        }
        ps.close();
        return pwd;
    }

    public Collection getDetectorIds(ElabGroup group) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            return getDetectorIds(conn, group);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    private Collection getDetectorIds(Connection c, ElabGroup group)
            throws SQLException {
    	PreparedStatement ps = c.prepareStatement(
    			"SELECT detectorid FROM research_group_detectorid WHERE research_group_id = ?;");
    	ps.setInt(1, group.getId());
    	ResultSet rs = ps.executeQuery();
        List ids = new ArrayList();
        while (rs.next()) {
            ids.add(rs.getString("detectorid"));
        }
        ps.close();
        return ids;
    }

    public void setDetectorIds(ElabGroup group, Collection detectorIds)
            throws ElabException {
        // maybe when I grow up I'll know how to do this better
        System.out.println(detectorIds);
        Connection conn = null;
        PreparedStatement ps = null; 
        
        // validate data 
        // DAQ board serial numbers are in the following form: 
        //  OLD: 1-3 digits 
        // 5000: 108705XXX  (X: Detector sequence number) 
        // 6000:  6XXXLLLL  (L: Lot number) 
        // User is only permitted to insert detector IDs <= 4 digits 
        // i.e. 8, 56, 201, 6XXX, 5XXX, etc.  
        String message = ""; 
        for (Iterator it = detectorIds.iterator(); it.hasNext(); ) { 
        	String thisID = ((String) it.next()).trim(); 
	         
	        // Easy check since DAQ IDs are <= 4 chars  
	        if (thisID.length() > 4) { 
                message += thisID + " ";  
                continue; 
	        } 
	         
	        // Is this four-character string even a number?  
	        try { 
                Integer.parseInt(thisID); 
	        } 
	        catch (NumberFormatException nfe) { 
                message += thisID + " "; 
	        } 
        } 
        if (message.length() != 0) { 
            throw new ElabException(message); 
        } 
        
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            Collection current = getDetectorIds(conn, group);
            Set toAdd = new HashSet(detectorIds);
            toAdd.removeAll(current);
            Set toRemove = new HashSet(current);
            toRemove.removeAll(detectorIds);
            boolean ac = conn.getAutoCommit();
            try {
                conn.setAutoCommit(false);
                Iterator i;
                i = toRemove.iterator();
                ps = conn.prepareStatement(
                		"DELETE FROM research_group_detectorid " +
                		"WHERE research_group_id = ? AND detectorid = ?;");
                while (i.hasNext()) {
                	ps.setInt(1, group.getId());
                	ps.setInt(2, (Integer) i.next());
                	ps.executeUpdate();
                }
                i = toAdd.iterator();
                ps = conn.prepareStatement(
                		"INSERT INTO research_group_detectorid (research_group_id, detectorid) " + 
                		"VALUES (?, ?);");
                while (i.hasNext()) {
                	 ps.setInt(1, group.getId());
                     ps.setInt(2, (Integer) i.next());
                     ps.executeUpdate();
                }
                conn.commit();
            }
            catch (SQLException se) {
            	conn.rollback();
            }
            finally {
                conn.setAutoCommit(ac);
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }
}
