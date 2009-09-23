/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog.query;

public class In extends MultiQueryElement {
	
	/**
	 * Constructs an IN query (select all elements from the matching the root predicate that are also in the child predicate.) 
	 * @param root Parent QueryElement 
	 * @param child Child QueryElement defining the IN search space
	 */
    public In() {
    	super(QueryElement.TYPES.IN);
    }
}
