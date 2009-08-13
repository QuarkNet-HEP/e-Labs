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
    public static final int AND = 0;
    public static final int OR = 1;
    public static final int NOT = 2;
    public static final int EXISTS = 3;
    public static final int LIKE = 4;
    public static final int BETWEEN = 5;
    public static final int CONTAINS = 6;
    public static final int EQ = 7;
    public static final int NE = 8;
    public static final int GT = 9;
    public static final int LT = 10;
    public static final int GE = 11;
    public static final int LE = 12;
    public static final int ILIKE = 13;
    public static final int IN = 14; 

    public static final String[] NAMES = new String[] { "AND", "OR", "NOT",
            "EXISTS", "LIKE", "BETWEEN", "CONTAINS", "EQ", "NE", "GT", "LT",
            "GE", "LE", "ILIKE", "IN" };

    int getType();

    boolean isLeaf();
}
