/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProperties;
import gov.fnal.elab.ElabUser;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabUtil;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseUserManagementProvider implements
        ElabUserManagementProvider {

    public static final String SWITCHING_ELABS = "switchingelabs";

    private ElabProperties properties;

    public DatabaseUserManagementProvider(ElabProperties properties) {
        this.properties = properties;
    }

    public ElabUser authenticate(String username, String password,
            String projectId) throws AuthenticationException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(properties);
            s = conn.createStatement();
            ResultSet rs;
            password = switchingElabs(s, username, password);
            ElabUser user = createUser(s, username, password, projectId);
            checkResearchGroup(s, user, projectId);
            updateUsage(s, user);
            return user;
        }
        catch (SQLException e) {
            throw new AuthenticationException("Database error: "
                    + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    private String switchingElabs(Statement s, String username, String password)
            throws SQLException, AuthenticationException {
        if (SWITCHING_ELABS.equals(password)) {
            ResultSet rs;
            rs = s.executeQuery("SELECT password FROM research_group "
                    + "WHERE name='" + ElabUtil.fixQuotes(username) + "';");
            if (!rs.next()) {
                throw new AuthenticationException(
                        "Invalid username or password");
            }
            else {
                return rs.getString("password");
            }
        }
        else {
            return password;
        }
    }

    private void checkResearchGroup(Statement s, ElabUser user, String projectID)
            throws SQLException, AuthenticationException {
        ResultSet rs;
        rs = s.executeQuery("SELECT research_group_project.project_id "
                + "FROM research_group_project "
                + "WHERE research_group_project.project_id='" + projectID
                + "' and research_group_project.research_group_id='"
                + user.getGroup().getId() + "';");
        if (!rs.next() && !user.isTeacher() && !user.isAdmin()) {
            throw new AuthenticationException(
                    "Your group is not associated with this project. "
                            + "Contact the person who entered your "
                            + "group into the database and tell them this.");
        }
    }

    private void updateUsage(Statement s, ElabUser user) throws SQLException {
        int rows = s.executeUpdate("INSERT INTO usage (research_group_id) "
                + "VALUES(" + user.getGroup().getId() + ");");
        if (rows != 1) {
            // logging?
            System.out.println("Weren't able to add statistics info "
                    + "to the database! " + rows + " rows updated. GroupID: "
                    + user.getGroup().getId() + "\n");
        }
    }

    private ElabUser createUser(Statement s, String username, String password,
            String projectId) throws SQLException, AuthenticationException {
        ResultSet rs;
        rs = s.executeQuery("SELECT id, teacher_id, role, userarea, "
                + "survey, first_time FROM research_group WHERE name='"
                + ElabUtil.fixQuotes(username) + "' AND password='"
                + ElabUtil.fixQuotes(password) + "';");
        if (!rs.next()) {
            throw new AuthenticationException("Invalid username or password");
        }

        ElabUser user = new ElabUser(this);
        user.setName(username);
        ElabGroup group = new ElabGroup();
        group.setId(rs.getString("id"));
        //The group name seems to be the same as the user name
        group.setName(user.getName());
        user.setGroup(group);
        user.setTeacherId(rs.getString("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getString("survey"));
        if (user.getSurvey() == null) {
            user.setSurvey("f");
        }
        user.setUserArea(rs.getString("userarea"));
        user.setUserDir(ElabUtil.pathcat(
                properties.getProperty("portal.users"), user.getUserArea()));
        user.setUserDirURL(ElabUtil.urlcat("users", user.getUserArea()));
        return user;
    }

    public void resetFirstTime(String groupId)
            throws SQLException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(properties);
            s = conn.createStatement();
            s.executeUpdate("UPDATE research_group "
                    + "SET first_time='f' WHERE id = \'" + groupId + "\';");
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }

    }
}
