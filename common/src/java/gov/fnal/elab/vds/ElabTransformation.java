package gov.fnal.elab.vds;

import gov.fnal.elab.beans.MappableBean;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabShellException;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringBufferInputStream;
import java.io.StringWriter;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.jsp.JspWriter;

import org.griphyn.common.util.Separator;
import org.griphyn.vdl.classes.Declare;
import org.griphyn.vdl.classes.Definition;
import org.griphyn.vdl.classes.Definitions;
import org.griphyn.vdl.classes.Derivation;
import org.griphyn.vdl.classes.LFN;
import org.griphyn.vdl.classes.Leaf;
import org.griphyn.vdl.classes.Pass;
import org.griphyn.vdl.classes.Scalar;
import org.griphyn.vdl.classes.Text;
import org.griphyn.vdl.classes.Transformation;
import org.griphyn.vdl.classes.Value;
import org.griphyn.vdl.dbschema.AnnotationSchema;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.dbschema.VDC;
import org.griphyn.vdl.directive.Connect;
import org.griphyn.vdl.directive.Define;
import org.griphyn.vdl.directive.Derive;
import org.griphyn.vdl.invocation.Job;
import org.griphyn.vdl.router.BookKeeper;
import org.griphyn.vdl.router.Route;
import org.griphyn.vdl.toolkit.VizDAX;
import org.griphyn.vdl.util.ChimeraProperties;

/**
 * Class for interaction with the VDS via a {@link Transformation} and
 * {@link Derivation}.
 *
 * @author Paul Nepywoda (nepywoda -at- f n a l -dot- gov)
 * @author Eric Gilbert (egilbert -at- f n a l -dot- gov)
 * @see Transformation
 * @see Derivation
 */
@SuppressWarnings("deprecation")
public class ElabTransformation{
    /**
     * The {@link Transformation} instance
     */
    private Transformation tr;

    /**
     * The {@link Derivation} instance
     */
    private Derivation dv;

    /**
     * Full path of directory to write output files to.
     */
    private String outputDir;

    /**
     * Final part of directory to write output files to. See {@link Derive#genShellScripts}
     */
    private String outputDirName;

    /**
     * Name for the Transformation.
     */
    private String trName;

    /**
     * Name for the Derivation.
     */
    private String dvName;

    /**
     * Namespace for the Transformation.
     */
    private String trNamespace;
    
    /**
     * Namespace for the Derivation.
     */
    private String dvNamespace;
    
    /**
     * Version of the Transformation to use.
     */
    private String trVersion;

    /**
     * Version of the Derivation to use.
     */
    private String dvVersion;

    /**
     * {@link VDC}
     */
    private VDC vdc;

    /**
     * Main schema for database interaction {@link DatabaseSchema}
     */
    private DatabaseSchema dbschema;

    /**
     * DAX in XML form, used in {@link #genShellScripts}
     */
    private StringWriter daxXML = null;

    /**
     * The job id created in runReturn()
     */
    private int jobId;

    /**
     * The strain this job will put on the system
     * @see #calculateStrain
     */
    double strain = -1;

    /**
     * The number of events the raw data files in this job contain.
     * @see #calculateStrain
     */
    long numberOfEvents = -1;


    /**
     * Default Constructor.
     */
    public ElabTransformation(){
    }

    /**
     * Constructor.
     *
     * @param trName the name of the transformation in the current 
     * namespace and version context.
     * @see #createTR
     */
    public ElabTransformation(String trName) throws ElabException{
        createTR(trName);
    }

    /**
     * Connects to the database by setting up the dbschema and vdc variables
     * @see VDC
     */
    private void connect() throws ElabException{
        String schemaName;
        Connect connect;
        try{
            schemaName = ChimeraProperties.instance().getVDCSchemaName();
            connect = new Connect();
            this.dbschema = connect.connectDatabase(schemaName);
        } catch(Exception e){
            throw new ElabException("Database connecting error: " + e.getMessage());
        }
        this.vdc = (VDC)this.dbschema;
        //AnnotationSchema yschema = (AnnotationSchema)dbschema;
    }

    /**
     * Closes open database connections.
     * @see AnnotationSchema#close
     * @see DatabaseSchema#close
     */
    public void close(){
        try{
            if (dbschema != null)
                dbschema.close();
            if (vdc != null)
                ((DatabaseSchema)vdc).close();
        } catch (Exception e){ }
    }

