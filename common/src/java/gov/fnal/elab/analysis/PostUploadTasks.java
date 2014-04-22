package gov.fnal.elab.analysis;

import java.util.ArrayList;

import gov.fnal.elab.analysis.ElabAnalysis;

public interface PostUploadTasks {
	void setUpload(ElabAnalysis ea);
	String createMetadata();
	ArrayList<String> runBenchmark();
	String createThresholdTimes();
}//end of PostUploadTasks