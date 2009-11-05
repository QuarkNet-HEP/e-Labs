package gov.fnal.elab.survey;

import java.util.List;
import java.util.Map;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.util.ElabException;

public interface ElabSurveyProvider {
	
	public ElabSurvey getSurvey(int surveyId) throws ElabException;
	
	public ElabSurveyQuestion getSurveyQuestion(int surveyId, int questionId, int responseId) throws ElabException;

	public void RecordCompletion(int surveyId, int studentId, String type, List<Integer> answers) throws ElabException;
	
	public boolean hasStudentTakenTest(int surveyId, int studentId, String type) throws ElabException; 
	
	public int getTotalTaken(String type, ElabGroup group) throws ElabException; 
	
	public Map<ElabStudent, Boolean> getStudentSurveyStatus(String type, ElabGroup group) throws ElabException;
	
	public Map<ElabGroup, Map<ElabStudent, List<ElabSurveyQuestion>>>  getStudentResultsForTeacher(String type, ElabGroup group) throws ElabException;
	
	public int getTotalStudents(ElabGroup group) throws ElabException;
	
	public Map<Integer, String> getElabSurveyListForProject(int projectId) throws ElabException; 
	
}
