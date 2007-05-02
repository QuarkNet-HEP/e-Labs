/*
 * Created on Mar 12, 2007
 */
package gov.fnal.elab;

/**
 * Encapsulates information about a research group. Setting different values for
 * various properties available through this class will not cause them to be
 * comitted to whatever backend was used to build objects of this class.
 */
public class ElabGroup {
    private String id;
    private String name, year, city, state, school, teacher;
    private String namelc;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.namelc = name.toLowerCase();
    }

    public boolean isProfDev() {
        return namelc.startsWith("pd_");
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getTeacher() {
        return teacher;
    }

    public void setTeacher(String teacher) {
        this.teacher = teacher;
    }
}
