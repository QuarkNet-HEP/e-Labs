/*
 * Created on Oct 6, 2008
 */
package gov.fnal.elab;

import gov.fnal.elab.util.URLEncoder;

import java.util.Arrays;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Downloader extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
						/* The original code got elabName via GET parameter "elab".
						 * A better method is to use the request's Elab object, if available.
						 * Keeping the original for backup/legacy, but it would be ideal if 
						 * passing by GET could be avoided entirely.
						 * This is also when and why I added "elab.namelist" to elab.properties
						 *   - JG 23Mar2018
						 */
						// if the request includes an Elab, which is typically set by elab.jsp
						if (req.getAttribute("elab") != null) {
								String elabName = req.getAttribute("elab").getName();
								if (elabName == null) {
										throw new ElabJspException("Elab exists but is missing name");
								}
						} else {
								// if the request does not include an Elab
								String elabName = req.getParameter("elab");
								if (elabName == null) {
										throw new ElabJspException("Elab name not provided");
								}
								
								/* GET parameters are dangerous.
								 * Here, "elab" -> elabName allows directory traversal attack.
								 * To fix, compare it to allowed e-Lab names from
								 * elab.properties and only allow matches - JG 23Mar2018 */
								String nameList = req.getAttribute("elab").getProperty("elab.namelist");
								List<String> elabNames = Arrays.asList(nameList.split(","));
								if ( !(elabNames.contains(elabName)) ) {
										throw new ElabJspException("Missing Elab and elab name. Options are" + nameList);
								}
						}
						
            ElabGroup user = ElabGroup.getUser(req.getSession());

            if (user == null) {
                RequestDispatcher rd = req.getRequestDispatcher("/" + elabName
                        + "/login/login.jsp?prevPage=/elab"
                        + req.getServletPath() + "?" + URLEncoder.encode(req.getQueryString()));

                if (rd != null) {
                    rd.forward(req, resp);
                    return;
                }
                else {
                    throw new ElabJspException(
                            "You must be logged in in order to access this page");
                }
            }

						/* More GET parameters, but these don't allow for directory
						 *   traversal attacks the way "elab" did - JG 2018 */ 
            String filename = req.getParameter("filename");
            if (filename == null) {
                throw new ElabJspException("Missing file name");
            }
            String type = req.getParameter("type");
            if (type == null) {
                throw new ElabJspException("Missing file type");
            }

            Elab elab = Elab.getElab(null, elabName);
            String pfn;
            if (type.equals("split")) {
                pfn = RawDataFileResolver.getDefault().resolve(elab, filename);
            }
            else {
                if (type.equals("equip")) {
                	pfn = elab.getProperties().getDataDir() + File.separator + "equip" + File.separator + filename;
                } else {
                	if (type.equals("file")) {
                    	pfn = elab.getProperties().getDataDir() + File.separator + filename;                		
                	} else {
                		pfn = user.getDir(type) + File.separator + filename;
                	}
                }
            }
            resp.setContentType("x-object/data");
            resp.addHeader("Content-Disposition", "attachment;filename=" + filename);
            resp.addHeader("Content-Length", String.valueOf(new File(pfn).length()));
            FileInputStream fis = new FileInputStream(pfn);
            byte[] buf = new byte[16384];
            OutputStream os = resp.getOutputStream();
            int len = 0;
            while ((len = fis.read(buf)) != -1) {
                os.write(buf, 0, len);
            }
            fis.close();
        }
        catch (ElabJspException e) {
            PrintWriter wr = resp.getWriter();
            wr.write("<html>\n");
            wr.write("<head>");
            wr.write("<title>Download error</title>");
            wr.write("</head>\n");
            wr.write("<body>");
            wr.write("<h1>");
            wr.write(e.getMessage());
            wr.write("</h1>");
            wr.write("</body>");
            wr.write("</html>");
        }
    }
}
