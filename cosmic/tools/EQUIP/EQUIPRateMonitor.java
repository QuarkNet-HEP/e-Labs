//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the RateMonitor tab
//

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.Calendar;
import java.util.GregorianCalendar;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.DateAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.DeviationRenderer;
import org.jfree.chart.renderer.xy.StandardXYItemRenderer;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.chart.renderer.xy.DefaultXYItemRenderer;
import org.jfree.data.xy.XYIntervalSeries;
import org.jfree.data.xy.XYIntervalSeriesCollection;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.RectangleInsets;


public class EQUIPRateMonitor extends JPanel {
	XYIntervalSeries [] count_rates;
    XYIntervalSeries coincidence_rate;
    XYIntervalSeriesCollection count_dataset;
    XYIntervalSeriesCollection coincidence_dataset;
    XYSeries temperature;
    XYSeries pressure;
    XYSeriesCollection temperature_dataset;
    XYSeriesCollection pressure_dataset;
    long gps_time;
    long [] prev_count;
    double dt;
    JLabel level_label;
    
    public class RateMeasurement {
      Calendar date;
      double dt;
      double temp, pres;
      int [] dc;

      public RateMeasurement(Calendar now,double t) {
        date = now;
        dt = t;
        dc = new int [5];
        for ( int i=0; i<5; i++ ) {
          dc[i] = 0;
        }
        temp = -1;
        pres = -1;
      }
      void SetCounts(int i,int n) {
        dc[i] = n;
      }
      void SetTemperature(double t) {
        temp = t;
      }
      void SetPressure(double p) {
        pres = p;
      }
      void Print(PrintWriter out) {
        int seconds = date.get(Calendar.SECOND)+60*(date.get(Calendar.MINUTE)+60*date.get(Calendar.HOUR_OF_DAY));
        out.println(String.format("%2d %2d %4d %6d %8.2f %4.1f %6.1f  %6d %6d %6d %6d %6d",
          date.get(Calendar.MONTH)+1,date.get(Calendar.DATE),date.get(Calendar.YEAR),seconds,dt,temp,pres,dc[0],dc[1],dc[2],dc[3],dc[4]));
      }
    }
    RateMeasurement rate;
    java.util.Vector<RateMeasurement> measurements;
    JFileChooser file_chooser = new JFileChooser();

