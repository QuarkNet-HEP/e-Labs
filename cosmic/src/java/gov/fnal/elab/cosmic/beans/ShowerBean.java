package gov.fnal.elab.cosmic.beans;

import java.io.*;                   //String
import java.util.*;                 //List
import gov.fnal.elab.util.*;        //ElabException
import gov.fnal.elab.beans.*;       //MappableBean, ElabBean
import org.griphyn.vdl.classes.*;   //Derivation, Declare, LFN, List

public class ShowerBean extends ElabBean implements Serializable, MappableBean{

    //TR variables
    private String channelCoincidence;
    private String combineOut;
    private String detectorCoincidence;
    private String detector;
    private String eventCandidates;
    private String eventCoincidence;
    private String eventFile;
    private String eventNum;
    private String extraFun_out;
    private String gate;
    private String geoDir;
    private String plot_caption;
    private String plot_highX;
    private String plot_highY;
    private String plot_highZ;
    private String plot_lowX;
    private String plot_lowY;
    private String plot_lowZ;
    private String plot_outfile_param;
    private String plot_outfile_image;
    private String plot_plot_type;
    private String plot_title;
    private String plot_xlabel;
    private String plot_ylabel;
    private String plot_zlabel;
    private String sort_sortKey1;
    private String sort_sortKey2;
    private String sortOut;
    private String zeroZeroZeroID;
    private java.util.List rawData;
    private java.util.List thresholdAll;
    private java.util.List wireDelayData;

    //Constructor
    public ShowerBean(){
        this.reset();
    }


    //get/set methods (scalar)
    public void setChannelCoincidence(String s){
        channelCoincidence = s;
    }

    public String getChannelCoincidence(){
        return channelCoincidence;
    }

    public void setCombineOut(String s){
        combineOut = s;
    }

    public String getCombineOut(){
        return combineOut;
    }

    public void setDetectorCoincidence(String s){
        detectorCoincidence = s;
    }

    public String getDetectorCoincidence(){
        return detectorCoincidence;
    }

    public void setDetector(String s){
        detector = s;
    }

    public String getDetector(){
        return detector;
    }

    public void setEventCandidates(String s){
        eventCandidates = s;
    }

    public String getEventCandidates(){
        return eventCandidates;
    }

    public void setEventCoincidence(String s){
        eventCoincidence = s;
    }

    public String getEventCoincidence(){
        return eventCoincidence;
    }

    public void setEventFile(String s){
        eventFile = s;
    }

    public String getEventFile(){
        return eventFile;
    }

    public void setEventNum(String s){
        eventNum = s;
    }

    public String getEventNum(){
        return eventNum;
    }

    public void setExtraFun_out(String s){
        extraFun_out = s;
    }

    public String getExtraFun_out(){
        return extraFun_out;
    }

    public void setGate(String s){
        gate = s;
    }

    public String getGate(){
        return gate;
    }

    public void setGeoDir(String s){
        geoDir = s;
    }

    public String getGeoDir(){
        return geoDir;
    }

    public void setPlot_caption(String s){
        plot_caption = s;
    }

    public String getPlot_caption(){
        return plot_caption;
    }

    public void setPlot_highX(String s){
        plot_highX = s;
    }

    public String getPlot_highX(){
        return plot_highX;
    }

    public void setPlot_highY(String s){
        plot_highY = s;
    }

    public String getPlot_highY(){
        return plot_highY;
    }

    public void setPlot_highZ(String s){
        plot_highZ = s;
    }

    public String getPlot_highZ(){
        return plot_highZ;
    }

    public void setPlot_lowX(String s){
        plot_lowX = s;
    }

    public String getPlot_lowX(){
        return plot_lowX;
    }

    public void setPlot_lowY(String s){
        plot_lowY = s;
    }

    public String getPlot_lowY(){
        return plot_lowY;
    }

    public void setPlot_lowZ(String s){
        plot_lowZ = s;
    }

    public String getPlot_lowZ(){
        return plot_lowZ;
    }

    public void setPlot_outfile_param(String s){
        plot_outfile_param = s;
    }

    public String getPlot_outfile_param(){
        return plot_outfile_param;
    }

    public void setPlot_outfile_image(String s){
        plot_outfile_image = s;
    }

    public String getPlot_outfile_image(){
        return plot_outfile_image;
    }

    public void setPlot_plot_type(String s){
        plot_plot_type = s;
    }

    public String getPlot_plot_type(){
        return plot_plot_type;
    }

    public void setPlot_title(String s){
        plot_title = s;
    }

    public String getPlot_title(){
        return plot_title;
    }

