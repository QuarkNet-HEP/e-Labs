//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

public class IfAnalysisIsNotOk extends IfAnalysisIsOk {
    protected boolean getCondition() {
        return !isAnalysisOk(pageContext);
    }
}
