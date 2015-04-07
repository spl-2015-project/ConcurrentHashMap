module spl.impl;

import std.stdio;
import spl.interfaces;

public class HashMap(K, V) : IMap!(K, V){
	
	private static final int INITIAL_CAPACITY = 16;
	
	/**
	* Hold the current size, which is equal to number of elements in the map
	*/
	private int size=0;
	/**
	* backingArray encapsulates the buckets
	*/
	private Node [] backingArr;
	
	private int capacity;
	
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
	}
	this(int capacity){
		this.capacity = capacity;
		backingArr = new Node[capacity];
	}
	/** 
	* Given a key, this function returns the appropriate bucket
	*/
	private int getBucket(K key){
		return key.toHash() % capacity;
	}
	
	override public void put(K key, V value){
		if(containsKey(key)){
			//TODO : need to add exception handling for this case
			return;
		}
		int bucket = getBucket(key);
		Node newNode = new Node(key, value);
		if(backingArr[bucket] is null){
			backingArr[bucket] = newNode;
		} else {
			newNode.next = backingArr[bucket];
			backingArr[bucket] = newNode;
		}
		this.size++;
	}
	
	override public V get(K key){
		int bucket = getBucket(key);
		Node t, first;
		t = first = backingArr[bucket];
		while(t !is null){
			if(t.key.opEquals(key)){
				return t.value;
			}
			t = t.next;
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
			return false;
		else
			return true;	
	}
	/**
	* Remove value of given key. 
	* returns the value that was returned, null if ke not found
	*/
	override public V remove(K key){
		int bucket = getBucket(key);
		//From the bucket, traverse the list for appropriate key
		Node prev, curr;
		prev = curr = backingArr[bucket];
		while(curr !is null){
			if(curr.key.opEquals(key)){
				// first node match; handle separately
				if(backingArr[bucket] == curr){
					backingArr[bucket] = curr.next;
					this.size--;
					return curr.value;
				}
					prev.next = curr.next;
					this.size--;
					return curr.value;
			}
			prev = curr;
			curr = curr.next;
		}
		//no key found
		return null;
	}
	
	/**
	* Wipe contents of map
	*/
	override public void clear(){
		
	}
}
