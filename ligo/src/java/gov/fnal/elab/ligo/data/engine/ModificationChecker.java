/*
 * Created on Feb 11, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.ligo.data.convert.ImportData;

import java.io.File;

public class ModificationChecker extends Thread {
    public static final int CHECK_INTERVAL = 60 * 60 * 1000;
    public static final int LOCK_CHECK_INTERVAL = 10 * 1000;

    private final Modifiable engine;
    private long checksum;
    
    public ModificationChecker(Modifiable engine) {
        this.engine = engine;
        setDaemon(true);
        setName("Data modification checker");
        start();
    }
    
    public void run() {
        try {
            this.checksum = computeChecksum();
            while (true) {
                Thread.sleep(CHECK_INTERVAL);
                long sum = computeChecksum();
                if (sum != checksum) {
                    waitForUpdate();
                    engine.reload();
                    checksum = sum;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void waitForUpdate() throws InterruptedException {
        File lock = new File(engine.getDataDirectory() + File.separator + ImportData.LOCKNAME);
        while (lock.exists()) {
            Thread.sleep(LOCK_CHECK_INTERVAL);
        }
    }

    private long computeChecksum() {
        File f = new File(engine.getDataDirectory());
        File[] infos = f.listFiles(new InfoFileFilter());
        long sum = 0;
        for (File info : infos) {
            sum += info.length();
        }
        return sum;
    }
}
