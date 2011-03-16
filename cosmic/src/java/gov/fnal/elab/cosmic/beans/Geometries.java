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
import java.sql.PreparedStatement;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.TreeMap;

public class Geometries implements Serializable {

    private TreeMap<Integer, Geometry> geometries;
    private HashSet<Geometry> changedGeometries;
    private boolean readOnly;

    public Geometries() {
        this.reset();
    }

    public Geometries(int groupID, String dataDirectory, Connection c)
            throws ElabException {
        this.reset();
        PreparedStatement ps = null; 
        try {
            ps = c.prepareStatement(
            		"SELECT detectorid FROM research_group_detectorid " +
    				"WHERE research_group_id= ? ORDER BY detectorid");
            ps.setInt(1, groupID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                addGeometry(new Geometry(dataDirectory, rs.getInt("detectorid")));
            }
        }
        catch (Exception e) {
            throw new ElabException(
                "Problem occured when assembling geometries from database: ", e);
        }
        finally {
        	DatabaseConnectionManager.close(c, ps);
        }
    }

    public Geometries(Elab elab, int detectorID) throws ElabException {
        this.reset();
        addGeometry(new Geometry(elab.getProperties().getDataDir(), detectorID));
        readOnly = true;
    }

    public Geometries(Elab elab, ElabGroup group) throws ElabException {
        this.reset();
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConnectionManager
                .getConnection(elab.getProperties());
            ps = conn.prepareStatement(
            		"SELECT detectorid FROM research_group_detectorid WHERE research_group_id = ? " +
                    "ORDER BY detectorid");
            ps.setInt(1, group.getId());
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                addGeometry(new Geometry(elab.getProperties().getDataDir(), rs
                    .getInt("detectorid")));
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, ps);
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

    public void setGeometries(TreeMap<Integer, Geometry> h) {
        geometries = h;
    }

    public TreeMap<Integer, Geometry> getGeometries() {
        return geometries;
    }

    public void addGeometry(Geometry g) {
        if (geometries != null) {
            geometries.put(g.getDetectorID(), g);
        }
    }

    public Geometry getGeometry(int detectorID) {
        return geometries.get(detectorID);
    }

    public void addGeoEntry(int detectorID, GeoEntryBean geb) throws ElabJspException {
        Geometry g = geometries.get(detectorID);
        if (g == null) {
            throw new ElabJspException("You are not allowed to modify this detector configuration");
        }
        g.addGeoEntry(geb);
        changedGeometries.add(g);
    }

    public void removeGeoEntry(int detectorID, GeoEntryBean geb) {
        Geometry g = geometries.get(detectorID);
        g.removeGeoEntry(geb);
        changedGeometries.add(g);
    }

    public GeoEntryBean getGeoEntry(int detectorID, String jd) {
        return geometries.get(detectorID).getGeoEntry(jd);
    }

    public Iterator<Geometry> iterator() {
        return geometries.values().iterator();
    }

    public Collection<Geometry> getValues() {
        return geometries.values();
    }

    public void commit() throws ElabException {
        if (readOnly) {
            throw new ElabException("You are not allowed to modify this detector configuration");
        }
        for (Geometry g : changedGeometries) {
        	g.commit(); 
        }
    }

    public void updateMetadata(DataCatalogProvider dcp, GeoEntryBean geoEntry)
            throws ElabException {
        for (Geometry g : changedGeometries) {
        	g.updateMetadata(dcp, geoEntry);
        }
    }

    public String dump() {
        StringBuilder sb = new StringBuilder();
        for (Geometry g : geometries.values()) {
        	sb.append("detectorID: ");
        	sb.append(g.getDetectorID());
        	sb.append("<br>"); 
        }
        return sb.toString();
    }
}
