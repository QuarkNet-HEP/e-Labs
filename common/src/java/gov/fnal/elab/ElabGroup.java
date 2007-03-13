/*
 * Created on Mar 12, 2007
 */
package gov.fnal.elab;

public class ElabGroup {
    private String id;
    private String name;
    private String namelc;

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
        this.namelc = name.toLowerCase();
    }

    public boolean isProfDev() {
        return namelc.startsWith("pd_"); 
    }
}
