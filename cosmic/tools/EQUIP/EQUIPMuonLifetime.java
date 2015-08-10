//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the MuonLifetime tab
//
import java.awt.ComponentOrientation;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.Calendar;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.StandardXYItemRenderer;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.data.general.Dataset;
import org.jfree.data.general.DatasetChangeEvent;
import org.jfree.data.general.DatasetChangeListener;
import org.jfree.data.statistics.SimpleHistogramBin;
import org.jfree.data.statistics.SimpleHistogramDataset;
import org.jfree.data.xy.XYSeriesCollection;

  public class EQUIPMuonLifetime extends JPanel {
    JFreeChart lifetime_chart;
    ChartPanel lifetime_panel;
    XYPlot lifetime_plot;
    SimpleHistogramDataset lifetime_dataset;
    XYSeriesCollection fit_dataset;

    JFreeChart [] deltat_chart;
    ChartPanel [] deltat_panel;
    SimpleHistogramDataset [] deltat_dataset;
    java.util.Vector<Double> measurements;

    JFileChooser file_chooser = new JFileChooser();

    int channel;
    int veto;
    double window;

    public class DeltaTListener implements DatasetChangeListener {
      public void datasetChanged(DatasetChangeEvent event) {
        Dataset dataset = event.getDataset();
        Font font = new Font("SansSerif",0,18);
        for ( int i=0; i<4; i++ ) {
          if ( dataset == deltat_dataset[i] ) {
            int n = deltat_dataset[i].getItemCount(0);
            int jmost = -1;
            double ymax = 0;
            for ( int j=0; j<n; j++ ) {
              double y = deltat_dataset[i].getYValue(0,j);
              if ( jmost < 0 || y > ymax ) {
                ymax = y;
                jmost = j;
              }
            }
            int jmin = jmost - 20;
            int jmax = jmost + 20;
            if ( jmin < 0 ) jmin = 0;
            if ( jmax >= n ) jmax = n;
            double sxy = 0;
            double sy = 0;
            for ( int j=jmin; j<=jmax; j++ ) {
              double y = deltat_dataset[i].getYValue(0,j);
              double x = deltat_dataset[i].getXValue(0,j);
              sxy += x*y;
              sy += y;
            }
            if ( sy > 0 ) {
              double mean = sxy/sy;
              double dxy = 0;
              for ( int j=jmin; j<=jmax; j++ ) {
                double y = deltat_dataset[i].getYValue(0,j);
                double x = deltat_dataset[i].getXValue(0,j);
                dxy += (x-mean)*(x-mean)*y;
              }
              double rms = Math.sqrt(dxy/sy);
              XYPlot plot = (XYPlot)deltat_chart[i].getPlot();
              plot.clearAnnotations();
              XYTextAnnotation hmean = new XYTextAnnotation("Mean = "+String.format("%.3f",mean)+" \u00b1 "+String.format("%.3f",rms/Math.sqrt(sy))+" ns",
                plot.getDomainAxis().getUpperBound()*0.6,
                plot.getRangeAxis().getUpperBound()*0.66);
              hmean.setFont(font);
              plot.addAnnotation(hmean);
            }        
          }
        }
      }
    }

    public EQUIPMuonLifetime() {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      //layout.setAutoCreateGaps(true);
      //layout.setAutoCreateContainerGaps(true);
      channel = 2;
      veto = 0;
      window = 100.0;

      measurements = new java.util.Vector<Double>();
      double values [] = { };
      lifetime_dataset = new SimpleHistogramDataset("lifetime");

      for ( int j=0; j<40; j++ ) {
        lifetime_dataset.addBin(new SimpleHistogramBin(250.0*j,250.0*(j+1),true,false));
      }
      lifetime_dataset.setAdjustForBinSize(false);

      fit_dataset = new XYSeriesCollection();
      
      lifetime_chart = ChartFactory.createHistogram("Delayed coincidence",
          "Delay  (ns)","Entries per 250 ns",lifetime_dataset,
          PlotOrientation.VERTICAL,false,false,false);
      lifetime_panel = new ChartPanel(lifetime_chart);
      lifetime_panel.setMouseZoomable(false);
      lifetime_plot = (XYPlot)lifetime_chart.getPlot();
      lifetime_plot.setDataset(1,fit_dataset);
      lifetime_plot.setRenderer(1,new StandardXYItemRenderer());
      lifetime_plot.setDatasetRenderingOrder(DatasetRenderingOrder.FORWARD);
      NumberAxis lifetime_numberaxis = (NumberAxis)lifetime_plot.getRangeAxis();
      lifetime_numberaxis.setAutoRangeMinimumSize(2,true);

      deltat_dataset = new SimpleHistogramDataset [4];
      deltat_panel = new ChartPanel [4];
      deltat_chart = new JFreeChart [4];
      DeltaTListener dataset_listener = new DeltaTListener();
      for ( int i=0; i<4; i++ ) {
        deltat_dataset[i] = new SimpleHistogramDataset("deltat"+Integer.toString(i));
        deltat_dataset[i].addChangeListener(dataset_listener);

        for ( int j=0; j<160; j++ ) {
          deltat_dataset[i].addBin(new SimpleHistogramBin(-50.0+1.25*j,-50+1.25*(j+1),true,false));
        }
        deltat_dataset[i].setAdjustForBinSize(false);
        deltat_chart[i] = ChartFactory.createHistogram("Time difference Ch. "+Integer.toString(i+1)+" - Ch. "+Integer.toString(channel+1),
          "Delta T (ns)","Entries per 1.25 ns",deltat_dataset[i],
          PlotOrientation.VERTICAL,false,false,false);
        deltat_panel[i] = new ChartPanel(deltat_chart[i]);
        deltat_panel[i].setMouseZoomable(false);
        XYPlot deltat_plot = (XYPlot)deltat_chart[i].getPlot();

        XYItemRenderer renderer = deltat_plot.getRenderer();
  	    renderer.setSeriesPaint(0, EQUIP.series_color[i]);  
  	    deltat_plot.setRenderer(renderer);

  	    NumberAxis deltat_numberaxis = (NumberAxis)deltat_plot.getRangeAxis();
        deltat_numberaxis.setAutoRangeMinimumSize(2,true);
      }

      ClearHistogramListener clear_listener = new ClearHistogramListener();
      JButton clear_button = new JButton("Clear");
      clear_button.addActionListener(clear_listener);

      JLabel channel_label = new JLabel("  Channel of interest:");
      JSpinner channel_spinner = new JSpinner(new SpinnerNumberModel(channel+1,1,4,1));
      ChannelListener channel_listener = new ChannelListener();
      channel_spinner.addChangeListener(channel_listener);
      channel_spinner.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
      JLabel veto_label = new JLabel("  Veto channel:");
      JSpinner veto_spinner = new JSpinner(new SpinnerNumberModel(veto+1,1,4,1));
      VetoListener veto_listener = new VetoListener();
      veto_spinner.addChangeListener(veto_listener);
      veto_spinner.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);

      MuonOutputHandler muon_output = new MuonOutputHandler(lifetime_panel);
      EQUIP.kernel.AddOutputHandler(muon_output);

      EQUIPTools.GateWidthControl gate_control = new EQUIPTools.GateWidthControl();
      EQUIPTools.PipelineDelayControl pipeline_control = new EQUIPTools.PipelineDelayControl();

      SaveButtonListener save_listener = new SaveButtonListener();
      JButton save_button = new JButton("Save...");
      save_button.addActionListener(save_listener);
      LoadButtonListener load_listener = new LoadButtonListener();
      JButton load_button = new JButton("Load...");
      load_button.addActionListener(load_listener);
      FitButtonListener fit_listener = new FitButtonListener();
      JButton fit_button = new JButton("Fit...");
      fit_button.addActionListener(fit_listener);

      layout.setHorizontalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addComponent(deltat_panel[0],400,500,600).
              addComponent(deltat_panel[1],400,500,600).
              addComponent(deltat_panel[2],400,500,600).
              addComponent(deltat_panel[3],400,500,600)).
            addComponent(lifetime_panel,400,500,600)).
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addGroup(layout.createSequentialGroup().
                addComponent(channel_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(channel_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(veto_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(veto_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
              addGroup(layout.createSequentialGroup().
                addComponent(gate_control,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(pipeline_control,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE))).
            addGroup(layout.createSequentialGroup().
                addComponent(clear_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(fit_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(load_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(save_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE))));

      layout.setVerticalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(deltat_panel[0],150,150,150).
              addComponent(deltat_panel[1],150,150,150).
              addComponent(deltat_panel[2],150,150,150).
              addComponent(deltat_panel[3],150,150,150)).
            addComponent(lifetime_panel,600,600,600)).
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addGroup(layout.createParallelGroup().
                addComponent(channel_label,30,30,30).
                addComponent(channel_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(veto_label,30,30,30).
                addComponent(veto_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
              addGroup(layout.createParallelGroup().
                addComponent(gate_control,30,30,30).
                addComponent(pipeline_control,30,30,30))).
            addGroup(layout.createParallelGroup().
                addComponent(clear_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(fit_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(load_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(save_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE))));

    }
    public void AnalyzeEvent(java.util.Vector<EQUIPPulse> pulses) {
      if ( pulses.size() == 0 ) return;
      EQUIPPulse pmin = null;
      for ( int i=0; i<pulses.size(); i++ ) {
    	EQUIPPulse p = (EQUIPPulse)pulses.get(i);
    	System.out.println("Pulse: "+p.DumpThresholdValues());
    	if ( p.Channel() == channel ) {
          if ( pmin == null ) {
            pmin = p;
          }
          else if ( pmin.TimeUntil(p) < 0 ) {
            pmin = p;
          }
        }
      }
      if ( pmin != null ) {
        boolean [] found = { false, false, false, false };
        for ( int i=0; i<pulses.size(); i++ ) {
          EQUIPPulse p = (EQUIPPulse)pulses.get(i);
          found[p.Channel()] = true;
          if ( ! p.equals(pmin) ) {
            try {
              System.out.println("Pmin channel: "+ pmin.Channel());
              System.out.println("Pmin: "+pmin.DumpThresholdValues());
              System.out.println("p: "+p.DumpThresholdValues());
              System.out.println("Channel: " + String.valueOf(p.Channel()));
              System.out.println("Time Until: " + String.valueOf(pmin.TimeUntil(p)));
              deltat_dataset[p.Channel()].addObservation(pmin.TimeUntil(p));
            }
            catch ( Exception e ) {
            }
          }
        }
        boolean no_veto = true;
        for ( int i=0; i<4; i++ ) {
          if ( i == veto ) {
            if ( found[i] ) {
              no_veto = false;
            }
          }
          else if ( ! found[i] ) {
            no_veto = false;
          }
        }
        if ( no_veto ) {
          for ( int i=0; i<pulses.size(); i++ ) {
        	EQUIPPulse p = (EQUIPPulse)pulses.get(i);
            double dt = pmin.TimeUntil(p);
            if ( p.Channel() == pmin.Channel() && dt > window ) {
              System.out.println("Delta t = "+Double.toString(dt)+" ns - Fill!");
              measurements.add(dt);
              try {
                lifetime_dataset.addObservation(dt);
              }
              catch ( Exception e ) {
              }
            }
          }
        }
      }
    }
    public class MuonOutputHandler extends EQUIPOutputHandler {
      JPanel panel;
      java.util.Vector<EQUIPPulse> pulses;
      EQUIPPulse [] pulse;
      public MuonOutputHandler(JPanel p) {
        panel = p;
        pulses = new java.util.Vector<EQUIPPulse>();
        pulse = new EQUIPPulse [4];
      }
      final void Process(String s) {
        if ( s.length() == 74 ) {
          String [] tokens = s.split(" ");
          if ( tokens.length == 16 ) {
            int i = 0;
            long t = Long.parseLong(tokens[i++],16);
            int [] re = new int [4];
            int [] fe = new int [4];
            for ( int j=0; j<4; j++ ) {
              System.out.println(s);
              re[j] = Integer.parseInt(tokens[i++],16);
              fe[j] = Integer.parseInt(tokens[i++],16);
              if ( (re[0]&0x80) != 0 ) {
                if ( pulses.size() > 0 ) {
//
//  We should sort the list of pulses...
//
                  AnalyzeEvent(pulses);
                  pulses.clear();
                }
                pulse[j] = new EQUIPPulse(j);
              }
              else if ( pulse[j] == null ) {
                pulse[j] = new EQUIPPulse(j);
              }
              if ( (fe[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetFallingEdge(t,fe[j]);
                if ( pulse[j].Valid() ) {
                  pulses.add(pulse[j]);
                  pulse[j] = new EQUIPPulse(j);
                }
              }
              if ( (re[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetRisingEdge(t,re[j]);
              }
            }
          }
        }
      }
    }

    private class FitButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
    	  EQUIP.lifetime_fit.SetDataset(lifetime_dataset);
    	  EQUIP.lifetime_fit.SetFitDataset(fit_dataset);
    	  EQUIP.lifetime_fit.SetPlot(lifetime_plot);
    	  EQUIP.fit.setVisible(true);
      }
    }
    private class LoadButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        int iret = file_chooser.showOpenDialog((JButton)evt.getSource());
        if ( iret == JFileChooser.APPROVE_OPTION ) {
          lifetime_plot.clearAnnotations();
          File file = file_chooser.getSelectedFile();
          try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            while ( in.ready() ) {
              String text = in.readLine();
              double t = Double.parseDouble(text);
              measurements.add(t);
              lifetime_dataset.addObservation(t);
            }
            in.close();
          }
          catch ( Exception e ) {
            System.out.println("File not found...");
          }
        }
      }
    }
    private class SaveButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        int iret = file_chooser.showSaveDialog((JButton)evt.getSource());
        if ( iret == JFileChooser.APPROVE_OPTION ) {
          File file = file_chooser.getSelectedFile();
          try {
            PrintStream out = new PrintStream(new FileOutputStream(file));
            for ( int i=0; i<measurements.size(); i++ ) {
              out.println(Double.toString(measurements.get(i)));
            }
            out.close();
          }
          catch ( Exception e ) {
            System.out.println("File not found...");
          }
        }
      }
    }
    private class ClearHistogramListener implements ActionListener {
      public void actionPerformed(ActionEvent e) {
        lifetime_dataset.clearObservations();
        fit_dataset.removeAllSeries();
        measurements.clear();
        for ( int i=0; i<4; i++ ) {
          deltat_dataset[i].clearObservations();
        }
      }
    }
    private class ChannelListener implements ChangeListener {
      public void stateChanged(ChangeEvent e) {
        JSpinner spinner = (JSpinner)e.getSource();
        channel = ((SpinnerNumberModel)spinner.getModel()).getNumber().intValue()-1;
        for ( int i=0; i<4; i++ ) {
          deltat_chart[i].setTitle("Time difference Ch. "+Integer.toString(i+1)+" - Ch. "+Integer.toString(channel+1));
        }
      }
    }
    private class VetoListener implements ChangeListener {
      public void stateChanged(ChangeEvent e) {
        JSpinner spinner = (JSpinner)e.getSource();
        veto = ((SpinnerNumberModel)spinner.getModel()).getNumber().intValue()-1;
      }
    }
    public void PlotFit() {
      System.out.println("PlotFit...");
    }
  }
