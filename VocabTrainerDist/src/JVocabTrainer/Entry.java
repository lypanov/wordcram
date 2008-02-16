import java.util.*;

public class Entry {

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
