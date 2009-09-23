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

import org.apache.commons.lang.StringUtils;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
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
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            password = switchingElabs(conn, username, password);
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

    private String switchingElabs(Connection c, String username, String password)
            throws SQLException, AuthenticationException {
        if (SWITCHING_ELABS.equals(password)) {            
            PreparedStatement ps = c.prepareStatement(
            		"SELECT password FROM research_group WHERE name ILIKE ?;");
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
    			"SELECT research_group_project.project_id " +
    			"FROM research_group_project " +
    			"WHERE research_group_project.project_id = ? " +
    			"AND research_group_project.research_group_id = ?;");
    	ps.setInt(1, projectID);
    	ps.setInt(2, user.getGroup().getId());
        ResultSet rs = ps.executeQuery();
        if (!rs.next() && !user.isTeacher() && !user.isAdmin()) {
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
    			"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
    			"FROM research_group AS rg " +
    			"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
    			"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
    			"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
    			"WHERE rg.name = ? AND rg.password = ?;");
    	ps.setString(1, username);
    	ps.setString(2, password);
    	ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new AuthenticationException("Invalid username or password");
        }

        return createUser(c, username, rs);
    }

    private ElabGroup createUser(Connection c, String username, int projectId)
            throws SQLException, ElabException {
		PreparedStatement ps = c.prepareStatement(
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
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
        PreparedStatement ps = c.prepareStatement(
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
        		"FROM research_group AS rg " +
        		"LEFT OUTER JOIN research_group_test AS rgt ON (rg.id = rgt.research_group_id) " +
        		"LEFT OUTER JOIN research_group_project AS rgp ON (rg.id = rgp.project_id) " +
        		"LEFT OUTER JOIN \"newSurvey\".tests AS t ON (rgp.project_id = t.proj_id) " +
        		"WHERE rg.id = ? ;");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        String name = rs.getString("name");
        ps.close();

        if (!rs.next()) {
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
        		"SELECT id, name FROM student WHERE id IN " +
        		"(SELECT student_id FROM research_group_student WHERE research_group_id = ?);");
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
        		"SELECT rg.id, rg.name, rg.password, rg.teacher_id, rg.role, rg.userarea, rg.ay, rg.survey, rg.first_time, rg.new_survey, rg.in_study, rgt.test_id " +
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
            		"SELECT distinct teacher.name as tname, teacher.email as temail, "
                            + "teacher.id as teacherid, research_group.id as id,"
                            + "research_group.name as rgname, research_group.userarea as rguserarea "
                            + "FROM teacher, research_group "
                            + "WHERE research_group.teacher_id = teacher.id "
                            + "AND research_group.id IN "
                            + "(SELECT distinct research_group_id FROM research_group_project WHERE "
                            + " research_group_project.project_id = ? ) ORDER BY tname ASC;");
            ps.setInt(1, projectId);
            rs = ps.executeQuery();
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
                    t.setId(rs.getInt("id"));
                    t.setTeacherId(rs.getInt("teacherid"));
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
        List names = new LinkedList();
        while (rs.next()) {
            names.add(rs.getString("name"));
        }
        Iterator i = names.iterator();
        while (i.hasNext()) {
            ElabGroup g = createGroup(c, (String) i.next(), elab.getId());
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
        int researchGroupId;
        
        GeneratePassword rp;  
        
        // Create a research group if needed
        if (groupToCreate != null) {
        	rp = new GeneratePassword();
        	pass = rp.getPassword();
        	
        	/* TODO: This really, really shouldn't be used. This is vulnerable to race conditions :( 
        	 * We should be inserting and checking for an exception
        	 */ 
            student.getGroup().setName(checkConflict(c, student.getGroup().getName()));
            
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
            
            ps = c.prepareStatement(
            		"INSERT INTO research_group " +
            		"(name, password, teacher_id, role, userarea, ay, survey, new_survey, in_study) " +
            		"VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id;");
            ps.setString(1, group.getName());
            ps.setString(2, pass);
            ps.setInt(3, et.getTeacherId());
            ps.setString(4, group.isUpload() ? "upload" : "user");
            ps.setString(5, group.getUserArea());
            ps.setString(6, ay);
            ps.setBoolean(7, group.getSurvey());
            ps.setBoolean(8, group.isNewSurvey());
            ps.setBoolean(9, group.isStudy());
            rs = ps.executeQuery();
            
            if (rs.next()) {
            	researchGroupId = rs.getInt(1);
            }
            else {
            	throw new SQLException("Database Error: Could not create a research group for" + group.getName());
            }
            
            ps = c.prepareStatement(
            		"INSERT INTO research_group_project (research_group_id, project_id) VALUES(?, ?);)");
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
        
        java.util.Random rand = new java.util.Random();
        String studentNameAddOn = "";
        ps = c.prepareStatement("INSERT INTO student (name) VALUES (?) RETURNING id;");
        do {
        	try {
	        	ps.setString(1, student.getName() + studentNameAddOn);
	        	rs = ps.executeQuery();
        	}
        	catch (SQLException e) {
        		// 23XXX-type errors are okay, we just attempt a re-insert 
        		if (!e.getSQLState().startsWith("23")) {
        			throw e; 
        		}
        		// If this is an integrity violation error, eat the exception and attempt a re-insert 
        	}
        	studentNameAddOn = Integer.toString(rand.nextInt(1000));
        } while ((rs == null) || !rs.next());
        studentId = rs.getInt(1);
        
        ps = c.prepareStatement("INSERT INTO research_group_student(research_group_id, student_id) "
                        + "VALUES(?, ?);");
        ps.setInt(1, group.getId());
        ps.setInt(2, studentId);
        ps.executeUpdate();
        
        if (group.isNewSurvey() == true) {
        	ps = c.prepareStatement("INSERT INTO research_group_test (research_group_id, test_id) "
        			+ "VALUES(?, ?);");
        	ps.setInt(1, group.getId());
        	ps.setInt(2, group.getNewSurveyId());
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

    public List addStudents(ElabGroup teacher, List<ElabStudent> students, List<Boolean> createGroups)
            throws ElabException {
        List passwords = new ArrayList();
        Connection conn = null;
        Savepoint svpt; 
        Boolean autoCommit; 
        if (students.size() != createGroups.size()) {
            throw new IllegalArgumentException(
                    "User list and createGroups list have different sizes");
        }
        Map<String, ElabGroup> groups = new HashMap();
        
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

    public void updateGroup(ElabGroup group, String password)
            throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null; 
        Savepoint svpt = null; 
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            try {
	            conn.setAutoCommit(false);
	            svpt = conn.setSavepoint();
	            boolean pass = false; 
	            String sql = "UPDATE research_group SET ay = ?, role = ?, survey = ?, new_survey = ?";
	            if (StringUtils.isNotBlank(password)) {
	            	sql += ", password = ? ";
	            	pass = true;
	            }
	            sql += "WHERE id = ?;";
	            ps = conn.prepareStatement(sql);
	            ps.setString(1, group.getYear());
	            ps.setString(2, group.getRole());
	            ps.setBoolean(3, group.getSurvey());
	            ps.setBoolean(4, group.isNewSurvey());
	            if (pass) {
	            	ps.setString(5, password);
	            	ps.setInt(6, group.getId());
	            }
	            else {
	            	ps.setInt(5, group.getId());
	            }
	            
	            ps.executeUpdate();
	            
	            if (group.isNewSurvey()) {
	            	PreparedStatement ps2 = conn.prepareStatement(
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
            DatabaseConnectionManager.close(conn, ps);
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
        List names = new ArrayList();
        PreparedStatement ps = c.prepareStatement(
    		"SELECT name FROM project WHERE id IN " +
            "(SELECT project_id FROM research_group_project WHERE research_group_id = ?);");
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
                Map ids = new HashMap();
                ps = conn.prepareStatement("SELECT id, name FROM project");
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    ids.put(rs.getString("name"), rs.getInt("id"));
                }
                Collection current = getProjectNames(conn, group);
                List updated = new ArrayList();
                for (String projectName : projectNames) {
                	updated.add(projectName);
                }
                Set toRemove = new HashSet(current);
                toRemove.removeAll(updated);
                Set toAdd = new HashSet(updated);
                toAdd.removeAll(current);
                Iterator i = toRemove.iterator();
                ps = conn.prepareStatement(
                		"DELETE FROM research_group_project " + 
                		"WHERE research_group_id = ? AND project_id = ?;");
                while (i.hasNext()) {
                    int id = (Integer) ids.get(i.next());
                    ps.setInt(1, group.getId());
                    ps.setInt(2, id);
                    ps.executeUpdate();
                }
                i = toAdd.iterator();
                ps = conn.prepareStatement(
                		"INSERT INTO research_group_project (research_group_id, project_id) " +
                		"VALUES (?, ?);");
                while (i.hasNext()) {
                    int id = (Integer) ids.get(i.next());
                    ps.setInt(1, group.getId());
                    ps.setInt(2, id);
                    ps.executeUpdate();
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
