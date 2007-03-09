<!-- still in an encompasing <table> in doAnalysis.jsp -->

<tr>
    <td align="center">To save this plot permanently, enter the new name you want.<BR>Then click <b>Save Plot</b>.<br>
        <FORM name="SaveForm" ACTION="save.jsp"  method="post" target="saveWindow" onsubmit='return openPopup("",this.target,500,200);'>
<%
        //Metadata section
        //there seems to be an unwritten rule to use lowercase for metadata...
        //pass any arguments to write as metadata in the "metadata" form variable as tuple strings
%>

<%@ include file="doAnalysis_common_metadata.jsp" %>

<%
        //lifetime-specific metadata:
        String m_study = "study string lifetime";
        String m_type = "type string plot";

        String m_energycheck = request.getParameter("lifetime_energyCheck");
        String m_numBins = request.getParameter("freq_binValue") ;
        String m_plot_title = request.getParameter("plot_title");
        String m_plot_caption = request.getParameter("plot_caption");
        m_plot_caption = m_plot_caption.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"

        String m_lifetime = "0.0";
        String m_lifetime_err = "0.0";
        String m_alpha = "0.0";
        String m_alpha_err = "0.0";
        String m_constant = "0.0";
        String m_constant_err = "0.0";

        // read the raw file and extract the metadata for lifetime, alpha and constant
        //find location and name for fit logfile 
        File lifetimeDirectory = new File(runDir);
        String singleFile, lifetimeLine, lifetimeFileLocation ="none"; 
        String[] splitLife = new String[9];
        String[] directoryList = lifetimeDirectory.list();
        for (int j=0; j<directoryList.length; j++) {
            singleFile = directoryList[j];
            if (singleFile.indexOf("extraFun_out") != -1){
                lifetimeFileLocation = singleFile;
            }
        }
        if(lifetimeFileLocation != "none"){
            lifetimeFileLocation= runDir + "/" + lifetimeFileLocation;
            //open file and match strings while reading from it.
            BufferedReader inLifetimeFileBuffer = new BufferedReader(new FileReader(lifetimeFileLocation));
            while(inLifetimeFileBuffer.ready() ){
                lifetimeLine=inLifetimeFileBuffer.readLine();
                splitLife=lifetimeLine.split("\\s");
                //match strings
                if(splitLife[0].equalsIgnoreCase("alpha:")) { 
                    m_alpha = splitLife[1];
                } else if (splitLife[0].equalsIgnoreCase("alpha_error:")) {
                    if(splitLife[1].equalsIgnoreCase("+/-")) {
                        m_alpha_err = splitLife[2];
                    } else { m_alpha_err = splitLife[1]; }
                } else if (splitLife[0].equalsIgnoreCase("lifetime:")) {
                    m_lifetime = splitLife[1];
                } else if (splitLife[0].equalsIgnoreCase("lifetime_error:")) {
                    if(splitLife[1].equalsIgnoreCase("+/-")) {
                        m_lifetime_err = splitLife[2];
                    } else { m_lifetime_err = splitLife[1]; }
                } else if (splitLife[0].equalsIgnoreCase("constant:")) {
                    m_constant = splitLife[1];
                } else if (splitLife[0].equalsIgnoreCase("constant_error:")) {
                    if(splitLife[1].equalsIgnoreCase("+/-")) {
                        m_constant_err = splitLife[2];
                    } else { m_constant_err = splitLife[1]; }
                }
            }
        }
%>

        <input type="hidden" name="metadata" value="<%=m_type%>" >
        <input type="hidden" name="metadata" value="<%=m_study%>" >

        <input type="hidden" name="metadata" value="<%="energycheck int " + m_energycheck%>" >
        <input type="hidden" name="metadata" value="<%="numBins float " + m_numBins%>" >
        <input type="hidden" name="metadata" value="<%="title string " + m_plot_title%>" >
        <input type="hidden" name="metadata" value="<%="caption string " + m_plot_caption%>" >

        <input type="hidden" name="metadata" value="<%="background_constant float " + m_constant%>" >
        <input type="hidden" name="metadata" value="<%="background_constant_error float " + m_constant_err%>" >
        <input type="hidden" name="metadata" value="<%="alpha float " + m_alpha%>" >
        <input type="hidden" name="metadata" value="<%="alpha_error float " + m_alpha_err%>" >
        <input type="hidden" name="metadata" value="<%="lifetime(microseconds) float " + m_lifetime%>" >
        <input type="hidden" name="metadata" value="<%="lifetime_error(microseconds) float " + m_lifetime_err%>" >

        <input type="hidden" name="scratchFile" value="<%=scratchPlot%>" >
        <input type="hidden" name="thumbnail" value="<%=thumbnail%>" >
        <input type="text" name="permanentFile"  size="20" maxlength="30">.png
        <input type="hidden" name="fileType" value="png" >
        <input name="save" type="submit" value="Save Plot">
        </form>
    </td>
</tr>
