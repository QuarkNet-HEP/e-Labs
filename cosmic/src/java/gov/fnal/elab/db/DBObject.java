/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import gov.fnal.elab.util.ElabException;
import java.beans.*;
import java.util.*;
import java.lang.reflect.*;

import org.hibernate.*;
import org.hibernate.criterion.*;
import org.hibernate.type.Type;

/**
 * All DBObjects have the ability to save and load themselves to and from the
 * backend Hibernate database. There is also additional functionality for 
 * returning full XML strings of the data contained in a class. So for 
 * instance, one could populate a DBObject with data from the database, obtain
 * an XML string, and transform that string into html or other display formats.
 *
 * @author      Paul Nepywoda
 * @author      Eric Gilbert
 * @version     %I%, %G%
 */
public abstract class DBObject {

    /**
     * The set of object names which subclass DBObject and therefore are
     * valid for use as "Elab DBObjects"
     */
    protected static HashSet elabDBObject = null;


    /**
     * Return a Hibernate Session and start the Transaction
     */
    private final Session getSession() throws ElabException {
        Session session = null;
        try{
            session = HibernateUtil.getSession();
        } catch(HibernateException e){
            throw new ElabException("HibernateExeption when getting the current Session: ", e);
        }
        if(session == null){
            throw new ElabException("getSession() returned a null Session object");
        }
        else{
            try{
                //Transaction tx = session.beginTransaction();
                HibernateUtil.beginTransaction();

                return session;

            } catch(HibernateException e){
                throw new ElabException("Hibernate exception in transaction ", e);
            }
        }
    }

    /**
     * Save the data in this object to the backend Hibernate database.
     * @param flush If true, flush the persisted object immediately after it's
     *  been saved (so the database is synced without having to wait until
     *  HibernateFilter commits the transaction);
     * @see Session#save
     */
    public void save(boolean flush) throws ElabException {
        Session session = getSession();
        try{
            session.save(this);

            if(flush){
                session.flush();
                HibernateUtil.commitTransaction();
            }

        } catch(HibernateException e){
            throw new ElabException("Hibernate exception in transaction: ", e);
        }
    }

    /**
     * Create (SQL insert) a new entry in the database.
     * @see Session#save
     */
    public void save() throws ElabException{
        this.save(false);
    }

    /**
     * Update the data in this object to the backend Hibernate database.
     * @param flush If true, flush the persisted object immediately after it's
     *  been updated (so the database is synced without having to wait until
     *  HibernateFilter commits the transaction);
     * @see Session#save
     */
    public void update(boolean flush) throws ElabException {
        Session session = getSession();
        try{
            session.update(this);

            if(flush){
                HibernateUtil.commitTransaction();
                session.flush();
            }

        } catch(HibernateException e){
            throw new ElabException("Hibernate exception in transaction: ", e);
        }
    }

    /**
     * Update (SQL update) this Elab DBObject in the Hibernate database.
     * @see Session#update
     */
    public void update() throws ElabException{
        this.update(false);
    }

    /**
     * Delete the data in this object to the backend Hibernate database.
     * @param flush If true, flush the persisted object immediately after it's
     *  been deleted (so the database is synced without having to wait until
     *  HibernateFilter commits the transaction);
     * @see Session#delete
     */
    public void delete(boolean flush) throws ElabException {
        Session session = getSession();
        try{
            session.delete(this);

            if(flush){
                session.flush();
            }

        } catch(HibernateException e){
            throw new ElabException("Hibernate exception in transaction: ", e);
        }
    }

    /**
     * Delete (SQL delete) this Elab DBObject in the Hibernate database.
     * @see delete#boolean
     */
    public void delete() throws ElabException{
        this.delete(false);
    }


    /**
     * Returns whether this object has valid data within it.
     */
    public abstract boolean isValid();

    /**
     * Returns the id of this object.
     */
    public abstract int getId();

    /**
     * Returns the owners of this object.
     */
    public Set grabOwners(){
        return null;
    }

