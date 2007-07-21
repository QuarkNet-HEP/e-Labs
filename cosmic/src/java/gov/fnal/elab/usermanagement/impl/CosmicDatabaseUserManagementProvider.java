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

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

    protected String addStudent(Statement s, ElabGroup et, ElabStudent student,
            boolean createGroup) throws SQLException, ElabException {
        String pwd = super.addStudent(s, et, student, createGroup);
        ResultSet rs = s
                .executeQuery("SELECT id FROM research_group WHERE name = '"
                        + student.getGroup().getName() + "'");
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
                            + groupId
                            + "', detectorid FROM research_group_detectorid WHERE research_group_id = '"
                            + et.getId() + "');");
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
                        + group.getId() + "';");
        List ids = new ArrayList();
        while (rs.next()) {
            ids.add(rs.getString("detectorid"));
        }
        return ids;
    }

    public void setDetectorIds(ElabGroup group, Collection detectorIds)
            throws ElabException {
        // maybe when I grow up I'll know how to do this better
        System.out.println(detectorIds);
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            Collection current = getDetectorIds(s, group);
            Set toAdd = new HashSet(detectorIds);
            toAdd.removeAll(current);
            Set toRemove = new HashSet(detectorIds);
            toRemove.removeAll(current);
            boolean ac = conn.getAutoCommit();
            try {
                conn.setAutoCommit(false);
                Iterator i;
                i = toRemove.iterator();
                while (i.hasNext()) {
                    s
                            .executeUpdate("DELETE FROM research_group_detectorid WHERE research_group_id = '"
                                    + group.getId()
                                    + "' AND detectorid = '"
                                    + i.next() + "';");
                }
                i = toAdd.iterator();
                while (i.hasNext()) {
                    s
                            .executeUpdate("INSERT INTO research_group_detectorid (research_group_id, detectorid) "
                                    + "VALUES ('"
                                    + group.getId()
                                    + "', '"
                                    + i.next() + "');");
                }
                conn.commit();
            }
            finally {
                conn.rollback();
                conn.setAutoCommit(ac);
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
}
