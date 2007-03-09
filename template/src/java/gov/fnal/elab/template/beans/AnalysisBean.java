package gov.fnal.elab.template.beans;

public class AnalysisBean {
	
	private String inputString;

	public String getInputString() {
		return inputString;
	}

	public void setInputString(String inputString) {
		this.inputString = inputString;
	}
	
	//Just an example on further processing the inputs from the analysisInput.jsp page
	public String moreComplexProcessing(){
		return inputString.toLowerCase()+inputString.toUpperCase();
	}
}