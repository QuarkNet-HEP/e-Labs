/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Set;

/**
 * A property name which only users should have a value for.
 *
 * @hibernate.subclass
 *      discriminator-value="UserPropertyName"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class UserPropertyName extends PropertyName {

}
