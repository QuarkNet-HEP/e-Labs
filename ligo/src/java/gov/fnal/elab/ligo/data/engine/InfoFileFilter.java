/*
 * Created on Feb 11, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.io.File;
import java.io.FileFilter;

public class InfoFileFilter implements FileFilter {
    public boolean accept(File pathname) {
        return pathname.getName().endsWith(".info");
    }
}
