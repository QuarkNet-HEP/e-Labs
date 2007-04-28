/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabTeacher;
import gov.fnal.elab.ElabUser;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabUtil;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class DatabaseUserManagementProvider implements
        ElabUserManagementProvider {

    public static final String SWITCHING_ELABS = "switchingelabs";

    private Elab elab;

    public DatabaseUserManagementProvider(Elab elab) {
        this.elab = elab;
    }

    public ElabUser authenticate(String username, String password,
            String projectId) throws AuthenticationException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
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

        ElabUser user = new ElabUser(elab, this);
        user.setName(username);
        ElabGroup group = new ElabGroup();
        group.setId(rs.getString("id"));
        // The group name seems to be the same as the user name
        group.setName(user.getName());
        user.setGroup(group);
        user.setTeacherId(rs.getString("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getString("survey"));
        if (user.getSurvey() == null) {
            user.setSurvey("f");
        }
        user.setUserArea(rs.getString("userarea"));
        setMiscGroupData(group, user.getUserArea());
        return user;
    }

    public void resetFirstTime(String groupId) throws SQLException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            s.executeUpdate("UPDATE research_group "
                    + "SET first_time='f' WHERE id = \'" + groupId + "\';");
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    protected void setMiscGroupData(ElabGroup group, String userArea) {
        if (userArea != null) {
            String[] sp = userArea.split("/");
            group.setYear(sp[0]);
            group.setState(sp[1].replace('_', ' ')); // useful for metadata
            // searches if the
            // state, city, school,
            // and teacher have
            // spaces instead of
            // underscores
            group.setCity(sp[2].replace('_', ' '));
            group.setSchool(sp[3].replace('_', ' '));
            group.setTeacher(sp[4].replace('_', ' '));
            // groupName = sp[5];
        }
    }

    public Collection getTeachers() throws SQLException {
        Statement s = null;
        Connection conn = null;
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            rs = s
                    .executeQuery("SELECT id as projectid from project where name='"
                            + elab.getName() + "';");
            int projectId = 1; // default to Cosmic
            if (rs.next()) {
                projectId = rs.getInt("projectid");
            }
            rs = s
                    .executeQuery("SELECT distinct teacher.name as tname, teacher.email as temail, "
                            + "research_group.name as rgname, research_group.userarea as rguserarea "
                            + "FROM teacher, research_group "
                            + "WHERE research_group.teacher_id = teacher.id "
                            + "AND research_group.id in "
                            + "(Select distinct research_group_id from research_group_project where "
                            + " research_group_project.project_id ='"
                            + projectId + "') ORDER BY tname ASC;");
            List teachers = new ArrayList();
            // the first one is a dummy, but it makes the code below less
            // cluttered
            ElabTeacher t = new ElabTeacher(elab, this);
            ElabGroup g = null;
            while (rs.next()) {
                String name = rs.getString("tname");
                if (name.equals(t.getName())) {
                    ElabGroup n = new ElabGroup();
                    n.setCity(g.getCity());
                    n.setSchool(g.getSchool());
                    n.setState(g.getState());
                    g = n;
                }
                else {
                    t = new ElabTeacher(elab, this);
                    t.setName(name);
                    t.setEmail(rs.getString("temail"));
                    g = new ElabGroup();
                    if (rs.getString("rguserarea") != null
                            && !rs.getString("rguserarea").equals("")) {
                        String[] brokenSchema = rs.getString("rguserarea")
                                .split("/");
                        if (brokenSchema != null) {
                            g.setSchool(brokenSchema[3].replaceAll("_", " "));
                            g.setCity(brokenSchema[2].replaceAll("_", " "));
                            g.setState(brokenSchema[1].replaceAll("_", " "));
                        }
                    }
                    teachers.add(t);
                }
                g.setName(rs.getString("rgname"));
                t.addGroup(g);
            }
            return teachers;
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    /**
     * A backdoor for running direct queries on the database
     */
    public ResultSet runQuery(String query) throws SQLException {
        Statement s = null;
        Connection conn = null;
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return s.executeQuery(query);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
}