    /**
     * Get simple attributes of this object which a human can use to identify
     * it with.
     */
    public abstract String grabIdentifier();

    /**
     * Returns whether the Login is an owner of this object.
     * @param   login   The login to test for ownership
     */
    public boolean isOwner(Login login){
        Set owners = grabOwners();
        if(owners != null){
            return owners.contains(login);
        }
        else{
            return false;
        }
    }

    /**
     * Returns a complete xml string representing this class instance, 
     * WITHOUT including relationships ths instance has.
     * @see #toXML(boolean)
     */
    public String toXML() throws Exception {
        return toXML(false);
    }

    /**
     * Returns a complete xml string representing this class instance, with
     * or without including relationships the instance has.
     * @param   showRelationships   If true, includes relationship ids and 
     *  identifiers of this object as well
     * @see #toXMLAttributes
     * @see #toXMLRelationships
     */
    public String toXML(boolean showRelationships) throws Exception {
        String s = "<?xml version=\"1.0\"?>\n";

        s += "\t<elab>\n";

        s += toXMLClassList();

        String className = this.getClass().getName();
        String classNameDisplay = className.substring(className.lastIndexOf(".")+1); //only take the class name (not fully qualified)
        s += "\t<class name=\"" + classNameDisplay + "\">\n";

        s += toXMLAttributes(new HashSet());

        if(showRelationships){
            s += toXMLRelationships(new HashSet());
        }

        s += "\t</class>\n";
        s += "\t</elab>\n";

        return s;
    }

    /**
     * Returns an xml string with the xml element "classlist", containing
     * a list of all classes which are valid Elab DBObjects.
     * @see #elabDBObject
     */
    public static String toXMLClassList() {
        String s = "\t<classlist>\n";
        for(Iterator i=elabDBObject.iterator(); i.hasNext(); ){
            String className = (String)i.next();
            s += "\t\t<class name=\"" + className + "\" />\n";
        }
        s += "\t</classlist>\n";

        return s;
    }


    /**
     * Returns an xml string of the attributes contained in this class
     * instance.
     * @see #toXMLAttributes(HashSet)
     */
    public String toXMLAttributes() throws ElabException {
        return toXMLAttributes(new HashSet());
    }

    /**
     * Returns an xml string of the attributes contained in this class
     * instance NOT including variable names in the HashSet parameter.
     * @param   h   don't include these variable names in the xml string
     * @see Introspector#getBeanInfo
     * @see Method#invoke
     */
    public String toXMLAttributes(HashSet h) throws ElabException {
        String s = "";

        //Java Object types to output as XML attributes
        HashSet attributes = new HashSet();
        attributes.add("String");
        attributes.add("int");
        attributes.add("Date");
        attributes.add("boolean");

        //special cases for other variables and methods in the Java Beans
        h.add("valid");

        PropertyDescriptor[] pd;
        try{
            pd = Introspector.getBeanInfo(this.getClass()).getPropertyDescriptors();
        } catch(Exception e){
            throw new ElabException("While introspecting", e);
        }
        for(int i=0; i<pd.length; i++){
            Method m = pd[i].getReadMethod();
            if(m != null){
                String type = pd[i].getPropertyType().getName();
                type = type.substring(type.lastIndexOf(".")+1); //only take the class name (not fully qualified)

                //only create xml for descriptors which are attributes
                if(attributes.contains(type)){
                    String name = pd[i].getName();

                    //only create xml for attributes NOT in the set "h"
                    if(!h.contains(name)){
                        String display = name.replaceAll("([A-Z])", " $1");
                        display = display.substring(0,1).toUpperCase() + display.substring(1);
                        Object invoke = null;
                        try{
                            invoke = m.invoke(this, (Object[])null);
                        } catch(Exception e){
                            throw new ElabException("While invoking", e);
                        }
                        String value = "";
                        if(invoke != null){
                            value = invoke.toString();
                        }

                        //special handling for bad html data that's not valid xhtml
                        value = "<![CDATA[" + value + "]]>";

                        s += "\t\t\t<attr name=\"" + name + "\" display=\"" + display + "\">\n";

                        s += "\t\t\t\t<type>" + type + "</type>\n";
                        s += "\t\t\t\t<value>" + value + "</value>\n";

                        s += "\t\t\t</attr>\n";
                    }
                }
            }
        }

        return s;
    }