    public void setPlot_xlabel(String s){
        plot_xlabel = s;
    }

    public String getPlot_xlabel(){
        return plot_xlabel;
    }

    public void setPlot_ylabel(String s){
        plot_ylabel = s;
    }

    public String getPlot_ylabel(){
        return plot_ylabel;
    }

    public void setPlot_zlabel(String s){
        plot_zlabel = s;
    }

    public String getPlot_zlabel(){
        return plot_zlabel;
    }

    public void setSort_sortKey1(String s){
        sort_sortKey1 = s;
    }

    public String getSort_sortKey1(){
        return sort_sortKey1;
    }

    public void setSort_sortKey2(String s){
        sort_sortKey2 = s;
    }

    public String getSort_sortKey2(){
        return sort_sortKey2;
    }

    public void setSortOut(String s){
        sortOut = s;
    }

    public String getSortOut(){
        return sortOut;
    }

    public void setZeroZeroZeroID(String s){
        zeroZeroZeroID = s;
    }

    public String getZeroZeroZeroID(){
        return zeroZeroZeroID;
    }

    //get/set methods (list)
    public void setRawData(java.util.List s){
        rawData = s;
    }

    public java.util.List getRawData(){
        return rawData;
    }

    public void setThresholdAll(java.util.List s){
        thresholdAll = s;
    }

    public java.util.List getThresholdAll(){
        return thresholdAll;
    }

    public void setWireDelayData(java.util.List s){
        wireDelayData = s;
    }

    public java.util.List getWireDelayData(){
        return wireDelayData;
    }



    //testing if the input is valid (scalar)
    public boolean isChannelCoincidenceValid(){
        return true;
    }

    public boolean isCombineOutValid(){
        return true;
    }

    public boolean isDetectorCoincidenceValid(){
        return true;
    }

    public boolean isDetectorValid(){
        return true;
    }

    public boolean isEventCandidatesValid(){
        return true;
    }

    public boolean isEventCoincidenceValid(){
        return true;
    }

    public boolean isEventFileValid(){
        return true;
    }

    public boolean isEventNumValid(){
        return true;
    }

    public boolean isExtraFun_outValid(){
        return true;
    }

    public boolean isGateValid(){
        return true;
    }

    public boolean isGeoDirValid(){
        return true;
    }

    public boolean isPlot_captionValid(){
        return true;
    }

    public boolean isPlot_highXValid(){
        return true;
    }

    public boolean isPlot_highYValid(){
        return true;
    }

    public boolean isPlot_highZValid(){
        return true;
    }

    public boolean isPlot_lowXValid(){
        return true;
    }

    public boolean isPlot_lowYValid(){
        return true;
    }

    public boolean isPlot_lowZValid(){
        return true;
    }

    public boolean isPlot_outfile_paramValid(){
        return true;
    }

    public boolean isPlot_outfile_imageValid(){
        return true;
    }

    public boolean isPlot_plot_typeValid(){
        return true;
    }

    public boolean isPlot_titleValid(){
        return true;
    }

    public boolean isPlot_xlabelValid(){
        return true;
    }

    public boolean isPlot_ylabelValid(){
        return true;
    }

    public boolean isPlot_zlabelValid(){
        return true;
    }

    public boolean isSort_sortKey1Valid(){
        return true;
    }

    public boolean isSort_sortKey2Valid(){
        return true;
    }

    public boolean isSortOutValid(){
        return true;
    }

    public boolean isZeroZeroZeroIDValid(){
        return true;
    }


    //testing if the input is valid (list)
    public boolean isRawDataValid(){
        if(rawData == null)
            return false;
        return true;
    }

    public boolean isThresholdAllValid(){
        if(thresholdAll == null)
            return false;
        return true;
    }

    public boolean isWireDelayDataValid(){
        if(wireDelayData == null)
            return false;
        return true;
    }


    //returns true is every key value is valid
    public boolean isValid(){
        java.util.List badkeys = this.getInvalidKeys();
        return badkeys.size() > 0 ? false : true;
    }

