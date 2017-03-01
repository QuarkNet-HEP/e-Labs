package gov.fnal.elab.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionContext;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import gov.fnal.elab.SessionListener;

import java.util.*;

public class SessionListenerTest {
	private SessionListener sessionListener;

	private HttpSession createSession(String id, boolean serializable, long lastAccess) {
		return new SessionTestImpl(id, serializable, lastAccess);
	}

	private HttpSessionEvent createSessionEvent(String id, boolean serializable, long lastAccess) {
		return new HttpSessionEvent(new SessionTestImpl(id, serializable, lastAccess));
	}

	private HttpSessionEvent createSessionEvent() {
		final long now = System.currentTimeMillis();
		return new HttpSessionEvent(createSession("xxx", true, now));
	}

	@Test
	public void testGetSessionCount() {
		sessionListener = new SessionListener();
		sessionListener.sessionCreated(createSessionEvent());
		if (SessionListener.getTotalActiveSession() < 1) {
			fail("getSessionCount");
		}
	}

	@Test
	public void testGetAllSessionsInformations() {
		final long now = System.currentTimeMillis();
		sessionListener = new SessionListener();
		sessionListener.sessionCreated(createSessionEvent("1", true, now));
		sessionListener.sessionCreated(createSessionEvent("2", true, now + 2));
		sessionListener.sessionCreated(createSessionEvent("3", true, now));
		sessionListener.sessionCreated(createSessionEvent("4", true, now - 2));
		sessionListener.sessionCreated(createSessionEvent("5", true, now));
		int total = sessionListener.getTotalActiveSession();
	}

	@Test
	public void testSessionCreated() {
		sessionListener = new SessionListener();
		sessionListener.sessionCreated(createSessionEvent());
		int total = sessionListener.getTotalActiveSession();
	}

	@Test
	public void testSessionDestroyed() {
		sessionListener = new SessionListener();
		sessionListener.sessionCreated(createSessionEvent());
		sessionListener.sessionDestroyed(createSessionEvent());
		int total = sessionListener.getTotalActiveSession();
	}

	public class SessionTestImpl implements HttpSession {
        private final Map<String, Object> attributes;
        private boolean invalidated;
        private String id = "12345";
        private long lastAccess = System.currentTimeMillis() - 3;

        SessionTestImpl(boolean serializable) {
                super();
                attributes = new LinkedHashMap<String, Object>();
                if (serializable) {
                        attributes.put("test", null);
                } else {
                        attributes.put("not serializable", new Object());
                        final Object exceptionInToString = new Object() {
                                /** {@inheritDoc} */
                                @Override
                                public String toString() {
                                        throw new IllegalStateException("error");
                                }
                        };
                        attributes.put("exception in toString()", exceptionInToString);
                }
        }

        SessionTestImpl(String id, boolean serializable, long lastAccess) {
                this(serializable);
                this.id = id;
                this.lastAccess = lastAccess;
        }

        boolean isInvalidated() {
                return invalidated;
        }

        @Override
        public Object getAttribute(String name) {
                return attributes.get(name);
        }

        /** {@inheritDoc} */
        @Override
        public Enumeration<String> getAttributeNames() {
                return Collections.enumeration(attributes.keySet());
        }

        /** {@inheritDoc} */
        @Override
        public long getCreationTime() {
                return System.currentTimeMillis() - 300000;
        }

        /** {@inheritDoc} */
        @Override
        public String getId() {
                return id;
        }

        /** {@inheritDoc} */
        @Override
        public long getLastAccessedTime() {
                return lastAccess;
        }

        /** {@inheritDoc} */
        @Override
        public int getMaxInactiveInterval() {
                return 20 * 60;
        }

        @Override
        public void invalidate() {
             invalidated = true;
        }

        @Override
        public boolean isNew() {
             return false;
        }

        @Override
        public void setAttribute(String name, Object value) {
             attributes.put(name, value);
        }

        @Override
        public void setMaxInactiveInterval(int interval) {
        }

		@Override
		public ServletContext getServletContext() {
			// TODO Auto-generated method stub
			return null;
		}


		@Override
		public Object getValue(String arg0) {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public String[] getValueNames() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public void putValue(String arg0, Object arg1) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void removeAttribute(String arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void removeValue(String arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public HttpSessionContext getSessionContext() {
			// TODO Auto-generated method stub
			return null;
		}
	}
}