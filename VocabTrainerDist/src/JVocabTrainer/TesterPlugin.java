import java.util.Vector;

public class TesterPlugin implements NextEntryPlugin {

	private UIcallback callback;

	public TesterPlugin(UIcallback callback) {
		this.callback = callback;
	}

	public PluginResponse nextEntry(Vector vector) {
		if (vector.isEmpty()) return null;
		Entry entry = (Entry) vector.firstElement();
		boolean direction = (Math.random()>=0.5);
		callback.callback(entry,direction);
		return new PluginResponse(entry, false);
	}
}
