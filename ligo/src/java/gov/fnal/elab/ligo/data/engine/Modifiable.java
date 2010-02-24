/*
 * Created on Feb 23, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.io.IOException;

public interface Modifiable {

    void reload() throws IOException;

    String getDataDirectory();

}
