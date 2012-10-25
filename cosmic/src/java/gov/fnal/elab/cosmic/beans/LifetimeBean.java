package gov.fnal.elab.cosmic.beans;

import java.io.*;                   //String
import java.util.*;                 //List
import gov.fnal.elab.util.*;        //ElabException
import gov.fnal.elab.beans.*;       //MappableBean, ElabBean
import gov.fnal.elab.beans.vds.*;

import org.griphyn.vdl.classes.*;   //Derivation, Declare, LFN, List

public class LifetimeBean extends VDSElabBean implements Serializable, VDSMappableBean{

    //TR variables
    private String combineOut;
    private String detector;
    private String extraFun_alpha_guess;
    private String extraFun_alpha_variate;
    private String extraFun_constant_guess;
    private String extraFun_constant_variate;
    private String extraFun_lifetime_guess;
    private String extraFun_lifetime_variate;
    private String extraFun_maxX;
    private String extraFun_minX;
    private String extraFun_turnedOn;
    private String extraFun_out;
    private String extraFun_rawFile;
    private String extraFun_type;
    private String freq_binType;
    private String freq_binValue;
    private String freq_col;
    private String frequencyOut;
    private String lifetimeOut;
    private String lifetime_coincidence;
    private String lifetime_energyCheck;
    private String lifetime_gatewidth;
    private String geoDir;
    private String plot_caption;
    private String plot_highX;
    private String plot_highY;
    private String plot_highZ;
    private String plot_lowX;
    private String plot_lowY;
    private String plot_lowZ;
    private String plot_size;
    private String plot_outfile_param;
    private String plot_outfile_image;
    private String plot_outfile_thumbnail;
    private String plot_plot_type;
    private String plot_title;
    private String plot_xlabel;
    private String plot_ylabel;
    private String plot_zlabel;
    private String sort_sortKey1;
    private String sort_sortKey2;
    private String sortOut;
    private java.util.List rawData;
    private java.util.List wireDelayData;
    private java.util.List thresholdAll;

    //Constructor
    public LifetimeBean(){
        this.reset();
    }


    //get/set methods (scalar)
    public void setCombineOut(String s){
        combineOut = s;
    }

    public String getCombineOut(){
        return combineOut;
    }

    public void setDetector(String s){
        detector = s;
    }

    public String getDetector(){
        return detector;
    }

    public void setExtraFun_alpha_guess(String s){
        extraFun_alpha_guess = s;
    }

    public String getExtraFun_alpha_guess(){
        return extraFun_alpha_guess;
    }

    public void setExtraFun_alpha_variate(String s){
        extraFun_alpha_variate = s;
    }

    public String getExtraFun_alpha_variate(){
        return extraFun_alpha_variate;
    }

    public void setExtraFun_constant_guess(String s){
        extraFun_constant_guess = s;
    }

    public String getExtraFun_constant_guess(){
        return extraFun_constant_guess;
    }

    public void setExtraFun_constant_variate(String s){
        extraFun_constant_variate = s;
    }

    public String getExtraFun_constant_variate(){
        return extraFun_constant_variate;
    }

    public void setExtraFun_lifetime_guess(String s){
        extraFun_lifetime_guess = s;
    }

    public String getExtraFun_lifetime_guess(){
        return extraFun_lifetime_guess;
    }

    public void setExtraFun_lifetime_variate(String s){
        extraFun_lifetime_variate = s;
    }

    public String getExtraFun_lifetime_variate(){
        return extraFun_lifetime_variate;
    }

    public void setExtraFun_maxX(String s){
        extraFun_maxX = s;
    }

    public String getExtraFun_maxX(){
        return extraFun_maxX;
    }

    public void setExtraFun_minX(String s){
        extraFun_minX = s;
    }

    public String getExtraFun_minX(){
        return extraFun_minX;
    }

    public void setExtraFun_turnedOn(String s){
        extraFun_turnedOn = s;
    }

    public String getExtraFun_turnedOn(){
        return extraFun_turnedOn;
    }

    public void setExtraFun_out(String s){
        extraFun_out = s;
    }

    public String getExtraFun_out(){
        return extraFun_out;
    }

