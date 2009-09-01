/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.password.GeneratePassword;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import org.apache.commons.lang.StringUtils;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
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

    private String switchingElabs(Connection c, String username, String password)
            throws SQLException, AuthenticationException {
        if (SWITCHING_ELABS.equals(password)) {            
            PreparedStatement ps = c.prepareStatement(
            		"SELECT password FROM research_group WHERE name = ?;");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
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

    private void checkResearchGroup(Connection c, ElabGroup user,
            int projectID) throws SQLException, AuthenticationException {
    	PreparedStatement ps = c.prepareStatement(
    			"SELECT research_group_project.project_id "
    			+ "FROM research_group_project "
    			+ "WHERE research_group_project.project_id = ? "
    			+ "AND research_group_project.research_group_id = ?;");
    	ps.setInt(1, projectID);
    	ps.setInt(2, Integer.parseInt(user.getGroup().getId()));
        ResultSet rs = ps.executeQuery();
        if (!rs.next() && !user.isTeacher() && !user.isAdmin()) {
            throw new AuthenticationException(
                    "Your group is not associated with this project. "
                            + "Contact the person who entered your "
                            + "group into the database and tell them this.");
        }
    }

    private void updateUsage(Connection c, ElabGroup user) throws SQLException {
    	PreparedStatement ps = c.prepareStatement("INSERT INTO usage (research_group_id) VALUES (?);");
    	ps.setInt(1, Integer.parseInt(user.getGroup().getId()));
    	int rows = ps.executeUpdate();
        if (rows != 1) {
            // logging?
            System.out.println("Weren't able to add statistics info "
                    + "to the database! " + rows + " rows updated. GroupID: "
                    + user.getGroup().getId() + "\n");
        }
    }

    private ElabGroup createUser(Connection c, String username, String password,
            String projectId) throws SQLException, AuthenticationException {
    	PreparedStatement ps = c.prepareStatement(
    			"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
    			"FROM research_group AS rg " +
    			"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
    			"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
    			"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
    			"WHERE rg.name = ? AND rg.password =?;");
    	ps.setString(1, username);
    	ps.setString(2, password);
    	ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new AuthenticationException("Invalid username or password");
        }

        return createUser(c, username, rs);
    }

    private ElabGroup createUser(Statement s, String username, String projectId)
            throws SQLException, ElabException {
        ResultSet rs = s.executeQuery(
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.name = '" + ElabUtil.fixQuotes(username) + "';");

        if (!rs.next()) {
            throw new ElabException("Invalid username (" + username + ")");
        }

        return createUser(s, username, rs);
    }
    
    private ElabGroup createUserById(Statement s, String id, String projectId)
            throws SQLException, ElabException {
        ResultSet rs = s.executeQuery(
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.id = '" + ElabUtil.fixQuotes(id) + "';");

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
        user.setStudy(rs.getBoolean("in_study"));
        user.setNewSurvey(rs.getBoolean("new_survey"));
        user.setNewSurveyId((Integer) rs.getObject("test_id"));
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
        ResultSet rs = s.executeQuery(
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.name = '" + ElabUtil.fixQuotes(groupName) + "';");
 
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
        user.setStudy(rs.getBoolean("in_study"));
        user.setNewSurvey(rs.getBoolean("new_survey"));
        user.setNewSurveyId((Integer) rs.getObject("test_id")); 
        setMiscGroupData(user, rs.getString("ay"), user.getUserArea());
        return user;
    }

    public void resetFirstTime(ElabGroup group) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            PreparedStatement ps = conn.prepareStatement(
            		"UPDATE research_group SET first_time='f' WHERE id = ? ;");
            ps.setInt(1, Integer.parseInt(group.getId()));
            ps.executeUpdate(); 
            group.setFirstTime(false);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }
    
    public void setTeacherInStudy(ElabGroup group) throws ElabException {
    	Connection con = null;
    	try {
    		con = DatabaseConnectionManager.getConnection(elab.getProperties());
    		java.sql.PreparedStatement ps = con.prepareStatement(
    				"UPDATE research_group SET in_study = 't', new_survey = 't' WHERE id = ?;");
    		ps.setInt(1, Integer.parseInt(group.getId()));
    		ps.execute();
    	}
    	catch (Exception e) {
    		throw new ElabException(e);
    	}
    	finally {
    		DatabaseConnectionManager.close(con);
    	}
    }
    
    public void setTeacherInStudy(ElabGroup group, int testId) throws ElabException {
    	Connection con = null;
    	try {
    		setTeacherInStudy(group);
    		con = DatabaseConnectionManager.getConnection(elab.getProperties());
    		java.sql.PreparedStatement ps = con.prepareStatement(
    				"INSERT INTO research_group_test (research_group_id, test_id) " + 
    				"SELECT ?, ? WHERE NOT EXISTS " +
    					"(SELECT research_group_id, test_id FROM research_group_test " + 
    					"WHERE research_group_id = ? AND test_id = ?)" + 
					";");
    		ps.setInt(1, Integer.parseInt(group.getId()));
    		ps.setInt(2, testId);
    		ps.setInt(3, Integer.parseInt(group.getId()));
    		ps.setInt(4, testId);
    		ps.execute();
    	}
    	catch (Exception e) {
    		throw new ElabException(e);
    	}
    	finally {
    		DatabaseConnectionManager.close(con);
    	}
    }

    protected void setMiscGroupData(ElabGroup group, String ay, String userArea) {
        if (userArea != null) {
            String[] sp = userArea.split("/");
            if (StringUtils.isBlank(ay)) {
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
                    if (StringUtils.isNotBlank(rs.getString("rguserarea"))) {
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

        rs = s.executeQuery("SELECT name, email, authenticator, forum_id FROM teacher WHERE id = '"
                + teacherId + "'");
        if (!rs.next()) {
            // TODO Apparently not having teacher data in the DB is a valid
            // situation?!?
            // throw new SQLException("Invalid teacher id: " + teacherId);
        }
        else {
            user.setEmail(rs.getString("email"));
            user.setAuthenticator(rs.getString("authenticator"));
            user.setForumId((Integer)rs.getObject("forum_id"));
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

        rs = s.executeQuery("select name, email, authenticator, forum_id from teacher where id = '"
                + teacherId + "'");
        if (!rs.next()) {
            throw new SQLException("Invalid teacher id: " + teacherId);
        }
        ElabGroup t = new ElabGroup(elab, this);
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setId(teacherId);
        t.setAuthenticator(rs.getString("authenticator"));
        t.setForumId((Integer) rs.getObject("forum_id"));

        rs = s
                .executeQuery("select name, userarea from research_group where teacher_id = '"
                        + teacherId + "'");

        while (rs.next()) {
            ElabGroup g = new ElabGroup(elab, this);
            if (StringUtils.isNotBlank(rs.getString("userarea"))) {
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
        Connection con = s.getConnection();
        
        GeneratePassword rp;  
        
        // Create a research group if needed
        if (groupToCreate != null) {
        	rp = new GeneratePassword();
        	pass = rp.getPassword();
        	
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
            
            /* Eventual replacement of raw SQL with proper prepared statements 
             * 
            PreparedStatement insertGroup = con.prepareStatement(
            		"INSERT INTO research_group " +
            		"(name, password, teacher_id, role, userarea, ay, survey, new_survey, in_study) " +
            		"VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);");
            insertGroup.setString(1, group.getName());
            insertGroup.setString(2, pass);
            insertGroup.setInt(3, Integer.parseInt(et.getTeacherId()));
            insertGroup.setString(4, group.isUpload() ? "upload" : "user");
            insertGroup.setString(5, group.getUserArea());
            insertGroup.setString(6, ay);
            insertGroup.setBoolean(7, group.getSurvey());
            insertGroup.setBoolean(8, group.isNewSurvey());
            insertGroup.setBoolean(9, group.isStudy());
            
            insertGroup.executeUpdate();
            */
            
            s
                    .executeUpdate("insert into research_group(name, password, teacher_id, "
                            + "role, userarea, ay, survey, new_survey, in_study) "
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
                            + ay + "', '" + group.getSurvey() 
                            + "','"
                            + (group.isNewSurvey() ? "t" : "f")
                            + "','"
                            + (group.isStudy()? "t" : "f")
                            + "')");
            
            /*
            PreparedStatement insertProject = con.prepareStatement(
            		"INSERT INTO research_group_project " +
            		"(research_group_id, project_id) " +
            		"VALUES((SELECT id FROM research_group WHERE name = ?), ?);)");
            insertProject.setString(1, group.getName());
            insertProject.setInt(2, Integer.parseInt(elab.getId()));
            */
            
            s
                    .executeUpdate("insert into research_group_project(research_group_id, project_id) "
                            + "values((select id from research_group where name = '"
                            + ElabUtil.fixQuotes(group.getName())
                            + "'), "
                            + elab.getId() + ")");
            
            
            if (groupToCreate.isNewSurvey() == true) {
            	s.executeUpdate("INSERT INTO research_group_test (research_group_id, test_id) "
            			+ "values((select id from research_group where name ilike '"
                        + ElabUtil.fixQuotes(group.getName())
                        + "'), "
                        + groupToCreate.getNewSurveyId().toString() + ");");
            }

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
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            boolean pass = false; 
            String sql = "UPDATE research_group SET ay = ?, role = ?, survey = ?, new_survey = ?";
            if (StringUtils.isNotBlank(password)) {
            	sql += ", password = ? ";
            	pass = true;
            }
            sql += "WHERE id = ?;";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, group.getYear());
            ps.setString(2, group.getRole());
            ps.setBoolean(3, group.getSurvey());
            ps.setBoolean(4, group.isNewSurvey());
            if (pass) {
            	ps.setString(5, password);
            	ps.setString(6, group.getId());
            }
            else {
            	ps.setString(5, group.getId());
            }
            
            ps.executeUpdate();
            
            if (group.isNewSurvey()) {
            	PreparedStatement ps2 = conn.prepareStatement("INSERT INTO research_group_test (research_group_id, test_id) " + 
				"SELECT ?, ? WHERE NOT EXISTS " +
					"(SELECT research_group_id, test_id FROM research_group_test " + 
					"WHERE research_group_id = ? AND test_id = ?)" + 
				";");
            	ps2.setInt(1, Integer.parseInt(group.getId()));
            	ps2.setInt(2, group.getNewSurveyId());
            	ps2.setInt(3, Integer.parseInt(group.getId()));
            	ps2.setInt(4, group.getNewSurveyId());
            	ps2.executeUpdate();
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
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
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            PreparedStatement ps = conn.prepareStatement(
            		"SELECT * FROM research_group_student WHERE research_group_id = ? AND student_id = ?");
            ps.setInt(1, Integer.parseInt(group.getId()));
            ps.setInt(2, Integer.parseInt(id));
            ResultSet rs = ps.executeQuery();

            return rs.next();
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    /**
     * A backdoor for running direct queries on the database. Obviously, it
     * should not be used.
     */
    public ResultSet runQuery(String query) throws SQLException {
        Statement s = null;
        Connection conn = null;
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
