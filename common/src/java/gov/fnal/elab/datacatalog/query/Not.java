package gov.fnal.elab.datacatalog.query;

public class Not extends OneChildQueryElement {
	public Not(QueryElement root, QueryElement child) {
    	super(QueryElement.TYPES.NOT, root, child);
    }
}
