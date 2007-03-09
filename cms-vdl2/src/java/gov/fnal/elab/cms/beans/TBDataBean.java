package gov.fnal.elab.cms.beans;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import java.io.File;
import java.util.Vector;
import java.io.IOException;

public class TBDataBean {

	//Exported Data:
	private Vector tbFiles; //vector containing  [name,type] arrays
	private Vector formulas; //vector containing [id,name,title,labelx,labely] arrays
	private Vector leaves; //vector containing [id,name,title,labelx,labely] arrays
	private String dataLocation;
	
	//internal use objects
	private DocumentBuilderFactory dbf;
	private DocumentBuilder builder;
	private Document xmlDoc;
	private String xmlTBDataFile;
	
	public TBDataBean(){
		System.out.println("Created TBData bean");
		dataLocation="/tmp"; // Overwrite later
		dbf=DocumentBuilderFactory.newInstance();
	}
	
	
	public void populateFromFile(String filename){
		//System.out.println("Populate bean from file "+filename);
		try{
			builder=dbf.newDocumentBuilder();
			File f=new File(filename);
			xmlDoc=builder.parse(f);
			
			tbFiles=getXMLFields(xmlDoc,"file");
			formulas = getXMLFields(xmlDoc,"formula");
			leaves = getXMLFields(xmlDoc,"leaf");
			
			dataLocation=((Element)xmlDoc.getElementsByTagName("dataset").item(0)).getAttribute("location");
			
		}catch(ParserConfigurationException pce){
			//TODO: replace with logger
			System.out.println(pce.getLocalizedMessage());			
		}catch(SAXException saxe){
			//TODO: replace with logger
			System.out.println(saxe.getLocalizedMessage());
		}catch(IOException ioe){
			System.out.println(ioe.getLocalizedMessage());
		}
	}
	
	private Vector getXMLFields(Document doc, String fieldName){
		Vector result=new Vector();
		
		NodeList fileNodes=doc.getElementsByTagName(fieldName);
		for (int i=0; i<fileNodes.getLength();i++){
			String nodeNameString=fileNodes.item(i).getNodeName();
			String nodeTypeString="n/a";
			short nodeType=fileNodes.item(i).getNodeType();
			if (nodeType==Node.ELEMENT_NODE){
				nodeTypeString="Element";
				//TODO: More work here, determine the attributes
				Element elementNode=(Element)fileNodes.item(i);
				
				//NOTE: file-specific code, handles files,formula, and leaf NODES
				if("file".equalsIgnoreCase(fieldName)){
					String nameAttributeString=elementNode.getAttribute("name");
					String typeAttributeString=elementNode.getAttribute("type");
					String[] arrayElement=new String[]{nameAttributeString,typeAttributeString};
					result.add(arrayElement);
					//System.out.println("Processing Node "+nodeNameString+" with type value "+typeAttributeString);
				}
				if("formula".equalsIgnoreCase(fieldName)){
					String idAttributeString=elementNode.getAttribute("id");					
					String nameAttributeString=elementNode.getAttribute("name");
					String titleAttributeString=elementNode.getAttribute("title");
					String labelxAttributeString=elementNode.getAttribute("labelx");
					String labelyAttributeString=elementNode.getAttribute("labely");
					String[] arrayElement=new String[]{idAttributeString,nameAttributeString,titleAttributeString,labelxAttributeString,labelyAttributeString};
					result.add(arrayElement);
					//System.out.println("Processing Node "+idAttributeString+nodeNameString+titleAttributeString);
				}
				if("leaf".equalsIgnoreCase(fieldName)){
					String idAttributeString=elementNode.getAttribute("id");					
					String nameAttributeString=elementNode.getAttribute("name");
					String titleAttributeString=elementNode.getAttribute("title");
					String labelxAttributeString=elementNode.getAttribute("labelx");
					String labelyAttributeString=elementNode.getAttribute("labely");
					String[] arrayElement=new String[]{idAttributeString,nameAttributeString,titleAttributeString,labelxAttributeString,labelyAttributeString};
					result.add(arrayElement);
					//System.out.println("Processing Node "+idAttributeString+nodeNameString+titleAttributeString);
				}
			}else{
				System.out.println("ERROR: Unexpected element in tb_data.xml for node "+nodeNameString+ " @ pos. "+i);
			}
		}
		
		return result;
	}

	public Vector getTbFiles() {
		return tbFiles;
	}



	public String getDataLocation() {
		return dataLocation;
	}



	public Vector getFormulas() {
		return formulas;
	}



	public Vector getLeaves() {
		return leaves;
	}
	
}
