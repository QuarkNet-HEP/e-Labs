/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

import java.util.List;

public interface DataEngine {
    DataSet get(DataPath path, Range range, Options options) throws DataBackendException;
    
    List<DataPath> getPaths() throws DataBackendException;
}
