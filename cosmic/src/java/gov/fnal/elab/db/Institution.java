/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * Institution is capable of modeling many of the institutions that may be 
 * involved in an e-Lab, such as high schools, universities and research labs. 
 * Only staff has permission to create Institutions.
 *
 * @hibernate.class
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Institution extends DBObject {

    private int id;
    private String name;
    private String department;
    private String street;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    private String phoneNumber;
    private String phoneNumber2;
    private String faxNumber;
    private Set logins;

    /**
     * Empty constructor for Hibernate.
     */
    public Institution() {}
    
    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Only managers part of the Institution own it *
     */
    public Set grabOwners(){
        Set owners = new HashSet();
        for(Iterator i=getLogins().iterator(); i.hasNext(); ){
            Login login = (Login)i.next();
            if(login instanceof Manager){
                owners.add(login);
            }
        }
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(name != null){
            s += name + " ";
        }
        if(department != null){
            s += department + " ";
        }
        return s;
    }


    /**
     * @hibernate.id
     *      column="id"
     *      generator-class="hilo"
     *      unsaved-value="null"
     * @return The id of this institution.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    /**
     * @hibernate.property
     *      column="name"
     * @return The name of this institution.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.property
     *      column="deparment"
     * @return The name of the deparment in this instution that we care about.
     */
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    /**
     * @hibernate.property
     *      column="street"
     * @return The street name.
     */
    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }

    /**
     * @hibernate.property
     *      column="city"
     * @return The city name.
     */
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    /**
     * @hibernate.property
     *      column="state"
     * @return The state name.
     */
    public String getState() { return state; } 
    public void setState(String state) { this.state = state; }

    /**
     * @hibernate.property
     *      column="zip_code"
     * @return The zip code.
     */
    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }

    /**
     * @hibernate.property
     *      column="country"
     * @return The country.
     */
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    /**
     * @hibernate.property
     *      column="phone_number"
     * @return The phone number of this institution.
     */
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    /**
     * @hibernate.property
     *      column="phone_number2"
     * @return The second phone number of this institution.
     */
    public String getPhoneNumber2() { return phoneNumber2; }
    public void setPhoneNumber2(String phoneNumber2) { this.phoneNumber2 = phoneNumber2; }

    /**
     * @hibernate.property
     *      column="fax_number"
     * @return The fax number at this institution.
     */
    public String getFaxNumber() { return faxNumber; }
    public void setFaxNumber(String faxNumber) { this.faxNumber = faxNumber; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Login"
     * @hibernate.collection-key
     *      column="fk_institution"
     * @return The logins that belong to this institution.
     */
    public Set getLogins() { return logins; }
    public void setLogins(Set logins) { this.logins = logins; }
}
