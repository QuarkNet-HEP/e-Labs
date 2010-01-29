/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.sql.Statement;

public class ChangePermissions extends AbstractDataTool {
    private String user;
    
    public ChangePermissions(String dburl, String dbuser,
            String dbpass, String user) {
        super(dburl, dbuser, dbpass);
        this.user = user;
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

    private void run2() throws Exception {
        connectToDb();
        loadChannelInfo();
        for (String table : tables.values()) {
            System.out.println(table);
            Statement s = conn.createStatement();
            s.execute("ALTER TABLE " + table + " OWNER TO " + user);
            s.close();
        }
    }
    
    public static void main(String[] args) {
        if (args.length < 4) {
            help();
            error("Missing argument(s)", 1);
        }
        try {
            new ChangePermissions(args[0], args[1], args[2], args[3]).run();
        }
        catch (NullPointerException e) {
            e.printStackTrace();
            System.exit(3);
        }
        catch (Exception e) {
            e.printStackTrace();
            error(e.getMessage(), 2);
        }
    }

    public static void error(String msg, int ec) {
        System.err.println(msg);
        System.exit(ec);
    }

    public static void help() {
        System.err.println("Usage: ChangePermissions <dburl> <dbsuser> <dbsupass> <user>");
        System.err.println("  where:");
        System.err.println("    <workdir> a directory to hold data and log state");
        System.err.println("    <dburl>    database name");
        System.err
            .println("    <dbsuser>  a database user with superuser priviledges (in order to be able to execute COPY statements)");
        System.err.println("    <dbsupass> password for said user");
        System.err.println("    <user>     new table owner");
    }
}
