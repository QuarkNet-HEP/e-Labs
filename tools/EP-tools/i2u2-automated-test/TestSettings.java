import static net.sourceforge.jwebunit.junit.JWebUnit.assertButtonPresentWithText;
import static net.sourceforge.jwebunit.junit.JWebUnit.assertTextPresent;
import static net.sourceforge.jwebunit.junit.JWebUnit.beginAt;
import static net.sourceforge.jwebunit.junit.JWebUnit.clickLinkWithText;
import static net.sourceforge.jwebunit.junit.JWebUnit.setTextField;
import static net.sourceforge.jwebunit.junit.JWebUnit.submit;

public class TestSettings {
	public static String urlBaseTest = "https://www.i2u2.org/elab";
	
	public static void loginAsGuest(String elab) {
		beginAt("/"+elab+"/home/index.jsp");
		setTextField("user","guest");
		setTextField("pass","guest");
		submit();
		assertTextPresent("guest");
		assertTextPresent("Log out");	
	}//end of loginAsGuest

	public static void loginAsUndergrads(String elab) {
		beginAt("/"+elab+"/teacher/index.jsp");
		setTextField("user","undergrads");
		setTextField("pass","1ll1n1");
		submit();		
		assertTextPresent("undergrads");
		assertTextPresent("Log out");		
	}//end of loginAsTestTeacher
	
	public static void loginAsTestTeacher(String elab) {
		beginAt("/"+elab+"/teacher/index.jsp");
		setTextField("user","TestTeacher");
		setTextField("pass","i2u2tt");
		submit();			
		assertTextPresent("TestTeacher");
		assertTextPresent("Log out");		
	}//end of loginAsTestTeacher
	
	public static void loginAsAdmin(String elab) {
		beginAt("/"+elab+"/admin/index.jsp");
		setTextField("user","admin");
		setTextField("pass","dull");
		submit();		
		assertTextPresent("admin");
		assertTextPresent("Log out");
	}//end of loginAsAdmin
	
	public static void logOut() {
		assertTextPresent("Log out");
		clickLinkWithText("Log out");
		assertButtonPresentWithText("Login");					
	}//end of logOut
	
}//end of webSettings