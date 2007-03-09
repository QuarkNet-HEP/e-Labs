package gov.fnal.elab.vds;

import java.util.*;
import java.io.*;   //StringWriter and PrintWriter, BufferedReader
import java.lang.*; //String, Process
import java.sql.*;
import gov.fnal.elab.util.*;
import gov.fnal.elab.beans.MappableBean;
import gov.fnal.elab.db.*;
import org.griphyn.vdl.classes.*;   //Definition, Transformation, Derivation, Definitions
import org.griphyn.vdl.util.ChimeraProperties;
import org.griphyn.vdl.directive.*;
import org.griphyn.vdl.dbschema.DatabaseSchema;
import org.griphyn.vdl.dbschema.VDC;
import org.griphyn.vdl.dbschema.AnnotationSchema;
import org.griphyn.common.util.*;
import org.griphyn.vdl.router.Route;
import org.griphyn.vdl.router.BookKeeper;
import org.griphyn.vdl.toolkit.VizDAX;

/**
 * Class for interaction with the VDS via a {@link Transformation} and
 * {@link Derivation}.
 *
 * @author Paul Nepywoda (nepywoda -at- f n a l -dot- gov)
 * @author Eric Gilbert (egilbert -at- f n a l -dot- gov)
 * @see Transformation
 * @see Derivation
 */
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
            throw new ElabException("Database connecting error", e);
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
                throw new ElabException("The tr name: " + s + " cannot be parsed correctly.", e);
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
            throw new ElabException("Error while setting up the Transformation", e);
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
            throw new ElabException("The dv name: " + trName + " cannot be parsed correctly.", e);
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
                addToDV((String)k, (String)v);
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
            throw new ElabException("The dv name: " + fqdn + " cannot be parsed correctly.", e);
        }
        VDC vdc = (VDC)dbschema;
        Definition def;
        try{
            def = vdc.loadDefinition(id[0], id[1], id[2], Definition.DERIVATION);
        } catch(Exception e){
            close();
            throw new ElabException("SQL exception when connecting to the database", e);
        }
        if(def == null){
            close();
            throw new ElabException("The definition " + fqdn + " was not found in the database.");
        }
        this.dv = (Derivation)def;
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
            throw new ElabException("Problem generating DAX xml.", ex);
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
     * Determine if the strain on the system is under a certain limit, if it 
     * is, create the VDS shell scripts, a new Job to represent this specific
     * run, and run the job (returning immediately).
     * 
     * Run the current <code>Derivation</code> outputting the DAX scripts in
     * whatever <code>outputDir</code> is set to. Writes any output from 
     * STDOUT to a file called "out" in the run directory. Returns immediately
     * without blocking. Asyncronous status information will be written to
     * the <code>Job</code> table. Stores the <code>Derivation</code> in
     * the VDC on <code>Job</code> creation.
     * @param sessionLogin The {@link SessionLogin} which made and owns this job.
     * @see Job
     * @see #storeDV
     */
    public void runReturn(final SessionLogin sessionLogin) throws ElabException{
        /*
         * Initial setup work before creating the shell scripts
         */
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before running this job.");
        }

        //create output directory
        try{
            File fDirName = new File(outputDir);
            fDirName.mkdirs();
        } catch(SecurityException e){
            throw new ElabException("Cannot create directory " + outputDir, e);
        }

        /**
         * Strain calculation. Throw an exception if this new Job will put the
         * total system strain over a certain threshold.
         * @see #calculateStrain
         */
        strain = calculateStrain();

        /* Total user strain limit */
        if(strain > 5000){
            ElabTooManyJobsException e = new ElabTooManyJobsException("");
            e.setStrain(strain);
            e.setIsOverUserLimit(true);
            throw e;
        }

        //TODO get total system strain
        /* Total system strain limit */
        /*
        if(systemStrain > 10){
            throw new ElabTooManyJobsException("");
        }
        */


        
        /**
         * We've been given the go-ahead for running this job
         */
        //create the route that makes the DAG for this job
        Route route = new Route(dbschema);
        BookKeeper state = new BookKeeper();
        Definitions defs = new Definitions();
        defs.addDefinition(dv);
        route.addDefinitions(defs);

        boolean b = route.requestDerivation(dvNamespace, dvName, dvVersion, state );
        if(!b){
            throw new ElabShellException("Didn't find anything for requestDerivation");
        }

        if ( state == null || state.isEmpty() ) {
            throw new ElabShellException("Failed to generate workflow for " + trName + "!");
        }

        //setup shell scripts
        int c;
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
            c = derive.genShellScripts(is, outputDir, build, register) ? 0:1;

        } catch(Exception e){
            throw new ElabShellException("While generating shell scripts: " + e);
        }

        if (c != 0) {
            throw new ElabShellException("genShellScripts returned non-zero for " + trName + 
                    " and outputDir: " + outputDir + "!\n" + daxXML.toString());
        }

        /* The job object which represents this run */
        Job job = new Job();
        job.setOwner(sessionLogin.getLogin());
        job.setIdentifier("PID4"); //TODO
        job.setDirectory(outputDir);
        job.setDVName(dvNamespace + "::" + dvName);     //NOTE: dvVersion not being used here (we don't version our files at this time)
        job.setStudyType(trName);
        job.setRunLocation("local");
        job.setNumberOfNodes(3);  //TODO
        job.setNodesCompleted(0);
        job.setCurrentStatus("currently starting...");
        job.setNumberOfEvents(numberOfEvents);
        job.setStrain(strain);
        job.setStage(Job.STARTING);
        job.save(true);

        final int jobId = job.getId();
        this.jobId = jobId;

        /* Store the derivation object used to run this job in the VDS */
        this.storeDV();


        /*
         * Shell script setup complete. Spawn thread and don't block.
         * NOTE: no database objects which were opened in this thread can be
         * passed to runShellScripts (since we're creating a new thread). This
         * is a consequence of using the SessionPerThread pattern in Hibernate.
         */

        new Thread() {
            public void run() {
                try{
                    runShellScripts(sessionLogin, jobId);
                } catch(Exception e){
                    //can't throw exceptions in anonymous threads
                }
            }
        }.start();
    }

    /**
     */
    public void runTeraportReturn(String groupID, final Connection c) throws ElabException, Exception {
        /*
         * Initial setup work before creating the shell scripts
         */
        //check if dv has been created
        if(dv == null){
            throw new ElabException("You must first create a new Derivation before running this job.");
        }

        //create output directory
        try{
            File fDirName = new File(outputDir);
            fDirName.mkdirs();
        } catch(SecurityException e){
            throw new ElabException("Cannot create directory " + outputDir , e);
        }

        /**
         * We've been given the go-ahead for running this job
         */
        //create the route that makes the DAG for this job
        Route route = new Route(dbschema);
        BookKeeper state = new BookKeeper();
        Definitions defs = new Definitions();
        defs.addDefinition(dv);
        route.addDefinitions(defs);

        boolean b = route.requestDerivation(dvNamespace, dvName, dvVersion, state );
        if(!b){
            throw new ElabShellException("Didn't find anything for requestDerivation");
        }

        if ( state == null || state.isEmpty() ) {
            throw new ElabShellException("Failed to generate workflow for " + trName + "!");
        }

        //setup shell scripts
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
            //c = derive.genShellScripts(is, outputDir, build, register) ? 0:1;

        } catch(Exception e){
            throw new ElabShellException("While generating shell scripts: " + e);
        }

        /* The job object which represents this run */
        Statement s = c.createStatement();
        int rowsInserted = s.executeUpdate(
            "insert into jobs(rg_id, job_dir, job_type, curr_status, submit_time) " +
            "values ('" + groupID + "', '" + outputDir + "', '', 'starting', 'now')");
        // assert that a single row has been inserted
        if(rowsInserted != 1) { 
            throw new RuntimeException("Wrong number of job rows inserted. Should be 1, actually got "+rowsInserted);}
        ResultSet rs = s.executeQuery("select id from jobs where rg_id = '" + groupID + "' and job_dir = '" + outputDir + "'");
        rs.next();
        final int jobID = rs.getInt("id");

        /* Store the derivation object used to run this job in the VDS */
        this.storeDV();

        new Thread() {
            public void run() {
                try{
                    runTeraport(jobID, c);
                } catch(Exception e){
                    //can't throw exceptions in anonymous threads
                }
            }
        }.start();
    }

    private void runTeraport(int jobID, Connection c) throws Exception {
        System.err.println("Starting WorkflowTest");

        String vdshome;

        /* get $VDS_HOME */

        try { vdshome = VDSProperties.instance().getVDSHome(); }
        catch(Exception e) {
            System.err.println("Cant get properties. Check -D$VDS_HOME set.");
            return;
        }
        Workflow.runwfCmd = vdshome + "/bin/vds-Workflow-script-runwf";
        Workflow.rlsURL = "rls://terminable.uchicago.edu"; /* Get from .vdsrc file */

        Workflow.defaultVOGroup = "quarknet";
        Workflow.logicalFileNameBase = "/home/dscheftn/quarknet_testing/runs";
        Workflow.defaultBaseDir = "/home/dscheftn/quarknet";

	    Workflow wf = Workflow.run(dvNamespace, dvName);

        if ( ! wf.errorMessage.equals("SUCCESS") ) {
            // insert that failure notification stuff
            return;
        } else {
            try {
                Statement s = c.createStatement();
                s.executeUpdate("update jobs set curr_status = 'Running' where id = " + jobID);
            } catch (Exception e) {
                throw new ElabException("", e);
            }
        }

        /* Wait for workflow to finish */
        while(true) {
            System.err.println("wf status:" + wf.toDetailStatusString());
	        if( (wf.state.equals("WFSTATE_FINISHED")) ) {
                try {
                    Statement s = c.createStatement();
                    s.executeUpdate("update jobs set curr_status = 'Finished' where id = " + jobID);
                } catch (Exception e) {
                    throw new ElabException("", e);
                }
                break;
            }

	        try { Thread.sleep(5000); } catch (Exception e) { }
        }
    }

    /**
     * Assuming {@link #runReturn} has run and the shell scripts are setup in
     * the output directory, run the scripts and update the database every 10
     * seconds with status information.
     * @param sessionLogin The {@link SessionLogin} which made and owns this job.
     * @param jobID The {@link Job} id bound to this run.
     * @see Job
     * @see #runReturn
     */
    private void runShellScripts(SessionLogin sessionLogin, int jobID){
        PrintWriter out = null;
        try{
            out = new PrintWriter(new BufferedWriter(new FileWriter(outputDir + "/out")));
        } catch (Exception e){
            //can't do anything with this exception
        }

        try{
            String[] cmd = new String[] {"bash", "-c", "cd " + outputDir + "; ./" + "run.sh"};
            Process p = Runtime.getRuntime().exec(cmd);

            Job job = (Job)DBObject.findById("Job", jobID);
            job.setStage(Job.RUNNING);
            job.setCurrentStatus("calculating...");
            job.save(true);

            out.println("Standard output from recently run bash script (run.sh):\n\n");

            Thread.sleep(1000);    //sleep for 1 second to allow run.log to be written

            int ret = -1;
            boolean processDone = false;
            String line = "";
            BufferedReader runLog = null;
            while(!processDone){
                try{
                    ret = p.exitValue();
                    processDone = true;
                } catch(IllegalThreadStateException e){
                    try{
                        /* Try to open the run.log file. If it doesn't exist yet, try later */
                        runLog = new BufferedReader(new FileReader( new File(outputDir + "/run.log")));
                    } catch(FileNotFoundException ex){
                        //try again later...
                    }
                    if(runLog != null){
                        /*
                         * Parse the run.log and keep updating the Job object until the job has finished
                         */
                        String lastLine = "";
                        while((line = runLog.readLine()) != null){
                            /*
                             * NOTE: this is heavily dependent on how run.log formats data
                             * example:
                             * 2005-08-04T14:09:55 ID000002 started Quarknet.Cosmic__Combine
                             */
                            lastLine = line;
                        }
                        String[] split = lastLine.split(" ");
                        String date = split[0];
                        String id = split[1];
                        String info = split[2];
                        String node = split[3];
                        int idNumber = Integer.parseInt(id.substring(2));

                        job.setNodesCompleted(idNumber);
                        job.setCurrentStatus(lastLine);

                        job.update(true); //update the database
                        out.println("job updated");
                    }

                    Thread.sleep(5000);    //sleep for 5 seconds
                }
            }

            /*
             * Read STDOUT and write to a file called "out" in outputDir
             */
            BufferedReader stdOutput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String outputString;
            while ((outputString = stdOutput.readLine()) != null) {
                out.println(outputString);
            }

            /*
             * If there was an error returned from the shell Process, write it
             * to the out file and set an error on the job.
             */
            if (ret != 0) {			
                String errorString = "";

                BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
                while ((outputString = stdError.readLine()) != null) {
                    errorString += outputString;
                }

                out.println(errorString);  //append error string to out file

                job.setIsError(true);
                job.setCurrentStatus(errorString);
            }

            try{
                runLog = new BufferedReader(new FileReader( new File(outputDir + "/run.log")));
            } catch(FileNotFoundException e){
                //unfortunately, we've never been able to open the run.log file...
                out.println("havn't been able to open run.log file");
            }
            if(runLog != null){
                /* Do one final pass on the job object for final run information */
                String lastLine = "";
                while((line = runLog.readLine()) != null){
                    //TODO set job based on stuff we parse
                    lastLine = line;
                    out.println("runlog:" + lastLine);
                }
                String[] split = lastLine.split(" ");
                /*
                 * NOTE: this is heavily dependent on how run.log formats data
                 * example:
                 * 2005-08-04T14:09:55 ID000002 started Quarknet.Cosmic__Combine
                 */
                String date = split[0];
                String id = split[1];
                String info = split[2];
                String node = split[3];
                int idNumber = Integer.parseInt(id.substring(2));
                out.println("idnumber: " +idNumber);

                job.setNodesCompleted(idNumber);
                job.setCurrentStatus(lastLine);
            }

            /* Final job status update */
            job.setStage(Job.FINISHED);
            job.setFinishTime(new java.util.Date());
            job.update(true); //update the database
            out.println("job updated for the last time");

        } catch(Exception e){
            //can't throw this Exception anywhere...write it to the STDOUT file
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw, true);
            e.printStackTrace(pw);
            pw.flush();
            sw.flush();
            out.println("Exception: " + sw.toString());
        } finally {
            out.close();
        }
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
            throw new ElabException("Cannot create directory " + outputDir, e);
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
            throw new ElabException("While generating shell scripts", e);
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
                            throw new ElabException("while running run.sh Thread process and trying to sleep()", e);
                        }
                    }
                }
            }
            int c;
            try{
                c = p.waitFor();
            } catch (Exception e){
                throw new ElabException("Exception while waiting for process to complete", e);
            }

            if (c != 0) {			
                String myError = "";

                BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
                String stdErrorString;
                while ((stdErrorString = stdError.readLine()) != null) {
                    myError += stdErrorString + "\n";
                }
                throw new ElabShellException(myError);
            }
        } catch(IOException e){
            //out.println(e);
            throw new ElabException("IOException when running the shell scripts: ", e);
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
