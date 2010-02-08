/*
 * Created on Jan 29, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.expression.data.engine.Range;

import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.SortedMap;
import java.util.TreeMap;

public class ChannelIndex {
    private File file;
    private SortedMap<Double, Double> rates;
    private SortedMap<Double, Long> cummulative; 

    public ChannelIndex(File file) throws IOException {
        this.file = file;
        load();
    }

    private void load() throws IOException {
        cummulative = new TreeMap<Double, Long>();
        rates = new TreeMap<Double, Double>();
        FileInputStream is = new FileInputStream(file);
        double lasttime = 0, lastrate = 0;
        long records = 0;
        try {
            while (true) {
                double time = EncodingTools.readDouble(is);
                double rate = EncodingTools.readDouble(is);
                records += Math.round((time - lasttime) / lastrate);
                cummulative.put(time, records);
                rates.put(time, rate);
                lasttime = time;
                lastrate = rate;
            }
        }
        catch (EOFException e) {
            is.close();
        }
    }
    
    public long getRecordIndex(double time) {
        SortedMap<Double, Long> hmc = cummulative.headMap(time);
        SortedMap<Double, Double> hm = rates.headMap(time);    
        
        long rangeOffset = hmc.get(hmc.lastKey());
        double currentRate = hm.get(hm.lastKey());
        double timeDiff = time - hm.lastKey();
        long offset = (long) (timeDiff / currentRate);
        
        return rangeOffset + offset - 1;
    }

    public Range getRange() {
        SortedMap<Double, Double> tm = rates.tailMap(1.0);
        return new Range(tm.firstKey(), tm.lastKey());
    }
}
