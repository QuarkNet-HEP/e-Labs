package gov.fnal.elab.survey;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

public class ElabSurvey {
	private int id; 
	private String name; 
	private SortedMap<Integer, ElabSurveyQuestion> questions;  
	
	public ElabSurvey(String name, int id) {
		this.id = id; 
		this.name = name; 
		questions = new TreeMap<Integer, ElabSurveyQuestion>(); 
	}
	
	public String getName() { 
		return name; 
	}
	
	public Collection<ElabSurveyQuestion> getQuestions() {
		return getQuestionsByNo();
	}
	
	public Collection<ElabSurveyQuestion> getQuestionsById() {
		return questions.values();
	}
	
	public Collection<ElabSurveyQuestion> getQuestionsByNo() {
		List<ElabSurveyQuestion> al = new ArrayList<ElabSurveyQuestion>(questions.values());
		java.util.Collections.sort(al);
		return al;
	}
	
	public int getQuestionCount() { 
		return questions.size();
	}
	
	public void addQuestion(ElabSurveyQuestion q) {
		questions.put(Integer.valueOf(q.getId()), q);
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
