/*
 * Created on May 24, 2010
 */
package gov.fnal.elab.cms.dataset;

import gov.fnal.elab.Elab;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Dataset {
    private String name, descriptorLocation, dataLocation, table;
    private List<Trigger> triggers;
    private List<Leaf> leaves;
    private Map<String, Leaf> leafMap;
    private Map<String, String> runFiles;
    private Elab elab;

    public Dataset(Elab elab, String name, String descriptor, String descriptorLocation)
            throws DatasetLoadException {
        this.elab = elab;
        this.name = name;
        this.descriptorLocation = descriptorLocation;

        InputStream is = getClass().getClassLoader().getResourceAsStream(descriptor);
        if (is == null) {
            throw new IllegalArgumentException("Dataset descriptor not found on classpath: "
                    + descriptor);
        }
        try {
            Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder()
                    .parse(is);
            this.dataLocation = elab.getProperty("dataset.location." + name);
            try {
                this.table = doc.getElementsByTagName("database").item(0).getAttributes().getNamedItem("table").getNodeValue();
            }
            catch (Exception e) {
            	throw new DatasetLoadException("Could not get run table name", e);
            }
            populateTriggers(doc);
            populateLeaves(doc);
        }
        catch (Exception e) {
            throw new DatasetLoadException(e);
        }
    }

    private void populateLeaves(Document doc) {
        this.leaves = new ArrayList<Leaf>();
        this.leafMap = new HashMap<String, Leaf>();
        NodeList branches = doc.getElementsByTagName("branch");

        for (int i = 0; i < branches.getLength(); i++) {
            Node branch = branches.item(i);
            String v1 = branch.getAttributes().getNamedItem("name").getNodeValue();
            NodeList leaves = branch.getChildNodes();
            for (int j = 0; j < leaves.getLength(); j++) {
                Node leafNode = leaves.item(j);
                if (leafNode.getNodeType() != Node.ELEMENT_NODE) {
                    continue;
                }
                String v2 = leafNode.getAttributes().getNamedItem("name").getNodeValue();
                String path = v1 + "." + v2;
                Leaf leaf = new Leaf(path, leafNode);
                this.leaves.add(leaf);
                this.leafMap.put(path, leaf);
            }
        }
    }

    private void populateTriggers(Document doc) {
        this.triggers = new ArrayList<Trigger>();
        NodeList triggers = doc.getElementsByTagName("trigger");
        for (int i = 0; i < triggers.getLength(); i++) {
            NamedNodeMap attrs = triggers.item(i).getAttributes();
            if (attrs == null) {
                continue;
            }
            org.w3c.dom.Node fake = attrs.getNamedItem("fake");
            if (fake != null && "true".equals(fake.getNodeValue())) {
                continue;
            }
            this.triggers.add(new Trigger(attrs));
        }
    }

    public String getName() {
        return name;
    }

    public String getDescriptorLocation() {
        return descriptorLocation;
    }

    public String getDataLocation() {
        return dataLocation;
    }

    public Leaf getLeaf(String path) {
        Leaf leaf = leafMap.get(path);
        if (leaf == null) {
            throw new IllegalArgumentException("Invalid leaf: " + path);
        }
        return leaf;
    }

    public List<Trigger> getTriggers() {
        return triggers;
    }
    
    public Map<String, String> getRunFiles() throws DatasetLoadException {
        if (runFiles == null) {
            try {
                runFiles = loadRunFiles();
            }
            catch (SQLException e) {
                throw new DatasetLoadException(e);
            }
        }
        return runFiles;
    }

    private Map<String, String> loadRunFiles() throws SQLException {
        Map<String, String> runFiles = new HashMap<String, String>();
        
        String db = elab.getProperties().getProperty("ogredb.database");
        String dbuser = elab.getProperties().getProperty("ogredb.username");
        String dbpass = elab.getProperties().getProperty("ogredb.password");

        try {
            Class.forName("com.mysql.jdbc.Driver");
        }
        catch (ClassNotFoundException e) {
            throw new RuntimeException("Couldn't find the mysql driver!");
        }

        String table = getTable();
        
        String sql = "SELECT run, filename FROM " + table;

        Connection conn = DriverManager.getConnection("jdbc:mysql:" + db, dbuser, dbpass);
        if (conn == null) {
            throw new SQLException(
                    "Connection to database failed. The SQL driver manager "
                            + "did not return a valid connection");
        }
        try {
            Statement s = conn.createStatement();
            ResultSet rs = s.executeQuery(sql);
            while (rs.next()) {
                String file = rs.getString(2);
                if (file.endsWith(".root")) {
                    file = file.substring(0, file.length() - 5);
                }
                runFiles.put(rs.getString(1), file);
            }
        }
        finally {
            conn.close();
        }
        return runFiles;
    }

    public String getTable() {
        return table;
    }
    
    public List<Leaf> getSimplePlots() {
        return getPlotsForLevel(5);
    }
    
    public List<Leaf> getPlotsForLevel(int level) {
        List<Leaf> lst = new ArrayList<Leaf>();
        for (Leaf l : leaves) {
            if (l.getLevel() == level) {
                lst.add(l);
            }
        }
        return lst;
    }
}
