package gov.fnal.elab.db;

import org.hibernate.*;
import org.hibernate.cfg.*;
import org.apache.commons.logging.*;

import javax.naming.*;

/**
 * Basic Hibernate helper class, handles SessionFactory, Session and Transaction.
 * <p>
 * Uses a static initializer for the initial SessionFactory creation
 * and holds Session and Transactions in thread local variables.
 *
 * http://www.hibernate.org/42.html
 *
 * @author christian@hibernate.org
 */
public class HibernateUtil {

    private static Log log = LogFactory.getLog(HibernateUtil.class);

    private static Configuration configuration;
    private static SessionFactory sessionFactory;
    private static final ThreadLocal threadSession = new ThreadLocal();
    private static final ThreadLocal threadTransaction = new ThreadLocal();

    // Create the initial SessionFactory from the default configuration files
    static {
        try {
            configuration = new Configuration();
            sessionFactory = configuration.configure().buildSessionFactory();
            // We could also let Hibernate bind it to JNDI:
            // configuration.configure().buildSessionFactory()
        } catch (Throwable ex) {
            // We have to catch Throwable, otherwise we will miss
            // NoClassDefFoundError and other subclasses of Error
            log.error("Building SessionFactory failed.", ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    /**
     * Returns the SessionFactory used for this static class.
     *
     * @return SessionFactory
     */
    public static SessionFactory getSessionFactory() {
        /* Instead of a static variable, use JNDI:
           SessionFactory sessions = null;
           try {
           Context ctx = new InitialContext();
           String jndiName = "java:hibernate/HibernateFactory";
           sessions = (SessionFactory)ctx.lookup(jndiName);
           } catch (NamingException ex) {
           throw new RuntimeException(ex);
           }
           return sessions;
           */
        return sessionFactory;
    }

    /**
     * Retrieves the current Session local to the thread.
     * <p/>
     * If no Session is open, opens a new Session for the running thread.
     *
     * @return Session
     */
    public static org.hibernate.classic.Session getSession() throws HibernateException{
        // With CMT, this should return getSessionFactory().getCurrentSession() and do nothing else
        org.hibernate.classic.Session s = (org.hibernate.classic.Session) threadSession.get();
        if (s == null) {
            log.debug("Opening new Session for this thread.");
            s = getSessionFactory().openSession();
            threadSession.set(s);
        }
        return s;
    }

    /**
     * Closes the Session local to the thread.
     */
    public static void closeSession() throws HibernateException{
        // Would be written as a no-op in an EJB container with CMT
        Session s = (Session) threadSession.get();
        threadSession.set(null);
        if (s != null && s.isOpen()) {
            log.debug("Closing Session of this thread.");
            s.close();
        }
    }

    /**
     * Start a new database transaction.
     */
    public static void beginTransaction() throws HibernateException{
        // Would be written as a no-op in an EJB container with CMT
        Transaction tx = (Transaction) threadTransaction.get();
        if (tx == null) {
            log.debug("Starting new database transaction in this thread.");
            tx = getSession().beginTransaction();
            threadTransaction.set(tx);
        }
    }

    /**
     * Commit the database transaction.
     */
    public static void commitTransaction() throws HibernateException{
        // Would be written as a no-op in an EJB container with CMT
        Transaction tx = (Transaction) threadTransaction.get();
        try {
            if ( tx != null && !tx.wasCommitted()
                    && !tx.wasRolledBack() ) {
                log.debug("Committing database transaction of this thread.");
                tx.commit();
                    }
            threadTransaction.set(null);
        } catch (HibernateException ex) {
            rollbackTransaction();
            throw ex;
        }
    }

    /**
     * Rollback the database transaction.
     */
    public static void rollbackTransaction() throws HibernateException{
        // Would be written as a no-op in an EJB container with CMT (maybe setRollBackOnly...)
        Transaction tx = (Transaction) threadTransaction.get();
        try {
            threadTransaction.set(null);
            if ( tx != null && !tx.wasCommitted() && !tx.wasRolledBack() ) {
                log.debug("Tyring to rollback database transaction of this thread.");
                tx.rollback();
            }
        } finally {
            closeSession();
        }
    }

}
