/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import java.io.File;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.Ostermiller.util.RandPass;

public class DatabaseUserManagementProvider implements
        ElabUserManagementProvider, ElabProvider {

    public static final String SWITCHING_ELABS = "switchingelabs";

    protected Elab elab;

    public DatabaseUserManagementProvider() {
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public ElabGroup authenticate(String username, String password)
            throws AuthenticationException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs;
            password = switchingElabs(s, username, password);
            ElabGroup user = createUser(s, username, password, elab.getId());
            checkResearchGroup(s, user, elab.getId());
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

    private void checkResearchGroup(Statement s, ElabGroup user,
            String projectID) throws SQLException, AuthenticationException {
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

    private void updateUsage(Statement s, ElabGroup user) throws SQLException {
        int rows = s.executeUpdate("INSERT INTO usage (research_group_id) "
                + "VALUES(" + user.getGroup().getId() + ");");
        if (rows != 1) {
            // logging?
            System.out.println("Weren't able to add statistics info "
                    + "to the database! " + rows + " rows updated. GroupID: "
                    + user.getGroup().getId() + "\n");
        }
    }

    private ElabGroup createUser(Statement s, String username, String password,
            String projectId) throws SQLException, AuthenticationException {
        ResultSet rs;
        rs = s.executeQuery("SELECT * FROM research_group WHERE name='"
                + ElabUtil.fixQuotes(username) + "' AND password='"
                + ElabUtil.fixQuotes(password) + "';");
        if (!rs.next()) {
            throw new AuthenticationException("Invalid username or password");
        }

        return createUser(s, username, rs);
    }

    private ElabGroup createUser(Statement s, String username, String projectId)
            throws SQLException, ElabException {
        ResultSet rs;
        rs = s.executeQuery("SELECT * FROM research_group WHERE name='"
                + ElabUtil.fixQuotes(username) + "';");
        if (!rs.next()) {
            throw new ElabException("Invalid username (" + username + ")");
        }

        return createUser(s, username, rs);
    }
    
    private ElabGroup createUserById(Statement s, String id, String projectId)
            throws SQLException, ElabException {
        ResultSet rs;
        rs = s.executeQuery("SELECT name FROM research_group WHERE id='"
                + ElabUtil.fixQuotes(id) + "';");
        if (!rs.next()) {
            throw new ElabException("Invalid user id (" + id + ")");
        }

        return createUser(s, rs.getString("name"), projectId);
    }

    private ElabGroup createUser(Statement s, String username, ResultSet rs)
            throws SQLException {
        ElabGroup user = new ElabGroup(elab, this);
        user.setName(username);
        user.setId(rs.getString("id"));
        user.setTeacherId(rs.getString("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getBoolean("survey"));
        user.setUserArea(rs.getString("userarea"));
        user.setNewSurveyId((Integer) rs.getObject("new_survey_id"));
        setMiscGroupData(user, rs.getString("ay"), user.getUserArea());
        if (user.isTeacher()) {
            addTeacherInfo(s, user);
        }
        addStudents(s, user);
        return user;
    }

    public ElabGroup getGroup(String username) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return createUser(s, username, elab.getId());
        }
        catch (SQLException e) {
            throw new ElabException("Database error: " + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
    
    public ElabGroup getGroupById(String id) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return createUserById(s, id, elab.getId());
        }
        catch (SQLException e) {
            throw new ElabException("Database error: " + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    private void addStudents(Statement s, ElabGroup group) throws SQLException {
        ResultSet rs;
        rs = s
                .executeQuery("SELECT id, name FROM student "
                        + "WHERE id IN "
                        + "(SELECT student_id FROM research_group_student WHERE research_group_id = '"
                        + group.getId() + "');");
        while (rs.next()) {
            group.addStudent(new ElabStudent(rs.getString("id"), rs
                    .getString("name")));
        }
    }

    private ElabGroup createGroup(Statement s, String groupName,
            String projectId) throws SQLException {
        ResultSet rs;
        rs = s.executeQuery("SELECT * FROM research_group WHERE name='"
                + ElabUtil.fixQuotes(groupName) + "';");

        if (!rs.next()) {
            throw new SQLException(
                    "Attempted to create a group that doesn't exist");
        }
        ElabGroup user = new ElabGroup(elab, this);
        user.setName(groupName);
        user.setId(rs.getString("id"));
        user.setTeacherId(rs.getString("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getBoolean("survey"));
        user.setUserArea(rs.getString("userarea"));
        user.setFirstTime(rs.getBoolean("first_time"));
        user.setNewSurveyId((Integer) rs.getObject("new_survey_id")); 
        setMiscGroupData(user, rs.getString("ay"), user.getUserArea());
        return user;
    }

    public void resetFirstTime(ElabGroup group) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            s.executeUpdate("UPDATE research_group "
                    + "SET first_time='f' WHERE id = \'" + group.getId()
                    + "\';");
            group.setFirstTime(false);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    protected void setMiscGroupData(ElabGroup group, String ay, String userArea) {
        if (userArea != null) {
            String[] sp = userArea.split("/");
            if (ay == null || ay.equals("")) {
                group.setYear(sp[0]);
            }
            else {
                group.setYear(ay);
            }
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

    public Collection getTeachers() throws ElabException {
        Statement s = null;
        Connection conn = null;
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            String projectId = elab.getId();
            rs = s
                    .executeQuery("SELECT distinct teacher.name as tname, teacher.email as temail, "
                            + "teacher.id as teacherid, research_group.id as id,"
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
            ElabGroup t = new ElabGroup(elab, this);
            ElabGroup g = null;
            while (rs.next()) {
                String name = rs.getString("tname");
                if (name.equals(t.getName())) {
                    g = new ElabGroup(elab, this);
                    g.setCity(t.getCity());
                    g.setSchool(t.getSchool());
                    g.setState(t.getState());
                }
                else {
                    t = new ElabGroup(elab, this);
                    t.setName(name);
                    t.setEmail(rs.getString("temail"));
                    t.setId(rs.getString("id"));
                    t.setTeacherId(rs.getString("teacherid"));
                    g = new ElabGroup(elab, this);
                    if (rs.getString("rguserarea") != null
                            && !rs.getString("rguserarea").equals("")) {
                        String[] brokenSchema = rs.getString("rguserarea")
                                .split("/");
                        if (brokenSchema != null) {
                            t.setSchool(brokenSchema[3].replaceAll("_", " "));
                            t.setCity(brokenSchema[2].replaceAll("_", " "));
                            t.setState(brokenSchema[1].replaceAll("_", " "));
                        }
                    }
                    teachers.add(t);
                }
                g.setName(rs.getString("rgname"));
                t.addGroup(g);
            }
            return teachers;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    protected void addTeacherInfo(Statement s, ElabGroup user)
            throws SQLException {
        ResultSet rs;
        String projectId = elab.getId();
        String teacherId = user.getTeacherId();
        if (teacherId == null) {
            System.out.println(user.getName() + " does not have a teacher id.");
            return;
        }
        user.getGroups().clear();

        rs = s.executeQuery("SELECT name, email FROM teacher WHERE id = '"
                + teacherId + "'");
        if (!rs.next()) {
            // TODO Apparently not having teacher data in the DB is a valid
            // situation?!?
            // throw new SQLException("Invalid teacher id: " + teacherId);
        }
        else {
            user.setEmail(rs.getString("email"));
        }

        rs = s
                .executeQuery("SELECT name FROM research_group WHERE teacher_id = '"
                        + teacherId + "'");

        // Can't do another query while iterating over a result set
        List names = new LinkedList();
        while (rs.next()) {
            names.add(rs.getString("name"));
        }
        Iterator i = names.iterator();
        while (i.hasNext()) {
            ElabGroup g = createGroup(s, (String) i.next(), elab.getId());
            System.out.println(g);
            user.addGroup(g);
            addStudents(s, g);
        }
    }

    protected ElabGroup getTeacher(String teacherId, Statement s)
            throws SQLException {
        ResultSet rs;
        String projectId = elab.getId();

        rs = s.executeQuery("select name, email from teacher where id = '"
                + teacherId + "'");
        if (!rs.next()) {
            throw new SQLException("Invalid teacher id: " + teacherId);
        }
        ElabGroup t = new ElabGroup(elab, this);
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setId(teacherId);

        rs = s
                .executeQuery("select name, userarea from research_group where teacher_id = '"
                        + teacherId + "'");

        while (rs.next()) {
            ElabGroup g = new ElabGroup(elab, this);
            if (rs.getString("userarea") != null
                    && !rs.getString("userarea").equals("")) {
                String[] brokenSchema = rs.getString("userarea").split("/");
                if (brokenSchema != null) {
                    g.setSchool(brokenSchema[3].replaceAll("_", " "));
                    g.setCity(brokenSchema[2].replaceAll("_", " "));
                    g.setState(brokenSchema[1].replaceAll("_", " "));
                }
            }

            g.setName(rs.getString("name"));
            t.addGroup(g);
        }
        return t;
    }

    public ElabGroup getTeacher(ElabGroup user) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return getTeacher(user.getTeacherId(), s);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
    
    public ElabGroup getTeacher(String id) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return getTeacher(id, s);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    protected String addStudent(Statement s, ElabGroup et, ElabStudent student,
            ElabGroup groupToCreate) throws SQLException, ElabException {
        ResultSet rs;
        ElabGroup group = student.getGroup();
        // More work to do if we haven't seen this one yet.
        String pass = null;
        if (groupToCreate != null) {
            RandPass rp = new RandPass();
            pass = rp.getPass();
            student.getGroup().setName(
                    checkConflict(s, student.getGroup().getName()));
            File tua = new File(et.getUserArea());
            group.setUserArea(new File(tua.getParentFile(), group.getName())
                    .getPath());
            // Generated a default academic year. LQ - 7-24-06
            Calendar calendar = new GregorianCalendar();
            int year = calendar.get(Calendar.YEAR);
            if (calendar.get(Calendar.MONTH) < 7) {
                year = year - 1;
            }
            String ay = "AY" + year;
            s
                    .executeUpdate("insert into research_group(name, password, teacher_id, "
                            + "role, userarea, ay, survey) "
                            + "values('"
                            + ElabUtil.fixQuotes(group.getName())
                            + "', '"
                            + ElabUtil.fixQuotes(pass)
                            + "', '"
                            + et.getTeacherId()
                            + "', '"
                            + (group.isUpload() ? "upload" : "user")
                            + "', '"
                            + ElabUtil.fixQuotes(group.getUserArea())
                            + "','"
                            + ay + "', '" + group.getSurvey() + "')");
            s
                    .executeUpdate("insert into research_group_project(research_group_id, project_id) "
                            + "values((select id from research_group where name = '"
                            + ElabUtil.fixQuotes(group.getName())
                            + "'), "
                            + elab.getId() + ")");

            String usersDir = elab.getAbsolutePath(elab.getProperties()
                    .getUsersDir());

            File f;
            f = new File(group.getDir("posters"));
            f.mkdirs();
            f = new File(group.getDir("plots"));
            f.mkdirs();
            f = new File(group.getDir("scratch"));
            f.mkdirs();
            et.addGroup(group);
        }
        else {
            boolean found = false;
            Iterator i = et.getGroups().iterator();
            while (i.hasNext()) {
                ElabGroup g = (ElabGroup) i.next();
                if (g.getName().equals(student.getGroup().getName())) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                throw new ElabException("The requested group (\""
                        + student.getGroup().getName() + "\") does not exist");
            }
        }

        // Just insert the student into the DB.
        int studentNameAddOn = 0;
        rs = s.executeQuery("select * from student where name = '"
                + ElabUtil.fixQuotes(student.getName()) + "'");
        while (rs.next()) {
            studentNameAddOn++;
            rs = s.executeQuery("select * from student where name = '"
                    + ElabUtil.fixQuotes(student.getName() + studentNameAddOn)
                    + "'");
        }
        if (studentNameAddOn > 0) {
            student.setName(student.getName() + studentNameAddOn);
        }

        s.executeUpdate("insert into student (name) values ('"
                + ElabUtil.fixQuotes(student.getName()) + "')");
        s
                .executeUpdate("insert into research_group_student(research_group_id, student_id) "
                        + "values((select id from research_group where name = '"
                        + ElabUtil.fixQuotes(group.getName())
                        + "'), "
                        + "(select id from student where name = '"
                        + ElabUtil.fixQuotes(student.getName()) + "'))");
        if (group.getSurvey()) {
            s
                    .executeUpdate("insert into survey(student_id, project_id) values("
                            + "(select id from student where name = '"
                            + ElabUtil.fixQuotes(student.getName())
                            + "'), "
                            + elab.getId() + " )");
        }
        return pass;
    }

    protected String checkConflict(Statement s, String name)
            throws SQLException, ElabException {
        String c = "";
        for (int i = 0; i < 100; i++) {
            c = i == 0 ? "" : String.valueOf(i);
            ResultSet rs = s
                    .executeQuery("select * from research_group where name = '"
                            + ElabUtil.fixQuotes(name) + c + "'");
            if (!rs.next()) {
                break;
            }
            if (i == 99) {
                throw new ElabException("Could not create group with name \""
                        + name + "\".");
            }
        }
        String newName = name + c;
        return newName;
    }

    public List addStudents(ElabGroup teacher, List students, List createGroups)
            throws ElabException {
        List passwords = new ArrayList();
        Statement s = null;
        Connection conn = null;
        if (students.size() != createGroups.size()) {
            throw new IllegalArgumentException(
                    "User list and createGroups list have different sizes");
        }
        Map groups = new HashMap();
        Iterator i = students.iterator(), j = createGroups.iterator();
        while (i.hasNext()) {
            ElabStudent student = (ElabStudent) i.next();
            ElabGroup group = student.getGroup();
            Boolean createGroup = (Boolean) j.next();
            if (createGroup.booleanValue()) {
                ElabGroup existing = (ElabGroup) groups.get(group.getName());
                if (existing == null) {
                    groups.put(group.getName(), group);
                }
                else {
                    if (group.isUpload()) {
                        existing.setRole(ElabGroup.ROLE_UPLOAD);
                    }
                    if (group.getSurvey()) {
                        existing.setSurvey(true);
                    }
                }
            }
        }
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            conn.setAutoCommit(false);
            try {
                i = students.iterator();
                while (i.hasNext()) {
                    ElabStudent student = (ElabStudent) i.next();
                    ElabGroup group = (ElabGroup) groups.remove(student.getGroup()
                            .getName());
                    passwords.add(addStudent(s, teacher, student, group));
                }
                conn.commit();
                // update the current logged in teacher with the new set of
                // groups
                addTeacherInfo(s, teacher);
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            return passwords;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public void deleteStudent(ElabGroup group, String id) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            s
                    .executeUpdate("DELETE FROM research_group_student WHERE research_group_id = '"
                            + group.getId()
                            + "' AND student_id = '"
                            + ElabUtil.fixQuotes(id) + "'");
            group.removeStudent(group.getStudent(id));
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public void updateGroup(ElabGroup group, String password)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            String passQ = "";
            if (password != null && !password.equals("")) {
                passQ = ", password = '" + ElabUtil.fixQuotes(password) + "'";
            }
            s.executeUpdate("UPDATE research_group SET ay = '"
                    + group.getYear() + "', role = '" + group.getRole()
                    + "', survey = "
                    + String.valueOf(group.getSurvey()).toUpperCase() + passQ
                    + " WHERE id = '" + group.getId() + "';");
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public Collection getProjectNames() throws ElabException {
        List names = new ArrayList();
        Statement s = null;
        Connection conn = null;

        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s.executeQuery("SELECT name FROM project;");
            while (rs.next()) {
                names.add(rs.getString("name"));
            }
            return names;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public Collection getProjectNames(ElabGroup group) throws ElabException {
        Statement s = null;
        Connection conn = null;

        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            return getProjectNames(s, group);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    private Collection getProjectNames(Statement s, ElabGroup group)
            throws SQLException {
        List names = new ArrayList();
        ResultSet rs = s
                .executeQuery("SELECT name FROM project WHERE id IN "
                        + "(SELECT project_id FROM research_group_project WHERE research_group_id = '"
                        + group.getId() + "');");
        while (rs.next()) {
            names.add(rs.getString("name"));
        }
        return names;
    }

    public void updateProjects(ElabGroup group, String[] projectNames)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            conn.setAutoCommit(false);
            conn.setSavepoint();
            try {
                Map ids = new HashMap();
                ResultSet rs = s.executeQuery("SELECT id, name FROM project");
                while (rs.next()) {
                    ids.put(rs.getString("name"), rs.getString("id"));
                }
                Collection current = getProjectNames(s, group);
                List updated = new ArrayList();
                for (int i = 0; i < projectNames.length; i++) {
                    updated.add(projectNames[i]);
                }
                Set toRemove = new HashSet(current);
                toRemove.removeAll(updated);
                Set toAdd = new HashSet(updated);
                toAdd.removeAll(current);
                Iterator i;
                i = toRemove.iterator();
                while (i.hasNext()) {
                    String id = (String) ids.get(i.next());
                    s
                            .executeUpdate("DELETE FROM research_group_project WHERE research_group_id = '"
                                    + group.getId()
                                    + "' AND project_id = '"
                                    + id + "';");
                }
                i = toAdd.iterator();
                while (i.hasNext()) {
                    String id = (String) ids.get(i.next());
                    s
                            .executeUpdate("INSERT INTO research_group_project (research_group_id, project_id) "
                                    + "VALUES ('"
                                    + group.getId()
                                    + "', '"
                                    + id
                                    + "');");
                }
                conn.commit();
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public boolean isStudentInGroup(ElabGroup group, String id)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                    .executeQuery("SELECT * FROM research_group_student WHERE research_group_id = '"
                            + group.getId()
                            + "' AND student_id = '"
                            + id
                            + "';");
            return rs.next();
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    /**
     * A backdoor for running direct queries on the database. Obviously, it
     * should not be used.
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

    public ResultSet executeQuery(String query) throws SQLException {
        return runQuery(query);
    }

    public Connection getConnection() throws SQLException {
        return DatabaseConnectionManager.getConnection(elab.getProperties());
    }

    public void closeConnection(Connection c, Statement s) {
        DatabaseConnectionManager.close(c, s);
    }
}
