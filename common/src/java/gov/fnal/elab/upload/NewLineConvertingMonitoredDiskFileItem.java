/* Licence:
 *   Use this however/wherever you like, just don't blame me if it breaks anything.
 *
 * Credit:
 *   If you're nice, you'll leave this bit:
 *
 *   Class by Pierre-Alexandre Losson -- http://www.telio.be/blog
 *   email : plosson@users.sourceforge.net
 */
package gov.fnal.elab.upload;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.fileupload.disk.DiskFileItem;

import be.telio.mediastore.ui.upload.MonitoredOutputStream;
import be.telio.mediastore.ui.upload.OutputStreamListener;

/**
 * Created by IntelliJ IDEA.
 * 
 * @author Original : plosson on 05-janv.-2006 10:46:33
 */
public class NewLineConvertingMonitoredDiskFileItem extends DiskFileItem {
	private MonitoredOutputStream mos = null;
	private OutputStreamListener listener;

	public NewLineConvertingMonitoredDiskFileItem(String fieldName,
			String contentType, boolean isFormField, String fileName,
			int sizeThreshold, File repository, OutputStreamListener listener) {
		super(fieldName, contentType, isFormField, fileName, sizeThreshold,
				repository);
		this.listener = listener;
	}

	public OutputStream getOutputStream() throws IOException {
		if (mos == null) {
			mos = new MonitoredOutputStream(new NewLineConvertingOutputStream(
					super.getOutputStream()), listener);
		}
		return mos;
	}
}