    /**
     * Returns an xml string of the relationships contained in this class
     * instance.
     * @see #toXMLRelationships(HashSet)
     */
    public String toXMLRelationships() throws ElabException {
        return toXMLRelationships(new HashSet());
    }

    /**
     * Returns an xml string of the relationships contained in this class
     * instance NOT including variable names in the HashSet parameter.
     * @param   h   don't include these variable names in the xml string
     * @see Introspector#getBeanInfo
     * @see Method#invoke
     */
    public String toXMLRelationships(HashSet h) throws ElabException {
        String s = "";

        //Java Object types to NOT output as XML relationships
        HashSet attributes = new HashSet();
        attributes.add("String");
        attributes.add("int");
        attributes.add("Date");
        attributes.add("boolean");
        attributes.add("Class");    //dunno why it grabs this otherwise...

        PropertyDescriptor[] pd;
        try{
            pd = Introspector.getBeanInfo(this.getClass()).getPropertyDescriptors();
        } catch(Exception e){
            throw new ElabException("While introspecting: ", e);
        }
        for(int i=0; i<pd.length; i++){
            Method m = pd[i].getReadMethod();
            if(m != null){
                String type = pd[i].getPropertyType().getName();
                type = type.substring(type.lastIndexOf(".")+1); //only take the class name (not fully qualified)

                //only create xml for descriptors which are NOT attributes
                if(!attributes.contains(type)){
                    String name = pd[i].getName();

                    //only create xml for relationships NOT in the set "h"
                    if(!h.contains(name)){
                        String display = name.replaceAll("([A-Z])", " $1");
                        display = display.substring(0,1).toUpperCase() + display.substring(1);

                        //get relationship type
                        String relType = "to_one";
                        if(type.equals("Set")){
                            relType = "to_many";
                        }

                        //FIXME "type" should really be "name" but we nave to name all the private Set vars the name of the Object they hold
                        s += "\t\t\t<relationship class=\"" + type + "\" type=\"" + relType + "\" display=\"" + display + "\">\n";

                        //get relationship ids
                        Object obj = null;
                        try{
                            obj = m.invoke(this, (Object[])null);
                        } catch(Exception e){
                            throw new ElabException("While invoking:", e);
                        }
                        if(obj != null){
                            if(obj instanceof Set){
                                for(Iterator j=((Set)obj).iterator(); j.hasNext(); ){
                                    DBObject dbobj = (DBObject)j.next();
                                    int id = dbobj.getId();
                                    String className = dbobj.getClass().getName();
                                    className = className.substring(className.lastIndexOf(".")+1);

                                    s += "\t\t\t\t<rel id=\""+ id + "\" class=\"" + className + "\"><![CDATA[" + dbobj.grabIdentifier() + "]]></rel>\n";
                                }
                            }
                            else if(isElabDBObject(type)){
                                DBObject dbobj = (DBObject)obj;
                                String className = dbobj.getClass().getName();
                                className = className.substring(className.lastIndexOf(".")+1);
                                s += "\t\t\t\t<rel id=\""+ dbobj.getId() + "\" class=\"" + className + "\"><![CDATA[" + dbobj.grabIdentifier() + "]]></rel>\n";
                            }
                            else{
                                s += "\t\t\t\t<rel id=\"0\" class=\"unknown object\" />\n";
                            }
                        }
                        else{
                            //s += "\t\t\t\t<empty></empty>\n";
                        }

                        s += "\t\t\t</relationship>\n";
                    }
                }
            }
        }

        return s;
    }

    /**
     * Takes a list of DBobjects and returns a complete xml string of their
     * attributes, without including relatinships.
     * @param   list    list of DBObjects
     * @see #toXMLList(List, boolean)
     */
    public static String toXMLList(java.util.List list) throws ElabException {
        return toXMLList(list, false);
    }

