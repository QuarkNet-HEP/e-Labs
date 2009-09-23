package gov.fnal.elab.datacatalog.query;

public class Not extends NestedQueryElement {
	public Not(QueryLeaf root, QueryElement child) {
    	super(QueryElement.TYPES.NOT, root, child);
    }
}
