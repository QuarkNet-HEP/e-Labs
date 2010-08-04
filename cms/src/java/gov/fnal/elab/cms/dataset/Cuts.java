/*
 * Created on Jul 9, 2010
 */
package gov.fnal.elab.cms.dataset;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Cuts are done on events. Essentially, when a cut says "Ee > 10 GeV" that
 * means "select all events in which at least one electron has energy > 10 GeV"
 * 
 * @author Mihael Hategan
 * 
 */
public class Cuts {
    private Map<String, double[]> params;
    private Map<String, Set<String>> runs;

    /**
     * Construct a set of cuts from a string specification in the form
     * leaf:low:high[ leaf:low:high [...]]
     * 
     */
    public Cuts(String spec) {
        if (spec == null) {
            return;
        }
        params = new HashMap<String, double[]>();
        runs = new HashMap<String, Set<String>>();
        String[] a = spec.split("\\s+");
        for (String s : a) {
            String[] b = s.split(":");
            params.put(b[0], new double[] { Double.parseDouble(b[1]),
                    Double.parseDouble(b[2]) });
        }
    }

    public Collection<String> getLeaves() {
        if (params == null) {
            return Collections.emptyList();
        }
        else {
            return params.keySet();
        }
    }

    public Collection<Cut> getCuts(Dataset ds) {
        if (params == null) {
            return Collections.emptyList();
        }
        else {
            List<Cut> l = new ArrayList<Cut>();
            for (Map.Entry<String, double[]> e : params.entrySet()) {
                Leaf leaf = ds.getLeaf(e.getKey());
                l.add(new Cut(e.getKey(), leaf.getUnits(), leaf.getTitle(), e.getValue()[0], e
                        .getValue()[1]));
            }
            return l;
        }
    }

    public Run getRun(String run) {
        return new Run(run);
    }

    public void add(String path, String run, String event, String[] values) {
        Set<String> disabledEvents = runs.get(run);
        if (disabledEvents == null) {
            disabledEvents = new HashSet<String>();
            runs.put(run, disabledEvents);
        }
        double[] cut = params.get(path);
        for (int i = 0; i < values.length; i++) {
            double v = Double.parseDouble(values[i]);
            if (v < cut[0] || v > cut[1]) {
                disabledEvents.add(event);
            }
        }
    }

    public class Run {
        private Set<String> set;

        private Run(String run) {
            if (params != null) {
                set = runs.get(run);
            }
        }

        public String filter(String event, String values) {
            if (set == null || !set.contains(event)) {
                return values;
            }
            else {
                return null;
            }
        }
    }
}
