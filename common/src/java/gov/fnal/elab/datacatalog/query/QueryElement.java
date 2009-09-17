//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog.query;

public interface QueryElement {
	public static enum TYPES {
		AND(0, "AND"), 
		OR(1, "OR"), 
		NOT(2, "NOT"), 
		EXISTS(3, "EXISTS"), 
		LIKE(4, "LIKE"), 
		BETWEEN(5, "BETWEEN"), 
		CONTAINS(6, "CONTAINS"), 
		EQ(7, "=="), 
		NE(8, "!="), 
		GT(9, ">"), 
		LT(10, "<"), 
		GE(11, ">="), 
		LE(12, "<="), 
		ILIKE(13, "ILIKE"), 
		IN(14, "IN");
		
		private final int vdsCode; 
		private final String description;
		
		TYPES(int vdsCode, String description) {
			this.vdsCode = vdsCode;
			this.description = description; 
		}
		
		public String toString() {
			return description; 
		}
	};
	
    QueryElement.TYPES getType();

    boolean isLeaf();
}
