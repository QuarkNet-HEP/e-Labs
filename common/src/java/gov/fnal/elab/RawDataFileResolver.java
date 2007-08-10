/*
 * Created on Aug 7, 2007
 */
package gov.fnal.elab;


import java.io.File;

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

    public abstract String resolve(Elab elab, String lfn);
    
    public abstract String resolve(String dataDir, String lfn);
    
    public abstract String[] resolveAll(Elab elab, String[] lfns);

    public static class Default extends RawDataFileResolver {
        public String resolve(Elab elab, String lfn) {
            return resolve(elab.getProperties().getDataDir(), lfn);
        }
        
        public String resolve(String dataDir, String lfn) {
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
