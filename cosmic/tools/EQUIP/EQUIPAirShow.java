//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the AirShow tab
//

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.text.FieldPosition;
import java.text.NumberFormat;
import java.text.ParsePosition;

import javax.swing.BorderFactory;
import javax.swing.GroupLayout;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.JTextArea;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

public class EQUIPAirShow extends JPanel {
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

    public class AirShowerOutputHandler extends EQUIPOutputHandler {
      long t0;
      EQUIPPulse [] pulse;
      public AirShowerOutputHandler() {
        pulse = new EQUIPPulse [4];
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
                pulse[j] = new EQUIPPulse(j);
                pulse[j].SetRisingEdge(t,re[j]);
              }
            }
            output.append(s);
          }
        }
      }
    }

    public EQUIPAirShow() {
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
      EQUIP.kernel.AddOutputHandler(trig_handler);

      EQUIPTools.CounterEnableDisableControls cecd_controls = new EQUIPTools.CounterEnableDisableControls(); 
      EQUIPTools.CoincidenceControls trigger_panel = new EQUIPTools.CoincidenceControls();
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
