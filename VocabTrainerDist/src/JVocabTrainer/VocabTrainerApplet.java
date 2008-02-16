import java.awt.*;
import java.awt.event.*;
import java.applet.*;
import java.io.*;

class AppletUI extends Panel implements ActionListener {

	public TextArea area;
	public TextField field;
	public Button begin,stop;
	public Semaphore sem;

	public AppletUI() {

		sem = new Semaphore(0);

		setLayout(new GridLayout(4,1));
		setBackground(Color.white);

		area = new TextArea();
		add(area);

		field = new TextField();
		add(field);
		
		begin = new Button("Begin!");
		begin.addActionListener(this);
		add(begin);

		stop = new Button("Stop!");
		add(stop);

		setVisible(true);
	}

	public void actionPerformed(ActionEvent event) {
      Object source = event.getSource();
      if (source == begin) {
			area.setText("pressed");
			sem.V();
		} /*
		else
      if (source == highestPriceField) {
         highestPrice = highestPriceField.getText();
      }*/
	}


}

class AppletTester implements UIcallback {

	AppletUI ui;

	public AppletTester(AppletUI ui) {
		this.ui=ui;
	}

	public void callback(Entry entry, boolean direction) {
		String question = entry.toQuestionString(direction);
		String correctAnswer = entry.toAnswerString(direction);
		String output = "";
		output += question + " =\n: ";
		System.out.println(output);
		ui.area.setText(output);
		ui.sem.P();
		/*
		boolean correct=(ui.in.readLine()).equals(correctAnswer);
		if (correct) {
			ui.out.println("correct!");
			p.entry.r+=1;
		} else {
			ui.out.println("wrong!");
			p.entry.r-=1;
		}
		ui.out.println(
			question + " = " +
			entry.toQuestionString(!direction));
		ui.in.readLine();
		*/
	}

}

/*
public class VocabTrainerApplet extends Applet {

	TextArea area;
	TextField field;
   Button begin,stop;

	public void init() {
		setLayout(new GridLayout(4,1));
		setBackground(Color.white);

		area = new TextArea();
		area.setText("");
		add(area);

		field = new TextField();
		add(field);
		
		begin = new Button("Begin!");
		add(begin);

		stop = new Button("Stop!");
		add(stop);

		//addListener(this);
	}

	public void actionPerformed(ActionEvent event) {
	      Object source = event.getSource();
	      if (source == begin) {
				area.setText("pressed");
			}
			else
	      if (source == highestPriceField)
	         highestPrice = highestPriceField.getText();
	      }
	}
}
*/

public class VocabTrainerApplet extends Applet {

	private AppletUI ui;

	public void init() {
		Panel holder = new Panel();
		holder.setLayout(new GridLayout(1,2));
		add(holder);
		add(new TextField());

		ui = new AppletUI();
		holder.add(ui);

		new TesterThread(ui).run();
	}
}

class TesterThread extends Thread {

	private AppletUI ui;

	public TesterThread(AppletUI ui) {
		this.ui = ui;
	}

	public void run() {
		try {		
	
			String filename="basic";
		
			BufferedReader in
			   = new BufferedReader(new InputStreamReader(System.in));
		
			WordList words = new WordList();
		
		   if (!(new File(filename)).exists())
				System.out.println(filename + "doesn't exist!!!");
			
		   words.load(filename);
		
			WordList wordset = words.clone(new RandomSorter());
	
			wordset = wordset.clone(new Snarfer(5));
			AppletTester tester = new AppletTester(ui);
			wordset = wordset.clone(new TesterPlugin(tester));
	
			/*
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
		   wordset = wordset.clone(new AccendingRetentionSorter()); 
			wordset = wordset.clone(new Snarfer(20));
		   wordset = wordset.clone(new RandomSorter());
		   wordset.test(in);
			
			System.out.println("pass four:");
			in.readLine();
		   wordset = wordset.clone(new AccendingRetentionSorter());
		   wordset = wordset.clone(new Snarfer(10));
		   wordset = wordset.clone(new RandomSorter());
		   wordset.test(in);
			*/
	
			words.save(filename);
		} catch(Exception e) {System.out.println(e); System.exit(1);}
	}
}
