<%@ page 
	import="java.io.*,java.awt.*,java.awt.image.*,javax.imageio.*,java.awt.geom.*"
	import="gov.fnal.elab.notifications.*,gov.fnal.elab.*"
%><%

String elab = request.getParameter("elab");
if (elab == null || elab.indexOf('/') >= 0) {
    throw new RuntimeException("Invalid elab: " + elab);
}
BufferedImage buffer = new BufferedImage(24, 24, BufferedImage.TYPE_INT_ARGB);
Graphics g = buffer.createGraphics();
Graphics2D g2 = (Graphics2D) g;
g2.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
g2.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION, RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);

BufferedImage baseIcon = ImageIO.read(new File(application.getRealPath(elab + "/graphics/notifications.png")));
g2.drawImage(baseIcon, 0, 0, null);

ElabGroup user = ElabGroup.getUser(session);
if (user != null) {
	ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(Elab.getElab(pageContext, elab));
	long count = np.getUnreadNotificationsCount(user);
	if (count > 0L) {
		String str = String.valueOf(count);
		Font font = new Font("sans", Font.BOLD, 9); 
		int radius = count < 10 ? 6 : count < 100 ? 7 : 10; 
		g2.setColor(Color.RED);
		g2.fillOval(15 - radius, 10 - radius, radius * 2, radius * 2);
		g2.setFont(font);
		g2.setColor(Color.WHITE);
		g2.drawString(String.valueOf(count), 24 - radius * 2, 13);
	}
}

response.setContentType("image/png");
OutputStream os = response.getOutputStream();
ImageIO.write(buffer, "png", os);
os.close();

%>