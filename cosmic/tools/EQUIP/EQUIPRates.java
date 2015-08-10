//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the Rates tab
//
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GradientPaint;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.Timer;

import org.jfree.chart.ChartColor;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.plot.dial.ArcDialFrame;
import org.jfree.chart.plot.dial.DialBackground;
import org.jfree.chart.plot.dial.DialPlot;
import org.jfree.chart.plot.dial.DialPointer;
import org.jfree.chart.plot.dial.StandardDialScale;
import org.jfree.chart.renderer.xy.XYErrorRenderer;
import org.jfree.data.general.DefaultValueDataset;
import org.jfree.data.xy.YIntervalSeries;
import org.jfree.data.xy.YIntervalSeriesCollection;
import org.jfree.ui.GradientPaintTransformType;
import org.jfree.ui.StandardGradientPaintTransformer;

public class EQUIPRates extends JPanel {
    DefaultValueDataset dial_dataset;
    YIntervalSeries [] rate_series;
    YIntervalSeriesCollection rate_dataset;
    JFreeChart rate_chart;
    ChartPanel rate_panel;
    NumberAxis xaxis;

    JButton start_button;
    JButton stop_button;
    JButton add_button;
    JButton clear_button;
    JTextField time_text;
    JTextField [] count_text;
    JTextField [] rate_text;
    JCheckBox [] graph_check;
    JTextField value_text;
    Timer timer;
    CheckScalers timer_task;
    String time_string;
    float time_left;
    float time_step;
    float elapsed_time;
    boolean active;
    boolean last_one;
    boolean first_one;
    int [] count;
    int [] initial_count;
    int [] final_count;

    public class RatesOutputHandler extends EQUIPOutputHandler {
      final void Process(String s) {
        if ( ! active ) return;
        if ( s.startsWith("DS S0=") ) {
          String [] token = s.substring(3).split("[ \r\n\t]");
          for ( int i=0; i<5; i++ ) {
            if ( token[i].startsWith("S") ) {
              count[i] = Integer.parseInt(token[i].substring(3),16)-initial_count[i];
              count_text[i].setText(Integer.toString(count[i]));
              float rate = 0;
              if ( elapsed_time > 0 ) {
                rate = (float)count[i]/elapsed_time;
              }
              rate_text[i].setText(String.format("%.2f",rate));
              if ( last_one ) {
                active = false;
              }
              else {
                dial_dataset.setValue(rate);
              }
            }
          }
        }
        else if ( s.startsWith("DS ") && ! s.startsWith("DS     - ") &&
                  ! s.startsWith("DS 000006B4 00001413 00000D62 000006B1 00001414") ) {
          String [] token = s.substring(3).split("[ \r\n\t]");
          for ( int i=0; i<5; i++ ) {
            if ( first_one ) {
              initial_count[i] = Integer.parseInt(token[i],16);
              if ( i == 4 ) first_one = false;
            }
            if ( last_one ) {
              final_count[i] = Integer.parseInt(token[i],16);
              active = false;
            }
            count[i] = Integer.parseInt(token[i],16)-initial_count[i];
            count_text[i].setText(Integer.toString(count[i]));
            float rate = 0;
            if ( elapsed_time > 0 ) {
              rate = (float)count[i]/elapsed_time;
            }
            rate_text[i].setText(String.format("%.2f",rate));
          }
        }
        else if ( s.startsWith("ST ") && ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
        }
      }
    }

