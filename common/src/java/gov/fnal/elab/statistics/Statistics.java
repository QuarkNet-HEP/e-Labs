/*
 * Created on Jan 10, 2009
 */
package gov.fnal.elab.statistics;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

public class Statistics {
    public static final Set<String> FILTERED_GROUPS = new HashSet<String>() {{
        add("TestTeacher");
        add("admin");
    }};
    
    
    private String start;
    private String end;
    private int span;
    private Elab elab;
    private String role;
    private String type;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Elab getElab() {
        return elab;
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public int getSpan() {
        return span;
    }

    public void setSpan(int span) {
        this.span = span;
    }

    public String getGroupCount() throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            // get number of research groups with the given role as long as they are
            // in the
            // specified interval and they are associated with this project
            PreparedStatement ps = con
                    .prepareStatement("select count(*) from research_group "
                            + "where role=? "
                            + "     and id in (select research_group_id from research_group_project"
                            + "         where project_id = ?) and name not in " + getGroupFilter());
            ps.setString(1, role);
            ps.setInt(2, elab.getId());
    
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
            else {
                return "-";
            }
        }
        finally {
            DatabaseConnectionManager.close(con);
        }
    }
    
    private String groupFilter;
    
    private synchronized String getGroupFilter() {
        if (groupFilter == null) {
            StringBuilder sb = new StringBuilder();
            sb.append(" (");
            Iterator<String> i = FILTERED_GROUPS.iterator();
            while (i.hasNext()) {
                sb.append("'");
                sb.append(i.next());
                sb.append("'");
                if (i.hasNext()) {
                    sb.append(',');
                }
            }
            if (FILTERED_GROUPS.isEmpty()) {
                sb.append("'<none>'");
            }
            sb.append(')');
            groupFilter = sb.toString();
        }
        return groupFilter;
    }

    public String getLogIns() throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            // get number of research groups with the given role as long as they are
            // in the
            // specified interval and they are associated with this project
            PreparedStatement ps = con
                    .prepareStatement("select count(id) from usage "
                            + "where date_entered between now() - ?::interval and now() "
                            + "and research_group_id in (select research_group_id from research_group_project"
                            + "         where project_id = ?) "
                            + "and research_group_id not in (select id from research_group where name in " + getGroupFilter() + ")");
            ps.setString(1, span + " days");
            ps.setInt(2, Integer.parseInt(elab.getId()));
    
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
            else {
                return "-";
            }
        }
        finally {
            DatabaseConnectionManager.close(con);
        }
    }

    public List getYearlyLoginCounts() throws SQLException {
        return getLoginCounts("year", "YYYY");
    }

    public List getMonthlyLoginCounts() throws SQLException {
        return getLoginCounts("month", "MM/YYYY");
    }

    private List getLoginCounts(String granularity, String format)
            throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            // get number of research groups with the given role as long as they
            // are
            // in the
            // specified interval and they are associated with this project
            PreparedStatement ps = con
                    .prepareStatement("select to_char(date_trunc('" + granularity + "', date_entered), '" + format + "'), count(date_entered) from usage "
                            + "where date_entered between ?::timestamp and ?::timestamp "
                            + "and research_group_id in "
                            + "   (select research_group_id from research_group_project "
                            + "         where project_id = ?) "
                            + "and research_group_id not in (select id from research_group where name in " + getGroupFilter() + ") "
                            + "group by date_trunc('" + granularity + "', date_entered) " 
                            + "order by date_trunc('" + granularity + "', date_entered)");
            ps.setString(1, start);
            ps.setString(2, end);
            ps.setInt(3, elab.getId());
            PreparedStatement gs = con
                    .prepareStatement("select to_char(date_trunc('" + granularity + "', date_entered), '" + format + "'), count(date_entered) from usage "
                            + "where date_entered between ?::timestamp and ?::timestamp "
                            + "and research_group_id in "
                            + "   (select research_group_id from research_group_project "
                            + "         where project_id = ? and research_group_id = (select id from research_group where name = 'guest')) "
                            + "group by date_trunc('" + granularity + "', date_entered) " 
                            + "order by date_trunc('" + granularity + "', date_entered)");
            gs.setString(1, start);
            gs.setString(2, end);
            gs.setInt(3, elab.getId());

            ResultSet rs = ps.executeQuery();
            ResultSet gss = gs.executeQuery();
            
            Map<String, Integer> gssm = new HashMap<String, Integer>();
            while (gss.next()) {
                gssm.put(gss.getString(1), gss.getInt(2));
            }
            
            List l = new ArrayList();
            while (rs.next()) {
                String name = rs.getString(1);
                int count = rs.getInt(2);
                BarChartEntry bce = new BarChartEntry(name, count);
                if (count == 0) {
                    continue;
                }
                int guestCount;
                if (gssm.containsKey(name)) {
                    guestCount = gssm.get(name);
                }
                else {
                    guestCount = 0;
                }
                
                bce.setGuestPercentage((double) guestCount / count * 100);
                l.add(bce);
            }
            int maxCount = 1;
            for (int i = 0; i < l.size(); i++) {
                BarChartEntry bce = (BarChartEntry) l.get(i);
                if (bce.count > maxCount) {
                    maxCount = bce.count;
                }
            }
            for (int i = 0; i < l.size(); i++) {
                BarChartEntry bce = (BarChartEntry) l.get(i);
                bce.setRelativeSize((double) bce.count / maxCount);
            }
            return l;
        }
        finally {
            DatabaseConnectionManager.close(con, null);
        }
    }

    public List getMostActiveLoginUsers() throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            PreparedStatement ps = con
                    .prepareStatement("select "
                            + " (select name from research_group where id = research_group_id), "
                            + "     count(research_group_id) from usage "
                            + "         where date_entered between ?::timestamp and ?::timestamp "
                            + "         and research_group_id in "
                            + "             (select research_group_id from research_group_project "
                            + "                 where project_id = ?) "
                            + " and research_group_id not in (select id from research_group where name in " + getGroupFilter() + ") "
                            + "     group by research_group_id "
                            + "     order by count(research_group_id) desc"
                            + "     limit 32");
            ps.setString(1, start);
            ps.setString(2, end);
            ps.setInt(3, elab.getId());
    
            ResultSet rs = ps.executeQuery();
    
            int maxCount = 1;
            List l = new ArrayList();
            while (rs.next()) {
                BarChartEntry bce = new BarChartEntry(rs.getString(1), rs.getInt(2));
                l.add(bce);
                if (bce.count > maxCount) {
                    maxCount = bce.count;
                }
            }
            for (int i = 0; i < l.size(); i++) {
                BarChartEntry bce = (BarChartEntry) l.get(i);
                bce.setRelativeSize((double) bce.count / maxCount);
            }
            return l;
        }
        finally {
            DatabaseConnectionManager.close(con);
        }
    }

    public String getSchoolCount() throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            // get number of schools as long as there is at least one teacher
            // for this project at that school
            PreparedStatement ps = con
                    .prepareStatement("select count(*) from school "
                            + "where id in (select school_id from teacher "
                            + "     where id in (select teacher_id from research_group "
                            + "         where id in (select research_group_id from research_group_project "
                            + "             where project_id = ?)))");
            ps.setInt(1, elab.getId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
            else {
                return "-";
            }
        }
        finally {
            DatabaseConnectionManager.close(con);
        }
    }

    public String getTestsTaken() throws SQLException {
        Connection con = DatabaseConnectionManager.getConnection(elab
                .getProperties());
        try {
            PreparedStatement ps = con
                    .prepareStatement("select count(*) from survey "
                            + "where project_id = ? " + "and " + type
                            + "survey = true");
            ps.setInt(1, elab.getId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
            else {
                return "-";
            }
        }
        finally {
            DatabaseConnectionManager.close(con);
        }
    }

    public int getVDCEntryCount() throws ElabException {
        And and = new And();
        Calendar end = Calendar.getInstance();
        Calendar start = Calendar.getInstance();
        start.add(Calendar.DAY_OF_YEAR, -span);
        and.add(new Between(type.equals("poster") ? "date" : "creationdate",
                start.getTime(), end.getTime()));
        and.add(new Equals("type", type));
        and.add(new Equals("project", elab.getName()));

        gov.fnal.elab.datacatalog.query.ResultSet rs = elab
                .getDataCatalogProvider().runQueryNoMetadata(and);
        return rs.size();
    }

    public List getYearlyDataCounts() throws ElabException, ParseException {
        return getDataCounts("yyyy");
    }

    public List getMonthlyDataCounts() throws ElabException, ParseException {
        return getDataCounts("yyyy-MM");
    }

    public static final Integer ONE = new Integer(1);

    private List getDataCounts(String format) throws ElabException,
            ParseException {
        And and = new And();

        DateFormat fmt = new SimpleDateFormat("MM/dd/yyyy");
        String date = type.equals("poster") ? "date" : "creationdate";
        and.add(new Equals("type", type));
        and.add(new Between(date, fmt.parse(start), fmt.parse(end)));
        and.add(new Equals("project", elab.getName()));

        gov.fnal.elab.datacatalog.query.ResultSet rs = elab
                .getDataCatalogProvider().runQuery(and);

        int max = 1;
        Map m = new HashMap();
        Calendar cal = Calendar.getInstance();
        Iterator i = rs.iterator();
        DateFormat df = new SimpleDateFormat(format);
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            Date s = (Date) e.getTupleValue(date);
            Object key = df.format(s);
            Integer c = (Integer) m.get(key);
            if (c == null) {
                c = ONE;
            }
            else {
                c = new Integer(c.intValue() + 1);
            }
            if (c.intValue() > max) {
                max = c.intValue();
            }
            m.put(key, c);
        }
        m = new TreeMap(m);

        List l = new ArrayList();
        i = m.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            BarChartEntry bce = new BarChartEntry((String) e.getKey(),
                    ((Integer) e.getValue()).intValue());
            bce.setRelativeSize((double) bce.count / max);
            l.add(bce);
        }
        return l;
    }

    public List getMostActiveDataUsers() throws ElabException, ParseException {
        And and = new And();

        DateFormat fmt = new SimpleDateFormat("MM/dd/yyyy");
        String date = type.equals("poster") ? "date" : "creationdate";
        and.add(new Equals("type", type));
        and.add(new Between(date, fmt.parse(start), fmt.parse(end)));
        and.add(new Equals("project", elab.getName()));

        gov.fnal.elab.datacatalog.query.ResultSet rs = elab
                .getDataCatalogProvider().runQuery(and);

        int max = 1;
        Map m = new HashMap();
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            Object key = e.getTupleValue("group");
            Integer c = (Integer) m.get(key);
            if (c == null) {
                c = ONE;
            }
            else {
                c = new Integer(c.intValue() + 1);
            }
            if (c.intValue() > max) {
                max = c.intValue();
            }
            m.put(key, c);
        }

        SortedMap sm = new TreeMap();
        i = m.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            sm.put(e.getValue(), e.getKey());
        }

        LinkedList l = new LinkedList();

        i = sm.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            BarChartEntry bce = new BarChartEntry((String) e.getValue(),
                    ((Integer) e.getKey()).intValue());
            bce.setRelativeSize((double) bce.count / max);
            l.addFirst(bce);
            if (l.size() > 32) {
                l.removeLast();
            }
        }
        return l;
    }

    public static class BarChartEntry {
        private String key;
        private int count;
        private double relativeSize;
        private double guestPercentage;

        public BarChartEntry(String key, int count) {
            this.key = key;
            this.count = count;
        }

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }

        public int getCount() {
            return count;
        }

        public void setCount(int count) {
            this.count = count;
        }

        public double getRelativeSize() {
            return relativeSize;
        }

        public void setRelativeSize(double relativeSize) {
            this.relativeSize = relativeSize;
        }

        public double getGuestPercentage() {
            return guestPercentage;
        }

        public void setGuestPercentage(double guestPercentage) {
            this.guestPercentage = guestPercentage;
        }

        public String toString() {
            return key + ": " + count;
        }
    }
}
