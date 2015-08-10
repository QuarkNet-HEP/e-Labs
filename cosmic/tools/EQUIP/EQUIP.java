//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//    Version 2.00 - June, 2012
//       First released during the Summer 2012 Quarnet Workshop
//    Version 2.01 - January, 2013
//       Modified to allow the barometer to work like an
//       altimeter.  This was not entirely successful.
//    Version 2.02 - April, 2014
//		 Compiled a lite version including control panel, performance, flux and geometry
//		 Updated some functionality
//		 Fixed some exceptions
//		 Modified layout
// 	  Version 2.03 - June, 2014
//		 Changed name from CosmicRayDetector to EQUIP
//		 Started factoring code out into meaningful groups

import gnu.io.CommPortIdentifier;

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

public class EQUIP extends JPanel {

  static JFrame frame;
  static JDialog title;
  static JDialog fit;

  static LifetimeFitControls lifetime_fit;

  static EQUIPKernel kernel;
  ControlPanel control_panel;
  EQUIPTOTMonitor totmonitor_panel;
  static EQUIPRateMonitor ratemonitor_panel;
  EQUIPAirShow air_shower_panel;
  EQUIPGeometry map_panel;
  EQUIPMuonLifetime lifetime_panel;
  EQUIPRates rates_panel;
  String default_port;
  static PressureFixer pfix;
  static String STChoice;
  static Color[] series_color = {Color.RED, Color.GREEN, Color.BLUE, Color.CYAN};
  
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

