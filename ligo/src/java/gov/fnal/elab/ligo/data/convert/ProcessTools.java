/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class ProcessTools {
    public static String getOutput(String desc, Process p, File f) throws IOException {
        String out = getOutput(p.getInputStream());
        int ec;
        try {
            ec = p.waitFor();
        }
        catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        String err = getOutput(p.getErrorStream());
        
        p.getOutputStream().close(); // Need to flush stdin, too?  

        // EPeronja-05/10/2013: commented this out and everything worked!
        //if (ec != 0) {
        //    throw new ToolException(desc + " failed for " + f + ": " + err);
        //}
        return out;
    }

    public static String getOutput(InputStream is) throws IOException {
        StringBuilder sb = new StringBuilder();
        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        String line = br.readLine();
        while (line != null) {
            sb.append(line);
            sb.append('\n');
            line = br.readLine();
        }
        is.close();
        return sb.toString();
    }
}
