package gov.fnal.elab.cosmic.beans;

import gov.fnal.elab.cosmic.Geometry;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;

import org.apache.commons.lang.time.DateFormatUtils;

import java.io.Serializable;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.TimeZone;

//made with: ./bean_skeleton.pl --scalar "stackedState latitude longitude altitude chan1X chan1Y chan1Z chan1Area chan1CableLength chan2X chan2Y chan2Z chan2Area chan2CableLength chan3X chan3Y chan3Z chan3Area chan3CableLength chan4X chan4Y chan4Z chan4Area chan4CableLength gpsCableLength" --list "" GeoEntryBean

public class GeoEntryBean implements Serializable {
    public static final String DATE_FORMAT = "MM/dd/yyyy hh:mm zzz";
    public static final TimeZone UTC = TimeZone.getTimeZone("UTC");

    private String julianDay;
    private GregorianCalendar calendar;
    private int detectorID;
    private String stackedState;
    private String latitude, longitude, altitude;
    private ChannelProperties[] channels;
    private String gpsCableLength;
    private List errors, badfields;

    /**
     * Constructor. It resets the bean to its initial state.
     * 
     */
    public GeoEntryBean() {
        this.channels = new ChannelProperties[4];
        this.reset();
    }

    private void addError(String err) {
        if (errors != null && !errors.contains(err)) {
            errors.add(err);
        }
    }

    /**
     * The Julian day and date stuff is rather confusing. If you set one it
     * changes the other, since they should be reflections of one another. So
     * this method has the effect of changing the Julian day and the Gregorian
     * date.
     * 
     * @param s
     *            The string representing the double version of the Julian day.
     */
    public void setJulianDay(String s) {
        julianDay = s;
        if (s != null && !s.equals("")) {
            try {
                NanoDate nd = Geometry.jdToGregorian(Double
                        .parseDouble(julianDay));
                calendar = new GregorianCalendar();
                calendar.setTimeZone(UTC);
                calendar.setTime(nd);
                // round seconds to nearest minute
                int minRounded = Math.round((float) (nd.getTime() % (60 * 1000)) / 60 / 1000); 
                calendar.add(Calendar.MINUTE, minRounded);
            }
            catch (NumberFormatException e) {
                calendar = null;
            }
        }
        else {
            calendar = null;
        }
    }

    public String getJulianDay() {
        return julianDay;
    }

    public Double getJulianDayAsDouble() {
        return Double.valueOf(julianDay);
    }

    public Double getInvertedJulianDay() {
        return new Double(1 / Double.valueOf(julianDay).doubleValue());
    }

    public String getFormattedDate() {
    	return DateFormatUtils.format(calendar.getTime(), DATE_FORMAT);
    }

    public Date getDate() {
        return getCalendar().getTime();
    }

    public void setDetectorID(int detectorID) {
        this.detectorID = detectorID;
    }

    public int getDetectorID() {
        return detectorID;
    }

    public void setStackedState(String s) {
        this.stackedState = s;
    }

    public String getStackedState() {
        return stackedState;
    }

    public void setLatitude(String s) {
        latitude = s;
    }

    /**
     * Returns the latitude in a form that is acceptable for the geometry file.
     * Strangely, we do not present this value to the user in the same way that
     * we store it.
     * 
     * @return The latitude in the correct form for the geo file.
     */
    public String breakUpLatitude() {
        return breakUpLL(getFormattedLatitude());
    }

    private String breakUpLL(String latlong) {
        String s[] = latlong.split("[\\.:]");
        return s[0] + "." + s[1] + "." + s[2];
    }

    public String getLatitude() {
        return latitude;
    }

    public String getFormattedLatitude() {
        if (latitude.matches("-?\\d{1,3}:\\d{1,3}\\.\\d{1,4}"))
            return latitude;
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
        return breakUpLL(getFormattedLongitude());
    }

    public void setLongitude(String s) {
        longitude = s;
    }

    public String getLongitude() {
        return longitude;
    }

