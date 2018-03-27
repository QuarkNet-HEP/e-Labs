/*
 * Created on Oct 6, 2008
 */
package gov.fnal.elab;

import gov.fnal.elab.util.URLEncoder;

import java.util.Arrays;
import java.util.List;

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
						/* Updated to prevent directory traversal attack by 
						 *   verifying GET parameter "elab"/elabName - JG 23March2018 */
						/* Typically, elab.jsp will set an Elab object as a Request
						 *   Attribute "elab" */
						String elabName;
						List<String> allowedNames = Arrays.asList("cms", "cosmic", "ligo");
						// If the request includes an Elab:
						if (req.getAttribute("elab") != null) {
								Elab e = (Elab)req.getAttribute("elab");
								elabName = e.getName();
								String nameList = e.getProperty("elab.namelist");
								allowedNames = Arrays.asList(nameList.split(","));
						}
						// If the request does not include an Elab:
						else { // legacy/backup code
								elabName = req.getParameter("elab");
						}
						if (elabName == null) {
								throw new ElabJspException("No valid e-Lab name provided");
						}
						/* Check to make sure "elab" is one of the allowed e-Labs. */
						if ( !(allowedNames.contains(elabName)) ) {
								throw new ElabJspException("Invalid e-Lab name provided");
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
