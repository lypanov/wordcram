import java.util.Vector;
import java.io.*;

public class RetentionSnarfer implements NextEntryPlugin {
	public int retention;
	public RetentionSnarfer(int retention) {
		this.retention = retention;
	}
	public PluginResponse nextEntry(Vector vector) {
		Enumeration elements = vector.elements();
		if (elements.hasMoreElements()) {
			PluginResponse response = new PluginResponse();
			Entry entry = (Entry)(elements.nextElement());
			response.entry = entry; 
			response.insert = (entry.r == retention);
			return response;
		} else return null;
	}
}
