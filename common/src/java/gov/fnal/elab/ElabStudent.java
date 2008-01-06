/*
 * Created on Jun 27, 2007
 */
package gov.fnal.elab;

public class ElabStudent {
    private String id, name;
    private ElabGroup group;

    public ElabStudent() {
    }

    public ElabStudent(String id, String name) {
        this.id = id;
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
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

    public boolean equals(Object obj) {
        if (id == null || name == null) {
            return false;
        }
        if (obj instanceof ElabStudent) {
            ElabStudent s = (ElabStudent) obj;
            return id.equals(s.id) && name.equals(s.name);
        }
        else {
            return false;
        }
    }

    public int hashCode() {
        int hc = 0;
        if (id != null) {
            hc += id.hashCode();
        }
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
