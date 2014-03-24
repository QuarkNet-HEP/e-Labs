package gov.fnal.elab.debug;

import java.util.*;
import java.io.File;
import java.text.*;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.LineNumberReader;

import gov.fnal.elab.Elab;

public class WriteLogFile {
	String logFile;
    Elab elabReference;
    BufferedWriter bw;
    
	public WriteLogFile(Elab elab, String filename, String subdir) {
		this.elabReference = elab;
		logFile = elabReference.getProperties().getDataDir() + File.separator + subdir + File.separator + filename + ".log";
		//check if the .thresh exists, if so, do not overwrite it
		File tf = new File(logFile);
		if (tf.exists()) {
			logFile = null;
			bw = null;
		} else {
			try {
				bw = new BufferedWriter(new FileWriter(logFile));
			} catch (Exception e) {
				System.out.println(e.getMessage());
			}
		}
	}
	
	public boolean canAppend() {
		if (bw != null) {
			return true;
		} else {
			return false;
		}
	}
	
	public void appendLines(String line) {
		try {
			bw.write(line);
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}
	
	public void cleanup() {
		try {
			bw.close();
		} catch (Exception e) {
			System.out.println(e.getMessage());			
		}
	}
}