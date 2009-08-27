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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.commons.lang.StringUtils;

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

    protected String addStudent(Statement s, ElabGroup et, ElabStudent student,
            ElabGroup group) throws SQLException, ElabException {
        String pwd = super.addStudent(s, et, student, group);
        ResultSet rs = s
                .executeQuery("SELECT id FROM research_group WHERE name = '"
                        + ElabUtil.fixQuotes(student.getGroup().getName()) + "'");
        if (!rs.next()) {
            throw new ElabException("Error retrieving the student's group from the database.");
        }
        String groupId = rs.getString("id");
        if ("cosmic".equals(elab.getName())) {
            // Connect the detector id from the teacher with the group
            // if it exists.
            s
                    .executeUpdate("INSERT INTO research_group_detectorid (research_group_id, detectorid) "
                            + "(SELECT '"
                            + ElabUtil.fixQuotes(groupId)
                            + "', detectorid FROM research_group_detectorid WHERE research_group_id = '"
                            + ElabUtil.fixQuotes(et.getId()) + "');");
        }
        return pwd;
    }

    public Collection getDetectorIds(ElabGroup group) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return getDetectorIds(s, group);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    private Collection getDetectorIds(Statement s, ElabGroup group)
            throws SQLException {
        ResultSet rs = s
                .executeQuery("SELECT detectorid FROM research_group_detectorid WHERE research_group_id = '"
                        + ElabUtil.fixQuotes(group.getId()) + "' ORDER BY detectorid;");
        List ids = new ArrayList();
        while (rs.next()) {
            ids.add(rs.getString("detectorid"));
        }
        return ids;
    }

    public void setDetectorIds(ElabGroup group, Collection<String> detectorIds)
            throws ElabException {
        // maybe when I grow up I'll know how to do this better
    	// we have grown up now :) -pxn
        System.out.println(detectorIds);
        Connection conn = null;
        PreparedStatement ps = null;
        Savepoint svpt = null; 
        SortedSet<Integer> ids = new TreeSet();
        int groupId = Integer.parseInt(group.getId());
        
        // validate data 
        // DAQ board serial numbers are in the following form: 
        //  OLD: 1-3 digits 
        // 5000: 108705XXX  (X: Detector sequence number) 
        // 6000:  6XXXLLLL  (L: Lot number) 
        // User is only permitted to insert detector IDs <= 4 digits 
        // i.e. 8, 56, 201, 6XXX, 5XXX, etc.  
        String message = ""; 
        
        for (String detectorId : detectorIds) {
        	String thisId = detectorId.trim();
        	if (StringUtils.isEmpty(thisId)) {
        		continue; 
        	}
        	if (thisId.length() > 4) {
        		message += detectorId + " ";
        		continue;
        	}
        	try {
        		ids.add(Integer.parseInt(thisId));
        	}
        	catch (NumberFormatException nfe) { 
                message += thisId + " "; 
	        } 
        }
        if (message.length() != 0) { 
            throw new ElabException(message); 
        } 
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());       
            boolean ac = conn.getAutoCommit();
            conn.setAutoCommit(false);
            svpt = conn.setSavepoint();
            try {
            	ps = conn.prepareStatement(
        			"DELETE FROM research_group_detectorid WHERE research_group_id = ?;");
            	ps.setInt(1, groupId);
            	ps.executeUpdate();
            	ps = conn.prepareStatement(
        			"INSERT INTO research_group_detectorid (research_group_id, detectorid) VALUES (?, ?);");
            	for (Integer i : ids) {
            		ps.setInt(1, groupId);
            		ps.setInt(2, i);
            		ps.addBatch();            		
            	}
            	ps.executeBatch();
                conn.commit();
            }
            catch(SQLException e) {
            	conn.rollback(svpt);
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
