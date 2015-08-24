import javax.swing.JButton;
import java.io.IOException;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.event.HyperlinkListener;
import javax.swing.event.HyperlinkEvent;
import javax.swing.ImageIcon;
import javax.swing.JPanel;
import javax.swing.JTextPane;
import javax.swing.JEditorPane;
import javax.swing.GroupLayout;
import javax.swing.SwingUtilities;
import java.awt.Desktop;
import java.net.URI;
import java.net.URL;

class TitleHyperlinkListener implements HyperlinkListener {
  public void hyperlinkUpdate(HyperlinkEvent evt) {
    if (evt.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
      JEditorPane pane = (JEditorPane)evt.getSource();
      System.out.println(evt.getURL());
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
 
public class TitlePage implements Runnable {

    @Override
    public void run() {
        JFrame f = new JFrame ("EQUIP - e-Lab Qn User Interface Purdue");
        JPanel pane = new JPanel();
        GroupLayout layout = new GroupLayout(pane);
        pane.setLayout(layout);
        f.add(pane);

        JLabel shower_label = new JLabel(new ImageIcon("images/crop.jpg"));
        JEditorPane title_text = new JEditorPane();
        title_text.setEditable(false);
        java.net.URL url = TitlePage.class.getResource("title.html");
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

        layout.setHorizontalGroup(layout.createSequentialGroup().
          addComponent(shower_label).
          addComponent(title_text)
        );
        layout.setVerticalGroup(layout.createParallelGroup().
          addComponent(shower_label).
          addComponent(title_text)
        );
        f.pack();
        f.setVisible(true);
    }
 
    public static void main(String[] args) {
        TitlePage tp = new TitlePage();
        SwingUtilities.invokeLater(tp);
    }
}
