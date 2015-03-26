module spl.interfaces;

public interface Map(K:Object, V:Object ){
	/**
		Put the given key value pair into the map
	*/
	public void put(K, V);
	/**
		Get the given value associated with the key
	*/
	public V get(K);
	/**
		Check if the given key has a mapping
	*/
	public bool containsKey(K);
	/**
		Check if the map contains at least one mapping
	*/
	public bool isEmpty();
	/**
		Remove the given key value mapping from the map if present
		Return the old value if the mapping was present, else null will be returned
	*/
	public V remove(K);
	/**
		Clear the contents of the map
	*/
	public void clear();
}