    /**
     * Create a new {@link Transformation} from the database using the current 
     * properties from {@link ChimeraProperties}.
     *
     * @param s the name of the transformation in the current 
     * namespace and version context.
     *
     * @see VDC#loadDefinition VDC.loadDefinition(namespace, name, 
     * version, Definition.TRANSFORMATION)
     */
    public void createTR(String s) throws ElabException{
        try{
            String[] nameArr;
            try{
                nameArr = Separator.split(s);
            } catch (IllegalArgumentException e){
                throw new ElabException("The tr name: " + s + " cannot be parsed correctly.");
            }
            this.trNamespace = nameArr[0];
            this.trName = nameArr[1];
            this.trVersion = nameArr[2];
            this.trVersion = "";
            connect();
            tr = (Transformation)vdc.loadDefinition(trNamespace, trName, trVersion, Definition.TRANSFORMATION);
            if (tr == null) {
                throw new ElabException("VDC returned null for: " +
                        trNamespace + " " + 
                        trName + " " + 
                        trVersion);
            }
        } catch(Exception e){
            close();
            throw new ElabException("Error while setting up the Transformation: " + e);
        }
    }

    /**
     * Generate an output directory name based on the current date and time.
     * e.g. run.2004.1210.194224.303 (12/10/2004 19:42:24.303)
     *
     * @param baseDir the generated directory name will be concatenated to this
     * "base" directory to form a full pathname.
     */
    public void generateOutputDir(String baseDir) throws ElabException{
        GregorianCalendar gc = new GregorianCalendar();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
        String dirName = "run-" + sdf.format(gc.getTime());

        File fDirName = new File(dirName);
        boolean isDirectory = fDirName.isDirectory();
        int collision = 0;
        while(isDirectory == true && collision < 50){
            collision++;
            dirName += "." + collision;
            fDirName = new File(dirName);
            isDirectory = fDirName.isDirectory();
        }
        if(isDirectory == true){
            throw new ElabException("Too many users on the system at once (" + collision + " max). Try again.\nError: cannot create directory: " + dirName);
        }
        outputDir = baseDir + "/" + dirName;
        outputDirName = dirName;

        // now check that outputDir exists:
        // benc TODO
    }

    /**
     * Set the output directory to the parameter.
     *
     * @param fullpath The output directory will be directly set to this. Should
     * be a full pathname.
     */
    public void setOutputDir(String fullpath){
        outputDir = fullpath;
        outputDirName = fullpath.substring(fullpath.lastIndexOf("/") + 1);
    }

    /**
     * Get the full output directory path
     */
    public String getOutputDir(){
        return outputDir;
    }

    /**
     * Get whatever the output directory is currently named (not fully
     * qualified).
     */
    public String getOutputDirName(){
        return outputDirName;
    }

    /**
     * Get the job id which was created in {@link #runReturn}
     */
    public int getJobId(){
        return jobId;
    }

    /**
     * Set the Derivation name.
     *
     * @param s Fully qualified Derivation name. Will be split by 
     * {@link Separator#split}.
     */
    public void setDVName(String s) throws ElabException{
        String[] nameArr;
        try{
            nameArr = Separator.split(s);
        } catch (IllegalArgumentException e){
            throw new ElabException("The dv name: " + trName + " cannot be parsed correctly.");
        }
        this.dvNamespace = nameArr[0];
        this.dvName = nameArr[1];
        this.dvVersion = nameArr[2];
    }

    /**
     * Get whatever <code>dvName</code> is currently set to.
     */
    public String getDVName(){
        return dvName;
    }

    /**
     * Writes dv.dax, dv.vdlx, dv.vdlt files to the output directory.
     * @see VizDAX#main
     */
    public void dump() throws ElabException{
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before dumping the Derivation info to file");
        }

        if(dbschema == null){
            throw new ElabException("You must first setup a Transformation before dumping the Derivation info to a file");
        }

        if(daxXML == null){
            throw new ElabException("You must first run this job before dumping it's contents to a file");
        }

