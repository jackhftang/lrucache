import unittest, options
import lrucache

suite "LruCache":

  test "put, get, del":
    let cache = newLruCache[int, int](100)

    # put
    for i in 1..10: cache[i] = i
    check: cache.len == 10  

    # get
    for i in 1..10: check: cache[i] == i
    
    # del
    for i in 1..10: cache.del(i)
    check: cache.len == 0
      
  test "remove items if capacity exceeded":
    let cache = newLruCache[int, int](5)

    # put
    for i in 1..10: cache[i] = i
    check: cache.len == 5  

    # check 
    for i in 1..5: 
      check: i notin cache
    for i in 6..10: 
      check: i in cache 

  test "remvoe least recently used item if capacity exceeded":
    let cache = newLruCache[int, int](2)
    cache[1] = 1
    cache[2] = 2
    cache[3] = 3
    check: 1 notin cache
    check: 2 in cache
    check: 3 in cache

    # access 2
    discard cache[2]
    cache[1] = 1

    check: 1 in cache
    check: 2 in cache
    check: 3 notin cache

  test "peek should not update recentness":
    let cache = newLruCache[int, int](2)
    cache[1] = 1
    cache[2] = 2

    # peek
    check: cache.peek(1) == 1
    cache[3] = 3

    check: 1 notin cache
    check: 2 in cache
    check: 3 in cache

  test "[]= should update recentness":
    let cache = newLruCache[int, int](2)
    cache[1] = 1
    cache[2] = 2

    # peek
    check: cache[1] == 1
    cache[3] = 3

    check: 1 in cache
    check: 2 notin cache
    check: 3 in cache

  test "getOrDefault()": 
    let cache = newLruCache[int, int](2)
    check: cache.getOrDefault(1,1) == 1
    check: 1 notin cache
    cache[1] = 2
    check: cache.getOrDefault(1,1) == 2

  test "getOrPut()":
    let cache = newLruCache[int, int](2)
    check: cache.getOrPut(1,1) == 1
    check: 1 in cache

  test "getOption()":
    let cache = newLruCache[int,int](1)
    check: cache.getOption(1).isNone
    cache[1] = 1
    check: cache.getOption(1) == some(1)

  test "isEmpty":
    let cache = newLruCache[int, int](2)
    check: cache.isEmpty
    cache[1] = 1
    check: not cache.isEmpty

  test "isFull":
    let cache = newLruCache[int, int](1)
    check: not cache.isFull
    cache[1] = 1
    check: cache.isFull

  test "clear":
    let cache = newLruCache[int, int](10)
    check: cache.isEmpty
    cache[1] = 1
    check: not cache.isEmpty
    cache.clear()
    check: cache.isEmpty

  test "re-capacity dynamically":
    let cache = newLruCache[int, int](1)
    cache[1] = 1
    cache[2] = 2 
    check: 1 notin cache
    check: 2 in cache
  
    cache.capacity = 2
    cache[1] = 1

    check: 1 in cache
    check: 2 in cache

  test "getLruValue":
    let cache = newLruCache[int, int](2)
    cache[1] = 10
    check: cache.getLruValue == 10
    cache[2] = 20
    check: cache.getLruValue == 10
    check: cache[1] == 10
    check: cache.getLruValue == 20
    cache[3] = 30
    check: cache.getLruValue == 10

  test "README usage":
    # create a new LRU cache with initial capacity of 1 items
    let cache = newLruCache[int, string](1) 

    cache[1] = "a"
    cache[2] = "b"

    # key 1 is not in cache, because key 1 is eldest and capacity is only 1
    assert: 1 notin cache 
    assert: 2 in cache

    # increase capacity and add key 1 
    cache.capacity = 2 
    cache[1] = "a"
    assert: 1 in cache
    assert: 2 in cache

    # update recentness of key 2 and add key 3, then key 1 will be discarded.
    assert: cache[2] == "b"
    cache[3] = "c"
    assert: 1 notin cache
    assert: 2 in cache
    assert: 3 in cache