import java.util.*;
import java.io.*;

class Entry {

	static Random random = new Random();
	
	public String l1, l2;
	public int r;

	private void construct(String l1, String l2, int r) {
		this.l1 = l1;
                this.l2 = l2;
                this.r  = r;
	}

	public Entry(String l1, String l2, int r) {
		construct(l1,l2,r);
	}

	public Entry(String s) {
		int p,r;
		String l1,l2;

		p=s.indexOf("|");
                l1=s.substring(0,p);
		s=s.substring(p+1);
	
		p=s.indexOf("|");

		if (p!=-1) {
                	l2=s.substring(0,p);
                	s=s.substring(p+1);
                	r=Integer.parseInt(s);
			construct(l1,l2,r);
		} else {
			construct(l1,s,Math.abs(random.nextInt()) % 10);
		}
	}

	public String toString() {
		return l1 + "|" + l2 + "|" + r;
	}

	public static String createAnswerString(String in) {
		String out="";
		int p = in.indexOf("=");
		if (p!=-1) {
			in = in.substring(0,p);
		}

		forLoop:for(int n=0;n<in.length();n++) {
			switch(in.charAt(n)) {
				case '(':
				case ')':
					break;
				case '=':
					break forLoop;
				default:
					out+=in.charAt(n);
					break;	
			}
		}

		return out;
	}
	
	private static String createQuestionString(String in) {
		String out="";

        forLoop:for(int n=0;n<in.length();n++) {
                        switch(in.charAt(n)) {
                                case '=':
					out+=" ";
                                        break;
                                default:
                                        out+=in.charAt(n);
                                        break;
                        }
                }

		return out;
	}

	public String toAnswerString(boolean direction) {
		if (direction) {
                        return createAnswerString(l1);
                } else {
                        return createAnswerString(l2);
                }
	}

	public String toQuestionString(boolean direction) {
		if (direction) {
			return createQuestionString(l2);
		} else {
			return createQuestionString(l1);
		}
	}
}

interface NextEntryPlugin {
	public PluginResponse nextEntry(Vector vector);
}

class PluginResponse {
	public Entry entry;
	public boolean insert;
	public PluginResponse() {}
	public PluginResponse(Entry entry,boolean insert) {
		this.entry = entry;
		this.insert = insert;
	}
}

class RandomSorter implements NextEntryPlugin {
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

class DecendingRetentionSorter implements NextEntryPlugin {
        public PluginResponse nextEntry(Vector vector) {
                Enumeration elements = vector.elements();
                Entry maxElem;
                if (elements.hasMoreElements())
                        maxElem = (Entry)(elements.nextElement());
                   else return null;
                while(elements.hasMoreElements()) {
                        Entry elem = (Entry)(elements.nextElement());
                        if (elem.r > maxElem.r) {
                                maxElem = elem;
                        }
                }
                return new PluginResponse(maxElem,true);
        }
}

class AccendingRetentionSorter implements NextEntryPlugin {
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

class RetentionSnarfer implements NextEntryPlugin {
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

class Snarfer implements NextEntryPlugin {
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

class WordList {

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

	public void test(BufferedReader in) throws IOException {
		String s1,s2;
		Enumeration elements = elements();
	        while (elements.hasMoreElements()) {
                        Entry entry = (Entry)(elements.nextElement());
			boolean direction = (Math.random()>=0.5);
			String correctAnswer = entry.toAnswerString(direction);
			String question = entry.toQuestionString(direction);
			System.out.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
			System.out.print(question + " =\n: ");
			boolean correct=(in.readLine()).equals(correctAnswer);
			if (correct) {
				System.out.println("correct!");
				entry.r+=1;
			} else {
				System.out.println("wrong!");
				entry.r-=1;
			}
			System.out.println(
                                entry.toQuestionString(direction) +
                                " = " +
                                entry.toQuestionString(!direction));
			in.readLine();
		}
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

class JVocabTrainer {

	public static void main(String[] args) throws FileNotFoundException {
		String filename;
	
		if(args.length==1) {
			filename=args[0];
		} else {
			filename="../../user/current";
		}

		BufferedReader in
                        = new BufferedReader(new InputStreamReader(System.in));

		WordList words = new WordList();

                if (!(new File(filename)).exists())
			System.out.println(filename + "doesn't exist!!!");

                words.load(filename);

		WordList wordset = words.clone(new RandomSorter());

		try {
			System.out.println("pass one:");
			in.readLine();
			wordset = wordset.clone(new AccendingRetentionSorter());
			wordset = wordset.clone(new Snarfer(30));
			wordset = wordset.clone(new RandomSorter());
			wordset.test(in);

			System.out.println("pass two:");
			in.readLine();
			wordset = wordset.clone(new AccendingRetentionSorter());
			wordset = wordset.clone(new Snarfer(20));
			wordset = wordset.clone(new RandomSorter());
			wordset.test(in);

			System.out.println("pass three:");
			in.readLine();
                        wordset = wordset.clone(new AccendingRetentionSorter());                        wordset = wordset.clone(new Snarfer(20));
                        wordset = wordset.clone(new RandomSorter());
                        wordset.test(in);

			System.out.println("pass four:");
			in.readLine();
                        wordset = wordset.clone(new AccendingRetentionSorter());
                        wordset = wordset.clone(new Snarfer(10));
                        wordset = wordset.clone(new RandomSorter());
                        wordset.test(in);

		} catch (IOException e) {
			System.out.println
				("fatal error while testing!");
		}

		words.save(filename);
	}
}