    public void setExtraFun_rawFile(String s){
        extraFun_rawFile = s;
    }

    public String getExtraFun_rawFile(){
        return extraFun_rawFile;
    }

    public void setExtraFun_type(String s){
        extraFun_type = s;
    }

    public String getExtraFun_type(){
        return extraFun_type;
    }

    public void setFreq_binType(String s){
        freq_binType = s;
    }

    public String getFreq_binType(){
        return freq_binType;
    }

    public void setFreq_binValue(String s){
        freq_binValue = s;
    }

    public String getFreq_binValue(){
        return freq_binValue;
    }

    public void setFreq_col(String s){
        freq_col = s;
    }

    public String getFreq_col(){
        return freq_col;
    }

    public void setFrequencyOut(String s){
        frequencyOut = s;
    }

    public String getFrequencyOut(){
        return frequencyOut;
    }

    public void setLifetimeOut(String s){
        lifetimeOut = s;
    }

    public String getLifetimeOut(){
        return lifetimeOut;
    }

    public void setLifetime_coincidence(String s){
        lifetime_coincidence = s;
    }

    public String getLifetime_coincidence(){
        return lifetime_coincidence;
    }

    public void setLifetime_energyCheck(String s){
        lifetime_energyCheck = s;
    }

    public String getLifetime_energyCheck(){
        return lifetime_energyCheck;
    }

    public void setLifetime_gatewidth(String s){
        lifetime_gatewidth = s;
    }