    /**
     * Takes a list of DBobjects and returns a complete xml string of their
     * attributes, with or without including relatinships.
     * @param   list    list of DBObjects
     * @param   showRelationships   if true, includes relationships in this
     *  class as well
     *  @see #toXMLAttributes
     *  @see #toXMLRelationships
     */
    public static String toXMLList(java.util.List list, boolean showRelationships) throws ElabException {
        String s = "<?xml version=\"1.0\"?>\n";

        s += "\t<elab>\n";

        s += toXMLClassList();

        for(Iterator i=list.iterator(); i.hasNext(); ){
            DBObject obj = (DBObject)i.next();

            String className = obj.getClass().getName();
            String classNameDisplay = className.substring(className.lastIndexOf(".")+1); //only take the class name (not fully qualified)
            s += "\t<class name=\"" + classNameDisplay + "\">\n";
            s += obj.toXMLAttributes();

            if(showRelationships){
                s += obj.toXMLRelationships();
            }

            s += "\t\t</class>\n";
        }

        s += "\t</elab>\n";
        
        return s;
    }

    /**
     * Takes the current instance of this DBObject, iterates through the
     * {@link PropertyDescriptor}s and attempts to map variables from the 
     * {@link javax.servlet.http.HttpServletRequest} to variables of the same name in the instance.
     * @param   request the current HttpServletRequest to fetch parameters from
     * @see Introspector#getBeanInfo
     * @see Method#invoke
     */
    public void setFromParam(javax.servlet.http.HttpServletRequest request) throws ElabException{
        
        //Java Object types to set in the DBObject instance
        HashSet attributes = new HashSet();
        attributes.add("String");
        attributes.add("int");
        attributes.add("boolean");

        PropertyDescriptor[] pd;
        try{
            pd = Introspector.getBeanInfo(this.getClass()).getPropertyDescriptors();
        } catch(Exception e){
            throw new ElabException("While introspecting: ", e);
        }
        for(int i=0; i<pd.length; i++){
            Method m = pd[i].getWriteMethod();
            //if we found a setter method
            if(m != null){
                String type = pd[i].getPropertyType().getName();
                type = type.substring(type.lastIndexOf(".")+1); //only take the class name (not fully qualified)

                //only set objects which are attributes we want
                if(attributes.contains(type)){
                    String name = pd[i].getName();
                    String paramValue = request.getParameter(name);

                    try{
                        if(paramValue != null){
                            if(type.equals("String")){
                                m.invoke(this, new Object[] {paramValue});   //call the setter method
                            }
                            else if(type.equals("int")){
                                m.invoke(this, new Object[] {paramValue});   //call the setter method
                            }
                            else if(type.equals("boolean")){
                                Boolean b = Boolean.valueOf(paramValue); //returns true if paramValue == "true" case-insensitive
                                m.invoke(this, new Object[] {b});   //call the setter method
                            }
                        }
                    } catch(Exception e){
                        throw new ElabException("While invoking: ", e);
                    }
                }
            }
        }
    }


    /**
     * Returns all data objects in the database of a certain name.
     * @param   objectName  the Elab DBobject to list
     * @see #findAll(String, int, int)
     */
    public static List findAll(String objectName) throws ElabException{
        return findAll(objectName, 0, -1);
    }
            
    /**
     * Returns all data objects in the database of a certain name, 
     * starting at the specified index.
     * @param   objectName  the Elab DBobject to list
     * @param   firstResult starting at 0, the position in the result set to
     *  start listing from
     * @see #findAll(String, int, int)
     */
    public static List findAll(String objectName, int firstResult) throws ElabException{
        return findAll(objectName, firstResult, -1);
    }

