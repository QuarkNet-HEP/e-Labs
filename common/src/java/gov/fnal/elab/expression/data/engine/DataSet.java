/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

import java.util.List;

import org.junit.experimental.theories.DataPoint;

public interface DataSet {
    Number getX(int index);
    Number getY(int index);
    
    Number map(Number x);
    
    int size();
    
    Range getXRange();
    Range getYRange();
    
    Unit getXUnit();
    Unit getYUnit();
    
    String getLabel();
    String getXLabel();
    String getYLabel();
}
