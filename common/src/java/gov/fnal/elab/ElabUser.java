/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

import java.sql.SQLException;

import javax.servlet.http.HttpSession;

public class ElabUser {
    public static final String ROLE_TEACHER = "teacher";
    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_UPLOAD = "upload";
    
    public static final String USER_SESSION_VARIABLE = "elab.user";
    
    private String teacherId, role, userArea, survey, userDirURL,
            userDir, name, webapp;
    private ElabGroup group;
    private boolean firstTime, guest;
    private Elab elab;
    
    private ElabUserManagementProvider provider;
    
    public ElabUser(Elab elab, ElabUserManagementProvider provider) {
        this.provider = provider;
        this.elab = elab;
        this.webapp = elab.getProperties().getProperty("elab.webapp", "elab");
    }
    
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isFirstTime() {
        return firstTime;
    }

    public void setFirstTime(boolean firstTime) {
        this.firstTime = firstTime;
    }
    
    public void resetFirstTime() throws SQLException {
        provider.resetFirstTime(group.getId());
    }

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

    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }

    public String getUserArea() {
        return userArea;
    }

    public void setUserArea(String userArea) {
        this.userArea = userArea;
        this.userDirURL = elab.getProperties().getProperty("portal.users") + '/' + userArea;
        this.userDir = elab.getServletContext().getRealPath(userDirURL);
    }

    public String getUserDirURL() {
        return userDirURL;
    }

    public void setUserDirURL(String userDirURL) {
        this.userDirURL = userDirURL;
    }

    public String getUserDir() {
        return userDir;
    }

    public void setUserDir(String userDir) {
        this.userDir = userDir;
    }
    
    public String getDirURL(String type) {
        return '/' + webapp + '/' + getWebappDirURL(type);
    }
    
    private String getWebappDirURL(String type) {
        return userDirURL + '/' + type;
    }
    
    public String getDir(String type) {
        return elab.getServletContext().getRealPath(getWebappDirURL(type));
    }

    public ElabGroup getGroup() {
        return group;
    }

    public void setGroup(ElabGroup group) {
        this.group = group;
    }

    public boolean isTeacher() {
        return ROLE_TEACHER.equals(role);
    }

    public boolean isAdmin() {
        return ROLE_ADMIN.equals(role);
    }
    
    public boolean isUpload() {
        return ROLE_UPLOAD.equals(role);
    }
    
    public boolean isGuest() {
        return guest;
    }

    public void setGuest(boolean guest) {
        this.guest = guest;
    }
    
    public static void setUser(HttpSession session, ElabUser user) {
        session.setAttribute(USER_SESSION_VARIABLE, user);
    }
    
    public static ElabUser getUser(HttpSession session) {
        return (ElabUser) session.getAttribute(USER_SESSION_VARIABLE);
    }
    
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