    /**
     * Returns all data objects in the database of a certain name,
     * with specific criteria placed on the attributes of the results,
     * starting at the specified index and bounding the results returned.
     * @param   objectName  the Elab DBobject to list
     * @param   firstResult starting at 0, the position in the result set to
     *  start listing from
     * @param   maxResults  the maximum number of results to return. If set to
     *  -1, returns an unbounded list of results
     * @see #getCriteriaObject(String, int, int)
     */
    public static List findAll(String objectName, int firstResult, int maxResults) throws ElabException{
        Criteria crit = getCriteriaObject(objectName);
        try{
            return crit.list();
        } catch(Exception e){
            throw new ElabException("in findAll", e);
        }
    }

    /**
     * Find and return a data object by matching the "name" attribute in the
     * class. Returns the first object matched even if there's more than 1
     * object with this value as a 'name' attribute.
     * @param   objectName the Elab DBObject to find
     * @param   name    the value of the name attribute to match
     * @see #getCriteriaObject(String, int, int)
     */
    public static DBObject findByName(String objectName, String name) throws ElabException{
        Criteria crit = getCriteriaObject(objectName);
        crit.add(org.hibernate.criterion.Expression.eq("name", name));
        try{
            if (crit.list() == null || crit.list().isEmpty())
                return null;
            return (DBObject) crit.list().iterator().next();
        } catch(Exception e){
            throw new ElabException("in findByName", e);
        }
        
        /*
         * 1/10/06 commented...since I think Hao put this in and I don't know why...
         *
        java.util.List results;
        try{
            Session session = HibernateUtil.getSession();
            HibernateUtil.beginTransaction();
            results = session.find(
                    "from " + objectName + " as " + objectName + 
                    " where name = ?",
                    name,
                    Hibernate.STRING
                    );
        } catch(Exception e){
            throw new ElabException(e.getMessage());
        }

        if(results != null && results.size()>0){
            return (DBObject)results.get(0);
        }
        return null;
        */

    }

    /**
     * Return a Criteria object for a certain {@link #elabDBObject}. Used to
     * add additional criteria for the database query.
     * @param   objectName the {@link #elabDBObject} to list
     * @see #getCriteriaObject(String, int, int)
     */
    public static Criteria getCriteriaObject(String objectName) throws ElabException{
        return getCriteriaObject(objectName, 0, -1);
    }

    /**
     * Return a Criteria object for a certain {@link #elabDBObject}. Used to
     * add additional criteria for the database query. Start the listing at
     * the specified index.
     * @param   objectName the {@link #elabDBObject} to list
     * @param   firstResult starting at 0, the position in the result set to
     *  start listing from
     * @param   maxResults  the maximum number of results to return. If set to
     *  -1, returns an unbounded list of results
     * @see #getCriteriaObject(String, int, int)
     */
    public static Criteria getCriteriaObject(String objectName, int firstResult) throws ElabException{
        return getCriteriaObject(objectName, firstResult, -1);
    }

    /**
     * Return a Criteria object for a certain {@link #elabDBObject}. Used to
     * add additional criteria for the database query. Start the listing at
     * the specified index and limit the result set to the specified number.
     * <br/><br/>
     * Good pages for the Hibernate Query API:<br/>
     * <a href="http://www.hibernate.org/hib_docs/reference/en/html/querycriteria.html">http://www.hibernate.org/hib_docs/reference/en/html/querycriteria.html</a><br/>
     * <a href="http://www.jroller.com/page/wakaleo/?anchor=the_hibernate_criteria_api">http://www.jroller.com/page/wakaleo/?anchor=the_hibernate_criteria_api</a><br/>
     * @param   objectName the {@link #elabDBObject} to list
     * @param   firstResult starting at 0, the position in the result set to
     *  start listing from
     * @param   maxResults  the maximum number of results to return. If set to
     *  -1, returns an unbounded list of results
     * @see Criteria
     */
    public static Criteria getCriteriaObject(String objectName, int firstResult, int maxResults) throws ElabException{
        if(isElabDBObject(objectName) == false){
            throw new ElabException(objectName + " is not an Elab DBObject");
        }

        if(firstResult < 0){
            throw new ElabException("firstResult must be >= 0");
        }
        if(maxResults < -1 || maxResults == 0){
            throw new ElabException("maxResults must be > 0, or -1 for unbounded");
        }

        Criteria crit = null;
        Session session = null;
		try {
            session = HibernateUtil.getSession();
            HibernateUtil.beginTransaction();

            crit = session.createCriteria(Class.forName("gov.fnal.elab.db." + objectName));

            /* Set first result and maximum returned results */
            crit.setFirstResult(firstResult);
            if(maxResults > 0){
                crit.setMaxResults(maxResults);
            }

        } catch(Exception e){
            throw new ElabException("in getCriteriaObject", e);
        }

        return crit;
    }


