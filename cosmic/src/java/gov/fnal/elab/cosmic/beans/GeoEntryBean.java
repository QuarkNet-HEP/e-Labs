package gov.fnal.elab.cosmic.beans;

import java.io.*;
import java.util.*;
import java.util.regex.*;

import gov.fnal.elab.util.*;
import gov.fnal.elab.cosmic.Geometry;

//made with: ./bean_skeleton.pl --scalar "stackedState latitude longitude altitude chan1X chan1Y chan1Z chan1Area chan1CableLength chan2X chan2Y chan2Z chan2Area chan2CableLength chan3X chan3Y chan3Z chan3Area chan3CableLength chan4X chan4Y chan4Z chan4Area chan4CableLength" --list "" GeoEntryBean

public class GeoEntryBean implements Serializable {

    private String julianDay = null;
    private String date = null;
    private String detectorID = null;
    private String stackedState = null;
    private String latitude = null;
    private String longitude = null;
    private String altitude = null;
    private String chan1X = null;
    private String chan1Y = null;
    private String chan1Z = null;
    private String chan1Area = null;
    private String chan1CableLength = null;
    private String chan2X = null;
    private String chan2Y = null;
    private String chan2Z = null;
    private String chan2Area = null;
    private String chan2CableLength = null;
    private String chan3X = null;
    private String chan3Y = null;
    private String chan3Z = null;
    private String chan3Area = null;
    private String chan3CableLength = null;
    private String chan4X = null;
    private String chan4Y = null;
    private String chan4Z = null;
    private String chan4Area = null;
    private String chan4CableLength = null;

    /**
     * Constructor. It resets the bean to its initial state.
     *
     */
    public GeoEntryBean(){
        this.reset();
    }

    /**
     * The Julian day and date stuff is rather confusing. If you set one it changes
     * the other, since they should be reflections of one another. So this method has
     * the effect of changing the Julian day and the Gregorian date.
     *
     * @param s     The string representing the double version of the Julian day.
     */
    public void setJulianDay(String s){
        julianDay = s;
        if (julianDay != null && !julianDay.equals("null")) {
            int [] tmp = Geometry.jdToGregorian(Double.parseDouble(julianDay));
            GregorianCalendar gc = new GregorianCalendar(
                tmp[2], tmp[1] - 1, tmp[0], tmp[3], tmp[4]);
            int minRounded = Math.round((float)tmp[5]/60);     //round seconds to nearest minute
            gc.add(Calendar.MINUTE, minRounded);
            date = gc.getTime().toString();
        }
    }

    public String getJulianDay(){
        return julianDay;
    }

    public Double getInvertedJulianDay() {
        return new Double(1 / ((new Double(julianDay)).doubleValue()));
    }

    /**
     * This method has many of the same properties as the setter for Julian day.
     * This changes the Gregorian day as well as the Julian day.
     *
     * @param s     The string representation of the Gregorian date.
     */
    public void setDate(String s){
        date = s;
        if (date != null && !date.equals("null")) { 
            GregorianCalendar gc = new GregorianCalendar();
            gc.setTime(new Date(date));
            julianDay = 
                (new Double(
                    Geometry.gregorianToJD(
                        gc.get(Calendar.DATE),
                        gc.get(Calendar.MONTH) + 1,
                        gc.get(Calendar.YEAR),
                        gc.get(Calendar.HOUR_OF_DAY),
                        gc.get(Calendar.MINUTE)))).toString();
        }
    }

    public String getDate(){
        return date;
    }

    public void setDetectorID(String s) {
        detectorID = s;
    }

    public String getDetectorID() {
        return detectorID;
    }

    public void setStackedState(String s){
        stackedState = s;
    }

    public String getStackedState(){
        return stackedState;
    }

    public void setLatitude(String s){
        latitude = s;
    }

    /**
     * Returns the latitude in a form that is acceptable for the geometry file.
     * Strangely, we do not present this value to the user in the same way that 
     * we store it.
     *
     * @return      The latitude in the correct form for the geo file.
     */
    public String breakUpLatitude() {
        String latArray[] = getFormattedLatitude().split("\\.");
        String lat3 = latArray[1];
        String latArray2[] = latArray[0].split(":");
        String lat1 = latArray2[0];
        String lat2 = latArray2[1];

        return lat1 + "." + lat2 + "." + lat3;
    }

    public String getLatitude(){
        return latitude;
    }

