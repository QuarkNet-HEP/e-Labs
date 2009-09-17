package gov.fnal.elab.datacatalog.query;

public abstract class OneChildQueryElement implements QueryElement {
	private final int type;
	private QueryElement root, child; 

	public OneChildQueryElement(int type, QueryElement root, QueryElement child) {
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

	public int getType() {
		return type; 
	}

	public String toString() {
		return "(" + root.toString() + ") " + NAMES[type] + " (" + child.toString() + ")";
	}

	public boolean isLeaf() {
		return false; 
	}
}
