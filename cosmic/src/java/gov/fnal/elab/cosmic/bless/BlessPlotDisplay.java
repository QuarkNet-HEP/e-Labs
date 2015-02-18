package gov.fnal.elab.cosmic.bless;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

import org.apache.commons.lang.time.DateFormatUtils;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;

public class BlessPlotDisplay {
	String iconDisplay = "";
	String filename = "";
	
	public BlessPlotDisplay() {
		this.filename = "";
		this.iconDisplay = "";
    }//end of BlessPlotDisplay
	
	public String getIcons(Elab elab, String filename) {
		StringBuilder sb = new StringBuilder();
		try {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
			if (entry != null) {
				sb.append("<a href=\"../jsp/comments-add.jsp?fileName=");
				sb.append(entry.getLFN());
				String comments = (String) entry.getTupleValue("comments");
				Boolean stacked = (Boolean) entry.getTupleValue("stacked");
				String blessfile = (String) entry.getTupleValue("blessfile");
				Boolean blessed = (Boolean) entry.getTupleValue("blessed");
		        if (comments != null && !comments.equals("")) {
		        	sb.append("\"><img src=\"../graphics/balloon_talk_blue.gif\"/></a>");
		        } else {
		        	sb.append("\"><img src=\"../graphics/balloon_talk_empty.gif\"/></a>");        	
		        }
		        if (stacked != null) {
		        	sb.append("<a href=\"javascript:glossary('geometry', 200)\">");
			        if (stacked) {
		            	sb.append("<img alt=\"Stacked data\" "
		                        + "src=\"../graphics/stacked.gif\"/>");
		            }
		            else {
		            	sb.append("<img alt=\"Unstacked data\" "
		                        + "src=\"../graphics/unstacked.gif\"/>");
		            }
		            sb.append("</a>");
		        } else {
		        	sb.append("<i>No Geo</i>");
		        }
		        if (blessfile != null) {
		        	if (blessed) {
		        		sb.append("<a href=\"../analysis-blessing/compare1.jsp?file=");
		        		sb.append(entry.getLFN());
		        		sb.append("\"");
		        		sb.append(" title=\""+ buildBlessingMetadata(entry));
		        		sb.append("\">");   
		        		sb.append("<img alt=\"Blessed data\" "
		                    + "src=\"../graphics/star.gif\"/></a>");
		        	}
		        	else {
		        		sb.append("<a href=\"../analysis-blessing/compare1.jsp?file=");
		        		sb.append(entry.getLFN());
		        		sb.append("\"");
		        		sb.append(" title=\""+ buildBlessingMetadata(entry));
		        		sb.append("\">");   
		        		sb.append("<img alt=\"Blessed data\" "
		                    + "src=\"../graphics/unblessed.gif\"/></a>");        	
		        	}
		        }
			}
		} catch (Exception e) {
			
		}
		return sb.toString();	
	}
    //EPeronja-02/18/2015: 641&645-Benchmark failure message
    public String buildBlessingMetadata(VDSCatalogEntry entry){
		String benchmarkfail = (String) entry.getTupleValue("benchmarkfail");
		String benchmarkreference = (String) entry.getTupleValue("benchmarkreference");
    	
        StringBuilder sb = new StringBuilder();
        String blessMessage = "Blessfile comment\n";
    	if (benchmarkfail == null && benchmarkreference != null) {
    		blessMessage = "This file has been blessed";
    	} 
    	if (benchmarkfail == null && benchmarkreference == null) {
    			blessMessage = "This file has been uploaded without using a benchmark";
    	}
    	if (benchmarkfail != null) {
    		blessMessage = benchmarkfail;
    	}
    	
        sb.append(blessMessage +"\n");
    	return sb.toString();
    }//end of buildBlessingMetadata 	

    protected static String formatNumber(long x) {
    	DecimalFormat df = new DecimalFormat();
    	DecimalFormatSymbols dfs = new DecimalFormatSymbols(Locale.US);
    	return df.format(x);
    }    
}//end of class BlessPlotDisplay