
import javax.swing.JComponent;

public class EQUIPOutputHandler {
  JComponent comp;
  public EQUIPOutputHandler() { }
  public EQUIPOutputHandler(JComponent c) {
    comp = c;
  }
  void Process(String s) {
    System.out.println("CosmicRayDetectorOutputHandler: '" + s + "'");
  }
}
