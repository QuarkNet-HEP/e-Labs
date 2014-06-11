//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//	  This file contains code for the Geometry tab
//
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GridLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import javax.swing.ButtonGroup;
import javax.swing.GroupLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JSlider;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;


public class EQUIPGeometry extends JPanel {
	
    double latitude;
    double longitude;
    int zoom;
    EQUIPAirShow air_shower_panel;

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

    public class MapOutputHandler extends EQUIPOutputHandler {
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

    public EQUIPGeometry(EQUIPAirShow a) {
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
      EQUIP.kernel.AddOutputHandler(map_handler);

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

}//end of EQUIPGeometry class