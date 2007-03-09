package gov.fnal.elab.cosmic;

import java.util.*;
import gov.fnal.elab.vds.*;
import gov.fnal.elab.util.ElabException;
import org.griphyn.vdl.annotation.*;

/**
 * A class containing a list of current files to be analyzed in an 
 * {@link ElabTransformation}. Metadata about the files is also help in this
 * class.
 *
 * @author Paul Nepywoda
 */
public class AnalyzingList {

    private ArrayList currentList;
    private HashMap metadata = new HashMap();

    private String html;
    public HashSet detectorIDs;
    public Date startDate;
    public Date endDate;
    public String rawDataString;
    public String detectorIDString;
    public String queryFilenames;
    public String detectorOfLastFile;   //TODO maybe deprecated
    public int chan1total = 0;
    public int chan2total = 0;
    public int chan3total = 0;
    public int chan4total = 0;
    public int allChannelTotal = 0;
    public String filenames_str;    //TODO maybe deprecated
    public int totalFiles = 0;

    /**
     * Default Constructor.
     */
    public AnalyzingList(){ }
    
    /**
     * Constructor.
     * @param   files   the files to analyze
     */
    public AnalyzingList(Set files) throws ElabException{
        add(files);
    }
    
    /**
     * Constructor.
     * @param   files   the files to analyze
     */
    public AnalyzingList(List files) throws ElabException{
        add(files);
    }

    /**
     * Add all the files in this Set to the list of files to analyze.
     * @param set   the set of files
     */
    public void add(Set set) throws ElabException{
        currentList = new ArrayList();
        currentList.addAll(set);
        this.updateInfo();
    }

    /**
     * Add all the files in this List to the list of files to analyze.
     * @param list   the list of files
     */
    public void add(List list) throws ElabException{
        this.currentList = new ArrayList();
        this.currentList.addAll(list);
        this.updateInfo();
    }

    /**
     * Remove files from the current list of files.
     * @param c the collection of files to remove
     */
    public void remove(Collection c) throws ElabException{
        boolean b = currentList.removeAll(c);
        this.updateInfo();
    }

    /**
     * Return true if channel 1 has events in it
     */
    public boolean chan1Valid(){
        return chan1total > 0;
    }

    /**
     * Return true if channel 2 has events in it
     */
    public boolean chan2Valid(){
        return chan2total > 0;
    }

    /**
     * Return true if channel 3 has events in it
     */
    public boolean chan3Valid(){
        return chan3total > 0;
    }

    /**
     * Return true if channel 4 has events in it
     */
    public boolean chan4Valid(){
        return chan4total > 0;
    }

    /**
     * Return the current list of files
     */
    public List getList(){
        return currentList;
    }

    public String getHTML(){
        return html;
    }


