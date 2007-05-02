/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

import java.sql.SQLException;

import javax.servlet.http.HttpSession;

/**
 * Encapsulates information about an elab user.
 */
public class ElabUser {
    public static final String ROLE_TEACHER = "teacher";
    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_UPLOAD = "upload";

    public static final String USER_SESSION_VARIABLE = "elab.user";

    private String teacherId, role, userArea, survey, userDirURL, userDir,
            name, webapp;
    private ElabGroup group;
    private boolean firstTime, guest;
    private Elab elab;

    private ElabUserManagementProvider provider;

    public ElabUser(Elab elab, ElabUserManagementProvider provider) {
        this.provider = provider;
        this.elab = elab;
        this.webapp = elab.getProperties().getProperty("elab.webapp", "elab");
    }

    /**
     * Returns the name of this user
     */
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
    public void resetFirstTime() throws SQLException {
        provider.resetFirstTime(group.getId());
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

    public String getSurvey() {
        return survey;
    }

    public void setSurvey(String survey) {
        this.survey = survey;
    }

    /**
     * Returns the ID of the teacher that this user belongs to
     */
    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
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
        this.userDirURL = elab.getProperties().getProperty("portal.users")
                + '/' + userArea;
        this.userDir = elab.getServletContext().getRealPath(userDirURL);
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
     * Returns the group that this user belongs to
     */
    public ElabGroup getGroup() {
        return group;
    }

    public void setGroup(ElabGroup group) {
        this.group = group;
    }

    /**
     * Returns <code>true</code> if this user is a teacher, and
     * <code>false</code> otherwise.
     */
    public boolean isTeacher() {
        return ROLE_TEACHER.equals(role);
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
     * <code>false</code> otherwise.
     */
    public boolean isUpload() {
        return ROLE_UPLOAD.equals(role);
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
    public static void setUser(HttpSession session, ElabUser user) {
        session.setAttribute(USER_SESSION_VARIABLE, user);
    }

    /**
     * Retrieves a user associated with a <code>HttpSession</code>
     */
    public static ElabUser getUser(HttpSession session) {
        return (ElabUser) session.getAttribute(USER_SESSION_VARIABLE);
    }

    /**
     * Returns <code>true</code> if a user is logged in in the specified
     * <code>HttpSession</code> and <code>false</code> otherwise
     */
    public static boolean isUserLoggedIn(HttpSession session) {
        return getUser(session) != null;
    }

    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("ElabUser[");
        sb.append("name=");
        sb.append(name);
        sb.append(", ");
        sb.append("group=");
        sb.append(group);
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
}
