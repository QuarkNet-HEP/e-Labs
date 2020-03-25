/*
 * Created on Aug 7, 2007
 */
package gov.fnal.elab;


import java.io.File;

/* This class takes a filename and an e-Lab and returns the absolute path 
 * to the given file with respect to the e-Lab's data directory - JG 25Mar2020
 */
public abstract class RawDataFileResolver {
    private static RawDataFileResolver def;

    public static synchronized RawDataFileResolver getDefault() {
        if (def == null) {
            def = new Default();
        }
        return def;
    }

    public static synchronized void setDefault(RawDataFileResolver resolver) {
        def = resolver;
    }

		/* 'lfn' represents the "logical filename"
		 * We expect it to be of the form 
		 *   6119.2019.0730.0
		 * We want to return the full path to this file.
		 * 'dataDir' is the absolute path of the e-Lab's data directory;
		 * it will form the basis of the returned filepath.
		 */
		/* These three methods account for different input signatures */
    public abstract String resolve(Elab elab, String lfn);

    public abstract String resolve(String dataDir, String lfn);

    public abstract String[] resolveAll(Elab elab, String[] lfns);

    public static class Default extends RawDataFileResolver {
        public String resolve(Elab elab, String lfn) {
            return resolve(elab.getProperties().getDataDir(), lfn);
        }

				/* This method does all the work */
        public String resolve(String dataDir, String lfn) {
						/* Find the first 'period'.  If it doesn't exist, return the
						 * filepath as `dataDir/lfn`
						 * If it does exist, extract the DAQ as the first segment and 
						 * return the filepath as `dataDir/DAQ/lfn
						 */
            int i = lfn.indexOf('.');
            if (i == -1) {
                return dataDir + File.separator + lfn;
            }
            else {
                String detectorid = lfn.substring(0, i);
                return dataDir + File.separator
                    + detectorid + File.separator + lfn;
            }
        }

				/* This method is the same as resolve() but with Array in -> Array out */
        public String[] resolveAll(Elab elab, String[] lfns) {
            String[] r = new String[lfns.length];
            String dataDir = elab.getProperties().getDataDir();
            for (int i = 0; i < lfns.length; i++) {
                r[i] = resolve(dataDir, lfns[i]);
            }
            return r;
        }
    }
}
