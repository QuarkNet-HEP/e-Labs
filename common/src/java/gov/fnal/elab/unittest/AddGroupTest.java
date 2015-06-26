package gov.fnal.elab.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;

import java.util.*;

public class AddGroupTest {
	public Elab cosmicElab = Elab.getElab(null, "cosmic");
	public Elab cmsElab = Elab.getElab(null, "cms");
	public Elab ligoElab = Elab.getElab(null, "ligo");

	@Test
	public void testGetStates() {
		String message = "";
		TreeMap<Integer, ArrayList> states = null;
		try {
			states = DataTools.getStates(cosmicElab);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(states != null);
	}//end of testGetStates
	
	@Test
	public void testGetStateAbbrev() {
		String message = "";
		String name = "";
		try {
			name = DataTools.getStateAbbrev(cosmicElab, 2);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(!name.equals(""));		
	}//end of testGetStateId
	
	@Test
	public void testInsertState() {
		String message = "";
		int stateId = 0;
		try {
			stateId = DataTools.insertState(cosmicElab, "Test", "XX", 2);
			assertTrue(stateId > 0);
			DataTools.deleteState(cosmicElab, stateId);
			stateId = DataTools.insertState(cosmicElab, "", "", 0);
			assertTrue(stateId == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertState
	
	@Test
	public void testGetCities() {
		String message = "";
		TreeMap<Integer, ArrayList> cities = null;
		try {
			cities = DataTools.getCities(cosmicElab);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(cities != null);		
	}//end of testGetCities
	
	@Test
	public void testGetCityName() {
		String message = "";
		String name = "";
		try {
			name = DataTools.getCityName(cosmicElab, 2);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(!name.equals(""));		
	}//end of testGetCityId
	
	@Test
	public void testInsertCity() {
		String message = "";
		int cityId = 0;
		try {
			cityId = DataTools.insertCity(cosmicElab, "Test", 1);
			assertTrue(cityId > 0);
			DataTools.deleteCity(cosmicElab, cityId);
			cityId = DataTools.insertCity(cosmicElab, "", 0);
			assertTrue(cityId == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertState
	
	@Test
	public void testGetSchools() {
		String message = "";
		TreeMap<Integer, ArrayList> schools = null;
		try {
			schools = DataTools.getSchools(cosmicElab);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(schools != null);				
	}//end of testGetSchools

	@Test
	public void testGetSchoolName() {
		String message = "";
		String name = "";
		try {
			name = DataTools.getSchoolName(cosmicElab, 2);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(!name.equals(""));		
	}//end of testGetSchoolName
	
	@Test
	public void testInsertSchool() {
		String message = "";
		int schoolId = 0;
		try {
			schoolId = DataTools.insertSchool(cosmicElab, "XX", 1);
			assertTrue(schoolId > 0);
			DataTools.deleteSchool(cosmicElab, schoolId);
			schoolId = DataTools.insertSchool(cosmicElab, "", 0);
			assertTrue(schoolId == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertSchool
	
	@Test
	public void testGetTeachers() {
		String message = "";
		TreeMap<Integer, ArrayList> teachers = null;
		try {
			teachers = DataTools.getTeachers(cosmicElab);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(teachers != null);				
	}//end of testGetTeachers

	@Test
	public void testGetTeacherName() {
		String message = "";
		String name = "";
		try {
			name = DataTools.getTeacherName(cosmicElab, 2);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(!name.equals(""));		
	}//end of testGetTeacherId
	
	@Test
	public void testInsertTeacher() {
		String message = "";
		int teacherId = 0;
		try {
			teacherId = DataTools.insertTeacher(cosmicElab, "EP", "ep@email.com", 22);
			assertTrue(teacherId > 0);
			DataTools.deleteTeacher(cosmicElab, teacherId);
			teacherId = DataTools.insertTeacher(cosmicElab, "", "", 0);
			assertTrue(teacherId == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertTeacher	

	@Test
	public void testGetGroups() {
		String message = "";
		TreeMap<Integer, ArrayList> groups = null;
		try {
			groups = DataTools.getGroups(cosmicElab);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
		assertTrue(groups != null);				
	}//end of testGetGroups

	@Test
	public void testInsertGroup() {
		String message = "";
		int groupId = 0;
		try {
			groupId = DataTools.insertGroup(cosmicElab, "EP-Test", "xx", "user", "dummyuserarea", "AY2015", "No", 29);
			assertTrue(groupId > 0);
			DataTools.deleteGroup(cosmicElab, groupId);
			groupId = DataTools.insertGroup(cosmicElab, "", "", "", "", "", "", 0);
			assertTrue(groupId == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertGroup	
	
	@Test
	public void testInsertGroupProject() {
		String message = "";
		int id = 0;
		try {
			id = DataTools.insertGroupProject(cosmicElab, 4, 4);
			assertTrue(id > 0);
			DataTools.deleteGroupProject(cosmicElab, 4, 4);
			id = DataTools.insertGroupProject(cosmicElab, 0, 0);
			assertTrue(id == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertGroupProject	

	@Test
	public void testInsertGroupDetector() {
		String message = "";
		int id = 0;
		String[] detectors = {"6119","6148"};
		try {
			id = DataTools.insertGroupDetector(cosmicElab, 4, detectors);
			assertTrue(id > 0);
			DataTools.deleteGroupDetector(cosmicElab, 4, 6119);
			DataTools.deleteGroupDetector(cosmicElab, 4, 6148);
			id = DataTools.insertGroupDetector(cosmicElab, 0, detectors);
			assertTrue(id == 0);
		} catch (Exception e) {
			message = "There was an exception";
		}
		assertTrue(message.equals(""));
	}//end of testInsertGroupDetector		
	
}//end of AddGroupTest