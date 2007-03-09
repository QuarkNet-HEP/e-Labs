
package gov.fnal.elab.db;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.db.*;

//import net.sf.hibernate.Hibernate;
//import net.sf.hibernate.Session;
//import net.sf.hibernate.Transaction;
import java.util.*;

public class DemoQuery {

    public static void main(String[] args) throws Exception{
        System.out.println("DemoQuery running...");

        String pass = "junk";

            System.out.println("BEFORE SAVE");
            Login me = Login.findByUsername("fermigroup");
            Group temp = new Group();
            temp.setEndDate(new Date());
            temp.save();
            System.out.println("AFTER SAVE");
                HibernateUtil.commitTransaction();
                HibernateUtil.closeSession();
            /*
            if(me != null){
                System.out.println("username2: " + me.getUsername());
                for(Iterator j=me.getProjects().iterator(); j.hasNext(); ){
                    Project p = (Project)j.next();
                    System.out.println(" project2: " + p.getName());
                }
            }
            */

    }

}
