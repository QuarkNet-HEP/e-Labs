package gov.fnal.elab.datacatalog;

public class ElabPredicate extends org.griphyn.vdl.annotation.Predicate {
	
	public static final int ILIKE = 13; // Case insensitive search
	public static final int IN    = 14; // TODO: IMPLEMENT
	
	public static final String[] PREDICATE_STRING = {
	      "AND",
	      "OR",
	      "NOT",
	      "EXISTS",
	      "LIKE",
	      "BETWEEN",
	      "CONTAINS",
	      "=",
	      "<>",
	      ">",
	      "<",
	      ">=",
	      "<=",
	      "ILIKE",
	      "IN"
	  };
	
	public ElabPredicate(int predicate) {
		super(predicate);
	}
	
	public ElabPredicate(int predicate, String key) {
		super(predicate, key);
	}
	
	public ElabPredicate( int predicate, String key, String value) {
		super(predicate, key, value);
	}
	
	public ElabPredicate( int predicate, String key, int type, String value) {
		super(predicate, key, type, value);
	}
	
	public ElabPredicate( int predicate, String key, int type, String value1, String value2) {
		super(predicate, key, type, value1, value2);
	}
}
