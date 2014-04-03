import static net.sourceforge.jwebunit.junit.JWebUnit.*;

import org.junit.*;
import net.sourceforge.jwebunit.api.*;
import java.util.*;

public class LoginAllElabs {
		@Before
		public void prepare() {
			setBaseUrl("https://www.i2u2.org/elab");
		}
	
		@Test
		public void runTests() {
			elabTest("cosmic");
			elabTest("cms");
			elabTest("ligo");
			cosmicDataTest();
			ligoDataTest();
			cmsDataTest();
		}
		
		public void elabTest(String elab) {
			System.out.println("Testing login for "+elab);
			loginTest(elab);
			System.out.println("Testing poster links for "+elab);
			posterTest(elab);
			System.out.println("Testing plot links for "+elab);
			plotTest(elab);
			System.out.println("Testing logbook links for "+elab);
			logbookTest(elab);			
		}
		
		public void loginTest(String elab) {
			TestSettings.loginAsGuest(elab);
			TestSettings.logOut();
			TestSettings.loginAsAdmin(elab);
			TestSettings.logOut();
			TestSettings.loginAsUndergrads(elab);
			TestSettings.logOut();
			TestSettings.loginAsTestTeacher(elab);
			TestSettings.logOut();				
		}
		
		public void posterTest(String elab) {
			TestSettings.loginAsTestTeacher(elab);
			setScriptingEnabled(false);
			//new poster
			gotoPage("/"+elab+"/posters/new.jsp");
			assertTextNotPresent("exception");
			assertTextPresent("Make or edit your poster");
			assertTextPresent("Abstract");
			assertButtonPresentWithText("Make Poster");
			//edit poster
			gotoPage("/"+elab+"/posters/edit.jsp");
			assertTextPresent("Edit Posters: Click on a poster to edit it.");
			assertTextNotPresent("exception");
			//view poster
			gotoPage("/"+elab+"/posters/view.jsp");
			assertTextPresent("Search for and view posters.");
			assertLinkPresentWithText("abbreviation");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			//delete
			gotoPage("/"+elab+"/posters/delete.jsp");
			assertTextPresent("Search for and delete posters");
			assertLinkPresentWithText("abbreviation");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			//upload image
			gotoPage("/"+elab+"/jsp/uploadImage.jsp");
			assertButtonPresentWithText("Upload");
			assertTextNotPresent("exception");
			setScriptingEnabled(true);
			TestSettings.logOut();				
		}

		public void plotTest(String elab) {
			TestSettings.loginAsTestTeacher(elab);
			gotoPage("/"+elab+"/plots/index.jsp");
			assertTextNotPresent("exception");
			assertTextPresent("Search for and view plots.");
			assertLinkPresentWithText("TestTeacher");
			assertButtonPresentWithText("Search Data");
			TestSettings.logOut();
		}
		
		public void logbookTest(String elab) {
			TestSettings.loginAsTestTeacher(elab);
			gotoPage("/"+elab+"/jsp/showLogbookT.jsp");
			assertTextNotPresent("exception");
			gotoPage("/"+elab+"/jsp/showLogbookKWforT.jsp");
			assertTextNotPresent("exception");
			gotoPage("/"+elab+"/jsp/showLogbookRGforT.jsp");
			assertTextNotPresent("exception");
			gotoPage("/"+elab+"/teacher/index.jsp");
			TestSettings.logOut();
			}
	
		public void cosmicDataTest() {
			System.out.println("Testing cosmic data");
			TestSettings.loginAsTestTeacher("cosmic");
			gotoPage("/cosmic/data/search.jsp");
			assertButtonPresentWithText("Search Data");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			setScriptingEnabled(false);
			assertTextNotPresent("exception");
			gotoPage("cosmic/analysis-performance/index.jsp");
			assertButtonPresentWithText("Search Data");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			TestSettings.logOut();
			TestSettings.loginAsTestTeacher("cosmic");			
			gotoPage("/cosmic/analysis-performance/analysis.jsp?rawData=202.2008.0212.0");
			assertRadioOptionPresent("runMode", "local");
			clickRadioOption("runMode", "local");
			clickButtonWithText("Analyze");
			TestSettings.logOut();
			TestSettings.loginAsTestTeacher("cosmic");	
			gotoPage("cosmic/analysis-flux/index.jsp");
			assertButtonPresentWithText("Search Data");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			gotoPage("cosmic/analysis-shower/index.jsp");
			assertButtonPresentWithText("Search Data");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			gotoPage("cosmic/analysis-lifetime/index.jsp");
			assertButtonPresentWithText("Search Data");
			assertLinkPresentWithText("TestTeacher");
			clickLinkWithText("TestTeacher");
			assertTextNotPresent("exception");
			gotoPage("cosmic/analysis/list.jsp");
			assertTextPresent("PerformanceStudy");
			assertButtonPresentWithText("Remove Selected");
			assertTextNotPresent("exception");	
			setScriptingEnabled(true);
			TestSettings.logOut();
		}
		
		public void ligoDataTest() {
			System.out.println("Testing ligo data");
			TestSettings.loginAsTestTeacher("ligo");
			setScriptingEnabled(false);
			gotoPage("/ligo/bluestone/index.jsp");
			assertTextPresent("Start Time");
			assertTextNotPresent("exception");
			assertButtonPresentWithText("Save Plot");
			assertButtonPresentWithText("Plot");
			//clickButtonWithText("Plot");
			//assertTextNotPresent("No data to plot");
			gotoPage("/ligo/current/index.jsp");
			assertTextPresent("Start Time");
			assertTextNotPresent("exception");
			assertButtonPresentWithText("Save Plot");
			assertButtonPresentWithText("Plot");
			//clickButtonWithText("Plot");
			//assertTextNotPresent("No data to plot");
			setScriptingEnabled(true);
			TestSettings.logOut();
		}
		
		public void cmsDataTest() {
			System.out.println("Testing cms data");
			TestSettings.loginAsTestTeacher("cms");
			gotoPage("/cms/data/index.jsp");
			setScriptingEnabled(false);
			assertTextPresent("Calibration");
			clickLinkWithText("Calibration");
			assertTextNotPresent("exception");
			gotoPage("cms/event-display/index.jsp");
			clickLinkWithImage("../graphics/open.png");
			gotoPage("/cms/data/index.jsp");
			setScriptingEnabled(true);
			TestSettings.logOut();
		}
}
