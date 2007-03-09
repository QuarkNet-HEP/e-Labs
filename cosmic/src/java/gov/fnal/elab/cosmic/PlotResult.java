package gov.fnal.elab.cosmic;

import gov.fnal.elab.db.Login;
import gov.fnal.elab.util.*;
import gov.fnal.elab.vds.*;
import org.griphyn.vdl.annotation.Tuple;
import java.util.*;
import java.io.File;
import java.sql.Timestamp;

/**
 * A class for keeping data which comes as a result from running an 
 * {@link ElabTransformation} starting with raw data and ending with a plot as
 * the result. The save method should be defined to save metadata associated 
 * with this result into the <code>VDC</code>.
 *
 * @author  Paul Nepywoda
 */
public class PlotResult extends RawDataResult{
    private String plotName;
    private String plotFile = null;
    private String plotHeight;
    private String provenanceFile = null;
    private String outputDir = null;

    public PlotResult(){
        super();
    }

    /**
     * Constructor.
     * @param   s   SessionLogin of the user saving this plot
     * @param   rawData the raw data used to create this plot
     * @param   trName  the transformation name used for this job
     * @param   plotFile    the full path to the svg plot file to save permanently
     * @param   plotHeight  the height of the plot image to create from svg
     * @param   provenanceFile  the full path to the provenance file (usually 
     *  dv.dot file)
     * @param   outputDir   the full path to the output directory to save the 
     *  plot, plot thumbnail, provenance file, and provenence file thumbnail
     * @see Result#setLogin
     * @see Result#setTransformation
     * @see RawData#setRawData
     * @see #setPlotFile
     * @see #setPlotHeight
     * @see #setProvenanceFile
     * @see #setOutputDir
     */
    public PlotResult(SessionLogin s, String trName, List rawData, String plotFile, String plotHeight, String provenanceFile, String outputDir) throws ElabException{
        setLogin(s);
        setTransformation(trName);
        setRawData(rawData);
        setPlotFile(plotFile);
        setPlotHeight(plotHeight);
        setProvenanceFile(provenanceFile);
        setOutputDir(outputDir);
    }

    public void setPlotFile(String plotFile){
        this.plotFile = plotFile;
    }
    public String getPlotFile(){
        return plotFile;
    }

    public void setPlotHeight(String plotHeight){
        this.plotHeight = plotHeight;
    }
    public String getPlotHeight(){
        return plotHeight;
    }

    public void setProvenanceFile(String provenanceFile){
        this.provenanceFile = provenanceFile;
    }
    public String getProvenanceFile(){
        return provenanceFile;
    }

    public void setOutputDir(String outputDir){
        this.outputDir = outputDir;
    }
    public String getOutputDir(){
        return outputDir;
    }

    public void setPlotName(String plotName){
        this.plotName = plotName;
    }
    public String getPlotName(){
        return plotName;
    }

    /**
     * Save the metadata contained in this Result to the <code>VDC</code>.
     * Also save the plot, the plot thumbnail, the provenance, the provenance
     * thumbnail.
     */
    public void save() throws ElabException{
        /*
         * Generate a filename prefix to be unique in the VDC based on the
         * login name and current timestamp. If there's a collision (which will
         * rarely happen) keep trying until a unique name is found.
         * Prefix will be formatted: savedimage-$login-$date-$type
         */
        GregorianCalendar gc = new GregorianCalendar();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
        String date = sdf.format(gc.getTime());
        Login me = sessionLogin.getLogin();
        String prefix = "savedimage-" + me.getUsername() + "-" + date + "-";

        String plotImage = prefix + "image.png";

        boolean added = ElabVDS.addRC(plotImage, outputDir + "/" + plotImage);
        int collision = 0;
        while(added == false && collision < 50){
            collision++;
            prefix = prefix + collision + "-";
            plotImage = prefix + "image.png";
            added = ElabVDS.addRC(plotImage, outputDir + "/" + plotImage);
        }
        if(added == false){
            throw new ElabException("Too many users on the system at this time. Try saving your plot again later");
        }



        /*
         * Create the png images and thumbnail images
         */
        String plotThumbnailImage = prefix + "image_thm.png";
        String provenanceImage = prefix + "provenance.png";
        String provenanceThumbnailImage = prefix + "provenance_thm.png";

        //FIXME This exists to clean out a bug in the DAX2DOT routine.
        if(provenanceFile == null)
            throw new ElabException("provenanceFile variable is null. Cannot create an image out of it");
        String[] cmd = new String[] {"bash", "-c", "/usr/bin/perl -pi -e 's/^.*\"\".*$//g' " + provenanceFile};
        int c;
        try{
            Process p = Runtime.getRuntime().exec(cmd);
            c = p.waitFor();
        } catch(Exception e){
            throw new ElabException("Exception while running DAX fix code for " + provenanceFile, e);
        }
        if (c != 0) {
            throw new ElabException("Failed to run DAX fix code for " + provenanceFile + " running command: " + cmd[2]);
        }
        
        /* Transform the dot file into an SVG */
        if(outputDir == null)
            throw new ElabException("outputDir variable is null. Cannot make dv.svg");
        File outputDirectory = new File(outputDir);
        if(!outputDirectory.isDirectory())
            throw new ElabException("svg output dir: " + outputDir + " does not exist");
        String dotCmd = "dot -Tsvg -o" + outputDir + "/dv.svg " + provenanceFile; //FIXME this should be some temp directory instead of here...
        cmd = new String[] {"bash", "-c", dotCmd};
        try{
            Process p = Runtime.getRuntime().exec(cmd);
            c = p.waitFor();
        } catch(Exception e){
            throw new ElabException("Exception while transforming the dot file into an svg file for " + provenanceFile, e);
        }
        if (c != 0) {
            throw new ElabException("Failed to create an svg out of the dot provenance file " + provenanceFile + " running command: " + cmd[2]);
        }

        /* png creation from svg */
        if(plotFile == null)
            throw new ElabException("plotFile variable is null. Cannot make a png out of it");
        ElabCommon.svg2png(outputDir + "/dv.svg", outputDir + "/" + provenanceImage, "800");
        ElabCommon.svg2png(outputDir + "/dv.svg", outputDir + "/" + provenanceThumbnailImage, "200");
        ElabCommon.svg2png(plotFile, outputDir + "/" + plotImage, plotHeight);
        ElabCommon.svg2png(plotFile, outputDir + "/" + plotThumbnailImage, "200");


        /* Add the other newly created files to the VDC */
        added = ElabVDS.addRC(plotThumbnailImage, outputDir + "/" + plotThumbnailImage);
        added = ElabVDS.addRC(provenanceImage, outputDir + "/" + provenanceImage);
        added = ElabVDS.addRC(provenanceThumbnailImage, outputDir + "/" + provenanceThumbnailImage);

        /* add image metadata */
        addMetadata("type string plot");
        addMetadata("name string " + plotName);
        addMetadata("thumbnail string " + plotThumbnailImage);
        addMetadata("provenance string " + provenanceImage);
        addMetadata("provenance_thumbnail string " + provenanceThumbnailImage);


        /*
         * Save the metadata to the VDC
         */
        ElabVDS.setMeta(plotImage, metadata);
    }
    
}
