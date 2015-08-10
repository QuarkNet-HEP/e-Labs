//
//    EQUIP - e-Lab Qn User Interface Purdue
//
//    Matthew Jones - Purdue University
//    Frank Roetker - Jefferson High School
//	  Edit Peronja - Education Office at Fermilab
//
//    This file provides the interface to the cosmic ray detector
//    hardware via the serial port.
//

import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

import java.io.FileDescriptor;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.FileNotFoundException;
import java.nio.charset.Charset;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

import java.util.Vector;

public class EQUIPKernel {

  InputStream in;
  OutputStream out;
  SerialReader reader;
  SerialWriter writer;
  Vector<EQUIPOutputHandler> handlers;
  String logfile;
  JFrame frame;
  boolean connected = false;

  public EQUIPKernel(JFrame f) {
    frame = f;
    handlers = new Vector<EQUIPOutputHandler>();
  }

  public boolean isConnected() {
	  return connected;
  }
  
  public void OpenLogFile( String filename ) throws Exception {
    logfile = filename;
    if ( reader != null ) reader.OpenLogFile(filename);
  }
  public void CloseLogFile( String filename ) throws Exception {
	SerialReader x = reader;
    reader.CloseLogFile();
  }
  public void AddOutputHandler(EQUIPOutputHandler o) {
    handlers.add(o);
    if ( reader != null ) reader.AddOutputHandler(o);
  }

  void connect ( String portName, int baud ) throws Exception {
    CommPortIdentifier portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
    if ( portIdentifier.isCurrentlyOwned() ) {
      System.out.println("Error: Port is currently in use");
      throw(new Exception());
    }
    else {
      CommPort commPort = portIdentifier.open(this.getClass().getName(),2000);
      if ( commPort instanceof SerialPort ) {
        SerialPort serialPort = (SerialPort) commPort;
        serialPort.setSerialPortParams(baud,SerialPort.DATABITS_8,SerialPort.STOPBITS_1,SerialPort.PARITY_NONE);
        in = serialPort.getInputStream();
        out = serialPort.getOutputStream();
        reader = new SerialReader(in);
        reader.OpenLogFile(logfile);
        for ( int i=0; i<handlers.size(); i++ ) {
          reader.AddOutputHandler((EQUIPOutputHandler)handlers.get(i));
        }
        writer = new SerialWriter(out);
        connected = true;
        (new Thread(reader)).start();
//        (new Thread(writer)).start();
      }
      else {
        System.out.println("Error: Only serial ports are handled by this example.");
        throw(new Exception());
      }
    }
  }
  void connect ( String portName ) throws Exception {
    connect(portName,115200);
  }

  void sendCommand(String s) throws Exception {
    s += '\r';
    byte buf[] = s.getBytes();
    for ( int i=0; i<buf.length; i++ ) {
   		out.write(buf[i]);
    }
  }
     
  public static class SerialReader implements Runnable {
    InputStream in;
    FileOutputStream out;
    Vector<EQUIPOutputHandler> handlers;
    String line;

    public SerialReader ( InputStream in ) {
      this.in = in;
      handlers = new Vector<EQUIPOutputHandler>();
      line = "";
    }
    public void AddOutputHandler(EQUIPOutputHandler o) {
      handlers.add(o);
    }
    public void OpenLogFile(String filename) {
      System.out.println("Opening file "+filename);
      try {
        out = new FileOutputStream(filename);
      }
      catch ( FileNotFoundException e ) {
        System.out.println("File not found exception.");
      }
    }
    public void CloseLogFile() {
      try {
        out.close();
      }
      catch ( Exception e ) {
        System.out.println("Failed to close...");
      }
    }
    public void run () {
      byte [] buffer = new byte[1024];
      int len = -1;
      try {
        while ( ( len = this.in.read(buffer)) > -1 ) {
          try {
            if ( out != null ) out.write(buffer,0,len);
          }
          catch ( IOException e ) {
            System.out.println("write() - "+e.getMessage());
            e.printStackTrace();
          }
          for ( int i=0; i<len; i++ ) {
            if ( buffer[i] == '\0' ) continue;
            line += (char)buffer[i];
            if ( buffer[i] == '\n' ) {
              //System.out.print(line);
              for ( int j=0; j<handlers.size(); j++ ) {
            	//EP - added try catch block with output and continue, lots of unhandled exceptions
            	//and user would not have any clue what failed
            	try {
                    ((EQUIPOutputHandler)handlers.get(j)).Process(line);            		
            	} catch (Exception e) {
                    System.out.println("Line: "+line+ " " + e.getMessage());
                    e.printStackTrace();
                    continue;
            	}
              }
              line = "";
            }
          }
        }
      }
      catch ( IOException e ) {
        e.printStackTrace();
      }            
    }
  }

  public static class SerialWriter implements Runnable {
    OutputStream out;
        
    public SerialWriter ( OutputStream out ) {
      this.out = out;
    }

    public void run () {
      try {                
        int c = 0;
        while ( ( c = System.in.read()) > -1 ) {
          if ( c == '\n' ) c = '\r';
          this.out.write(c);
        }
      }
      catch ( IOException e ) {
        e.printStackTrace();
      }            
    }
  }
}
