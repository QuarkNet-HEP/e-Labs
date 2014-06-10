//
//    CosmicRayDetector 2.0 - Java interface for QuarkNet detector hardware
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//
//    Version 2.00 - June, 2012
//       First released during the Summer 2012 Quarnet Workshop
//    Version 2.01 - January, 2013
//       Modified to allow the barometer to work like an
//       altimeter.  This was not entirely successful.
//

import javax.swing.*;
import javax.swing.event.*;
import javax.swing.GroupLayout;
import javax.swing.AbstractButton.*;
import java.awt.*;
import java.net.*;
import java.io.*;
import java.util.*;
import javax.swing.Timer;
import java.awt.event.*;
import java.lang.Math;
import java.text.*;

import org.jfree.chart.*;
import org.jfree.chart.plot.*;
import org.jfree.chart.axis.*;
import org.jfree.chart.plot.dial.*;
import org.jfree.chart.renderer.xy.DeviationRenderer;
import org.jfree.data.xy.*;
import org.jfree.data.general.*;
import org.jfree.data.statistics.*;
import org.jfree.ui.*;
import org.jfree.data.time.*;
import org.jfree.chart.renderer.xy.*;
import org.jfree.data.function.*;
import org.jfree.chart.annotations.*;

import org.freehep.math.minuit.*;

public class CosmicRayDetector extends JPanel {

  static JFrame frame;
  static JDialog title;
  static JDialog fit;
  static LifetimeFitControls lifetime_fit;

  CosmicRayDetectorKernel kernel;
  ControlPanel control_panel;
  PerformancePanel performance_panel;
  MuonLifetimePanel lifetime_panel;
  RatesPanel rates_panel;
  FluxPanel flux_panel;
  AirShowerPanel air_shower_panel;
  GeometryPanel map_panel;
  String default_port;

  PressureFixer pfix;

  public class PressureFixer {
    static final double p0 = 1014.54;
    static final int q0 = 1520;
    static final double slope = 0.367632;
    static final double dpmax = 75.0;
    static final int dq = 100;
    int q;

    public PressureFixer() {
      q = 1520;
    }
    int DacValue() {
      return q;
    }
    void SetDac(int dac) {
      q = dac;
//      System.out.println("PressureFixer::SetDac("+dac+")...");
    }
    final void Increment() {
      q += dq;
    }
    final void Decrement() {
      q -= dq;
    }
    final double TruePressure(double raw) {
      return raw + slope*(q-q0);
    }
    final int Adjust(double raw) {
      double dp = raw - p0;
//  System.out.println("PressureFixer::Adjust() - dp = "+dp);
      if ( dp < -dpmax ) {
        Decrement();
        return DacValue();
      }
      else if ( dp > dpmax ) {
        Increment();
        return DacValue();
      }
      return 0;
    }
  }

