/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import java.text.*;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.db.*;

/**
 * DemoUserDB shows what can be done with the basic user database modeling classes.
 * Especially note the save() function, which can be applied to all objects that subclass
 * {@link DBObject}.
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class DemoUserDB {

    public static void main(String[] args) throws ElabException {
        DateFormat f = new SimpleDateFormat("yyyy-DD-dd");
        Set s = new HashSet();
        
        //eric
        Login eric = new Login();
        eric.setUsername("eric");
        eric.setPassword("junk");
        eric.setFirstName("Eric");
        eric.setLastName("Gilbert");
        eric.setEmail("nowhere@here.there");
        eric.setIsFirstTimeLoggingIn(true);
        eric.setIsTestAccount(false);

        /*
        //paul
        Manager paul = new Manager();
        paul.setUsername("paul");
        paul.setPassword("junk");
        paul.setFirstName("Paul");
        paul.setLastName("Nepywoda");
        paul.setEmail("nowhere@here.there");
        paul.setIsFirstTimeLoggingIn(false);
        paul.setIsTestAccount(true);
        paul.setPhoneNumber("555-9999");
        
        
        //logentry
        LogEntry log = new LogEntry();
        LogEntry log2 = new LogEntry();
        LogEntry log3 = new LogEntry();
        log.setBody("this is a log entry");
        log.setBeenRead(false);
        book.addEntry(log);
        log2.setBody("this is a log entry 2");
        log2.setBeenRead(false);
        book.addEntry(log2);
        log3.setBody("this is a log entry 3");
        book.addEntry(log3);

        Set managers = new HashSet();
        managers.add(paul);
        eric.setManagers(managers);

        

        //institution
        Institution phome = new Institution();
        phome.setName("Paul's Home");
        phome.setDepartment("Department of all things good");
        phome.setPhoneNumber("555-6666");
        phome.setPhoneNumber2("555-7777");
        phome.setFaxNumber("555-8888");

        paul.setInstitution(phome);
        
        //project
        Project cosmic = new Project();
        cosmic.setName("cosmic project");
        cosmic.setDescription("stuff goes here");
        cosmic.setAudience("people");
        cosmic.setSubjectMatter("subject stuff");
        Date d1 = new Date();
        Date d2 = new Date();
        try{
            d1 = f.parse("2005-06-15");
            d2 = f.parse("2005-06-16");
        } catch (Exception e){}
        cosmic.setStartDate(d1);
        cosmic.setEndDate(d2);

        book.setOwner(eric);
        book.setProject(cosmic);

        eric.addProject(cosmic);
        paul.addProject(cosmic);

        //Persons
        Person ericP = new Person();
        Person paulP = new Person();
        ericP.setFirstName("Eric");
        paulP.setFirstName("Paul");
        Set peeps1 = new HashSet();
        peeps1.add(ericP);
        peeps1.add(paulP);
        eric.setPersons(peeps1);

        */
        eric.save();
        try{
            HibernateUtil.commitTransaction();
            HibernateUtil.closeSession();
        }catch(Exception e){
            System.out.println(e + " ");
        }

//
//        //milestone
//        Milestone mile = new Milestone();
//        Milestone mile2 = new Milestone();
//        mile.setName("CS");
//        mile.setDescription("What every physics major here should be switching to.");
//        mile.setSection("A");
//        mile.setSectionId("1");
//        mile.setType("everyone");
//        mile2.setName("Math");
//        mile2.setDescription("Also another good major. Why are you studying physics!?");
//        mile2.setType("students");
//
//
//        //group
//        User group = new User();
//        group.setPassword("thisisneeded");
//        group.setUsername("our_group");
//
//
//
//        //relationships
//        eric.addProject(cosmic);  //FIXME not added to users_projects
//        paul.addProject(cosmic);
//        ((Manager)paul).setProjectContact(cosmic);
//        paul.setInstitution(phome);
//        mile.setProject(cosmic);
//        mile2.setProject(cosmic);
//        mile.save();    //I'm almost sure now that cascade is used for calling the save method on classes, and NOT used to set foreign key references for you
//        mile2.save();
//        book.setProject(cosmic);
//        paul.setLogbook(book);
//        //book.setOwner(paul);
//        s = new HashSet();  //either setLogEntries or save log,log2,log3 individually. But setLogbook NEEDS to be here for the relationship to save
//        s.add(log);
//        s.add(log2);
//        s.add(log3);
//        book.setLogEntries(s);
//        //log.setLogbook(book);
//        //log.setMaker(paul);
//        //log.setMilestone(mile);
//        //log2.setLogbook(book);
//        //log2.setMaker(eric);
//        //log2.setMilestone(mile2);
//        //log3.setLogbook(book);
//        book.setProject(cosmic);
//        //paul.setRole(role2);  //doesn't work
//        //eric.setRole(role2);  //doesn't work
//        paul.setRole(role2);
//        eric.setRole(role);
//        //role.save();
//        //role2.save();
//        eric.setInstitution(phome);
//        Set users_group = new HashSet();
//        users_group.add(nick);
//        users_group.add(hao);
//        paul.setPersons(users_group);
//
//
//        //cosmic.save();
//        //book.save();
//        //mile.save();
//        //mile2.save();
//        eric.save();
//        paul.save();
//        //group.save();
//
//
//        //user relationships to project
//        //s = new HashSet();
//        //s.add(cosmic);
//        //eric.setProjects(s);
//        //paul.setProjects(s);
//
//        // cascading save-update 
//        //paul.save();
//        //eric.save();
//
//
//        //get some stuff
//        //logbook entries
//        //Logbook lb = group.getLogbook();
//        //Set ss = lb.getLogEntries();
//        //if(ss != null){
//        //    for(Iterator i=ss.iterator(); i.hasNext(); ){
//        //        LogEntry le = (LogEntry)i.next();
//        //        System.out.println("logentry: " + le.getText() + " on date: " + le.getDateEntered());
//        //    }
//        //}
//        //else{
//        //    System.out.println("no logentries for group");
//        //}
//
//        ////users in projects
//        //ss = cosmic.getUsers();
//        //if(ss != null){
//        //    for(Iterator i=ss.iterator(); i.hasNext(); ){
//        //        User u = (User)i.next();
//        //        System.out.println("user in cosmic: " + u.getName());
//        //    }
//        //}
//        //else{
//        //    System.out.println("no users in cosmic");
//        //}
//
//        ////role
//        //Role rr = paul.getRole();
//        //if(rr != null){
//        //    System.out.println("paul's role: can comment? " + rr.getCanComment() + " id:" + rr.getId());
//        //}
//        //else{
//        //    System.out.println("paul's role is NULL");
//        //}
//        //Role rr2 = eric.getRole();
//        //if(rr2 != null){
//        //    System.out.println("paul's role: can comment? " + rr2.getCanComment() + " id:" + rr2.getId());
//        //}
//        //else{
//        //    System.out.println("paul's role is NULL");
//        //}
//
    }
}
