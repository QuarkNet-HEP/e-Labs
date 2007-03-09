/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * Glossary item.
 * 
 * @hibernate.subclass
 *      discriminator-value="Glossary"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Glossary extends Comment {

    private String name;

    /**
     * Default Constructor
     */
    public Glossary() { }

    /**
     * @hibernate.property
     *      column="name"
     *      type="text"
     * @return The name of this glossary entry.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

}
