import java.util.*;

public class AccendingRetentionSorter implements NextEntryPlugin {
	public PluginResponse nextEntry(Vector vector) {
		Enumeration elements = vector.elements();
		Entry minElem;
                if (elements.hasMoreElements())
                        minElem = (Entry)(elements.nextElement());
                   else return null;
                while(elements.hasMoreElements()) {
                        Entry elem = (Entry)(elements.nextElement());
                        if (elem.r < minElem.r) {
                                minElem = elem;
                        }
                }
                return new PluginResponse(minElem,true);
	}
}
