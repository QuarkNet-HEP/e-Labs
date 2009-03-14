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

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;

import be.telio.mediastore.ui.upload.OutputStreamListener;

import java.io.File;

/**
 * Created by IntelliJ IDEA.
 * 
 * @author Original : plosson on 05-janv.-2006 10:46:26
 * 
 */
public class NewLineConvertingMonitoredDiskFileItemFactory extends
		DiskFileItemFactory {
	private OutputStreamListener listener = null;

	public NewLineConvertingMonitoredDiskFileItemFactory(
			OutputStreamListener listener) {
		super();
		this.listener = listener;
	}

	public NewLineConvertingMonitoredDiskFileItemFactory(int sizeThreshold,
			File repository, OutputStreamListener listener) {
		super(sizeThreshold, repository);
		this.listener = listener;
	}

	public FileItem createItem(String fieldName, String contentType,
			boolean isFormField, String fileName) {
		return new NewLineConvertingMonitoredDiskFileItem(fieldName, contentType, isFormField,
				fileName, getSizeThreshold(), getRepository(), listener);
	}
}