  public class AllOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextArea pane;
    int total;
    public static final int max = 4*65536;
    public AllOutputHandler(JTextArea p) {
      pane = p;
      total = 0;
    }
    final void Process(String s) {
      if ( total > max ) {
        pane.setText(pane.getText().substring(max/2));
        total -= max/2;
      }
      pane.append(s);
      total += s.length();
      pane.setCaretPosition(total);
    }
  }

  public class SerialNumberOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public SerialNumberOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String sn_string = "Serial#=";
      int i = s.indexOf(sn_string);
      if ( i >= 0 ) {
        i += sn_string.length();
        pane.setText(s.substring(i,i+4));
      }
    }
  }

  public class GpsStatusOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public GpsStatusOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String status_string = "Status:    ";
      int i = s.indexOf(status_string);
      if ( i >= 0 ) {
        i += status_string.length();
        pane.setText(s.substring(i));
      }
    }
  }
  public class GpsSatsOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public GpsSatsOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String sats_string = "Sats used: ";
      int i = s.indexOf(sats_string);
      if ( i >= 0 ) {
        i += sats_string.length();
        pane.setText(s.substring(i,i+2));
      }
    }
  }
  public class TemperatureOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public TemperatureOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      if ( s.startsWith("ST ") && ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
        String [] field = s.substring(3).split("[ \r\n\t]");
        if ( field.length == 13 ) {
          try {
            if ( field[1].charAt(0) == '+' ) field[1] = field[1].substring(1);
            int temp = Integer.parseInt(field[1]);
            if ( temp > -2000 ) {
              pane.setText(Integer.toString(temp/10)+"."+Integer.toString(Math.abs(temp%10)));
            }
            else {
              pane.setText("---");
            }
          }
          catch ( Exception e ) {
            System.out.println("Error parsing temperature: '"+field[1]+"'");
            pane.setText("---");
          }
        }
      }
    }
  }
  public class PressureOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public PressureOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      if ( s.startsWith("ST ") && ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
        String [] field = s.substring(3).split("[ \r\n\t]");
        if ( field.length == 13 ) {
//  System.out.println("Pressure = "+field[0]);
          double praw = Double.parseDouble(field[0]);
          pane.setText(Double.toString(pfix.TruePressure(praw)));
          int dac = pfix.Adjust(praw);
          if ( dac != 0 ) {
//             System.out.println("New DAC value = "+dac);
            try {
              kernel.sendCommand("BA "+Integer.toString(dac));
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(frame,"Error writing to serial port.",
                                    "Serial port error",
                                    JOptionPane.WARNING_MESSAGE);
            }
          }
        }
      }
    }
  }
  public class DacOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public DacOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      if ( s.startsWith("BA ") && s.length() < 16 ) {
        String [] field = s.substring(3).split("[ \r\n\t]");
        if ( field.length == 1) {
//  System.out.println("DAC = "+field[0]);
          pfix.SetDac(Integer.parseInt(field[0]));
          pane.setText(field[0]);
        }
      }
    }
  }

  public class GpsTimeOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public GpsTimeOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String time_string = " Date+Time: ";
      int i = s.indexOf(time_string);
      if ( i >= 0 ) {
        i += time_string.length();
        pane.setText(s.substring(i));
      }
    }
  }
  public class LatitudeOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public LatitudeOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String lat_string = "Latitude:  ";
      int i = s.indexOf(lat_string);
      if ( i >= 0 ) {
        i += lat_string.length();
        pane.setText(s.substring(i,i+16));
      }
    }
  }

  public class LongitudeOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public LongitudeOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String lon_string = "Longitude: ";
      int i = s.indexOf(lon_string);
      if ( i >= 0 ) {
        i += lon_string.length();
        pane.setText(s.substring(i,i+16));
      }
    }
  }

  public class AltitudeOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public AltitudeOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String alt_string = "Altitude:  ";
      int i = s.indexOf(alt_string);
      if ( i >= 0 ) {
        i += alt_string.length();
        pane.setText(s.substring(i,i+8));
      }
    }
  }
  public class PulserVoltageOutputHandler extends CosmicRayDetectorOutputHandler {
    JTextField pane;
    public PulserVoltageOutputHandler(JTextField p) {
      pane = p;
    }
    final void Process(String s) {
      String tv_string = "TV TV=";
      String mv_string = "mV";
      int i = s.indexOf(tv_string);
      int j = s.indexOf(mv_string);
      if ( i >= 0 ) {
        i += tv_string.length();
        if ( j >= 0 ) {
          pane.setText(s.substring(i,j));
        }
        else {
          pane.setText(s.substring(i));
        }
      }
    }
  }

  public class ScalerOutputHandler extends CosmicRayDetectorOutputHandler {
    JPanel panel;
    public ScalerOutputHandler(JPanel p) {
      panel = p;
    }
    final void Process(String s) {
      if ( s.startsWith("DS ") && ! s.startsWith("DS     - ") &&
           ! s.startsWith("DS 000006B4 00001413 00000D62 000006B1 00001414") ) {
        String [] counts = s.substring(3).split("[ \r\n\t]");
        for ( int i=0; i<counts.length; i++ ) {
          if ( counts[i].startsWith("S") ) {
            counts[i] = counts[i].substring(3);
          }
          if ( i+1 < panel.getComponentCount() ) {
            ((JTextField)(panel.getComponent(i+1))).setText(Integer.toString(Integer.parseInt(counts[i],16)));
          }
        }
      }
    }
  }

  public class ControlRegOutputHandler extends CosmicRayDetectorOutputHandler {
    JPanel panel;
    public ControlRegOutputHandler(JPanel p) {
      panel = p;
    }
    final void Process(String s) {
      if ( s.startsWith("WC ") && ! s.startsWith("WC a d - ") ||
           s.startsWith("DC ") && ! s.startsWith("DC     - ") ) {
        String [] counts = s.substring(3).split("[ \r\n\t]");
        for ( int i=0; i<counts.length; i++ ) {
          int j = counts[i].indexOf('=');
          if ( j > 0 ) {
            int chan = counts[i].charAt(j-1)-'0';
            if ( chan+1 < panel.getComponentCount() ) {
              ((JTextField)panel.getComponent(chan+1)).setText(counts[i].substring(j+1,j+3));
            }
          }
        }
      }
    }
  }

  public class GateWidthControl extends JPanel {
    public class GateWidthOutputHandler extends CosmicRayDetectorOutputHandler {
      JTextField pane;
      public GateWidthOutputHandler(JTextField p) {
        pane = p;
      }
      final void Process(String s) {
        if ( s.startsWith("WC ") && ! s.startsWith("WC a d - ") ||
             s.startsWith("DC ") && ! s.startsWith("DC     - ") ) {
          int prev = 0;
          int high = 0;
          int low = 0;
          try {
            prev = Integer.parseInt(pane.getText());
            high = (prev/10)>>8;
            low = (prev/10)&0xff;
          }
          catch ( Exception e ) {
          }       
          String [] counts = s.substring(3).split("[ \r\n\t]");
          for ( int i=0; i<counts.length; i++ ) {
            int j = counts[i].indexOf('=');
            if ( j > 0 ) {
              int chan = counts[i].charAt(j-1)-'0';
              int value = Integer.parseInt(counts[i].substring(j+1,j+3),16);
              if ( chan == 2 ) {
                int data = ((high<<8)|value)*10;
                low = value;
                pane.setText(Integer.toString(data));
              }
              else if ( chan == 3 ) {
                int data = ((value<<8)|low)*10;
                high = value;
                pane.setText(Integer.toString(data));
              }
            }
          }
        }
      }
    }
    private class GateWidthListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        int data = Integer.parseInt(evt.getActionCommand())/10;
        if ( data > 65535 ) data = 65535;
        try {
          kernel.sendCommand("WC 3 "+Integer.toHexString(data>>8));
          kernel.sendCommand("WC 2 "+Integer.toHexString(data&0xff));
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,"Error writing to serial port.",
                                    "Serial port error",
                                    JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    public GateWidthControl() {
      GroupLayout gate_layout = new GroupLayout(this);
      setLayout(gate_layout);
      gate_layout.setAutoCreateGaps(true);
      gate_layout.setAutoCreateContainerGaps(true);

      JLabel gate_label = new JLabel("  Gate width:");
      JTextField gate_text = new JTextField();
      gate_text.setEditable(true);
      gate_text.setHorizontalAlignment(JTextField.RIGHT);
      GateWidthListener gate_width_listener = new GateWidthListener();
      gate_text.addActionListener(gate_width_listener);
      GateWidthOutputHandler gate_width_handler = new GateWidthOutputHandler(gate_text);
      kernel.AddOutputHandler(gate_width_handler);
      JLabel gns_label = new JLabel(" ns");

      gate_layout.setHorizontalGroup(
        gate_layout.createSequentialGroup().
          addComponent(gate_label).
          addComponent(gate_text,50,50,50).
          addComponent(gns_label));
      gate_layout.setVerticalGroup(
        gate_layout.createParallelGroup().
          addComponent(gate_label).
          addComponent(gate_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(gns_label));
    }
  }

  public class StatusControl extends JPanel {
    JTextField time_interval;
    JComboBox status_choice;
    boolean updating;
    public class StatusOutputHandler extends CosmicRayDetectorOutputHandler {
      final void Process(String s) {
        if ( s.startsWith("ST ") && s.length() < 10 ) {
          String [] tokens = s.substring(3).split("[ \r\n\t]");
          if ( tokens.length > 0 ) {
            if ( Character.isDigit(tokens[0].charAt(0)) ) {
              int status = Integer.parseInt(tokens[0]);
              updating = true;
              status_choice.setSelectedIndex(status);
              if ( tokens.length > 1 ) {
                int time = Integer.parseInt(tokens[1]);
                time_interval.setText(Integer.toString(time));
              }
              updating = false;
            }
          }
        }
      }
    }
    private class StatusControlListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        if ( updating ) return;
        int time = Integer.parseInt(time_interval.getText());
        int choice = status_choice.getSelectedIndex();
        try {
          kernel.sendCommand("ST "+Integer.toString(choice)+" "+Integer.toString(time));
        }
        catch ( Exception e2 ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }

    public StatusControl() {
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      updating = false;

      JLabel status_label = new JLabel("Status output: ");
      JLabel interval_label = new JLabel(" time interval: ");
      time_interval = new JTextField();
      time_interval.setEditable(true);
      time_interval.setHorizontalAlignment(JTextField.RIGHT);
      time_interval.setText("1");

      StatusControlListener status_listener = new StatusControlListener();
      time_interval.addActionListener(status_listener);

      String [] status_strings = { "Disabled", "Enabled", "With scalers", "Reset scalers" };
      status_choice = new JComboBox(status_strings);
      status_choice.setSelectedIndex(0);
      status_choice.addActionListener(status_listener);

      JLabel min_label = new JLabel(" min");

      StatusOutputHandler status_handler = new StatusOutputHandler();
      kernel.AddOutputHandler(status_handler);

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addComponent(status_label).
          addComponent(status_choice,100,100,100).
          addComponent(interval_label).
          addComponent(time_interval,50,50,50).
          addComponent(min_label)
      );
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addComponent(status_label).
          addComponent(status_choice,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(interval_label).
          addComponent(time_interval,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(min_label)
      );
    }
  }

  public class PipelineDelayControl extends JPanel {
    public class PipelineDelayOutputHandler extends CosmicRayDetectorOutputHandler {
      JTextField pane;
      int rdelay, wdelay;
      public PipelineDelayOutputHandler(JTextField p) {
        pane = p;
        rdelay = 0;
        wdelay = 0;
      }
      final void Process(String s) {
        if ( s.startsWith("WT ") && ! s.startsWith("WT a d - ") ||
             s.startsWith("DT ") && ! s.startsWith("DT     - ") ) {
          String [] counts = s.substring(3).split("[ \r\n\t]");
          int chan = 0, value = 0;
          if ( counts.length == 4 ) {
            for ( int i=0; i<counts.length; i++ ) {
              int j = counts[i].indexOf('=');
              if ( j > 0 ) {
                chan = counts[i].charAt(j-1)-'0';
                value = Integer.parseInt(counts[i].substring(j+1,j+3),16);
                if ( chan == 1 ) {
                  rdelay = value;
                }
                else if ( chan == 2 ) {
                  wdelay = value;
                  int delay = wdelay-rdelay;
                  if ( delay < 0 ) delay += 256;
                  delay *= 10;
                  pane.setText(Integer.toString(delay));
                }
              }
            }
          }
          else if ( counts.length == 2 ) {
            chan = Integer.parseInt(counts[0]);
            try {
              value = Integer.parseInt(counts[1],16);
              if ( chan == 1 ) {
                rdelay = value;
                int delay = wdelay-rdelay;
                if ( delay < 0 ) delay += 256;
                delay *= 10;
                pane.setText(Integer.toString(delay));
              }
              else if ( chan == 2 ) {
                wdelay = value;
                int delay = wdelay-rdelay;
                if ( delay < 0 ) delay += 256;
                delay *= 10;
                pane.setText(Integer.toString(delay));
              }
            }
            catch ( Exception e1 ) {
              try {
                kernel.sendCommand("DT");
              }
              catch ( Exception e2 ) {
                JOptionPane.showMessageDialog(frame,
                  "Error writing to serial port.",
                  "Serial port error",JOptionPane.WARNING_MESSAGE);
              }
            }
          }
        }
      }
    }
    private class PipelineDelayListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        int data = Integer.parseInt(evt.getActionCommand())/10;
        if ( data > 255 ) data = 255;
        try {
          kernel.sendCommand("CD");
          kernel.sendCommand("WT 1 0");
          kernel.sendCommand("WT 2 "+Integer.toHexString(data));
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);

        }
      }
    }
  
    public PipelineDelayControl() {
      GroupLayout pipeline_layout = new GroupLayout(this);
      setLayout(pipeline_layout);
      pipeline_layout.setAutoCreateGaps(true);
      pipeline_layout.setAutoCreateContainerGaps(true);

      JLabel delay_label = new JLabel("  Pipeline delay:");
      JTextField delay_text = new JTextField();
      delay_text.setEditable(true);
      delay_text.setHorizontalAlignment(JTextField.RIGHT);
      PipelineDelayListener delay_listener = new PipelineDelayListener();
      delay_text.addActionListener(delay_listener);
      PipelineDelayOutputHandler delay_handler = new PipelineDelayOutputHandler(delay_text);
      kernel.AddOutputHandler(delay_handler);
      JLabel dns_label = new JLabel(" ns");

      pipeline_layout.setHorizontalGroup(
        pipeline_layout.createSequentialGroup().
          addComponent(delay_label).
          addComponent(delay_text,50,50,50).
          addComponent(dns_label));
      pipeline_layout.setVerticalGroup(
        pipeline_layout.createParallelGroup().
          addComponent(delay_label).
          addComponent(delay_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(dns_label));
    }
  }


  public class TimingRegOutputHandler extends CosmicRayDetectorOutputHandler {
    JPanel panel;
    public TimingRegOutputHandler(JPanel p) {
      panel = p;
    }
    final void Process(String s) {
      if ( s.startsWith("WT ") && ! s.startsWith("WT a d - ") ||
           s.startsWith("DT ") && ! s.startsWith("DT     - ") ) {
        String [] counts = s.substring(3).split("[ \r\n\t]");
        if ( counts.length == 4 ) {
          for ( int i=0; i<counts.length; i++ ) {
            int j = counts[i].indexOf('=');
            if ( j > 0 ) {
              int chan = counts[i].charAt(j-1)-'0';
              if ( chan+1 < panel.getComponentCount() ) {
                ((JTextField)panel.getComponent(chan+1)).setText(counts[i].substring(j+1,j+3));
              }
            }
          }
        }
        else if ( counts.length == 2 ) {
          int chan = Integer.parseInt(counts[0]);
          if ( chan+1 < panel.getComponentCount() && counts[1].matches("[0-9A-Fa-f]+") ) {
            try {
              int value = Integer.parseInt(counts[1],16);
              String hex = Integer.toHexString(value);
              if ( value < 16 ) hex = "0"+hex;
              ((JTextField)panel.getComponent(chan+1)).setText(hex);
            }
            catch ( Exception e1 ) {
              try {
                kernel.sendCommand("DT");
              }
              catch ( Exception e2 ) {
                JOptionPane.showMessageDialog(frame,
                  "Error writing to serial port.",
                  "Serial port error",JOptionPane.WARNING_MESSAGE);
              }
            }
          }
        }
      }
    }
  }

  public class TmcEnableOutputHandler extends CosmicRayDetectorOutputHandler {
    JButton button;
    Color oldcolor;
    public TmcEnableOutputHandler(JButton b) {
      button = b;
      oldcolor = button.getBackground();
    }
    final void Process(String s) {
      if ( s.startsWith("CE") && ! s.startsWith("CE    - ") ) {
        button.setBackground(oldcolor);
      }
      else if ( s.startsWith("CD") && ! s.startsWith("CD     - ") ||
                s.startsWith("RB") && ! s.startsWith("RB     - ") ) {
//        button.setBackground(Color.green);
      }
    }
  }
  public class TmcDisableOutputHandler extends CosmicRayDetectorOutputHandler {
    JButton button;
    Color oldcolor;
    public TmcDisableOutputHandler(JButton b) {
      button = b;
      oldcolor = button.getBackground();
    }
    final void Process(String s) {
      if ( s.startsWith("CE") ) {
//        button.setBackground(Color.red);
      }
      else if ( s.startsWith("CD") && ! s.startsWith("CD     - ") ||
                s.startsWith("RB") && ! s.startsWith("RB     - ") ) {
//        button.setBackground(oldcolor);
      }
    }
  }
  public class PulserOffOutputHandler extends CosmicRayDetectorOutputHandler {
    JButton button;
    Color oldcolor;
    public PulserOffOutputHandler(JButton b) {
      button = b;
      oldcolor = button.getBackground();
    }
    final void Process(String s) {
      if ( s.startsWith("TE 1") || s.startsWith("TE 2") ) {
//        button.setBackground(Color.red);
      }
      else if ( s.startsWith("TE 0") ) {
//        button.setBackground(oldcolor);
      }
    }
  }

  public class PulserResetOutputHandler extends CosmicRayDetectorOutputHandler {
    JButton button;
      Color oldcolor;
    public PulserResetOutputHandler(JButton b) {
      button = b;
      oldcolor = button.getBackground();
    }
    final void Process(String s) {
      if ( s.startsWith("TD 1") || s.startsWith("TD 2") ) {
//        button.setBackground(Color.red);
      }
      else if ( s.startsWith("TD 0") ) {
//        button.setBackground(oldcolor);
      }
    }
  }

  public class ThresholdOutputHandler extends CosmicRayDetectorOutputHandler {
    JPanel panel;
    public ThresholdOutputHandler(JPanel p) {
      panel = p;
    }
    final void Process(String s) {
      if ( s.startsWith("TL ") && ! s.startsWith("TL c d - ") ) {
        String [] counts = s.substring(3).split("[ \r\n\t]");
        for ( int i=0; i<counts.length; i++ ) {
          int j = counts[i].indexOf('=');
          if ( j > 0 ) {
            int chan = counts[i].charAt(j-1)-'0';
            if ( chan+1 < panel.getComponentCount() ) {
              double thr = 0.0;
              try {
                thr = 0.1*Double.parseDouble(counts[i].substring(j+1));
              }
              catch ( Exception e ) {
                thr = 0.0;
              }
              ((JTextField)panel.getComponent(chan+1)).setText(String.format("%5.1f",thr));
            }
          }
        }
      }
    }
  }
  class CoincidenceControls extends JPanel {
    int cr0;
    JCheckBox [] coinc_chan;
    JSpinner coinc_spinner;
    public class CoincidenceChannelListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        int value = cr0&0xc0;
        for ( int i=0; i<4; i++ ) {
          if ( coinc_chan[i].isSelected() ) {
            value |= (1<<i);
          }
        }
        int level = ((SpinnerNumberModel)coinc_spinner.getModel()).getNumber().intValue();
        value |= ((level-1)<<4);
        try {
          kernel.sendCommand("WC 0 "+Integer.toHexString(value));
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
          
        }
      }
    }
    public class CoincidenceListener implements ChangeListener {
      public void stateChanged(ChangeEvent evt) {
        int value = cr0&0xc0;
        for ( int i=0; i<4; i++ ) {
          if ( coinc_chan[i].isSelected() ) {
            value |= (1<<i);
          }
        }
        int level = ((SpinnerNumberModel)coinc_spinner.getModel()).getNumber().intValue();
        value |= ((level-1)<<4);
        try {
          kernel.sendCommand("WC 0 "+Integer.toHexString(value));
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }  
      }
    }
    public class CoincidenceChannelOutputHandler extends CosmicRayDetectorOutputHandler {
      JPanel panel;
      public CoincidenceChannelOutputHandler(JPanel p) {
        panel = p;
      }
      final void Process(String s) {
        if ( s.startsWith("WC ") && ! s.startsWith("WC a d - ") ||
             s.startsWith("DC ") && ! s.startsWith("DC     - ") ) {
          String [] counts = s.substring(3).split("[ \r\n\t]");
          for ( int i=0; i<counts.length; i++ ) {
            int j = counts[i].indexOf('=');
            if ( j > 0 ) {
              int chan = counts[i].charAt(j-1)-'0';
              if ( chan == 0 ) {
                int value = Integer.parseInt(counts[i].substring(j+1,j+3),16);
                cr0 = value;
                for ( int k=0; k<4; k++ ) {
                  boolean prev = coinc_chan[k].isSelected();
                  boolean next = ((1<<k)&value)!=0;
                  if ( prev != next ) {
                    coinc_chan[k].setSelected(next);
                  }
                }
                int prev = ((SpinnerNumberModel)coinc_spinner.getModel()).getNumber().intValue();
                int next = ((value>>4)&3)+1;
                if ( prev != next ) {
                  coinc_spinner.setModel(new SpinnerNumberModel(next,1,4,1));
                }
              }
            }
          }
        }
      }
    }

    public CoincidenceControls() {
      cr0 = 0x2f;
      GroupLayout coinc_layout = new GroupLayout(this);
      this.setLayout(coinc_layout);
      coinc_layout.setAutoCreateGaps(true);
      coinc_layout.setAutoCreateContainerGaps(true);
      coinc_chan = new JCheckBox [4];
      CoincidenceChannelListener coinc_chan_listener = new CoincidenceChannelListener();
      for ( int i=0; i<4; i++ ) {
        coinc_chan[i] = new JCheckBox("Ch. "+Integer.toString(i+1));
        coinc_chan[i].addActionListener(coinc_chan_listener);
      }
      JLabel level_label = new JLabel("  Coincidence level:");
      coinc_spinner = new JSpinner(new SpinnerNumberModel(1,1,4,1));
      CoincidenceListener coinc_listener = new CoincidenceListener();
      coinc_spinner.addChangeListener(coinc_listener);
      coinc_spinner.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);

      CoincidenceChannelOutputHandler coinc_chan_handler = new CoincidenceChannelOutputHandler(this);
      kernel.AddOutputHandler(coinc_chan_handler);

      coinc_layout.setHorizontalGroup(
        coinc_layout.createSequentialGroup().
          addComponent(coinc_chan[0]).
          addComponent(coinc_chan[1]).
          addComponent(coinc_chan[2]).
          addComponent(coinc_chan[3]).
          addComponent(level_label).
          addComponent(coinc_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));

      coinc_layout.setVerticalGroup(
        coinc_layout.createParallelGroup().
          addComponent(coinc_chan[0]).
          addComponent(coinc_chan[1]).
          addComponent(coinc_chan[2]).
          addComponent(coinc_chan[3]).
          addComponent(level_label).
          addComponent(coinc_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));
    }

  }

  class SimpleButtonListener implements ActionListener {
    public void actionPerformed(ActionEvent evt) {
      JButton field = (JButton)evt.getSource();
      try {
        kernel.sendCommand(field.getName());
      }
      catch ( Exception e ) {
        JOptionPane.showMessageDialog(frame,
          "Error writing to serial port.",
          "Serial port error",JOptionPane.WARNING_MESSAGE);
      }
    }
  }

  class CounterEnableDisableControls extends JPanel {
    public CounterEnableDisableControls() {
      GroupLayout cecd_layout = new GroupLayout(this);
      setLayout(cecd_layout);
      cecd_layout.setAutoCreateGaps(true);
      cecd_layout.setAutoCreateContainerGaps(true);
      JLabel cecd_label = new JLabel();
      cecd_label.setText("Data output:");
      SimpleButtonListener cecd_listener = new SimpleButtonListener();
      JButton ce_button = new JButton("Enable");
      ce_button.setName("CE");
      TmcEnableOutputHandler ce_handler = new TmcEnableOutputHandler(ce_button);
      kernel.AddOutputHandler(ce_handler);
      ce_button.addActionListener(cecd_listener);
      JButton cd_button = new JButton("Disable");
      cd_button.setName("CD");
      cd_button.addActionListener(cecd_listener);
      TmcDisableOutputHandler cd_handler = new TmcDisableOutputHandler(cd_button);
      kernel.AddOutputHandler(cd_handler);

      cecd_layout.setHorizontalGroup(
        cecd_layout.createSequentialGroup().
          addComponent(cecd_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(ce_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cd_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));
      cecd_layout.setVerticalGroup(
        cecd_layout.createParallelGroup().
          addComponent(cecd_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(ce_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cd_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));
    }
  }

  public class ControlPanel extends JPanel {
    JTextField command;
    JTextField port_text;
    JTextField log_text;
    JTextField thr_text [];

    private class DiscThresholdListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        int ichan = 0;
        while ( field != thr_text[ichan] ) {
          ichan += 1;
        }
        try {
          int data = (int)(Double.parseDouble(evt.getActionCommand())*10);
          try {
            kernel.sendCommand("TL "+Integer.toString(ichan)+" "+Integer.toString(data));
          }
          catch ( Exception e ) {
            JOptionPane.showMessageDialog(frame,"Error writing to serial port.",
                                      "Serial port error",
                                      JOptionPane.WARNING_MESSAGE);
          }
        }
        catch ( Exception e ) {
          field.setText("???");
        }
      }
    }

    public ControlPanel() {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
//      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      JLabel port_label = new JLabel("Serial port:");
      port_text = new JTextField(default_port);
      OpenPortListener port_listener = new OpenPortListener();
      port_text.addActionListener(port_listener);
      JLabel log_label = new JLabel("Log file:");
      Calendar now = Calendar.getInstance();
      String log_file = String.format("data/CosmicRayDetector_%d-%d-%d_%02d%02d%02d.txt",now.get(Calendar.MONTH)+1,now.get(Calendar.DATE),now.get(Calendar.YEAR),now.get(Calendar.HOUR_OF_DAY),now.get(Calendar.MINUTE),now.get(Calendar.SECOND));
      log_text = new JTextField(log_file);
      OpenLogListener log_listener = new OpenLogListener();
      log_text.addActionListener(log_listener);
      try {
        kernel.OpenLogFile(log_file);
      }
      catch ( Exception e ) {
        JOptionPane.showMessageDialog(frame,"Error opening output file '"+log_file+"'","Port error",JOptionPane.ERROR_MESSAGE);
      }

      JPanel sn_panel = new JPanel();
      GroupLayout sn_layout = new GroupLayout(sn_panel);
      sn_panel.setLayout(sn_layout);
      sn_layout.setAutoCreateGaps(true);
      sn_layout.setAutoCreateContainerGaps(true);
      JButton sn_label = new JButton("S/N:");
      sn_label.setName("SN");
      SimpleButtonListener sn_listener = new SimpleButtonListener();
      sn_label.addActionListener(sn_listener);
      JTextField sn_text = new JTextField();
      sn_text.setEditable(false);
      sn_text.setHorizontalAlignment(JTextField.RIGHT);
      SerialNumberOutputHandler sn_handler = new SerialNumberOutputHandler(sn_text);
      kernel.AddOutputHandler(sn_handler);
      sn_layout.setHorizontalGroup(
       sn_layout.createSequentialGroup().
          addComponent(sn_label).
          addComponent(sn_text,50,50,50));
      sn_layout.setVerticalGroup(
       sn_layout.createParallelGroup().
          addComponent(sn_label).
          addComponent(sn_text));
  
      JPanel help_panel = new JPanel();
      GroupLayout help_layout = new GroupLayout(help_panel);
      help_panel.setLayout(help_layout);
      help_layout.setAutoCreateGaps(true);
      help_layout.setAutoCreateContainerGaps(true);
      JLabel help_label = new JLabel();
      help_label.setText("Help:");
  
      JButton h1_label = new JButton("Page 1");
      h1_label.setName("H1");
      SimpleButtonListener help_listener = new SimpleButtonListener();
      h1_label.addActionListener(help_listener);
  
      JButton h2_label = new JButton("Page 2");
      h2_label.setName("H2");
      h2_label.addActionListener(help_listener);
  
      JButton hb_label = new JButton("Barometer");
      hb_label.setName("HB");
      hb_label.addActionListener(help_listener);
  
      JButton hs_label = new JButton("Status");
      hs_label.setName("HS");
      hs_label.addActionListener(help_listener);
  
      JButton ht_label = new JButton("Trigger");
      ht_label.setName("HT");
      ht_label.addActionListener(help_listener);

      JButton v1_label = new JButton("Setup");
      v1_label.setName("V1");
      v1_label.addActionListener(help_listener);
  
      JButton v2_label = new JButton("Voltages");
      v2_label.setName("V2");
      v2_label.addActionListener(help_listener);

      JButton v3_label = new JButton("GPS Lock");
      v3_label.setName("V3");
      v3_label.addActionListener(help_listener);
  
      help_layout.setHorizontalGroup(
        help_layout.createSequentialGroup().
          addComponent(help_label).
          addGroup(help_layout.createParallelGroup().
            addGroup(help_layout.createSequentialGroup().
              addComponent(h1_label).
              addComponent(h2_label).
              addComponent(hb_label).
              addComponent(hs_label)).
            addGroup(help_layout.createSequentialGroup().
              addComponent(ht_label).
              addComponent(v1_label).
              addComponent(v2_label).
              addComponent(v3_label))));

      help_layout.setVerticalGroup(
       help_layout.createParallelGroup().
          addComponent(help_label).
          addGroup(help_layout.createSequentialGroup().
            addGroup(help_layout.createParallelGroup().
              addComponent(h1_label).
              addComponent(h2_label).
              addComponent(hb_label).
              addComponent(hs_label)).
            addGroup(help_layout.createParallelGroup().
              addComponent(ht_label).
              addComponent(v1_label).
              addComponent(v2_label).
              addComponent(v3_label))));

      JPanel gps_panel = new JPanel();
      GroupLayout gps_layout = new GroupLayout(gps_panel);
      gps_panel.setLayout(gps_layout);
      gps_layout.setAutoCreateGaps(true);
      gps_layout.setAutoCreateContainerGaps(true);

      JLabel gps_status_label = new JLabel();
      gps_status_label.setText("GPS status:");
      JTextField gps_status_text = new JTextField();
      gps_status_text.setEditable(false);
      GpsStatusOutputHandler gps_status_handler = new GpsStatusOutputHandler(gps_status_text);
      kernel.AddOutputHandler(gps_status_handler);

      JLabel gps_sats_label = new JLabel();
      gps_sats_label.setText("Sats used:");
      JTextField gps_sats_text = new JTextField();
      gps_sats_text.setEditable(false);
      GpsSatsOutputHandler gps_sats_handler = new GpsSatsOutputHandler(gps_sats_text);
      kernel.AddOutputHandler(gps_sats_handler);

      JLabel temp_label = new JLabel();
      temp_label.setText("T=");
      JTextField temp_text = new JTextField();
      temp_text.setEditable(false);
      TemperatureOutputHandler temp_handler = new TemperatureOutputHandler(temp_text);
      kernel.AddOutputHandler(temp_handler);

      JLabel pressure_label = new JLabel();
      pressure_label.setText("deg C    P=");
      JTextField pressure_text = new JTextField();
      pressure_text.setEditable(false);
      PressureOutputHandler pressure_handler = new PressureOutputHandler(pressure_text);
      kernel.AddOutputHandler(pressure_handler);
//      JLabel hpa_label = new JLabel();
//      hpa_label.setText("hPa");

      JLabel dac_label = new JLabel();
      dac_label.setText("hPa  DAC=");
      JTextField dac_text = new JTextField();
      dac_text.setEditable(false);
      DacOutputHandler dac_handler = new DacOutputHandler(dac_text);
      kernel.AddOutputHandler(dac_handler);

      JLabel lat_label = new JLabel();
      lat_label.setText("Latitude:");
      JTextField lat_text = new JTextField();
      lat_text.setEditable(false);
      LatitudeOutputHandler lat_handler = new LatitudeOutputHandler(lat_text);
      kernel.AddOutputHandler(lat_handler);

      JLabel lon_label = new JLabel();
      lon_label.setText("Longitude:");
      JTextField lon_text = new JTextField();
      lon_text.setEditable(false);
      LongitudeOutputHandler lon_handler = new LongitudeOutputHandler(lon_text);
      kernel.AddOutputHandler(lon_handler);

      JLabel alt_label = new JLabel();
      alt_label.setText("Altitude:");
      JTextField alt_text = new JTextField();
      alt_text.setEditable(false);
      AltitudeOutputHandler alt_handler = new AltitudeOutputHandler(alt_text);
      kernel.AddOutputHandler(alt_handler);

      JLabel gps_time_label = new JLabel();
      gps_time_label.setText("Time:");
      JTextField gps_time_text = new JTextField();
      gps_time_text.setEditable(false);
      GpsTimeOutputHandler gps_time_handler = new GpsTimeOutputHandler(gps_time_text);
      kernel.AddOutputHandler(gps_time_handler);

      gps_layout.setHorizontalGroup(
        gps_layout.createParallelGroup().
          addGroup(gps_layout.createSequentialGroup().
          addComponent(gps_status_label).
          addComponent(gps_status_text,65,65,65).
          addComponent(gps_sats_label).
          addComponent(gps_sats_text,25,25,25).
          addComponent(temp_label).
          addComponent(temp_text,50,50,50).
          addComponent(pressure_label).
          addComponent(pressure_text,50,50,50).
          addComponent(dac_label).
          addComponent(dac_text,40,40,40)).
        addGroup(gps_layout.createSequentialGroup().
          addComponent(lat_label).
          addComponent(lat_text,150,150,150).
          addComponent(lon_label).
          addComponent(lon_text,150,150,150)).
        addGroup(gps_layout.createSequentialGroup().
          addComponent(alt_label).
          addComponent(alt_text,150,150,150).
          addComponent(gps_time_label).
          addComponent(gps_time_text,180,180,180)));
      gps_layout.setVerticalGroup(
      gps_layout.createSequentialGroup().
        addGroup(gps_layout.createParallelGroup().
          addComponent(gps_status_label).
          addComponent(gps_status_text).
          addComponent(gps_sats_label).
          addComponent(gps_sats_text).
          addComponent(temp_label).
          addComponent(temp_text).
          addComponent(pressure_label).
          addComponent(pressure_text).
          addComponent(dac_label).
          addComponent(dac_text)).
        addGroup(gps_layout.createParallelGroup().
          addComponent(lat_label).
          addComponent(lat_text).
          addComponent(lon_label).
          addComponent(lon_text)).
        addGroup(gps_layout.createParallelGroup().
          addComponent(alt_label).
          addComponent(alt_text).
          addComponent(gps_time_label).
          addComponent(gps_time_text)));
 
      JPanel sca_panel = new JPanel();
      GroupLayout sca_layout = new GroupLayout(sca_panel);
      sca_panel.setLayout(sca_layout);
      sca_layout.setAutoCreateGaps(true);
      sca_layout.setAutoCreateContainerGaps(true);
      JButton sca_label = new JButton("Scalers:");
      sca_label.setName("DS");
      SimpleButtonListener ds_listener = new SimpleButtonListener();
      sca_label.addActionListener(ds_listener);
  
      JButton sca_reset = new JButton("Reset scalers");
      ResetScalerListener sca_reset_listener = new ResetScalerListener();
      sca_reset.addActionListener(sca_reset_listener);

      JButton board_reset = new JButton("Reset board");
      board_reset.setName("RE");
      board_reset.addActionListener(ds_listener);
  
      UpdateButtonListener update_listener = new UpdateButtonListener();
      JButton update_button = new JButton("Update");
      update_button.addActionListener(update_listener);

      JButton gps_button = new JButton("GPS");
      gps_button.setName("DG");
      SimpleButtonListener gps_listener = new SimpleButtonListener();
      gps_button.addActionListener(gps_listener);

      JPanel button_panel = new JPanel();
      GroupLayout button_layout = new GroupLayout(button_panel);
      button_panel.setLayout(button_layout);
      button_layout.setAutoCreateGaps(true);
      button_layout.setAutoCreateContainerGaps(true);
      button_layout.setHorizontalGroup(
        button_layout.createSequentialGroup().
          addComponent(update_button).
          addComponent(sca_reset).
          addComponent(board_reset).
          addComponent(gps_button));
      button_layout.setVerticalGroup(
        button_layout.createParallelGroup().
          addComponent(update_button).
          addComponent(sca_reset).
          addComponent(board_reset).
          addComponent(gps_button));

      JTextField sca_text[] = new JTextField [5];
      for ( int i=0; i<5; i++ ) {
        sca_text[i] = new JTextField();
        sca_text[i].setEditable(false);
        sca_text[i].setHorizontalAlignment(JTextField.RIGHT);
      }
      ScalerOutputHandler sca_handler = new ScalerOutputHandler(sca_panel);
      kernel.AddOutputHandler(sca_handler);
      sca_layout.setHorizontalGroup(
        sca_layout.createSequentialGroup().
          addComponent(sca_label).
          addComponent(sca_text[0],80,80,80).
          addComponent(sca_text[1],80,80,80).
          addComponent(sca_text[2],80,80,80).
          addComponent(sca_text[3],80,80,80).
          addComponent(sca_text[4],80,80,80));
      sca_layout.setVerticalGroup(
        sca_layout.createParallelGroup().
          addComponent(sca_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(sca_text[0],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(sca_text[1],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(sca_text[2],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(sca_text[3],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(sca_text[4],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));

      JPanel cr_panel = new JPanel();
      GroupLayout cr_layout = new GroupLayout(cr_panel);
      cr_panel.setLayout(cr_layout);
      cr_layout.setAutoCreateGaps(true);
      cr_layout.setAutoCreateContainerGaps(true);

      JButton cr_label = new JButton("Control registers:");
      cr_label.setName("DC");
      SimpleButtonListener dc_listener = new SimpleButtonListener();
      cr_label.addActionListener(dc_listener);

      RegisterListener cr_listener = new RegisterListener();
      JTextField cr_text[] = new JTextField [4];
      for ( int i=0; i<4; i++ ) {
        cr_text[i] = new JTextField();
        cr_text[i].setEditable(true);
        cr_text[i].setHorizontalAlignment(JTextField.RIGHT);
        cr_text[i].addActionListener(cr_listener);
        cr_text[i].setName("WC " + Integer.toString(i) + " ");
      }
      ControlRegOutputHandler cr_handler = new ControlRegOutputHandler(cr_panel);
      kernel.AddOutputHandler(cr_handler);
      cr_layout.setHorizontalGroup(
        cr_layout.createSequentialGroup().
          addComponent(cr_label).
          addComponent(cr_text[0],50,50,50).
          addComponent(cr_text[1],50,50,50).
          addComponent(cr_text[2],50,50,50).
          addComponent(cr_text[3],50,50,50));
      cr_layout.setVerticalGroup(
        cr_layout.createParallelGroup().
          addComponent(cr_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cr_text[0],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cr_text[1],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cr_text[2],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cr_text[3],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));

      JPanel tr_panel = new JPanel();
      GroupLayout tr_layout = new GroupLayout(tr_panel);
      tr_panel.setLayout(tr_layout);
      tr_layout.setAutoCreateGaps(true);
      tr_layout.setAutoCreateContainerGaps(true);
      JButton tr_label = new JButton("Timing registers:");
      tr_label.setName("DT");
      SimpleButtonListener dt_listener = new SimpleButtonListener();
      tr_label.addActionListener(dt_listener);
    
      RegisterListener tr_listener = new RegisterListener();
      JTextField tr_text[] = new JTextField [4];
      for ( int i=0; i<4; i++ ) {
        tr_text[i] = new JTextField();
        if ( i == 1 || i == 2 ) {
          tr_text[i].setEditable(true);
          tr_text[i].addActionListener(tr_listener);
        }
        else {
          tr_text[i].setEditable(false);
        }
        tr_text[i].setHorizontalAlignment(JTextField.RIGHT);
        tr_text[i].setName("WT " + Integer.toString(i) + " ");
      }
      TimingRegOutputHandler tr_handler = new TimingRegOutputHandler(tr_panel);
      kernel.AddOutputHandler(tr_handler);
      tr_layout.setHorizontalGroup(
        tr_layout.createSequentialGroup().
          addComponent(tr_label).
          addComponent(tr_text[0],50,50,50).
          addComponent(tr_text[1],50,50,50).
          addComponent(tr_text[2],50,50,50).
          addComponent(tr_text[3],50,50,50));
      tr_layout.setVerticalGroup(
        tr_layout.createParallelGroup().
          addComponent(tr_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(tr_text[0],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(tr_text[1],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(tr_text[2],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(tr_text[3],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));


      CoincidenceControls coinc_panel = new CoincidenceControls();
      GateWidthControl gate_control = new GateWidthControl();
      PipelineDelayControl pipeline_control = new PipelineDelayControl();
      JPanel gate_panel = new JPanel();
      GroupLayout gate_layout = new GroupLayout(gate_panel);
      gate_panel.setLayout(gate_layout);
      gate_layout.setHorizontalGroup(
        gate_layout.createParallelGroup().
          addComponent(coinc_panel).
          addGroup(gate_layout.createSequentialGroup().
            addComponent(gate_control).
            addComponent(pipeline_control)));
      gate_layout.setVerticalGroup(
        gate_layout.createSequentialGroup().
          addComponent(coinc_panel).
          addGroup(gate_layout.createParallelGroup().
            addComponent(gate_control).
            addComponent(pipeline_control)));
      gate_panel.setBorder(BorderFactory.createTitledBorder("Trigger"));

      JPanel thr_panel = new JPanel();
      GroupLayout thr_layout = new GroupLayout(thr_panel);
      thr_panel.setLayout(thr_layout);
      thr_layout.setAutoCreateGaps(true);
      thr_layout.setAutoCreateContainerGaps(true);
      JButton thr_label = new JButton("Threshold:");
      thr_label.setName("TL");
      SimpleButtonListener tl_listener = new SimpleButtonListener();
      thr_label.addActionListener(tl_listener);
      JLabel mv_label = new JLabel(" mV");

      DiscThresholdListener thr_listener = new DiscThresholdListener();
      thr_text = new JTextField [4];
      for ( int i=0; i<4; i++ ) {
        thr_text[i] = new JTextField();
        thr_text[i].setEditable(true);
        thr_text[i].setHorizontalAlignment(JTextField.RIGHT);
        thr_text[i].addActionListener(thr_listener);
        thr_text[i].setName("TL " + Integer.toString(i) + " ");
      }
      ThresholdOutputHandler thr_handler = new ThresholdOutputHandler(thr_panel);
      kernel.AddOutputHandler(thr_handler);
      thr_layout.setHorizontalGroup(
        thr_layout.createSequentialGroup().
          addComponent(thr_label).
          addComponent(thr_text[0],50,50,50).
          addComponent(thr_text[1],50,50,50).
          addComponent(thr_text[2],50,50,50).
          addComponent(thr_text[3],50,50,50).
          addComponent(mv_label));
      thr_layout.setVerticalGroup(
        thr_layout.createParallelGroup().
          addComponent(thr_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(thr_text[0],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(thr_text[1],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(thr_text[2],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(thr_text[3],GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(mv_label));

      CounterEnableDisableControls cecd_panel = new CounterEnableDisableControls();
/*
      JPanel cecd_panel = new JPanel();
      GroupLayout cecd_layout = new GroupLayout(cecd_panel);
      cecd_panel.setLayout(cecd_layout);
      cecd_layout.setAutoCreateGaps(true);
      cecd_layout.setAutoCreateContainerGaps(true);
      JLabel cecd_label = new JLabel();
      cecd_label.setText("TMC Counters:");
      SimpleButtonListener cecd_listener = new SimpleButtonListener();
      JButton ce_button = new JButton("Enable");
      ce_button.setName("CE");
      TmcEnableOutputHandler ce_handler = new TmcEnableOutputHandler(ce_button);
      kernel.AddOutputHandler(ce_handler);
      ce_button.addActionListener(cecd_listener);
      JButton cd_button = new JButton("Disable");
      cd_button.setName("CD");
      cd_button.addActionListener(cecd_listener);
      TmcDisableOutputHandler cd_handler = new TmcDisableOutputHandler(cd_button);
      kernel.AddOutputHandler(cd_handler);

      cecd_layout.setHorizontalGroup(
        cecd_layout.createSequentialGroup().
          addComponent(cecd_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(ce_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cd_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));
      cecd_layout.setVerticalGroup(
        cecd_layout.createParallelGroup().
          addComponent(cecd_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(ce_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
          addComponent(cd_button,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE));
*/

      JPanel status_panel = new StatusControl();

      JPanel pulser_panel = new JPanel();
      GroupLayout pulser_layout = new GroupLayout(pulser_panel);
      pulser_panel.setLayout(pulser_layout);
      pulser_layout.setAutoCreateGaps(true);
      pulser_layout.setAutoCreateContainerGaps(true);
      JLabel pulser_label = new JLabel();
      pulser_label.setText("Test pulser:");
      SimpleButtonListener pulser_listener = new SimpleButtonListener();
      JButton pulser_off_button = new JButton("Off");
      pulser_off_button.setName("TE 0");
      pulser_off_button.addActionListener(pulser_listener);
      PulserOffOutputHandler pulser_off_handler = new PulserOffOutputHandler(pulser_off_button);
      kernel.AddOutputHandler(pulser_off_handler);

      JButton pulser_once_button = new JButton("Once");
      pulser_once_button.setName("TE 1");
      pulser_once_button.addActionListener(pulser_listener);
      JButton pulser_cont_button = new JButton("Continuous");
      pulser_cont_button.setName("TE 2");
      pulser_cont_button.addActionListener(pulser_listener);
  
      JButton pulser_reset_button = new JButton("Reset");
      pulser_reset_button.setName("TD 0");
      pulser_reset_button.addActionListener(pulser_listener);
      PulserResetOutputHandler pulser_reset_handler = new PulserResetOutputHandler(pulser_reset_button);
      kernel.AddOutputHandler(pulser_reset_handler);
      JButton pulser_singles_button = new JButton("Singles");
      pulser_singles_button.setName("TD 1");
      pulser_singles_button.addActionListener(pulser_listener);
      JButton pulser_majority_button = new JButton("Majority");
      pulser_majority_button.setName("TD 2");
      pulser_majority_button.addActionListener(pulser_listener);

      JLabel pulser_voltage_label = new JLabel("Voltage:");
      JLabel pulser_mv_label = new JLabel(" mV");
      JTextField pulser_voltage_text = new JTextField();
      pulser_voltage_text.setEditable(true);
      pulser_voltage_text.setHorizontalAlignment(JTextField.RIGHT);
      PulserVoltageListener pulser_voltage_listener = new PulserVoltageListener();
      pulser_voltage_text.addActionListener(pulser_voltage_listener);
      PulserVoltageOutputHandler pulser_voltage_handler = new PulserVoltageOutputHandler(pulser_voltage_text);
      kernel.AddOutputHandler(pulser_voltage_handler);

      pulser_layout.setHorizontalGroup(
        pulser_layout.createSequentialGroup().
          addComponent(pulser_label).
          addGroup(pulser_layout.createParallelGroup().
            addGroup(pulser_layout.createSequentialGroup().
              addComponent(pulser_off_button).
              addComponent(pulser_once_button).
              addComponent(pulser_cont_button)).
            addGroup(pulser_layout.createSequentialGroup().
              addComponent(pulser_reset_button).
              addComponent(pulser_singles_button).
              addComponent(pulser_majority_button))).
          addComponent(pulser_voltage_label).
          addComponent(pulser_voltage_text,50,50,50).
          addComponent(pulser_mv_label));
      pulser_layout.setVerticalGroup(
        pulser_layout.createParallelGroup().
          addComponent(pulser_label).
          addGroup(pulser_layout.createSequentialGroup().
            addGroup(pulser_layout.createParallelGroup().
              addComponent(pulser_off_button).
              addComponent(pulser_once_button).
              addComponent(pulser_cont_button)).
            addGroup(pulser_layout.createParallelGroup().
              addComponent(pulser_reset_button).
              addComponent(pulser_singles_button).
              addComponent(pulser_majority_button))).
              addComponent(pulser_voltage_label).
          addComponent(pulser_voltage_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(pulser_mv_label));

      JLabel cmd_label = new JLabel();
      cmd_label.setText("Command:");
      command = new JTextField(1);
      CommandListener command_listener = new CommandListener();
      command.addActionListener(command_listener);

      JTextArea output = new JTextArea();
      output.setLineWrap(false);
      output.setEditable(false);
      output.setFont(new Font("monospaced",Font.PLAIN,10));
      AllOutputHandler output_handler = new AllOutputHandler(output);
      kernel.AddOutputHandler(output_handler);

      pfix = new PressureFixer();

      JScrollPane output_scroll = new JScrollPane(output,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS); 

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(port_label).
              addComponent(port_text,150,150,150).
              addComponent(log_label).
              addComponent(log_text,300,300,300)).
            addGroup(layout.createSequentialGroup().
              addComponent(sn_panel).
              addComponent(button_panel)).
            addComponent(help_panel).
            addComponent(gps_panel).
            addComponent(sca_panel).
            addComponent(cr_panel).
            addComponent(tr_panel).
//            addComponent(coinc_panel).
            addComponent(gate_panel).
            addComponent(thr_panel).
            addComponent(status_panel).
            addComponent(cecd_panel).
            addComponent(pulser_panel).
            addGroup(layout.createSequentialGroup().
              addComponent(cmd_label).
              addComponent(command,250,250,250))).
          addComponent(output_scroll,300,400,600)); 
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addComponent(port_label).
              addComponent(port_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(log_label).
              addComponent(log_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(sn_panel,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(button_panel,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addComponent(help_panel).
            addComponent(gps_panel,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(sca_panel).
            addComponent(cr_panel).
            addComponent(tr_panel).
//            addComponent(coinc_panel).
            addComponent(gate_panel).
            addComponent(thr_panel).
            addComponent(status_panel).
            addComponent(cecd_panel).
            addComponent(pulser_panel).
            addGroup(layout.createParallelGroup().
              addComponent(cmd_label).
              addComponent(command,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE))).
          addComponent(output_scroll));

    }
    private class OpenPortListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.connect(port_text.getText());
          try {
            kernel.sendCommand("SN");
            kernel.sendCommand("DG");
            kernel.sendCommand("DC");
            kernel.sendCommand("DT");
            kernel.sendCommand("TL");
            kernel.sendCommand("TV");
            kernel.sendCommand("BA");
            kernel.sendCommand("ST 2 1");
            kernel.sendCommand("ST");
          }
          catch ( Exception e1 ) {
            JOptionPane.showMessageDialog(frame,
              "Error writing to serial port.",
              "Serial port error",JOptionPane.WARNING_MESSAGE);
          }
        }
        catch ( Exception e2 ) {
          JOptionPane.showMessageDialog(frame,"Error opening port '"+port_text.getText()+"'","Port error",JOptionPane.ERROR_MESSAGE);
        }
      }
    }
    private class OpenLogListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.OpenLogFile(log_text.getText());
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,"Error opening output file '"+log_text.getText()+"'","Port error",JOptionPane.ERROR_MESSAGE);
        }
      }
    }

    private class CommandListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.sendCommand(evt.getActionCommand());
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
        command.setText(null); 
      }
    }
    private class PulserVoltageListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.sendCommand("TV "+evt.getActionCommand());
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    private class RegisterListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        try {
          kernel.sendCommand(field.getName()+evt.getActionCommand());
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    private class ResetScalerListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.sendCommand("RB");
          kernel.sendCommand("DS");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    private class UpdateButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
          kernel.sendCommand("SN");
          kernel.sendCommand("DG");
          kernel.sendCommand("DC");
          kernel.sendCommand("DT");
          kernel.sendCommand("TL");
          kernel.sendCommand("TV");
          kernel.sendCommand("BA");
          kernel.sendCommand("ST 2 1");
          kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }

      }
    }
  }

  public class Pulse {
    long counter_rising_edge;
    long counter_falling_edge;
    int time_rising_edge;
    int time_falling_edge;
    int channel;
    public Pulse() {
      channel = -1;
      counter_rising_edge = 0;
      counter_falling_edge = 0;
      time_rising_edge = 0;
      time_falling_edge = 0;
    }
    public Pulse(int i) {
      channel = i;
      counter_rising_edge = 0;
      counter_falling_edge = 0;
      time_rising_edge = 0;
      time_falling_edge = 0;
    }
    public int Channel() {
      return channel;
    }
    public boolean HasRisingEdge() {
      return ( counter_rising_edge > 0 && (time_rising_edge&0x1f) > 0 );
    }
    public boolean HasFallingEdge() {
      return ( counter_falling_edge > 0 && (time_falling_edge&0x1f) > 0 );
    }
    public boolean Valid() {
      return ( HasRisingEdge() && HasFallingEdge() );
    }
    public void SetRisingEdge(long c,int t) {
      counter_rising_edge = c;
      time_rising_edge = t;
    }
    public void SetFallingEdge(long c,int t) {
      counter_falling_edge = c;
      time_falling_edge = t;
    }
    public long RisingEdgeCounter() {
      return counter_rising_edge;
    }
    public int RisingEdgeTime() {
      return time_rising_edge;
    }
    public long FallingEdgeCounter() {
      return counter_falling_edge;
    }
    public int FallingEdgeTime() {
      return time_falling_edge;
    }
    public double TimeOverThreshold() {
      return 40.0*(counter_falling_edge-counter_rising_edge) +
             1.25*((time_falling_edge&0x1f)-((time_rising_edge&0x1f)));
    }
    public double TimeBefore(Pulse other) {
      return 40.0*(counter_rising_edge-other.RisingEdgeCounter()) +
             1.25*((time_rising_edge&0x1f)-(other.RisingEdgeTime()&0x1f));
    }
    public double TimeUntil(Pulse other) {
      return 40.0*(-counter_rising_edge+other.RisingEdgeCounter()) +
             1.25*(-(time_rising_edge&0x1f)+(other.RisingEdgeTime()&0x1f));
    }
    public boolean equals(Pulse p) {
      return channel == p.Channel() &&
             counter_rising_edge == p.RisingEdgeCounter() &&
             counter_falling_edge == p.FallingEdgeCounter() &&
             time_rising_edge == p.RisingEdgeTime() &&
             time_falling_edge == p.FallingEdgeTime();
    }
    public void Dump() {
      System.out.println(" RE="+Long.toString(counter_rising_edge)+","+Integer.toString(time_rising_edge&0x1f)+
                         " FE="+Long.toString(counter_falling_edge)+","+Integer.toString(time_falling_edge&0x1f));
    }
  }
  public class PerformancePanel extends JPanel {
    JFreeChart [] chart;
    ChartPanel [] chart_panel;
    SimpleHistogramDataset [] dataset;
    int [] unpaired_rising_edge;
    int [] unpaired_falling_edge;
    Pulse [] pulse;
    Random rnd;
    int nbin = 20;
    double bwid = 5.0;
    double dtmax = nbin*bwid;
    int nana;
    int na, nv;
    int ure, ufe;
    int snu, src;
    long [] scalers;
    double fa;
    JTextField gps_valid_text;
    JTextField ure_text;
    JTextField ufe_text;
    JTextField snu_text;
    JTextField src_text;
    JTextField nana_text;

    public class TriggerOutputHandler extends CosmicRayDetectorOutputHandler {
      JPanel panel;
      public TriggerOutputHandler(JPanel p) {
        panel = p;
        na = 0;
        nv = 0;
        fa = 0.0;
        nana = 0;
        ure = 0;
        ufe = 0;
        snu = 0;
        src = 0;
        scalers = new long [4];
        for ( int i=0; i<4; i++ ) {
          scalers[i] = -1;
        }
      }
      final void Process(String s) {
        if ( s.length() == 74 ) {
          String [] tokens = s.split(" ");
          if ( tokens.length == 16 ) {
            if ( tokens[12].matches("[AV]") ) {
              if ( tokens[12].matches("A") ) {
                na += 1;
              }
              else if ( tokens[12].matches("V") ) {
                nv += 1;
              }
              double newfa = na/(nv+na);
              if ( (int)(newfa*1000) != (int)(fa*1000) ) {
                fa = newfa;
                gps_valid_text.setText(String.format("%4.1f %%",fa*100));
              }
            }
            int i = 0;
            long t = Long.parseLong(tokens[i++],16);
            int [] re = new int [4];
            int [] fe = new int [4];
            for ( int j=0; j<4; j++ ) {
              re[j] = Integer.parseInt(tokens[i++],16);
              fe[j] = Integer.parseInt(tokens[i++],16);
              if ( (re[0]&0x80) != 0 && pulse[j] != null ) {
                nana += 1;
                if ( pulse[j].HasRisingEdge() && ! pulse[j].HasFallingEdge() ) {
                  ufe += 1;
                  ufe_text.setText(Integer.toString(ufe));
                }
                if ( pulse[j].HasFallingEdge() && ! pulse[j].HasRisingEdge() ) {
                  ure += 1;
                  ure_text.setText(Integer.toString(ure));
                }
              }
              if ( (re[0]&0x80) != 0 || pulse[j] == null ) {
                pulse[j] = new Pulse(j);
              }
              if ( (fe[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetFallingEdge(t,fe[j]);
                if ( pulse[j].Valid() ) {
                  double dt = pulse[j].TimeOverThreshold();
                  try {
                    dataset[j].addObservation(dt);
                  }
                  catch ( Exception e ) {
                  }
                  pulse[j] = new Pulse(j);
                }
              }
              if ( (re[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetRisingEdge(t,re[j]);
              }
            }
            nana_text.setText(Integer.toString(nana));
          }
        }
        else if ( s.startsWith("ST ") &&
                  ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
          String [] tokens = s.split(" ");
          if ( tokens.length == 14 ) {
            if ( tokens[7].matches("[AV]") ) {
              if ( tokens[7].matches("A") ) {
                na += 1;
              }
              else if ( tokens[12].matches("V") ) {
                nv += 1;
              }
              if ( nv + na > 0 ) {
                double newfa = na/(nv+na);
                if ( (int)(newfa*1000) != (int)(fa*1000) ) {
                  fa = newfa;
                  gps_valid_text.setText(String.format("%4.1f %%",fa*100));
                }
              }
            }
          }
        }
        else if ( s.startsWith("DS ") &&
                  ! s.startsWith("DS     - Display Scalar, channel(S0-S3), trigger(S4), time(S5).") &&
                  ! s.startsWith("DS 000006B4 00001413 00000D62 000006B1 00001414") ) {
          boolean reset = false;
          if ( s.startsWith("DS S0=00000000 S1=00000000 S2=00000000 S3=00000000") ) {
            reset = true;
          }
          else {
            String [] tokens = s.split(" ");
            if ( tokens.length >= 6 ) {
              boolean updating = false; 
              for ( int i=0; i<4; i++ ) {
                if ( tokens[i+1].startsWith("S") ) {
                  tokens[i+1] = tokens[i+1].substring(3);
                }
                if ( scalers[i] < 0 ) {
                  scalers[i] = Integer.parseInt(tokens[i+1],16);
                }
                else {
                  long newcount = Integer.parseInt(tokens[i+1],16);
                  if ( newcount != scalers[i] ) {
                    updating = true;
                    scalers[i] = newcount;
                  }
                }
              }
              if ( ! updating ) {
                snu += 1;
                snu_text.setText(Integer.toString(snu));
              }
            }
          }
          if ( reset ) {
            src += 1;
            src_text.setText(Integer.toString(src));
          }
        }
      }
    }

    private class ClearHistogramListener implements ActionListener {
      public void actionPerformed(ActionEvent e) {
        for ( int i=0; i<4; i++ ) {
          dataset[i].clearObservations();
        }
        na = 0;
        nv = 0;
        fa = 0;
        gps_valid_text.setText(String.format("%4.1f %%",fa*100));
        snu = 0;
        snu_text.setText(Integer.toString(snu));
        src = 0;
        src_text.setText(Integer.toString(src));
        ure = 0;
        ure_text.setText(Integer.toString(ure));
        ufe = 0;
        ufe_text.setText(Integer.toString(ufe));
        nana = 0;
        nana_text.setText(Integer.toString(nana));
      }
    }
    public PerformancePanel() {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      unpaired_rising_edge = new int [4];
      unpaired_falling_edge = new int [4];
      pulse = new Pulse[4];
      for ( int i=0; i<4; i++ ) {
        unpaired_rising_edge[i] = 0;
        unpaired_falling_edge[i] = 0;
      }

      TriggerOutputHandler trig_handler = new TriggerOutputHandler(this);
      kernel.AddOutputHandler(trig_handler);

      JLabel stat_label = new JLabel("--- Statistics ---");
      JLabel gps_valid_label = new JLabel("Valid GPS: ");
      gps_valid_text = new JTextField(String.format("%4.1f %%",fa*100));
      gps_valid_text.setEditable(false);
      JLabel nana_label = new JLabel("Pulses analyzed: ");
      nana_text = new JTextField(Integer.toString(nana));
      nana_text.setEditable(false);
      JLabel ure_label = new JLabel(" Rising orphans: ");
      ure_text = new JTextField(Integer.toString(ure));
      ure_text.setEditable(false);
      JLabel ufe_label = new JLabel("Falling orphans: ");
      ufe_text = new JTextField(Integer.toString(ufe));
      ufe_text.setEditable(false);
      JLabel snu_label = new JLabel("Scalers not updating: ");
      snu_text = new JTextField(Integer.toString(snu));
      snu_text.setEditable(false);
      JLabel src_label = new JLabel("Scalers reset: ");
      src_text = new JTextField(Integer.toString(src));
      src_text.setEditable(false);

      dataset = new SimpleHistogramDataset[4];
      chart = new JFreeChart[4];
      chart_panel = new ChartPanel[4];
      double values [] = { };
      for ( int i=0; i<4; i++ ) {
        dataset[i] = new SimpleHistogramDataset("Ch"+Integer.toString(i+1));
        for ( int j=0; j<nbin; j++ ) {
          dataset[i].addBin(new SimpleHistogramBin(bwid*j,bwid*(j+1),true,false));
        }
        dataset[i].setAdjustForBinSize(false);
        chart[i] = ChartFactory.createHistogram("Channel "+Integer.toString(i+1),
          "Time over threshold (ns)","Entries per 5 ns",dataset[i],
          PlotOrientation.VERTICAL,false,false,false);
        chart_panel[i] = new ChartPanel(chart[i]);
        chart_panel[i].setMouseZoomable(false);
        XYPlot xyplot = (XYPlot)chart[i].getPlot();
        NumberAxis axis = (NumberAxis)xyplot.getRangeAxis();
        axis.setAutoRangeMinimumSize(2,false);
        axis.setAutoRangeIncludesZero(true);   

      }

      ClearHistogramListener clear_listener = new ClearHistogramListener();
      JButton clear_button = new JButton("Clear");
      clear_button.addActionListener(clear_listener);

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addComponent(stat_label).
            addGroup(layout.createSequentialGroup().
              addComponent(gps_valid_label).
              addComponent(gps_valid_text)).
            addGroup(layout.createSequentialGroup().
              addComponent(nana_label).
              addComponent(nana_text)).
            addGroup(layout.createSequentialGroup().
              addComponent(ure_label).
              addComponent(ure_text)).
            addGroup(layout.createSequentialGroup().
              addComponent(ufe_label).
              addComponent(ufe_text)).
            addGroup(layout.createSequentialGroup().
              addComponent(snu_label).
              addComponent(snu_text)).
            addGroup(layout.createSequentialGroup().
              addComponent(src_label).
              addComponent(src_text)).
            addComponent(clear_button)).
          addGroup(layout.createParallelGroup().
            addComponent(chart_panel[0]).
            addComponent(chart_panel[1]).
            addComponent(chart_panel[2]).
            addComponent(chart_panel[3])));
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addComponent(stat_label).
            addGroup(layout.createParallelGroup().
              addComponent(gps_valid_label).
              addComponent(gps_valid_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(nana_label).
              addComponent(nana_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(ure_label).
              addComponent(ure_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(ufe_label).
              addComponent(ufe_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(snu_label).
              addComponent(snu_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addGroup(layout.createParallelGroup().
              addComponent(src_label).
              addComponent(src_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addComponent(clear_button)).
          addGroup(layout.createSequentialGroup().
            addComponent(chart_panel[0]).
            addComponent(chart_panel[1]).
            addComponent(chart_panel[2]).
            addComponent(chart_panel[3])));
    }
  }

  public class RatesPanel extends JPanel {
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

    public class RatesOutputHandler extends CosmicRayDetectorOutputHandler {
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
          kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
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
          kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
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
              kernel.sendCommand("ST");
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(frame,
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
          kernel.sendCommand("DS");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }

    public RatesPanel() {

      time_step = 0.1F;
      timer_task = new CheckScalers();
      timer = new Timer((int)(time_step*1000),timer_task);

      active = false;
      count = new int [5];
      initial_count = new int [5];
      final_count = new int [5];

      RatesOutputHandler rate_handler = new RatesOutputHandler();
      kernel.AddOutputHandler(rate_handler);

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

      CoincidenceControls coinc_panel = new CoincidenceControls();
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

  public class FluxPanel extends JPanel {
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

    public class FluxOutputHandler extends CosmicRayDetectorOutputHandler {
      JPanel panel;
      public FluxOutputHandler(JPanel p) {
        panel = p;
      }
      final void Process(String s) {
        if ( s.startsWith("ST ") && ! s.startsWith("ST 1008 +273 +086 3349 180022 021007 A  05 C5ED5FF1 106 6148 00171300 000A710F") ) {
          String [] status = s.substring(3).split("[ \r\n\t]");
          if ( status.length > 5 ) {
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
            double p = pfix.TruePressure(Integer.parseInt(status[0]));
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
              double ed = Math.sqrt(d);
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
            prev_count[i] = count;
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
          kernel.sendCommand("ST");
        }
        catch ( Exception e ) {
          JOptionPane.showMessageDialog(frame,
            "Error writing to serial port.",
            "Serial port error",JOptionPane.WARNING_MESSAGE);
        }
      }
    }
    private class SaveRateListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {

        int iret = file_chooser.showOpenDialog((JButton)evt.getSource());
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
    public FluxPanel() {

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
      count_deviationrenderer.setSeriesFillPaint(0, new Color(255, 200, 200));   
      count_deviationrenderer.setSeriesFillPaint(1, new Color(200, 200, 255));   
      count_xyplot.setRenderer(count_deviationrenderer);
      NumberAxis count_numberaxis = (NumberAxis)count_xyplot.getRangeAxis();   
      count_numberaxis.setAutoRangeIncludesZero(false);   
      count_numberaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
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

      JFreeChart coincidence_chart = ChartFactory.createXYLineChart("Coincidence rate (Hz)", "GPS time", "Rate (Hz)",
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
      coincidence_numberaxis.setAutoRangeIncludesZero(false);   
      coincidence_numberaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
      coincidence_xyplot.setDomainAxis(new DateAxis("GPS time"));   

      ChartPanel count_panel = new ChartPanel(count_chart);
      ChartPanel tp_panel = new ChartPanel(temperature_chart);
      ChartPanel coincidence_panel = new ChartPanel(coincidence_chart);

      FluxOutputHandler flux_handler = new FluxOutputHandler(this);
      kernel.AddOutputHandler(flux_handler);

      ClearRateListener clear_listener = new ClearRateListener();
      JButton clear_button = new JButton("Clear");
      clear_button.addActionListener(clear_listener);

      FillRateListener fill_listener = new FillRateListener();
      JButton fill_button = new JButton("Fill");
      fill_button.addActionListener(fill_listener);

      SaveRateListener save_listener = new SaveRateListener();
      JButton save_button = new JButton("Save...");
      save_button.addActionListener(save_listener);

      layout.setHorizontalGroup(
        layout.createParallelGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(count_panel).
              addComponent(tp_panel)).
            addComponent(coincidence_panel)).
          addGroup(layout.createSequentialGroup().
            addComponent(fill_button).
            addComponent(save_button).
            addComponent(clear_button)));
      layout.setVerticalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
            addComponent(count_panel).
              addComponent(tp_panel)).
            addComponent(coincidence_panel)).
          addGroup(layout.createParallelGroup().
            addComponent(fill_button).
            addComponent(save_button).
            addComponent(clear_button)));
    }
  }


  public class MuonLifetimePanel extends JPanel {
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

    public MuonLifetimePanel() {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);
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
      kernel.AddOutputHandler(muon_output);

      GateWidthControl gate_control = new GateWidthControl();
      PipelineDelayControl pipeline_control = new PipelineDelayControl();

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
              addComponent(deltat_panel[0]).
              addComponent(deltat_panel[1]).
              addComponent(deltat_panel[2]).
              addComponent(deltat_panel[3])).
            addComponent(lifetime_panel)).
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addGroup(layout.createSequentialGroup().
                addComponent(channel_label).
                addComponent(channel_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(veto_label).
                addComponent(veto_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
              addGroup(layout.createSequentialGroup().
                addComponent(gate_control).
                addComponent(pipeline_control))).
            addGroup(layout.createSequentialGroup().
                addComponent(clear_button).
                addComponent(fit_button).
                addComponent(load_button).
                addComponent(save_button))));

      layout.setVerticalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(deltat_panel[0]).
              addComponent(deltat_panel[1]).
              addComponent(deltat_panel[2]).
              addComponent(deltat_panel[3])).
            addComponent(lifetime_panel)).
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addGroup(layout.createParallelGroup().
                addComponent(channel_label).
                addComponent(channel_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
                addComponent(veto_label).
                addComponent(veto_spinner,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
              addGroup(layout.createParallelGroup().
                addComponent(gate_control).
                addComponent(pipeline_control))).
            addGroup(layout.createParallelGroup().
                addComponent(clear_button).
                addComponent(fit_button).
                addComponent(load_button).
                addComponent(save_button))));

    }
    public void AnalyzeEvent(java.util.Vector<Pulse> pulses) {
      if ( pulses.size() == 0 ) return;
      Pulse pmin = null;
      for ( int i=0; i<pulses.size(); i++ ) {
        Pulse p = (Pulse)pulses.get(i);
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
          Pulse p = (Pulse)pulses.get(i);
          found[p.Channel()] = true;
          if ( ! p.equals(pmin) ) {
            try {
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
            Pulse p = (Pulse)pulses.get(i);
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
    public class MuonOutputHandler extends CosmicRayDetectorOutputHandler {
      JPanel panel;
      java.util.Vector<Pulse> pulses;
      Pulse [] pulse;
      public MuonOutputHandler(JPanel p) {
        panel = p;
        pulses = new java.util.Vector<Pulse>();
        pulse = new Pulse [4];
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
                pulse[j] = new Pulse(j);
              }
              else if ( pulse[j] == null ) {
                pulse[j] = new Pulse(j);
              }
              if ( (fe[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetFallingEdge(t,fe[j]);
                if ( pulse[j].Valid() ) {
                  pulses.add(pulse[j]);
                  pulse[j] = new Pulse(j);
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
        lifetime_fit.SetDataset(lifetime_dataset);
        lifetime_fit.SetFitDataset(fit_dataset);
        lifetime_fit.SetPlot(lifetime_plot);
        fit.setVisible(true);
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

  public class MapPicture extends JPanel {
    double scale;
    double angle;
    double [] counter_x;
    double [] counter_y;
    ImageIcon map_image;

    void LoadMapImage(double latitude,double longitude,int zoom,int width,int height) {
      String map_url = "http://maps.google.com/maps/api/staticmap?center="+Double.toString(latitude)+","+Double.toString(longitude)+"&zoom="+Integer.toString(zoom)+"&size="+Integer.toString(width)+"x"+Integer.toString(height)+"&maptype=satellite&sensor=false";
      ImageIcon icon;
      try {
        URLConnection con = new URL(map_url).openConnection();
        InputStream is = con.getInputStream();
        int nbytes = con.getContentLength();
        byte bytes[] = new byte[nbytes];
        int nread = 0;
        while ( nread < nbytes ) {
          int n = is.read(bytes,nread,nbytes-nread);
          nread += n;
        }
        is.close();
        icon = new ImageIcon(bytes);
      }
      catch ( Exception e ) {
        System.out.println("Did not load new map image.");
        icon = new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/world_map.jpg")));
      }
      map_image = icon;
      repaint();
    }

    public MapPicture(int w,int h) {
      double latitude = 40.41170843;
      double longitude = -86.88868695;
      int zoom = 19;
      scale = 1.0;
      angle = 0.0;
      counter_x = new double [4];
      counter_y = new double [4];
      for ( int i=0; i<4; i++ ) {
        counter_x[i] = 0.0;
        counter_y[i] = 0.0;
      }
      LoadMapImage(latitude,longitude,zoom,w,h);
    }
    public void SetCounterCoordinates(int i,double x,double y) {
      counter_x[i] = x;
      counter_y[i] = y;
      repaint();
    }
    public void SetDirection(double a) {
      angle = a;
      repaint();
    }
    public void paintComponent(Graphics g) {
      double [] dx = { 0.2, -0.2, -0.2, 0.2, 0.2 };
      double [] dy = { 0.15, 0.15, -0.15, -0.15, 0.15 };

      super.paintComponent(g);
      Graphics2D g2d = (Graphics2D)g;
      Dimension size = getSize();
      int w = size.width;
      int h = size.height;
      g2d.drawImage(map_image.getImage(),0,0,null);
      g2d.setColor(Color.red);
      for ( int i=0; i<4; i++ ) {
        double x0 = 0, y0 = 0;
        for ( int j=0; j<5; j++ ) {
          double u = dx[j]*Math.cos(angle)-dy[j]*Math.sin(angle);
          double v = dx[j]*Math.sin(angle)+dy[j]*Math.cos(angle);
          double x1 = (counter_x[i]+u)*scale*w/2;
          double y1 = (counter_y[i]+v)*scale*h/2;
          if ( j > 0 ) {
            g2d.drawLine((int)(w/2+x0),(int)(h/2-y0),(int)(w/2+x1),(int)(h/2-y1));
          }
          else {
            double x = (counter_x[i]-0.1)*scale*w/2;
            double y = counter_y[i]*scale*h/2;
            g2d.drawString("Ch."+Integer.toString(i+1),(int)(w/2+x),(int)(h/2-y));
          }
          x0 = x1;
          y0 = y1;
        }
      }
    }
  }

  public class GeometryPanel extends JPanel {
    double latitude;
    double longitude;
    int zoom;
    AirShowerPanel air_shower_panel;

    JLabel [] counter_icon;
    JTextField [] cable_length;
    JTextField [] counter_area;
    JTextField [] east_west;
    double [] east_west_value;
    JTextField [] north_south;
    double [] north_south_value;
    JTextField [] up_down;
    double [] up_down_value;
    JRadioButton stacked_button, unstacked_button;
    JTextField latitude_text;
    JTextField longitude_text;
    JTextField altitude_text;
    JTextField gps_cable_text;

    int angle;
    JSlider orientation;
    MapPicture map;

    private class ButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JRadioButton button = (JRadioButton)evt.getSource();
        if ( button == stacked_button ) {
          for ( int i=0; i<4; i++ ) {
            east_west_value[i] = 0;
            north_south_value[i] = 0;
            up_down_value[i] = 0.12-0.04*i;
            east_west[i].setText(String.format("%.2f",east_west_value[i]));
            north_south[i].setText(String.format("%.2f",north_south_value[i]));
            up_down[i].setText(String.format("%.2f",up_down_value[i]));
            map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);
          }
        }
        else if ( button == unstacked_button ) {
          double [] east_west_unstacked = { 0.5, -0.5, -0.5, 0.5 };
          double [] north_south_unstacked = { 0.5, 0.5, -0.5, -0.5 };
          for ( int i=0; i<4; i++ ) {
            east_west_value[i] = east_west_unstacked[i];
            north_south_value[i] = north_south_unstacked[i];
            up_down_value[i] = 0.0;
            east_west[i].setText(String.format("%.2f",east_west_value[i]));
            north_south[i].setText(String.format("%.2f",north_south_value[i]));
            up_down[i].setText(String.format("%.2f",up_down_value[i]));
            map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);
          }
        }
      }
    }
    private class ZoomListener implements ChangeListener {
      public void stateChanged(ChangeEvent e) {
        JSlider slider = (JSlider)e.getSource();
        if (! slider.getValueIsAdjusting() ) {
          zoom = slider.getValue();
          Dimension size = map.getSize();
          int w = size.width;
          int h = size.height;
          map.LoadMapImage(latitude,longitude,zoom,w,h);
        }
      }
    }
    private class OrientationListener implements ChangeListener {
      public void stateChanged(ChangeEvent e) {
        JSlider slider = (JSlider)e.getSource();
        if ( slider.getValueIsAdjusting() ) {
          int newangle = slider.getValue();
          if ( newangle != angle ) {
            double delta = (newangle-angle)*0.01745329251994329576;
            for ( int i=0; i<4; i++ ) {
              double x = east_west_value[i];
              double y = north_south_value[i];
              double u = x*Math.cos(delta)-y*Math.sin(delta);
              double v = x*Math.sin(delta)+y*Math.cos(delta);
              east_west_value[i] = u;
              north_south_value[i] = v;
              east_west[i].setText(String.format("%.2f",east_west_value[i]));
              north_south[i].setText(String.format("%.2f",north_south_value[i]));
              map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);
              map.SetDirection(newangle*0.01745329251994329576);
            }
            angle = newangle;
          }
        }
      }
    }
    private class CoordinateListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        for ( int i=0; i<4; i++ ) {
          if ( field == east_west[i] ) {
            east_west_value[i] = Double.parseDouble(field.getText());
            map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);
          }
          else if ( field == north_south[i] ) {
            north_south_value[i] = Double.parseDouble(field.getText());
            map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);
          }
          else if ( field == up_down[i] ) {
            up_down_value[i] = Double.parseDouble(field.getText());
          }
        }
      }
    }
    private class UpdateGeometryListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        air_shower_panel.UpdateGeometry(east_west_value,north_south_value,up_down_value,angle);
      }
    }

    public class MapOutputHandler extends CosmicRayDetectorOutputHandler {
      final void Process(String s) {
        String [] tokens = s.split("[ \t\r\n:]");
        if ( tokens.length == 8 && tokens[1].equals("Latitude") ) {
          latitude_text.setText(s.substring(12,28));
          double lat = Double.parseDouble(tokens[5]) + Double.parseDouble(tokens[6])/60.0;
          if ( tokens[7] == "S" ) lat = -lat;
          latitude = lat;
        }
        else if ( tokens.length > 1 && tokens[1].equals("Longitude") ) {
          longitude_text.setText(s.substring(12));
          double lon = Double.parseDouble(tokens[3]) + Double.parseDouble(tokens[4])/60.0;
          if ( tokens[5].equals("W") ) lon = -lon;
          longitude = lon;
        }
        else if ( tokens.length > 1 && tokens[1].equals("Altitude") ) {
          altitude_text.setText(s.substring(12));
        }
        else if ( tokens.length == 4 && tokens[1].equals("ChkSumErr") ) {
          Dimension size = map.getSize();
          int w = size.width;
          int h = size.height;
          map.LoadMapImage(latitude,longitude,zoom,w,h);
        }
      }
    }

    public GeometryPanel(AirShowerPanel a) {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);
      air_shower_panel = a;

      latitude = 40.41170843;
      longitude = -86.88868695;
      zoom = 19;

      map = new MapPicture(450,450);

      JLabel zoom_label = new JLabel("Zoom",JLabel.CENTER);
      zoom_label.setAlignmentX(Component.CENTER_ALIGNMENT);
      JSlider zoom_slider = new JSlider(JSlider.HORIZONTAL,0,20,zoom);
      ZoomListener zoom_listener = new ZoomListener();
      zoom_slider.addChangeListener(zoom_listener);
      zoom_slider.setMajorTickSpacing(10);
      zoom_slider.setMinorTickSpacing(1);
      zoom_slider.setPaintTicks(true);
      zoom_slider.setPaintLabels(true);

      MapOutputHandler map_handler = new MapOutputHandler();
      kernel.AddOutputHandler(map_handler);

      GridLayout table_layout = new GridLayout(5,6,10,5);
      JPanel table = new JPanel(table_layout);

      JLabel [] column_labels = new JLabel [6];
      column_labels[0] = new JLabel("Counter");
      column_labels[1] = new JLabel("<html>Cable<br>length (m)</html>");
      column_labels[2] = new JLabel("Area (cm\u00b2)");
      column_labels[3] = new JLabel("E-W (m)");
      column_labels[4] = new JLabel("N-S (m)");
      column_labels[5] = new JLabel("Up-Dn (m)");
      for ( int i=0; i<6; i++ ) {
        column_labels[i].setPreferredSize(new Dimension(80,20));
        column_labels[i].setMinimumSize(new Dimension(70,15));
        column_labels[i].setMaximumSize(new Dimension(90,25));
        table.add(column_labels[i]);
      }
      counter_icon = new JLabel [4];
      cable_length = new JTextField [4];
      counter_area = new JTextField [4];
      east_west = new JTextField [4];
      north_south = new JTextField [4];
      up_down = new JTextField [4];
      east_west_value = new double [] { 0.5, -0.5, -0.5, 0.5 };
      north_south_value = new double [] { 0.5, 0.5, -0.5, -0.5 };
      up_down_value = new double [] { 0.0, 0.0, 0.0, 0.0 };

      CoordinateListener ewnsud_listener = new CoordinateListener();
      for ( int i=0; i<4; i++ ) {
        counter_icon[i] = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/geo_det"+Integer.toString(i+1)+".gif"))));
        counter_icon[i].setPreferredSize(new Dimension(65,35));
        counter_icon[i].setMinimumSize(new Dimension(65,35));
        counter_icon[i].setMaximumSize(new Dimension(65,35));

        cable_length[i] = new JTextField();
        cable_length[i].setEditable(true);
        cable_length[i].setPreferredSize(new Dimension(80,15));
        cable_length[i].setMinimumSize(new Dimension(70,15));
        cable_length[i].setMaximumSize(new Dimension(90,15));
        cable_length[i].setText("15.30");

        counter_area[i] = new JTextField();
        counter_area[i].setEditable(true);
        counter_area[i].setPreferredSize(new Dimension(80,15));
        counter_area[i].setMinimumSize(new Dimension(70,15));
        counter_area[i].setMaximumSize(new Dimension(90,15));
        counter_area[i].setText("744.2");

        east_west[i] = new JTextField();
        east_west[i].setEditable(true);
        east_west[i].setPreferredSize(new Dimension(80,15));
        east_west[i].setMinimumSize(new Dimension(70,15));
        east_west[i].setMaximumSize(new Dimension(90,15));
        east_west[i].setText(String.format("%.2f",east_west_value[i]));
        east_west[i].addActionListener(ewnsud_listener);

        north_south[i] = new JTextField();
        north_south[i].setEditable(true);
        north_south[i].setPreferredSize(new Dimension(80,15));
        north_south[i].setMinimumSize(new Dimension(70,15));
        north_south[i].setMaximumSize(new Dimension(90,15));
        north_south[i].setText(String.format("%.2f",north_south_value[i]));
        north_south[i].addActionListener(ewnsud_listener);

        map.SetCounterCoordinates(i,east_west_value[i],north_south_value[i]);

        up_down[i] = new JTextField();
        up_down[i].setEditable(true);
        up_down[i].setPreferredSize(new Dimension(80,15));
        up_down[i].setMinimumSize(new Dimension(70,15));
        up_down[i].setMaximumSize(new Dimension(90,15));
        up_down[i].setText(String.format("%.2f",up_down_value[i]));
        up_down[i].addActionListener(ewnsud_listener);

        table.add(counter_icon[i]);
        table.add(cable_length[i]);
        table.add(counter_area[i]);
        table.add(east_west[i]);
        table.add(north_south[i]);
        table.add(up_down[i]);
      }
      table.setPreferredSize(new Dimension(80*6,35*5));
      table.setMinimumSize(new Dimension(70*6,30*5));
      table.setMaximumSize(new Dimension(90*6,40*5));

      angle = 0;
      orientation = new JSlider(JSlider.HORIZONTAL,0,360,angle);
      OrientationListener orientation_listener = new OrientationListener();
      orientation.addChangeListener(orientation_listener);
      orientation.setMajorTickSpacing(90);
      orientation.setMinorTickSpacing(10);
      orientation.setPaintTicks(true);
      orientation.setPaintLabels(true);

      ButtonListener button_listener = new ButtonListener();
      JLabel stacked_label = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/med_stacked.gif"))));
      stacked_button = new JRadioButton("Stacked");
      stacked_button.setSelected(false);
      stacked_button.addActionListener(button_listener);

      JLabel unstacked_label = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/med_unstacked.gif"))));
      unstacked_button = new JRadioButton("Unstacked");
      unstacked_button.setSelected(true);
      unstacked_button.addActionListener(button_listener);

      ButtonGroup group = new ButtonGroup();
      group.add(stacked_button);
      group.add(unstacked_button);

      JPanel button_panel = new JPanel(new GridLayout(1,0));
      button_panel.add(stacked_label);
      button_panel.add(stacked_button);
      button_panel.add(unstacked_label);
      button_panel.add(unstacked_button);

      JLabel latitude_label = new JLabel("Latitude: ");
      latitude_text = new JTextField();
      latitude_text.setEditable(false);
      latitude_text.setPreferredSize(new Dimension(120,20));
      latitude_text.setMinimumSize(new Dimension(120,20));
      latitude_text.setMaximumSize(new Dimension(120,20));
      latitude_text.setText("0:0.0 N");

      JLabel longitude_label = new JLabel("Longitude: ");
      longitude_text = new JTextField();
      longitude_text.setEditable(false);
      longitude_text.setPreferredSize(new Dimension(120,20));
      longitude_text.setMinimumSize(new Dimension(120,20));
      longitude_text.setMaximumSize(new Dimension(120,20));
      longitude_text.setText("0:0.0 W");

      JLabel altitude_label = new JLabel("Altitude: ");
      altitude_text = new JTextField();
      altitude_text.setEditable(false);
      altitude_text.setPreferredSize(new Dimension(80,20));
      altitude_text.setMinimumSize(new Dimension(80,20));
      altitude_text.setMaximumSize(new Dimension(80,20));
      altitude_text.setText("0");

      JLabel gps_cable_label = new JLabel("GPS cable length (m): ");
      gps_cable_text = new JTextField();
      gps_cable_text.setEditable(true);
      gps_cable_text.setPreferredSize(new Dimension(50,20));
      gps_cable_text.setMinimumSize(new Dimension(50,20));
      gps_cable_text.setMaximumSize(new Dimension(50,20));
      gps_cable_text.setText("0");

      JButton update_button = new JButton("Update geometry");
      UpdateGeometryListener update_listener = new UpdateGeometryListener();
      update_button.addActionListener(update_listener);

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addComponent(map,450,450,450).
            addComponent(zoom_label).
            addComponent(zoom_slider,200,200,200)).
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(table).
            addComponent(orientation,300,300,300).
            addComponent(button_panel,400,400,400).
            addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
              addGroup(layout.createSequentialGroup().
                addComponent(latitude_label).
                addComponent(latitude_text).
                addComponent(longitude_label).
                addComponent(longitude_text)).
              addGroup(layout.createSequentialGroup().
                addComponent(altitude_label).
                addComponent(altitude_text).
                addComponent(gps_cable_label).
                addComponent(gps_cable_text))).
              addComponent(update_button))
      );
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addComponent(map,450,450,450).
            addComponent(zoom_label).
            addComponent(zoom_slider)).
          addGroup(layout.createSequentialGroup().
            addComponent(table).
            addComponent(orientation).
            addComponent(button_panel,50,50,50).
            addGroup(layout.createSequentialGroup().
              addGroup(layout.createParallelGroup().
                addComponent(latitude_label).
                addComponent(latitude_text).
                addComponent(longitude_label).
                addComponent(longitude_text)).
              addGroup(layout.createParallelGroup().
                addComponent(altitude_label).
                addComponent(altitude_text).
                addComponent(gps_cable_label).
                addComponent(gps_cable_text))).
              addComponent(update_button))
      );
    }
  }

  public class AirShowerPanel extends JPanel {
    EventPicture view;
    OscilloscopePicture scope;
    JTextArea output;

    public class EventPicture extends JPanel {
      double phi;
      double theta;
      double radius;
      double height;
      double scale;

      java.util.Vector<Double> px;
      java.util.Vector<Double> py;
      java.util.Vector<Double> pz;
      java.util.Vector<Color> color;
      java.util.Vector<String> text;

      java.util.Vector<Double> qx;
      java.util.Vector<Double> qy;
      java.util.Vector<Double> qz;
      java.util.Vector<Color> chcol;

      double [] det_x;
      double [] det_y;
      double [] det_z;

      public EventPicture() {
        phi = 0.0;
        theta = 1.04719755119659774642;
        radius = 5.5;
        height = 0.5;

        px = new java.util.Vector<Double>();
        py = new java.util.Vector<Double>();
        pz = new java.util.Vector<Double>();
        color = new java.util.Vector<Color>();
        text = new java.util.Vector<String>();
        qx = new java.util.Vector<Double>();
        qy = new java.util.Vector<Double>();
        qz = new java.util.Vector<Double>();
        chcol = new java.util.Vector<Color>();
        det_x = new double [4];
        det_y = new double [4];
        det_z = new double [4];
      }
      void Reset() {
        color.clear();
        text.clear();
        px.clear();
        py.clear();
        pz.clear();

        chcol.clear();
        qx.clear();
        qy.clear();
        qz.clear();
      }
      void ResetEvent() {
        chcol.clear();
        qx.clear();
        qy.clear();
        qz.clear();
      }
      void AddPoint(double a,double b,double c,Color d) {
        px.add(a);
        py.add(b);
        pz.add(c);
        color.add(d);
        text.add(new String());
      }
      void AddFallingEdge(int i,double t) {
        Color [] channel_colors = { Color.red, Color.blue, Color.green, Color.orange };
        qx.add(det_x[i]);
        qy.add(det_y[i]);
        qz.add(det_z[i]+t*scale);
        chcol.add(channel_colors[i]);
        repaint();
      }
      void AddRisingEdge(int i,double t) {
        Color blank = new Color(0,0,0,0);
        chcol.add(blank);
        qx.add(det_x[i]);
        qy.add(det_y[i]);
        qz.add(det_z[i]+t*scale);
      }
      void AddText(double a,double b,double c,Color d,String s) {
        px.add(a);
        py.add(b);
        pz.add(c);
        color.add(d);
        text.add(s);
      }
      void AddArrow() {
        Color c = new Color(0,0,0,0);
        AddPoint(-0.05,-0.05,0,c);
        c = Color.blue;
        AddPoint(-0.05,0.25,0,c);
        AddPoint(-0.10,0.25,0,c);
        AddPoint(0.0,0.35,0,c);
        AddPoint(0.10,0.25,0,c);
        AddPoint(0.05,0.25,0,c);
        AddPoint(0.05,-0.05,0,c);
        AddPoint(-0.05,-0.05,0,c);
        AddText(-0.02,0.45,0,c,"N");
      }
      void AddDetectorElement(int i,double x,double y,double z,double a,Color c) {
        det_x[i] = x;
        det_y[i] = y;
        det_z[i] = z;
        double [] dx = { 0.2, -0.2, -0.2, 0.2, 0.2 };
        double [] dy = { 0.15, 0.15, -0.15, -0.15, 0.15 };
        Color blank = new Color(0,0,0,0);
        for ( int j=0; j<5; j++ ) {
          double u = dx[j]*Math.cos(a)-dy[j]*Math.sin(a);
          double v = dx[j]*Math.sin(a)+dy[j]*Math.cos(a);
          if ( j == 0 ) {
            AddPoint(x+u,y+v,z,blank);
          }
          else {
            AddPoint(x+u,y+v,z,c);
          }
        }
      }
//
//  zmax is the maximum height of the scale in distance units
//  dz is the spacing between minor divisions in distance units
//  tz is the spacing between major divisions in distance units
//  mult is the multiplicitive factor that relates distance to time
//
      void AddScale(double zmax,double dz,double tz,double mult,Color c) {
        Color blank = new Color(0,0,0,0);
        AddPoint(0,0,0,blank);
        AddPoint(0,0,zmax,c);
        for ( double z=dz; z<zmax; z+=dz ) {
          AddPoint(0,-0.01,z,blank);
          AddPoint(0,0.01,z,c);
          AddPoint(-0.01,0,z,blank);
          AddPoint(0.01,0,z,c);
        }
        for ( double z=tz; z<=zmax; z+=tz ) {
          AddText(0.02,0.02,z,c,String.format("%4.1f ns",mult*z));
        }
        scale = 1/mult;
      }
      public void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D)g;
        Dimension size = getSize();
        int w = size.width;
        int h = size.height;
        g2d.setColor(Color.black);
        g2d.fillRoundRect(1,1,w-2,h-2,10,10);

        double dist = 2.0;
        double rx = radius*Math.cos(phi)*Math.sin(theta);
        double ry = radius*Math.sin(phi)*Math.sin(theta);
        double rz = radius*Math.cos(theta);
        double rr = Math.sqrt(rx*rx+ry*ry+rz*rz);
        double nx = -rx/rr;
        double ny = -ry/rr;
        double nz = -rz/rr;
        double ux = -Math.sin(phi);
        double uy = Math.cos(phi);
        double uz = 0.0;
        double vx = uy*nz-uz*ny;
        double vy = uz*nx-ux*nz;
        double vz = ux*ny-uy*nx;
        double xx = rx+dist*nx;
        double xy = ry+dist*ny;
        double xz = rz+dist*nz;

        double x0 = 0, y0 = 0, x1, y1;
        for ( int i=0; i<color.size()+chcol.size(); i++ ) {
          Color c;
          String str;
          double x, y, z;
          if ( i < color.size() ) {
            c = color.elementAt(i);
            str = text.elementAt(i);
            x = px.elementAt(i);
            y = py.elementAt(i);
            z = pz.elementAt(i);
          }
          else {
            c = chcol.elementAt(i-color.size());
            str = "";
            x = qx.elementAt(i-color.size());
            y = qy.elementAt(i-color.size());
            z = qz.elementAt(i-color.size());
          }
          double dx = xx-x;
          double dy = xy-y;
          double dz = xz-z;
          double fx = rx-x;
          double fy = ry-y;
          double fz = rz-z;
          double s = (dx*nx+dy*ny+dz*nz)/(fx*nx+fy*ny+fz*nz);
          double sx = -dx + s*fx;
          double sy = -dy + s*fy;
          double sz = -dz + s*fz;
          double u = sx*ux + sy*uy + sz*uz;
          double v = sx*vx + sy*vy + sz*vz - height;
          x1 = u*w/2;
          y1 = v*h/2;
          if ( str.length() > 0 ) {
            g2d.setColor(c);
            g2d.drawString(str,(int)(w/2+x1),(int)(h/2-y1));
          }
          else if ( c.getAlpha() > 0 ) {
            g2d.setColor(c);
            g2d.drawLine((int)(w/2+x0),(int)(h/2-y0),(int)(w/2+x1),(int)(h/2-y1));
            if ( i > color.size() ) {
              g2d.fillRect((int)(w/2+x0-2),(int)(h/2-y0-2),4,4);
            }
          }
          x0 = x1;
          y0 = y1;
        }
      }
      void setPhi(double a) {
        phi = a*0.01745329251994329576;
        repaint();
      }
      void setRadius(double r) {
        radius = r;
        repaint();
      }
      void setTheta(double a) {
        theta = 1.57079632679489661922-a*0.01745329251994329576;
        repaint();
      }
    }

    public class OscilloscopePicture extends JPanel {
      JFreeChart chart;
      XYSeriesCollection dataset;
      XYSeries [] disc;
      public OscilloscopePicture() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        disc = new XYSeries [4];
        dataset = new XYSeriesCollection();
        BasicStroke stroke = new BasicStroke(2.0f);
        for ( int i=0; i<4; i++ ) {
          disc[i] = new XYSeries("Chan. "+Integer.toString(i+1),false,true);
          dataset.addSeries(disc[i]);
        }
        chart = ChartFactory.createXYStepChart(
          "Inferred waveforms",
          "Time (ns)",
          "",
          dataset,
          PlotOrientation.VERTICAL,
          true,   // legend
          true,   // tooltips
          false   // url
        );
        XYPlot plot = (XYPlot)chart.getPlot();
        plot.getRenderer().setSeriesPaint(3,Color.orange);

        plot.getRangeAxis().setRange(-0.5,7.5);
        plot.setDomainAxis(0,new NumberAxis("Time (ns)"));
        ((NumberAxis)(plot.getDomainAxis())).setNumberFormatOverride(
          new NumberFormat() {
            @Override
            public StringBuffer format(double number,StringBuffer toAppendTo,FieldPosition pos) {
              return new StringBuffer(String.format("%6.1f",number));
            }
            @Override
            public StringBuffer format(long number, StringBuffer toAppendTo, FieldPosition pos) {
              return new StringBuffer(String.format("%6.0f",number));
            }
            @Override
            public Number parse(String source, ParsePosition parsePosition) {
              return null;
            }
          }
        );
        for ( int i=0; i<4; i++ ) {
          plot.getRenderer().setSeriesStroke(i,stroke);
        }

        ChartPanel panel = new ChartPanel(chart);
        layout.setHorizontalGroup(
          layout.createParallelGroup().
            addComponent(panel)
        );
        layout.setVerticalGroup(
          layout.createSequentialGroup().
            addComponent(panel)
        );
      }
      void ClearWaveforms() {
        for ( int i=0; i<4; i++ ) {
          disc[i].clear();
          disc[i].add(0,2*i);
        }
      }
      void AddTransition(int i,double t,double v) {
        double tend [] = { 50.0, 100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0,
                           10000.0, 20000.0, 50000.0, 100000.0, -1 };
        int n;
        double tmax = tend[0];
        for ( int j=0; j<4; j++ ) {
          n = disc[j].getItemCount();
          if ( n > 0 ) {
            double x = disc[j].getX(n-1).doubleValue();
            disc[j].remove(n-1);
            if ( x > tmax ) tmax = x;
          }
        }
        if ( tmax <= t ) {
          int j = 0;
          while ( tend[j] > 0 && tend[j] < t ) j++;
          if ( tend[j] < 0 ) j -= 1;
          tmax = tend[j];
        }
        
        n = disc[i].getItemCount();
        if ( n == 0 ) {
          disc[i].add(0,2*i);
        }
        disc[i].add(t,2*i+v);
        for ( int j=0; j<4; j++ ) {
          n = disc[j].getItemCount();
          if ( n > 0 ) {
            double y = disc[j].getY(n-1).doubleValue();
            disc[j].add(tmax,y);
          }
        }
      }
    }

    public class PhiListener implements ChangeListener {
      public void stateChanged(ChangeEvent evt) {
        JSlider source = (JSlider)evt.getSource();
        double ang = (double)source.getValue();
        view.setPhi(ang);
      }
    }
    public class RadiusListener implements ChangeListener {
      public void stateChanged(ChangeEvent evt) {
        JSlider source = (JSlider)evt.getSource();
        double r = (double)source.getValue();
        view.setRadius(0.1*r+3.0);
      }
    }
    public class ThetaListener implements ChangeListener {
      public void stateChanged(ChangeEvent evt) {
        JSlider source = (JSlider)evt.getSource();
        double ang = (double)source.getValue();
        view.setTheta(ang);
      }
    }

    void UpdateGeometry(double [] x,double [] y,double [] z,double angle) {
      view.Reset();
      view.AddArrow();
      for ( int i=0; i<4; i++ ) {
        view.AddDetectorElement(i,x[i],y[i],z[i],angle,Color.red);
      }
      view.AddScale(2.0,0.1,0.5,100.0,Color.gray);
    }

    public class AirShowerOutputHandler extends CosmicRayDetectorOutputHandler {
      long t0;
      Pulse [] pulse;
      public AirShowerOutputHandler() {
        pulse = new Pulse [4];
        t0 = 0;
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
              re[j] = Integer.parseInt(tokens[i++],16);
              fe[j] = Integer.parseInt(tokens[i++],16);
              if ( j == 0 && (re[0]&0x80) != 0 ) {
                scope.ClearWaveforms();
                view.ResetEvent();
                t0 = t;
                output.setText("");
              }
              if ( (fe[j]&0x20) != 0 ) {
                double time = 40.0*(t-t0)+1.25*(fe[j]&0x1f);
                scope.AddTransition(j,time,0);
                if ( pulse[j] != null ) {
                  pulse[j].SetFallingEdge(t,fe[j]);
                  time = 40.0*(pulse[j].RisingEdgeCounter()-t0)+1.25*(pulse[j].RisingEdgeTime()&0x1f);
                  view.AddRisingEdge(j,time);
                  time = 40.0*(pulse[j].FallingEdgeCounter()-t0)+1.25*(pulse[j].FallingEdgeTime()&0x1f);
                  view.AddFallingEdge(j,time);
                  pulse[j] = null;
                }
              }
              if ( (re[j]&0x20) != 0 ) {
                double time = 40.0*(t-t0)+1.25*(re[j]&0x1f);
                scope.AddTransition(j,time,1);
                pulse[j] = new Pulse(j);
                pulse[j].SetRisingEdge(t,re[j]);
              }
            }
            output.append(s);
          }
        }
      }
    }

    public AirShowerPanel() {
      int w = 400;
      int h = 400;
      JPanel output_panel = new JPanel();
      output_panel.setBorder(BorderFactory.createTitledBorder("Raw data"));

      output = new JTextArea();
      output.setLineWrap(false);
      output.setEditable(false);
      output.setPreferredSize(new Dimension(450,80));
      output.setMinimumSize(new Dimension(450,80));
      output.setMaximumSize(new Dimension(450,80));
      output.setFont(new Font("monospaced",Font.PLAIN,10));
      JScrollPane output_scroll = new JScrollPane(output,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,JScrollPane.HORIZONTAL_SCROLLBAR_NEVER); 
      output_panel.add(output_scroll);

      view = new EventPicture();
      scope = new OscilloscopePicture();
      JPanel scope_panel = new JPanel();
      scope_panel.setBorder(BorderFactory.createTitledBorder("Oscilloscope"));
      scope_panel.add(scope);
      double [] x = { 1, -1, -1, 1 };
      double [] y = { 1, 1, -1, -1 };
      for ( int i=0; i<4; i++ ) {
        view.AddDetectorElement(i,x[i],y[i],0,0,Color.red);
      }
      view.AddScale(2.0,0.1,0.5,100.0,Color.gray);
  
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);

      JSlider phi = new JSlider(JSlider.HORIZONTAL,0,360,0);
      phi.addChangeListener(new PhiListener());
      phi.setMajorTickSpacing(30);
      phi.setMinorTickSpacing(10);
      phi.setPaintTicks(true);

      JSlider radius = new JSlider(JSlider.HORIZONTAL,0,100,25);
      radius.addChangeListener(new RadiusListener());
      radius.setMajorTickSpacing(10);
      radius.setMinorTickSpacing(2);
      radius.setPaintTicks(true);

      JSlider theta = new JSlider(JSlider.VERTICAL,0,90,30);
      theta.addChangeListener(new ThetaListener());
      theta.setMajorTickSpacing(10);
      theta.setMinorTickSpacing(2);
      theta.setPaintTicks(true);

      JPanel picture_panel = new JPanel();
      GroupLayout picture_layout = new GroupLayout(picture_panel);
      picture_panel.setLayout(picture_layout);
      picture_layout.setHorizontalGroup(
        picture_layout.createParallelGroup().
          addGroup(picture_layout.createSequentialGroup().
            addComponent(view,w,w,w).
            addComponent(theta)).
          addComponent(phi,w,w,w).
          addComponent(radius,w,w,w)
      );
      picture_layout.setVerticalGroup(
        picture_layout.createSequentialGroup().
          addGroup(picture_layout.createParallelGroup().
            addComponent(view,h,h,h).
            addComponent(theta,h,h,h)).
          addComponent(phi).
          addComponent(radius)
      );
      picture_panel.setBorder(BorderFactory.createTitledBorder("Event picture"));

      AirShowerOutputHandler trig_handler = new AirShowerOutputHandler();
      kernel.AddOutputHandler(trig_handler);

      CounterEnableDisableControls cecd_controls = new CounterEnableDisableControls(); 
      CoincidenceControls trigger_panel = new CoincidenceControls();
      trigger_panel.setBorder(BorderFactory.createTitledBorder("Trigger"));

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(picture_panel).
            addComponent(trigger_panel).
            addComponent(cecd_controls)).
          addGroup(layout.createParallelGroup().
            addComponent(scope_panel).
            addComponent(output_panel))
      );
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addComponent(picture_panel).
            addComponent(trigger_panel).
            addComponent(cecd_controls)).
          addGroup(layout.createSequentialGroup().
            addComponent(scope_panel,460,460,460).
            addComponent(output_panel,120,120,120))
      );
    }
  }
  
  public CosmicRayDetector(String port) {
    super(new GridLayout(1,1));

    default_port = port;
    kernel = new CosmicRayDetectorKernel(frame);

    JTabbedPane tabbedPane = new JTabbedPane();
    ImageIcon icon = null;

    control_panel = new ControlPanel();

    tabbedPane.addTab("Control Panel",icon,control_panel,"Low-level controls of cosmic ray detector electronics");
    tabbedPane.setMnemonicAt(0,KeyEvent.VK_1);
    
    rates_panel = new RatesPanel();
    tabbedPane.addTab("Rates",icon,rates_panel,"Graphs count rates");
    tabbedPane.setMnemonicAt(1,KeyEvent.VK_2);

    performance_panel = new PerformancePanel();
    tabbedPane.addTab("Performance",icon,performance_panel,"Histograms of time-over-threshold");
    tabbedPane.setMnemonicAt(2,KeyEvent.VK_3);

    flux_panel = new FluxPanel();
    tabbedPane.addTab("Flux",icon,flux_panel,"Graphs count rates as functions of time");
    tabbedPane.setMnemonicAt(3,KeyEvent.VK_4);

    lifetime_panel = new MuonLifetimePanel();
    tabbedPane.addTab("Muon lifetime",icon,lifetime_panel,"Muon lifetime analysis");
    tabbedPane.setMnemonicAt(4,KeyEvent.VK_5);

    air_shower_panel = new AirShowerPanel();
    tabbedPane.addTab("Air shower",icon,air_shower_panel,"Air shower analysis");
    tabbedPane.setMnemonicAt(5,KeyEvent.VK_6);

    map_panel = new GeometryPanel(air_shower_panel);
    tabbedPane.addTab("Geometry",icon,map_panel,"Enter geometry data");
    tabbedPane.setMnemonicAt(6,KeyEvent.VK_7);

    JScrollPane pain_in_the_butt = new JScrollPane(tabbedPane,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
//     pain_in_the_butt.add(tabbedPane);
//    add(tabbedPane);
    add(pain_in_the_butt);
    tabbedPane.setTabLayoutPolicy(JTabbedPane.SCROLL_TAB_LAYOUT);
  }

  protected JComponent makeTextPanel(String text) {
    JPanel panel = new JPanel(false);
    JLabel filler = new JLabel(text);
    filler.setHorizontalAlignment(JLabel.CENTER);
    panel.setLayout(new GridLayout(1,1));
    panel.add(filler);
    return panel;
  }

  protected static ImageIcon createImageIcon(String path) {
    java.net.URL imgURL = CosmicRayDetector.class.getResource(path);
    if ( imgURL != null ) {
      return new ImageIcon(imgURL);
    }
    else {
      System.err.println("Couldn't find file: " + path );
      return null;
    }
  }


  private static class TitleHyperlinkListener implements HyperlinkListener {
    public void hyperlinkUpdate(HyperlinkEvent evt) {
      if (evt.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
        JEditorPane pane = (JEditorPane)evt.getSource();
        System.out.println("Opening "+evt.getURL());
        try {
          URI uri = new URI(evt.getURL().toString());
          java.awt.Desktop.getDesktop().browse(uri);
        }
        catch ( Exception e ) {
          System.out.println("Did not open "+evt.getURL().toString());
        }
      }
    }
  }

  public static class SplashScreen extends JPanel {
    
    public SplashScreen() {

      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);

      JLabel shower_label = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/crop.jpg"))));
      JEditorPane title_text = new JEditorPane();
      title_text.setEditable(false);
      java.net.URL url = TitlePage.class.getResource("/title.html");
      if ( url != null ) {
        try {
          title_text.setPage(url);
        }
        catch ( IOException e ) {
          System.out.println("Bad url");
        }
      }
      else {
        System.out.println("Did not find url");
      }
      title_text.addHyperlinkListener(new TitleHyperlinkListener());
      addMouseListener(new MouseAdapter() {
        public void mousePressed(MouseEvent e) {
          title.setVisible(false);
          title.dispose();
        }
      } );

      layout.setHorizontalGroup(layout.createSequentialGroup().
        addComponent(shower_label).
        addComponent(title_text,450,450,450)
      );
      layout.setVerticalGroup(layout.createParallelGroup().
        addComponent(shower_label).
        addComponent(title_text)
      );
      final Runnable closeRunner = new Runnable() {
        public void run() {
          title.setVisible(false);
          title.dispose();
        }
      };
      final Runnable waitRunner = new Runnable() {
        public void run() {
          try {
            Thread.sleep(10*1000);
            SwingUtilities.invokeAndWait(closeRunner);
          } 
          catch ( Exception e ) {
            e.printStackTrace();
          }
        }
      };

      Thread splash_thread = new Thread(waitRunner,"SplashThread");
      splash_thread.start();

    }

  }

  public static class LifetimeFitControls extends JPanel {
    SimpleHistogramDataset dataset;
    XYSeriesCollection fataset;
    JRadioButton two_parameter_fit;
    JRadioButton three_parameter_fit;
    JTextField tmin_text;
    XYPlot lifetime_plot;

    double [] fitpar;
    double [] fiterr;

    public void SetDataset(SimpleHistogramDataset d) {
      dataset = d;
    }
    public void SetFitDataset(XYSeriesCollection d) {
      fataset = d;
    }
    public void SetPlot(XYPlot p) {
      lifetime_plot = p;
    }
    private class CloseButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        fit.setVisible(false);
      }
    }
    private class FitButtonListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        ((LifetimeFitControls)(((JButton)evt.getSource()).getParent())).DoFit();
      }
    }
    public LifetimeFitControls() {
      GroupLayout layout = new GroupLayout(this);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);
      setLayout(layout);

      two_parameter_fit = new JRadioButton();
      JLabel two_label = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/two_func.gif"))));
      three_parameter_fit = new JRadioButton();
      JLabel three_label = new JLabel(new ImageIcon(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/three_func.gif"))));
      two_parameter_fit.setSelected(true);
      three_parameter_fit.setSelected(true);
      JLabel tmin_label = new JLabel("Fit ragne, t >");
      JLabel ns_label = new JLabel(" ns");
      tmin_text = new JTextField("500");

      ButtonGroup fit_buttons = new ButtonGroup();
      fit_buttons.add(two_parameter_fit);
      fit_buttons.add(three_parameter_fit);

      JButton fit_button = new JButton("Fit");
      fit_button.addActionListener(new FitButtonListener());

      JButton close_button = new JButton("Close");
      close_button.addActionListener(new CloseButtonListener());

      layout.setHorizontalGroup(layout.createSequentialGroup().
        addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
          addGroup(layout.createSequentialGroup().
            addComponent(two_parameter_fit).
            addComponent(two_label)).
          addGroup(layout.createSequentialGroup().
            addComponent(three_parameter_fit).
            addComponent(three_label)).
          addGroup(layout.createSequentialGroup().
            addComponent(tmin_label).
            addComponent(tmin_text,60,60,60).
            addComponent(ns_label)).
          addGroup(layout.createSequentialGroup().
            addComponent(fit_button).
            addComponent(close_button))));
      layout.setVerticalGroup(layout.createParallelGroup().
        addGroup(layout.createSequentialGroup().
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(two_parameter_fit,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(two_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(three_parameter_fit,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(three_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(tmin_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(tmin_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
            addComponent(ns_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
          addGroup(layout.createParallelGroup(GroupLayout.Alignment.CENTER).
            addComponent(fit_button).
            addComponent(close_button))));
    }
    class FCN implements FCNBase {
      SimpleHistogramDataset data;
      int nbin;
      double tmin;
      public FCN(SimpleHistogramDataset h,double t) {
        data = h;
        nbin = data.getItemCount(0);
        tmin = t;
      }
      public double valueOf(double [] par ) {
        double logl = 0;
        for ( int i=0; i<nbin; i++ ) {
          double t = data.getXValue(0,i);
          if ( t > tmin ) {
            double n = data.getYValue(0,i);
            double f = par[0]+par[1]*Math.exp(-t/par[2]);
            if ( f <= 0 ) {
              logl += 100.0;
            }
            else {
              logl -= (n*Math.log(f) - f);
            }
          }
        }
        return 2*logl;
      }
    }

    public double GetTmin() {
      try {
        return Double.parseDouble(tmin_text.getText());
      }
      catch ( Exception e ) {
      }
      return 0;
    }

    public class LifetimeFunction implements Function2D {
      double [] par;
      public LifetimeFunction(double c,double a,double t) { 
        par = new double [3];
        par[0] = c;
        par[1] = a;
        par[2] = t;
      }
      public double getValue(double x) {
        return par[0] + par[1]*Math.exp(-x/par[2]);
      }
    }

    public void DoFit() {

      int npar = 2;
      if ( three_parameter_fit.isSelected() ) npar = 3;
      double tmin = GetTmin();
      
      FCN fcn = new FCN(dataset,tmin);

      MnUserParameters par = new MnUserParameters();
      par.add("c",0,0.1,0,100);
      par.add("a",0.5*dataset.getYValue(0,0),0.1);
      par.add("t",2200.0,0.1);
      if ( npar == 2 ) {
        par.fix(0);
      }
      MnMigrad migrad = new MnMigrad(fcn,par);

      lifetime_plot.clearAnnotations();
      FunctionMinimum min = migrad.minimize();
      Font font = new Font("SansSerif",0,18);

      if ( ! min.isValid() ) {
        XYTextAnnotation oops_label = new XYTextAnnotation("Fit did not converge.",
          lifetime_plot.getDomainAxis().getUpperBound()*0.6,
          lifetime_plot.getRangeAxis().getUpperBound()*0.66);
        oops_label.setFont(font);
        lifetime_plot.addAnnotation(oops_label);
      }
      else {
        fitpar = migrad.params();
        fiterr = migrad.errors();

        fataset.removeAllSeries();
        XYSeries series = DatasetUtilities.sampleFunction2DToSeries(new LifetimeFunction(fitpar[0],fitpar[1],fitpar[2]),tmin,10000,50,"f(x)");
        fataset.addSeries(series);
    
        XYTextAnnotation lifetime_label = new XYTextAnnotation("\u03c4 = "+String.format("%.2f",fitpar[2]*0.001)+" \u00b1 "+String.format("%.2f",fiterr[2]*0.001)+" \u03bcs",
          lifetime_plot.getDomainAxis().getUpperBound()*0.6,
          lifetime_plot.getRangeAxis().getUpperBound()*0.7);
        lifetime_label.setFont(font);
        lifetime_plot.addAnnotation(lifetime_label);

        XYTextAnnotation constant_label = new XYTextAnnotation("A = "+String.format("%.2f",fitpar[1])+" \u00b1 "+String.format("%.2f",fiterr[1])+" /(250 ns)",
          lifetime_plot.getDomainAxis().getUpperBound()*0.6,
          lifetime_plot.getRangeAxis().getUpperBound()*0.66);
        constant_label.setFont(font);
        lifetime_plot.addAnnotation(constant_label);
  
        XYImageAnnotation function_label;
        if ( npar == 2 ) {
          function_label = new XYImageAnnotation(
            lifetime_plot.getDomainAxis().getUpperBound()*0.6,
            lifetime_plot.getRangeAxis().getUpperBound()*0.80,
            Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/two_func.gif")));
  
        }
        else {
          XYTextAnnotation background_label = new XYTextAnnotation("C = "+String.format("%.2f",fitpar[0])+" \u00b1 "+String.format("%.2f",fiterr[0])+" /(250 ns)",
            lifetime_plot.getDomainAxis().getUpperBound()*0.6,
            lifetime_plot.getRangeAxis().getUpperBound()*0.62);
          background_label.setFont(font);
          lifetime_plot.addAnnotation(background_label);
          function_label = new XYImageAnnotation(
            lifetime_plot.getDomainAxis().getUpperBound()*0.6,
            lifetime_plot.getRangeAxis().getUpperBound()*0.80,
            Toolkit.getDefaultToolkit().getImage(getClass().getResource("/images/three_func.gif")));
        }
        lifetime_plot.addAnnotation(function_label);
      }
    }
  }

  private static void createAndShowGUI() {
    frame = new JFrame("CosmicRayDetector");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    String os = System.getProperty("os.name");
    String tty = "";
    if ( os.equals("Linux") ) {
      tty = "/dev/ttyUSB0";
    }
    else if ( os.startsWith("Windows") ) {
      tty = "COM3";
    }
   
    frame.add(new CosmicRayDetector(tty),BorderLayout.CENTER);
    frame.pack();
    frame.setVisible(true);

    Dimension screen_size = Toolkit.getDefaultToolkit().getScreenSize();

    boolean modal = true;
    fit = new JDialog(new JFrame("Lifetime fit"),modal);
    lifetime_fit = new LifetimeFitControls();
    fit.add(lifetime_fit,BorderLayout.CENTER);
    fit.pack();
    fit.setVisible(false);
    Dimension layout_size = fit.getPreferredSize();
    fit.setLocation(screen_size.width/2-layout_size.width/2,
                    screen_size.height/2-layout_size.height/2);

    title = new JDialog(new JFrame("Cosmic Ray Detector Interface"),true);
    SplashScreen splash = new SplashScreen();
    title.add(splash,BorderLayout.CENTER);
    title.pack();
    layout_size = title.getPreferredSize();
    title.setLocation(screen_size.width/2-layout_size.width/2,
                      screen_size.height/2-layout_size.height/2);
    title.setVisible(true);
  }

  public static void main(String[] args) {
    SwingUtilities.invokeLater(new Runnable() {
      public void run() {
        UIManager.put("swing.boldMetal",Boolean.FALSE);
        createAndShowGUI();
      }
    } );
  }
}
