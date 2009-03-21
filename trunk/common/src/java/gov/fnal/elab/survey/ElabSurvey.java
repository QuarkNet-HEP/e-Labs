package gov.fnal.elab.survey;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
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
		return getQuestionsByNo();
	}
	
	public Collection getQuestionsById() {
		return questions.values();
	}
	
	public Collection getQuestionsByNo() {
		List al = new ArrayList(questions.values());
		java.util.Collections.sort(al);
		return al;
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
