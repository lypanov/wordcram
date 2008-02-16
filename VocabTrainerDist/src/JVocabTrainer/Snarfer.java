import java.util.Vector;

public class Snarfer implements NextEntryPlugin {
	public int n;
	public Snarfer(int n) {
		this.n = n;
	}
	public PluginResponse nextEntry(Vector vector) {
		if (n>0) {
			if (vector.isEmpty()) return null;
			Entry entry = (Entry) vector.firstElement(); n--;
			return new PluginResponse(entry, true);
		} else {
			return null;
		}
	}
}
