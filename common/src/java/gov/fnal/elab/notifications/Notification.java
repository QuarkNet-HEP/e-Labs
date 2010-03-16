/*
 * Created on Feb 26, 2010
 */
package gov.fnal.elab.notifications;

import java.util.Date;

public class Notification {
    public static final int PRIORITY_NORMAL = 0;
    public static final int PRIORITY_SYSTEM_MESSAGE = 1;
    public static final int USER_EVERYONE = -1; 
    
    private int id;
    private String message;
    private int groupId, projectId, priority;
    private long time, expires;
    private boolean read;

    public Notification() {
    }

    public Notification(int id, String message, Integer groupId, Integer projectId, long time, long expires, int priority,
            boolean read) {
        this.id = id;
        this.message = message;
        this.groupId = groupId;
        this.projectId = projectId;
        this.time = time;
        this.read = read;
        this.expires = expires;
        this.priority = priority;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public int getProjectId() {
        return projectId;
    }

    public void setProjectId(int projectId) {
        this.projectId = projectId;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public long getExpires() {
        return expires;
    }

    public void setExpires(long expires) {
        this.expires = expires;
    }
    
    public Date getTimeAsDate() {
        return new Date(time);
    }
    
    public Date getExpiresAsDate() {
        return new Date(expires);
    }
}
