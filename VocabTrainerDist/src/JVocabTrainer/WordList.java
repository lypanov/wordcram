import java.util.*;
import java.io.*;

public class WordList {

	Vector wordList;

	public Vector vector() {
		return wordList;
	}

	public WordList(Vector wordList) {
		this.wordList = wordList;
	}

	public WordList() {
		this(new Vector());
	}

	public WordList(String filename) {
		this();
		load(filename);
	}


	public void load(String filename) {
		try {
			BufferedReader file = 
				new BufferedReader(new FileReader(filename));
			while(true) {
				String line = file.readLine();
				if (line==null) break;
				add(new Entry(line));
			}
			file.close();
		} catch(Exception e) {
			System.out.println("Error while loading file!");
			System.out.println(e);
         System.exit(1);
		}
	}

	public void save(String filename) {
		try {
			BufferedWriter file;
			file = new BufferedWriter(new FileWriter(filename));
			Enumeration elements = elements();
                	while(elements.hasMoreElements()) {
                        	Entry elem = (Entry)(elements.nextElement());
				file.write(elem.toString());
				if(elements.hasMoreElements()) file.newLine();
			}
			file.flush();
			file.close();
		} catch(Exception e) {
                	System.out.println("Error while saving file!");
                	System.exit(1);
                }

	}
	
	public Object clone() {
		return new WordList((Vector)wordList.clone());
	}

	public WordList clone(NextEntryPlugin plugin) {
		WordList tmp = (WordList)(this.clone());
		WordList list = new WordList();
	      nextLoop:	
		while(true) {
			PluginResponse response;
			response = plugin.nextEntry(tmp.vector());
			if (response==null) break nextLoop;
			Entry elem = response.entry;
			if (response.insert) list.add(elem);
			tmp.remove(elem);
		}
		return list;
	}

	public void add(Entry e) {
		wordList.addElement(e);
	}

	public void remove(Entry e) {
		wordList.removeElement(e);
	}

	public void removeAll() {
		wordList.removeAllElements();
	}

	public Enumeration elements() {
		return wordList.elements();
	} 

	public Entry searchField_l1(String s) {
		Enumeration elements = elements();
                while(elements.hasMoreElements()) {
			Entry elem = (Entry)(elements.nextElement());
			if (elem.l1.equals(s)) {
				return elem;
			}
		}
		return null;
	}

	public Entry searchField_l2(String s) {
                Enumeration elements = elements();
                while(elements.hasMoreElements()) {
                        Entry elem = (Entry)(elements.nextElement());
                        if (elem.l2.equals(s)) {
                                return elem;
                        }
                }
                return null;
        }

	public String toString() {
		String str = super.toString();
		Enumeration elements = elements();
                while(elements.hasMoreElements()) {
			str+="\n";
                        Entry elem = (Entry)(elements.nextElement());
			str+="   " + elem;
                }
                return str;
	}

}
