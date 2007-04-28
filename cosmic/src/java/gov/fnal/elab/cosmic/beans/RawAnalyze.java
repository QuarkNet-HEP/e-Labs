package gov.fnal.elab.cosmic.beans;

//made with: /home/nepywoda/SHARK/quarknet/tools/bean_skeleton.pl --scalar "inFile outFile gatewidth" --list "" RawAnalyze



import java.io.*;                   //String
import java.util.*;                 //List
import gov.fnal.elab.util.*;        //ElabException
import gov.fnal.elab.beans.*;       //MappableBean, ElabBean
import org.griphyn.vdl.classes.*;   //Derivation, Declare, LFN, List

public class RawAnalyze extends ElabBean implements Serializable, MappableBean{

    //TR variables
    private String inFile = "";
    private String outFile = "";
    private String gatewidth = "";


    //get/set methods (scalar)
    public void setInFile(String s){
        inFile = s;
    }

    public String getInFile(){
        return inFile;
    }

    public void setOutFile(String s){
        outFile = s;
    }

    public String getOutFile(){
        return outFile;
    }

    public void setGatewidth(String s){
        gatewidth = s;
    }

    public String getGatewidth(){
        return gatewidth;
    }

    //get/set methods (list)


    //testing if the input is valid (scalar)
    public boolean isInFileValid(){
        boolean isValid = false;
        if(inFile.matches(".+")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isOutFileValid(){
        boolean isValid = false;
        if(outFile.matches(".+")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isGatewidthValid(){
        boolean isValid = false;
        if(gatewidth.matches("[0-9]+")){
            isValid = true;
        }
        return isValid;
    }


    //testing if the input is valid (list)

    //returns true is every key value is valid
    public boolean isValid(){
        java.util.List badkeys = this.getInvalidKeys();
        return badkeys.size() > 0 ? false : true;
    }

    //get a List of invalid keys
    public java.util.List getInvalidKeys(){
        java.util.List badkeys = new java.util.ArrayList();
        if(!isInFileValid()){
            badkeys.add("inFile");
        }
        if(!isOutFileValid()){
            badkeys.add("outFile");
        }
        if(!isGatewidthValid()){
            badkeys.add("gatewidth");
        }
        return badkeys;
    }


    //maps the values in this Derivation onto this class
    public void mapToBean(Derivation dv) throws ElabException{
        //not implemented
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
        java.util.List badkeys = getInvalidKeys();
        if(badkeys.size() > 0){
            String s = "The following keys are invalid within the bean: ";
            for(Iterator i=badkeys.iterator(); i.hasNext(); ){
                s += (String)i.next() + " ";
            }
            throw new ElabException(s);
        }

        //copy tr variable (used in addToDV)
        this.tr = tr;

        //create a new empty DV
        dv = new Derivation(ns, name, version, us, uses, min, max);

        //name these exactly as they're named in the TR in the VDC
        addToDV("inFile", inFile);
        addToDV("outFile", outFile);
        addToDV("gatewidth", gatewidth);

        //return Derivation
        return dv;
    }

    //reset all variables to the empty string
    public void reset(){
        inFile = "";
        outFile = "";
        gatewidth = "";
    }

}
