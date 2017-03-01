package gov.fnal.elab.cosmic.plot;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.TreeMap;
import java.lang.Math;
import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;


public class PlotData {

	private TreeMap<Integer, Detail> plotData; 
	
	public PlotData(File file, String ndx, String xaxisnum, String yaxisnum, Elab elab) throws IOException {
		String filename = file.getName();
		String legend = "";
		String xunits = "";
		String yunits = "";
		boolean drawxaxis = false;
		boolean drawyaxis = false;
		String xaxisposition = "";
		String yaxisposition = "";
		try {
			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
			if (e != null && !e.getTupleValue("name").equals("")) {
				legend = (String) e.getTupleValue("label");
				xunits = (String) e.getTupleValue("xunits");
				yunits = (String) e.getTupleValue("yunits");
				xaxisposition = (String) e.getTupleValue("xaxisposition");
				yaxisposition = (String) e.getTupleValue("yaxisposition");
				drawxaxis = (Boolean) e.getTupleValue("drawxaxis");
				drawyaxis = (Boolean) e.getTupleValue("drawyaxis");
			}
		} catch (Exception e) {
			
		}
		BufferedReader br = new BufferedReader(new FileReader(file));		
		Detail thisLineData = null;
		plotData = new TreeMap<Integer, Detail>();
		plotData = saveLineData(br, ndx, xaxisnum, yaxisnum, legend, xunits, yunits, xaxisposition, yaxisposition, drawxaxis, drawyaxis);
	}

	public TreeMap<Integer, Detail> saveLineData(BufferedReader br, String ndx, 
			String xaxisnum, String yaxisnum,
			String legend, String xunits, String yunits, 
			String xaxisposition, String yaxisposition,
			boolean drawxaxis, boolean drawyaxis) {
		Detail thisLineData = null;
		String[] split; 
		String line;
		double error = 0;
		TreeMap<Integer, Detail> plotData = new TreeMap<Integer, Detail>();
		int ts=0; 
		try {
			while ((line = br.readLine()) != null) {
				split = line.split("\t"); 
				if (split.length < 2) {
					return null;
				}
				if (split.length == 3) {
					//we are plotting the error
					error = parseToDouble(split[2]);
				}
				thisLineData = new Detail(	
						parseToDouble(split[0]),
						parseToDouble(split[1]),
						error,
						ndx,
						xaxisnum,
						yaxisnum,
						legend,
						xunits,
						yunits,
						xaxisposition,
						yaxisposition,
						drawxaxis,
						drawyaxis
				);				
				ts++;
				plotData.put(ts, thisLineData);				
			}
		} catch (Exception e) {
			return null;
		}
		return plotData;
	}
	
	public TreeMap<Integer, Detail> getTimeData() {
		return plotData;
	}
	
	public class Detail {
		private double x;
		private double y;
		private double yError;
		private String ndx;
		private String xaxisnum;
		private String yaxisnum;
		private String legend;
		private String xunits;
		private String yunits;
		private String xaxisposition;
		private String yaxisposition;
		private boolean drawxaxis;
		private boolean drawyaxis;
	
		private Detail(double x,
						 double y,
						 double error,
						 String ndx,
						 String xaxisnum,
						 String yaxisnum,
						 String legend,
						 String xunits,
						 String yunits,
						 String xaxisposition,
						 String yaxisposition,
						 boolean drawxaxis,
						 boolean drawyaxis) {
				this.x = x;
				this.y = y;
				this.ndx = ndx;
				this.xaxisnum = xaxisnum;
				this.yaxisnum = yaxisnum;
				this.legend = legend;
				if (error > 0) {
					this.yError = error;
				} else {
					this.yError = Math.sqrt(y);
				}
				this.xunits = xunits;
				this.yunits = yunits;
			    this.xaxisposition = xaxisposition;
			    this.yaxisposition = yaxisposition;
				this.drawxaxis = drawxaxis;
				this.drawyaxis = drawyaxis;				
		}

		public double getX() {
			return x; 
		}
		public double getY() {
			return y; 
		}	
		public double getYError() {
			return yError; 
		}	
		public String getNdx() {
			return ndx;
		}
		public String getXAxisNum() {
			return xaxisnum;
		}
		public String getYAxisNum() {
			return yaxisnum;
		}
		public String getXAxisPosition() {
			return xaxisposition;
		}
		public String getYAxisPosition() {
			return yaxisposition;
		}
		public String getLegend() {
			return legend;
		}
		public String getXUnits() {
			return xunits;
		}
		public String getYUnits() {
			return yunits;
		}
		public boolean getDrawXAxis() {
			return drawxaxis;
		}
		public boolean getDrawYAxis() {
			return drawyaxis;
		}
	}
	
	public double parseToDouble(String split)
	{
		double result = 0;
		try {
			result = Double.parseDouble(split);
		} catch (NumberFormatException e) {
			result = 0;
		}
		return result;
	}//end of parseToDouble	
}
