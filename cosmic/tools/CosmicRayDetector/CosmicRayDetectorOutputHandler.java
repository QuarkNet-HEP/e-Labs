
import javax.swing.JComponent;

public class CosmicRayDetectorOutputHandler {
  JComponent comp;
  public CosmicRayDetectorOutputHandler() { }
  public CosmicRayDetectorOutputHandler(JComponent c) {
    comp = c;
  }
  void Process(String s) {
    System.out.println("CosmicRayDetectorOutputHandler: '" + s + "'");
  }
}