    //get a List of invalid keys
    public java.util.List getInvalidKeys(){
        java.util.List badkeys = new java.util.ArrayList();
        if(!isChannelCoincidenceValid()){
            badkeys.add("channelCoincidence");
        }
        if(!isCombineOutValid()){
            badkeys.add("combineOut");
        }
        if(!isDetectorCoincidenceValid()){
            badkeys.add("detectorCoincidence");
        }
        if(!isDetectorValid()){
            badkeys.add("detector");
        }
        if(!isEventCandidatesValid()){
            badkeys.add("eventCandidates");
        }
        if(!isEventCoincidenceValid()){
            badkeys.add("eventCoincidence");
        }
        if(!isEventFileValid()){
            badkeys.add("eventFile");
        }
        if(!isEventNumValid()){
            badkeys.add("eventNum");
        }
        if(!isExtraFun_outValid()){
            badkeys.add("extraFun_out");
        }
        if(!isGateValid()){
            badkeys.add("gate");
        }
        if(!isGeoDirValid()){
            badkeys.add("geoDir");
        }
        if(!isPlot_captionValid()){
            badkeys.add("plot_caption");
        }
        if(!isPlot_highXValid()){
            badkeys.add("plot_highX");
        }
        if(!isPlot_highYValid()){
            badkeys.add("plot_highY");
        }
        if(!isPlot_highZValid()){
            badkeys.add("plot_highZ");
        }
        if(!isPlot_lowXValid()){
            badkeys.add("plot_lowX");
        }
        if(!isPlot_lowYValid()){
            badkeys.add("plot_lowY");
        }
        if(!isPlot_lowZValid()){
            badkeys.add("plot_lowZ");
        }
        if(!isPlot_outfile_paramValid()){
            badkeys.add("plot_outfile_param");
        }
        if(!isPlot_outfile_imageValid()){
            badkeys.add("plot_outfile_image");
        }
        if(!isPlot_plot_typeValid()){
            badkeys.add("plot_plot_type");
        }
        if(!isPlot_titleValid()){
            badkeys.add("plot_title");
        }
        if(!isPlot_xlabelValid()){
            badkeys.add("plot_xlabel");
        }
        if(!isPlot_ylabelValid()){
            badkeys.add("plot_ylabel");
        }
        if(!isPlot_zlabelValid()){
            badkeys.add("plot_zlabel");
        }
        if(!isSort_sortKey1Valid()){
            badkeys.add("sort_sortKey1");
        }
        if(!isSort_sortKey2Valid()){
            badkeys.add("sort_sortKey2");
        }
        if(!isSortOutValid()){
            badkeys.add("sortOut");
        }
        if(!isZeroZeroZeroIDValid()){
            badkeys.add("zeroZeroZeroID");
        }
        if(!isRawDataValid()){
            badkeys.add("rawData");
        }
        if(!isThresholdAllValid()){
            badkeys.add("thresholdAll");
        }
        if(!isWireDelayDataValid()){
            badkeys.add("wireDelayData");
        }
        return badkeys;
    }


    //returns a new Derivation with all your info in it
    public Derivation mapToDV(Transformation tr,
                            String ns,
                            String name,
                            String version,
                            String us,
                            String uses,
                            String min,
                            String max)
                            throws ElabException{
        java.util.List<String> badkeys = getInvalidKeys();
        if(badkeys.size() > 0){
            StringBuilder sb = new StringBuilder("The following keys are invalid within the bean: ");
            for (String s : badkeys) {
            	sb.append(s);
            	sb.append(" ");
            }
            throw new ElabException(sb.toString());
        }

        //copy tr variable (used in addToDV)
        this.tr = tr;

        //create a new empty DV
        dv = new Derivation(ns, name, version, us, uses, min, max);

        //name these exactly as they're named in the TR in the VDC
        addToDV("channelCoincidence", channelCoincidence);
        addToDV("combineOut", combineOut);
        addToDV("detectorCoincidence", detectorCoincidence);
        addToDV("detector", detector);
        addToDV("eventCandidates", eventCandidates);
        addToDV("eventCoincidence", eventCoincidence);
        addToDV("eventFile", eventFile);
        addToDV("eventNum", eventNum);
        addToDV("extraFun_out", extraFun_out);
        addToDV("gate", gate);
        addToDV("geoDir", geoDir);
        addToDV("plot_caption", plot_caption);
        addToDV("plot_highX", plot_highX);
        addToDV("plot_highY", plot_highY);
        addToDV("plot_highZ", plot_highZ);
        addToDV("plot_lowX", plot_lowX);
        addToDV("plot_lowY", plot_lowY);
        addToDV("plot_lowZ", plot_lowZ);
        addToDV("plot_outfile_param", plot_outfile_param);
        addToDV("plot_outfile_image", plot_outfile_image);
        addToDV("plot_plot_type", plot_plot_type);
        addToDV("plot_title", plot_title);
        addToDV("plot_xlabel", plot_xlabel);
        addToDV("plot_ylabel", plot_ylabel);
        addToDV("plot_zlabel", plot_zlabel);
        addToDV("sort_sortKey1", sort_sortKey1);
        addToDV("sort_sortKey2", sort_sortKey2);
        addToDV("sortOut", sortOut);
        addToDV("zeroZeroZeroID", zeroZeroZeroID);
        addToDV("rawData", rawData);
        addToDV("thresholdAll", thresholdAll);
        addToDV("wireDelayData", wireDelayData);

        //return Derivation
        return dv;
    }


