/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Set;

/**
 * A property name which only Managers should have a value for.
 *
 * @hibernate.subclass
 *      discriminator-value="ManagerPropertyName"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class ManagerPropertyName extends PropertyName {

}
