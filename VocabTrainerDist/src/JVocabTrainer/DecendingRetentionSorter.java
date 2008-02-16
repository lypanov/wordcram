import java.util.*;

public class DecendingRetentionSorter implements NextEntryPlugin {
	public PluginResponse nextEntry(Vector vector) {
		Enumeration elements = vector.elements();
		Entry maxElem;
		if (elements.hasMoreElements())
			maxElem = (Entry)(elements.nextElement());
		else return null;
		while(elements.hasMoreElements()) {
			Entry elem = (Entry)(elements.nextElement());
			if (elem.r > maxElem.r) maxElem = elem;
		}
		return new PluginResponse(maxElem,true);
	}
}
