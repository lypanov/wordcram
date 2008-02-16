import java.util.*;
import java.io.*;

class TextUI {
	public BufferedReader in;
	public PrintStream out;
	public TextUI(BufferedReader in,PrintStream out) {
		this.in=in;
		this.out=out;
	}
}

class TextTester implements UIcallback {

	private TextUI ui;

	public TextTester(TextUI ui) {
		this.ui=ui;
	}

   public void callback(Entry entry, boolean direction) {
		try {
			String question = entry.toQuestionString(direction);
			String correctAnswer = entry.toAnswerString(direction);
			ui.out.println
				("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
			ui.out.print(question + " =\n: ");
			boolean correct=(ui.in.readLine()).equals(correctAnswer);
			if (correct) {
				ui.out.println("correct!");
				entry.r+=1;
			} else {
				ui.out.println("wrong!");
				entry.r-=1;
			}
			ui.out.println(
				question + " = " +
				entry.toQuestionString(!direction));
			ui.in.readLine();
		} catch(IOException e) {
			System.err.println("ouch!!!" + e);
			System.exit(1);
		}
	}
}

class JVocabTrainer {

	public static void linePause(BufferedReader in) {
		try {
			in.readLine();
		} catch(IOException e) {
			System.err.println("ouch!!!" + e);
			System.exit(1);
		}
	}

	public static void main(String[] args) throws FileNotFoundException {
		String filename;
		
		if(args.length==1) {
			filename=args[0];
		} else {
			filename="../../user/current";
		}
	
		BufferedReader in = 
			new BufferedReader(new InputStreamReader(System.in));
	
		WordList words = new WordList();
	
	   if (!(new File(filename)).exists())
			System.out.println(filename + "doesn't exist!!!");
	
	   words.load(filename);
	
		WordList wordset = words.clone(new RandomSorter());

		TextUI ui = new TextUI(in,System.out);
		TextTester tester = new TextTester(ui);

		System.out.println("pass one:");
		linePause(in);
		wordset = wordset.clone(new AccendingRetentionSorter());
		wordset = wordset.clone(new Snarfer(30));
		wordset = wordset.clone(new RandomSorter());
		wordset.clone(new TesterPlugin(tester));
			
		System.out.println("pass two:");
		linePause(in);
		wordset = wordset.clone(new AccendingRetentionSorter());
		wordset = wordset.clone(new Snarfer(20));
		wordset = wordset.clone(new RandomSorter());
		wordset.clone(new TesterPlugin(tester));
	
		System.out.println("pass three:");
		linePause(in);
	   wordset = wordset.clone(new AccendingRetentionSorter()); 
		wordset = wordset.clone(new Snarfer(20));
	   wordset = wordset.clone(new RandomSorter());
		wordset.clone(new TesterPlugin(tester));
			
		System.out.println("pass four:");
		linePause(in);
		wordset = wordset.clone(new AccendingRetentionSorter());
		wordset = wordset.clone(new Snarfer(10));
		wordset = wordset.clone(new RandomSorter());
		wordset.clone(new TesterPlugin(tester));

		words.save(filename);
	}
}
