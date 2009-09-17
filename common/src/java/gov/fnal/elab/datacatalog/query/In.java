/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog.query;

public class In extends OneChildQueryElement {
	
	/**
	 * Constructs an IN query (SELECT column FROM table WHERE value IN (...))
	 * @param root Parent QueryElement 
	 * @param child Child QueryElement defining the IN search space
	 */
    public In(QueryElement root, QueryElement child) {
    	super(QueryElement.TYPES.IN, root, child);
    }
}
