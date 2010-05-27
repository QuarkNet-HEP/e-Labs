/*
 * Created on May 24, 2010
 */
package gov.fnal.elab.cms.dataset;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabProperties;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

public class Datasets {
    public static final String DATASETS = "cms.datasets";
    public static final String CURRENT_DATASET = "cms.current.dataset";
    
    @SuppressWarnings("unchecked")
    public static synchronized Map<String, Dataset> getDatasets(Elab elab, HttpSession session) throws DatasetLoadException {
        Map<String, Dataset> datasets = (Map<String, Dataset>) session.getAttribute(DATASETS); 
        if (datasets == null) {
            datasets = loadDatasets(elab);
            session.setAttribute(DATASETS, datasets);
        }
        return datasets;
    }
    
    private static Map<String, Dataset> loadDatasets(Elab elab) throws DatasetLoadException {
        Map<String, Dataset> datasets = new HashMap<String, Dataset>();
        ElabProperties props = elab.getProperties();
        for (Object key : props.keySet()) {
            String skey = (String) key;
            if (skey.startsWith("dataset.descriptor.")) {
                String name = skey.substring("dataset.description".length());
                datasets.put(name, new Dataset(elab, name, props.getProperty(skey), props.getProperty("dataset.location." + name)));
            }
        }
        return datasets;
    }

    public static Dataset getDataset(Elab elab, HttpSession session, String name) throws DatasetLoadException {
        Map<String, Dataset> datasets = getDatasets(elab, session);
        Dataset ds = datasets.get(name);
        if (ds == null) {
            throw new IllegalArgumentException("Invalid dataset: " + name);
        }
        session.setAttribute(CURRENT_DATASET, ds);
        return ds;
    }
}
