//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Oct 2, 2006
 */
package gov.fnal.elab.analysis.impl.swift;

import java.util.StringTokenizer;
import java.io.Serializable;

import org.globus.cog.karajan.arguments.AbstractWriteOnlyVariableArguments;

public class OutputChannel extends AbstractWriteOnlyVariableArguments implements Serializable {
    public static final String START = "PROGRESS_INIT";
    public static final String DONE = "PROGRESS_MARKER";
        
	private StringBuffer sb;
	private int total, current;
	
	private String prefix;
	
	public OutputChannel() {
	}

	public OutputChannel(String prefix) {
	    this.prefix = prefix;
		sb = new StringBuffer();
	}

	public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public synchronized void append(Object value) {
		String str = String.valueOf(value);
		
		if (str.startsWith(START)) {
		    total++;
		}
		else if (str.startsWith(DONE)) {
		    current++;
		}
		else {
    		StringTokenizer st = new StringTokenizer(str, "\n\r");
    		while (st.hasMoreTokens()) {
    		    System.out.println(prefix + ": " + st.nextToken());
    		}
    		sb.append(str);
		}
	}

	public boolean isCommutative() {
		return true;
	}

	public String toString() {
		return sb.toString();
	}

    public int getTotal() {
        return total;
    }

    public int getCurrent() {
        return current;
    }
}
