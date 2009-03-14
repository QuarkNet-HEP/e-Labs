/*
 * Created on Mar 13, 2009
 */
package gov.fnal.elab.upload;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class NewLineConvertingOutputStream extends OutputStream {
	private OutputStream os;
	private boolean lastWasCR;

	public NewLineConvertingOutputStream(OutputStream os) {
		if (os instanceof BufferedOutputStream) {
			this.os = os;
		}
		else {
			this.os = new BufferedOutputStream(os);
		}
	}

	public void write(int b) throws IOException {
		if (b == '\r') {
			if (lastWasCR) {
				os.write('\n');
			}
			else {
				lastWasCR = true;
			}
		}
		else {
			if (b != '\n' && lastWasCR) {
				os.write('\n');
			}
			lastWasCR = false;
			os.write(b);
		}
	}

	public void write(byte[] b, int off, int len) throws IOException {
		for (int i = 0; i < len; i++) {
			write(b[i + off]);
		}
	}

	public void write(byte[] b) throws IOException {
		for (int i = 0; i < b.length; i++) {
			write(b[i]);
		}
	}

	public void flush() throws IOException {
		os.flush();
	}

	public void close() throws IOException {
		if (lastWasCR) {
			os.write('\n');
			lastWasCR = false;
		}
		os.close();
		super.close();
	}
}
