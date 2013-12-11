/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement.impl;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProviderHandled;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.password.GeneratePassword;
import gov.fnal.elab.usermanagement.AuthenticationException;
import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import org.apache.commons.lang.StringUtils;

import org.mindrot.BCrypt; 

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
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
import java.io.*;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;
import javax.servlet.http.*;
import javax.servlet.*;

public class DatabaseUserManagementProvider implements
        ElabUserManagementProvider, ElabProviderHandled {

    public static final String SWITCHING_ELABS = "switchingelabs";
    
    protected Elab elab;

    public DatabaseUserManagementProvider() {
    }

    @Override
    public void setElab(Elab elab) {
        this.elab = elab;
    }
    
    public ElabGroup adminAuthenticateAsOtherUser(String adminUsername, String adminPassword, String usergroup) 
    	throws AuthenticationException {
    	Connection conn = null; 
    	try {
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());
    		authenticateUserWithRole(conn, adminUsername, adminPassword, "admin");
    		ElabGroup user = createUser(conn, usergroup, null, elab.getId()); 
    		checkResearchGroup(conn, user, elab.getId());
    		updateUsage(conn, user); 
    		return user; 
    	}
    	catch (SQLException e) {
            throw new AuthenticationException("Database error: "
                    + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    public ElabGroup authenticate(String username, String password)
            throws AuthenticationException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            authenticateUser(conn, username, password); 
            ElabGroup user = createUser(conn, username, password, elab.getId());
            checkResearchGroup(conn, user, elab.getId());
            updateUsage(conn, user);
            return user;
        }
        catch (SQLException e) {
            throw new AuthenticationException("Database error: "
                    + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }
    
    private void authenticateUserWithRole(Connection c, String username, String password, String role) throws SQLException, AuthenticationException {
    	String hashedPassword;
    	String sql = "SELECT hashedpassword FROM research_group WHERE name = ?"; 
    	if (role != null) {
    		sql += " AND role = ?"; 
    	}
    	PreparedStatement psCredentials = c.prepareStatement(sql); 
    	psCredentials.setString(1, username); 
    	if (role != null) {
    		psCredentials.setString(2, role); 
    	}
    	ResultSet rsCredentials = psCredentials.executeQuery(); 
    	
    	try {
    		if (!rsCredentials.next()) { throw new AuthenticationException(); }
    		hashedPassword = rsCredentials.getString("hashedpassword");
    		if (!BCrypt.checkpw(password, hashedPassword)) { throw new AuthenticationException(); } 
    	}
    	catch(AuthenticationException ae) {
    		throw new AuthenticationException("Invalid username or password");
    	}
    	finally {
    		rsCredentials.close(); 
    		psCredentials.close(); 
    	}
    }
    
    private void authenticateUser(Connection c, String username, String password) throws SQLException, AuthenticationException {
    	authenticateUserWithRole(c, username, password, null); 
	}

    /***
     * 
     * @param c Connection to the database 
     * @param username User-supplied username 
     * @param password User-supplied password
     * @return returns the BCrypt-hashed password 
     * @throws SQLException 
     * @throws AuthenticationException
     */
    @Deprecated private String switchingElabs(Connection c, String username, String password)
            throws SQLException, AuthenticationException {
        if (SWITCHING_ELABS.equals(password)) {            
            PreparedStatement ps = c.prepareStatement(
            		"SELECT hashedpassword FROM research_group WHERE name = ?;");
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
    			"SELECT project_id FROM research_group_project " +
    			"WHERE project_id = ? AND research_group_id = ?;");
    	ps.setInt(1, projectID);
    	ps.setInt(2, user.getGroup().getId());
        ResultSet rs = ps.executeQuery();
        if (!rs.next() && !user.isTeacher() && !user.isAdmin() && !user.isGuest()) {
            throw new AuthenticationException(
                    "Your group isn't registered in this project, please tell your teacher" );
        }
        ps.close();
    }

    private void updateUsage(Connection c, ElabGroup user) throws SQLException {
    	PreparedStatement ps = c.prepareStatement("INSERT INTO usage (research_group_id) VALUES (?);");
    	ps.setInt(1, user.getGroup().getId());
     	int rows = ps.executeUpdate();
        if (rows != 1) {
            // logging?
            System.out.println("Weren't able to add statistics info "
                    + "to the database! " + rows + " rows updated. GroupID: "
                    + user.getGroup().getId() + "\n");
        }
        ps.close();
    }

    private ElabGroup createUser(Connection c, String username, String password,
            int projectId) throws SQLException, AuthenticationException {
    	PreparedStatement ps = c.prepareStatement(
    			"SELECT rg.id, rg.name, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id, rg.active " +
    			"FROM research_group AS rg " +
    			"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
    			"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
    			"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
    			"WHERE rg.name = ?;");
    	ps.setString(1, username);
    	ResultSet rs = ps.executeQuery();
        if (!rs.next()) { 
        	throw new AuthenticationException("Invalid username or password"); 
    	} 
        return createUser(c, username, rs);
    }

    private ElabGroup createUser(Connection c, String username, int projectId)
            throws SQLException, ElabException {
		PreparedStatement ps = c.prepareStatement(
        		"SELECT rg.id, rg.name, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id, rg.active " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.name = ? ;");
		ps.setString(1, username);
		ResultSet rs = ps.executeQuery();

        if (!rs.next()) {
            throw new ElabException("Invalid username (" + username + ")");
        }

        return createUser(c, username, rs);
    }
    
    private ElabGroup createUserById(Connection c, int id, int projectId)
            throws SQLException, ElabException {
    	String name = "";
        PreparedStatement ps = c.prepareStatement(
        		"SELECT rg.id, rg.name, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id, rg.active " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.id = ? ;");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
        	name = rs.getString("name");
        	ps.close();
        }
        else {
            throw new ElabException("Invalid user id (" + id + ")");
        }

        return createUser(c, name, projectId);
    }

    private ElabGroup createUser(Connection c, String username, ResultSet rs)
            throws SQLException {
        ElabGroup user = new ElabGroup(elab, this);
        user.setName(username);
        user.setId(rs.getInt("id"));
        user.setTeacherId(rs.getInt("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getBoolean("survey"));
        user.setActive(rs.getBoolean("active"));
        user.setUserArea(rs.getString("userarea"));
        user.setStudy(rs.getBoolean("in_study"));
        user.setNewSurvey(rs.getBoolean("new_survey"));
        user.setNewSurveyId((Integer) rs.getObject("test_id"));
        setMiscGroupData(user, rs.getString("ay"), user.getUserArea());
        if (user.isTeacher()) {
            addTeacherInfo(c, user);
        }
        addStudents(c, user);
        return user;
    }

    public ElabGroup getGroup(String username) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            return createUser(conn, username, elab.getId());
        }
        catch (SQLException e) {
            throw new ElabException("Database error: " + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }
    
    public ElabGroup getGroupById(int id) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            return createUserById(conn, id, elab.getId());
        }
        catch (SQLException e) {
            throw new ElabException("Database error: " + e.getMessage(), e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    private void addStudents(Connection c, ElabGroup group) throws SQLException {
        PreparedStatement ps = c.prepareStatement(
        		"SELECT s.id, s.name FROM research_group_student AS rgs " +
        		"LEFT OUTER JOIN student AS s ON rgs.student_id = s.id " +
        		"WHERE research_group_id = ?;");
        ps.setInt(1, group.getId());
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            group.addStudent(new ElabStudent(rs.getInt("id"), rs.getString("name")));
        }
        ps.close();
    }

    private ElabGroup createGroup(Connection c, String groupName,
            int projectId) throws SQLException {
        PreparedStatement ps = c.prepareStatement(
        		"SELECT rg.id, rg.name, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id, rg.active " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.name = ?;");
        ps.setString(1, groupName);
        ResultSet rs = ps.executeQuery();
 
        if (!rs.next()) {
            throw new SQLException(
                    "Attempted to create a group that doesn't exist");
        }
        ElabGroup user = new ElabGroup(elab, this);
        user.setName(groupName);
        user.setId(rs.getInt("id"));
        user.setTeacherId(rs.getInt("teacher_id"));
        user.setRole(rs.getString("role"));
        user.setSurvey(rs.getBoolean("survey"));
        user.setUserArea(rs.getString("userarea"));
        user.setFirstTime(rs.getBoolean("first_time"));
        user.setStudy(rs.getBoolean("in_study"));
        user.setNewSurvey(rs.getBoolean("new_survey"));
        user.setActive(rs.getBoolean("active"));
        user.setNewSurveyId((Integer) rs.getObject("test_id")); 
        setMiscGroupData(user, rs.getString("ay"), user.getUserArea());
        
        ps.close();
        return user;
    }

    public void resetFirstTime(ElabGroup group) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            ps = conn.prepareStatement(
            		"UPDATE research_group SET first_time='f' WHERE id = ? ;");
            ps.setInt(1, group.getId());
            ps.executeUpdate(); 
            group.setFirstTime(false);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }
    
    public void setTeacherInStudy(ElabGroup group) throws ElabException {
    	Connection conn = null;
    	PreparedStatement ps = null;
    	try {
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());
    		ps = conn.prepareStatement(
    				"UPDATE research_group SET in_study = 't', new_survey = 't' WHERE id = ?;");
    		ps.setInt(1, group.getId());
    		ps.execute();
    	}
    	catch (Exception e) {
    		throw new ElabException(e);
    	}
    	finally {
    		DatabaseConnectionManager.close(conn, ps);
    	}
    }
    
    public void setTeacherInStudy(ElabGroup group, int testId) throws ElabException {
    	Connection conn = null;
    	PreparedStatement ps = null; 
    	try {
    		setTeacherInStudy(group);
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());
    		ps = conn.prepareStatement(
    				"INSERT INTO research_group_test (research_group_id, test_id) " + 
    				"SELECT ?, ? WHERE NOT EXISTS " +
    					"(SELECT research_group_id, test_id FROM research_group_test " + 
    					"WHERE research_group_id = ? AND test_id = ?)" + 
					";");
    		ps.setInt(1, group.getId());
    		ps.setInt(2, testId);
    		ps.setInt(3, group.getId());
    		ps.setInt(4, testId);
    		ps.execute();
    	}
    	catch (Exception e) {
    		throw new ElabException(e);
    	}
    	finally {
    		DatabaseConnectionManager.close(conn, ps);
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
        Connection conn = null;
        PreparedStatement ps = null; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            int projectId = elab.getId();
            ps = conn.prepareStatement(
            		"SELECT DISTINCT teacher.name AS tname, teacher.email AS temail, teacher.id AS teacherid, " +
            				"research_group.id AS id, research_group.name AS rgname, research_group.userarea AS rguserarea, " +
            				" research_group.active AS rgactive, teacher.cosmic_all_data_access as cosmic_all_data_access " +
            		"FROM research_group_project " + 
            		"LEFT OUTER JOIN research_group ON research_group.id = research_group_project.research_group_id " + 
            		"INNER JOIN teacher ON research_group.teacher_id = teacher.id " +  
            		"WHERE research_group_project.project_id = ? ORDER BY tname ASC;");
            ps.setInt(1, projectId);
            rs = ps.executeQuery();
            List<ElabGroup> teachers = new ArrayList<ElabGroup>();
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
                    t.setId(rs.getInt("id"));
                    t.setTeacherId(rs.getInt("teacherid"));
                    t.setActive(rs.getBoolean("rgactive"));
                    t.setCosmicAllDataAccess(rs.getBoolean("cosmic_all_data_access"));
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
                g.setActive(rs.getBoolean("rgactive"));
                g.setCosmicAllDataAccess(rs.getBoolean("cosmic_all_data_access"));                
                t.addGroup(g);
            }
            return teachers;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    protected void addTeacherInfo(Connection c, ElabGroup user)
            throws SQLException {
        ResultSet rs;
        PreparedStatement ps;
        int projectId = elab.getId();
        int teacherId = user.getTeacherId();
        
        user.getGroups().clear();
        
        ps = c.prepareStatement(
        		"SELECT name, email, authenticator, forum_id FROM teacher WHERE id = ?;");
        ps.setInt(1, teacherId);
        rs = ps.executeQuery();
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
        
        ps = c.prepareStatement(
        		"SELECT name FROM research_group WHERE teacher_id = ?;");
        ps.setInt(1, teacherId);
        rs = ps.executeQuery();

        // Can't do another query while iterating over a result set
        List<String> names = new LinkedList<String>();
        while (rs.next()) {
            names.add(rs.getString("name"));
        }
        for (String name : names) {
        	ElabGroup g = createGroup(c, name, elab.getId());
            System.out.println(g);
            user.addGroup(g);
            addStudents(c, g);
        }
        ps.close();
    }

    protected ElabGroup getTeacher(int teacherId, Connection c)
            throws SQLException {
        ResultSet rs = null;
        int projectId = elab.getId();
        PreparedStatement ps = null; 

        ps = c.prepareStatement("SELECT name, email, authenticator, forum_id FROM teacher WHERE id = ?;");
        ps.setInt(1, teacherId);
        rs = ps.executeQuery();

        if (!rs.next()) {
            throw new SQLException("Invalid teacher id: " + teacherId);
        }
        ElabGroup t = new ElabGroup(elab, this);
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setId(teacherId);
        t.setAuthenticator(rs.getString("authenticator"));
        t.setForumId((Integer) rs.getObject("forum_id"));

        ps = c.prepareStatement("SELECT name, userarea FROM research_group WHERE teacher_id = ?;");
        ps.setInt(1, teacherId);
        rs = ps.executeQuery();

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
        ps.close();
        return t;
    }

    public ElabGroup getTeacher(ElabGroup user) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            return getTeacher(user.getTeacherId(), conn);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }
    
    public ElabGroup getTeacher(int id) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            return getTeacher(id, conn);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    protected String addStudent(Connection c, ElabGroup et, ElabStudent student,
            ElabGroup groupToCreate) throws SQLException, ElabException {
        ResultSet rs = null;
        PreparedStatement ps = null; 
        ElabGroup group = student.getGroup();
        // More work to do if we haven't seen this one yet.
        String pass = null;
        int result; 
        int studentId; 
        int researchGroupId = -1;
        
        GeneratePassword rp;  
        java.util.Random rand = new java.util.Random();
        
        // Create a research group if needed
        if (groupToCreate != null) {
        	rp = new GeneratePassword();
        	pass = rp.getPassword();
        	
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
            
            Savepoint beforeRGInsert = c.setSavepoint("beforerginsert");
            String groupNameAddon = "";
            String hashedPassword = BCrypt.hashpw(pass, BCrypt.gensalt(12));
            ps = c.prepareStatement(
            		"INSERT INTO research_group " +
            		"(name, hashedpassword, teacher_id, role, userarea, ay, survey, new_survey, in_study, active) " +
            		"VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id;");
            ps.setString(2, hashedPassword);
            ps.setInt(3, et.getTeacherId());
            ps.setString(4, group.isUpload() ? "upload" : "user");
            ps.setString(5, group.getUserArea());
            ps.setString(6, ay);
            ps.setBoolean(7, group.getSurvey());
            ps.setBoolean(8, group.isNewSurvey());
            ps.setBoolean(9, group.isStudy());
            ps.setBoolean(10, group.getActive());
            
            do {
            	try {
		            ps.setString(1, group.getName() + groupNameAddon);
		            rs = ps.executeQuery();
            	}
            	catch (SQLException e) {
            		if (e.getSQLState().startsWith("23")) {
            			c.rollback(beforeRGInsert);
            			groupNameAddon = Integer.toString(rand.nextInt(1000));
            		}
            		else {
            			throw e; 
            		}
            	}
            }
            while ((rs == null) || (!rs.next()));
            
        	researchGroupId = rs.getInt(1);
        	group.setName(group.getName() + groupNameAddon);
        	group.setId(researchGroupId);
            
            ps = c.prepareStatement(
            		"INSERT INTO research_group_project (research_group_id, project_id) VALUES(?, ?);");
            ps.setInt(1, researchGroupId);
            ps.setInt(2, elab.getId());
            ps.executeUpdate();

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
        	ElabGroup eg = et.getGroupMap().get(student.getGroup().getName());
            if (eg != null) {
            	researchGroupId = eg.getId(); 
            }
            else { 
            	throw new ElabException("Cannot add student \"" + student.getName() + 
            			"\" to nonexistant research group \"" +
                		student.getGroup().getName() + "\".");
            }
        }
        
        String studentNameAddOn = "";
        ps = c.prepareStatement("INSERT INTO student (name) VALUES (?) RETURNING id;");
        Savepoint beforeStudentInsert = c.setSavepoint("student_insert");
        rs = null; 
        do {
        	try {
	        	ps.setString(1, student.getName() + studentNameAddOn);
	        	rs = ps.executeQuery();
        	}
        	catch (SQLException e) {
        		// 23XXX-type errors are okay (key violation) - roll back to pre-insertion attempt state and try again. 
        		if (e.getSQLState().startsWith("23")) {
        			c.rollback(beforeStudentInsert);
        			studentNameAddOn = Integer.toString(rand.nextInt(1000));
        		}
        		else {
        			throw e;
        		}
        	}
        } while ((rs == null) || !rs.next());
        studentId = rs.getInt(1);
        
        ps = c.prepareStatement("INSERT INTO research_group_student(research_group_id, student_id) "
                        + "SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM research_group_student "
                        + "WHERE research_group_id = ? AND student_id = ?);");
        ps.setInt(1, researchGroupId);
        ps.setInt(2, studentId);
        ps.setInt(3, researchGroupId);
        ps.setInt(4, studentId);
    	ps.executeUpdate();
        
        if (group.isNewSurvey() == true) {
        	ps = c.prepareStatement("INSERT INTO research_group_test (research_group_id, test_id) "
        			+ "SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM research_group_test "
        			+ "WHERE research_group_id = ? AND test_id = ?);");
        	ps.setInt(1, researchGroupId);
        	ps.setInt(2, group.getNewSurveyId());
        	ps.setInt(3, researchGroupId);
        	ps.setInt(4, group.getNewSurveyId());
        	result = ps.executeUpdate();
        	
        }
        return pass;
    }

    @Deprecated 
    protected String checkConflict(Connection conn, String name)
            throws SQLException, ElabException {
    	java.util.Random rand = new java.util.Random();
        String studentNameAddOn = "";
        ResultSet rs = null; 
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM research_group WHERE name = ?;");
        for (int i = 0; i < 100; i++) {
            ps.setString(1, name + studentNameAddOn);
            rs = ps.executeQuery();
            if (!rs.next()) {
                break;
            }
            if (i == 99) {
                throw new ElabException("Could not create group with name \"" + name + "\".");
            }
            studentNameAddOn = Integer.toString(rand.nextInt(1000));
        }
        ps.close();        
        return name + studentNameAddOn;
    }

    public List<String> addStudents(ElabGroup teacher, List<ElabStudent> students, List<Boolean> createGroups)
            throws ElabException {
        List<String> passwords = new ArrayList<String>();
        Connection conn = null;
        Savepoint svpt; 
        Boolean autoCommit; 
        if (students.size() != createGroups.size()) {
            throw new IllegalArgumentException(
                    "User list and createGroups list have different sizes");
        }
        Map<String, ElabGroup> groups = new HashMap<String, ElabGroup>();
        Iterator studentIterator = students.iterator();
        Iterator createGroupIterator = createGroups.iterator();
        
        while (studentIterator.hasNext() && createGroupIterator.hasNext()) {
        	ElabStudent student = (ElabStudent) studentIterator.next();
        	ElabGroup group = student.getGroup();
        	Boolean createGroup = (Boolean) createGroupIterator.next();
        	if (createGroup) {
    			ElabGroup existing = groups.get(group.getName());
    			if (existing == null) {
                    groups.put(group.getName(), group);
                }
    			else {
                    if (group.isUpload()) {
                        existing.setRole(ElabGroup.ROLE_UPLOAD);
                    }
                    if (group.isNewSurvey()) {
                    	existing.setNewSurvey(true);
                    }
                    else if (group.getSurvey()) {
                        existing.setSurvey(true);
                    }
                    else {
                    	existing.setSurvey(false);
                    	existing.setNewSurvey(false);
                    }
                }        		
        	}
        }
 /* EPeronja: the next piece of code doesn't work at all when you have mixed lists!       
        for (ElabStudent student : students) {
        	ElabGroup group = student.getGroup();
        	for (Boolean createGroup : createGroups) {
        		if (createGroup.booleanValue()) {
        			ElabGroup existing = groups.get(group.getName());
        			if (existing == null) {
                        groups.put(group.getName(), group);
                    }
        			else {
                        if (group.isUpload()) {
                            existing.setRole(ElabGroup.ROLE_UPLOAD);
                        }
                        if (group.isNewSurvey()) {
                        	existing.setNewSurvey(true);
                        }
                        else if (group.getSurvey()) {
                            existing.setSurvey(true);
                        }
                        else {
                        	existing.setSurvey(false);
                        	existing.setNewSurvey(false);
                        }
                    }
        		}
        	}
        }
*/        
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            autoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            svpt = conn.setSavepoint(); 
            try {
                for (ElabStudent student : students) {
                	ElabGroup group = groups.remove(student.getGroup().getName());
                    passwords.add(addStudent(conn, teacher, student, group));
                }
                conn.commit();
                // update the current logged in teacher with the new set of
                // groups
                addTeacherInfo(conn, teacher);
            }
            catch (SQLException e) {
                conn.rollback(svpt);
                throw e;
            }
            finally {
            	conn.setAutoCommit(autoCommit);
            }
            return passwords;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    public void deleteStudent(ElabGroup group, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            ps = conn.prepareStatement(
            		"DELETE FROM research_group_student " +
            		"WHERE research_group_id = ? AND student_id = ?;");
            ps.setInt(1, group.getId());
            ps.setInt(2, id);
            ps.executeUpdate();
            group.removeStudent(group.getStudent(id));
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }
    
    public void updateGroupPassword(ElabGroup group, String password) throws ElabException {
    	Connection conn = null; 
    	PreparedStatement ps = null;
    	try {
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());
    		
    		String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12)); 
    		
    		ps = conn.prepareStatement("UPDATE research_group SET hashedpassword = ? WHERE id = ?;");
    		ps.setString(1, hashedPassword);
    		ps.setInt(2, group.getId());
    		ps.executeUpdate(); 
    	}
    	catch(SQLException e) {
    		throw new ElabException("Could not update password for research group \"" + group.getName() + "\".");
    	}
    	finally {
    		DatabaseConnectionManager.close(conn, ps);
    	}
    }

    public void updateGroup(ElabGroup group, String password)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null, ps2 = null; 
        Savepoint svpt = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            try {
	            conn.setAutoCommit(false);
	            svpt = conn.setSavepoint();
	            boolean pass = false; 
	            String sql = "UPDATE research_group SET ay = ?, role = ?, survey = ?, new_survey = ?, active = ?";
	            if (StringUtils.isNotBlank(password)) {
	            	sql += ", hashedpassword = ? ";
	            	pass = true;
	            }
	            sql += "WHERE id = ?;";
	            ps = conn.prepareStatement(sql);
	            ps.setString(1, group.getYear());
	            ps.setString(2, group.getRole());
	            ps.setBoolean(3, group.getSurvey());
	            ps.setBoolean(4, group.isNewSurvey());
	            ps.setBoolean(5, group.getActive());
	            if (pass) {
	            	String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12)); 
	            	ps.setString(6, hashedPassword);
	            	ps.setInt(7, group.getId());
	            }
	            else {
	            	ps.setInt(6, group.getId());
	            }
	            
	            ps.executeUpdate();
	            
	            if (group.isNewSurvey()) {
	            	ps2 = conn.prepareStatement(
	        			"INSERT INTO research_group_test (research_group_id, test_id) " + 
						"SELECT ?, ? WHERE NOT EXISTS " +
							"(SELECT research_group_id, test_id FROM research_group_test " + 
							"WHERE research_group_id = ? AND test_id = ?)" + 
						";");
	            	ps2.setInt(1, group.getId());
	            	ps2.setInt(2, group.getNewSurveyId());
	            	ps2.setInt(3, group.getId());
	            	ps2.setInt(4, group.getNewSurveyId());
	            	ps2.executeUpdate();
	            }
	            
	            conn.commit();
            }
            catch (SQLException e) {
            	conn.rollback(svpt);
            	throw e; 
            }
            finally {
            	conn.setAutoCommit(true);
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps, ps2);
        }
    }

    public void updateEmail(String username, String newemail) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        Savepoint svpt = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            try {
	            conn.setAutoCommit(false);
	            svpt = conn.setSavepoint();
	            boolean pass = false; 
	            String sql = "UPDATE teacher " +
	            			 "   SET email = ? " +
	            			 "  FROM teacher t " +
	            		 	 " INNER JOIN research_group rg " +
	            		 	 "    ON t.id = rg.teacher_id " +
	            		 	 " WHERE rg.name = ? " +
	            		 	 "   AND teacher.id = t.id;";
	            ps = conn.prepareStatement(sql);
	            ps.setString(1, newemail);
	            ps.setString(2, username);
	            
	            ps.executeUpdate();
          
	            conn.commit();
            }
            catch (SQLException e) {
            	conn.rollback(svpt);
            	throw e; 
            }
            finally {
            	conn.setAutoCommit(true);
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }
    
    
    
    public String resetPassword(String groupname)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null, ps2 = null; 
        Savepoint svpt = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            try {
	            conn.setAutoCommit(false);
	            svpt = conn.setSavepoint();
	            GeneratePassword rp;  
	        	rp = new GeneratePassword();
	        	String password = rp.getPassword();
	            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
	            
	            String sql = "UPDATE research_group SET hashedpassword = ? ";
	            sql += "WHERE name = ?;";
	            ps = conn.prepareStatement(sql);
            	ps.setString(1, hashedPassword);
	            ps.setString(2, groupname);

	            ps.executeUpdate();
	            conn.commit();
	            return password;
            }
            catch (SQLException e) {
            	conn.rollback(svpt);
            	throw e; 
            }
            finally {
            	conn.setAutoCommit(true);
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps, ps2);
        }
    }
    //EPeronja: get email address
    public String getEmail(String groupname) throws ElabException {
    	String email = "";
    	PreparedStatement ps = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            String sql = "SELECT email " +
            			 "FROM teacher t " +
            			 "INNER JOIN research_group rg " +
            			 "ON t.id = rg.teacher_id " +
            			 "WHERE rg.name = ? " ;
            ps = conn.prepareStatement(sql);
            ps.setString(1, groupname);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                email = rs.getString("email");
            }
            return email;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }//end of getEmail (from groupname)
    
    //EPeronja: get user role
    public String getUserRole(String groupname) throws ElabException {
    	String role = "";
    	PreparedStatement ps = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            String sql = "SELECT rg.role " +
            			 "FROM research_group rg " +
            			 "WHERE rg.name = ? " ;
            ps = conn.prepareStatement(sql);
            ps.setString(1, groupname);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
            	role = rs.getString("role");
            }
            return role;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }    	
    }//end of getUserRole
    
    //EPeronja: retrieve usernames    
    public String[] getUsernameFromEmail(String email) throws ElabException {
    	String[] username;
    	PreparedStatement ps = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            String sql = "SELECT rg.name " +
            			 "FROM teacher t " +
            			 "INNER JOIN research_group rg " +
            			 "ON t.id = rg.teacher_id " +
            			 "WHERE t.email = ? " +
            			 "AND rg.role = 'teacher' ";
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            
            ResultSet rs = ps.executeQuery();
            int count = 0;
            while (rs.next()) {
            	count++;
            }
            
            if (count > 0) {
            	username = new String[count];
	            int i = 0;
	            rs = ps.executeQuery();
	            while (rs.next()) {
	            	username[i] = rs.getString("name");
	            	i++;
	            }
	            return username;
            } else {
            	return null;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }   	
    }//end of get username from email address

    //EPeronja: send e-mail to users
    public String sendEmail(String to, String subject, String message) throws ElabException {
    	String result = "";
		//Sender's email ID 
		final String from = "elabs@i2u2.org";
		final String password = "";
	    //Get system properties object
	    Properties properties = System.getProperties();
	    //Setup mail server
	    properties.put("mail.smtp.host", "smtp.mcs.anl.gov");
	    properties.put("mail.smtp.port", "25");
	    properties.put("mail.smtp.auth", "true");
	    properties.put("mail.smtp.starttls.enable", "true");			    
	    //Get the default Session object.
	    //Session mailSession = Session.getDefaultInstance(properties);
	   	Session mailSession = Session.getInstance(properties, new javax.mail.Authenticator() {
	   		protected PasswordAuthentication getPasswordAuthentication() {
	   			return new PasswordAuthentication(from, password );
	   		}
	   	});
	    try{
	       //Create a default MimeMessage object.
	       MimeMessage msg = new MimeMessage(mailSession);
	       //Set From: header field of the header.
	       msg.setFrom(new InternetAddress(from));
	       //Set To: header field of the header.
	       msg.addRecipient(Message.RecipientType.TO,
	                               new InternetAddress(to));
	       // Set Subject: header field
	       msg.setSubject(subject);
	       msg.setText(message);
	       //Send message
	       Transport.send(msg); 
		} catch (MessagingException mex) {
		      mex.printStackTrace();
		      result = "Error: unable to send message. " + mex.toString();
		}	
	    return result;
    }//end of sendEmail
    
    //EPeronja: update active/inactive status 
    public void updateGroupStatus(String[] activeIds) throws ElabException {
       	Connection conn = null; 
    	PreparedStatement ps = null;
    	StringBuilder sb = new StringBuilder();
		for (int i = 0; i < activeIds.length; i++) {
			sb.append(activeIds[i]);
			if (i < activeIds.length - 1) {
				sb.append(",");
			}
		}
		try {
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());      		
    		ps = conn.prepareStatement("UPDATE research_group " +
    									  "SET active = false " +
    									"WHERE teacher_id not in ("+sb.toString()+") ");
    		ps.executeUpdate(); 
			conn.commit();
    	}
    	catch(SQLException e) {
    		throw new ElabException("Could not update the research_group table.");
    	}
    	finally {
    		DatabaseConnectionManager.close(conn, ps);
    	}		
    }//end of updateGroupStatus
    
    //EPeronja: give/remove permission to see all data (blessed and unblessed)
    public void updateCosmicDataAccess(Collection teachers, String[] allowIds) throws ElabException {
    	Connection conn = null; 
    	PreparedStatement ps = null;
    	Object[] teacher = teachers.toArray();
		try {
    		//first set them all to false
    		conn = DatabaseConnectionManager.getConnection(elab.getProperties());      		
    		ps = conn.prepareStatement("UPDATE teacher SET cosmic_all_data_access = false;");
    		ps.executeUpdate(); 
    		for (int i = 0; i < teacher.length; i++) {
    			ElabGroup t = (ElabGroup) teacher[i];
    			t.setCosmicAllDataAccess(false);
    		}
			//now update the permissions
			for (int j = 0; j < allowIds.length; j++) {
	    		for (int i = 0; i < teacher.length; i++) {
	    			ElabGroup t = (ElabGroup) teacher[i]; 
	    			if (t.getTeacherId() == Integer.parseInt(allowIds[j])){
				    		ps = conn.prepareStatement("UPDATE teacher SET cosmic_all_data_access = true " +
				    								   "WHERE id = ?;");
				    		ps.setInt(1, t.getTeacherId());
				    		ps.executeUpdate(); 
							t.setCosmicAllDataAccess(true);
					}
				}
			}
			conn.commit();
    	}
    	catch(SQLException e) {
    		throw new ElabException("Could not update the teacher table.");
    	}
    	finally {
    		DatabaseConnectionManager.close(conn, ps);
    	}
    }//end of updateCosmicDataAccess

    //EPeronja: check if user's teacher has permission
    public boolean getDataAccessPermission(int teacherId) throws ElabException {
    	boolean gotAccess = false;
    	PreparedStatement ps = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            String sql = "SELECT cosmic_all_data_access " +
            			 "FROM teacher " +
            			 "WHERE id = ? ";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
            	gotAccess = rs.getBoolean("cosmic_all_data_access");
            }
        	return gotAccess;            
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }   	    	
    }//end of getDataAccessPermission

    
    public Collection<String> getProjectNames() throws ElabException {
        List<String> names = new ArrayList<String>();
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

    public Collection<String> getProjectNames(ElabGroup group) throws ElabException {
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            return getProjectNames(conn, group);
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn);
        }
    }

    private Collection<String> getProjectNames(Connection c, ElabGroup group)
            throws SQLException {
        List<String> names = new ArrayList<String>();
        PreparedStatement ps = c.prepareStatement(
        		"SELECT p.name FROM research_group_project AS rgp " +
        		"LEFT OUTER JOIN project AS p ON p.id = rgp.project_id " +
        		"WHERE research_group_id = ?;");
        ps.setInt(1, group.getId());
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            names.add(rs.getString("name"));
        }
        ps.close();
        return names;
    }

    public void updateProjects(ElabGroup group, String[] projectNames)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            conn.setAutoCommit(false);
            conn.setSavepoint();
            try {
                Map<String, Integer> ids = new HashMap<String, Integer>();
                ps = conn.prepareStatement("SELECT id, name FROM project;");
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    ids.put(rs.getString("name"), rs.getInt("id"));
                }
                Collection<String> current = getProjectNames(conn, group);
                List<String> updated = new ArrayList<String>();
                for (String projectName : projectNames) {
                	updated.add(projectName);
                }
                Set<String> toRemove = new HashSet<String>(current);
                toRemove.removeAll(updated);
                Set<String> toAdd = new HashSet<String>(updated);
                toAdd.removeAll(current);
                
                ps = conn.prepareStatement(
                		"DELETE FROM research_group_project " + 
                		"WHERE research_group_id = ? AND project_id = ?;");
                for (String s : toRemove) {
                	int id = ids.get(s);
                	ps.setInt(1, group.getId());
                	ps.setInt(2, id);
                	ps.addBatch();
                }
                ps.executeBatch();
                
                ps = conn.prepareStatement(
                		"INSERT INTO research_group_project (research_group_id, project_id) " +
                		"VALUES (?, ?);");
                for (String s: toAdd) {
                	int id = ids.get(s);
                	ps.setInt(1, group.getId());
                    ps.setInt(2, id);
                    ps.addBatch();
                }
                ps.executeBatch();
                
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
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    public boolean isStudentInGroup(ElabGroup group, int id)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(
            		"SELECT * FROM research_group_student WHERE research_group_id = ? AND student_id = ?");
            ps.setInt(1, group.getId());
            ps.setInt(2, id);
            ResultSet rs = ps.executeQuery();

            return rs.next();
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
        }
    }

    /**
     * A backdoor for running direct queries on the database. Obviously, it
     * should not be used. Should flag things in the logs and maybe email if someone 
     * uses this, ever. 
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