    public String getFormattedLongitude() {
        if (longitude.matches("-?\\d{1,3}:\\d{1,3}\\.\\d{1,4}"))
            return longitude;
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

    public void setAltitude(String s) {
        altitude = s;
    }

    public String getAltitude() {
        return altitude;
    }

    private ChannelProperties getChannel(int index) {
        return channels[index - 1];
    }

    public boolean getChan1IsActive() {
        return getChannel(1).isActive();
    }

    public void setChan1IsActive(boolean active) {

    }

    public boolean getChan2IsActive() {
        return getChannel(2).isActive();
    }

    public void setChan2IsActive(boolean active) {

    }

    public boolean getChan3IsActive() {
        return getChannel(3).isActive();
    }

    public void setChan3IsActive(boolean active) {

    }

    public boolean getChan4IsActive() {
        return getChannel(4).isActive();
    }

    public void setChan4IsActive(boolean active) {

    }

    public void setChan1X(String s) {
        getChannel(1).setX(s);
    }

    public String getChan1X() {
        return getChannel(1).getX();
    }

    public void setChan1Y(String s) {
        getChannel(1).setY(s);
    }

    public String getChan1Y() {
        return getChannel(1).getY();
    }

    public void setChan1Z(String s) {
        getChannel(1).setZ(s);
    }

    public String getChan1Z() {
        return getChannel(1).getZ();
    }

    public void setChan1Area(String s) {
        getChannel(1).setArea(s);
    }

    public String getChan1Area() {
        return getChannel(1).getArea();
    }

    public void setChan1CableLength(String s) {
        getChannel(1).setCableLength(s);
    }

    public String getChan1CableLength() {
        return getChannel(1).getCableLength();
    }

    public void setChan2X(String s) {
        getChannel(2).setX(s);
    }

    public String getChan2X() {
        return getChannel(2).getX();
    }

    public void setChan2Y(String s) {
        getChannel(2).setY(s);
    }

    public String getChan2Y() {
        return getChannel(2).getY();
    }

    public void setChan2Z(String s) {
        getChannel(2).setZ(s);
    }

    public String getChan2Z() {
        return getChannel(2).getZ();
    }

    public void setChan2Area(String s) {
        getChannel(2).setArea(s);
    }

    public String getChan2Area() {
        return getChannel(2).getArea();
    }

    public void setChan2CableLength(String s) {
        getChannel(2).setCableLength(s);
    }

    public String getChan2CableLength() {
        return getChannel(2).getCableLength();
    }

    public void setChan3X(String s) {
        getChannel(3).setX(s);
    }

    public String getChan3X() {
        return getChannel(3).getX();
    }

    public void setChan3Y(String s) {
        getChannel(3).setY(s);
    }

    public String getChan3Y() {
        return getChannel(3).getY();
    }

    public void setChan3Z(String s) {
        getChannel(3).setZ(s);
    }

    public String getChan3Z() {
        return getChannel(3).getZ();
    }

    public void setChan3Area(String s) {
        getChannel(3).setArea(s);
    }

    public String getChan3Area() {
        return getChannel(3).getArea();
    }

    public void setChan3CableLength(String s) {
        getChannel(3).setCableLength(s);
    }

    public String getChan3CableLength() {
        return getChannel(3).getCableLength();
    }

    public void setChan4X(String s) {
        getChannel(4).setX(s);
    }

    public String getChan4X() {
        return getChannel(4).getX();
    }

    public void setChan4Y(String s) {
        getChannel(4).setY(s);
    }

    public String getChan4Y() {
        return getChannel(4).getY();
    }

    public void setChan4Z(String s) {
        getChannel(4).setZ(s);
    }

    public String getChan4Z() {
        return getChannel(4).getZ();
    }

    public void setChan4Area(String s) {
        getChannel(4).setArea(s);
    }

    public String getChan4Area() {
        return getChannel(4).getArea();
    }

    public void setChan4CableLength(String s) {
        getChannel(4).setCableLength(s);
    }

    public String getChan4CableLength() {
        return getChannel(4).getCableLength();
    }

    public void setGpsCableLength(String s) {
        gpsCableLength = s;
    }

    public String getGpsCableLength() {
        return gpsCableLength;
    }

    public boolean isJulianDayValid() {
        if (calendar == null) {
            addError(GeometryErrors.ERROR_DATE_FIELD_NOT_SET);
            return false;
        }
        if (calendar.getTime().after(new Date())) {
            addError(GeometryErrors.ERROR_DATE_IN_THE_FUTURE);
            return false;
        }
        return true;
    }

    public boolean isStackedStateValid() {
        return "1".equals(stackedState) || "0".equals(stackedState);
    }

    public boolean isStacked() {
        return "1".equals(stackedState);
    }

    public boolean isLatitudeValid() {
        if (latitude == null
                || !latitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (N|S)")) {
            addError(GeometryErrors.ERROR_LATITUDE);
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isLongitudeValid() {
        if (longitude == null
                || !longitude.matches("\\d{1,3}:\\d{1,3}\\.\\d{1,4} (E|W)")) {
            addError(GeometryErrors.ERROR_LONGITUDE);
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isAltitudeValid() {
        if (altitude == null
                || !altitude
                        .matches("\\d{1,100}\\.\\d{0,100}|\\d{0,100}\\.\\d{1,100}|\\d{1,100}")) {
            addError(GeometryErrors.ERROR_ALTITUDE);
            return false;
        }
        else {
            return true;
        }
    }

    private boolean isValidFloat(String number) {
        try {
            Double.parseDouble(number);
            return true;
        }
        catch (NumberFormatException e) {
            return false;
        }
    }

    private boolean isPositiveFloat(String number) {
        try {
            return Double.parseDouble(number) >= 0;
        }
        catch (NumberFormatException e) {
            return false;
        }
    }

    private boolean checkStackedX(int src) {
        if (getChannel(src).isActive()) {
            String x = getChannel(src).getX();
            for (int i = src + 1; i <= 4; i++) {
                if (getChannel(i).isActive() && !x.equals(getChannel(i).getX())) {
                    addError(GeometryErrors.ERROR_STACKED_EW);
                    return false;
                }
            }
        }
        return true;
    }

    private boolean checkStackedY(int src) {
        if (getChannel(src).isActive()) {
            String x = getChannel(src).getY();
            for (int i = src + 1; i <= 4; i++) {
                if (getChannel(i).isActive() && !x.equals(getChannel(i).getY())) {
                    addError(GeometryErrors.ERROR_STACKED_NS);
                    return false;
                }
            }
        }
        return true;
    }

    private boolean checkStackedZ(int src) {
        if (getChannel(src).isActive()) {
            String x = getChannel(src).getZ();
            for (int i = src + 1; i <= 4; i++) {
                if (getChannel(i).isActive() && x.equals(getChannel(i).getZ())) {
                    addError(GeometryErrors.ERROR_STACKED_UD);
                    return false;
                }
            }
        }
        return true;
    }

    public boolean isChanXValid(int channel) {
        if (isStacked()) {
            if (!checkStackedX(channel)) {
                return false;
            }
        }
        if (!isValidFloat(getChannel(channel).getX())) {
            addError("channel" + channel + "-ew");
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isChanYValid(int channel) {
        if (isStacked()) {
            if (!checkStackedY(channel)) {
                return false;
            }
        }
        if (!isValidFloat(getChannel(channel).getY())) {
            addError("channel" + channel + "-ns");
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isChanZValid(int channel) {
        if (isStacked()) {
            if (!checkStackedZ(channel)) {
                return false;
            }
        }
        if (!isValidFloat(getChannel(channel).getZ())) {
            addError("channel" + channel + "-ud");
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isChan1XValid() {
        return isChanXValid(1);
    }

    public boolean isChan1YValid() {
        return isChanYValid(1);
    }

    public boolean isChan1ZValid() {
        return isChanZValid(1);
    }

    private boolean isAreaValid(int channel) {
        if (!isPositiveFloat(getChannel(channel).getArea())) {
            addError("channel" + channel + "-area");
            return false;
        }
        else {
            return true;
        }
    }

    private boolean isCableLengthValid(int channel) {
        if (!isPositiveFloat(getChannel(channel).getCableLength())) {
            addError("channel" + channel + "-cable-length");
            return false;
        }
        else {
            return true;
        }
    }

    public boolean isChan1AreaValid() {
        return isAreaValid(1);
    }

    public boolean isChan1CableLengthValid() {
        return isCableLengthValid(1);
    }

    public boolean isChan2XValid() {
        return isChanXValid(2);
    }

    public boolean isChan2YValid() {
        return isChanYValid(2);
    }

    public boolean isChan2ZValid() {
        return isChanZValid(2);
    }

    public boolean isChan2AreaValid() {
        return isAreaValid(2);
    }

    public boolean isChan2CableLengthValid() {
        return isCableLengthValid(2);
    }

    public boolean isChan3XValid() {
        return isChanXValid(3);
    }

    public boolean isChan3YValid() {
        return isChanYValid(3);
    }

    public boolean isChan3ZValid() {
        return isChanZValid(3);
    }

    public boolean isChan3AreaValid() {
        return isAreaValid(3);
    }

    public boolean isChan3CableLengthValid() {
        return isCableLengthValid(3);
    }

    public boolean isChan4XValid() {
        return isChanXValid(4);
    }

    public boolean isChan4YValid() {
        return isChanYValid(4);
    }

    public boolean isChan4ZValid() {
        return isChanZValid(4);
    }

    public boolean isChan4AreaValid() {
        return isAreaValid(4);
    }

    public boolean isChan4CableLengthValid() {
        return isCableLengthValid(4);
    }

    public boolean isGpsCableLengthValid() {
        if (!isPositiveFloat(gpsCableLength)) {
            addError(GeometryErrors.ERROR_GPS_CABLE_LENGTH);
            return false;
        }
        else {
            return true;
        }
    }

    // returns true if every key value is valid
    public boolean isValid() {
        errors = new ArrayList();
        badfields = new ArrayList();
        checkFields();
        return errors.size() + badfields.size() == 0;
    }

    public boolean getValid() {
        return isValid();
    }

    public List getBadKeys() {
        return badfields;
    }

    public List getErrors() {
        return errors;
    }

    private void check(boolean v, String key) {
        if (!v) {
            badfields.add(key);
        }
    }

    // get a List of invalid keys
    private void checkFields() {
        check(isJulianDayValid(), "julianDay");
        check(isStackedStateValid(), "stackedState");
        check(isLatitudeValid(), "latitude");
        check(isLongitudeValid(), "longitude");
        check(isAltitudeValid(), "altitude");
        check(isChan1XValid(), "chan1X");
        check(isChan1YValid(), "chan1Y");
        check(isChan1ZValid(), "chan1Z");
        check(isChan1AreaValid(), "chan1Area");
        check(isChan1CableLengthValid(), "chan1CableLength");
        check(isChan2XValid(), "chan2X");
        check(isChan2YValid(), "chan2Y");
        check(isChan2ZValid(), "chan2Z");
        check(isChan2AreaValid(), "chan2Area");
        check(isChan2CableLengthValid(), "chan2CableLength");
        check(isChan3XValid(), "chan3X");
        check(isChan3YValid(), "chan3Y");
        check(isChan3ZValid(), "chan3Z");
        check(isChan3AreaValid(), "chan3Area");
        check(isChan3CableLengthValid(), "chan3CableLength");
        check(isChan4XValid(), "chan4X");
        check(isChan4YValid(), "chan4Y");
        check(isChan4ZValid(), "chan4Z");
        check(isChan4AreaValid(), "chan4Area");
        check(isChan4CableLengthValid(), "chan4CableLength");
        check(isGpsCableLengthValid(), "gpsCableLength");
    }

    /*
     * Tests whether this GeoEntryBean is equal to another GeoEntryBean.
     * 
     * @return boolean Whether they are equal.
     */
    public boolean equals(GeoEntryBean geb) {
        return julianDay != null && geb.getJulianDay() != null
                && julianDay.equals(geb.getJulianDay()) 
                && detectorID == geb.getDetectorID();
    }

    // reset all variables to defaults
    public void reset() {
        julianDay = null;
        calendar = null;
        detectorID = -1;
        stackedState = "0";
        latitude = "0:0.0 N";
        longitude = "0:0.0 W";
        altitude = "0";
        for (int i = 0; i < 4; i++) {
            channels[i] = new ChannelProperties();
        }
        gpsCableLength = "0";
    }

    public String writeForFile() {
        double cl = Double.parseDouble(getGpsCableLength());
        cl = Math.round(cl * 500);
        return julianDay + "\n" + breakUpLatitude() + "\n" + breakUpLongitude()
                + "\n" + altitude + "\n" + stackedState + "\n"
                + getChannel(1).toString() + "\n" + getChannel(2).toString()
                + "\n" + getChannel(3).toString() + "\n"
                + getChannel(4).toString() + "\n" + cl;
    }

    private GregorianCalendar getCalendar() {
        if (calendar == null) {
            calendar = new GregorianCalendar();
            calendar.setTimeZone(UTC);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
        }
        return calendar;
    }

    // you need about 4 decimals to get minute resolution
    private static final NumberFormat JD_FORMAT = new DecimalFormat("0.0000");

    private void updateJulianDay() {
        Calendar calendar = getCalendar();
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        int month = calendar.get(Calendar.MONTH) + 1;
        int year = calendar.get(Calendar.YEAR);
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        double jd = ElabUtil.gregorianToJulian(year, month, day, hour, minute, 0);
        this.julianDay = JD_FORMAT.format(jd);
    }

    private void updateCalendar(int field, int value) {
        getCalendar().set(field, value);
        updateJulianDay();
    }

    public void setMonth(String v) {
        updateCalendar(Calendar.MONTH, Integer.parseInt(v) - 1);
    }

    public String getMonth() {
        return String.valueOf(getCalendar().get(Calendar.MONTH) + 1);
    }

    public void setDay(String v) {
        updateCalendar(Calendar.DAY_OF_MONTH, Integer.parseInt(v));
    }

    public String getDay() {
        return String.valueOf(getCalendar().get(Calendar.DAY_OF_MONTH));
    }

    public void setYear(String v) {
        updateCalendar(Calendar.YEAR, Integer.parseInt(v));
    }

    public String getYear() {
        return String.valueOf(getCalendar().get(Calendar.YEAR));
    }

    public void setHour(String v) {
        updateCalendar(Calendar.HOUR_OF_DAY, Integer.parseInt(v));
    }

    public String getHour() {
        return String.valueOf(getCalendar().get(Calendar.HOUR_OF_DAY));
    }

    public void setMinute(String v) {
        updateCalendar(Calendar.MINUTE, Integer.parseInt(v));
    }

    public String getMinute() {
        return String.valueOf(getCalendar().get(Calendar.MINUTE));
    }

    public boolean equals(Object obj) {
        if (obj instanceof GeoEntryBean) {
            GeoEntryBean g = (GeoEntryBean) obj;
            return julianDay.equals(g.getJulianDay())
                    && detectorID == g.getDetectorID();
        }
        else {
            return false;
        }
    }

    private static class ChannelProperties implements Serializable {
        private String x, y, z;
        private String area;
        private String cableLength;
        private String active;

        public ChannelProperties() {
            x = "0";
            y = "0";
            z = "0";
            area = "625.0";
            cableLength = "0";
        }

        public ChannelProperties(String length, String area, String x,
                String y, String z) {
            this.cableLength = length;
            this.area = area;
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public String getX() {
            return x;
        }

        public void setX(String x) {
            this.x = x;
        }

        public String getY() {
            return y;
        }

        public void setY(String y) {
            this.y = y;
        }

        public String getZ() {
            return z;
        }

        public void setZ(String z) {
            this.z = z;
        }

        public String getArea() {
            return area;
        }

        public void setArea(String area) {
            this.area = area;
        }

        public String getCableLength() {
            return cableLength;
        }

        public void setCableLength(String length) {
            this.cableLength = length;
        }

        public boolean isActive() {
            return !"0".equals(x) || !"0".equals(y) || !"0".equals(z)
                    || !"625.0".equals(area) || !"0.0".equals(cableLength);
        }

        public String toString() {
            double a = Double.parseDouble(area);
            a = a / 100 / 100;
            double cl = Double.parseDouble(cableLength);
            cl = Math.round(cl * 500);
            return x + " " + y + " " + z + " " + a + " " + cl;
        }
    }
}
