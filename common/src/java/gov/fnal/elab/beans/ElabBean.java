package gov.fnal.elab.beans;

import java.util.*;
import org.griphyn.vdl.classes.*;       //Transformation, Derivation, Declare, List
import gov.fnal.elab.util.ElabException;

/**
 * Utility methods for creating MappableBean classes
 */
public class ElabBean{
    protected Transformation tr;
    protected Derivation dv;


    /**
     * Add a {@link Scalar} value to an existing {@link Derivation}.
     *
     * @param key the key
     * @param value the value
     */     
    protected void addToDV(String key, String value) throws ElabException{
        Declare dec;
        int link;

        dec = tr.getDeclare(key);
        if(dec == null){
            throw new ElabException("The key: " + key + " is not defined in the" +
                    " transformation: " + tr.getNamespace() + "::" + tr.getName() 
                    + " (no Declare found in the tr).");
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
     * @param key the key
     * @param value the list of values
     */     
    protected void addToDV(String key, java.util.List value) throws ElabException{
        Declare dec;
        int link;

        dec = tr.getDeclare(key);
        if(dec == null){
            throw new ElabException("The key: " + key + " is not defined in the" +
                    " transformation: " + tr.getNamespace() + "::" + tr.getName() 
                    + " (no Declare found in the tr).");
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
                if(value==null) throw new ElabException("value is null for key "+key);
                for (Iterator j=value.iterator(); j.hasNext();) {
                    String lfn = (String)j.next();
                    if(lfn==null) throw new ElabException("lfn is null for key "+key);
                    list.addScalar(new Scalar(new LFN(lfn, link)));
                }
                dv.addPass(new Pass(key, list));
                break;
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
            throw new ElabException("If you are expecting a List of values for this key, please use getDVValues()");
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
            throw new ElabException("If you are expecting a Scalar value for this key, please use getDVValue()");
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
