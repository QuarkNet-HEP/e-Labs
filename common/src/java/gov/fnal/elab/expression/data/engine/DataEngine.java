/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public interface DataEngine {
    DataSet get(String path, Range range, Options options);
}