    /**
     * Update info
     * Update the html string of filenames to analyze
     */
    private void updateInfo() throws ElabException{
        /* Variables set from the list of file metadata */
        this.html = "<table colspace=4 border=0><tbody><tr>" +
            "<td align=center>You're Analyzing...</td>" + 
            "<td align=center>Chan1 events</td>" + 
            "<td align=center>Chan2 events</td>" + 
            "<td align=center>Chan3 events</td>" + 
            "<td align=center>Chan4 events</td>" + 
            "<td colspan=2 align=center>Raw Data</td>";
        if(currentList != null && currentList.size() > 1){
            this.html += "<td align=center>Remove from analysis</td>";
        }
        this.html += "</tr>";
        detectorIDs = new HashSet();
        rawDataString = "File Date: ";
        detectorIDString = "Detector(s): ";
        queryFilenames = "";
        chan1total = 0;
        chan2total = 0;
        chan3total = 0;
        chan4total = 0;
        allChannelTotal = 0;
        filenames_str = "";
        totalFiles = currentList.size();;

        /* Variables used for html output string calculation */
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MM/dd/yyyy");
        //sdf.setiTimeZone(TimeZone.getTimeZone("GMT"));
        String filedate = "";
        String title = "";

        int currentRow = 0;
        for (Iterator i=currentList.iterator(); i.hasNext(); ){
            String lfn = (String)i.next();
            HashMap metaMap;

            /* Only get metadata for newly added files */
            if(!metadata.containsKey(lfn)){
                List currentMeta = null;
                currentMeta = ElabVDS.getMeta(lfn);
                if(currentMeta != null && currentMeta.size() == 0){
                    //TODO throw exception??
                    continue;
                }

                /* Save key-value metadata for this lfn */
                HashMap currentMetaMap = new HashMap();
                for(Iterator j=currentMeta.iterator(); j.hasNext(); ){
                    Tuple t = (Tuple)j.next();
                    currentMetaMap.put(t.getKey(), t.getValue());
                }
                metadata.put(lfn, currentMetaMap);
            }

            metaMap = (HashMap)metadata.get(lfn);

            currentRow++;


            /* Calculate start and end dates */
            filedate = sdf.format((Date)metaMap.get("startdate"));
            if(startDate == null){
                startDate = (Date)metaMap.get("startdate");
            }
            if(endDate == null){
                endDate = (Date)metaMap.get("enddate");
            }
            if(((Date)metaMap.get("enddate")).after(endDate)){
                endDate = (Date)metaMap.get("enddate");
            }
            if(((Date)metaMap.get("startdate")).before(startDate)){
                startDate = (Date)metaMap.get("startdate");
            }

            //create a string of filenames to send to rawanalyzeMultiple for comparison
            queryFilenames += "f=" + lfn + "&";

            //create a string of rawData files delimited by commas
            //if(totalFiles <= 3)
            rawDataString += filedate + ", ";

            //raw data string for use in passing to other analysis pages
            filenames_str += "&f=" + lfn;

            //create a list of detector IDs delimited by commas, but don't repeat detector numbers
            if(detectorOfLastFile == null || !((String)metaMap.get("detectorid")).equals(detectorOfLastFile)){
                detectorIDString += (String)metaMap.get("detectorid") + ", ";
            }
            detectorOfLastFile = (String)metaMap.get("detectorid");

            //variables provided for calling page
            detectorIDs.add(metaMap.get("detectorid"));
            chan1total += ((Long)metaMap.get("chan1")).intValue();
            chan2total += ((Long)metaMap.get("chan2")).intValue();
            chan3total += ((Long)metaMap.get("chan3")).intValue();
            chan4total += ((Long)metaMap.get("chan4")).intValue();

            if(currentRow == 10){
                html += "</tbody><tbody id=tog2 style=display:none>";
            }



            /*
             * Create the html string from file metadata
             */
            /* CSS alternating row colors */
            String rowClass = "";
            if(currentRow%2 == 0){
                rowClass = "even";
            }
            else{
                rowClass = "odd";
            }

            String city = (String)metaMap.get("city");
            String school = (String)metaMap.get("school");
            String group = (String)metaMap.get("group");
            String detector = (String)metaMap.get("detectorid");
            title = city + ", " + group + ", Detector: " + detector;
            html += "<tr class=" + rowClass + "><td align=center>" +
                metaMap.get("school") + " " + filedate + "</td>" + 
                "<td align=center>" + ((Long)metaMap.get("chan1")).intValue() + "</td>" +
                "<td align=center>" + ((Long)metaMap.get("chan2")).intValue() + "</td>" +
                "<td align=center>" + ((Long)metaMap.get("chan3")).intValue() + "</td>" +
                "<td align=center>" + ((Long)metaMap.get("chan4")).intValue() + "</td>" +
                "<td bgcolor=#EFEFFF align=center><a title=" + title + 
                " href=view.jsp?filename=" + lfn + "&type=data&get=meta>View</a>&nbsp</td>" +
                "<td bgcolor=#EFFEDE align=center><a href=rawanalyzeOutput.jsp?filename=" +
                lfn + ">Statistics</a></td>\n";

            //for removing files from the list
            if(totalFiles > 1){
                html += "<td align=center><input name=remfile type=checkbox value=" + lfn + "></td>";
            }

            html += "</tr>\n";

        }

        //trim off extra ", " in Strings
        rawDataString = rawDataString.substring(0, rawDataString.length()-2);
        detectorIDString = detectorIDString.substring(0, detectorIDString.length()-2);
        //trim off last "&"
        queryFilenames = queryFilenames.substring(0, queryFilenames.length()-1);
        //get total events in all chans
        allChannelTotal = chan1total + chan2total + chan3total + chan4total;


        //only show "show more files" link if there's more files to show...
        if(totalFiles > 10){
            html += "</tbody><tbody><tr>" + 
                "<td colspan=1 align=center>" +
                "<a href=# id=tog1 onclick=toggle('tog1', 'tog2', '...show more files', 'show less files...')>...show more files</a></td>" +
                "<td colspan=8></td></tr>\n";
        }

        html += "<tr><td align=center>" +
            "<font color=grey>Total (" + totalFiles + " files " + allChannelTotal + " events)</font>" +
            "</td><td align=center>" + "<font color=grey>" + chan1total + "</font></td>" +
            "</td><td align=center>" + "<font color=grey>" + chan2total + "</font></td>" +
            "</td><td align=center>" + "<font color=grey>" + chan3total + "</font></td>" +
            "</td><td align=center>" + "<font color=grey>" + chan4total + "</font></td>" +
            "<td colspan=2 align=center><a href=rawanalyzeMultiple.jsp?" + queryFilenames + ">Compare files</a></td>\n";

        //allow removal of files if analyzing more than one
        if(totalFiles > 1){
            html += "<td colspan=7 align=center><input name=submit type=submit value=remove></td>\n";
        }
        html += "</tr></tbody></table>\n";

    }


}
