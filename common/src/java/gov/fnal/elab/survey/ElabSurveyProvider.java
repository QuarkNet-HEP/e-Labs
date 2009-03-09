package gov.fnal.elab.survey;

import java.util.List;
import java.util.Map;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.ElabException;

public interface ElabSurveyProvider {
	
	public ElabSurvey getSurvey(int testId) throws ElabException;

	public void RecordCompletion(int surveyId, int studentId, String type, List answers) throws ElabException;
	
	public boolean hasStudentTakenTest(int surveyId, int studentId, String type) throws ElabException; 
	
	public int getTotalTaken(String type, ElabGroup group) throws ElabException; 
	
	public Map getStudentSurveyStatus(String type, ElabGroup group) throws ElabException;
	
	public Map getStudentResultsForTeacher(String type, ElabGroup group) throws ElabException;
	
	public int getTotalStudents(ElabGroup group) throws ElabException;
	
	public ElabSurveyQuestion getSurveyQuestion(int questionId, int responseId) throws ElabException;
}