    //sets the variables in this bean to values in the Derivation
    public void mapToBean(Derivation dv) throws ElabException{
        //copy dv variable (used in getDVValue)
        this.dv = dv;

        channelCoincidence = getDVValue("channelCoincidence") == null ? "" : getDVValue("channelCoincidence");
        combineOut = getDVValue("combineOut") == null ? "" : getDVValue("combineOut");
        detectorCoincidence = getDVValue("detectorCoincidence") == null ? "" : getDVValue("detectorCoincidence");
        detector = getDVValue("detector") == null ? "" : getDVValue("detector");
        eventCandidates = getDVValue("eventCandidates") == null ? "" : getDVValue("eventCandidates");
        eventCoincidence = getDVValue("eventCoincidence") == null ? "" : getDVValue("eventCoincidence");
        eventFile = getDVValue("eventFile") == null ? "" : getDVValue("eventFile");
        eventNum = getDVValue("eventNum") == null ? "" : getDVValue("eventNum");
        extraFun_out = getDVValue("extraFun_out") == null ? "" : getDVValue("extraFun_out");
        gate = getDVValue("gate") == null ? "" : getDVValue("gate");
        geoDir = getDVValue("geoDir") == null ? "" : getDVValue("geoDir");
        plot_caption = getDVValue("plot_caption") == null ? "" : getDVValue("plot_caption");
        plot_highX = getDVValue("plot_highX") == null ? "" : getDVValue("plot_highX");
        plot_highY = getDVValue("plot_highY") == null ? "" : getDVValue("plot_highY");
        plot_highZ = getDVValue("plot_highZ") == null ? "" : getDVValue("plot_highZ");
        plot_lowX = getDVValue("plot_lowX") == null ? "" : getDVValue("plot_lowX");
        plot_lowY = getDVValue("plot_lowY") == null ? "" : getDVValue("plot_lowY");
        plot_lowZ = getDVValue("plot_lowZ") == null ? "" : getDVValue("plot_lowZ");
        plot_outfile_param = getDVValue("plot_outfile_param") == null ? "" : getDVValue("plot_outfile_param");
        plot_outfile_image = getDVValue("plot_outfile_image") == null ? "" : getDVValue("plot_outfile_image");
        plot_plot_type = getDVValue("plot_plot_type") == null ? "" : getDVValue("plot_plot_type");
        plot_title = getDVValue("plot_title") == null ? "" : getDVValue("plot_title");
        plot_xlabel = getDVValue("plot_xlabel") == null ? "" : getDVValue("plot_xlabel");
        plot_ylabel = getDVValue("plot_ylabel") == null ? "" : getDVValue("plot_ylabel");
        plot_zlabel = getDVValue("plot_zlabel") == null ? "" : getDVValue("plot_zlabel");
        sort_sortKey1 = getDVValue("sort_sortKey1") == null ? "" : getDVValue("sort_sortKey1");
        sort_sortKey2 = getDVValue("sort_sortKey2") == null ? "" : getDVValue("sort_sortKey2");
        sortOut = getDVValue("sortOut") == null ? "" : getDVValue("sortOut");
        zeroZeroZeroID = getDVValue("zeroZeroZeroID") == null ? "" : getDVValue("zeroZeroZeroID");
        rawData = getDVValues("rawData");
        thresholdAll = getDVValues("thresholdAll");
        wireDelayData = getDVValues("wireDelayData");
    }

    //reset all variables to defaults
    public void reset(){
        channelCoincidence = "";
        combineOut = "combineOut";
        detectorCoincidence = "";
        detector = "";
        eventCandidates = "eventCandidates";
        eventCoincidence = "";
        eventFile = "eventFile";
        eventNum = "";
        extraFun_out = "";
        gate = "";
        geoDir = "";
        plot_caption = "";
        plot_highX = "";
        plot_highY = "";
        plot_highZ = "";
        plot_lowX = "";
        plot_lowY = "";
        plot_lowZ = "";
        plot_outfile_param = "";
        plot_outfile_image = "";
        plot_plot_type = "";
        plot_title = "";
        plot_xlabel = "";
        plot_ylabel = "";
        plot_zlabel = "";
        sort_sortKey1 = "";
        sort_sortKey2 = "";
        sortOut = "sortOut";
        zeroZeroZeroID = "";
        rawData = null;
        thresholdAll = null;
        wireDelayData = null;
    }

}
