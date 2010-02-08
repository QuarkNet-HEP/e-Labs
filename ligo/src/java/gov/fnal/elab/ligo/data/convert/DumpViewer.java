/*
 * Created on Feb 6, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.prefs.Preferences;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

public class DumpViewer implements Runnable, WindowListener, ActionListener {
    private JFrame frame;
    private JButton load;
    private List<Double> data;
    private Canvas canvas;

    public void run() {
        data = new ArrayList<Double>();
        frame = new JFrame();
        frame.setTitle("Dump Viewer");
        frame.setLayout(new BorderLayout());
        JPanel p = new JPanel();
        frame.add(p, BorderLayout.SOUTH);
        p.setLayout(new FlowLayout());
        load = new JButton("Load...");
        load.addActionListener(this);
        p.add(load);
        canvas = new Canvas();
        frame.add(canvas, BorderLayout.CENTER);
        frame.setSize(640, 400);
        frame.setLocationByPlatform(true);
        frame.setVisible(true);
        frame.addWindowListener(this);

    }

    public void actionPerformed(ActionEvent e) {
        JFileChooser fc = new JFileChooser();
        Preferences pref = Preferences.userNodeForPackage(DumpViewer.class);
        String dir = pref.get("dumpviewer.dir", new File(".").getAbsolutePath());
        fc.setCurrentDirectory(new File(dir));
        fc.showOpenDialog(frame);
        File f = fc.getSelectedFile();
        if (f != null) {
            pref.put("dumpviewer.dir", f.getParent());
            load(f);
        }
    }

    private void load(File f) {
        try {
            String type = (String) JOptionPane.showInputDialog(frame, "Select data type: ", "Data Type Selection",
                JOptionPane.PLAIN_MESSAGE, null, new String[] { "int", "float", "double" }, "double");
            System.out.println("Loading " + f);
            FileInputStream is = new FileInputStream(f);
            try {
                data.clear();
                int index = 0;
                while (true) {
                    if (type.equals("int")) {
                        data.add((double) EncodingTools.readInt(is));
                    }
                    else if (type.equals("float")) {
                        data.add((double) EncodingTools.readFloat(is));
                    }
                    else {
                        data.add(print(EncodingTools.readDouble(is)));
                    }
                }
            }
            catch (EOFException e) {
            }
            finally {
                is.close();
            }
            canvas.repaint();
        }
        catch (IOException e) {
            JOptionPane.showMessageDialog(frame, "I/O Error", e.getMessage(), JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private double print(double v) {
        System.out.println(v);
        return v;
    }

    private class Canvas extends JComponent {
        @Override
        public void paint(Graphics g) {
            Graphics2D g2 = (Graphics2D) g;
            double min = Double.MAX_VALUE;
            double max = -Double.MAX_VALUE;

            for (Double d : data) {
                if (d < min) {
                    min = d;
                }
                if (d > max) {
                    max = d;
                }
            }

            double range = max - min;
            if (range == 0 || data.size() == 0) {
                return;
            }

            double scaley = (getHeight() - 20) / range;
            double scalex = (double) (getWidth() - 10) / (double) Math.max(1, data.size());

            for (int i = 0; i < data.size(); i++) {
                double d = data.get(i);
                g2.drawLine((int) (i * scalex + 10), getHeight() - (int) ((d - min) * scaley) + 10, (int) ((i + 1) * scalex + 10), getHeight() - (int) ((d - min) * scaley) + 10);
            }
            g2.drawString(String.valueOf(max), 10, 10);
            g2.drawString(String.valueOf(min), 10, getHeight());
            
            g2.drawLine(0, getHeight() - 10, getWidth(), getHeight() - 10);
            g2.drawLine(10, 0, 10, getHeight());
        }
    }

    public void windowActivated(WindowEvent e) {
    }

    public void windowClosed(WindowEvent e) {
    }

    public void windowClosing(WindowEvent e) {
        System.exit(0);
    }

    public void windowDeactivated(WindowEvent e) {
    }

    public void windowDeiconified(WindowEvent e) {
    }

    public void windowIconified(WindowEvent e) {
    }

    public void windowOpened(WindowEvent e) {
    }

    public static void main(String[] args) {
        new DumpViewer().run();
    }
}
