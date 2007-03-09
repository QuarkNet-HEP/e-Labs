/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import gov.fnal.elab.vds.ElabTransformation;    //for JavaDoc references


/**
 * Models a job running on the grid or locally, usually started from
 * {@link ElabTransformation#run}. In general, this class keeps track of any
 * processes which we as an Elab entity are responsible for.
 * 
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Job extends DBObject {

    private int id;
    private String identifier;
    private String directory;
    private String dvName;
    private String studyType;
    private String runLocation;
    private int numberOfNodes;
    private int nodesCompleted;
    private String currentStatus;
    private long numberOfEvents;
    private double strain;
    private Date submitTime;
    private Date finishTime;
    private int stage;
    private boolean isError = false;
    private Login owner;

    /**
     * Special section for job "stages"
     */
    public static final int STARTING = 0;
    public static final int RUNNING = 1;
    public static final int ENDING = 2;
    public static final int FINISHED = 3;
    
    /**
     * Constructor
     */
    public Job() {
        submitTime = new Date();
    }

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     */
    public Set grabOwners(){
        Set owners = new HashSet();
        owners.add(owner);
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(directory != null){
            s += directory + " ";
        }
        return s;
    }

    /**
     * @hibernate.id column="id" generator-class="hilo" unsaved-value="null"
     * @return The id of this job.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="identifier"
     *      type="text"
     * @return The identifier of this job in the namespace it's running in
     * (usually grid or local)
     */
    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }

    /**
     * @hibernate.property
     *      column="directory"
     *      type="text"
     * @return The directory this job resides in.
     */
    public String getDirectory() { return directory; }
    public void setDirectory(String directory) { this.directory = directory; }

    /**
     * @hibernate.property
     *      column="dv_name"
     *      type="text"
     * @return The {@link Derivation} name bound to this job.
     */
    public String getDVName() { return dvName; }
    public void setDVName(String dvName) { this.dvName = dvName; }

    /**
     * @hibernate.property
     *      column="study_type"
     *      type="text"
     * @return The type of study this job is.
     */
    public String getStudyType() { return studyType; }
    public void setStudyType(String studyType) { this.studyType = studyType; }

    /**
     * @hibernate.property
     *      column="run_location"
     *      type="text"
     * @return The location this job runs at.
     */
    public String getRunLocation() { return runLocation; }
    public void setRunLocation(String runLocation) { this.runLocation = runLocation; }

    /**
     * @hibernate.property
     *      column="number_of_nodes"
     * @return The total number of nodes in this job.
     */
    public int getNumberOfNodes() { return numberOfNodes; }
    public void setNumberOfNodes(int numberOfNodes) { this.numberOfNodes = numberOfNodes; }

    /**
     * @hibernate.property
     *      column="nodes_completed"
     * @return The number of nodes completed for the job.
     */
    public int getNodesCompleted() { return nodesCompleted; }
    public void setNodesCompleted(int nodesCompleted) { this.nodesCompleted = nodesCompleted; }

    /**
     * @hibernate.property
     *      column="current_status"
     *      type="text"
     * @return The current status string of this job.
     */
    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }

    /**
     * @hibernate.property
     *      column="number_of_events"
     * @return The total number of events in in all the files we're analyzing
     *  in this job.
     */
    public long getNumberOfEvents() { return numberOfEvents; }
    public void setNumberOfEvents(long numberOfEvents) { this.numberOfEvents = numberOfEvents; }

    /**
     * An integer which represents the strain this job is putting on the 
     * system. Used as a metric for CPU and memory use.
     * @hibernate.property
     *      column="strain"
     * @return The strain this job is expected to put on the system.
     */
    public double getStrain() { return strain; }
    public void setStrain(double strain) { this.strain = strain; }

    /**
     * @hibernate.property
     *      column="submit_time"
     * @return The date this job was submitted.
     */
    public Date getSubmitTime() { return submitTime; }
    public void setSubmitTime(Date submitTime) { this.submitTime = submitTime; }

    /**
     * @hibernate.property
     *      column="finish_time"
     * @return The date this job finished executing.
     */
    public Date getFinishTime() { return finishTime; }
    public void setFinishTime(Date finishTime) { this.finishTime = finishTime; }

    /**
     * Default false;
     * @hibernate.property
     *      column="stage"
     * @return The stage this job is currently at.
     */
    public int getStage() { return stage; }
    public void setStage(int stage) { this.stage = stage; }


    /**
     * Default false;
     * @hibernate.property
     *      column="is_error"
     * @return True if there's an error running this job.
     */
    public boolean getIsError() { return isError; }
    public void setIsError(boolean isError) { this.isError = isError; }


    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_login"
     * @return The login that owns and started this job.
     */
    public Login getOwner() { return owner; }
    public void setOwner(Login owner) { this.owner = owner; }

}
