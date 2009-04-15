package gov.fnal.elab.cosmic.beans;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabJspException;
import gov.fnal.elab.cosmic.Geometry;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.TreeMap;

public class Geometries implements Serializable {

    private TreeMap geometries;
    private HashSet changedGeometries;
    private boolean readOnly;

    public Geometries() {
        this.reset();
    }

    public Geometries(String groupID, String dataDirectory, Connection c)
            throws ElabException {
        this.reset();
        try {
            Statement s = c.createStatement();
            ResultSet rs = s
                .executeQuery("SELECT detectorid FROM research_group_detectorid WHERE research_group_id='"
                        + groupID + "' ORDER BY detectorid");

            while (rs.next()) {
                addGeometry(new Geometry(dataDirectory, rs.getString(1)));
            }
            if (s != null)
                s.close();
            if (c != null)
                c.close();
        }
        catch (Exception e) {
            throw new ElabException(
                "Problem occured when assembling geometries from database: ", e);
        }
    }

    public Geometries(Elab elab, String detectorID) throws ElabException {
        this.reset();
        addGeometry(new Geometry(elab.getProperties().getDataDir(), detectorID));
        readOnly = true;
    }

    public Geometries(Elab elab, ElabGroup group) throws ElabException {
        this.reset();
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                .executeQuery("SELECT detectorid FROM research_group_detectorid WHERE research_group_id='"
                        + group.getId() + "' ORDER BY detectorid");

            while (rs.next()) {
                addGeometry(new Geometry(elab.getProperties().getDataDir(), rs
                    .getString(1)));
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public void reset() {
        geometries = new TreeMap();
        changedGeometries = new HashSet();
    }

    public void setChangedGeometries(HashSet h) {
        changedGeometries = h;
    }

    public HashSet getChangedGeometries() {
        return changedGeometries;
    }

    public void setGeometries(TreeMap h) {
        geometries = h;
    }

    public TreeMap getGeometries() {
        return geometries;
    }

    public void addGeometry(Geometry g) {
        if (geometries != null) {
            geometries.put(g.getDetectorID(), g);
        }
    }

    public Geometry getGeometry(String detectorID) {
        return (Geometry) geometries.get(detectorID);
    }

    public void addGeoEntry(String detectorID, GeoEntryBean geb) throws ElabJspException {
        Geometry g = (Geometry) geometries.get(detectorID);
        if (g == null) {
            throw new ElabJspException("You are not allowed to modify this detector configuration");
        }
        g.addGeoEntry(geb);
        changedGeometries.add(g);
    }

    public void removeGeoEntry(String detectorID, GeoEntryBean geb) {
        Geometry g = (Geometry) geometries.get(detectorID);
        g.removeGeoEntry(geb);
        changedGeometries.add(g);
    }

    public GeoEntryBean getGeoEntry(String detectorID, String jd) {
        Geometry g = (Geometry) geometries.get(detectorID);
        return g.getGeoEntry(jd);
    }

    public Iterator iterator() {
        return geometries.values().iterator();
    }

    public Collection getValues() {
        return geometries.values();
    }

    public void commit() throws ElabException {
        if (readOnly) {
            throw new ElabException("You are not allowed to modify this detector configuration");
        }
        Iterator i = changedGeometries.iterator();
        while (i.hasNext()) {
            ((Geometry) i.next()).commit();
        }
    }

    public void updateMetadata(DataCatalogProvider dcp, GeoEntryBean geoEntry)
            throws ElabException {
        Iterator i = changedGeometries.iterator();
        while (i.hasNext()) {
            ((Geometry) i.next()).updateMetadata(dcp, geoEntry);
        }
    }

    public String dump() {
        Iterator i = geometries.values().iterator();
        String s = "";
        while (i.hasNext()) {
            Geometry g = (Geometry) i.next();
            s += "detectorID:" + g.getDetectorID() + "<br>";
        }
        return s;
    }
}
