package gov.fnal.elab.survey;

import java.util.Collection;
import java.util.SortedMap;
import java.util.TreeMap;

public class ElabSurvey {
	private int id; 
	private String name; 
	private SortedMap questions;  // one day we can have generics! 
	
	public ElabSurvey(String name, int id) {
		this.id = id; 
		this.name = name; 
		questions = new TreeMap(); 
	}
	
	public String getName() { 
		return name; 
	}
	
	public Collection getQuestions() {
		return questions.values();
	}
	
	public int getQuestionCount() { 
		return questions.size();
	}
	
	public void addQuestion(ElabSurveyQuestion q) {
		questions.put(new Integer(q.getId()), q);
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
