import java.util.LinkedList;

class Node
{
	String name;
	String on;
	boolean clear;
	Node()
	{
		name="";
		on="";
		clear = false;
	}
	
	Node(String name, String on, boolean clear)
	{
		this.name = name;
		this.on = on;
		this.clear = clear;
	}

}

class Stack
{
	LinkedList<Node> nodes;
	Stack(int is_start)
	{
		 if(is_start==1) //start state
		 {
			 nodes = new LinkedList<Node>();
			 nodes.add(new Node("B", "A", true));//B on A with clear=true(as no element rests on B)
			 nodes.add(new Node("A", "table", false));	
			 nodes.add(new Node("C", "table", true));
			 nodes.add(new Node("D", "table", true));
		 }
		 else
		 {
			 nodes = new LinkedList<Node>();
			 nodes.add(new Node("C","A", true));
			 nodes.add(new Node("A","table", false));
			 nodes.add(new Node("B","D", true));
			 nodes.add(new Node("D","table", false));
		 }
	}
	
	public String toString()
	{
		String output = "";
		for(int i=0; i<nodes.size(); i++)
		{
			output = output + nodes.get(i).name + " on " + nodes.get(i).on + " | clear=" + nodes.get(i).clear+"\n";
		}
		return output;
	}
	
}

public class MainClass 
{
	static Stack start;
	static Stack goal;
	public static void main(String args[])
	{
		start = new Stack(1);
		goal = new Stack(0);
		show(start, goal);	//shows actions from start to goal
	}

	static void show(Stack start, Stack goal) 
	{
		System.out.println("Start:\n"+start);		
		System.out.println("Goal:\n"+goal);		
		for(int i=0; i<goal.nodes.size(); i++)
		{
			process(goal.nodes.get(i));
		}
		System.out.println("Final State:\n"+start);		
		
	}

	static void process(Node node)
	{
		for(int i=0; i<start.nodes.size(); i++)	//check if goal condition already exists
		{
			if(start.nodes.get(i).name == node.name && start.nodes.get(i).on == node.on)
			{
				return;
			}
		}
		//if not found in start state
		//B on A
		//actions: clear(A), clear(B), pickup(B), put(B,A)
		// table is always clear()
		//clear(A): if not true:
		//				clear(whatever is on A)
		// 				recurse;
		if(!node.on.equals("table"))
		{
			clear(node.on);	//clear A
		}
		clear(node.name);	//clear B
		put(node.name, node.on);	//put(B, A)
	}

	static void put(String name, String on) 
	{
		for(int i=0; i<start.nodes.size(); i++)
		{
			if(start.nodes.get(i).name.equals(name))
			{
				start.nodes.get(i).on = on;
			}
		}
		
		for(int i=0; i<start.nodes.size(); i++)
		{
			if(start.nodes.get(i).name.equals(on))
			{
				start.nodes.get(i).clear= false;
			}
		}
		System.out.println("Put " +name+ " on "+ on);
	}

	static void clear(String element) 
	{
		Node temp=null;	//temporary node
		for(int i=0; i<start.nodes.size(); i++)	//find that element
		{
			if(start.nodes.get(i).name == element)
				temp = start.nodes.get(i);
		}
		if(!temp.clear)	//check if that element is clear
		{
			System.out.println("Clear "+element);
			for(int i=0; i<start.nodes.size(); i++)	//find that element which sits on top of temp
			{
				if(start.nodes.get(i).on == temp.name)
				{
					clear(start.nodes.get(i).name);
					put(start.nodes.get(i).name, "table");
				}
			}
			temp.clear = true;
			
		}
	}
}
