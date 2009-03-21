<%@ page import="java.io.*,java.awt.*,java.awt.image.*,javax.imageio.*" %><%

String[] pvalues = request.getParameterValues("v");
String[] pcolors = request.getParameterValues("c");
String[] labels = request.getParameterValues("label");
if (pvalues == null) {
	pvalues = new String[] { "100" };
}
int sc = pvalues.length;
double[] values = new double[sc];
Color[] colors = new Color[sc];

if (labels == null) {
	labels = new String[sc]; 
}

for (int i = 0; i < sc; i++) {
    values[i] = Double.parseDouble(pvalues[i]);
    if (pcolors == null || i >= pcolors.length) {
    	colors[i] = Color.BLUE;
    }
    else {
    	try {
    		colors[i] = new Color(Integer.parseInt(pcolors[i], 16));
    	}
    	catch (NumberFormatException e) {
    		colors[i] = Color.BLUE;
    	}
    }
}

int width = 200;
int height = 200;

String tmp = request.getParameter("width");

if (tmp != null) { 
	width = Integer.parseInt(tmp);
}

tmp = request.getParameter("height");

if (tmp != null) { 
	height = Integer.parseInt(tmp);
}

BufferedImage buffer = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
Graphics g = buffer.createGraphics();
Graphics2D g2 = (Graphics2D) g;
g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
g2.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION, RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);

double arc = 0;
for (int i = 0; i < sc; i++) {
    g.setColor(colors[i]);
    double crt = values[i] * 360 / 100;
    g.fillArc(0, 0, width , height, (int) arc, (int) crt + 1);
    arc += crt;
}

response.setContentType("image/png");
OutputStream os = response.getOutputStream();
ImageIO.write(buffer, "png", os);
os.close();

%>