//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the TOTMonitor tab
//
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.Color;
import java.util.Calendar;
import java.util.Random;
import java.io.*;
import java.io.FileWriter;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.StandardChartTheme;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.axis.NumberTickUnit;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.SeriesRenderingOrder;
import org.jfree.chart.plot.XYPlot;
import org.jfree.data.statistics.SimpleHistogramBin;
import org.jfree.data.statistics.SimpleHistogramDataset;
import org.jfree.chart.renderer.xy.XYItemRenderer;

public class EQUIPTOTMonitor extends JPanel {
    JFreeChart [] chart;
    ChartPanel [] chart_panel;
    SimpleHistogramDataset [] dataset;
    int [] unpaired_rising_edge;
    int [] unpaired_falling_edge;
    EQUIPPulse [] pulse;
    Random rnd;
    //EP - changes to the scale
    int nbin = 80;
    double bwid = 10.0;
    int nana;
    int na, nv;
    int ure, ufe;
    int snu, src;
    double column_width = 1.25;
    long [] scalers;
    double fa;
    JTextField gps_valid_text;
    JTextField ure_text;
    JTextField ufe_text;
    JTextField snu_text;
    JTextField src_text;
    JTextField nana_text;
    JTextField bin_width_text;

    public class TriggerOutputHandler extends EQUIPOutputHandler {
      JPanel panel;
      Calendar now = Calendar.getInstance();
      String output_file = String.format("data/Performance_%d-%d-%d_%02d%02d%02d.txt",now.get(Calendar.MONTH)+1,now.get(Calendar.DATE),now.get(Calendar.YEAR),now.get(Calendar.HOUR_OF_DAY),now.get(Calendar.MINUTE),now.get(Calendar.SECOND));
      File output = new File(output_file);

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
    	  //BufferedWriter bw = null;
       	  //try {
    	  //	  bw = new BufferedWriter(new FileWriter(output, true));
       	  //} catch (Exception ioex) {}
    	  if ( s.length() == 74 ) {
    	  //try {
    	  //	  bw.append(s+"\n");
       	  //} catch (Exception ioex) {
       		  
       	  //}
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
          	  //try {
              //  bw.append("na:" + String.valueOf(na) + " nv:" + String.valueOf(nv) + " gps_valid_text (na/(nv+na)*100):"+String.valueOf(fa*100));
              //  bw.newLine();
           	  //} catch (Exception ioex) {}
              }
            }
            int i = 0;
            long t = Long.parseLong(tokens[i++],16);
            int [] re = new int [4];
            int [] fe = new int [4];
            for ( int j=0; j<4; j++ ) {
              re[j] = Integer.parseInt(tokens[i++],16);
              fe[j] = Integer.parseInt(tokens[i++],16);
              //try {
              //	  bw.append("Rising Edge "+String.valueOf(j)+":" +String.valueOf(re[j]));
            	//  bw.newLine();
            	//  bw.append("Falling Edge "+String.valueOf(j)+":" +String.valueOf(fe[j]));
            	//  bw.newLine();
           	  //} catch (Exception ioex) {}
              
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
                pulse[j] = new EQUIPPulse(j);
              }
              if ( (fe[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetFallingEdge(t,fe[j]);
                //try {
              	//  bw.append("Setting Falling Edge "+String.valueOf(j)+" counter:" +String.valueOf(t) +"-time:" +String.valueOf(fe[j]));
              	//  bw.newLine();
             	//  } catch (Exception ioex) {}

                //System.out.println("bucket: "+String.valueOf(j));
          	  //try {
            	//bw.append("Pulse RE-FE: "+pulse[j].DumpREFE());
                //bw.newLine();
            	//bw.append("Pulse valid?: " +String.valueOf(pulse[j].Valid()));
                //bw.newLine();
                //bw.append("TimeOverThreshold:"+String.valueOf(pulse[j].TimeOverThreshold()));
                //bw.newLine();
                //bw.append("TimeOverThresholdCalculation:" +pulse[j].DumpThresholdValues());
                //bw.newLine();
           	  //} catch (Exception ioex) {
           		//
           	  //}
            	if ( pulse[j].Valid() ) {
                  double dt = pulse[j].TimeOverThreshold();                  
                  //try {
                    dataset[j].addObservation(dt);
    	         //   for (int x=0; x < dataset[j].getItemCount(0); x++) {
    	        //        try {
    	          //    	  bw.append("Channel "+String.valueOf(j)+" Series: "+String.valueOf(x)+" count:" );
    	          //    	  bw.newLine();
    	          //   	  } catch (Exception ioex) {}
    	          //    }
                  //  bw.newLine();
                 // }
                 // catch ( Exception e ) {
                 // }
                  pulse[j] = new EQUIPPulse(j);
                }
              }
              if ( (re[j]&0x20) != 0 ) {
                if ( pulse[j] == null ) {
                  System.out.println("pulses["+Integer.toString(j)+"] is null");
                }
                pulse[j].SetRisingEdge(t,re[j]);
                //try {
               //	  bw.append("Setting Rising Edge "+String.valueOf(j)+" counter:" +String.valueOf(t) +"-time:" +String.valueOf(re[j]));
               // 	  bw.newLine();
               //	  } catch (Exception ioex) {}

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
//    	  if (bw != null) {
//    		  try {
//    			  bw.close();
//    		  } catch (Exception ioex) {}
//    	  }
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
        bin_width_text.setText(String.valueOf(column_width));
        createNewDataset();
      }
    }
    
    public void createNewDataset() {
        nbin = (int) (100 / column_width);
        for ( int i=0; i<4; i++ ) {
            dataset[i] = new SimpleHistogramDataset("Ch"+Integer.toString(i+1));
            for ( int j=0; j<nbin; j++ ) {
              //EP - changes to the x axis
            	dataset[i].addBin(new SimpleHistogramBin(column_width*j,column_width*(j+1), true, false));
            }
            dataset[i].setAdjustForBinSize(false);
            XYPlot xyplot = (XYPlot) chart[i].getPlot();
            xyplot.setDataset(dataset[i]);
        }
    }
    
    public EQUIPTOTMonitor() {
      setPreferredSize(new Dimension(1000,800));
      GroupLayout layout = new GroupLayout(this);
      setLayout(layout);
      layout.setAutoCreateGaps(true);
      layout.setAutoCreateContainerGaps(true);

      unpaired_rising_edge = new int [4];
      unpaired_falling_edge = new int [4];
      pulse = new EQUIPPulse[4];
      for ( int i=0; i<4; i++ ) {
        unpaired_rising_edge[i] = 0;
        unpaired_falling_edge[i] = 0;
      }

      TriggerOutputHandler trig_handler = new TriggerOutputHandler(this);
      EQUIP.kernel.AddOutputHandler(trig_handler);

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
      JLabel bin_width_label = new JLabel("Bin width: ");
      bin_width_text = new JTextField(String.valueOf(column_width));
      bin_width_text.setEditable(true);
      bin_width_text.addActionListener(new ActionListener(){
	      public void actionPerformed(ActionEvent e){
	    	  column_width = Double.valueOf(e.getActionCommand());
	    	  createNewDataset();
	      }
	  }); 
      dataset = new SimpleHistogramDataset[4];
      chart = new JFreeChart[4];
      chart_panel = new ChartPanel[4];
      double values [] = { };
      for ( int i=0; i<4; i++ ) {
        dataset[i] = new SimpleHistogramDataset("Ch"+Integer.toString(i+1));
        for ( int j=0; j<nbin; j++ ) {
          //EP - changes to the x axis
        	dataset[i].addBin(new SimpleHistogramBin(column_width*j,column_width*(j+1), true, false));
        }
        dataset[i].setAdjustForBinSize(false);
        chart[i] = ChartFactory.createHistogram("Channel "+Integer.toString(i+1),
          "Time over threshold (ns)","Counts",dataset[i],
          PlotOrientation.VERTICAL,false,false,false);
        chart_panel[i] = new ChartPanel(chart[i]);
        chart_panel[i].setMouseZoomable(false);
        XYPlot xyplot = (XYPlot)chart[i].getPlot();
        NumberAxis axis = (NumberAxis)xyplot.getRangeAxis();
        axis.setAutoRangeMinimumSize(2,false);
        axis.setAutoRangeIncludesZero(true);   
		NumberAxis domain = (NumberAxis)xyplot.getDomainAxis();
        domain.setTickUnit(new NumberTickUnit(bwid));
        domain.setUpperBound(100);
      }

      for (int x=0; x < 4; x++) {
	      XYPlot xyplot = (XYPlot)chart[x].getPlot();
	      XYItemRenderer renderer = xyplot.getRenderer();
	      renderer.setSeriesPaint(0, EQUIP.series_color[x]);  
	      xyplot.setRenderer(renderer);
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
            addGroup(layout.createSequentialGroup().
              addComponent(bin_width_label).
              addComponent(bin_width_text)).
            addComponent(clear_button)).
          addGroup(layout.createParallelGroup().
            addComponent(chart_panel[0],800,800,800).
            addComponent(chart_panel[1],800,800,800).
            addComponent(chart_panel[2],800,800,800).
            addComponent(chart_panel[3],800,800,800)));
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
            addGroup(layout.createParallelGroup().
              addComponent(bin_width_label).
              addComponent(bin_width_text,GroupLayout.PREFERRED_SIZE,GroupLayout.DEFAULT_SIZE,GroupLayout.PREFERRED_SIZE)).
            addComponent(clear_button)).
          addGroup(layout.createSequentialGroup().
            addComponent(chart_panel[0],170,170,170).
            addComponent(chart_panel[1],170,170,170).
            addComponent(chart_panel[2],170,170,170).
            addComponent(chart_panel[3],170,170,170)));
    }
 
}