    public class FluxOutputHandler extends EQUIPOutputHandler {
      JPanel panel;
      public FluxOutputHandler(JPanel p) {
        panel = p;
      }
      final void Process(String s) {
        if ( s.startsWith("ST ") && ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
          String [] status = s.substring(3).split("[ \r\n\t]");
          //EP - this was failing when selecting Status output: Reset Scalars because
          //"ST Enabled, scalar data plus reset counters".length > 5!!!
          if ( status.length > 5 && ! s.startsWith("ST Enabled")) {
            int hour = Integer.parseInt(status[4].substring(0,2));
            int min = Integer.parseInt(status[4].substring(2,4));
            int sec = Integer.parseInt(status[4].substring(4,6));
            int day = Integer.parseInt(status[5].substring(0,2));
            int mon = Integer.parseInt(status[5].substring(2,4));
            int year = 2000+Integer.parseInt(status[5].substring(4,6));
            Calendar gps_date = new GregorianCalendar();
            gps_date.set(year,mon-1,day,hour,min,sec);  // Month starts at zero
            long new_time = gps_date.getTimeInMillis();
            if ( gps_time > 0 ) {
              dt = (new_time-gps_time)*0.001;
              if ( dt > 0 ) {
                rate = new RateMeasurement(gps_date,dt);
              }
            }
            gps_time = new_time;
            //System.out.println(s);
        
            double p = EQUIP.pfix.TruePressure(Integer.parseInt(status[0]));
            pressure.add(gps_time,p);
            if ( rate != null ) rate.SetPressure(p);

            try {
              if ( status[1].charAt(0) == '+' ) status[1] = status[1].substring(1);
              double temp = 0.1*Integer.parseInt(status[1]);
              temperature.add(gps_time,temp);
              if ( rate != null ) rate.SetTemperature(temp);
            }
            catch ( Exception e ) {
            }
          }
        }
        if ( s.startsWith("DS ") && ! s.startsWith("DS     - ") &&
             ! s.startsWith("DS 000006B4 00001413 00000D62 000006B1 00001414") ) {
          String [] counts = s.substring(3).split("[ \r\n\t]");
          for ( int i=0; i<5; i++ ) {
            if ( counts[i].startsWith("S") ) {
              counts[i] = counts[i].substring(3);
            }
            long count = Long.parseLong(counts[i],16);
            if ( dt > 0 ) {
              double d = (double)(count-prev_count[i]);
              double r = d/dt;
              double er = Math.sqrt(d)/dt;
              rate.SetCounts(i,(int)(count-prev_count[i]));
              if ( i < 4 ) {
                count_rates[i].add(gps_time,gps_time,gps_time,r,r-er,r+er);
              }
              else if ( i == 4 ) {
                coincidence_rate.add(gps_time,gps_time,gps_time,r,r-er,r+er);
              }
            }
            if (EQUIP.STChoice != null) {
	            if (!EQUIP.STChoice.equals("") && EQUIP.STChoice.equals("2")) {
	            	prev_count[i] = count;
	            }
            }
          }
          if ( rate != null ) {
            measurements.add(rate);
          }
        }
      }
    }
    private class FillRateListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          EQUIP.kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(EQUIP.frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    private class SaveRateListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {

        //int iret = file_chooser.showOpenDialog((JButton)evt.getSource());
        int iret = file_chooser.showSaveDialog((JButton)evt.getSource());
        if ( iret == JFileChooser.APPROVE_OPTION ) {
          File file = file_chooser.getSelectedFile();
          try {
            PrintWriter out = new PrintWriter(new FileWriter(file));
            for ( int i=0; i<measurements.size(); i++ ) {
              measurements.get(i).Print(out);
            }
            out.close();
          }
          catch ( Exception e ) {
            System.out.println("File not found...");
          }
        }
      }
    }
    private class ClearRateListener implements ActionListener {
      public void actionPerformed(ActionEvent e) {
        count_dataset.removeAllSeries();
        for ( int i=0; i<4; i++ ) {
          count_rates[i] = new XYIntervalSeries("Channel "+Integer.toString(i+1));
          count_dataset.addSeries(count_rates[i]);
        }
        coincidence_dataset.removeAllSeries();
        coincidence_rate = new XYIntervalSeries("Coincidence rates");
        coincidence_dataset.addSeries(coincidence_rate);
        measurements.clear();

        temperature_dataset.removeAllSeries();
        temperature = new XYSeries("Temperature");
        temperature_dataset.addSeries(temperature);

        pressure_dataset.removeAllSeries();
        pressure = new XYSeries("Pressure");
        pressure_dataset.addSeries(pressure);
      }
    }
    
    public void update_coincidence(String coincidence) {
    	String coincidenceLabel = "";
    	if (coincidence.equals("1")) {
    		coincidenceLabel = "Single";
    	} else if (coincidence.equals("2")) {
    		coincidenceLabel = "Two-fold";
    	} else if (coincidence.equals("3")) {
    		coincidenceLabel = "Three-fold";
    	} else if (coincidence.equals("4")) {
    		coincidenceLabel = "Four-fold";
    	}
    	level_label.setText("       Coincidence level:" + coincidenceLabel);
    }
    
