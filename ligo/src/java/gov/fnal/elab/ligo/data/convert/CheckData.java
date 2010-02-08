/*
 * Created on Feb 5, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.ChannelProperties;
import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.io.EOFException;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class CheckData implements Runnable {
    private String dataDir;
    private int errorCount;

    public CheckData(String dataDir) {
        this.dataDir = dataDir;
    }

    public void run() {
        try {
            checkFiles();
        }
        catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private void checkFiles() throws IOException {
        File[] bins = new File(dataDir).listFiles(new FileFilter() {
            public boolean accept(File pathname) {
                return pathname.getName().endsWith(".bin") && !pathname.getName().endsWith(".index.bin");
            }
        });

        for (File bin : bins) {
            checkFile(bin);
        }
        System.out.println("There were " + errorCount + " errors");
    }

    private void checkFile(File bin) throws IOException {
        System.out.print("Checking " + bin.getName() + "...");
        String path = bin.getAbsolutePath();
        ChannelProperties cp = new ChannelProperties(new File(path.substring(0, path.length() - ".bin".length())
                + ".info"));
        InputStream is = new FileInputStream(bin);
        try {
            if (cp.getDataType().equals("float") || cp.getDataType().equals("double")) {
                checkDouble(is);
            }
            else {
                checkLong(is);
            }
        }
        catch (EOFException e) {
            System.out.println("OK");
            is.close();
        }
    }

    private void checkLong(InputStream is) throws IOException {
        long last = 0;
        while(true) {
            double time = EncodingTools.readDouble(is);
            EncodingTools.readLong(is);
            long ssq = EncodingTools.readLong(is);
            if (ssq < last) {
                System.out.print("\n\tSSQ not monotonic at time " + time);
                errorCount++;
            }
            ssq = last;
        }
    }

    private void checkDouble(InputStream is) throws IOException {
        double last = 0;
        while(true) {
            double time = EncodingTools.readDouble(is);
            EncodingTools.readDouble(is);
            double ssq = EncodingTools.readDouble(is);
            if (ssq < last) {
                System.out.print("\n\tSSQ not monotonic at time " + time);
                errorCount++;
            }
            ssq = last;
        }
    }

    public static void main(String[] args) {
        new CheckData(args[0]).run();
    }
}
