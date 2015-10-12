1 - Extract all the files from EQUIP_date.zip

2 - Use this folder or move somewhere else in your computer. You need to check that all these files have been extracted:
	  EQUIP_date.jar
		freehep-jminuit-1.0.jar
		jcommon-1.0.17.jar
		jfreechart-1.0.14.jar
		junit.jar
		librxtxSerial.jnilib (only needed for Windows)
		RXTXcomm.jar
		README
		rxtxSerial.dll (only needed for Windows)
		-->You might need to download the 64 bit version (depending on your machine)
		http://jlog.org/rxtx-win.html
	
3 - Install driver from Silabs. A restart might be needed and connect the detector.
	  (Download from: http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx)
	
4 - If you are using a MAC:
	  Open a terminal window
	  Type 'cd /var'
	  Type 'sudo mkdir lock' (This will ask you for sudo password)
	  Type 'chown -R [user]:wheel /var/lock' (where [user] is your username)

5 - To test if the install is successful (either a MAC or PC): 
	  Open a terminal window (MAC) or cmd window (PC)
	  type 'cd /path/to/folder/EQUIP_date'
	  type 'java -jar EQUIP_date.jar'
	
	  If everything is OK you will see output (in the terminal or cmd window) like the following and a java application called EQUIP will open up:
	  *******************************************
 	  Experimental:  JNI_OnLoad called.
	  Stable Library
	  =========================================
	  Native lib Version = RXTX-2.1-7
	  Java lib Version   = RXTX-2.1-7
    *******************************************
    
    If you get any other output, please copy/paste it in an email to help@i2u2.org.
     
6 - You need at least Java 6 in your machine for this to work.
	  To test, open a terminal window (MAC) or a cmd window (PC) and: 
	  type 'java -version'
	  You should expect some output like:
   	*******************************************
	  java version "1.6.0_65" --> the first 6 indicates the version.
	  Java(TM) SE Runtime Environment (build 1.6.0_65-b14-462-11M4609)
	  Java HotSpot(TM) 64-Bit Server VM (build 20.65-b04-462, mixed mode)
	  *******************************************

	  If Java is not installed, then you need to download it from: 
	  https://www.java.com/en/download/
	  And install it in your machine. You might need admin rights to do this.

	  Installation error: 'Cannot Proceed with current Internet proxy settings'
	  https://www.java.com/en/download/help/connect_proxy.xml
	  Download from:
	  https://www.java.com/en/download/windows_offline.jsp

	  Also, you need to make sure that java is in the PATH
	  type 'echo %PATH%' (in Windows)
	  There has to be something like C:\Program Files\Java\Jre7\bin in the response you get. 
	  If you do not see it, then you need to add the java path to the environment variables.
		
		
7 - If you are installing EQUIP on a Raspberry Pi, you need to install the RXTX library. Open a command window and run:
	  sudo apt-get install librxtx-java
	  
	  Then, go to the folder where you downloaded and extracted EQUIP and run EQUIP by using this command:
	  java -Djava.library.path=/usr/lib/jni -cp /usr/share/java/RXTXcomm.jar:. -jar EQUIP_xxx.jar
	
8 - If you are using any other OS and are not able to get EQUIP to run, please send an email to help@i2u2.org. Other users that have successfully
    installed EQUIP using other OS may be able to help you with your questions.
    