    public EQUIPRateMonitor() {
      gps_time = 0;
      dt = 0;
      prev_count = new long [5];
      for ( int i=0; i<5; i++ ) {
        prev_count[i] = 0;
      }
      measurements = new java.util.Vector<RateMeasurement>();

      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      count_rates = new XYIntervalSeries[4];
      coincidence_rate = new XYIntervalSeries("Coincidence rates");
      for ( int i=0; i<4; i++ ) {
        count_rates[i] = new XYIntervalSeries("Channel "+Integer.toString(i+1));
      }
      count_dataset = new XYIntervalSeriesCollection();
      for ( int i=0; i<4; i++ ) {
        count_dataset.addSeries(count_rates[i]);
      }
      coincidence_dataset = new XYIntervalSeriesCollection();
      coincidence_dataset.addSeries(coincidence_rate);

      temperature = new XYSeries("Temperature");
      pressure = new XYSeries("Pressure");
      temperature_dataset = new XYSeriesCollection();
      pressure_dataset = new XYSeriesCollection();
      temperature_dataset.addSeries(temperature);
      pressure_dataset.addSeries(pressure);

      JFreeChart count_chart = ChartFactory.createXYLineChart("Count rates (Hz)", "GPS time", "Rate (Hz)",
        count_dataset, PlotOrientation.VERTICAL, true, true, false);
      count_chart.setBackgroundPaint(Color.white);   
      XYPlot count_xyplot = (XYPlot)count_chart.getPlot();   
      count_xyplot.setBackgroundPaint(Color.lightGray);   
      count_xyplot.setAxisOffset(new RectangleInsets(5D, 5D, 5D, 5D));   
      count_xyplot.setDomainGridlinePaint(Color.white);   
      count_xyplot.setRangeGridlinePaint(Color.white);   
      DeviationRenderer count_deviationrenderer = new DeviationRenderer(true, false);   
      count_deviationrenderer.setSeriesStroke(0, new BasicStroke(3F, 1, 1));   
      count_deviationrenderer.setSeriesStroke(0, new BasicStroke(3F, 1, 1));   
      count_deviationrenderer.setSeriesStroke(1, new BasicStroke(3F, 1, 1));   
      count_deviationrenderer.setSeriesStroke(2, new BasicStroke(3F, 1, 1));   
      count_deviationrenderer.setSeriesStroke(3, new BasicStroke(3F, 1, 1));   
      count_deviationrenderer.setSeriesFillPaint(0, new Color(255, 200, 200));   
      count_deviationrenderer.setSeriesFillPaint(1, new Color(200, 255, 200)); 
      count_deviationrenderer.setSeriesFillPaint(2, new Color(200, 200, 255)); 
      count_deviationrenderer.setSeriesFillPaint(3, new Color(200, 255, 255)); 

      count_xyplot.setRenderer(count_deviationrenderer);
      XYItemRenderer color_renderer = count_xyplot.getRenderer();
      for (int i=0; i < 4; i++) {
	      color_renderer.setSeriesPaint(i, EQUIP.series_color[i]);
      }
      NumberAxis count_numberaxis = (NumberAxis)count_xyplot.getRangeAxis();   
      //count_numberaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
      count_numberaxis.setAutoTickUnitSelection(true);
      count_numberaxis.setAutoRangeIncludesZero(false);   
      count_xyplot.setDomainAxis(new DateAxis("GPS time"));

      JFreeChart temperature_chart = ChartFactory.createXYLineChart("Temperature/Pressure", "GPS time", "Temperature (deg C)",
        temperature_dataset, PlotOrientation.VERTICAL, true, true, false);
      temperature_chart.setBackgroundPaint(Color.white);
      XYPlot temperature_xyplot = (XYPlot)temperature_chart.getPlot();
      temperature_xyplot.setBackgroundPaint(Color.lightGray);
      temperature_xyplot.setAxisOffset(new RectangleInsets(5D, 5D, 5D, 5D));
      temperature_xyplot.setDomainGridlinePaint(Color.white);
      temperature_xyplot.setRangeGridlinePaint(Color.white);
      NumberAxis temperature_numberaxis = (NumberAxis)temperature_xyplot.getRangeAxis();
      temperature_numberaxis.setRange(0,50);
      temperature_numberaxis.setAutoRangeMinimumSize(10,false);
      temperature_numberaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
      temperature_xyplot.setDomainAxis(new DateAxis("GPS time"));

      NumberAxis pressure_numberaxis = new NumberAxis("Pressure (hPa)");
      pressure_numberaxis.setAutoRangeIncludesZero(false);
      pressure_numberaxis.setRange(980,1050);
      pressure_numberaxis.setAutoRangeMinimumSize(10,false);

      temperature_xyplot.setRangeAxis(1,pressure_numberaxis);
      temperature_xyplot.setDataset(1,pressure_dataset);
      temperature_xyplot.mapDatasetToRangeAxis(1,1);
      XYItemRenderer renderer = new StandardXYItemRenderer();
      temperature_xyplot.setRenderer(1,renderer);
      
      JFreeChart coincidence_chart = ChartFactory.createXYLineChart("Coincidence rate (Hz)", "GPS time", "Rate (Hz) ",
        coincidence_dataset, PlotOrientation.VERTICAL, false, true, false);
      coincidence_chart.setBackgroundPaint(Color.white);   
      XYPlot coincidence_xyplot = (XYPlot)coincidence_chart.getPlot();   
      coincidence_xyplot.setBackgroundPaint(Color.lightGray);   
      coincidence_xyplot.setAxisOffset(new RectangleInsets(5D, 5D, 5D, 5D));   
      coincidence_xyplot.setDomainGridlinePaint(Color.white);   
      coincidence_xyplot.setRangeGridlinePaint(Color.white);   
      DeviationRenderer coincidence_deviationrenderer = new DeviationRenderer(true, false);   
      coincidence_deviationrenderer.setSeriesStroke(0, new BasicStroke(3F, 1, 1));   
      coincidence_deviationrenderer.setSeriesStroke(0, new BasicStroke(3F, 1, 1));   
      coincidence_deviationrenderer.setSeriesStroke(1, new BasicStroke(3F, 1, 1));   
      coincidence_deviationrenderer.setSeriesFillPaint(0, new Color(255, 200, 200));   
      coincidence_deviationrenderer.setSeriesFillPaint(1, new Color(200, 200, 255));   
      coincidence_xyplot.setRenderer(coincidence_deviationrenderer);   
      NumberAxis coincidence_numberaxis = (NumberAxis)coincidence_xyplot.getRangeAxis();   
      //coincidence_numberaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
      coincidence_numberaxis.setAutoTickUnitSelection(true);
      coincidence_numberaxis.setAutoRangeIncludesZero(false);   
      coincidence_xyplot.setDomainAxis(new DateAxis("GPS time"));   

      ChartPanel count_panel = new ChartPanel(count_chart);
      ChartPanel tp_panel = new ChartPanel(temperature_chart);
      ChartPanel coincidence_panel = new ChartPanel(coincidence_chart);

      FluxOutputHandler flux_handler = new FluxOutputHandler(this);
      EQUIP.kernel.AddOutputHandler(flux_handler);

      ClearRateListener clear_listener = new ClearRateListener();
      JButton clear_button = new JButton("Clear");
      clear_button.addActionListener(clear_listener);

      FillRateListener fill_listener = new FillRateListener();
      JButton fill_button = new JButton("Fill");
      fill_button.addActionListener(fill_listener);

      level_label = new JLabel("       Coincidence level:");
      Font level_font = new Font("Serif", Font.BOLD, 20);
      level_label.setFont(level_font);
      
      SaveRateListener save_listener = new SaveRateListener();
      JButton save_button = new JButton("Save...");
      save_button.addActionListener(save_listener);

      layout.setHorizontalGroup(
        layout.createParallelGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(count_panel,600,600,600).
              addComponent(tp_panel,600,600,600)).
            addComponent(coincidence_panel,1205,1205,1205)).
          addGroup(layout.createSequentialGroup().
            addComponent(fill_button).
            addComponent(save_button).
            addComponent(clear_button).addComponent(level_label)));
      layout.setVerticalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
            addComponent(count_panel,310,310,310).
              addComponent(tp_panel,310,310,310)).
            addComponent(coincidence_panel,350,350,350)).
          addGroup(layout.createParallelGroup().
            addComponent(fill_button).
            addComponent(save_button).
            addComponent(clear_button).addComponent(level_label)));
    }
  }


