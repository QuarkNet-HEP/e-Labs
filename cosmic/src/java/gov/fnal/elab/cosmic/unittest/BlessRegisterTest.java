package gov.fnal.elab.cosmic.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.cosmic.bless.*;

public class BlessRegisterTest {

	@Test
	public void test_getValidLabel() {
		BlessRegister br = new BlessRegister("0A");
		String brValue = br.getRegisterValue();
		assertTrue(brValue.equalsIgnoreCase("Trigger: Singles <br />Channel(s): 2 and 4"));
	}
	
	@Test
	public void test_getInvalidLabel() {
		String brValue = "";
		BlessRegister br1 = new BlessRegister("Unknown");
		brValue = br1.getRegisterValue();
		assertTrue(brValue.equalsIgnoreCase("Unknown"));
		BlessRegister br2 = new BlessRegister("");
		brValue = br2.getRegisterValue();
		assertTrue(brValue.equalsIgnoreCase("Unknown"));
		BlessRegister br3 = new BlessRegister(null);
		brValue = br3.getRegisterValue();		
		assertTrue(brValue.equalsIgnoreCase("Unknown"));
	}

}//end of BlessRegisterTest