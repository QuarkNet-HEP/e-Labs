package gov.fnal.elab.util;

public class ElabTooManyJobsException extends ElabException{
    private double strain = 0;
    private boolean isOverUserLimit = false;
    private boolean isOverSystemLimit = false;

    public ElabTooManyJobsException(int i){
        this.setStrain(i);
    }

    public ElabTooManyJobsException(String msg){
        super(msg);
    }
    
    public void setStrain(double i){
        strain = i;
    }

    public double getStrain(){
        return strain;
    }

    /**
     * Set to true if the user running a job is over their own user-limit
     * for a maximum number of jobs (or strain).
     */
    public void setIsOverUserLimit(boolean b){
        isOverUserLimit = b;
    }

    /**
     * @return  true if the user is over their limit
     */
    public boolean getIsOverUserLimit(){
        return isOverUserLimit;
    }

    /**
     * Set to true if the system is over a specified limit
     */
    public void setIsOverSystemLimit(boolean b){
        isOverSystemLimit = b;
    }

    /**
     * @return  true if the system is over the limit
     */
    public boolean getIsOverSystemLimit(){
        return isOverSystemLimit;
    }
}
