/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * A Comment has a date, body, tag if it's been read and is linked to a Login who 
 * made the comment.
 * 
 * @hibernate.class
 *      discriminator-value="Comment"
 * @hibernate.discriminator
 *      column="discriminator"
 *      type="string"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Comment extends DBObject {

    private int id;
    private Date dateEntered;
    private String body;
    private boolean isRead = false;
    private Login maker;
    private Comment parentComment;
    private Set childComments;
    private Project project;
    private Group aboutGroup;
    
    /**
     * Empty constructor for Hibernate.
     */
    public Comment() {
        dateEntered = new Date();
    }

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Owners has the one who makes the Comment *
     */
    public Set grabOwners(){
        Set owners = new HashSet();
        owners.add(maker);
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(dateEntered != null){
            s += dateEntered + " ";
        }
        if(body != null){
            s += body + " ";
        }
        return s;
    }

    /**
     * @hibernate.id column="id" generator-class="hilo" unsaved-value="null"
     * @return The id of this comment.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="date_entered"
     * @return The date/time when this comment happened.
     */
    public Date getDateEntered() { return dateEntered; }
    public void setDateEntered(Date dateEntered) { this.dateEntered = dateEntered; }

    /**
     * @hibernate.property
     *      column="body"
     *      type="text"
     * @return The body of this comment where the text goes.
     */
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    /**
     * @hibernate.property column="is_read"
     * @return Whether this comment has been read by someone.
     */
    public boolean getIsRead() { return isRead; }
    public void setIsRead(boolean isRead) { this.isRead = isRead; }


    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_login"
     * @return The login that made this comment.
     */
    public Login getMaker() { return maker; }
    public void setMaker(Login maker) { this.maker = maker; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_comment"
     * @return The parent comment that this comment comments on.
     */
    public Comment getParentComment() { return parentComment; }
    public void setParentComment(Comment parentComment) { this.parentComment = parentComment; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Comment"
     * @hibernate.collection-key
     *      column="fk_comment"
     * @return The set of comments which comment on this comment.
     */
    public Set getChildComments() { return childComments; }
    public void setChildComments(Set childComments) { this.childComments = childComments; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_project"
     * @return The project this comment is realted to.
     */
    public Project getProject() { return project; }
    public void setProject(Project project) { this.project = project; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_group"
     * @return The group this comment comments on (instead of another comment)
     */
    public Group getAboutGroup() { return aboutGroup; }
    public void setAboutGroup(Group aboutGroup) { this.aboutGroup = aboutGroup; }

}
