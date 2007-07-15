package gov.fnal.elab.cosmic.beans;

import java.util.*;
import java.io.*;
import java.sql.*;
import gov.fnal.elab.cosmic.Geometry;
import gov.fnal.elab.util.ElabException;

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
            throw new ElabException("Problem occured when assembling geometries from database: " + e);
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
