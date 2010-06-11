package gov.fnal.elab;

/**
 * 
 * Providers that require a handle on an {@link Elab} object should implement this interface
 *
 */
public interface ElabProviderHandled extends ElabProvider {
	void setElab(Elab elab);
}