    private class StartButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        add_button.setEnabled(false);
        clear_button.setEnabled(false);
        time_text.setEditable(false);
        time_string = time_text.getText();
        time_left = Float.parseFloat(time_string);
        elapsed_time = 0;
        active = true;
        first_one = true;
        last_one = false;
        try {
        	EQUIP.kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(EQUIP.frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
        timer.start();
      }
    }
    private class StopButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        timer.stop();
        time_text.setEditable(true);
        time_text.setText(time_string);
        last_one = true;
        try {
        	EQUIP.kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(EQUIP.frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
        add_button.setEnabled(true);
        clear_button.setEnabled(true);
      }
    }
    private class GraphAxisListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        xaxis.setLabel(((JTextField)evt.getSource()).getText());
      }
    }

    private class GraphAddListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        double x = Double.parseDouble(value_text.getText());
        for ( int i=0; i<5; i++ ) {
          if ( graph_check[i].isSelected() ) {
            double y = Double.parseDouble(rate_text[i].getText());
            double z = Double.parseDouble(count_text[i].getText());
            double dt = z/y;
            double ey = Math.sqrt(z)/dt;
            rate_series[i].add(x,y,y-ey,y+ey);
          }
        }
      }
    }

    private class GraphClearListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        for ( int i=0; i<5; i++ ) {
          rate_series[i].clear();
        }
      }
    }

    class CheckScalers implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        time_left -= time_step;
        elapsed_time += time_step;
        if ( time_left < 0 ) {
          if ( ! last_one ) {
            last_one = true;
            try {
              EQUIP.kernel.sendCommand("ST");
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(EQUIP.frame,
                "Error writing to serial port.",
                "Serial port error",JOptionPane.WARNING_MESSAGE);
            }
          }
          else if ( time_left > -1 ) {
            dial_dataset.setValue(0.5*(float)dial_dataset.getValue().floatValue());
          }
          else {  
            timer.stop();
            time_text.setEditable(true);
            time_text.setText(time_string);
            add_button.setEnabled(true);
            clear_button.setEnabled(true);
          }
        }
        else {
          time_text.setText(String.format("%.1f",time_left));
        }
        try {
        	EQUIP.kernel.sendCommand("DS");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(EQUIP.frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }

    public EQUIPRates() {

      time_step = 0.1F;
      timer_task = new CheckScalers();
      timer = new Timer((int)(time_step*1000),timer_task);

      active = false;
      count = new int [5];
      initial_count = new int [5];
      final_count = new int [5];

      RatesOutputHandler rate_handler = new RatesOutputHandler();
      EQUIP.kernel.AddOutputHandler(rate_handler);

      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      GridLayout table_layout = new GridLayout(6,4,10,5);
      JPanel table = new JPanel(table_layout);

      JLabel [] column_labels = new JLabel [5];
      column_labels[0] = new JLabel();
      column_labels[1] = new JLabel("Count");
      column_labels[2] = new JLabel("Rate (Hz)");
      column_labels[3] = new JLabel("Graph");
      for ( int i=0; i<4; i++ ) {
        column_labels[i].setPreferredSize(new Dimension(80,20));
        column_labels[i].setMinimumSize(new Dimension(70,15));
        column_labels[i].setMaximumSize(new Dimension(90,25));
        table.add(column_labels[i]);
      }

      dial_dataset = new DefaultValueDataset(0.0);
      DialPlot rate_dial = new DialPlot();
      rate_dial.setView(0.20999999999999999D, 0.0D, 0.57999999999999996D, 0.29999999999999999D);
      rate_dial.setDataset(dial_dataset);
      ArcDialFrame arc_dial_frame = new ArcDialFrame(55,70);
      arc_dial_frame.setInnerRadius(0.65);
      arc_dial_frame.setOuterRadius(0.95);
      arc_dial_frame.setForegroundPaint(Color.lightGray);
      arc_dial_frame.setStroke(new BasicStroke(1F));
      rate_dial.setDialFrame(arc_dial_frame);
      GradientPaint gradient_paint = new GradientPaint(new java.awt.Point(),new Color(255,255,255),new java.awt.Point(),new Color(180,180,180));
      DialBackground dial_background = new DialBackground(gradient_paint);
      dial_background.setGradientPaintTransformer(new StandardGradientPaintTransformer(GradientPaintTransformType.VERTICAL));
      rate_dial.addLayer(dial_background);
      StandardDialScale standard_dial_scale = new StandardDialScale(0,100,115,-50,10,4);
      standard_dial_scale.setTickRadius(0.92D);
      standard_dial_scale.setTickLabelOffset(0.080000000000000007D);
      standard_dial_scale.setMajorTickIncrement(25D);
      rate_dial.addScale(0,standard_dial_scale);
      DialPointer.Pin pin = new DialPointer.Pin();
      pin.setRadius(0.81999999999999995D);
      rate_dial.addLayer(pin);
      JFreeChart dial_chart = new JFreeChart(rate_dial);
      ChartPanel dial_panel = new ChartPanel(dial_chart);
      dial_panel.setPreferredSize(new Dimension(300,150));
      dial_panel.setMinimumSize(new Dimension(300,150));
      dial_panel.setMaximumSize(new Dimension(300,150));

      count_text = new JTextField [5];
      rate_text = new JTextField [5];
      graph_check = new JCheckBox [5];
      JLabel channel_label [] = new JLabel [5];
      for ( int i=0; i<5; i++ ) {

        String label;
        if ( i == 4 ) {
          label = "Coincidence:";
        }
        else {
          label = "Channel "+Integer.toString(i+1)+":";
        }
        channel_label[i] = new JLabel(label);
        channel_label[i].setPreferredSize(new Dimension(80,20));
        channel_label[i].setMinimumSize(new Dimension(70,15));
        channel_label[i].setMaximumSize(new Dimension(90,25));
        
        count_text[i] = new JTextField();
        count_text[i].setEditable(false);
        count_text[i].setPreferredSize(new Dimension(80,20));
        count_text[i].setMinimumSize(new Dimension(70,15));
        count_text[i].setMaximumSize(new Dimension(90,25));
        rate_text[i] = new JTextField();
        rate_text[i].setEditable(false);
        rate_text[i].setPreferredSize(new Dimension(80,20));
        rate_text[i].setMinimumSize(new Dimension(70,15));
        rate_text[i].setMaximumSize(new Dimension(90,25));
        graph_check[i] = new JCheckBox();
        graph_check[i].setPreferredSize(new Dimension(40,20));
        graph_check[i].setMinimumSize(new Dimension(35,15));
        graph_check[i].setMaximumSize(new Dimension(45,25));
        table.add(channel_label[i]);
        table.add(count_text[i]);
        table.add(rate_text[i]);
        table.add(graph_check[i]);
      }
      table.setPreferredSize(new Dimension(80*4,20*6));
      table.setMinimumSize(new Dimension(70*4,15*6));
      table.setMaximumSize(new Dimension(90*4,25*6));

      JLabel time_label = new JLabel("Time (sec):");
      time_string = "30.0";
      time_text = new JTextField(time_string);
      time_text.setEditable(true);
      start_button = new JButton("Start");
      start_button.addActionListener(new StartButtonListener());
      start_button.setBackground(new ChartColor(100,200,100));
      stop_button = new JButton("Stop");
      stop_button.addActionListener(new StopButtonListener());
      stop_button.setBackground(new ChartColor(250,80,80));

      JLabel graph_label = new JLabel("Independent variable:");
      JTextField graph_text = new JTextField("(x-axis title)");
      graph_text.addActionListener(new GraphAxisListener());
      JLabel value_label = new JLabel("  Value:");
      value_text = new JTextField("0.0");
      add_button = new JButton("Add");
      add_button.addActionListener(new GraphAddListener());
      clear_button = new JButton("Clear");
      clear_button.addActionListener(new GraphClearListener());

      xaxis = new NumberAxis(graph_text.getText());
      xaxis.setAutoRangeIncludesZero(false);
      NumberAxis yaxis = new NumberAxis("Rate (Hz)");
      yaxis.setAutoRangeIncludesZero(true);

      XYErrorRenderer xy_error_renderer = new XYErrorRenderer();
      rate_dataset = new YIntervalSeriesCollection();
      XYPlot xy_plot = new XYPlot(rate_dataset,xaxis,yaxis,xy_error_renderer);
      rate_chart = new JFreeChart("Count rates",xy_plot);
      rate_panel = new ChartPanel(rate_chart);
      rate_series = new YIntervalSeries [5];
      for ( int i=0; i<5; i++ ) {
        if ( i < 4 ) {
          rate_series[i] = new YIntervalSeries("Channel "+Integer.toString(i+1));
        }
        else {
          rate_series[i] = new YIntervalSeries("Coincidence");
        }
        rate_dataset.addSeries(rate_series[i]);
      }

      EQUIPTools.CoincidenceControls coinc_panel = new EQUIPTools.CoincidenceControls();
      coinc_panel.setBorder(BorderFactory.createTitledBorder("Trigger"));

      layout.setHorizontalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addComponent(table).
              addComponent(coinc_panel)).
            addComponent(dial_panel)).
          addGroup(layout.createSequentialGroup().
            addComponent(time_label).
            addComponent(time_text,60,60,60).
            addComponent(start_button).
            addComponent(stop_button)).
          addGroup(layout.createSequentialGroup().
            addComponent(graph_label).
            addComponent(graph_text).
            addComponent(value_label).
            addComponent(value_text).
            addComponent(add_button).
            addComponent(clear_button)).
          addComponent(rate_panel));

      layout.setVerticalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(table).
              addComponent(coinc_panel)).
            addComponent(dial_panel)).
            addGroup(layout.createParallelGroup().
              addComponent(time_label).
              addComponent(time_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(start_button).
              addComponent(stop_button)).
            addGroup(layout.createParallelGroup().
              addComponent(graph_label).
              addComponent(graph_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(value_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(value_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(add_button).
              addComponent(clear_button)).
            addComponent(rate_panel));
    }
  }
