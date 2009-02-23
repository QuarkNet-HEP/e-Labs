package gov.fnal.elab.survey;

import java.util.ArrayList; 
import java.util.List;

public class ElabSurvey {
	private int id; 
	private String name; 
	private List questions;  // one day we can have generics! 
	
	public ElabSurvey(String name) {
		this.name = name; 
		questions = new ArrayList(); 
	}
	
	public String getName() { 
		return name; 
	}
	
	public List getQuestions() {
		return questions;
	}
	
	public int getQuestionCount() { 
		return questions.size();
	}
	
	public void addQuestion(ElabSurveyQuestion q) {
		questions.add(q);
	}
}
