package gov.fnal.elab.password;

import org.multicians.thvv.gpw.*;

public final class GeneratePassword { 
	private static Gpw data = new Gpw(); 
	
	public String getPassword() {
		return this.getPassword(8);
	}
	
	public String getPassword(int length) {
		return GeneratePassword.data.generate(length);
	}
}