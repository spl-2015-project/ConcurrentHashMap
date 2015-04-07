module spl.main;
import std.stdio;
import spl.impl;
import spl.interfaces;

class SimpleValue{
	string attr;
	public this(string attr){
		this.attr = attr;
	}
	override public string toString(){
		return attr;
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
}
unittest{ 
	HashMap!(SimpleKey, SimpleValue) m = new HashMap!(SimpleKey, SimpleValue)();
	SimpleKey keyObj2 = new SimpleKey("myKey2"), keyObj1 = new SimpleKey("myKey1");
	SimpleValue valObj2 = new SimpleValue("myVal2"), valObj1 = new SimpleValue("myVal1");
	m.put(keyObj1, valObj1);
	m.put(keyObj2, valObj2);
	assert(m.get(keyObj1).opEquals(valObj1));
	assert(m.get(keyObj2).opEquals(valObj2));
}

void main() {
	
	
	writeln("tests");
	
	/*int d;
	readf("Enter number : %d", &d);*/
}