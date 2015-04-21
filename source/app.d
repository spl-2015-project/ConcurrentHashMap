module main;
import std.stdio;
import std.string;
import spl.impl; 
import spl.impl2; 
import std.conv;
import spl.interfaces;
import std.concurrency;
import core.thread;
import std.datetime;

class SimpleValue{
	string attr;
	int id;
	public this(string attr, int id){
		this.attr = attr;
		this.id = id;
	}
	override public string toString(){
		return attr;
	}
	override size_t toHash(){
		size_t hash;
        foreach (char c; attr)
            hash = (hash * 9) + c;
        return hash;
	}
	override bool opEquals(Object o2){
		SimpleValue o = cast(SimpleValue) o2;
		return cmp(this.attr, o.attr) == 0;
	}
}
class SimpleKey{
	string key;
	public this(string key){
		this.key = key;
	}	
	override public string toString(){
		return key;
	}
	override size_t toHash(){
		size_t hash;
        foreach (char c; key)
            hash = (hash * 9) + c;
        return hash;
	}
	override bool opEquals(Object o2){
		SimpleKey o = cast(SimpleKey) o2;
		return cmp(this.key, o.key) == 0;
	}
}
unittest{ 
	
	//Testing simple put
	ConcurrentHashMap!(SimpleKey, SimpleValue) m = new ConcurrentHashMap!(SimpleKey, SimpleValue)();
	SimpleKey keyObj2 = new SimpleKey("key2"), keyObj1 = new SimpleKey("key1");
	SimpleValue valObj2 = new SimpleValue("val2", 2), valObj1 = new SimpleValue("val1", 1);
	m.put(keyObj1, valObj1);
	m.put(keyObj2, valObj2);
	assert(m.get(keyObj1).opEquals(valObj1));
	assert(m.get(keyObj2).opEquals(valObj2));
	
	SimpleKey k = new SimpleKey("key1");
	assert(m.get(k).opEquals(valObj1));
}

unittest{ 
	
	//Testing remove and containsKey
	ConcurrentHashMap!(SimpleKey, SimpleValue) m = new ConcurrentHashMap!(SimpleKey, SimpleValue)();
	SimpleKey keyObj2 = new SimpleKey("myKey2"), keyObj1 = new SimpleKey("myKey1");
	SimpleValue valObj2 = new SimpleValue("myVal2", 2), valObj1 = new SimpleValue("myVal1", 1);
	m.put(keyObj1, valObj1);
	m.put(keyObj2, valObj2);
	assert(m.getSize() ==2);
	m.remove(keyObj1);
	assert(m.containsKey(keyObj1) == false);
	assert(m.containsKey(keyObj2) == true);
	assert(m.getSize() ==1);
}
auto threads=200000;
void main() {
	
//	writeln("testing");
	 ConcurrentHashMap!(SimpleKey, SimpleValue) m = new ConcurrentHashMap!(SimpleKey, SimpleValue)(10000);
	 DateTime startTime = cast(DateTime)Clock.currTime();
	for(int i=0; i<threads; i+=2){
		 SimpleKey k = new SimpleKey("key" ~ to!string(i));
		 SimpleValue v =  new SimpleValue("val"  ~ to!string(i), i);
		 m.put(k, v);
		 SimpleKey k1 = new SimpleKey("key" ~ to!string(i+1));
		 SimpleValue v1 =  new SimpleValue("val"  ~ to!string(i+1), i+1);
		Task t = new Task(cast(shared)m, k1, v1);
		t.setTime(startTime);
		t.start();
//		writeln("From main : ", m.getSize());
	}
	 writeln("CHM Main Time ", (cast(DateTime)Clock.currTime() - startTime));
	
	
	 HashMap!(SimpleKey, SimpleValue) mhm = new HashMap!(SimpleKey, SimpleValue)(10000);
	  startTime = cast(DateTime)Clock.currTime();
	for(int i=0; i<threads; i+=2){
		 SimpleKey k = new SimpleKey("key" ~ to!string(i));
		 SimpleValue v =  new SimpleValue("val"  ~ to!string(i), i);
		 mhm.put(k, v);
		 SimpleKey k1 = new SimpleKey("key" ~ to!string(i+1));
		 SimpleValue v1 =  new SimpleValue("val"  ~ to!string(i+1), i+1);
		TaskHM t = new TaskHM(cast(shared)mhm, k1, v1);
		t.setTime(startTime);
		t.start();
//		writeln("From main : ", m.getSize());
	}
	 writeln("HM Main Time ", (cast(DateTime)Clock.currTime() - startTime));
}
class Task : Thread{
	ConcurrentHashMap!(SimpleKey, SimpleValue) m;
	SimpleKey k;
	SimpleValue v;
	DateTime startTime;
	this(shared ConcurrentHashMap!(SimpleKey, SimpleValue) m, SimpleKey k, SimpleValue v)
    {
        super(&run);
        this.m = cast(ConcurrentHashMap!(SimpleKey, SimpleValue)) m;
        this.k = k;
		this.v = v;
    }
    private:
    void run()
    {
       m.put(k,v);
//       writeln("From thread : ", m.getSize());
       if(v.id == threads-1){
       	 writeln("CHM Thread Time ", (cast(DateTime)Clock.currTime() - startTime));
       }
    }
    public:
    void setTime(DateTime time){
    	this.startTime = time;
    } 

}

class TaskHM : Thread{
	HashMap!(SimpleKey, SimpleValue) m;
	SimpleKey k;
	SimpleValue v;
	DateTime startTime;
	this(shared HashMap!(SimpleKey, SimpleValue) m, SimpleKey k, SimpleValue v)
    {
        super(&run);
        this.m = cast(HashMap!(SimpleKey, SimpleValue)) m;
        this.k = k;
		this.v = v;
    }
    private:
    void run()
    {
       m.put(k,v);
//       writeln("From thread : ", m.getSize());
       if(v.id == threads-1){
       	 writeln("HM Thread Time ", (cast(DateTime)Clock.currTime() - startTime));
       }
    }
    public:
    void setTime(DateTime time){
    	this.startTime = time;
    } 

}