  public class AllOutputHandler extends EQUIPOutputHandler {
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
      int len = pane.getDocument().getLength();
      pane.setCaretPosition(len);
    }
  }

  public class SerialNumberOutputHandler extends EQUIPOutputHandler {
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

  public class GpsStatusOutputHandler extends EQUIPOutputHandler {
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
  public class GpsSatsOutputHandler extends EQUIPOutputHandler {
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
  public class TemperatureOutputHandler extends EQUIPOutputHandler {
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
  public class PressureOutputHandler extends EQUIPOutputHandler {
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
  public class DacOutputHandler extends EQUIPOutputHandler {
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

  public class GpsTimeOutputHandler extends EQUIPOutputHandler {
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
  public class LatitudeOutputHandler extends EQUIPOutputHandler {
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

  public class LongitudeOutputHandler extends EQUIPOutputHandler {
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

  public class AltitudeOutputHandler extends EQUIPOutputHandler {
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
  public class PulserVoltageOutputHandler extends EQUIPOutputHandler {
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

  public class ScalerOutputHandler extends EQUIPOutputHandler {
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

  public class ControlRegOutputHandler extends EQUIPOutputHandler {
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

  public class StatusControl extends JPanel {
    JTextField time_interval;
    JComboBox status_choice;
    boolean updating;
    public class StatusOutputHandler extends EQUIPOutputHandler {
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
        //EPeronja-05/8/2014: we need this for the the flux panel calculations (See CosmicRayDetectorFluxPanel.java
        //					  if command is ST 2, we need to subtact previous count
        // 					  if command is ST 3, we don't 
        STChoice = String.valueOf(choice);
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
      time_interval.setText("0");

      StatusControlListener status_listener = new StatusControlListener();
      time_interval.addActionListener(status_listener);

      String [] status_strings = { "Disabled(ST 0 x)", "Enabled(ST 1 x)", "With scalers(ST 2 x)", "Reset scalers(ST 3 x)" };
      status_choice = new JComboBox(status_strings);
      status_choice.setSelectedIndex(0);
      status_choice.addActionListener(status_listener);

      JLabel min_label = new JLabel(" min");

      StatusOutputHandler status_handler = new StatusOutputHandler();
      kernel.AddOutputHandler(status_handler);

      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addComponent(status_label).
          addComponent(status_choice,200,200,200).
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

  public class TimingRegOutputHandler extends EQUIPOutputHandler {
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

  public class PulserOffOutputHandler extends EQUIPOutputHandler {
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

  public class PulserResetOutputHandler extends EQUIPOutputHandler {
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

  public class ThresholdOutputHandler extends EQUIPOutputHandler {
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
                //thr = 0.1*Double.parseDouble(counts[i].substring(j+1));
                thr = Double.parseDouble(counts[i].substring(j+1));
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

  public class ControlPanel extends JPanel {
    JTextField command;
    //JTextField port_text;
    JComboBox port_text;
    JTextField log_text;
    JTextField thr_text [];
    JPanel panelparent = this;

    private class DiscThresholdListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        JTextField field = (JTextField)evt.getSource();
        int ichan = 0;
        while ( field != thr_text[ichan] ) {
          ichan += 1;
        }
        try {
          //int data = (int)(Double.parseDouble(evt.getActionCommand())*10);
          int data = (int)(Double.parseDouble(evt.getActionCommand()));
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
      //layout.setAutoCreateGaps(true);
      //layout.setAutoCreateContainerGaps(true);
      JLabel port_label = new JLabel("Serial port:");
      //EP - Ports
      //port_text = new JTextField(default_port);
      //OpenPortListener port_listener = new OpenPortListener();
      //port_text.addActionListener(port_listener);
      port_text = new JComboBox();
      port_text.setEditable(true);
      port_text.setModel(new javax.swing.DefaultComboBoxModel(EQUIPTools.getAvailableSerialPorts().toArray()));
	  port_text.setSelectedIndex(-1);
	  port_text.addItemListener(new ItemListener(){
	      public void itemStateChanged(ItemEvent e){
	          default_port = (String)((JComboBox)e.getSource()).getSelectedItem();
	      }
	  });
	  OpenPortListener port_listener = new OpenPortListener();
      port_text.addActionListener(port_listener);
      //EP - added SA 1 command
      JButton save_label = new JButton("Capture Configuration(SA 1)");
      save_label.setName("SA 1");
      save_label.setForeground(Color.RED);
      Font save_font = new Font("Serif", Font.BOLD, 14);
      save_label.setFont(save_font);
      EQUIPTools.SaveButtonListener save_listener = new EQUIPTools.SaveButtonListener();
      save_label.addActionListener(save_listener);      
      
      JLabel log_label = new JLabel("Log file:");
      Calendar now = Calendar.getInstance();

      String dir = System.getProperty("user.dir");
      File dataCollection = new File("data");
      if (!dataCollection.exists()) {
    	  dataCollection.mkdir();
      }
      String log_file = String.format("data/EQUIP_%d%s%d_%02d%02d%02d.txt",now.get(Calendar.DATE),EQUIPTools.getMonthName(now.get(Calendar.MONTH)),now.get(Calendar.YEAR),now.get(Calendar.HOUR_OF_DAY),now.get(Calendar.MINUTE),now.get(Calendar.SECOND));
      log_text = new JTextField(log_file);
      OpenLogListener log_listener = new OpenLogListener();
      log_text.addActionListener(log_listener);
      JButton save_log_as = new JButton("Choose File");
      SaveLogListener sll_listener = new SaveLogListener();
      save_log_as.addActionListener(sll_listener);
      
      JPanel sn_panel = new JPanel();
      GroupLayout sn_layout = new GroupLayout(sn_panel);
      sn_panel.setLayout(sn_layout);
      sn_layout.setAutoCreateGaps(true);
      sn_layout.setAutoCreateContainerGaps(true);
      JButton sn_label = new JButton("S/N:");
      sn_label.setName("SN");
      EQUIPTools.SimpleButtonListener sn_listener = new EQUIPTools.SimpleButtonListener();
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
      //help_layout.setAutoCreateGaps(true);
      //help_layout.setAutoCreateContainerGaps(true);
      JLabel help_label = new JLabel();
      help_label.setText("Help:");
  
      JButton h1_label = new JButton("Page 1(H1)");
      h1_label.setName("H1");
      EQUIPTools.SimpleButtonListener help_listener = new EQUIPTools.SimpleButtonListener();
      h1_label.addActionListener(help_listener);
  
      JButton h2_label = new JButton("Page 2(H2)");
      h2_label.setName("H2");
      h2_label.addActionListener(help_listener);
  
      JButton hb_label = new JButton("Barometer(HB)");
      hb_label.setName("HB");
      hb_label.addActionListener(help_listener);
  
      JButton hs_label = new JButton("Status(HS)");
      hs_label.setName("HS");
      hs_label.addActionListener(help_listener);
  
      JButton ht_label = new JButton("Trigger(HT)");
      ht_label.setName("HT");
      ht_label.addActionListener(help_listener);

      JButton v1_label = new JButton("Setup(V1)");
      v1_label.setName("V1");
      v1_label.addActionListener(help_listener);
  
      JButton v2_label = new JButton("Voltages(V2)");
      v2_label.setName("V2");
      v2_label.addActionListener(help_listener);

      JButton v3_label = new JButton("GPS Lock(V3)");
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
      //EP-made changes to the size of components
      gps_layout.setHorizontalGroup(
        gps_layout.createParallelGroup().
          addGroup(gps_layout.createSequentialGroup().
          addComponent(gps_status_label).
          addComponent(gps_status_text,65,65,65).
          addComponent(gps_sats_label).
          addComponent(gps_sats_text,30,30,30).
          addComponent(temp_label).
          addComponent(temp_text,100,100,100).
          addComponent(pressure_label).
          addComponent(pressure_text,60,60,60).
          addComponent(dac_label).
          addComponent(dac_text,60,60,60)).
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
      JButton sca_label = new JButton("Scalers(DS):");
      sca_label.setName("DS");
      EQUIPTools.SimpleButtonListener ds_listener = new EQUIPTools.SimpleButtonListener();
      sca_label.addActionListener(ds_listener);
  
      JButton sca_reset = new JButton("Reset scalers(RB)");
      ResetScalerListener sca_reset_listener = new ResetScalerListener();
      sca_reset.addActionListener(sca_reset_listener);

      JButton board_reset = new JButton("Reset board(RE)");
      board_reset.setName("RE");
      board_reset.addActionListener(ds_listener);
  
      UpdateButtonListener update_listener = new UpdateButtonListener();
      JButton update_button = new JButton("Update");
      update_button.addActionListener(update_listener);

      JButton gps_button = new JButton("GPS(DG)");
      gps_button.setName("DG");
      EQUIPTools.SimpleButtonListener gps_listener = new EQUIPTools.SimpleButtonListener();
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

      JButton cr_label = new JButton("Control registers(DC):");
      cr_label.setName("DC");
      EQUIPTools.SimpleButtonListener dc_listener = new EQUIPTools.SimpleButtonListener();
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
      JButton tr_label = new JButton("Timing registers(DT):");
      tr_label.setName("DT");
      EQUIPTools.SimpleButtonListener dt_listener = new EQUIPTools.SimpleButtonListener();
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


      EQUIPTools.CoincidenceControls coinc_panel = new EQUIPTools.CoincidenceControls();
      EQUIPTools.GateWidthControl gate_control = new EQUIPTools.GateWidthControl();
      EQUIPTools.PipelineDelayControl pipeline_control = new EQUIPTools.PipelineDelayControl();
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
      JButton thr_label = new JButton("Threshold(TL):");
      thr_label.setName("TL");
      EQUIPTools.SimpleButtonListener tl_listener = new EQUIPTools.SimpleButtonListener();
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

      EQUIPTools.CounterEnableDisableControls cecd_panel = new EQUIPTools.CounterEnableDisableControls();
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
      EQUIPTools.SimpleButtonListener pulser_listener = new EQUIPTools.SimpleButtonListener();
      JButton pulser_off_button = new JButton("Off(TE 0)");
      pulser_off_button.setName("TE 0");
      pulser_off_button.addActionListener(pulser_listener);
      PulserOffOutputHandler pulser_off_handler = new PulserOffOutputHandler(pulser_off_button);
      kernel.AddOutputHandler(pulser_off_handler);

      JButton pulser_once_button = new JButton("Once(TE 1)");
      pulser_once_button.setName("TE 1");
      pulser_once_button.addActionListener(pulser_listener);
      JButton pulser_cont_button = new JButton("Continuous(TE 2)");
      pulser_cont_button.setName("TE 2");
      pulser_cont_button.addActionListener(pulser_listener);
  
      JButton pulser_reset_button = new JButton("Reset(TD 0)");
      pulser_reset_button.setName("TD 0");
      pulser_reset_button.addActionListener(pulser_listener);
      PulserResetOutputHandler pulser_reset_handler = new PulserResetOutputHandler(pulser_reset_button);
      kernel.AddOutputHandler(pulser_reset_handler);
      JButton pulser_singles_button = new JButton("Singles(TD 1)");
      pulser_singles_button.setName("TD 1");
      pulser_singles_button.addActionListener(pulser_listener);
      JButton pulser_majority_button = new JButton("Majority(TD 2)");
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
      command.addKeyListener(new KeyAdapter() {
    	  public void keyTyped(KeyEvent e) {
    		  char keyChar = e.getKeyChar();
    		  if (Character.isLowerCase(keyChar)) {
    			  e.setKeyChar(Character.toUpperCase(keyChar));
    		  }
    	  }
      });
      JTextArea output = new JTextArea();
      output.setLineWrap(false);
      output.setEditable(false);
      //output.setSize(600, 700);
      output.setFont(new Font("monospaced",Font.PLAIN,10));
      AllOutputHandler output_handler = new AllOutputHandler(output);
      kernel.AddOutputHandler(output_handler);

      pfix = new PressureFixer();

      JScrollPane output_scroll = new JScrollPane(output,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS); 
 
      
      //EP
      layout.setHorizontalGroup(
        layout.createSequentialGroup().
          addGroup(layout.createParallelGroup().
            addGroup(layout.createSequentialGroup().
              addComponent(log_label,100,100,100).
              addComponent(log_text,400,400,400).
              addComponent(save_log_as)).
            addGroup(layout.createSequentialGroup().
              addComponent(port_label,100,100,100).
              addComponent(port_text,250,250,250)).
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
            //addComponent(pulser_panel).
            addGroup(layout.createSequentialGroup().
              addComponent(cmd_label).
              addComponent(command,250,250,250).
              addComponent(save_label))).
          addComponent(output_scroll,600,600,600)); 
      //EP
      layout.setVerticalGroup(
        layout.createParallelGroup().
          addGroup(layout.createSequentialGroup().
            addGroup(layout.createParallelGroup().
              addComponent(log_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(log_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(save_log_as)).
            addGroup(layout.createParallelGroup().
              addComponent(port_label,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(port_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
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
            //addComponent(pulser_panel).
            addGroup(layout.createParallelGroup().
              addComponent(cmd_label).
              addComponent(command,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE).
              addComponent(save_label))).
              addComponent(output_scroll,700,700,700));
              

    }
    private class OpenPortListener implements ActionListener {
      public void actionPerformed(ActionEvent evt) {
        try {
        	//EP - ports
            try {
              kernel.OpenLogFile(log_text.getText());
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(frame,"Error opening output file '"+log_text.getText()+"'","Port error",JOptionPane.ERROR_MESSAGE);
            }
        	kernel.connect(port_text.getSelectedItem().toString());
	        try {
	            kernel.sendCommand("H1");
	            kernel.sendCommand("DG");
	            kernel.sendCommand("DC");
	            kernel.sendCommand("DT");
	            kernel.sendCommand("DS");
	            kernel.sendCommand("TL");
	            kernel.sendCommand("TI");
	            kernel.sendCommand("BA");
	            kernel.sendCommand("SN");
	            kernel.sendCommand("V1");
	            kernel.sendCommand("V2");
	            kernel.sendCommand("V3");
	            kernel.sendCommand("ST 3 5");
	            kernel.sendCommand("ST");
	            kernel.sendCommand("CE");
	            
	         }
	         catch ( Exception e1 ) {
	            JOptionPane.showMessageDialog(frame,
	              "Error writing to serial port.",
	              "Serial port error",JOptionPane.WARNING_MESSAGE);
	         }
	    }
        catch ( Exception e2 ) {
          String port_name = port_text.getSelectedItem().toString();
          //EP - ports
          //String port_name = port_text.getText();
          JOptionPane.showMessageDialog(frame,"Error opening port '"+port_name+"'","Port error",JOptionPane.ERROR_MESSAGE);
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
    private class SaveLogListener implements ActionListener {
    	public void actionPerformed(ActionEvent evt) {
    		if (!kernel.isConnected()) {
	    		try {
	    			String old_file_name = log_text.getText();
	    			JFileChooser saveFile = new JFileChooser();
	    			int result = saveFile.showSaveDialog(panelparent);
	    			if (result == JFileChooser.APPROVE_OPTION) {
	    				String file_name = saveFile.getSelectedFile().getAbsolutePath();
	    				log_text.setText(file_name);
	    			}
	    		} catch (Exception ex) {
	    	          JOptionPane.showMessageDialog(frame,"Unable to save","Save error",JOptionPane.ERROR_MESSAGE);    			
	    		}
    		} else {
  	          JOptionPane.showMessageDialog(frame,"Unable to switch files once the detector is connected","Switch error",JOptionPane.ERROR_MESSAGE);    			    			
    		}
    	}
    }//end of SaveLogAsListener
    
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
	        try {
	        	//send default commands as soon as we connect to the board
	        	kernel.sendCommand("H1");
	            kernel.sendCommand("DG");
	            kernel.sendCommand("DC");
	            kernel.sendCommand("DT");
	            kernel.sendCommand("DS");
	            kernel.sendCommand("TL");
	            kernel.sendCommand("TI");
	            kernel.sendCommand("BA");
	            kernel.sendCommand("SN");
	            kernel.sendCommand("V1");
	            kernel.sendCommand("V2");
	            kernel.sendCommand("V3");
	            kernel.sendCommand("ST 3 5");
	            kernel.sendCommand("ST");
	            kernel.sendCommand("CE");
	        }
	        catch ( Exception e ) {
	          JOptionPane.showMessageDialog(frame,
	            "Error writing to serial port.",
	            "Serial port error",JOptionPane.WARNING_MESSAGE);
	        }
    	} catch (Exception e2) {
    		
    	}
      }
    }
  }


  public EQUIP(String port) {
    super(new GridLayout(1,1));

    default_port = port;
    //default_port = "/dev/tty.SLAB_USBtoUART";
    kernel = new EQUIPKernel(frame);

    JTabbedPane tabbedPane = new JTabbedPane();
    ImageIcon icon = null;

    control_panel = new ControlPanel();

    tabbedPane.addTab("Control Panel",icon,control_panel,"Low-level controls of cosmic ray detector electronics");
    tabbedPane.setMnemonicAt(0,KeyEvent.VK_1);
    
    rates_panel = new EQUIPRates();
//    tabbedPane.addTab("Rates",icon,rates_panel,"Graphs count rates");
//    tabbedPane.setMnemonicAt(1,KeyEvent.VK_2);

    totmonitor_panel = new EQUIPTOTMonitor();
    tabbedPane.addTab("TOT Monitor",icon,totmonitor_panel,"Histograms of time-over-threshold");
    tabbedPane.setMnemonicAt(1,KeyEvent.VK_2);

    ratemonitor_panel = new EQUIPRateMonitor();
    tabbedPane.addTab("Rate Monitor",icon,ratemonitor_panel,"Graphs count rates as functions of time");
    tabbedPane.setMnemonicAt(2,KeyEvent.VK_3);

    air_shower_panel = new EQUIPAirShow();
    tabbedPane.addTab("Shower Monitor",icon,air_shower_panel,"Air shower analysis");
    tabbedPane.setMnemonicAt(3,KeyEvent.VK_4);

    //lifetime_panel = new EQUIPMuonLifetime();
    //tabbedPane.addTab("Muon Lifetime Monitor",icon,lifetime_panel,"Muon lifetime analysis");
    //tabbedPane.setMnemonicAt(4,KeyEvent.VK_5);

    map_panel = new EQUIPGeometry(air_shower_panel);
    tabbedPane.addTab("Geometry",icon,map_panel,"Enter geometry data");
    tabbedPane.setMnemonicAt(4,KeyEvent.VK_5);

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
    java.net.URL imgURL = EQUIP.class.getResource(path);
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
    frame = new JFrame("EQUIP - e-Lab Qn User Interface Purdue");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    String os = System.getProperty("os.name");
    String tty = "";
    if ( os.equals("Linux") ) {
      tty = "/dev/ttyUSB0";
    }
    else if ( os.startsWith("Windows") ) {
      tty = "COM3";
    }
   
    frame.add(new EQUIP(tty),BorderLayout.CENTER);
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

    //EP-Added this next line to get the app to fill the screen
    frame.setSize(screen_size);
    title = new JDialog(new JFrame("EQUIP - e-Lab Qn User Interface"),true);
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
