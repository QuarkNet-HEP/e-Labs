/*
 * Created on Jul 15, 2007
 */
package gov.fnal.elab;

/**
 * 
 * Provider that want a handle on the elab they're used in should implement this
 * interface
 * 
 */
public interface ElabProvider {
    void setElab(Elab elab);
}
