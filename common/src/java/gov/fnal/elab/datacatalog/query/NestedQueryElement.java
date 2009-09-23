package gov.fnal.elab.datacatalog.query;

public abstract class NestedQueryElement implements QueryElement {
	private final QueryElement.TYPES type;
	private QueryElement root, child; 

	public NestedQueryElement(QueryElement.TYPES type, QueryElement root, QueryElement child) {
		this.type = type;
		this.setRoot(root);
		this.setChild(child); 
	}

	public void setRoot(QueryElement root) {
		this.root = root;
	}

	public QueryElement getRoot() {
		return root;
	}

	public void setChild(QueryElement child) {
		this.child = child;
	}

	public QueryElement getChild() {
		return child;
	}

	public QueryElement.TYPES getType() {
		return type; 
	}

	public String toString() {
		return "(" + root.toString() + ") " + type.toString() + " (" + child.toString() + ")";
	}

	public boolean isLeaf() {
		return false; 
	}
}
