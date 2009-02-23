package gov.fnal.elab.survey;

import java.util.List;

import gov.fnal.elab.util.ElabException;

public interface ElabSurveyProvider {
	
	public ElabSurvey getSurvey(int id) throws ElabException;

	public void RecordCompletion(int studentId, int testId, String type, List answers) throws ElabException;
	
	public boolean hasStudentTakenTest(int studentID, int testID) throws ElabException;

}
