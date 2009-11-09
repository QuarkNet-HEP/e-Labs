package gov.fnal.elab.cosmic.beans;

import java.io.*;                   //String
import java.util.*;                 //List
import gov.fnal.elab.util.*;        //ElabException
import gov.fnal.elab.beans.*;       //MappableBean, ElabBean
import org.griphyn.vdl.classes.*;   //Derivation, Declare, LFN, List

public class FluxBean extends ElabBean implements Serializable, MappableBean{

    //TR variables
    private String combineOut;
    private String detector;
    private String fluxOut;
    private String flux_binWidth;
    private String flux_geoDir;
    private String plot_caption;
    private String extraFun_out;
    private String plot_highX;
    private String plot_highY;
    private String plot_highZ;
    private String plot_lowX;
    private String plot_lowY;
    private String plot_lowZ;
    private String plot_outfile_param;
    private String plot_plot_type;
    private String plot_outfile_image;
    private String plot_title;
    private String plot_xlabel;
    private String plot_ylabel;
    private String plot_zlabel;
    private String singlechannelOut;
    private String singlechannel_channel;
    private String sortOut;
    private String sort_sortKey1;
    private String sort_sortKey2;
    private java.util.List rawData;
    private java.util.List wireDelayData;
    private java.util.List thresholdAll;

