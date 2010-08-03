/*
 * Created on Jul 29, 2010
 */
package gov.fnal.elab.cms.dataset;

import gov.fnal.elab.ElabGroup;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import uk.ltd.getahead.dwr.util.Logger;

public class RecentCuts {
    public static final Logger logger = Logger.getLogger(RecentCuts.class);
    
    public static final int MAX_CUTS = 20;

    private static Map<String, RecentCuts> instances = new HashMap<String, RecentCuts>();

    public synchronized static RecentCuts getInstance(ElabGroup user, Dataset dataset) {
        RecentCuts rc = instances.get(user.getName());
        if (rc == null) {
            rc = new RecentCuts(user, dataset);
            instances.put(user.getName(), rc);
        }
        return rc;
    }

    private ElabGroup user;
    private LinkedList<Cut> cuts;
    private Dataset dataset;

    public RecentCuts(ElabGroup user, Dataset dataset) {
        this.user = user;
        this.dataset = dataset;
    }

    public synchronized List<Cut> getCuts() throws IOException {
        if (cuts == null) {
            cuts = load();
        }
        return cuts;
    }

    private LinkedList<Cut> load() throws IOException {
        LinkedList<Cut> l = new LinkedList<Cut>();
        String dir = user.getUserDir();
        File fdir = new File(dir);
        if (!fdir.exists()) {
            fdir.mkdirs();
        }
        File listFile = new File(dir, "cuts");
        if (listFile.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(listFile));
            try {
                String line = br.readLine();
                while (line != null) {
                    if (!line.equals("")) {
                        try {
                            String[] e = line.split("\\s+", 5);
                            l.add(new Cut(e[2], e[3], e[4], Double.parseDouble(e[0]), Double
                                    .parseDouble(e[1])));
                        }
                        catch (Exception e) {
                            logger.warn("Invalid line in " + listFile + ": " + line);
                        }
                    }
                    line = br.readLine();
                }
            }
            finally {
                br.close();
            }
        }
        return l;
    }

    private void save() throws IOException {
        File listFile = new File(user.getUserDir(), "cuts");
        BufferedWriter br = new BufferedWriter(new FileWriter(listFile));
        try {
            for (Cut cut : cuts) {
                br.write(cut.getMin() + " " + cut.getMax() + " " + cut.getLeaf() + " " + cut.getUnits() + " "
                        + cut.getLabel() + "\n");
            }
        }
        finally {
            br.close();
        }
    }

    public synchronized void add(Cut cut) throws IOException {
        if (!cuts.contains(cut)) {
            cuts.add(cut);
        }
    }
    
    public void commit() throws IOException {
        while (cuts.size() > MAX_CUTS) {
            cuts.removeFirst();
        }
        save();
    }
}
