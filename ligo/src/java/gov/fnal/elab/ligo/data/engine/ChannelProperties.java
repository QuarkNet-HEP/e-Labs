/*
 * Created on Jan 29, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class ChannelProperties {
    private String dataType;
    private int nbits;
    private double bias, slope;
    private String units;
    
    public ChannelProperties(File propfile) throws IOException {
        load(propfile);
    }

    private void load(File propfile) throws IOException {
        Properties props = new Properties();
        props.load(new FileInputStream(propfile));
        dataType = getProp(props, "datatype");
        nbits = Integer.parseInt(getProp(props, "nbits"));
        bias = Double.parseDouble(getProp(props, "bias"));
        slope = Double.parseDouble(getProp(props, "slope"));
        units = getProp(props, "units");
    }

    private String getProp(Properties props, String name) throws IOException {
        String value = props.getProperty(name);
        if (value == null) {
            throw new IOException("Missing property " + name);
        }
        else {
            return value;
        }
    }
    
    public String getDataType() {
        return dataType;
    }

    public int getNbits() {
        return nbits;
    }

    public double getBias() {
        return bias;
    }

    public double getSlope() {
        return slope;
    }

    public String getUnits() {
        return units;
    }
}
