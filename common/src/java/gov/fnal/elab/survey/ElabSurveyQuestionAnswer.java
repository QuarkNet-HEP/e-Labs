package gov.fnal.elab.survey;

public class ElabSurveyQuestionAnswer implements Comparable<ElabSurveyQuestionAnswer> {
	private String text; 
	private Integer id; 
	private int number; 

	public ElabSurveyQuestionAnswer(int id, String text, int response_no) {
		this.id = new Integer(id);
		this.text = text; 
		this.number = response_no;
	}
	
	public void setText(String text) {
		this.text = text;
	}

	public String getText() {
		return text;
	}

	public void setId(int id) {
		this.id = Integer.valueOf(id);
	}

	public Integer getId() {
		return id;
	} 
	
	public int compareTo(ElabSurveyQuestionAnswer o) {
		// TODO Auto-generated method stub
		return this.id.compareTo(o.id);
	}
	
	public boolean equals(ElabSurveyQuestionAnswer o) {
		return this.compareTo(o) == 0;
	}

	public void setNumber(int number) {
		this.number = number;
	}

	public int getNumber() {
		return number;
	}
}