    /**
     * Find and return a data object by id.
     * @param   obj the Elab DBObject to find
     * @param   id  the id of the object in the database
     * @see Session#load
     */
    public static DBObject findById(String obj, int id) throws ElabException{
        if(!isElabDBObject(obj)){
            throw new ElabException("Object '" + obj + "' isn't an elab DBObject!");
        }

        DBObject object = newElabDBObject(obj);

        DBObject returnObject = null;
        try{
            returnObject = (DBObject) HibernateUtil.getSession().load(object.getClass(), new Integer(id));
        } catch(Exception e){
            throw new ElabException("Exception while loading item " + id, e);
        }

        return returnObject;
    }

    /**
     * Find and return a data object by id.
     * @param   obj the Elab DBObject to find
     * @param   id  the id of the object in the database
     * @see #findById(String, int)
     */
    public static DBObject findById(String obj, String id) throws ElabException{
        if(!id.matches("^[0-9]+$")){
            throw new ElabException("Id '" + id + "' isn't a number!");
        }

        int itemId = Integer.parseInt(id);
        
        return findById(obj, itemId);
    }


    /**
     * Check to see if this name is valid as an Elab DBObject name.
     * @param   objectName  the name to check
     * @see #elabDBObject
     */
    public static boolean isElabDBObject(String objectName) throws ElabException {
        setupElabDBObject();
        return elabDBObject.contains(objectName);
    }

    /**
     * Return a new instance of a certain Elab DBObject
     * @param   objectName  the Elab DBObject name you want a new instance of
     * @see Class#forName
     */
    public static DBObject newElabDBObject(String objectName) throws ElabException {
        if(isElabDBObject(objectName)){
            try{
                Class c = Class.forName("gov.fnal.elab.db." + objectName);

                return (DBObject)c.newInstance();
            } catch(Exception e){
                throw new ElabException("in newElabDBObject", e);
            }
        }
        else{
            return null;
        }
    }

    /*
     * Set the valid Elab DBObjects HashSet if they haven't been set yet.
     * @see #elabDBObject
     */
    protected static void setupElabDBObject(){
        if(elabDBObject == null){
            elabDBObject = new HashSet();
            elabDBObject.add("Login");
            elabDBObject.add("Manager");
            elabDBObject.add("Group");
            elabDBObject.add("Institution");
            elabDBObject.add("Use");
            elabDBObject.add("Job");
            elabDBObject.add("Comment");
            elabDBObject.add("FAQ");
            elabDBObject.add("News");
            elabDBObject.add("Glossary");
            elabDBObject.add("Feedback");
            elabDBObject.add("LogEntry");
            elabDBObject.add("Milestone");
            elabDBObject.add("MilestonePlacement");
            elabDBObject.add("MilestoneSet");
            elabDBObject.add("Project");
            elabDBObject.add("Test");
            elabDBObject.add("ResponseSheet");
            elabDBObject.add("Question");
            elabDBObject.add("Response");
            elabDBObject.add("MultipleChoice");
            elabDBObject.add("Choice");
            elabDBObject.add("Essay");
            elabDBObject.add("MultipleChoiceResponse");
            elabDBObject.add("ProjectProperty");
            elabDBObject.add("PropertyName");
            elabDBObject.add("UserPropertyName");
            elabDBObject.add("ManagerPropertyName");
            elabDBObject.add("PropertyValue");
            elabDBObject.add("Permissions");
            elabDBObject.add("PermissionSet");
        }
    }

}
