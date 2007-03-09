package gov.fnal.elab.util;

import gov.fnal.elab.db.*;
import gov.fnal.elab.vds.ElabTransformation;    //for JavaDoc
import org.griphyn.vdl.classes.Transformation;  //for JavaDoc
import java.util.*;

/**
 * A class for keeping data which comes as a result from running an 
 * {@link ElabTransformation}. The save method should be defined to save
 * metadata associated with this result into the <code>VDC</code>.
 *
 * @author  Paul Nepywoda
 */
public abstract class Result {

    protected Set metadata = new HashSet();   //set of strings to be converted to metadata Tuples
    protected SessionLogin sessionLogin;
    
    public Result(){
        setDate();
    }

    /**
     * @see #setDate
     * @see #setLogin
     * @see #setTransformation
     */
    public Result(SessionLogin s, String trName) throws ElabException{
        setDate();
        setLogin(s);
        setTransformation(trName);
    }

    /**
     * Set metadata based on the current login and project. (project, 
     * institution, city, state, username)
     */
    public void setLogin(SessionLogin s) throws ElabException{
        this.sessionLogin = s;

        Login login = s.getLogin();
        Project project = s.getProject();
        Institution inst = login.getInstitution();
        String instname = "none";
        String city = "none";
        String state = "none";
        if(inst != null){
            instname = inst.getName();
            city = inst.getCity();
            state = inst.getState();
        }
        metadata.add("username string " + login.getUsername());
        metadata.add("project string " + project.getName());
        metadata.add("institution string " + instname);
        metadata.add("city string " + city);
        metadata.add("state string " + state);
    }
    public SessionLogin getLogin(){
        return sessionLogin;
    }

    /**
     * Add metadata "creationdate" to be the current timestamp
     */
    public void setDate(){
        Date now = new Date();
        long millisecondsSince1970 = now.getTime();
        java.sql.Timestamp timestamp = new java.sql.Timestamp(millisecondsSince1970);

        metadata.add("creationdate date " + timestamp.toString());
    }

    /**
     * Add metadata "transformation" for the {@link Transformation} used in
     * this job
     */
    public void setTransformation(String s){
        metadata.add("transformation string " + s);
    }

    /**
     * Add a string to the metadata.
     * @param   s   the string to add
     */
    public void addMetadata(String s){
        metadata.add(s);
    }

    /**
     * Save the metadata contained in this Result to the <code>VDC</code>.
     * Override this method to save any physical files, or do any other
     * saving which should go along with this result.
     */
    public abstract void save() throws ElabException;
    
}