        try {
            String fileNoExt = outputDir + System.getProperty("file.separator", "/") + "dv";
            // Write the dax.
            PrintWriter pw = new PrintWriter(new FileWriter(new File(fileNoExt + ".dax")));
            pw.println(daxXML.toString());
            pw.close();

            // Write the VDL text.
            BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fileNoExt + ".vdlt")));
            dv.toString(bw);
            bw.close();

            // Write the VDL XML.
            bw = new BufferedWriter(new FileWriter(new File(fileNoExt + ".vdlx")));
            dv.toXML(bw, "", "");
            bw.close();

            // Call the Java that is called by vds.home/bin/dax2dot.
            String [] dax2dot = new String[] 
                {"-o" + fileNoExt + ".dot", "-f", fileNoExt + ".dax"};
            VizDAX.main(dax2dot);
        }
        catch (Exception ex) {
            throw new ElabException("Not able to save the derivation to the output directory.",ex);
        }
    }

    /**
     * Create a new Derivation associated with the current Transformation.
     * If {@link #setDVName} has not been called yet, the <code>dvName</code> will
     * be set to a string based off the current <code>outputDirName</code>.
     *
     * @param b A {@link MappableBean} containing the data which to map to the
     * Derivation.
     */
    public void createDV (MappableBean b) throws ElabException{
        //check if tr has been created
        if(tr == null){
            throw new ElabException("You must first create a new Transformation before creating a Derivation");
        }

        //if not set yet, base the dv name off outputDirName
        if(this.dvName == null){
            this.dvNamespace = this.trNamespace;
            this.dvName = this.outputDirName;
            this.dvVersion = this.trVersion;
        }
        dv = b.mapToDV(tr, dvNamespace, dvName, dvVersion, trNamespace, trName, trVersion, trVersion);
    }

    /**
     * Return the Derivation instance in this class
     */
    public Derivation getDV(){
        return dv;
    }

    /**
     * Create a new {@link Derivation} associated with the current 
     * <code>Transformation</code>.
     * If {@link #setDVName} has not been called yet, the <code>dvName</code> 
     * will be set to a string based off the current <code>outputDirName</code>.
     *
     * @param h key/pair values to map to the Derivation. String values will be
     * associated with {@link Scalar} and List values with 
     * {@link org.griphyn.vdl.classes.List}.
     */
    public void createDV (HashMap h) throws ElabException{
        //check if tr has been created
        if(tr == null){
            throw new ElabException("You must first create a new Transformation before creating a Derivation");
        }

        //if not set yet, base the dv name off outputDirName
        if(dvName == null){
            this.dvNamespace = this.trNamespace;
            this.dvName = this.outputDirName;
            this.dvVersion = this.trVersion;
        }

        //create a new empty DV
        dv = new Derivation(dvNamespace, dvName, dvVersion, trNamespace, trName, trVersion, trVersion);

        Set keys = h.keySet();
        if(keys == null || keys.isEmpty()){
            throw new ElabException("Key set for the Derivation HashMap is empty.");
        }
        for(Iterator i = keys.iterator(); i.hasNext(); ){
            Object k = i.next();
            Object v = h.get(k);
            if(v instanceof String){
                /*
                 * I believe this is a better place to escape newlines.
                 * After all, it's not a problem with the webapp, but with
                 * the implementation
                 */
                addToDV((String)k, ((String)v).replaceAll("\r\n?",
                                "\\\\n"));
            }
            else if(v instanceof java.util.List){
                addToDV((String)k, (java.util.List)v);
            }
        }
    }

    /**
     * Add a {@link Scalar} value to an existing {@link Derivation}.
     *
     * @param key the key to add
     * @param value the value of the key
     */     
    private void addToDV(String key, String value) throws ElabException{
        Declare dec;
        int link;

        dec = tr.getDeclare(key);
        if(dec == null){
            throw new ElabException("The key: " + key + " is not defined in the" +
                    " transformation (no Declare associated).");
        }
        link = dec.getLink();
        switch (link) {
            case LFN.NONE:
                dv.addPass(new Pass(key, new Scalar(new Text(value))));
                break;
            case LFN.INPUT:
            case LFN.INOUT:
            case LFN.OUTPUT:
                dv.addPass(new Pass(key, new Scalar( new LFN(value, link))));
                break;
        }
    }

    /**
     * Add a List value to an existing {@link Derivation}.
     *
     * @param key the key to add
     * @param value the List to add
     */     
    private void addToDV(String key, java.util.List value) throws ElabException{
        Declare dec;
        int link;

        dec = tr.getDeclare(key);
        if(dec == null){
            throw new ElabException("The key: " + key + " is not defined in the" +
                    " transformation (no Declare associated).");
        }
        link = dec.getLink();
        org.griphyn.vdl.classes.List list;
        switch (link) {
            case LFN.NONE:
                list = new org.griphyn.vdl.classes.List();
                for (Iterator j=value.iterator(); j.hasNext();) {
                    list.addScalar(new Scalar(new Text((String)j.next())));
                }
                dv.addPass(new Pass(key, list));
                break;
            case LFN.INPUT:
            case LFN.INOUT:
            case LFN.OUTPUT:
                list = new org.griphyn.vdl.classes.List();
                for (Iterator j=value.iterator(); j.hasNext();) {
                    list.addScalar(new Scalar(new LFN((String)j.next(), link)));
                }
                dv.addPass(new Pass(key, list));
                break;
        }
    }

    /**
     * Loads a single Definition from the backend database into this object.
     *
     * @param fqdn The full-qualified <code>Derivation</code> string to load.
     * @see VDC#loadDefinition
     */
    public void loadDV (String fqdn) throws ElabException{
        connect();

        String[] id;
        try{
            id = Separator.split(fqdn);
        } catch (IllegalArgumentException e){
            close();
            throw new ElabException("The dv name: " + fqdn + " cannot be parsed correctly.");
        }
        VDC vdc = (VDC)dbschema;
        Definition def;
        List defs;
        try{
            defs = vdc.searchDefinition(id[0], id[1], id[2], Definition.DERIVATION);
        } catch(Exception e){
            close();
            throw new ElabException("SQL exception when connecting to the database: " + e.getMessage());
        }
        if(defs == null || defs.size() == 0){
            close();
            throw new ElabException("The definition " + fqdn + " was not found in the database.");
        }
        if (defs.size() > 1) {
            System.err.println("Warning. Multiple definitions found for " + fqdn + ". Using the first one.");
        }
        this.dv = (Derivation) defs.iterator().next();
        close();
    }

    /**
     * Iterate through the <code>Transformation</code> {@link Declare} keys and
     * find ones that have not been set yet.
     *
     * @return A list of <code>Strings</code> of the keys which are null. Returns 
     * an empty </code>List</code> if none are null.
     * @see #getDVValue
     * @see #getDVValues
     */
    public java.util.List getNullKeys() throws ElabException {
        java.util.List nullKeys = new java.util.ArrayList();
        
        for (Iterator i = tr.iterateDeclare(); i.hasNext(); ) {
            Declare dec = (Declare)i.next();
            String decName = dec.getName();
            int type = dec.getContainerType();
            if(type == Value.SCALAR){
                String s = null;
                s = getDVValue(decName);
                if(s == null){
                    nullKeys.add(decName);
                }
            }
            else if(type == Value.LIST){
                java.util.List l = null;
                l = getDVValues(decName);
                if(l == null){
                    nullKeys.add(decName);
                }
                else if(l.size() == 0){
                    nullKeys.add(decName);
                }
            }
            else{
                throw new ElabException("The Declare key: " + decName + " is neither a SCALAR or a LIST (which is all this function supports");
            }
        }

        return nullKeys;
    }

    /**
     * This is just part of quick hack to run QuarkNet jobs on the Grid before Wales.
     */
    public void dumpForGrid() throws ElabException {
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before dumping for the Grid");
        }

        //createOutputDir();
        
        //create the route that makes the DAG for this job
        Route route = new Route(dbschema);
        BookKeeper state = new BookKeeper();
        Definitions defs = new Definitions();
        defs.addDefinition(dv);
        route.addDefinitions(defs);

        boolean b = route.requestDerivation(dvNamespace, dvName, dvVersion, state );
        if(!b){
            throw new ElabException("Didn't find anything for requestDerivation");
        }

        if ( state == null || state.isEmpty() ) {
            throw new ElabException("Failed to generate workflow for " + trName + "!");
        }

        try {
            daxXML = new StringWriter();
            //TODO what exactly do we want the string "run" to be?
            //state.getDAX( label==null ? "cosmic" : label ).toXML(sw, "");
            state.getDAX("run").toXML(daxXML, "");
            daxXML.close();
        } catch (Exception ex) {
            throw new ElabException("Problem generating DAX xml.");
        }

        // Now can run regular dump.
        dump();
    }

    /**
     * Set the number of events the raw data files in this job contain.
     * @see #calculateStrain
     */
    public void setNumberOfEvents(long events){
        numberOfEvents = events;
    }

    /**
     * Calculate the strain this {@link Job} will put on the system by running.
     * If the total number of jobs exceed some threshold, system response time 
     * becomes unacceptable. Therefore both the total number of jobs and the
     * number of jobs per user should be limited.<br/>
     *
     * Parameters for the algorithm: number of events, study type
     */
    public double calculateStrain() throws ElabException{
        if(numberOfEvents == -1)
            throw new ElabException("Please set the number of events for this job");
        if(trName == null)
            throw new ElabException("Please specify a tr name");

        /* switch case would work nice here */
        if(trName.equals("ShowerStudy")){
            strain = 2*((double)numberOfEvents/1000);
        }
        else if(trName.equals("PerformanceStudy")){
            strain = 1*((double)numberOfEvents/1000);
        }
        else if(trName.equals("LifetimeStudy")){
            strain = 3*((double)numberOfEvents/1000);
        }
        else if(trName.equals("FluxStudy")){
            strain = 1.5*((double)numberOfEvents/1000);
        }
        else{
            throw new ElabException("Study " + trName + " unknown, can't accept it as a new job");
        }

        return strain;
    }

    /**
     * Run this <code>Derivation</code> without the heartbeat output described
     * in {@link #run(JspWriter)}
     */
    public boolean run() throws ElabException{
        return run(null);
    }  

    /**
     * Run the current <code>Derivation</code> outputting the DAX scripts in
     * whatever <code>outputDir</code> is set to. Writes any output from 
     * STDOUT to a file called "out" in the run directory.
     *
     * @param out if not null, outputs a heartbeat to this handle during calculation
     *
     * @return true if there were no errors in the whole job, false otherwise
     */
    public boolean run(javax.servlet.jsp.JspWriter out) throws ElabException{
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before running this job.");
        }

        //create output directory
        try{
            File fDirName = new File(outputDir);
            fDirName.mkdirs();
        } catch(SecurityException e){
            throw new ElabException("Cannot create directory " + outputDir + ": " + e.getMessage());
        }
        
        //create the route that makes the DAG for this job
        Route route = new Route(dbschema);
        BookKeeper state = new BookKeeper();
        Definitions defs = new Definitions();
        defs.addDefinition(dv);
        route.addDefinitions(defs);

        boolean b = route.requestDerivation(dvNamespace, dvName, dvVersion, state );
        if(!b){
            throw new ElabException("Didn't find anything for requestDerivation");
        }

        if ( state == null || state.isEmpty() ) {
            throw new ElabException("Failed to generate workflow for " + trName + "!");
        }

        //setup shell scripts
        boolean genResult;
        try{
            daxXML = new StringWriter();
            //TODO what exactly do we want the string "run" to be?
            //state.getDAX( label==null ? "cosmic" : label ).toXML(sw, "");
            state.getDAX("run").toXML(daxXML, "");
            daxXML.close();
            //TODO StringBufferInputStream is deprecated as of JDK 1.1, but this would have to change in the VDS as well...
            StringBufferInputStream is = new StringBufferInputStream(daxXML.toString());
            Derive derive = new Derive();
            boolean build = true;
            boolean register = false;
            genResult = derive.genShellScripts(is, outputDir, build, register);

        } catch(Exception e){
            throw new ElabException("Exception while generating shell scripts", e);
        }

        if (!genResult) {
            throw new ElabException("genShellScripts returned false for " +
                    trName + " and outputDir: " + outputDir + "\n" + 
                    daxXML.toString());
        }

        //run shell scripts
        try{
            String[] cmd = new String[] {"bash", "-c", "cd " + outputDir + "; ./" + "run.sh"};    //output captured with Process Class
            Process p = Runtime.getRuntime().exec(cmd);

            //Note 10-23-04: to keep jsp from hanging, read out the standard output and write it to a log file. Do this BEFORE you call waitFor()
            BufferedReader stdOutput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            BufferedWriter outFile = new BufferedWriter(new FileWriter(outputDir + "/out"));
            String stdOutputString;
            outFile.write("Standard output from recently run bash script (run.sh):\n\n");
            while ((stdOutputString = stdOutput.readLine()) != null) {
                outFile.write(stdOutputString + "\n");
            }
            outFile.close();

            if(out != null){
                boolean procDone = false;
                int seconds = 0;
                int ret;        //process return value
                out.println("<!-- printing out heartbeats every second -->");
                while (!procDone) {
                    try {
                        ret = p.exitValue();
                        procDone = true;
                        out.println("<!-- finishing heartbeat second " + seconds + "-->");
                        out.flush();
                    }
                    catch (IllegalThreadStateException ex) {
                        out.println("<!-- heartbeat second " + seconds + "-->");
                        seconds++;
                        out.flush(); // necessary to send to client immediately.
                        try{
                            Thread.sleep(1000); // sleep for a second
                        }
                        catch (InterruptedException e){
                            throw new ElabException("while running run.sh Thread process and trying to Sleep(): " + e.getMessage());
                        }
                    }
                }
            }
            int c;
            try{
                c = p.waitFor();
            } catch (Exception e){
                throw new ElabException("Exception while waiting for process to complete: " + e);
            }

            if (c != 0) {			
                StringBuffer sb = new StringBuffer();

                BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
                String stdErrorString;
                while ((stdErrorString = stdError.readLine()) != null) {
                    sb.append(stdErrorString);
                    sb.append('\n');
                }
                sb.append("Exit code: ");
                sb.append(String.valueOf(c));
                throw new ElabShellException(sb.toString());
            }
        } catch(IOException e){
            //out.println(e);
            throw new ElabException("IOException when running the shell scripts: " + e);
        }

        return true;
    }

    /**
     * Store the <code>Derivation</code> instance into the backend database.
     * @see Define#store
     */
    public void storeDV() throws ElabException{
        Define define;
        try{
            define = new Define(dbschema);
        } catch(Exception e){
            throw new ElabException("IOException while creating a new Define");
        }
        boolean b1 = define.store(this.dv);
        if(!b1){
            throw new ElabException("Derivation store didn't work for: " + this.dv.identify());
        }
    }

    /**
     * Get the value of a {@link Leaf} within the <code>Derivation</code>.
     *
     * @param decName Name of the <code>Leaf</code> to get the value of.
     * @return Value of the <code>Leaf</code>.
     */
    public String getDVValue(String decName) throws ElabException{
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before getting a value from it.");
        }

        Pass p = dv.getPass(decName);
        if(p == null){
            throw new ElabException("Key " + decName + " not found in the Transformation");
        }
        Value v = p.getValue();
        int type = v.getContainerType();
        if(type != Value.SCALAR){
            throw new ElabException("Key " + decName + " is not a Value.SCALAR type. If you are expecting a List of values for this key, please use getDVValues() or update the VDC with correct VDL");
        }

        Iterator i = ((Scalar)v).iterateLeaf();   //because I don't know where the array starts to use v.getLeaf(index)
        Leaf leaf = (Leaf)i.next();
        //TODO fix this to remove instanceof checking once they fix their superclass in VDL
        if(leaf instanceof LFN){
            return ((LFN)leaf).getFilename();
        }
        else if(leaf instanceof Text){
            return ((Text)leaf).getContent();
        }
        else{
            throw new ElabException("Leaf instance must either be of type LFN or Text.");
        }
    }

    /**
     * Get the values of a {@link Leaf} within the <code>Derivation</code>.
     *
     * @param decName Name of the <code>Leaf</code> to get the values of.
     * @return {@link List} of values for the <code>Leaf</code>.
     */
    public java.util.List getDVValues(String decName) throws ElabException{
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before getting values from it.");
        }

        Pass p = dv.getPass(decName);
        if(p == null){
            throw new ElabException("Key " + decName + " not found in the Transformation");
        }
        Value v = p.getValue();
        int type = v.getContainerType();
        if(type != Value.LIST){
            throw new ElabException("Key " + decName + " is not a Value.SCALAR type. If you are expecting a Scalar value for this key, please use getDVValue() or update the VDC with correct VDL");
        }

        java.util.List list = new java.util.ArrayList();
        java.util.List scalarList = ((org.griphyn.vdl.classes.List)v).getScalarList();
        for(Iterator i=scalarList.iterator(); i.hasNext(); ){
            Value v2 = (Value)i.next();

            Iterator i2 = ((Scalar)v2).iterateLeaf();   //because I don't know where the array starts to use v.getLeaf(index)
            Leaf leaf = (Leaf)i2.next();
            String value;
            //TODO fix this to remove instanceof checking once they fix their superclass in VDL
            if(leaf instanceof LFN){
                value = ((LFN)leaf).getFilename();
            }
            else if(leaf instanceof Text){
                value = ((Text)leaf).getContent();
            }
            else{
                throw new ElabException("Leaf instance must either be of type LFN or Text.");
            }
            list.add(value);
        }
        return list;
    }
}