    public String getLifetime_gatewidth(){
        return lifetime_gatewidth;
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

    public void setPlot_size(String s){
        plot_size = s;
    }

    public String getPlot_size(){
        return plot_size;
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

    public void setPlot_outfile_thumbnail(String s){
        plot_outfile_thumbnail = s;
    }

    public String getPlot_outfile_thumbnail(){
        return plot_outfile_thumbnail;
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

    //get/set methods (list)
    public void setRawData(java.util.List s){
        rawData = s;
    }

    public java.util.List getRawData(){
        return rawData;
    }

    public void setWireDelayData(java.util.List s){
        wireDelayData = s;
    }

    public java.util.List getWireDelayData(){
        return wireDelayData;
    }

    public void setThresholdAll(java.util.List s){
        thresholdAll = s;
    }

    public java.util.List getThresholdAll(){
        return thresholdAll;
    }



    //testing if the input is valid (scalar)
    public boolean isCombineOutValid(){
        return true;
    }

    public boolean isDetectorValid(){
        return true;
    }

    public boolean isExtraFun_alpha_guessValid(){
        return true;
    }

    public boolean isExtraFun_alpha_variateValid(){
        return true;
    }

    public boolean isExtraFun_constant_guessValid(){
        return true;
    }

    public boolean isExtraFun_constant_variateValid(){
        return true;
    }

    public boolean isExtraFun_lifetime_guessValid(){
        return true;
    }

    public boolean isExtraFun_lifetime_variateValid(){
        return true;
    }

    public boolean isExtraFun_maxXValid(){
        return true;
    }

    public boolean isExtraFun_minXValid(){
        return true;
    }

    public boolean isExtraFun_turnedOnValid(){
        return true;
    }

    public boolean isExtraFun_outValid(){
        return true;
    }

    public boolean isExtraFun_rawFileValid(){
        return true;
    }

    public boolean isExtraFun_typeValid(){
        return true;
    }

    public boolean isFreq_binTypeValid(){
        return true;
    }

    public boolean isFreq_binValueValid(){
        return true;
    }

    public boolean isFreq_colValid(){
        return true;
    }

    public boolean isFrequencyOutValid(){
        return true;
    }

    public boolean isLifetimeOutValid(){
        return true;
    }

    public boolean isLifetime_coincidenceValid(){
        return true;
    }

    public boolean isLifetime_energyCheckValid(){
        return true;
    }

    public boolean isLifetime_gatewidthValid(){
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

    public boolean isPlot_sizeValid(){
        return true;
    }

    public boolean isPlot_outfile_paramValid(){
        return true;
    }

    public boolean isPlot_outfile_imageValid(){
        return true;
    }

    public boolean isPlot_outfile_thumbnailValid(){
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


    //testing if the input is valid (list)
    public boolean isRawDataValid(){
        if(rawData == null)
            return false;
        return true;
    }

    public boolean isWireDelayDataValid(){
        if(wireDelayData == null)
            return false;
        return true;
    }

    public boolean isThresholdAllValid(){
        if(thresholdAll == null)
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
        if(!isCombineOutValid()){
            badkeys.add("combineOut");
        }
        if(!isDetectorValid()){
            badkeys.add("detector");
        }
        if(!isExtraFun_alpha_guessValid()){
            badkeys.add("extraFun_alpha_guess");
        }
        if(!isExtraFun_alpha_variateValid()){
            badkeys.add("extraFun_alpha_variate");
        }
        if(!isExtraFun_constant_guessValid()){
            badkeys.add("extraFun_constant_guess");
        }
        if(!isExtraFun_constant_variateValid()){
            badkeys.add("extraFun_constant_variate");
        }
        if(!isExtraFun_lifetime_guessValid()){
            badkeys.add("extraFun_lifetime_guess");
        }
        if(!isExtraFun_lifetime_variateValid()){
            badkeys.add("extraFun_lifetime_variate");
        }
        if(!isExtraFun_maxXValid()){
            badkeys.add("extraFun_maxX");
        }
        if(!isExtraFun_minXValid()){
            badkeys.add("extraFun_minX");
        }
        if(!isExtraFun_turnedOnValid()){
            badkeys.add("extraFun_turnedOn");
        }
        if(!isExtraFun_outValid()){
            badkeys.add("extraFun_out");
        }
        if(!isExtraFun_rawFileValid()){
            badkeys.add("extraFun_rawFile");
        }
        if(!isExtraFun_typeValid()){
            badkeys.add("extraFun_type");
        }
        if(!isFreq_binTypeValid()){
            badkeys.add("freq_binType");
        }
        if(!isFreq_binValueValid()){
            badkeys.add("freq_binValue");
        }
        if(!isFreq_colValid()){
            badkeys.add("freq_col");
        }
        if(!isFrequencyOutValid()){
            badkeys.add("frequencyOut");
        }
        if(!isLifetimeOutValid()){
            badkeys.add("lifetimeOut");
        }
        if(!isLifetime_coincidenceValid()){
            badkeys.add("lifetime_coincidence");
        }
        if(!isLifetime_energyCheckValid()){
            badkeys.add("lifetime_energyCheck");
        }
        if(!isLifetime_gatewidthValid()){
            badkeys.add("lifetime_gatewidth");
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
        if(!isPlot_sizeValid()){
            badkeys.add("plot_size");
        }
        if(!isPlot_outfile_paramValid()){
            badkeys.add("plot_outfile_param");
        }
        if(!isPlot_outfile_imageValid()){
            badkeys.add("plot_outfile_image");
        }
        if(!isPlot_outfile_thumbnailValid()){
            badkeys.add("plot_outfile_thumbnail");
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
        if(!isRawDataValid()){
            badkeys.add("rawData");
        }
        if(!isWireDelayDataValid()){
            badkeys.add("wireDelayData");
        }
        if(!isThresholdAllValid()){
            badkeys.add("thresholdAll");
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
        addToDV("combineOut", combineOut);
        addToDV("detector", detector);
        addToDV("extraFun_alpha_guess", extraFun_alpha_guess);
        addToDV("extraFun_alpha_variate", extraFun_alpha_variate);
        addToDV("extraFun_constant_guess", extraFun_constant_guess);
        addToDV("extraFun_constant_variate", extraFun_constant_variate);
        addToDV("extraFun_lifetime_guess", extraFun_lifetime_guess);
        addToDV("extraFun_lifetime_variate", extraFun_lifetime_variate);
        addToDV("extraFun_maxX", extraFun_maxX);
        addToDV("extraFun_minX", extraFun_minX);
        addToDV("extraFun_turnedOn", extraFun_turnedOn);
        addToDV("extraFun_out", extraFun_out);
        addToDV("extraFun_rawFile", extraFun_rawFile);
        addToDV("extraFun_type", extraFun_type);
        addToDV("freq_binType", freq_binType);
        addToDV("freq_binValue", freq_binValue);
        addToDV("freq_col", freq_col);
        addToDV("frequencyOut", frequencyOut);
        addToDV("lifetimeOut", lifetimeOut);
        addToDV("lifetime_coincidence", lifetime_coincidence);
        addToDV("lifetime_energyCheck", lifetime_energyCheck);
        addToDV("lifetime_gatewidth", lifetime_gatewidth);
        addToDV("geoDir", geoDir);
        addToDV("plot_caption", plot_caption);
        addToDV("plot_highX", plot_highX);
        addToDV("plot_highY", plot_highY);
        addToDV("plot_highZ", plot_highZ);
        addToDV("plot_lowX", plot_lowX);
        addToDV("plot_lowY", plot_lowY);
        addToDV("plot_lowZ", plot_lowZ);
        addToDV("plot_size", plot_size);
        addToDV("plot_outfile_param", plot_outfile_param);
        addToDV("plot_outfile_image", plot_outfile_image);
        addToDV("plot_outfile_thumbnail", plot_outfile_thumbnail);
        addToDV("plot_plot_type", plot_plot_type);
        addToDV("plot_title", plot_title);
        addToDV("plot_xlabel", plot_xlabel);
        addToDV("plot_ylabel", plot_ylabel);
        addToDV("plot_zlabel", plot_zlabel);
        addToDV("sort_sortKey1", sort_sortKey1);
        addToDV("sort_sortKey2", sort_sortKey2);
        addToDV("sortOut", sortOut);
        addToDV("rawData", rawData);
        addToDV("wireDelayData", wireDelayData);
        addToDV("thresholdAll", thresholdAll);

        //return Derivation
        return dv;
    }


    //sets the variables in this bean to values in the Derivation
    public void mapToBean(Derivation dv) throws ElabException{
        //copy dv variable (used in getDVValue)
        this.dv = dv;

        combineOut = getDVValue("combineOut") == null ? "" : getDVValue("combineOut");
        detector = getDVValue("detector") == null ? "" : getDVValue("detector");
        extraFun_alpha_guess = getDVValue("extraFun_alpha_guess") == null ? "" : getDVValue("extraFun_alpha_guess");
        extraFun_alpha_variate = getDVValue("extraFun_alpha_variate") == null ? "" : getDVValue("extraFun_alpha_variate");
        extraFun_constant_guess = getDVValue("extraFun_constant_guess") == null ? "" : getDVValue("extraFun_constant_guess");
        extraFun_constant_variate = getDVValue("extraFun_constant_variate") == null ? "" : getDVValue("extraFun_constant_variate");
        extraFun_lifetime_guess = getDVValue("extraFun_lifetime_guess") == null ? "" : getDVValue("extraFun_lifetime_guess");
        extraFun_lifetime_variate = getDVValue("extraFun_lifetime_variate") == null ? "" : getDVValue("extraFun_lifetime_variate");
        extraFun_maxX = getDVValue("extraFun_maxX") == null ? "" : getDVValue("extraFun_maxX");
        extraFun_minX = getDVValue("extraFun_minX") == null ? "" : getDVValue("extraFun_minX");
        extraFun_turnedOn = getDVValue("extraFun_turnedOn") == null ? "" : getDVValue("extraFun_turnedOn");
        extraFun_out = getDVValue("extraFun_out") == null ? "" : getDVValue("extraFun_out");
        extraFun_rawFile = getDVValue("extraFun_rawFile") == null ? "" : getDVValue("extraFun_rawFile");
        extraFun_type = getDVValue("extraFun_type") == null ? "" : getDVValue("extraFun_type");
        freq_binType = getDVValue("freq_binType") == null ? "" : getDVValue("freq_binType");
        freq_binValue = getDVValue("freq_binValue") == null ? "" : getDVValue("freq_binValue");
        freq_col = getDVValue("freq_col") == null ? "" : getDVValue("freq_col");
        frequencyOut = getDVValue("frequencyOut") == null ? "" : getDVValue("frequencyOut");
        lifetimeOut = getDVValue("lifetimeOut") == null ? "" : getDVValue("lifetimeOut");
        lifetime_coincidence = getDVValue("lifetime_coincidence") == null ? "" : getDVValue("lifetime_coincidence");
        lifetime_energyCheck = getDVValue("lifetime_energyCheck") == null ? "" : getDVValue("lifetime_energyCheck");
        lifetime_gatewidth = getDVValue("lifetime_gatewidth") == null ? "" : getDVValue("lifetime_gatewidth");
        geoDir = getDVValue("geoDir") == null ? "" : getDVValue("geoDir");
        plot_caption = getDVValue("plot_caption") == null ? "" : getDVValue("plot_caption");
        plot_highX = getDVValue("plot_highX") == null ? "" : getDVValue("plot_highX");
        plot_highY = getDVValue("plot_highY") == null ? "" : getDVValue("plot_highY");
        plot_highZ = getDVValue("plot_highZ") == null ? "" : getDVValue("plot_highZ");
        plot_lowX = getDVValue("plot_lowX") == null ? "" : getDVValue("plot_lowX");
        plot_lowY = getDVValue("plot_lowY") == null ? "" : getDVValue("plot_lowY");
        plot_lowZ = getDVValue("plot_lowZ") == null ? "" : getDVValue("plot_lowZ");
        plot_size = getDVValue("plot_size") == null ? "" : getDVValue("plot_size");
        plot_outfile_param = getDVValue("plot_outfile_param") == null ? "" : getDVValue("plot_outfile_param");
        plot_outfile_image = getDVValue("plot_outfile_image") == null ? "" : getDVValue("plot_outfile_image");
        plot_outfile_thumbnail = getDVValue("plot_outfile_thumbnail") == null ? "" : getDVValue("plot_outfile_thumbnail");
        plot_plot_type = getDVValue("plot_plot_type") == null ? "" : getDVValue("plot_plot_type");
        plot_title = getDVValue("plot_title") == null ? "" : getDVValue("plot_title");
        plot_xlabel = getDVValue("plot_xlabel") == null ? "" : getDVValue("plot_xlabel");
        plot_ylabel = getDVValue("plot_ylabel") == null ? "" : getDVValue("plot_ylabel");
        plot_zlabel = getDVValue("plot_zlabel") == null ? "" : getDVValue("plot_zlabel");
        sort_sortKey1 = getDVValue("sort_sortKey1") == null ? "" : getDVValue("sort_sortKey1");
        sort_sortKey2 = getDVValue("sort_sortKey2") == null ? "" : getDVValue("sort_sortKey2");
        sortOut = getDVValue("sortOut") == null ? "" : getDVValue("sortOut");
        rawData = getDVValues("rawData");
        wireDelayData = getDVValues("wireDelayData");
        thresholdAll = getDVValues("thresholdAll");
    }

    //reset all variables to defaults
    public void reset(){
        combineOut = "combineOut";
        detector = "";
        extraFun_alpha_guess = "";
        extraFun_alpha_variate = "";
        extraFun_constant_guess = "";
        extraFun_constant_variate = "";
        extraFun_lifetime_guess = "";
        extraFun_lifetime_variate = "";
        extraFun_maxX = "";
        extraFun_minX = "";
        extraFun_turnedOn = "";
        extraFun_out = "extraFun_out";
        extraFun_rawFile = "";
        extraFun_type = "";
        freq_binType = "";
        freq_binValue = "";
        freq_col = "";
        frequencyOut = "frequencyOut";
        lifetimeOut = "lifetimeOut";
        lifetime_coincidence = "";
        lifetime_energyCheck = "";
        lifetime_gatewidth = "";
        geoDir = "";
        plot_caption = "";
        plot_highX = "";
        plot_highY = "";
        plot_highZ = "";
        plot_lowX = "";
        plot_lowY = "";
        plot_lowZ = "";
        plot_size = "";
        plot_outfile_param = "";
        plot_outfile_image = "";
        plot_outfile_thumbnail = "";
        plot_plot_type = "";
        plot_title = "";
        plot_xlabel = "";
        plot_ylabel = "";
        plot_zlabel = "";
        sort_sortKey1 = "";
        sort_sortKey2 = "";
        sortOut = "sortOut";
        rawData = null;
        wireDelayData = null;
        thresholdAll = null;
    }

}
