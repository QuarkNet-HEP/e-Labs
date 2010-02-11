/*
 * Created on Feb 9, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.ligo.data.convert.ChannelName;

import java.io.File;
import java.io.RandomAccessFile;
import java.text.DecimalFormat;
import java.text.NumberFormat;

public class DumpSums {

    public static final NumberFormat NF = new DecimalFormat("0000000.0000");
    public static void main(String[] args) {
        try {
            double start = 859644060;
            double end = 859655418;
            String dir = "/mnt/ubuntu/tmp/funny";
            String channel = "H0:PEM-MX_TILTT";
            
            ChannelProperties props = new ChannelProperties(new File(dir + "/" + channel + ".info"));
            LIGOFileReader rf = LIGOFileReader.instance(new ChannelName(channel), props, "mean", 
                new RandomAccessFile(new File(dir + "/" + channel + ".bin"), "r"));
            ChannelIndex ci = new ChannelIndex(new File(dir + "/" + channel + ".index.bin"));
            long rec = ci.getRecordIndex(start);
            long endrec = ci.getRecordIndex(end);
            Record last = rf.readRecord(rec++);
            while (rec <= endrec) {
                Record r = rf.readRecord(rec++);
                System.out.println(rec + ", " + NF.format((r.sum.doubleValue() - last.sum.doubleValue())) + ", " + r);
                last = r;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
