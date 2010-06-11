/*
 * Created on Jun 27, 2007
 */
package gov.fnal.elab;

public class ElabStudent {
	private int id;
    private String name;
    private ElabGroup group;

    public ElabStudent() {
    }

    public ElabStudent(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String toString() {
        return "ElabStudent[id=" + id + ", name=" + name + "]";
    }

    public boolean equals(ElabStudent es) {
    	return (es.id == id) && name.equals(es.name);
    }

    public int hashCode() {
        int hc = id;
        if (name != null) {
            hc += name.hashCode();
        }
        return hc;
    }

    /**
     * Retrieve the group that this student belongs to
     */
    public ElabGroup getGroup() {
        return group;
    }

    /**
     * Set the group that this student belongs to
     */
    public void setGroup(ElabGroup group) {
        this.group = group;
    }
}
