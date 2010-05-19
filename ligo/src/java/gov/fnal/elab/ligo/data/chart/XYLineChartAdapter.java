package gov.fnal.elab.ligo.data.chart;

import com.googlecode.charts4j.*;

import gov.fnal.elab.expression.data.engine.DataSet;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class XYLineChartAdapter {

	public static XYLineChart newXYLineChart(DataSet... dataSets) {
		List<Data> dataScaledY = null; 
		List<XYLine> lines = new ArrayList<XYLine>();
		List<List<Number>> dataY = new ArrayList<List<Number>>(); 
		List<Data> dataX = new ArrayList<Data>(); 
		for (DataSet ds : dataSets) {
			List<Number> tempListY = new ArrayList<Number>();
			List<Number> tempListX = new ArrayList<Number>();
			for (int i=0; i < ds.size(); ++i) {
				tempListX.add(ds.getX(i));
				tempListY.add(ds.getY(i));
			}
			dataX.add(Data.newData(tempListX));
			dataY.add(tempListY);
		}
		
		// Scale the data! 
		dataScaledY = DataUtil.scale(dataY);
		
		for (int i=0; i < dataX.size(); ++i) {
			lines.add(Plots.newXYLine(dataX.get(i), dataScaledY.get(i)));
		}
		
		return GCharts.newXYLineChart((XYLine[]) lines.toArray());
		
	}
	
}
