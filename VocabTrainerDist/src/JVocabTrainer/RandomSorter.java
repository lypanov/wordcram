import java.util.Random;	
import java.util.Vector;

public class RandomSorter implements NextEntryPlugin {
	Random random = new Random();
	public PluginResponse nextEntry(Vector vector) {
		int size = vector.size();
		if (size>0) {
			PluginResponse response = new PluginResponse();
			int pos = Math.abs(random.nextInt()) % size;
			response.entry = (Entry)vector.elementAt(pos);
			response.insert = true;
			return response;
		} else {
			return null;
		}
	}
}
