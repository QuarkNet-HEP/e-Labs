/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import org.hibernate.HibernateException;
import org.hibernate.cfg.Configuration;

/**
 * ConfigSingleton creates a {@link net.sf.hibernate.cfg.Configuration} for the entire
 * JVM session.  This eliminates the need for creating the map files for every database
 * request, especially useful when used inside of a webapp.
 *
 * @author      Eric Gilbert, FNAL
 * @version     %I%, %G%
 */
public class ConfigSingleton {

    private static Configuration config = null;

    /**
     * Gets the configuration for the caller to use when creating a database session.
     * This method only creates configurations once per JVM session.
     *
     * Note: Any new classes (*exempting subclasses*) need to be explicitly included
     * in the addClass() calls below.
     *
     * @return Configuration    The Hibernate configuration representing the mapping files.
     */
    public static Configuration getConfig() throws HibernateException {
        if (config == null) {
            config = new Configuration();
            config.configure();
            //config.addClass(Address.class);
            //config.addClass(Answer.class);
            //config.addClass(AnswerSheet.class);
            //config.addClass(Choice.class);
            //config.addClass(Institution.class);
            //config.addClass(Logbook.class);
            //config.addClass(LogEntry.class);
            //config.addClass(Milestone.class);
            //config.addClass(Person.class);
            //config.addClass(Project.class);
            //config.addClass(Question.class);
            //config.addClass(Role.class);
            //config.addClass(Survey.class);
            //config.addClass(Use.class);
            //config.addClass(User.class);
            //config.addClass(QuarkNetDetector.class);
        }
        return config;
    }
}
