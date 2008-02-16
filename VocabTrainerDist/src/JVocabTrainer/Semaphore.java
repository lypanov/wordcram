
import java.io.*;
import java.lang.*;
import java.util.*;

public class Semaphore {

	private int count = 0;

	public Semaphore(int val)
		{
      	count = val;
      }
	
        public synchronized void P()
        {
                while (count <= 0) {
                        try{ wait(); } catch(InterruptedException exc) {
                                System.err.print("IE: " + exc);
                                System.exit(0);
                        }
                }
                count--;
        }
	
        public synchronized void V()
        {
               count++;
               notifyAll();
        }
}
