/*
 * Created on Jan 24, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class CreateDatabase implements Runnable {
    private String frdumpOut, dburl, dbuser, dbpass;
    private Connection conn;
    private Set<String> seen;
    private boolean drop;
    
    public static final Map<String, String> TYPE_MAPPING, DOUBLE_TYPE_MAPPING;
    
    static {
        TYPE_MAPPING = new HashMap<String, String>();
        DOUBLE_TYPE_MAPPING = new HashMap<String, String>();
        
        TYPE_MAPPING.put("int", "integer");
        DOUBLE_TYPE_MAPPING.put("int", "bigint");
        
        TYPE_MAPPING.put("double", "double precision");
        DOUBLE_TYPE_MAPPING.put("double", "double precision");
        
        TYPE_MAPPING.put("float", "real");
        DOUBLE_TYPE_MAPPING.put("float", "double precision");
    }

    public CreateDatabase(String frdumpOut, String dburl, String dbuser, String dbpass, boolean drop) {
        this.frdumpOut = frdumpOut;
        this.dburl = dburl;
        this.dbuser = dbuser;
        this.dbpass = dbpass;
        this.seen = new HashSet<String>();
        this.drop = drop;
    }

    public void run() {
        try {
            run2();
        }
        catch (RuntimeException e) {
            throw e;
        }
        catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }
    
    public static final Pattern DEBUG_LEVEL = Pattern.compile("\\s*Debug level\\s*:\\s*(\\d)+"); 
    public static final Pattern ADC_LINE = Pattern.compile("\\s*ADC:\\s*(\\w+:\\w+-[\\w\\.\\-]+)\\.mean\\s.*nBits=(\\d+) bias=((?:\\w|\\-|\\.)+) slope=((?:\\w|\\-|\\.)+) units=(.*)");
    public static final Pattern DATA_LINE = Pattern.compile("\\s*Data\\((\\w+)\\).*");

    private void run2() throws Exception {
        BufferedReader br;
        if (frdumpOut.equals("-")) {
            br = new BufferedReader(new InputStreamReader(System.in));
        }
        else {
            br = new BufferedReader(new FileReader(frdumpOut));
        }
        Matcher level = skipToNotNull(br, DEBUG_LEVEL);
        if (!"4".equals(level.group(1))) {
            throw new RuntimeException("You must run FrDump with the \"-d 4\" option.");
        }
        connectToDb();
        createDescriptionTables();
        Matcher adc = skipTo(br, ADC_LINE);
        while (adc != null) {
            Matcher data = skipToNotNull(br, DATA_LINE);
            createChannelTable(adc.group(1), data.group(1), adc.group(2), adc.group(3), adc.group(4), adc.group(5));
            adc = skipTo(br, ADC_LINE);
        }
        br.close();
        System.out.println("All done");
    }


    private void createChannelTable(String name, String datatype, String nbits, String bias, String slope, String units) throws SQLException {
        if (seen.contains(name)) {
            return;
        }
        seen.add(name);
        System.out.println("Adding channel " + name + "...");
        PreparedStatement s = conn.prepareStatement("INSERT INTO channels VALUES (?, ?, ?, ?, ?, ?, ?)");
        s.setString(1, name);
        s.setString(2, units);
        s.setString(3, datatype);
        s.setInt(4, Integer.parseInt(nbits));
        s.setDouble(5, Double.parseDouble(slope));
        s.setDouble(6, Double.parseDouble(bias));
        String tblname = specialToUnderscore(name);
        s.setString(7, tblname);
        s.execute();
        s.close();
        
        String sqltype = TYPE_MAPPING.get(datatype);
        String sqltype2 = DOUBLE_TYPE_MAPPING.get(datatype);
        if (sqltype == null || sqltype2 == null) {
            throw new RuntimeException("Data file contains an unknown data type: " + datatype);
        }
        if (drop) {
            Statement d = conn.createStatement();
            try {
                d.execute("DROP TABLE " + tblname + " CASCADE");
                d.close();
            }
            catch (SQLException e) {
                // no previous table?
            }
        }
        Statement s2 = conn.createStatement();
        s2.execute("CREATE TABLE " + tblname + " (" +
        		   "  time numeric(14, 3) PRIMARY KEY," +
        		   "  value " + sqltype + "," +
        		   "  sum " + sqltype2 + "," +
        		   "  sumsq " + sqltype2 +
        		   ") TABLESPACE ligodata");
        s2.execute("CREATE INDEX " + tblname + "_index ON " + tblname + " (time) TABLESPACE ligodata");
        s2.close();
    }

    private String specialToUnderscore(String name) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < name.length(); i++) {
            char c = name.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                sb.append(c);
            }
            else {
                sb.append("_");
            }
        }
        return sb.toString();
    }

    private void createDescriptionTables() throws SQLException {
        if (drop) {
            Statement s = conn.createStatement();
            try {
                s.execute("DROP TABLE channels");
            }
            catch (SQLException e) {
                // no previous table to drop
            }
            try {
                s.execute("DROP TABLE sumupdates");
            }
            catch (SQLException e) {
                // no previous table to drop
            }
            s.close();
        }
        System.out.println("Creating channel descriptor table...");
        Statement s = conn.createStatement();
        s.execute("CREATE TABLE channels (" +
        		  "  name      varchar(80) NOT NULL," +
        		  "  units     varchar(8)," +
        		  "  datatype  varchar(16) NOT NULL," +
        		  "  nBits     integer," +
        		  "  slope     double precision," +
        		  "  bias      double precision," +
        		  "  tablename varchar(80) NOT NULL" +
        		  ") TABLESPACE ligodata");
        s.execute("CREATE TABLE sumupdates (" +
                  "  id        SERIAL," +
        		  "  tablename varchar(80) NOT NULL," +
        		  "  starttime numeric(14, 3)," +
        		  "  endtime   numeric(14, 3)," +
        		  "  sumdeltad double precision," +
        		  "  sumdeltai bigint," +
        		  "  ssqdeltad double precision," +
        		  "  ssqdeltai bigint" +
        		  ") TABLESPACE ligodata");
    }

    private void connectToDb() throws SQLException {
        System.out.println("Connecting to database...");
        conn = DriverManager.getConnection(
                "jdbc:postgresql:" + dburl, dbuser, dbpass);
    }

    private Matcher skipToNotNull(BufferedReader br, Pattern p) throws IOException {
        Matcher result = skipTo(br, p);
        if (result == null) {
            throw new RuntimeException("Search string not found in FrDump output: " + p);
        }
        else {
            return result;
        }
    }

    private Matcher skipTo(BufferedReader br, Pattern p) throws IOException {
        String line = br.readLine();
        while (line != null) {
            Matcher m = p.matcher(line);
            if (m.matches()) {
                return m;
            }
            line = br.readLine();
        }
        return null;
    }

    public static void main(String[] args) {
        if (args.length < 4) {
            error("Incorrect number of arguments", 1);
        }
        boolean drop = false;
        if (args.length == 5 && args[4].equals("--drop")) {
            drop = true;
        }
        try {
            new CreateDatabase(args[0], args[1], args[2], args[3], drop).run();
        }
        catch (Exception e) {
            error(e.getMessage(), 2);
        }
    }

    public static void error(String msg, int ec) {
        System.err.println(msg);
        help();
        System.exit(ec);
    }

    public static void help() {
        System.err.println("Usage: CreateDatabase <frdump> <dburl> <dbuser> <dbpass> [--drop]");
        System.err.println("  where:");
        System.err.println("    <frdump> is the output from FrDump on a frame file with -d 4 (or '-' for stdin)");
        System.err.println("    <dburl> is the url for the PostgreSQL server");
        System.err.println("    <dbuser> the database username");
        System.err.println("    <dbpass> the database password");
    }
}
