module spl.impl2;

import std.stdio;
import spl.interfaces;

public class ConcurrentHashMap(K, V) : IMap!(K, V){
	
	private static final int INITIAL_CAPACITY = 32;
	private static final int LOCKS = 32;
	
	/**
	* Hold the current size, which is equal to number of elements in the map
	*/
	private int size=0;
	/**
	* backingArray encapsulates the buckets
	*/
	private Node [] backingArr;
	
	private int capacity;
	
	private Object locks[];
	/**
	* This class will encapsulate a key value pair
	*/
	static class Node{
		K key;
		V value;
		Node next = null;
		this(){
			this.key = null;
			this.value = null;
		}
		this(K key, V value){
			this.key = key;
			this.value = value;
		}
	}
	this(){
		this.capacity = INITIAL_CAPACITY;
		backingArr = new Node[INITIAL_CAPACITY];
		locks =  new Object[LOCKS];
		initializeLocks();
	}
	this(int capacity){
		if(capacity < 32){
			capacity = 32;
		}
		this.capacity = capacity;
		backingArr = new Node[capacity];
		locks = new Object[LOCKS];
		initializeLocks();
	}
	private void initializeLocks(){
		for(int i=0; i<LOCKS; i++){
			locks[i] = new Object();
		}
	}
	/** 
	* Given a key, this function returns the appropriate bucket
	*/
	private int getBucket(K key){
		return key.toHash() % capacity;
	}
	
	private Object getLock(int bucket){
		return locks[bucket/capacity];
	}
	/**
	* Put a value in the Hash Map based on its key
	*/
	override public void put(K key, V value){
		if(containsKey(key)){
			//TODO : need to add exception handling for this case
			return;
		}
		if(this.size == this.capacity - 1){
			rehash();
		}
		int bucket = getBucket(key);
		Object lock = getLock(bucket);
		synchronized (lock) {
			Node newNode = new Node(key, value);
			if(backingArr[bucket] is null){
				backingArr[bucket] = newNode;
			} else {
				newNode.next = backingArr[bucket];
				backingArr[bucket] = newNode;
			}
			this.size++;
		}
		
	}
	private void rehash(){
	}
	/**
	*Find a value based on a given key
	*/
	override public V get(K key){
		int bucket = getBucket(key);
		Node t, first;
		t = first = backingArr[bucket];
		while(t !is null){
			if(t.key.opEquals(key)){
				// null implies element has been removed
				if(t.value is null){
				 	break;
			 	}
				else{
					return t.value;
				}
			}
			t = t.next;
		}
		// obtain corresponding lock and re check
		Object lock = getLock(bucket);
		synchronized (lock) {
			while(t !is null){
				if(t.key.opEquals(key)){
					// null implies element has been removed
					if(t.value is null){
					 	break;
				 	}
					else{
						return t.value;
					}
				}
				t = t.next;
			}
		}
		return null;
	}
	
	/**
	* Check if the given key is present in the map
	*/
	override public bool containsKey(K key){
		int bucket = getBucket(key);
		Node t, first;
		t = first = backingArr[bucket];
		if(first is null){
			return false;
		}
		while(t !is null){
			if(t.key.opEquals(key)){
				return true;
			}
			t = t.next;
		}
		return false;
	}
	/**
	* Check if map is empty
	*/
	override public bool isEmpty(){
		if(this.size == 0)
			return true;
		else
			return false;	
	}
	/**
	* Remove value of given key. 
	* returns the value that was returned, null if key not found
	*/
	override public V remove(K key){
		int bucket = getBucket(key);
		Node prev, curr;
		Object lock = getLock(bucket);
		synchronized (lock) {
			//From the bucket, traverse the list for appropriate key
			prev = curr = backingArr[bucket];
			while(curr !is null){
				if(curr.key.opEquals(key)){
					// first node match; handle separately
					if(backingArr[bucket] == curr){
						backingArr[bucket] = curr.next;						
					}else{
						prev.next = curr.next;
					}	
						this.size--;
						return curr.value;
				}
				prev = curr;
				curr = curr.next;
			}
		}
		//no key found
		return null;
	}
	
	/**
	* Wipe contents of map
	*/
	override public void clear(){
		backingArr = new Node[capacity];
		//TODO need to check on how gc works in this case
	}
	
	/**
	*	Get size of Hash Map
	*/
	override public int getSize(){
		return this.size;
	}
}
