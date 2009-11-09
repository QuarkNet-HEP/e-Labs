package gov.fnal.elab.survey;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap; 

public class ElabSurveyQuestion implements Cloneable, Comparable<ElabSurveyQuestion> {
	private int id, number; 
	private SortedMap<Integer, ElabSurveyQuestionAnswer> answers; 
	private String text; 
	private ElabSurveyQuestionAnswer correctAnswer = null, givenAnswer = null; 
	
	// hack
	private java.util.Date answeredTime; 
	
	/**
	 * Constructor for an ElabSurveyQuestion
	 * 
	 * @param Question ID
	 * @param Question Number
	 * @param Question Text
	 */
	public ElabSurveyQuestion(int id, int number, String text) {
		this.id = id; 
		this.number = number; 
		this.text = text; 
		this.answers = new TreeMap<Integer, ElabSurveyQuestionAnswer>(); 
	}
	
	public void addAnswer(ElabSurveyQuestionAnswer a) {
		this.answers.put(a.getId(), a);
	}
	
	public int getId() {
		return id;
	}
	
	public String getText() {
		return text;
	}
	
	public Collection<ElabSurveyQuestionAnswer> getAnswers() {
		return getAnswersByNo();
	}
	
	public Collection<ElabSurveyQuestionAnswer> getAnswersById() {
		return answers.values(); 
	}
	
	public Collection<ElabSurveyQuestionAnswer> getAnswersByNo() {
		List<ElabSurveyQuestionAnswer> al = new ArrayList<ElabSurveyQuestionAnswer>(answers.values());
		java.util.Collections.sort(al);
		return al;
	}
	
	public void setCorrectAnswer(int id) {
		this.correctAnswer = this.answers.get(Integer.valueOf(id));
	};

	public void setCorrectAnswer(ElabSurveyQuestionAnswer correctAnswer) {
		this.correctAnswer = correctAnswer;
	}

	public ElabSurveyQuestionAnswer getCorrectAnswer() {
		return correctAnswer;
	}
	
	public void setGivenAnswer(int id) {
		this.givenAnswer = this.answers.get(Integer.valueOf(id));
	}

	public void setGivenAnswer(ElabSurveyQuestionAnswer givenAnswer) {
		this.givenAnswer = givenAnswer;
	}

	public ElabSurveyQuestionAnswer getGivenAnswer() {
		return givenAnswer;
	}
	
	/**
	 * Returns a boolean if the correct answer is given
	 * 
	 * @return the correct answer is given
	 */
	public boolean getCorrectAnswerGiven() {
		if ((givenAnswer != null) && (correctAnswer!= null) && (correctAnswer == givenAnswer)) {
			return true;
		}
		return false; 
	}
	
	public ElabSurveyQuestion clone() {
		ElabSurveyQuestion question = null;
		try {
			// A shallow copy is fine
			question = (ElabSurveyQuestion) super.clone();
		}
		catch (CloneNotSupportedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return question; 
	}
	
	/**
	 * Returns the question number for ordering
	 * 
	 * @return the question number 
	 */
	public int getNumber() {
		return number;
	}

	/**
	 * Sort by question number 
	 */
	public int compareTo(ElabSurveyQuestion o) {
		return Integer.valueOf(number).compareTo(Integer.valueOf(o.getNumber()));
	}
	
	public int getNumAnswers() { 
		try {
			return answers.size();
		}
		catch(NullPointerException npe) {
			return 0;
		}
	}

	public void setAnsweredTime(java.util.Date answeredTime) {
		this.answeredTime = answeredTime;
	}

	public java.util.Date getAnsweredTime() {
		return answeredTime;
	}
}
