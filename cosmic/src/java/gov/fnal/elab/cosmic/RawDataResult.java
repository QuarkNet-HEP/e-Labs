package gov.fnal.elab.cosmic;

import gov.fnal.elab.db.Login;
import gov.fnal.elab.util.*;
import gov.fnal.elab.vds.*;
import org.griphyn.vdl.annotation.Tuple;
import java.util.*;
import java.sql.Timestamp;

/**
 * A class for keeping data which comes as a result from running an 
 * {@link ElabTransformation} starting with raw data. The save method should 
 * be defined to save metadata associated with this result into the 
 * <code>VDC</code>.
 *
 * @author  Paul Nepywoda
 */
abstract class RawDataResult extends Result{

    public RawDataResult(){
        super();
    }

    /**
     * @see #setRawData
     */
    public RawDataResult(SessionLogin s, List rawData) throws ElabException{
        this.setLogin(s);
        setRawData(rawData);
    }

    /**
     * Sets the metadata "source, detector and rawdate".
     * @param   rawData the rawdata to base the metadata off of
     */
    public void setRawData(List rawData) throws ElabException{
        String m_source="source string ";
        String m_detectorIDs="detector string ";
        String m_rawdate="";
        Timestamp timestamp = new Timestamp(0);
        for(Iterator i=rawData.iterator(); i.hasNext(); ){
            String currFile = (String)i.next();

            m_source +=  currFile + " ";    //source of the result: space delimited list of lfns

            //get metadata from datafile
            List rawMeta = null;
            rawMeta = ElabVDS.getMeta(currFile);

            HashMap metaMap = new HashMap();
            if(rawMeta != null){
                for(Iterator metai=rawMeta.iterator(); metai.hasNext(); ){
                    Tuple t = (Tuple)metai.next();
                    metaMap.put(t.getKey(), t.getValue());
                }
            }

            try{
                timestamp = java.sql.Timestamp.valueOf(metaMap.get("startdate") + "");
            } catch(java.lang.IllegalArgumentException e){
                //throw new ElabException("While setting the startdate " + metaMap.get("startdate") + " of the file: " + currFile + ":" + e.getMessage());
            }
            m_rawdate = "rawdate date " + timestamp.toString();    //this variable is overwritten, so it'll arbitrarily be the last raw data startdate...
            m_detectorIDs += metaMap.get("detectorid") + " ";
        }
        m_source = m_source.substring(0, m_source.length()-1);  //delete last space
        m_detectorIDs = m_detectorIDs.substring(0, m_detectorIDs.length()-1);  //delete last space

        metadata.add(m_source); 
        metadata.add(m_detectorIDs); 
        metadata.add(m_rawdate); 
    }

    /**
     * Save the metadata contained in this Result to the <code>VDC</code>.
     * Override this method to save any physical files, or do any other
     * saving which should go along with this result.
     */
    public abstract void save() throws ElabException;
    
}