    /**
     * Get the latitude in form ready for and HTML form.
     *
     * @return      The string ready for an HTML form.
     */
    public String getFormLatitude() {
        if (latitude.endsWith("N") || latitude.endsWith("S")) return latitude;
        if (latitude.startsWith("-")) return latitude.substring(1) + " S";
        else return latitude + " N";
    }

    public String getFormattedLatitude() {
        if (latitude.matches("-?\\d{1,3}:\\d{1,3}\\.\\d{1,4}")) return latitude;
        else if (latitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (N|S)")) {
            char direction = latitude.charAt(latitude.length() - 1);
            String tmp = latitude.substring(0, latitude.length() - 2);
            if (direction == 'N')
                return tmp;
            else 
                return "-" + tmp;
        }
        return "";
    }

    public String breakUpLongitude() {
        String longArray[] = getFormattedLongitude().split("\\.");
        String long3 = longArray[1];
        String longArray2[] = longArray[0].split(":");
        String long1 = longArray2[0];
        String long2 = longArray2[1];

        return long1 + "." + long2 + "." + long3;
    }
    
    public void setLongitude(String s){
        longitude = s;
    }

    public String getLongitude(){
        return longitude;
    }

    public String getFormLongitude() {
        if (longitude.endsWith("E") || longitude.endsWith("W")) return longitude;
        if (longitude.startsWith("-")) return longitude.substring(1) + " W";
        else return longitude + " E";
    }

    public String getFormattedLongitude() {
        if (longitude.matches("-?\\d{1,3}:\\d{1,3}\\.\\d{1,4}")) return longitude;
        else if (longitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (E|W)")) {
            char direction = longitude.charAt(longitude.length() - 1);
            String tmp = longitude.substring(0, longitude.length() - 2);
            if (direction == 'E')
                return tmp;
            else 
                return "-" + tmp;
        }
        return "";
    }

    public void setAltitude(String s){
        altitude = s;
    }

    public String getAltitude(){
        return altitude;
    }

    public void setChan1X(String s){
        chan1X = s;
    }

    public String getChan1X(){
        return chan1X;
    }

    public void setChan1Y(String s){
        chan1Y = s;
    }

    public String getChan1Y(){
        return chan1Y;
    }

    public void setChan1Z(String s){
        chan1Z = s;
    }

    public String getChan1Z(){
        return chan1Z;
    }

    public String getFormattedChan1Area() {
        double chan1A = Double.valueOf(chan1Area).doubleValue();
        return Double.toString(chan1A/100/100);
    }

    public void setChan1Area(String s){
        chan1Area = s;
    }

    public String getChan1Area(){
        return chan1Area;
    }

    public void setChan1CableLength(String s){
        chan1CableLength = s;
    }

    public String getChan1CableLength(){
        return chan1CableLength;
    }

    public void setChan2X(String s){
        chan2X = s;
    }

    public String getChan2X(){
        return chan2X;
    }

    public void setChan2Y(String s){
        chan2Y = s;
    }

    public String getChan2Y(){
        return chan2Y;
    }

    public void setChan2Z(String s){
        chan2Z = s;
    }

    public String getChan2Z(){
        return chan2Z;
    }

    public String getFormattedChan2Area() {
        double chan2A = Double.valueOf(chan2Area).doubleValue();
        return Double.toString(chan2A/100/100);
    }

    public void setChan2Area(String s){
        chan2Area = s;
    }

    public String getChan2Area(){
        return chan2Area;
    }

    public void setChan2CableLength(String s){
        chan2CableLength = s;
    }

    public String getChan2CableLength(){
        return chan2CableLength;
    }

    public void setChan3X(String s){
        chan3X = s;
    }

    public String getChan3X(){
        return chan3X;
    }

    public void setChan3Y(String s){
        chan3Y = s;
    }

    public String getChan3Y(){
        return chan3Y;
    }

    public void setChan3Z(String s){
        chan3Z = s;
    }

    public String getChan3Z(){
        return chan3Z;
    }
    
    public String getFormattedChan3Area() {
        double chan3A = Double.valueOf(chan3Area).doubleValue();
        return Double.toString(chan3A/100/100);
    }

    public void setChan3Area(String s){
        chan3Area = s;
    }

    public String getChan3Area(){
        return chan3Area;
    }

    public void setChan3CableLength(String s){
        chan3CableLength = s;
    }

    public String getChan3CableLength(){
        return chan3CableLength;
    }

    public void setChan4X(String s){
        chan4X = s;
    }