    //Constructor
    public FluxBean(){
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

    public void setFluxOut(String s){
        fluxOut = s;
    }

    public String getFluxOut(){
        return fluxOut;
    }

    public void setFlux_binWidth(String s){
        flux_binWidth = s;
    }

    public String getFlux_binWidth(){
        return flux_binWidth;
    }

    public void setFlux_geoDir(String s){
        flux_geoDir = s;
    }

    public String getFlux_geoDir(){
        return flux_geoDir;
    }

    public void setPlot_caption(String s){
        plot_caption = s;
    }

    public String getPlot_caption(){
        return plot_caption;
    }

    public void setExtraFun_out(String s){
        extraFun_out = s;
    }

    public String getExtraFun_out(){
        return extraFun_out;
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

    public void setPlot_plot_type(String s){
        plot_plot_type = s;
    }

    public String getPlot_plot_type(){
        return plot_plot_type;
    }

    public void setPlot_outfile_image(String s){
        plot_outfile_image = s;
    }

    public String getPlot_outfile_image(){
        return plot_outfile_image;
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

    public void setSinglechannelOut(String s){
        singlechannelOut = s;
    }

    public String getSinglechannelOut(){
        return singlechannelOut;
    }

    public void setSinglechannel_channel(String s){
        singlechannel_channel = s;
    }

    public String getSinglechannel_channel(){
        return singlechannel_channel;
    }

    public void setSortOut(String s){
        sortOut = s;
    }

    public String getSortOut(){
        return sortOut;
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

    public boolean isFluxOutValid(){
        return true;
    }

    public boolean isFlux_binWidthValid(){
        return true;
    }

    public boolean isFlux_geoDirValid(){
        return true;
    }

    public boolean isPlot_captionValid(){
        return true;
    }

    public boolean isExtraFun_outValid(){
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

    public boolean isPlot_plot_typeValid(){
        return true;
    }

    public boolean isPlot_outfile_imageValid(){
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

    public boolean isSinglechannelOutValid(){
        return true;
    }

    public boolean isSinglechannel_channelValid(){
        return true;
    }

    public boolean isSortOutValid(){
        return true;
    }

    public boolean isSort_sortKey1Valid(){
        return true;
    }

    public boolean isSort_sortKey2Valid(){
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
        if(!isFluxOutValid()){
            badkeys.add("fluxOut");
        }
        if(!isFlux_binWidthValid()){
            badkeys.add("flux_binWidth");
        }
        if(!isFlux_geoDirValid()){
            badkeys.add("flux_geoDir");
        }
        if(!isPlot_captionValid()){
            badkeys.add("plot_caption");
        }
        if(!isExtraFun_outValid()){
            badkeys.add("extraFun_out");
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
        if(!isPlot_plot_typeValid()){
            badkeys.add("plot_plot_type");
        }
        if(!isPlot_outfile_imageValid()){
            badkeys.add("plot_outfile_image");
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
        if(!isSinglechannelOutValid()){
            badkeys.add("singlechannelOut");
        }
        if(!isSinglechannel_channelValid()){
            badkeys.add("singlechannel_channel");
        }
        if(!isSortOutValid()){
            badkeys.add("sortOut");
        }
        if(!isSort_sortKey1Valid()){
            badkeys.add("sort_sortKey1");
        }
        if(!isSort_sortKey2Valid()){
            badkeys.add("sort_sortKey2");
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
            StringBuffer sb = new StringBuffer("The following keys are invalid within the bean: ");
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
        addToDV("fluxOut", fluxOut);
        addToDV("flux_binWidth", flux_binWidth);
        addToDV("flux_geoDir", flux_geoDir);
        addToDV("plot_caption", plot_caption);
        addToDV("extraFun_out", extraFun_out);
        addToDV("plot_highX", plot_highX);
        addToDV("plot_highY", plot_highY);
        addToDV("plot_highZ", plot_highZ);
        addToDV("plot_lowX", plot_lowX);
        addToDV("plot_lowY", plot_lowY);
        addToDV("plot_lowZ", plot_lowZ);
        addToDV("plot_outfile_param", plot_outfile_param);
        addToDV("plot_plot_type", plot_plot_type);
        addToDV("plot_outfile_image", plot_outfile_image);
        addToDV("plot_title", plot_title);
        addToDV("plot_xlabel", plot_xlabel);
        addToDV("plot_ylabel", plot_ylabel);
        addToDV("plot_zlabel", plot_zlabel);
        addToDV("singlechannelOut", singlechannelOut);
        addToDV("singlechannel_channel", singlechannel_channel);
        addToDV("sortOut", sortOut);
        addToDV("sort_sortKey1", sort_sortKey1);
        addToDV("sort_sortKey2", sort_sortKey2);
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
        fluxOut = getDVValue("fluxOut") == null ? "" : getDVValue("fluxOut");
        flux_binWidth = getDVValue("flux_binWidth") == null ? "" : getDVValue("flux_binWidth");
        flux_geoDir = getDVValue("flux_geoDir") == null ? "" : getDVValue("flux_geoDir");
        plot_caption = getDVValue("plot_caption") == null ? "" : getDVValue("plot_caption");
        extraFun_out = getDVValue("extraFun_out") == null ? "" : getDVValue("extraFun_out");
        plot_highX = getDVValue("plot_highX") == null ? "" : getDVValue("plot_highX");
        plot_highY = getDVValue("plot_highY") == null ? "" : getDVValue("plot_highY");
        plot_highZ = getDVValue("plot_highZ") == null ? "" : getDVValue("plot_highZ");
        plot_lowX = getDVValue("plot_lowX") == null ? "" : getDVValue("plot_lowX");
        plot_lowY = getDVValue("plot_lowY") == null ? "" : getDVValue("plot_lowY");
        plot_lowZ = getDVValue("plot_lowZ") == null ? "" : getDVValue("plot_lowZ");
        plot_outfile_param = getDVValue("plot_outfile_param") == null ? "" : getDVValue("plot_outfile_param");
        plot_plot_type = getDVValue("plot_plot_type") == null ? "" : getDVValue("plot_plot_type");
        plot_outfile_image = getDVValue("plot_outfile_image") == null ? "" : getDVValue("plot_outfile_image");
        plot_title = getDVValue("plot_title") == null ? "" : getDVValue("plot_title");
        plot_xlabel = getDVValue("plot_xlabel") == null ? "" : getDVValue("plot_xlabel");
        plot_ylabel = getDVValue("plot_ylabel") == null ? "" : getDVValue("plot_ylabel");
        plot_zlabel = getDVValue("plot_zlabel") == null ? "" : getDVValue("plot_zlabel");
        singlechannelOut = getDVValue("singlechannelOut") == null ? "" : getDVValue("singlechannelOut");
        singlechannel_channel = getDVValue("singlechannel_channel") == null ? "" : getDVValue("singlechannel_channel");
        sortOut = getDVValue("sortOut") == null ? "" : getDVValue("sortOut");
        sort_sortKey1 = getDVValue("sort_sortKey1") == null ? "" : getDVValue("sort_sortKey1");
        sort_sortKey2 = getDVValue("sort_sortKey2") == null ? "" : getDVValue("sort_sortKey2");
        rawData = getDVValues("rawData");
        wireDelayData = getDVValues("wireDelayData");
        thresholdAll = getDVValues("thresholdAll");
    }

    //reset all variables to defaults
    public void reset(){
        combineOut = "combineOut";
        detector = "";
        fluxOut = "fluxOut";
        flux_binWidth = "";
        flux_geoDir = "";
        plot_caption = "";
        extraFun_out = "extraFun_out";
        plot_highX = "";
        plot_highY = "";
        plot_highZ = "";
        plot_lowX = "";
        plot_lowY = "";
        plot_lowZ = "";
        plot_outfile_param = "";
        plot_plot_type = "";
        plot_outfile_image = "";
        plot_title = "";
        plot_xlabel = "";
        plot_ylabel = "";
        plot_zlabel = "";
        singlechannelOut = "singlechannelOut";
        singlechannel_channel = "";
        sortOut = "sortOut";
        sort_sortKey1 = "";
        sort_sortKey2 = "";
        rawData = null;
        wireDelayData = null;
        thresholdAll = null;
    }

}
