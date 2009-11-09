/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.usermanagement.ElabUserManagementProvider;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import javax.servlet.http.HttpSession;

/**
 * Encapsulates information about an elab user.
 */
public class ElabGroup {
    public static final String ROLE_TEACHER = "teacher";
    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_UPLOAD = "upload";

    public static final String USER_SESSION_VARIABLE = "elab.user";
    
    private int teacherId, id; 

    private String role, userArea, userDirURL, userDir, name,
            webapp, email;
    private boolean firstTime, guest, survey;
    private Elab elab;
    private String year, city, state, school, teacher;
    private String namelc;
    private SortedMap<String, ElabGroup> groups; 
    private SortedMap<Integer, ElabStudent> students;
    private Map attributes;
    
    // Used only if a group is in a study
    private boolean study = false;
    
    // New survey framework stuff. Default handler for LIGO, CMS. Optional for COSMIC. 
    private boolean newSurvey = false;
    private Integer newSurveyId;

    private ElabUserManagementProvider provider;

    private String authenticator; 
    private Integer forumId; 
    
    public ElabGroup() {
        new Exception("Don't use this constructor. Use ElabGroup(Elab)").printStackTrace();
    }
    
    public ElabGroup(Elab elab) {
        this(elab, elab.getUserManagementProvider());
    }

    public ElabGroup(Elab elab, ElabUserManagementProvider provider) {
        this.provider = provider;
        this.elab = elab;
        this.webapp = elab.getProperties().getProperty("elab.webapp", "elab");
        this.groups = new TreeMap(String.CASE_INSENSITIVE_ORDER);
        this.students = new TreeMap();
        this.attributes = new HashMap();
    }

