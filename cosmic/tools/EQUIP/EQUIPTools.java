//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains helper functions
//

import gnu.io.CommPortIdentifier;
import gnu.io.CommPort;
import gnu.io.SerialPort;

import java.awt.Color;
import java.awt.ComponentOrientation;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.util.*;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class EQUIPTools {
	
	public static List<String> getAvailableSerialPorts() {
		List<String> serialPorts = new ArrayList();
	    Enumeration pList = CommPortIdentifier.getPortIdentifiers();
	    while (pList.hasMoreElements()) {
	      CommPortIdentifier cpi = (CommPortIdentifier)pList.nextElement();
	      if (cpi.getPortType() == CommPortIdentifier.PORT_SERIAL) {
	    	  serialPorts.add(cpi.getName());
	      }
	    }	
		return serialPorts;
	}
	
    public static String getMonthName(int month){
        String[] monthNames = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
        return monthNames[month];
    }
    
    public static class SaveButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent evt) {
          JButton field = (JButton)evt.getSource();
          try {
            EQUIP.kernel.sendCommand(field.getName());
          }
          catch ( Exception e ) {
            JOptionPane.showMessageDialog(EQUIP.frame,
              "Error writing to serial port.",
              "Serial port error",JOptionPane.WARNING_MESSAGE);
          }
        }
    }

    public static class SimpleButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent evt) {
          JButton field = (JButton)evt.getSource();
          try {
            EQUIP.kernel.sendCommand(field.getName());
          }
          catch ( Exception e ) {
            JOptionPane.showMessageDialog(EQUIP.frame,
              "Error writing to serial port.",
              "Serial port error",JOptionPane.WARNING_MESSAGE);
          }
        }
    }
    
    public static class TmcEnableOutputHandler extends EQUIPOutputHandler {
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
//            button.setBackground(Color.green);
          }
        }
      }
      public static class TmcDisableOutputHandler extends EQUIPOutputHandler {
        JButton button;
        Color oldcolor;
        public TmcDisableOutputHandler(JButton b) {
          button = b;
          oldcolor = button.getBackground();
        }
        final void Process(String s) {
          if ( s.startsWith("CE") ) {
//            button.setBackground(Color.red);
          }
          else if ( s.startsWith("CD") && ! s.startsWith("CD     - ") ||
                    s.startsWith("RB") && ! s.startsWith("RB     - ") ) {
//            button.setBackground(oldcolor);
          }
        }
      }    
    public static class CounterEnableDisableControls extends JPanel {
        public CounterEnableDisableControls() {
          GroupLayout cecd_layout = new GroupLayout(this);
          setLayout(cecd_layout);
          cecd_layout.setAutoCreateGaps(true);
          cecd_layout.setAutoCreateContainerGaps(true);
          JLabel cecd_label = new JLabel();
          cecd_label.setText("Data output:");
          SimpleButtonListener cecd_listener = new SimpleButtonListener();
          JButton ce_button = new JButton("Enable(CE)");
          ce_button.setName("CE");
          TmcEnableOutputHandler ce_handler = new TmcEnableOutputHandler(ce_button);
          EQUIP.kernel.AddOutputHandler(ce_handler);
          ce_button.addActionListener(cecd_listener);
          JButton cd_button = new JButton("Disable(CD)");
          cd_button.setName("CD");
          cd_button.addActionListener(cecd_listener);
          TmcDisableOutputHandler cd_handler = new TmcDisableOutputHandler(cd_button);
          EQUIP.kernel.AddOutputHandler(cd_handler);

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
    
    public static class CoincidenceControls extends JPanel {
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
            EQUIP.ratemonitor_panel.update_coincidence(String.valueOf(level));
            value |= ((level-1)<<4);
            try {
            	EQUIP.kernel.sendCommand("WC 0 "+Integer.toHexString(value));
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(EQUIP.frame,
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
            EQUIP.ratemonitor_panel.update_coincidence(String.valueOf(level));
            value |= ((level-1)<<4);
            try {
            	EQUIP.kernel.sendCommand("WC 0 "+Integer.toHexString(value));
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(EQUIP.frame,
                "Error writing to serial port.",
                "Serial port error",JOptionPane.WARNING_MESSAGE);
            }  
          }
        }
        public class CoincidenceChannelOutputHandler extends EQUIPOutputHandler {
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
                      EQUIP.ratemonitor_panel.update_coincidence(String.valueOf(next));
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
//          coinc_layout.setAutoCreateGaps(true);
//          coinc_layout.setAutoCreateContainerGaps(true);
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
          EQUIP.kernel.AddOutputHandler(coinc_chan_handler);

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
    
    public static class GateWidthControl extends JPanel {
        public class GateWidthOutputHandler extends EQUIPOutputHandler {
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
            	EQUIP.kernel.sendCommand("WC 3 "+Integer.toHexString(data>>8));
            	EQUIP.kernel.sendCommand("WC 2 "+Integer.toHexString(data&0xff));
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(EQUIP.frame,"Error writing to serial port.",
                                        "Serial port error",
                                        JOptionPane.WARNING_MESSAGE);
            }
          }
        }
        public GateWidthControl() {
          GroupLayout gate_layout = new GroupLayout(this);
          setLayout(gate_layout);
          //gate_layout.setAutoCreateGaps(true);
          //gate_layout.setAutoCreateContainerGaps(true);

          JLabel gate_label = new JLabel("  Gate width:");
          JTextField gate_text = new JTextField();
          gate_text.setEditable(true);
          gate_text.setHorizontalAlignment(JTextField.RIGHT);
          GateWidthListener gate_width_listener = new GateWidthListener();
          gate_text.addActionListener(gate_width_listener);
          GateWidthOutputHandler gate_width_handler = new GateWidthOutputHandler(gate_text);
          EQUIP.kernel.AddOutputHandler(gate_width_handler);
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
    public static class PipelineDelayControl extends JPanel {
        public class PipelineDelayOutputHandler extends EQUIPOutputHandler {
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
                    EQUIP.kernel.sendCommand("DT");
                  }
                  catch ( Exception e2 ) {
                    JOptionPane.showMessageDialog(EQUIP.frame,
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
            	EQUIP.kernel.sendCommand("CD");
            	EQUIP.kernel.sendCommand("WT 1 0");
            	EQUIP.kernel.sendCommand("WT 2 "+Integer.toHexString(data));
            }
            catch ( Exception e ) {
              JOptionPane.showMessageDialog(EQUIP.frame,
                "Error writing to serial port.",
                "Serial port error",JOptionPane.WARNING_MESSAGE);

            }
          }
        }
      
        public PipelineDelayControl() {
          GroupLayout pipeline_layout = new GroupLayout(this);
          setLayout(pipeline_layout);
          //pipeline_layout.setAutoCreateGaps(true);
          //pipeline_layout.setAutoCreateContainerGaps(true);

          JLabel delay_label = new JLabel("  Pipeline delay:");
          JTextField delay_text = new JTextField();
          delay_text.setEditable(true);
          delay_text.setHorizontalAlignment(JTextField.RIGHT);
          PipelineDelayListener delay_listener = new PipelineDelayListener();
          delay_text.addActionListener(delay_listener);
          PipelineDelayOutputHandler delay_handler = new PipelineDelayOutputHandler(delay_text);
          EQUIP.kernel.AddOutputHandler(delay_handler);
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

}