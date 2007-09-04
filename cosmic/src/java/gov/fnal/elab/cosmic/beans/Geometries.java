package gov.fnal.elab.cosmic.beans;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.cosmic.Geometry;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Iterator;
import java.util.TreeMap;

public class Geometries implements Serializable {

    private TreeMap geometries; 
    private HashSet changedGeometries;

    public Geometries() {
        this.reset();
    }
    
    public Geometries(String groupID, String dataDirectory, Connection c) throws ElabException {
        this.reset();
        try {
            Statement s = c.createStatement();
            ResultSet rs = s.executeQuery(
                    "SELECT detectorid FROM research_group_detectorid WHERE research_group_id='" + 
                    groupID + "' ORDER BY detectorid");   

            while(rs.next()) {
                addGeometry(new Geometry(dataDirectory, rs.getString(1)));
            }
            if (s != null) 
                s.close();
            if (c != null)
                c.close();
        } catch (Exception e) {
            throw new ElabException("Problem occured when assembling geometries from database: ", e);
        }
    }

    public Geometries(Elab elab, ElabGroup group) throws ElabException {
        this.reset();
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s.executeQuery(
                    "SELECT detectorid FROM research_group_detectorid WHERE research_group_id='" + 
                    group.getId() + "' ORDER BY detectorid");   

            while(rs.next()) {
                addGeometry(new Geometry(elab.getProperties().getDataDir(), rs.getString(1)));
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

    public void setChangedGeometries(HashSet h) { changedGeometries = h; }
    public HashSet getChangedGeometries() { return changedGeometries; }

    public void setGeometries(TreeMap h) { geometries = h; }
    public TreeMap getGeometries() { return geometries; }

    public void addGeometry(Geometry g) {
        if (geometries != null) {
            geometries.put(g.getDetectorID(), g);
        }
    }
    
    public Geometry getGeometry(String detectorID) {
        return (Geometry) geometries.get(detectorID);
    }

    public void addGeoEntry(String detectorID, GeoEntryBean geb) {
        Geometry g = (Geometry)geometries.get(detectorID);
        g.addGeoEntry(geb);
        changedGeometries.add(g);
    }

    public void removeGeoEntry(String detectorID, GeoEntryBean geb) {
        Geometry g = (Geometry)geometries.get(detectorID);
        g.removeGeoEntry(geb);
        changedGeometries.add(g);
    }

    public GeoEntryBean getGeoEntry(String detectorID, String jd) {
        Geometry g = (Geometry)geometries.get(detectorID);
        return g.getGeoEntry(jd);
    }

    public Iterator iterator() {
        return geometries.values().iterator();
    }

    public void commit() throws ElabException {
        Iterator i = changedGeometries.iterator();
        while (i.hasNext()) {
            ((Geometry)i.next()).commit();
        }
    }

    public void updateMetadata() throws ElabException {
        Iterator i = changedGeometries.iterator();
        while (i.hasNext()) {
            ((Geometry)i.next()).updateMetadata();
        }
    }

    public String dump() {
         Iterator i = geometries.values().iterator();
         String s = "";
         while (i.hasNext()) { 
             Geometry g = (Geometry)i.next();
             s += "detectorID:" + g.getDetectorID() + "<br>";
         }
         return s;
    }
}