    /**
     * Returns the name of this user
     */
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.namelc = name.toLowerCase();
    }

    /**
     * Returns <code>true</code> if this user has logged in for the first time
     */
    public boolean isFirstTime() {
        return firstTime;
    }

    public void setFirstTime(boolean firstTime) {
        this.firstTime = firstTime;
    }

    /**
     * Resets the first time flag. This method changes the value of this flag in
     * the backing provider.
     */
    public void resetFirstTime() throws ElabException {
        if (provider != null) {
            provider.resetFirstTime(this);
        }
    }

    /**
     * Returns a string representing the role of this user
     */
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean getSurvey() {
        return survey;
    }

    public void setSurvey(boolean survey) {
        this.survey = survey;
    }

    /**
     * Returns the ID of the teacher that this user belongs to
     */
    public int getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(int teacherId) {
        this.teacherId = teacherId;
    }

    /**
     * Returns this user's directory used for posters, analyses, plots, etc.
     * This method returns a directory relative to the main user directory. Use
     * the <code>getUserDir</code> method to retrieve the full user directory
     * instead.
     */
    public String getUserArea() {
        return userArea;
    }

    public void setUserArea(String userArea) {
        this.userArea = userArea;
        if (elab != null) {
            this.userDirURL = elab.getProperties().getUsersDir() + '/'
                    + userArea + '/' + elab.getName();
            this.userDir = elab.getServletContext().getRealPath(userDirURL);
        }
    }

    /**
     * Returns the URL of the full user directory
     */
    public String getUserDirURL() {
        return userDirURL;
    }

    public void setUserDirURL(String userDirURL) {
        this.userDirURL = userDirURL;
    }

    /**
     * Returns the full user directory
     */
    public String getUserDir() {
        return userDir;
    }

    public void setUserDir(String userDir) {
        this.userDir = userDir;
    }

    /**
     * Returns the URL of a specific user directory. By default the URL is built
     * using the following scheme: <br>
     * <code>'/' + webappName + '/' + userDirURL + '/' + type</code><br>
     * where <code>webappName</code> represents the application name
     * (typically "elab") and <code>type</code> is the parameter passed to
     * this method (typically one of "plots", "posters", "scratch", etc.)<br>
     * <br>
     * 
     * However, part of the value returned by this method can be overriden in
     * the properties file using a property of the "&lt;type&gt;.dir" form. For
     * example, if <code>plots.dir=testing123</code> is present in the
     * properties file, then the value returned by
     * <code>getDirURL("plots")</code> will be:<br>
     * <code>'/' + webappName + '/' + "testing123"</code>
     */
    public String getDirURL(String type) {
        return '/' + webapp + '/' + getWebappDirURL(type);
    }

    private String getWebappDirURL(String type) {
        String fromProps = elab.getProperties().getProperty(type + ".dir");
        if (fromProps == null) {
            return userDirURL + '/' + type;
        }
        else {
            return fromProps;
        }
    }

    /**
     * Returns a specific user directory (such as plots, posters, or scratch
     * directories). The directory is determined by querying the servlet engine
     * for the real path of the URL returned by <code>getDirURL(type)</code>.
     */
    public String getDir(String type) {
        return elab.getServletContext().getRealPath(getWebappDirURL(type));
    }

    /**
     * Returns the group that this user belongs to.
     */
    public ElabGroup getGroup() {
        return this;
    }

    /**
     * Returns <code>true</code> if this user is a teacher, and
     * <code>false</code> otherwise.
     */
    public boolean isTeacher() {
        return ROLE_TEACHER.equals(role) || isAdmin();
    }

    /**
     * Returns <code>true</code> if this user is an elab administrator and
     * <code>false</code> otherwise.
     */
    public boolean isAdmin() {
        return ROLE_ADMIN.equals(role);
    }

    /**
     * Returns <code>true</code> if this user has upload permission and
     * <code>false</code> otherwise. A user has upload permissions if they have
     * either the upload role, the teacher role, or the admin role.
     */
    public boolean isUpload() {
        return ROLE_UPLOAD.equals(role) || ROLE_TEACHER.equals(role) || ROLE_ADMIN.equals(role);
    }

    /**
     * Returns <code>true</code> if this user is the guest user and
     * <code>false</code> otherwise.
     */
    public boolean isGuest() {
        return guest;
    }

    public void setGuest(boolean guest) {
        this.guest = guest;
    }

    /**
     * Associates a user with a <code>HttpSession</code>
     */
    public static void setUser(HttpSession session, ElabGroup user) {
        session.setAttribute(USER_SESSION_VARIABLE, user);
    }

    /**
     * Retrieves a user associated with a <code>HttpSession</code>
     */
    public static ElabGroup getUser(HttpSession session) {
        return (ElabGroup) session.getAttribute(USER_SESSION_VARIABLE);
    }

    /**
     * Returns <code>true</code> if a user is logged in in the specified
     * <code>HttpSession</code> and <code>false</code> otherwise
     */
    public static boolean isUserLoggedIn(HttpSession session) {
        return getUser(session) != null;
    }
    
    /**
     * Provides ordering on roles
     */
    public boolean isA(String role) {
        if ("user".equals(role)) {
            return true;
        }
        else if ("upload".equals(role)) {
            return isUpload();
        }
        else if ("teacher".equals(role)) {
            return isTeacher();
        }
        else if ("admin".equals(role)) {
            return isAdmin();
        }
        else {
            return false;
        }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public boolean isProfDev() {
        return namelc.startsWith("pd_");
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getTeacher() {
        return teacher;
    }

    public void setTeacher(String teacher) {
        this.teacher = teacher;
    }

    /**
     * Get this theacher's email
     */
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * Retrieve a collection of <code>ElabGroup</code> objects containing
     * information about the groups associated with this teacher.
     */
    public Collection<ElabGroup> getGroups() {
        return groups.values();
    }

    public Collection<String> getGroupNames() {
        return groups.keySet();
    }

    public void addGroup(ElabGroup group) {
        groups.put(group.getName(), group);
    }

    public ElabGroup getGroup(String name) {
        return groups.get(name);
    }

    public void addStudent(ElabStudent student) {
        students.put(student.getId(), student);
    }

    public void removeStudent(ElabStudent student) {
        if (student == null) {
            return;
        }
        students.remove(student.getId());
    }

    public ElabStudent getStudent(int id) {
        return students.get(id);
    }

    public Collection<ElabStudent> getStudents() {
        return students.values();
    }

    public void setAttribute(String name, Object value) {
        attributes.put(name, value);
    }

    public Object getAttribute(String name) {
        return attributes.get(name);
    }

    public Elab getElab() {
        return elab;
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public ElabUserManagementProvider getProvider() {
        return provider;
    }

    public void setProvider(ElabUserManagementProvider provider) {
        this.provider = provider;
    }

    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("ElabUser[");
        sb.append("name=");
        sb.append(name);
        sb.append(", ");
        sb.append(", ");
        sb.append("teacherId=");
        sb.append(teacherId);
        sb.append(", ");
        sb.append("role=");
        sb.append(role);
        sb.append(", ");
        sb.append("userArea=");
        sb.append(userArea);
        sb.append(", ");
        sb.append("survey=");
        sb.append(survey);
        sb.append(", ");
        sb.append("newsurvey=");
        sb.append(newSurveyId);
        sb.append(", ");
        sb.append("userDirURL=");
        sb.append(userDirURL);
        sb.append(", ");
        sb.append("userDir=");
        sb.append(userDir);
        sb.append(", ");
        sb.append("firstTime=");
        sb.append(firstTime);
        sb.append("]");
        return sb.toString();
    }

	public void setNewSurveyId(Integer newSurveyId) {
		this.newSurveyId = newSurveyId;
	}

	public Integer getNewSurveyId() {
		return newSurveyId;
	}
	
	public void setNewSurveyId(int id) {
		this.newSurveyId = Integer.valueOf(id);
	}

	public void setNewSurvey(boolean newSurvey) {
		this.newSurvey = newSurvey;
	}

	public boolean isNewSurvey() {
		return newSurvey;
	}

	public void setStudy(boolean study) {
		this.study = study;
	}

	public boolean isStudy() {
		return study;
	}

	public void setAuthenticator(String authenticator) {
		this.authenticator = authenticator;
	}

	public String getAuthenticator() {
		return authenticator;
	}

	public void setForumId(Integer forumId) {
		this.forumId = forumId;
	}

	public Integer getForumId() {
		return forumId;
	}
}