    public String getChan4X(){
        return chan4X;
    }

    public void setChan4Y(String s){
        chan4Y = s;
    }

    public String getChan4Y(){
        return chan4Y;
    }

    public void setChan4Z(String s){
        chan4Z = s;
    }

    public String getChan4Z(){
        return chan4Z;
    }
    
    public String getFormattedChan4Area() {
        double chan4A = Double.valueOf(chan4Area).doubleValue();
        return Double.toString(chan4A/100/100);
    }

    public void setChan4Area(String s){
        chan4Area = s;
    }

    public String getChan4Area(){
        return chan4Area;
    }

    public void setChan4CableLength(String s){
        chan4CableLength = s;
    }

    public String getChan4CableLength(){
        return chan4CableLength;
    }

    //testing if the input is valid (scalar)
    public boolean isJulianDayValid(){
        boolean isValid = false;
        if(julianDay.matches(".*")){
            isValid = true;
        }
        return isValid;
    }
    
    public boolean isDateValid(){
        boolean isValid = false;
        if(date.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isStackedStateValid(){
        boolean isValid = false;
        if(stackedState.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isLatitudeValid(){
        boolean isValid = false;
        if(latitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (N|S)")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isLongitudeValid(){
        boolean isValid = false;
        if(longitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (E|W)")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isAltitudeValid(){
        boolean isValid = false;
        if(altitude.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan1XValid(){
        boolean isValid = false;
        if(chan1X.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan1YValid(){
        boolean isValid = false;
        if(chan1Y.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan1ZValid(){
        boolean isValid = false;
        if(chan1Z.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan1AreaValid(){
        boolean isValid = false;
        if(chan1Area.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan1CableLengthValid(){
        boolean isValid = false;
        if(chan1CableLength.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan2XValid(){
        boolean isValid = false;
        if(chan2X.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan2YValid(){
        boolean isValid = false;
        if(chan2Y.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan2ZValid(){
        boolean isValid = false;
        if(chan2Z.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan2AreaValid(){
        boolean isValid = false;
        if(chan2Area.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan2CableLengthValid(){
        boolean isValid = false;
        if(chan2CableLength.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan3XValid(){
        boolean isValid = false;
        if(chan3X.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan3YValid(){
        boolean isValid = false;
        if(chan3Y.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan3ZValid(){
        boolean isValid = false;
        if(chan3Z.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan3AreaValid(){
        boolean isValid = false;
        if(chan3Area.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan3CableLengthValid(){
        boolean isValid = false;
        if(chan3CableLength.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan4XValid(){
        boolean isValid = false;
        if(chan4X.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan4YValid(){
        boolean isValid = false;
        if(chan4Y.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan4ZValid(){
        boolean isValid = false;
        if(chan4Z.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan4AreaValid(){
        boolean isValid = false;
        if(chan4Area.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    public boolean isChan4CableLengthValid(){
        boolean isValid = false;
        if(chan4CableLength.matches(".*")){
            isValid = true;
        }
        return isValid;
    }

    //returns true is every key value is valid
    public boolean isValid(){
        java.util.List badkeys = this.getInvalidKeys();
        return badkeys.size() > 0 ? false : true;
    }

    //get a List of invalid keys
    public java.util.List getInvalidKeys(){
        java.util.List badkeys = new java.util.ArrayList();
        if(!isJulianDayValid()){
            badkeys.add("julianDay");
        }
        if(!isDateValid()){
            badkeys.add("date");
        }
        if(!isStackedStateValid()){
            badkeys.add("stackedState");
        }
        if(!isLatitudeValid()){
            badkeys.add("latitude");
        }
        if(!isLongitudeValid()){
            badkeys.add("longitude");
        }
        if(!isAltitudeValid()){
            badkeys.add("altitude");
        }
        if(!isChan1XValid()){
            badkeys.add("chan1X");
        }
        if(!isChan1YValid()){
            badkeys.add("chan1Y");
        }
        if(!isChan1ZValid()){
            badkeys.add("chan1Z");
        }
        if(!isChan1AreaValid()){
            badkeys.add("chan1Area");
        }
        if(!isChan1CableLengthValid()){
            badkeys.add("chan1CableLength");
        }
        if(!isChan2XValid()){
            badkeys.add("chan2X");
        }
        if(!isChan2YValid()){
            badkeys.add("chan2Y");
        }
        if(!isChan2ZValid()){
            badkeys.add("chan2Z");
        }
        if(!isChan2AreaValid()){
            badkeys.add("chan2Area");
        }
        if(!isChan2CableLengthValid()){
            badkeys.add("chan2CableLength");
        }
        if(!isChan3XValid()){
            badkeys.add("chan3X");
        }
        if(!isChan3YValid()){
            badkeys.add("chan3Y");
        }
        if(!isChan3ZValid()){
            badkeys.add("chan3Z");
        }
        if(!isChan3AreaValid()){
            badkeys.add("chan3Area");
        }
        if(!isChan3CableLengthValid()){
            badkeys.add("chan3CableLength");
        }
        if(!isChan4XValid()){
            badkeys.add("chan4X");
        }
        if(!isChan4YValid()){
            badkeys.add("chan4Y");
        }
        if(!isChan4ZValid()){
            badkeys.add("chan4Z");
        }
        if(!isChan4AreaValid()){
            badkeys.add("chan4Area");
        }
        if(!isChan4CableLengthValid()){
            badkeys.add("chan4CableLength");
        }
        return badkeys;
    }

    /*
     * Tests whether this GeoEntryBean is equal to another GeoEntryBean.
     *
     * @return boolean  Whether they are equal.
     */
    public boolean equals(GeoEntryBean geb) {
        return 
            julianDay != null && geb.getJulianDay() != null &&
            julianDay.equals(geb.getJulianDay()) &&
            detectorID != null && geb.getDetectorID() != null &&
            detectorID.equals(geb.getDetectorID());
    }

    //reset all variables to defaults
    public void reset(){
        julianDay = null;
        GregorianCalendar gc = new GregorianCalendar();
        date = gc.getTime().toString();
        detectorID = "";
        stackedState = "0";
        latitude = "0:0.0 N";
        longitude = "0:0.0 W";
        altitude = "0";
        chan1X = "0";
        chan1Y = "0";
        chan1Z = "0";
        chan1Area = "625.0";
        chan1CableLength = "0";
        chan2X = "0";
        chan2Y = "0";
        chan2Z = "0";
        chan2Area = "625.0";
        chan2CableLength = "0";
        chan3X = "0";
        chan3Y = "0";
        chan3Z = "0";
        chan3Area = "625.0";
        chan3CableLength = "0";
        chan4X = "0";
        chan4Y = "0";
        chan4Z = "0";
        chan4Area = "625.0";
        chan4CableLength = "0";
    }

    public String writeForFile() {
        return 
            julianDay + "\n" +
            breakUpLatitude() + "\n" + 
            breakUpLongitude() + "\n" +
            altitude + "\n" + 
            stackedState + "\n" +
            chan1X + " " + chan1Y + " " + chan1Z + " " + getFormattedChan1Area() + " " + chan1CableLength + "\n" +
            chan2X + " " + chan2Y + " " + chan2Z + " " + getFormattedChan2Area() + " " + chan2CableLength + "\n" +
            chan3X + " " + chan3Y + " " + chan3Z + " " + getFormattedChan3Area() + " " + chan3CableLength + "\n" +
            chan4X + " " + chan4Y + " " + chan4Z + " " + getFormattedChan4Area() + " " + chan4CableLength;  
    }

    public String getFormDate() {
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("MM/dd/yyyy");
        return df.format(new Date(date));
    }

    public String getFormTime() {
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("HH:mm");
        return df.format(new Date(date));
    }
        
    public String getPrettyDay() {
        java.text.SimpleDateFormat dfDay = new java.text.SimpleDateFormat("EEE");
        return dfDay.format(new Date(date));
    }

    public String getPrettyMonth() {
        java.text.SimpleDateFormat dfMonth = new java.text.SimpleDateFormat("MMM");
        return dfMonth.format(new Date(date));
    }

    public String getPrettyDayNumber() {
        java.text.SimpleDateFormat dfDayNumber = new java.text.SimpleDateFormat("d");
        return dfDayNumber.format(new Date(date));
    }

    public String getPrettyShortYear() {
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yy");
        return df.format(new Date(date));
    }
    
    public String getPrettyLongYear() {
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy");
        return df.format(new Date(date));
    }

    public String getPrettyTime() {
        java.text.SimpleDateFormat dfTime = new java.text.SimpleDateFormat("h:mm");
        return dfTime.format(new Date(date));
    }

    public String getPrettyAMPM() {
        java.text.SimpleDateFormat dfAMPM = new java.text.SimpleDateFormat("a");
        return dfAMPM.format(new Date(date));
    }
}
