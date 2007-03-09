/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Set;

/**
 * Milestone class.
 * 
 * @hibernate.subclass
 *      discriminator-value="Milestone"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Milestone extends Comment {

    private String name;
    private String normalDescription;
    private String commandDescription;
    private String referenceInfo;
    private String type;
    private Set milestonePlacements;

    /**
     * Empty constructor for Hibernate.
     */
    public Milestone() {}

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * @hibernate.property
     *      column="name"
     * @return The name of this milestone.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.property
     *      column="normal_description"
     *      type="text"
     * @return The description of this milestone.
     */
    public String getNormalDescription() { return normalDescription; }
    public void setNormalDescription(String normalDescription) { this.normalDescription = normalDescription; }

    /**
     * @hibernate.property
     *      column="command_description"
     *      type="text"
     * @return A sentence (or sentences) asking the user to _do something_ with this milestone. Usually asking to "describe" it.
     */
    public String getCommandDescription() { return commandDescription; }
    public void setCommandDescription(String commandDescription) { this.commandDescription = commandDescription; }

    /**
     * @hibernate.property
     *      column="reference_info"
     *      type="text"
     * @return The reference information for this milestone should be kept here. This will usually be a long string of html.
     */
    public String getReferenceInfo() { return referenceInfo; }
    public void setReferenceInfo(String referenceInfo) { this.referenceInfo = referenceInfo; }

    /**
     * @hibernate.property
     *      column="type"
     * @return What kind of milestone is this, and who should see it.
     */
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.MilestonePlacement"
     * @hibernate.collection-key
     *      column="fk_milestone"
     * @return The set of milestone placements for this milestone.
     */
    public Set getMilestonePlacements() { return milestonePlacements; }
    public void setMilestonePlacements(Set milestonePlacements) { this.milestonePlacements = milestonePlacements; }

}
