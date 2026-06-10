import UIKit

/*
 
 ARRAY, SET, DICTIONARY, RANGE AND ANY IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 PART 1 — ARRAY
 ================================================================

 WHAT IS AN ARRAY?
 =================
 An Array is an ordered collection of values of the same type.
 Values can repeat and are accessed by index starting at 0.
 Declared using [] or Array<Type> syntax.

 Syntax:
   var array: [Type] = [value1, value2, value3]
   var array = [value1, value2, value3]
   var array: Array<Type> = []


 ================================================================
 ARRAY — CREATING ARRAYS
 ================================================================

 Empty Array:
   var names: [String] = []
   print(names)
   // Output: []

   var scores = [Int]()
   print(scores)
   // Output: []

 Array with Values:
   var fruits = ["Apple", "Banana", "Cherry"]
   print(fruits)
   // Output: ["Apple", "Banana", "Cherry"]

 Array with Repeated Value:
   var zeros = Array(repeating: 0, count: 5)
   print(zeros)
   // Output: [0, 0, 0, 0, 0]

 Array from Range:
   var numbers = Array(1...5)
   print(numbers)
   // Output: [1, 2, 3, 4, 5]

 Multi-dimensional Array:
   var matrix = [[1, 2], [3, 4], [5, 6]]
   print(matrix[1][0])
   // Output: 3


 ================================================================
 ARRAY — ACCESSING ELEMENTS
 ================================================================

 By Index:
   let colors = ["Red", "Green", "Blue"]
   print(colors[0])
   // Output: Red
   print(colors[2])
   // Output: Blue

 First and Last:
   print(colors.first ?? "None")
   // Output: Red
   print(colors.last ?? "None")
   // Output: Blue

 First and Last — Optional:
   var empty: [Int] = []
   print(empty.first)
   // Output: nil
   print(empty.last)
   // Output: nil

 Count and isEmpty:
   print(colors.count)
   // Output: 3
   print(colors.isEmpty)
   // Output: false
   print(empty.isEmpty)
   // Output: true

 Index of Element:
   let index = colors.firstIndex(of: "Green")
   print(index ?? -1)
   // Output: 1

 Contains:
   print(colors.contains("Red"))
   // Output: true
   print(colors.contains("Yellow"))
   // Output: false


 ================================================================
 ARRAY — MODIFYING ARRAYS
 ================================================================

 Append:
   var nums = [1, 2, 3]
   nums.append(4)
   print(nums)
   // Output: [1, 2, 3, 4]

 Append Multiple:
   nums.append(contentsOf: [5, 6, 7])
   print(nums)
   // Output: [1, 2, 3, 4, 5, 6, 7]

 Insert at Index:
   nums.insert(0, at: 0)
   print(nums)
   // Output: [0, 1, 2, 3, 4, 5, 6, 7]

 Remove at Index:
   nums.remove(at: 0)
   print(nums)
   // Output: [1, 2, 3, 4, 5, 6, 7]

 Remove First:
   nums.removeFirst()
   print(nums)
   // Output: [2, 3, 4, 5, 6, 7]

 Remove Last:
   nums.removeLast()
   print(nums)
   // Output: [2, 3, 4, 5, 6]

 Remove All:
   nums.removeAll()
   print(nums)
   // Output: []

 Update Element:
   var letters = ["a", "b", "c"]
   letters[1] = "B"
   print(letters)
   // Output: ["a", "B", "c"]

 Combine Arrays:
   let a = [1, 2, 3]
   let b = [4, 5, 6]
   let combined = a + b
   print(combined)
   // Output: [1, 2, 3, 4, 5, 6]


 ================================================================
 ARRAY — ITERATING
 ================================================================

 For Loop:
   let items = ["X", "Y", "Z"]
   for item in items {
       print(item)
   }
   // Output: X
   //         Y
   //         Z

 With Index (enumerated):
   for (index, value) in items.enumerated() {
       print("\(index): \(value)")
   }
   // Output: 0: X
   //         1: Y
   //         2: Z

 ForEach:
   items.forEach { print($0) }
   // Output: X
   //         Y
   //         Z


 ================================================================
 ARRAY — HIGHER ORDER FUNCTIONS
 ================================================================

 map — Transform each element:
   let numbers = [1, 2, 3, 4, 5]
   let doubled = numbers.map { $0 * 2 }
   print(doubled)
   // Output: [2, 4, 6, 8, 10]

 filter — Keep matching elements:
   let evens = numbers.filter { $0 % 2 == 0 }
   print(evens)
   // Output: [2, 4]

 reduce — Combine into one value:
   let sum = numbers.reduce(0) { $0 + $1 }
   print(sum)
   // Output: 15

   let product = numbers.reduce(1, *)
   print(product)
   // Output: 120

 compactMap — Map and remove nils:
   let strings = ["1", "two", "3", "four"]
   let ints = strings.compactMap { Int($0) }
   print(ints)
   // Output: [1, 3]

 flatMap — Flatten nested arrays:
   let nested = [[1, 2], [3, 4], [5, 6]]
   let flat = nested.flatMap { $0 }
   print(flat)
   // Output: [1, 2, 3, 4, 5, 6]

 sorted:
   let unsorted = [5, 3, 1, 4, 2]
   print(unsorted.sorted())
   // Output: [1, 2, 3, 4, 5]
   print(unsorted.sorted(by: >))
   // Output: [5, 4, 3, 2, 1]

 sort (in-place):
   var mutable = [5, 3, 1]
   mutable.sort()
   print(mutable)
   // Output: [1, 3, 5]

 reversed:
   let rev = [1, 2, 3].reversed()
   print(Array(rev))
   // Output: [3, 2, 1]

 min and max:
   let vals = [3, 1, 4, 1, 5, 9]
   print(vals.min() ?? 0)
   // Output: 1
   print(vals.max() ?? 0)
   // Output: 9

 first(where:) and last(where:):
   let found = vals.first { $0 > 4 }
   print(found ?? -1)
   // Output: 5

 allSatisfy and contains(where:):
   print([2, 4, 6].allSatisfy { $0 % 2 == 0 })
   // Output: true
   print([1, 2, 3].contains { $0 > 2 })
   // Output: true

 prefix and suffix:
   let arr = [1, 2, 3, 4, 5]
   print(Array(arr.prefix(3)))
   // Output: [1, 2, 3]
   print(Array(arr.suffix(2)))
   // Output: [4, 5]

 dropFirst and dropLast:
   print(Array(arr.dropFirst(2)))
   // Output: [3, 4, 5]
   print(Array(arr.dropLast(2)))
   // Output: [1, 2, 3]

 zip:
   let names = ["Alice", "Bob"]
   let scores = [95, 88]
   let zipped = zip(names, scores)
   for (name, score) in zipped {
       print("\(name): \(score)")
   }
   // Output: Alice: 95
   //         Bob: 88

 split:
   let sentence = "one two three"
   let words = sentence.split(separator: " ")
   print(words)
   // Output: ["one", "two", "three"]

 joined:
   let parts = ["Hello", "World"]
   print(parts.joined(separator: ", "))
   // Output: Hello, World

 chunked (Swift Algorithms package):
   // import Algorithms
   // let pairs = [1,2,3,4].chunks(ofCount: 2)
   // print(pairs.map { Array($0) })
   // Output: [[1, 2], [3, 4]]


 ================================================================
 ARRAY — SLICING
 ================================================================

 Slice with Range:
   let arr = [10, 20, 30, 40, 50]
   let slice = arr[1...3]
   print(slice)
   // Output: [20, 30, 40]
   print(Array(slice))
   // Output: [20, 30, 40]

 Slice from Start:
   print(Array(arr[..<3]))
   // Output: [10, 20, 30]

 Slice to End:
   print(Array(arr[2...]))
   // Output: [30, 40, 50]


 ================================================================
 ARRAY — VALUE TYPE BEHAVIOR
 ================================================================

 Arrays are Value Types:
   var original = [1, 2, 3]
   var copy = original
   copy.append(4)
   print(original)
   // Output: [1, 2, 3]
   print(copy)
   // Output: [1, 2, 3, 4]


 ================================================================
 ARRAY — SUMMARY TABLE
 ================================================================

 Operation           | Method/Syntax            | Output Type
 --------------------|--------------------------|------------------
 Create empty        | [Int]()                  | [Int]
 Create with values  | [1, 2, 3]                | [Int]
 Count               | .count                   | Int
 Is empty            | .isEmpty                 | Bool
 Access by index     | arr[0]                   | Element
 First/Last          | .first / .last           | Element?
 Append              | .append(value)           | Void
 Insert              | .insert(at:)             | Void
 Remove              | .remove(at:)             | Element
 Contains            | .contains(value)         | Bool
 Index of            | .firstIndex(of:)         | Int?
 Sort                | .sorted()                | [Element]
 Map                 | .map { }                 | [T]
 Filter              | .filter { }              | [Element]
 Reduce              | .reduce(initial) { }     | T
 FlatMap             | .flatMap { }             | [T]
 CompactMap          | .compactMap { }          | [T]
 Zip                 | zip(a, b)                | Zip2Sequence
 Reversed            | .reversed()              | ReversedCollection
 Prefix/Suffix       | .prefix(n) / .suffix(n)  | ArraySlice


 ================================================================
 PART 2 — SET
 ================================================================

 WHAT IS A SET?
 ==============
 A Set is an unordered collection of unique values.
 No duplicates are allowed.
 Elements must conform to the Hashable protocol.
 Declared using Set<Type> syntax.

 Syntax:
   var set: Set<Type> = [value1, value2, value3]
   var set: Set = [value1, value2, value3]


 ================================================================
 SET — CREATING SETS
 ================================================================

 Empty Set:
   var letters: Set<String> = []
   print(letters)
   // Output: []

   var nums = Set<Int>()
   print(nums)
   // Output: []

 Set with Values:
   var colors: Set = ["Red", "Green", "Blue"]
   print(colors)
   // Output: unordered — e.g. ["Blue", "Red", "Green"]

 Removing Duplicates Automatically:
   var nums: Set = [1, 2, 2, 3, 3, 3]
   print(nums)
   // Output: [1, 2, 3] — duplicates removed
   print(nums.count)
   // Output: 3


 ================================================================
 SET — ACCESSING AND MODIFYING
 ================================================================

 Count and isEmpty:
   var fruits: Set = ["Apple", "Mango"]
   print(fruits.count)
   // Output: 2
   print(fruits.isEmpty)
   // Output: false

 Contains:
   print(fruits.contains("Apple"))
   // Output: true
   print(fruits.contains("Grape"))
   // Output: false

 Insert:
   fruits.insert("Grape")
   print(fruits.contains("Grape"))
   // Output: true

 Insert Return Value:
   let result = fruits.insert("Apple")
   print(result.inserted)
   // Output: false (already exists)
   print(result.memberAfterInsert)
   // Output: Apple

 Remove:
   fruits.remove("Mango")
   print(fruits.contains("Mango"))
   // Output: false

 Remove (safe — returns Optional):
   let removed = fruits.remove("Pineapple")
   print(removed ?? "Not found")
   // Output: Not found

 RemoveAll:
   fruits.removeAll()
   print(fruits.isEmpty)
   // Output: true

 First (random — unordered):
   var nums: Set = [1, 2, 3]
   print(nums.first ?? 0)
   // Output: any of 1, 2, or 3 (unordered)


 ================================================================
 SET — SET OPERATIONS
 ================================================================

 Union — all elements from both sets:
   let a: Set = [1, 2, 3]
   let b: Set = [3, 4, 5]
   print(a.union(b))
   // Output: [1, 2, 3, 4, 5]

 Intersection — only elements in both:
   print(a.intersection(b))
   // Output: [3]

 Subtracting — elements in a not in b:
   print(a.subtracting(b))
   // Output: [1, 2]

 Symmetric Difference — elements in one but not both:
   print(a.symmetricDifference(b))
   // Output: [1, 2, 4, 5]

 Mutating versions:
   var c: Set = [1, 2, 3]
   c.formUnion([4, 5])
   print(c)
   // Output: [1, 2, 3, 4, 5]

   c.formIntersection([3, 4])
   print(c)
   // Output: [3, 4]

   c.subtract([4])
   print(c)
   // Output: [3]


 ================================================================
 SET — MEMBERSHIP AND EQUALITY
 ================================================================

 Subset:
   let small: Set = [1, 2]
   let large: Set = [1, 2, 3, 4]
   print(small.isSubset(of: large))
   // Output: true

 Superset:
   print(large.isSuperset(of: small))
   // Output: true

 Strict Subset (proper subset):
   print(small.isStrictSubset(of: large))
   // Output: true

   let same: Set = [1, 2]
   print(small.isStrictSubset(of: same))
   // Output: false

 Disjoint (no common elements):
   let x: Set = [1, 2]
   let y: Set = [3, 4]
   print(x.isDisjoint(with: y))
   // Output: true

   let z: Set = [2, 3]
   print(x.isDisjoint(with: z))
   // Output: false

 Equality:
   let p: Set = [1, 2, 3]
   let q: Set = [3, 1, 2]
   print(p == q)
   // Output: true


 ================================================================
 SET — ITERATING
 ================================================================

 For Loop:
   let animals: Set = ["Cat", "Dog", "Bird"]
   for animal in animals {
       print(animal)
   }
   // Output: unordered — Dog, Cat, Bird (any order)

 Sorted Iteration (predictable order):
   for animal in animals.sorted() {
       print(animal)
   }
   // Output: Bird
   //         Cat
   //         Dog


 ================================================================
 SET — VALUE TYPE BEHAVIOR
 ================================================================

 Sets are Value Types:
   var set1: Set = [1, 2, 3]
   var set2 = set1
   set2.insert(4)
   print(set1)
   // Output: [1, 2, 3]
   print(set2)
   // Output: [1, 2, 3, 4]


 ================================================================
 SET — SUMMARY TABLE
 ================================================================

 Operation           | Method/Syntax            | Output Type
 --------------------|--------------------------|------------------
 Create empty        | Set<Int>()               | Set<Int>
 Count               | .count                   | Int
 Is empty            | .isEmpty                 | Bool
 Contains            | .contains(value)         | Bool
 Insert              | .insert(value)           | (inserted: Bool, ...)
 Remove              | .remove(value)           | Element?
 Remove all          | .removeAll()             | Void
 Union               | .union(other)            | Set<T>
 Intersection        | .intersection(other)     | Set<T>
 Subtract            | .subtracting(other)      | Set<T>
 Symmetric diff      | .symmetricDifference     | Set<T>
 Is subset           | .isSubset(of:)           | Bool
 Is superset         | .isSuperset(of:)         | Bool
 Is disjoint         | .isDisjoint(with:)       | Bool
 Sorted              | .sorted()                | [Element]


 ================================================================
 PART 3 — DICTIONARY
 ================================================================

 WHAT IS A DICTIONARY?
 =====================
 A Dictionary is an unordered collection of key-value pairs.
 Keys must be unique and Hashable.
 Values are accessed by their key.
 Declared using [Key: Value] or Dictionary<Key, Value>.

 Syntax:
   var dict: [KeyType: ValueType] = [key1: value1, key2: value2]
   var dict = [key1: value1, key2: value2]


 ================================================================
 DICTIONARY — CREATING DICTIONARIES
 ================================================================

 Empty Dictionary:
   var scores: [String: Int] = [:]
   print(scores)
   // Output: [:]

   var capitals = Dictionary<String, String>()
   print(capitals)
   // Output: [:]

 Dictionary with Values:
   var ages = ["Alice": 30, "Bob": 25, "Eve": 28]
   print(ages)
   // Output: ["Alice": 30, "Bob": 25, "Eve": 28]
   // (order may vary)

 Dictionary from Arrays using zip:
   let keys = ["a", "b", "c"]
   let values = [1, 2, 3]
   let dict = Dictionary(uniqueKeysWithValues: zip(keys, values))
   print(dict)
   // Output: ["a": 1, "b": 2, "c": 3]


 ================================================================
 DICTIONARY — ACCESSING VALUES
 ================================================================

 By Key (returns Optional):
   let score = ages["Alice"]
   print(score ?? 0)
   // Output: 30

   let missing = ages["Zara"]
   print(missing ?? -1)
   // Output: -1

 Default Value Access:
   print(ages["Alice", default: 0])
   // Output: 30
   print(ages["Zara", default: 0])
   // Output: 0

 Keys and Values:
   print(ages.keys)
   // Output: ["Alice", "Bob", "Eve"] (order varies)
   print(ages.values)
   // Output: [30, 25, 28] (order varies)

 Count and isEmpty:
   print(ages.count)
   // Output: 3
   print(ages.isEmpty)
   // Output: false

 Contains Key:
   print(ages.keys.contains("Alice"))
   // Output: true

 Contains Value:
   print(ages.values.contains(30))
   // Output: true


 ================================================================
 DICTIONARY — MODIFYING DICTIONARIES
 ================================================================

 Add or Update:
   ages["Charlie"] = 22
   print(ages["Charlie"] ?? 0)
   // Output: 22

   ages["Alice"] = 31
   print(ages["Alice"] ?? 0)
   // Output: 31

 Update with Return (updateValue):
   let old = ages.updateValue(35, forKey: "Alice")
   print(old ?? 0)
   // Output: 31 (previous value)
   print(ages["Alice"] ?? 0)
   // Output: 35

 Remove by Key:
   ages["Charlie"] = nil
   print(ages["Charlie"] ?? "Removed")
   // Output: Removed

 Remove with Return:
   let removed = ages.removeValue(forKey: "Bob")
   print(removed ?? "Not found")
   // Output: 25

 Remove All:
   ages.removeAll()
   print(ages.isEmpty)
   // Output: true

 Merge Dictionaries:
   var dict1 = ["a": 1, "b": 2]
   let dict2 = ["b": 3, "c": 4]
   dict1.merge(dict2) { current, _ in current }
   print(dict1)
   // Output: ["a": 1, "b": 2, "c": 4]
   // Keeps current value for "b"

   dict1.merge(dict2) { _, new in new }
   print(dict1["b"] ?? 0)
   // Output: 3 — new value wins

 Merged (non-mutating):
   let merged = dict1.merging(dict2) { current, _ in current }
   print(merged)
   // Output: merged dictionary


 ================================================================
 DICTIONARY — ITERATING
 ================================================================

 For Loop (key-value pairs):
   let country = ["IN": "India", "US": "USA", "UK": "UK"]
   for (code, name) in country {
       print("\(code): \(name)")
   }
   // Output: unordered pairs

 Sorted by Key:
   for (code, name) in country.sorted(by: { $0.key < $1.key }) {
       print("\(code): \(name)")
   }
   // Output: IN: India
   //         UK: UK
   //         US: USA

 Iterate Keys Only:
   for key in country.keys.sorted() {
       print(key)
   }
   // Output: IN
   //         UK
   //         US

 Iterate Values Only:
   for value in country.values {
       print(value)
   }
   // Output: unordered values


 ================================================================
 DICTIONARY — HIGHER ORDER FUNCTIONS
 ================================================================

 mapValues:
   let prices = ["Apple": 1.0, "Banana": 0.5]
   let doubled = prices.mapValues { $0 * 2 }
   print(doubled)
   // Output: ["Apple": 2.0, "Banana": 1.0]

 filter:
   let expensive = prices.filter { $0.value > 0.6 }
   print(expensive)
   // Output: ["Apple": 1.0]

 compactMapValues:
   let rawPrices = ["Apple": "1.5", "Banana": "abc"]
   let parsedPrices = rawPrices.compactMapValues { Double($0) }
   print(parsedPrices)
   // Output: ["Apple": 1.5]

 reduce into Dictionary:
   let items = ["a", "b", "a", "c", "b", "a"]
   let counts = items.reduce(into: [:]) { result, item in
       result[item, default: 0] += 1
   }
   print(counts)
   // Output: ["a": 3, "b": 2, "c": 1]

 grouping with Dictionary(grouping:by:):
   let words = ["apple", "ant", "bat", "bee", "cat"]
   let grouped = Dictionary(grouping: words) { $0.first! }
   print(grouped)
   // Output: ["a": ["apple", "ant"],
   //          "b": ["bat", "bee"],
   //          "c": ["cat"]]


 ================================================================
 DICTIONARY — VALUE TYPE BEHAVIOR
 ================================================================

 Dictionaries are Value Types:
   var d1 = ["x": 1]
   var d2 = d1
   d2["y"] = 2
   print(d1)
   // Output: ["x": 1]
   print(d2)
   // Output: ["x": 1, "y": 2]


 ================================================================
 DICTIONARY — SUMMARY TABLE
 ================================================================

 Operation              | Method/Syntax              | Output Type
 -----------------------|----------------------------|------------------
 Create empty           | [String: Int]()            | Dictionary
 Access value           | dict[key]                  | Value?
 Default access         | dict[key, default: val]    | Value
 Add/Update             | dict[key] = value          | Void
 Update (return old)    | .updateValue(_:forKey:)    | Value?
 Remove by key          | dict[key] = nil            | Void
 Remove (return val)    | .removeValue(forKey:)      | Value?
 Count                  | .count                     | Int
 Is empty               | .isEmpty                   | Bool
 All keys               | .keys                      | Keys
 All values             | .values                    | Values
 Merge                  | .merge(_:uniquingWith:)     | Void
 Filter                 | .filter { }                | [Key: Value]
 Map values             | .mapValues { }             | [Key: NewValue]
 CompactMap values      | .compactMapValues { }      | [Key: NewValue]
 Group by               | Dictionary(grouping:by:)   | [Key: [Value]]
 Reduce to dict         | .reduce(into: [:]) { }     | [Key: Value]


 ================================================================
 PART 4 — RANGE
 ================================================================

 WHAT IS A RANGE?
 ================
 A Range represents a sequence of values between
 a lower and upper bound.
 Swift has several range types for different use cases.

 Range Types:
   Closed Range       a...b    includes both a and b
   Half-Open Range    a..<b    includes a, excludes b
   One-sided Range    ...b     up to b (inclusive)
   One-sided Range    a...     from a onwards
   One-sided Range    ..<b     up to b (exclusive)


 ================================================================
 RANGE — DECLARING RANGES
 ================================================================

 Closed Range (Int):
   let range = 1...5
   print(range)
   // Output: 1...5

 Half-Open Range:
   let range = 1..<5
   print(range)
   // Output: 1..<5

 Character Range:
   let letters = "a"..."z"
   print(letters.contains("m"))
   // Output: true

 Double Range:
   let temps = 36.0...37.5
   print(temps.contains(37.0))
   // Output: true


 ================================================================
 RANGE — USING RANGES
 ================================================================

 Iterate Closed Range:
   for i in 1...5 {
       print(i)
   }
   // Output: 1
   //         2
   //         3
   //         4
   //         5

 Iterate Half-Open Range:
   for i in 0..<3 {
       print(i)
   }
   // Output: 0
   //         1
   //         2

 Contains:
   let r = 1...10
   print(r.contains(5))
   // Output: true
   print(r.contains(11))
   // Output: false

 Range as Array Subscript:
   let arr = ["a", "b", "c", "d", "e"]
   print(arr[1...3])
   // Output: ["b", "c", "d"]
   print(arr[..<2])
   // Output: ["a", "b"]
   print(arr[3...])
   // Output: ["d", "e"]

 Range in Switch:
   let score = 85
   switch score {
   case 90...100: print("A")
   case 80..<90:  print("B")
   case 70..<80:  print("C")
   default:       print("F")
   }
   // Output: B

 Count of Range:
   let r = 1...10
   print(r.count)
   // Output: 10

   let r2 = 1..<10
   print(r2.count)
   // Output: 9

 Lower and Upper Bound:
   let r = 5...15
   print(r.lowerBound)
   // Output: 5
   print(r.upperBound)
   // Output: 15

 Convert Range to Array:
   let arr = Array(1...5)
   print(arr)
   // Output: [1, 2, 3, 4, 5]

 Reversed Range:
   for i in (1...5).reversed() {
       print(i)
   }
   // Output: 5
   //         4
   //         3
   //         2
   //         1

 Stride (step value):
   for i in stride(from: 0, to: 10, by: 2) {
       print(i)
   }
   // Output: 0, 2, 4, 6, 8

   for i in stride(from: 10, through: 0, by: -2) {
       print(i)
   }
   // Output: 10, 8, 6, 4, 2, 0

 Random Element from Range:
   let rand = Int.random(in: 1...100)
   print(rand)
   // Output: random Int between 1 and 100

 Clamping:
   let r = 0...100
   print(r.clamped(to: 0...50))
   // Output: 0...50

   print(r.clamped(to: -10...50))
   // Output: 0...50


 ================================================================
 RANGE — RANGE TYPES SUMMARY
 ================================================================

 Type               | Syntax | Lower | Upper | Example
 -------------------|--------|-------|-------|------------------
 ClosedRange        | a...b  | Yes   | Yes   | 1...5
 Range              | a..<b  | Yes   | No    | 1..<5
 PartialRangeThru   | ...b   | No    | Yes   | ...5
 PartialRangeUpTo   | ..<b   | No    | No    | ..<5
 PartialRangeFrom   | a...   | Yes   | No    | 1...
 CountableRange     | a..<b  | Yes   | No    | integers only


 ================================================================
 RANGE — SUMMARY TABLE
 ================================================================

 Operation           | Syntax / Method          | Output
 --------------------|--------------------------|------------------
 Closed range        | 1...5                    | ClosedRange
 Half-open range     | 1..<5                    | Range
 Contains value      | range.contains(x)        | Bool
 Lower bound         | range.lowerBound         | Bound
 Upper bound         | range.upperBound         | Bound
 Count               | range.count              | Int
 Convert to array    | Array(1...5)             | [Int]
 Reversed            | (1...5).reversed()       | ReversedCollection
 Stride step         | stride(from:to:by:)      | StrideTo
 Random in range     | Int.random(in: 1...10)   | Int
 Clamp               | .clamped(to:)            | Range
 Array slice         | arr[1...3]               | ArraySlice
 Switch matching     | case 1...5:              | Bool


 ================================================================
 PART 5 — ANY AND ANYOBJECT
 ================================================================

 WHAT IS ANY?
 ============
 Any can represent an instance of ANY type at all,
 including functions, structs, classes, and enums.
 Any is a protocol-like type alias in Swift.

 WHAT IS ANYOBJECT?
 ==================
 AnyObject can represent an instance of any CLASS type.
 Only reference types (classes) conform to AnyObject.
 Value types (struct, enum) do NOT conform to AnyObject.

 Syntax:
   var anything: Any
   var classRef: AnyObject


 ================================================================
 ANY — BASIC EXAMPLES
 ================================================================

 Storing Different Types in Any:
   var anything: Any = 42
   print(anything)
   // Output: 42

   anything = "Hello"
   print(anything)
   // Output: Hello

   anything = true
   print(anything)
   // Output: true

   anything = [1, 2, 3]
   print(anything)
   // Output: [1, 2, 3]

   anything = { print("Closure") }

 Array of Any:
   let mixed: [Any] = [1, "Swift", true, 3.14, [1, 2]]
   print(mixed)
   // Output: [1, "Swift", true, 3.14, [1, 2]]


 ================================================================
 ANY — TYPE CHECKING AND CASTING
 ================================================================

 is — Type Check:
   let val: Any = "Hello"
   print(val is String)
   // Output: true
   print(val is Int)
   // Output: false

 as? — Safe Cast:
   let val: Any = 42
   if let num = val as? Int {
       print("Int: \(num)")
   }
   // Output: Int: 42

   if let str = val as? String {
       print("String: \(str)")
   } else {
       print("Not a String")
   }
   // Output: Not a String

 as! — Force Cast (unsafe):
   let val: Any = "Swift"
   let str = val as! String
   print(str)
   // Output: Swift

   let bad = val as! Int
   // CRASH: Could not cast value of type 'String' to 'Int'

 Switch with Type Matching:
   let values: [Any] = [1, "Hello", true, 3.14, [1, 2, 3]]
   for value in values {
       switch value {
       case let i as Int:
           print("Int: \(i)")
       case let s as String:
           print("String: \(s)")
       case let b as Bool:
           print("Bool: \(b)")
       case let d as Double:
           print("Double: \(d)")
       case let a as [Int]:
           print("Array: \(a)")
       default:
           print("Unknown type")
       }
   }
   // Output:
   // Int: 1
   // String: Hello
   // Bool: true
   // Double: 3.14
   // Array: [1, 2, 3]


 ================================================================
 ANY — PRACTICAL USE CASES
 ================================================================

 Heterogeneous Array:
   let data: [Any] = [42, "Alice", true, 3.14]
   for item in data {
       if let n = item as? Int    { print("Int:    \(n)") }
       if let s = item as? String { print("String: \(s)") }
       if let b = item as? Bool   { print("Bool:   \(b)") }
       if let d = item as? Double { print("Double: \(d)") }
   }
   // Output:
   // Int:    42
   // String: Alice
   // Bool:   true
   // Double: 3.14

 Function Accepting Any:
   func describe(_ value: Any) {
       print("Type: \(type(of: value)), Value: \(value)")
   }
   describe(42)
   // Output: Type: Int, Value: 42
   describe("Swift")
   // Output: Type: String, Value: Swift

 Dictionary with Any Values:
   var config: [String: Any] = [
       "name": "Alice",
       "age": 30,
       "isAdmin": true
   ]
   if let name = config["name"] as? String {
       print(name)
   }
   // Output: Alice


 ================================================================
 ANYOBJECT — EXAMPLES
 ================================================================

 AnyObject with Classes:
   class Dog { var name = "Rex" }
   class Cat { var name = "Whiskers" }

   let animals: [AnyObject] = [Dog(), Cat()]
   for animal in animals {
       if let dog = animal as? Dog {
           print("Dog: \(dog.name)")
       } else if let cat = animal as? Cat {
           print("Cat: \(cat.name)")
       }
   }
   // Output: Dog: Rex
   //         Cat: Whiskers

 AnyObject does NOT accept structs:
   struct Point { var x = 0 }
   let p: AnyObject = Point()
   // Error: Value of type 'Point' does not conform to 'AnyObject'


 ================================================================
 ANY vs ANYOBJECT — COMPARISON
 ================================================================

 Feature              | Any                       | AnyObject
 ---------------------|---------------------------|------------------
 Accepts struct       | Yes                       | No
 Accepts class        | Yes                       | Yes
 Accepts enum         | Yes                       | No
 Accepts function     | Yes                       | No
 Accepts primitive    | Yes                       | No
 Type safety          | Low — requires casting    | Low — requires casting
 Where used           | General heterogeneous     | Objective-C APIs
 Swift vs ObjC        | Swift native              | ObjC bridging common
 Example              | var x: Any = 42           | var x: AnyObject = MyClass()


 ================================================================
 PART 6 — COLLECTION COMPARISON TABLE
 ================================================================

 Feature              | Array          | Set              | Dictionary
 ---------------------|----------------|------------------|------------------
 Order                | Ordered        | Unordered        | Unordered
 Duplicates           | Allowed        | Not allowed      | Keys unique
 Access               | By index       | No direct access | By key
 Key/Value            | No             | No               | Yes
 Hashable required    | No             | Yes (Element)    | Yes (Key)
 Null/nil values      | Optional       | Optional         | Optional values
 Best for             | Ordered lists  | Unique items     | Key-value lookup
 Mutable              | var            | var              | var
 Value type           | Yes            | Yes              | Yes
 Init syntax          | []             | Set<T>()         | [:]


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 ARRAY — INTERVIEW Q&A
 ================================================================

 --------------------------------------------------------------
 BASIC
 --------------------------------------------------------------

 Q1. What is an Array in Swift?
 --------------------------------
 A: An ordered collection of values of the same type.
    Values can repeat and are accessed by index.
    Example:
      let nums = [10, 20, 30]
      print(nums[0])
      // Output: 10


 Q2. How do you declare an empty Array?
 ----------------------------------------
 A: Several ways:
    Example:
      var a: [Int] = []
      var b = [Int]()
      var c: Array<Int> = []
      print(a.isEmpty)
      // Output: true


 Q3. How do you add elements to an Array?
 -----------------------------------------
 A: Use append, insert, or +=.
    Example:
      var arr = [1, 2]
      arr.append(3)
      arr.insert(0, at: 0)
      print(arr)
      // Output: [0, 1, 2, 3]


 Q4. How do you remove elements from an Array?
 ----------------------------------------------
 A: Use remove, removeFirst, removeLast, removeAll.
    Example:
      var arr = [1, 2, 3, 4]
      arr.remove(at: 1)
      print(arr)
      // Output: [1, 3, 4]

      arr.removeLast()
      print(arr)
      // Output: [1, 3]


 Q5. How do you check if an Array contains a value?
 ---------------------------------------------------
 A: Use contains.
    Example:
      let fruits = ["Apple", "Banana"]
      print(fruits.contains("Apple"))
      // Output: true
      print(fruits.contains("Mango"))
      // Output: false


 Q6. How do you find the index of an element?
 ---------------------------------------------
 A: Use firstIndex(of:).
    Example:
      let arr = ["a", "b", "c"]
      print(arr.firstIndex(of: "b") ?? -1)
      // Output: 1
      print(arr.firstIndex(of: "z") ?? -1)
      // Output: -1


 Q7. How do you sort an Array?
 ------------------------------
 A: Use sorted() for new array or sort() in-place.
    Example:
      let arr = [3, 1, 4, 1, 5]
      print(arr.sorted())
      // Output: [1, 1, 3, 4, 5]

      var mutable = [5, 2, 8]
      mutable.sort()
      print(mutable)
      // Output: [2, 5, 8]


 Q8. What is the difference between sort and sorted?
 ----------------------------------------------------
 A: sort — mutates the original array (needs var)
    sorted — returns a new sorted array
    Example:
      var a = [3, 1, 2]
      let b = a.sorted()
      print(a)         // Output: [3, 1, 2]
      print(b)         // Output: [1, 2, 3]
      a.sort()
      print(a)         // Output: [1, 2, 3]


 Q9. Are Arrays value types or reference types?
 -----------------------------------------------
 A: Value types. Copying an Array creates an independent copy.
    Example:
      var x = [1, 2, 3]
      var y = x
      y.append(4)
      print(x)         // Output: [1, 2, 3]
      print(y)         // Output: [1, 2, 3, 4]


 Q10. What is the difference between append and insert?
 ------------------------------------------------------
 A: append adds to the end.
    insert adds at a specific index.
    Example:
      var arr = [1, 3]
      arr.append(4)
      print(arr)        // Output: [1, 3, 4]
      arr.insert(2, at: 1)
      print(arr)        // Output: [1, 2, 3, 4]


 --------------------------------------------------------------
 INTERMEDIATE
 --------------------------------------------------------------

 Q11. What does map do on an Array?
 ------------------------------------
 A: Transforms each element and returns a new array.
    Example:
      let nums = [1, 2, 3]
      let squared = nums.map { $0 * $0 }
      print(squared)
      // Output: [1, 4, 9]


 Q12. What does filter do on an Array?
 ---------------------------------------
 A: Returns a new array with elements matching
    the given condition.
    Example:
      let nums = [1, 2, 3, 4, 5, 6]
      let odds = nums.filter { $0 % 2 != 0 }
      print(odds)
      // Output: [1, 3, 5]


 Q13. What does reduce do on an Array?
 ---------------------------------------
 A: Combines all elements into a single value.
    Example:
      let nums = [1, 2, 3, 4, 5]
      let total = nums.reduce(0, +)
      print(total)
      // Output: 15


 Q14. What is compactMap and how is it different from map?
 ----------------------------------------------------------
 A: compactMap transforms elements and removes nil results.
    Example:
      let strings = ["1", "two", "3"]
      let ints = strings.compactMap { Int($0) }
      print(ints)
      // Output: [1, 3]

      let mapped = strings.map { Int($0) }
      print(mapped)
      // Output: [Optional(1), nil, Optional(3)]


 Q15. What is flatMap on Arrays?
 ---------------------------------
 A: Transforms each element to a sequence and
    flattens the results into one array.
    Example:
      let nested = [[1, 2], [3, 4], [5]]
      let flat = nested.flatMap { $0 }
      print(flat)
      // Output: [1, 2, 3, 4, 5]


 Q16. How do you iterate with index?
 -------------------------------------
 A: Use enumerated().
    Example:
      let arr = ["a", "b", "c"]
      for (i, v) in arr.enumerated() {
          print("\(i) — \(v)")
      }
      // Output: 0 — a
      //         1 — b
      //         2 — c


 Q17. How do you check all or any elements meet a condition?
 -----------------------------------------------------------
 A: allSatisfy and contains(where:).
    Example:
      let nums = [2, 4, 6]
      print(nums.allSatisfy { $0 % 2 == 0 })
      // Output: true

      let mixed = [1, 2, 3]
      print(mixed.contains { $0 > 2 })
      // Output: true


 Q18. What does zip do with arrays?
 ------------------------------------
 A: Combines two sequences into pairs.
    Example:
      let names = ["Alice", "Bob"]
      let scores = [90, 85]
      for (n, s) in zip(names, scores) {
          print("\(n): \(s)")
      }
      // Output: Alice: 90
      //         Bob: 85


 Q19. How do you get a subarray (slice)?
 -----------------------------------------
 A: Use range subscripting.
    Example:
      let arr = [10, 20, 30, 40, 50]
      print(Array(arr[1...3]))
      // Output: [20, 30, 40]
      print(Array(arr[..<2]))
      // Output: [10, 20]
      print(Array(arr[3...]))
      // Output: [40, 50]


 Q20. What is the difference between Array and ArraySlice?
 ----------------------------------------------------------
 A: ArraySlice is a view into an existing array's storage.
    It shares memory with the original array.
    Always convert to Array when storing long-term.
    Example:
      let arr = [1, 2, 3, 4, 5]
      let slice = arr[1...3]           // ArraySlice
      let copy = Array(arr[1...3])     // Array — independent
      print(type(of: slice))
      // Output: ArraySlice<Int>
      print(type(of: copy))
      // Output: Array<Int>


 --------------------------------------------------------------
 ADVANCED
 --------------------------------------------------------------

 Q21. How do you sort an array of custom objects?
 -------------------------------------------------
 A: Use sorted(by:) with a custom comparator.
    Example:
      struct Person {
          var name: String
          var age: Int
      }
      let people = [
          Person(name: "Eve", age: 28),
          Person(name: "Alice", age: 25),
          Person(name: "Bob", age: 32)
      ]
      let sorted = people.sorted { $0.age < $1.age }
      for p in sorted { print("\(p.name): \(p.age)") }
      // Output: Alice: 25
      //         Eve: 28
      //         Bob: 32


 Q22. How do you group an Array into a Dictionary?
 --------------------------------------------------
 A: Use Dictionary(grouping:by:).
    Example:
      let words = ["ant", "apple", "bat", "bee"]
      let grouped = Dictionary(grouping: words) { $0.first! }
      print(grouped)
      // Output: ["a": ["ant", "apple"], "b": ["bat", "bee"]]


 Q23. How do you count occurrences in an Array?
 -----------------------------------------------
 A: Use reduce(into:).
    Example:
      let items = ["a", "b", "a", "c", "a", "b"]
      let counts = items.reduce(into: [:]) {
          result, item in
          result[item, default: 0] += 1
      }
      print(counts)
      // Output: ["a": 3, "b": 2, "c": 1]


 Q24. How do you remove duplicates from an Array?
 -------------------------------------------------
 A: Use a Set or reduce.
    Example:
      let arr = [1, 2, 2, 3, 3, 3]
      let unique = Array(Set(arr))
      print(unique.sorted())
      // Output: [1, 2, 3]

    Preserving order:
      var seen = Set<Int>()
      let ordered = arr.filter { seen.insert($0).inserted }
      print(ordered)
      // Output: [1, 2, 3]


 Q25. What is Copy-on-Write in Swift Arrays?
 --------------------------------------------
 A: Swift Arrays use copy-on-write (COW) optimization.
    A copy is only made when one of the copies is modified.
    Until then, they share the same underlying storage.
    Example:
      var a = [1, 2, 3]
      var b = a         // no copy yet — shared storage
      b.append(4)       // copy happens here
      print(a)          // Output: [1, 2, 3] — unaffected
      print(b)          // Output: [1, 2, 3, 4]


 Q26. How does Array memory grow when appending?
 ------------------------------------------------
 A: Swift uses an amortized doubling strategy.
    When capacity is exceeded, Array allocates roughly
    double the current capacity. This keeps the average
    cost of append at O(1).
    Example:
      var arr = [Int]()
      print(arr.capacity)   // Output: 0
      arr.append(1)
      print(arr.capacity)   // Output: 1
      arr.append(2)
      print(arr.capacity)   // Output: 2
      arr.append(3)
      print(arr.capacity)   // Output: 4


 Q27. How do you use reserveCapacity to optimize?
 -------------------------------------------------
 A: Pre-allocate memory to avoid repeated reallocation.
    Example:
      var arr = [Int]()
      arr.reserveCapacity(1000)
      for i in 0..<1000 {
          arr.append(i)
      }
      print(arr.count)
      // Output: 1000


 Q28. Can you use Array with Codable?
 --------------------------------------
 A: Yes. Arrays of Codable types are Codable.
    Example:
      struct User: Codable { var name: String }
      let users = [User(name: "Alice"), User(name: "Bob")]
      let data = try! JSONEncoder().encode(users)
      let decoded = try! JSONDecoder()
                        .decode([User].self, from: data)
      print(decoded[0].name)
      // Output: Alice


 ================================================================
 SET — INTERVIEW Q&A
 ================================================================

 --------------------------------------------------------------
 BASIC
 --------------------------------------------------------------

 Q29. What is a Set in Swift?
 ------------------------------
 A: An unordered collection of unique values.
    Elements must be Hashable.
    Example:
      var nums: Set = [1, 2, 3, 2, 1]
      print(nums)
      // Output: [1, 2, 3] (no duplicates, order varies)


 Q30. When should you use a Set over an Array?
 ----------------------------------------------
 A: When:
    - Uniqueness is required
    - Order does not matter
    - Fast contains check is needed (O(1) vs O(n))
    Example:
      var visited: Set<String> = []
      visited.insert("Page1")
      visited.insert("Page1")
      print(visited.count)
      // Output: 1


 Q31. How do you declare an empty Set?
 --------------------------------------
 A: Must use explicit type — cannot use [] alone.
    Example:
      var s: Set<Int> = []
      var s2 = Set<String>()
      print(s.isEmpty)
      // Output: true


 Q32. What protocols must a Set's element conform to?
 -----------------------------------------------------
 A: Hashable (which also requires Equatable).
    Example:
      struct ID: Hashable { var value: Int }
      var ids: Set<ID> = [ID(value: 1), ID(value: 2)]
      print(ids.count)
      // Output: 2


 Q33. How does Set perform compared to Array
      for contains check?
 ---------------------------------------------
 A: Set.contains is O(1) — hash-based lookup.
    Array.contains is O(n) — linear scan.
    For large collections requiring frequent lookups,
    Set is significantly faster.


 --------------------------------------------------------------
 INTERMEDIATE
 --------------------------------------------------------------

 Q34. What are the main Set operations?
 ----------------------------------------
 A: union, intersection, subtracting, symmetricDifference.
    Example:
      let a: Set = [1, 2, 3]
      let b: Set = [3, 4, 5]
      print(a.union(b))
      // Output: [1, 2, 3, 4, 5]
      print(a.intersection(b))
      // Output: [3]
      print(a.subtracting(b))
      // Output: [1, 2]
      print(a.symmetricDifference(b))
      // Output: [1, 2, 4, 5]


 Q35. What is the difference between union and formUnion?
 ---------------------------------------------------------
 A: union returns a new Set.
    formUnion mutates the original Set.
    Example:
      let a: Set = [1, 2]
      let b: Set = [3, 4]
      let c = a.union(b)
      print(a)    // Output: [1, 2] — unchanged
      print(c)    // Output: [1, 2, 3, 4]

      var d: Set = [1, 2]
      d.formUnion([3, 4])
      print(d)    // Output: [1, 2, 3, 4]


 Q36. What does insert return on a Set?
 ----------------------------------------
 A: A tuple (inserted: Bool, memberAfterInsert: Element).
    Example:
      var s: Set = [1, 2, 3]
      let r1 = s.insert(4)
      print(r1.inserted)
      // Output: true

      let r2 = s.insert(2)
      print(r2.inserted)
      // Output: false
      print(r2.memberAfterInsert)
      // Output: 2


 Q37. How do you check if two Sets are disjoint?
 ------------------------------------------------
 A: Use isDisjoint(with:) — returns true if no shared elements.
    Example:
      let a: Set = [1, 2]
      let b: Set = [3, 4]
      print(a.isDisjoint(with: b))
      // Output: true

      let c: Set = [2, 3]
      print(a.isDisjoint(with: c))
      // Output: false


 --------------------------------------------------------------
 ADVANCED
 --------------------------------------------------------------

 Q38. How do you make a custom type work in a Set?
 --------------------------------------------------
 A: Conform to Hashable (and Equatable).
    Example:
      struct Student: Hashable {
          var id: Int
          var name: String

          func hash(into hasher: inout Hasher) {
              hasher.combine(id)
          }
          static func == (lhs: Student,
                          rhs: Student) -> Bool {
              return lhs.id == rhs.id
          }
      }
      var students: Set<Student> = [
          Student(id: 1, name: "Alice"),
          Student(id: 1, name: "Alice Duplicate")
      ]
      print(students.count
 // Output: 1  (same id = same element, duplicate removed)


Q39. How does Set handle hash collisions?
------------------------------------------
A: Swift uses open addressing with linear probing.
When two elements hash to the same bucket,
Swift uses equality check (==) to distinguish them.
If equal — duplicate, not inserted.
If not equal — stored in a different bucket.


Q40. Can you use Set with enums?
---------------------------------
A: Yes. Enums without associated values are
automatically Hashable.
Example:
 enum Direction: Hashable {
     case north, south, east, west
 }
 var dirs: Set<Direction> = [.north, .south, .north]
 print(dirs.count)
 // Output: 2

 var all: Set<Direction> = [.north, .south,
                             .east, .west]
 print(all.contains(.east))
 // Output: true


================================================================
DICTIONARY — INTERVIEW Q&A
================================================================

--------------------------------------------------------------
BASIC
--------------------------------------------------------------

Q41. What is a Dictionary in Swift?
-------------------------------------
A: An unordered collection of key-value pairs.
Keys are unique and must be Hashable.
Values are accessed by their key.
Example:
 var capitals = ["France": "Paris", "Japan": "Tokyo"]
 print(capitals["France"] ?? "Unknown")
 // Output: Paris


Q42. How do you declare an empty Dictionary?
---------------------------------------------
A: Example:
 var d1: [String: Int] = [:]
 var d2 = Dictionary<String, Int>()
 print(d1.isEmpty)
 // Output: true


Q43. Why does Dictionary subscript return an Optional?
-------------------------------------------------------
A: Because the key may not exist.
Example:
 let dict = ["a": 1, "b": 2]
 print(dict["a"])
 // Output: Optional(1)
 print(dict["z"])
 // Output: nil


Q44. How do you safely access a Dictionary value
 with a default?
-------------------------------------------------
A: Use subscript with default parameter.
Example:
 let scores = ["Alice": 95]
 print(scores["Alice", default: 0])
 // Output: 95
 print(scores["Bob", default: 0])
 // Output: 0


Q45. How do you add a new key-value pair?
------------------------------------------
A: Assign value to a new key.
Example:
 var dict = ["a": 1]
 dict["b"] = 2
 print(dict)
 // Output: ["a": 1, "b": 2]


Q46. How do you update an existing value?
------------------------------------------
A: Reassign or use updateValue.
Example:
 var dict = ["a": 1]
 dict["a"] = 99
 print(dict["a"] ?? 0)
 // Output: 99

 let old = dict.updateValue(50, forKey: "a")
 print(old ?? 0)
 // Output: 99
 print(dict["a"] ?? 0)
 // Output: 50


Q47. How do you remove a key-value pair?
-----------------------------------------
A: Set key to nil or use removeValue.
Example:
 var dict = ["a": 1, "b": 2]
 dict["a"] = nil
 print(dict)
 // Output: ["b": 2]

 let removed = dict.removeValue(forKey: "b")
 print(removed ?? "Not found")
 // Output: 2
 print(dict.isEmpty)
 // Output: true


Q48. How do you iterate over a Dictionary?
-------------------------------------------
A: Use for-in loop with key-value tuple.
Example:
 let dict = ["x": 10, "y": 20]
 for (key, value) in dict {
     print("\(key): \(value)")
 }
 // Output: unordered — x: 10, y: 20

 for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
     print("\(key): \(value)")
 }
 // Output: x: 10
 //         y: 20


Q49. Are Dictionaries ordered in Swift?
----------------------------------------
A: No. Dictionaries are unordered.
Use sorted(by:) when order is needed.
Example:
 let d = ["b": 2, "a": 1, "c": 3]
 print(d.keys.sorted())
 // Output: ["a", "b", "c"]


Q50. Are Dictionaries value types or reference types?
------------------------------------------------------
A: Value types.
Example:
 var d1 = ["a": 1]
 var d2 = d1
 d2["b"] = 2
 print(d1)
 // Output: ["a": 1]
 print(d2)
 // Output: ["a": 1, "b": 2]


--------------------------------------------------------------
INTERMEDIATE
--------------------------------------------------------------

Q51. What does mapValues do?
------------------------------
A: Transforms the values of a Dictionary, keeping keys.
Example:
 let prices = ["Apple": 1.0, "Banana": 0.5]
 let discounted = prices.mapValues { $0 * 0.9 }
 print(discounted)
 // Output: ["Apple": 0.9, "Banana": 0.45]


Q52. What does compactMapValues do?
-------------------------------------
A: Transforms values and removes entries where
the transform returns nil.
Example:
 let raw = ["a": "10", "b": "hello", "c": "20"]
 let parsed = raw.compactMapValues { Int($0) }
 print(parsed)
 // Output: ["a": 10, "c": 20]


Q53. How do you filter a Dictionary?
--------------------------------------
A: Use filter — returns a new Dictionary.
Example:
 let scores = ["Alice": 90, "Bob": 70, "Eve": 85]
 let passing = scores.filter { $0.value >= 80 }
 print(passing)
 // Output: ["Alice": 90, "Eve": 85]


Q54. How do you merge two Dictionaries?
----------------------------------------
A: Use merge or merging with a closure to resolve conflicts.
Example:
 var d1 = ["a": 1, "b": 2]
 let d2 = ["b": 99, "c": 3]

 d1.merge(d2) { current, _ in current }
 print(d1)
 // Output: ["a": 1, "b": 2, "c": 3] — b keeps old value

 d1.merge(d2) { _, new in new }
 print(d1["b"] ?? 0)
 // Output: 99 — b takes new value


Q55. How do you group an Array into a Dictionary?
--------------------------------------------------
A: Use Dictionary(grouping:by:).
Example:
 let names = ["Alice", "Anna", "Bob", "Brian", "Eve"]
 let grouped = Dictionary(grouping: names) { $0.first! }
 print(grouped["A"] ?? [])
 // Output: ["Alice", "Anna"]
 print(grouped["B"] ?? [])
 // Output: ["Bob", "Brian"]


Q56. How do you count word frequency using a Dictionary?
---------------------------------------------------------
A: Use reduce(into:) with default value.
Example:
 let words = ["apple","banana","apple","cherry","banana","apple"]
 let freq = words.reduce(into: [:]) {
     result, word in
     result[word, default: 0] += 1
 }
 print(freq)
 // Output: ["apple": 3, "banana": 2, "cherry": 1]


Q57. How do you create a Dictionary from two Arrays?
-----------------------------------------------------
A: Use zip and Dictionary(uniqueKeysWithValues:).
Example:
 let keys = ["name", "age", "city"]
 let values: [Any] = ["Alice", 30, "NY"]
 // Note: for same-type use:
 let k = [1, 2, 3]
 let v = ["a", "b", "c"]
 let dict = Dictionary(uniqueKeysWithValues: zip(k, v))
 print(dict)
 // Output: [1: "a", 2: "b", 3: "c"]


Q58. What happens with duplicate keys in
 Dictionary(uniqueKeysWithValues:)?
-----------------------------------------------
A: It crashes at runtime with a fatal error.
Use Dictionary(_:uniquingKeysWith:) instead.
Example:
 let pairs = [(1, "a"), (1, "b"), (2, "c")]
 let dict = Dictionary(pairs) { first, _ in first }
 print(dict)
 // Output: [1: "a", 2: "c"]


--------------------------------------------------------------
ADVANCED
--------------------------------------------------------------

Q59. Can you use a custom type as a Dictionary key?
----------------------------------------------------
A: Yes. The key must conform to Hashable.
Example:
 struct Coordinate: Hashable {
     var row: Int
     var col: Int
 }
 var grid: [Coordinate: String] = [:]
 grid[Coordinate(row: 0, col: 0)] = "Start"
 grid[Coordinate(row: 1, col: 1)] = "End"
 print(grid[Coordinate(row: 0, col: 0)] ?? "?")
 // Output: Start


Q60. How does Dictionary handle hash collisions for keys?
---------------------------------------------------------
A: Dictionary uses hashing to find the bucket,
then equality (==) to confirm the key match.
If two keys hash to the same bucket but are not equal,
they are both stored (open addressing with probing).
Only identical keys (same hash AND equal) are treated
as the same key.


Q61. How do you use a nested Dictionary?
-----------------------------------------
A: Example:
 var school: [String: [String: Int]] = [:]
 school["Alice"] = ["Math": 95, "English": 88]
 school["Bob"]   = ["Math": 70, "English": 82]
 print(school["Alice"]?["Math"] ?? 0)
 // Output: 95
 print(school["Bob"]?["English"] ?? 0)
 // Output: 82


Q62. How do you safely increment a value in a Dictionary?
----------------------------------------------------------
A: Use subscript with default.
Example:
 var counts: [String: Int] = [:]
 let items = ["a", "b", "a", "a", "b", "c"]
 for item in items {
     counts[item, default: 0] += 1
 }
 print(counts)
 // Output: ["a": 3, "b": 2, "c": 1]


Q63. Can a Dictionary have Optional values?
--------------------------------------------
A: Yes. But assigning nil to a key removes it.
Use explicit Optional if you want to store nil.
Example:
 var dict: [String: Int?] = ["a": 1, "b": nil]
 print(dict["b"] ?? "missing")
 // Output: Optional(nil) — key exists, value is nil

 dict["b"] = Optional(nil)
 print(dict.keys.contains("b"))
 // Output: true — key still exists

 dict["b"] = nil as Int??
 // This removes the key entirely


Q64. How do you convert a Dictionary to sorted Arrays?
-------------------------------------------------------
A: Example:
 let d = ["banana": 2, "apple": 5, "cherry": 1]
 let sortedKeys = d.keys.sorted()
 print(sortedKeys)
 // Output: ["apple", "banana", "cherry"]

 let sortedByValue = d.sorted { $0.value < $1.value }
 print(sortedByValue.map { $0.key })
 // Output: ["cherry", "banana", "apple"]


================================================================
RANGE — INTERVIEW Q&A
================================================================

--------------------------------------------------------------
BASIC
--------------------------------------------------------------

Q65. What is a Range in Swift?
--------------------------------
A: A Range represents a sequence of values between
a lower and upper bound.
Swift has several range types for different needs.
Example:
 let r = 1...5
 print(r.contains(3))
 // Output: true


Q66. What is the difference between ... and ..<  ?
---------------------------------------------------
A: ... — Closed Range, includes both endpoints
..< — Half-Open Range, excludes upper bound
Example:
 for i in 1...3 { print(i) }
 // Output: 1, 2, 3

 for i in 1..<3 { print(i) }
 // Output: 1, 2


Q67. How do you use a Range to slice an Array?
-----------------------------------------------
A: Use subscript with a range.
Example:
 let arr = ["a", "b", "c", "d", "e"]
 print(Array(arr[1...3]))
 // Output: ["b", "c", "d"]

 print(Array(arr[..<2]))
 // Output: ["a", "b"]

 print(Array(arr[2...]))
 // Output: ["c", "d", "e"]


Q68. How do you use a Range in a switch statement?
---------------------------------------------------
A: Use case with range pattern.
Example:
 let age = 17
 switch age {
 case 0..<13:    print("Child")
 case 13..<18:   print("Teenager")
 case 18...64:   print("Adult")
 default:        print("Senior")
 }
 // Output: Teenager


Q69. How do you generate a random number in a range?
-----------------------------------------------------
A: Use Int.random(in:) or Double.random(in:).
Example:
 let rand = Int.random(in: 1...6)
 print(rand)
 // Output: random number 1 to 6

 let d = Double.random(in: 0.0..<1.0)
 print(d)
 // Output: random Double 0.0..<1.0


Q70. How do you iterate a Range in reverse?
--------------------------------------------
A: Use reversed().
Example:
 for i in (1...5).reversed() {
     print(i)
 }
 // Output: 5
 //         4
 //         3
 //         2
 //         1


--------------------------------------------------------------
INTERMEDIATE
--------------------------------------------------------------

Q71. What are one-sided ranges in Swift?
-----------------------------------------
A: Ranges with only one bound specified.
Example:
 let arr = [10, 20, 30, 40, 50]
 print(Array(arr[...2]))
 // Output: [10, 20, 30]

 print(Array(arr[2...]))
 // Output: [30, 40, 50]

 print(Array(arr[..<3]))
 // Output: [10, 20, 30]


Q72. What is stride and when do you use it?
--------------------------------------------
A: stride creates a sequence with a custom step value.
Used when you need a step other than 1.
Example:
 for i in stride(from: 0, to: 10, by: 3) {
     print(i)
 }
 // Output: 0, 3, 6, 9

 for i in stride(from: 10, through: 0, by: -2) {
     print(i)
 }
 // Output: 10, 8, 6, 4, 2, 0


Q73. What is the difference between stride(from:to:by:)
 and stride(from:through:by:)?
---------------------------------------------------------
A: to       — excludes the end value (like ..<)
through  — includes the end value (like ...)
Example:
 print(Array(stride(from: 1, to: 5, by: 1)))
 // Output: [1, 2, 3, 4]

 print(Array(stride(from: 1, through: 5, by: 1)))
 // Output: [1, 2, 3, 4, 5]


Q74. Can you use a Range with non-integer types?
-------------------------------------------------
A: Closed ranges work with any Comparable type.
But only integer ranges are iterable (CountableRange).
Example:
 let charRange = "a"..."z"
 print(charRange.contains("m"))
 // Output: true

 let tempRange = 36.0...37.5
 print(tempRange.contains(37.2))
 // Output: true

 // Cannot iterate over Double range directly
 // Use stride instead:
 for t in stride(from: 36.0, through: 37.5, by: 0.5) {
     print(t)
 }
 // Output: 36.0, 36.5, 37.0, 37.5


Q75. What is clamped(to:)?
---------------------------
A: Returns the range clamped within another range.
Useful for keeping values within valid bounds.
Example:
 let valid = 0...100
 print(valid.clamped(to: 0...50))
 // Output: 0...50

 print(valid.clamped(to: -10...120))
 // Output: 0...100

 let value = 150
 let clamped = (0...100).clamped(to: 0...100)
 print(clamped.upperBound)
 // Output: 100


--------------------------------------------------------------
ADVANCED
--------------------------------------------------------------

Q76. What are the different Range types in Swift?
--------------------------------------------------
A: ClosedRange<T>:     a...b   — both bounds included
Range<T>:           a..<b   — upper excluded
PartialRangeThru:   ...b    — upper only, included
PartialRangeUpTo:   ..<b    — upper only, excluded
PartialRangeFrom:   a...    — lower only
Example:
 let a: ClosedRange<Int>      = 1...5
 let b: Range<Int>            = 1..<5
 let c: PartialRangeThrough   = ...5
 let d: PartialRangeUpTo<Int> = ..<5
 let e: PartialRangeFrom<Int> = 1...
 print(a.contains(5))         // Output: true
 print(b.contains(5))         // Output: false


Q77. What is the difference between a CountableRange
 and Range?
-----------------------------------------------------
A: CountableRange and CountableClosedRange are typealiases
for Range<Int> and ClosedRange<Int> respectively
(since Swift 4). Integer ranges are iterable.
Non-integer ranges (Double, String) are not iterable
but can use contains.
Example:
 let intRange: CountableRange<Int> = 1..<5
 for i in intRange { print(i) }
 // Output: 1, 2, 3, 4

 // Double range — not iterable directly
 let dRange: ClosedRange<Double> = 1.0...2.0
 // for d in dRange { } // Error — not iterable


Q78. Can you use a Range with pattern matching?
------------------------------------------------
A: Yes. Use ~= operator or case in switch.
Example:
 let r = 1...10
 print(r ~= 5)
 // Output: true
 print(r ~= 11)
 // Output: false

 let x = 7
 if case 1...10 = x {
     print("In range")
 }
 // Output: In range


Q79. How do you convert a Range to an Array?
---------------------------------------------
A: Use Array() initializer.
Example:
 let arr = Array(1...5)
 print(arr)
 // Output: [1, 2, 3, 4, 5]

 let arr2 = Array(1..<5)
 print(arr2)
 // Output: [1, 2, 3, 4]

 // For step values use stride:
 let arr3 = Array(stride(from: 0, to: 10, by: 2))
 print(arr3)
 // Output: [0, 2, 4, 6, 8]


Q80. How does Range work with String indices?
----------------------------------------------
A: String uses String.Index, not Int.
You must use string-specific range operations.
Example:
 let str = "Hello, Swift"
 if let range = str.range(of: "Swift") {
     print(str[range])
     // Output: Swift
 }

 let start = str.startIndex
 let end = str.index(start, offsetBy: 5)
 print(str[start..<end])
 // Output: Hello


================================================================
ANY / ANYOBJECT — INTERVIEW Q&A
================================================================

--------------------------------------------------------------
BASIC
--------------------------------------------------------------

Q81. What is Any in Swift?
---------------------------
A: Any can represent an instance of any type —
structs, classes, enums, functions, closures.
Example:
 var val: Any = 42
 print(val)
 // Output: 42

 val = "Hello"
 print(val)
 // Output: Hello

 val = true
 print(val)
 // Output: true


Q82. What is AnyObject in Swift?
---------------------------------
A: AnyObject represents any class (reference type) instance.
Structs, enums, and primitives cannot be AnyObject.
Example:
 class MyClass {}
 let obj: AnyObject = MyClass()
 print(type(of: obj))
 // Output: MyClass


Q83. What is the difference between Any and AnyObject?
-------------------------------------------------------
A: Any    — any type (class, struct, enum, function)
AnyObject — class types only
Example:
 var a: Any = 42          // Int (struct) — OK
 var b: Any = "Hello"     // String (struct) — OK
 var c: AnyObject = MyClass()  // class — OK

 struct Point { var x = 0 }
 var d: AnyObject = Point()   // Error — struct not allowed


Q84. How do you check and cast an Any type?
--------------------------------------------
A: Use is to check, as? for safe cast, as! for force cast.
Example:
 let val: Any = "Swift"
 print(val is String)
 // Output: true

 if let s = val as? String {
     print(s.uppercased())
 }
 // Output: SWIFT


Q85. Why should you avoid overusing Any?
-----------------------------------------
A: Any bypasses Swift's type system, losing
type safety. Requires runtime casting, which
can crash or produce unexpected behavior.
Use specific types, protocols, or generics instead.
Example:
 // Avoid:
 func process(_ value: Any) { }

 // Prefer:
 func process<T: Numeric>(_ value: T) { }


--------------------------------------------------------------
INTERMEDIATE
--------------------------------------------------------------

Q86. How do you use a switch statement to handle
 multiple types stored as Any?
-------------------------------------------------
A: Use type pattern matching in switch.
Example:
 let items: [Any] = [1, "hello", 3.14, true, [1,2,3]]
 for item in items {
     switch item {
     case let i as Int:     print("Int:    \(i)")
     case let s as String:  print("String: \(s)")
     case let d as Double:  print("Double: \(d)")
     case let b as Bool:    print("Bool:   \(b)")
     case let a as [Int]:   print("Array:  \(a)")
     default:               print("Other")
     }
 }
 // Output:
 // Int:    1
 // String: hello
 // Double: 3.14
 // Bool:   true
 // Array:  [1, 2, 3]


Q87. When is Any commonly used in real Swift code?
---------------------------------------------------
A: 1. UserInfo dictionaries in Notification
2. JSON parsing before Codable
3. Objective-C API bridging
4. Heterogeneous collections
5. @objc protocols and NSObject-based APIs
Example:
 // Notification userInfo:
 let info: [AnyHashable: Any] = ["key": "value",
                                  "count": 5]
 if let key = info["key"] as? String {
     print(key)
 }
 // Output: value


Q88. What is AnyHashable?
--------------------------
A: AnyHashable is a type-erased Hashable value.
Used as Dictionary keys when multiple Hashable
types are needed in the same dictionary.
Example:
 var dict: [AnyHashable: String] = [:]
 dict[1] = "Int key"
 dict["name"] = "String key"
 print(dict[1] ?? "?")
 // Output: Int key
 print(dict["name"] ?? "?")
 // Output: String key


Q89. How does Any interact with Optional?
------------------------------------------
A: Any can hold an Optional without unwrapping it.
This can cause unexpected behavior.
Example:
 let name: String? = "Alice"
 let val: Any = name
 print(val)
 // Output: Optional("Alice")
 // Warning: Expression implicitly coerced
 //          from 'String?' to 'Any'

 // Better:
 let val2: Any = name as Any
 print(val2)
 // Output: Optional("Alice")


Q90. What is the difference between Any and Generics?
------------------------------------------------------
A: Any — resolved at runtime, type info lost, requires casting
Generics — resolved at compile time, type-safe, no casting
Example:
 // Any approach:
 func printAny(_ value: Any) {
     print(value)
 }
 printAny(42)
 // Output: 42

 // Generic approach (preferred):
 func printGeneric<T>(_ value: T) {
     print(value)
 }
 printGeneric(42)
 // Output: 42
 // Generics preserve type safety — use them over Any


--------------------------------------------------------------
ADVANCED
--------------------------------------------------------------

Q91. Can Any hold a function or closure?
-----------------------------------------
A: Yes. Functions and closures are first-class types.
Example:
 var action: Any = { print("Hello from closure") }
 if let fn = action as? () -> Void {
     fn()
 }
 // Output: Hello from closure


Q92. How does AnyObject relate to Objective-C?
-----------------------------------------------
A: AnyObject maps to Objective-C's id type.
All Objective-C objects are AnyObject in Swift.
Commonly seen in UIKit and Foundation APIs.
Example:
 // NSArray in Objective-C returns [AnyObject]
 let arr: [AnyObject] = NSArray() as [AnyObject]
 // Use as? to cast to specific Swift types


Q93. Can a protocol type be stored as Any?
-------------------------------------------
A: Yes. Any protocol type can be stored as Any.
Example:
 protocol Describable {
     var description: String { get }
 }
 struct Car: Describable {
     var description: String { "A car" }
 }
 let item: Any = Car()
 if let d = item as? Describable {
     print(d.description)
 }
 // Output: A car


Q94. How do you print the type of an Any value?
------------------------------------------------
A: Use type(of:).
Example:
 let val: Any = 3.14
 print(type(of: val))
 // Output: Double

 let val2: Any = "Swift"
 print(type(of: val2))
 // Output: String

 let val3: Any = [1, 2, 3]
 print(type(of: val3))
 // Output: Array<Int>


Q95. What is the danger of using Any in a
 heterogeneous array?
-----------------------------------------------
A: Loss of type safety, verbose casting, and
potential runtime crashes.
Example:
 let items: [Any] = [1, "two", 3.0]

 // Safe cast:
 for item in items {
     if let n = item as? Int {
         print("Int: \(n)")
     }
 }
 // Output: Int: 1

 // Force cast — dangerous:
 let n = items[1] as! Int
 // CRASH: Could not cast value of type 'String' to 'Int'


================================================================
CROSS-COLLECTION INTERVIEW QUESTIONS
================================================================

Q96. What is the difference between Array, Set and Dictionary?
---------------------------------------------------------------
A: Array   — ordered, duplicates allowed, index access
Set     — unordered, unique elements, no index
Dictionary — unordered, key-value pairs, key access
Example:
 let arr: [Int]        = [1, 2, 2, 3]      // [1,2,2,3]
 let set: Set<Int>     = [1, 2, 2, 3]      // {1,2,3}
 let dict: [String:Int]= ["a":1, "b":2]    // key:value


Q97. When should you choose each collection type?
--------------------------------------------------
A: Array:       ordered data, index access, duplicates OK
Set:         uniqueness required, fast lookup, no order
Dictionary:  key-value mapping, fast key lookup
Example:
 var cart = ["Apple", "Banana", "Apple"]  // Array
 var visited: Set<String> = ["Home"]       // Set
 var config = ["theme": "dark"]            // Dictionary


Q98. What are the time complexities of common operations?
---------------------------------------------------------
A: Operation     | Array  | Set    | Dictionary
-------------|--------|--------|------------
Access       | O(1)   | O(1)   | O(1)
Contains     | O(n)   | O(1)   | O(1)
Insert       | O(1)*  | O(1)   | O(1)
Remove       | O(n)   | O(1)   | O(1)
Search       | O(n)   | O(1)   | O(1)
Sort         | O(nlogn)| N/A   | N/A
* O(n) when inserting at beginning


Q99. How do you convert between Array and Set?
-----------------------------------------------
A: Array to Set:
 let arr = [1, 2, 2, 3]
 let set = Set(arr)
 print(set)
 // Output: [1, 2, 3]

Set to Array:
 let set2: Set = [3, 1, 2]
 let arr2 = Array(set2)
 print(arr2.sorted())
 // Output: [1, 2, 3]


Q100. How do you convert an Array to a Dictionary?
---------------------------------------------------
A: Use reduce(into:) or Dictionary(uniqueKeysWithValues:).
Example:
 let fruits = ["apple", "banana", "cherry"]
 let lengths = Dictionary(uniqueKeysWithValues:
     fruits.map { ($0, $0.count) })
 print(lengths)
 // Output: ["apple": 5, "banana": 6, "cherry": 6]

 // Or reduce:
 let d = fruits.reduce(into: [:]) {
     result, f in
     result[f] = f.count
 }
 print(d)
 // Output: ["apple": 5, "banana": 6, "cherry": 6]


Q101. How do all Swift collections handle
  Copy-on-Write (COW)?
-----------------------------------------------
A: Array, Set, and Dictionary all use COW.
A copy is only made when a mutation occurs on
a copied collection. Until then, they share storage.
Example:
 var a = [1, 2, 3]
 var b = a              // Shared storage — no copy
 b.append(4)            // Copy happens NOW
 print(a)               // Output: [1, 2, 3]
 print(b)               // Output: [1, 2, 3, 4]

 var s1: Set = [1, 2]
 var s2 = s1            // Shared storage
 s2.insert(3)           // Copy happens NOW
 print(s1)              // Output: [1, 2]
 print(s2)              // Output: [1, 2, 3]


Q102. How do you use compactMap vs flatMap vs map?
---------------------------------------------------
A: map       — 1-to-1 transform, keeps count
compactMap — transform + remove nils, count may reduce
flatMap    — transform + flatten nested sequences
Example:
 let nums: [Int?] = [1, nil, 3, nil, 5]
 print(nums.map { $0 })
 // Output: [Optional(1), nil, Optional(3), nil, Optional(5)]

 print(nums.compactMap { $0 })
 // Output: [1, 3, 5]

 let nested = [[1, 2], [3, 4]]
 print(nested.flatMap { $0 })
 // Output: [1, 2, 3, 4]


Q103. How do you use higher-order functions together?
------------------------------------------------------
A: Chain them for powerful transformations.
Example:
 let data = ["Alice:90", "Bob:70", "Eve:85", "Zara:92"]
 let top = data
     .compactMap { entry -> (String, Int)? in
         let parts = entry.split(separator: ":")
         guard parts.count == 2,
               let score = Int(parts[1]) else {
             return nil
         }
         return (String(parts[0]), score)
     }
     .filter { $0.1 >= 80 }
     .sorted { $0.1 > $1.1 }
     .map { "\($0.0): \($0.1)" }
 print(top)
 // Output: ["Zara: 92", "Alice: 90", "Eve: 85"]


Q104. How do you safely access nested Dictionary values?
---------------------------------------------------------
A: Use optional chaining and as?.
Example:
 let data: [String: Any] = [
     "user": [
         "name": "Alice",
         "age": 30
     ]
 ]
 if let user = data["user"] as? [String: Any],
    let name = user["name"] as? String {
     print(name)
 }
 // Output: Alice


Q105. How do you find common elements between
  two Arrays?
-----------------------------------------------
A: Convert to Set and intersect.
Example:
 let a = [1, 2, 3, 4, 5]
 let b = [3, 4, 5, 6, 7]
 let common = Set(a).intersection(Set(b))
 print(common.sorted())
 // Output: [3, 4, 5]


================================================================
COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

ARRAY
Task                          | Code
------------------------------|------------------------------------------
Create                        | var arr = [1, 2, 3]
Create empty                  | var arr = [Int]()
Append                        | arr.append(4)
Insert                        | arr.insert(0, at: 0)
Remove at index               | arr.remove(at: 0)
Remove last                   | arr.removeLast()
Access by index               | arr[0]
First / Last (Optional)       | arr.first / arr.last
Count                         | arr.count
Is empty                      | arr.isEmpty
Contains                      | arr.contains(x)
Index of                      | arr.firstIndex(of: x)
Sort new                      | arr.sorted()
Sort in-place                 | arr.sort()
Reverse                       | arr.reversed()
Map                           | arr.map { }
Filter                        | arr.filter { }
Reduce                        | arr.reduce(0, +)
CompactMap                    | arr.compactMap { }
FlatMap                       | arr.flatMap { }
Enumerate                     | arr.enumerated()
Zip two arrays                | zip(a, b)
Slice                         | Array(arr[1...3])
Join with separator           | arr.joined(separator: ",")
Group into Dictionary         | Dictionary(grouping: arr) { }
Remove duplicates             | Array(Set(arr))
Count occurrences             | arr.reduce(into: [:]) { $0[$1, default: 0] += 1 }

SET
Task                          | Code
------------------------------|------------------------------------------
Create                        | var s: Set = [1, 2, 3]
Create empty                  | var s = Set<Int>()
Insert                        | s.insert(4)
Remove                        | s.remove(4)
Contains                      | s.contains(2)
Count                         | s.count
Union                         | s.union(other)
Intersection                  | s.intersection(other)
Subtract                      | s.subtracting(other)
Symmetric diff                | s.symmetricDifference(other)
Is subset                     | s.isSubset(of: other)
Is superset                   | s.isSuperset(of: other)
Is disjoint                   | s.isDisjoint(with: other)
Sorted iteration              | s.sorted()
Convert to Array              | Array(s)

DICTIONARY
Task                          | Code
------------------------------|------------------------------------------
Create                        | var d = ["a": 1]
Create empty                  | var d = [String: Int]()
Access value                  | d["key"]        → Optional
Default access                | d["key", default: 0]
Add / Update                  | d["key"] = value
Update return old             | d.updateValue(v, forKey: k)
Remove key                    | d["key"] = nil
Remove return value           | d.removeValue(forKey: k)
Count                         | d.count
Iterate                       | for (k, v) in d
Keys                          | d.keys
Values                        | d.values
Filter                        | d.filter { $0.value > 5 }
Map values                    | d.mapValues { $0 * 2 }
CompactMap values             | d.compactMapValues { Int($0) }
Merge                         | d.merge(other) { cur, _ in cur }
Group array                   | Dictionary(grouping: arr) { }
Build from arrays             | Dictionary(uniqueKeysWithValues: zip(k,v))
Word frequency                | reduce(into: [:]) { $0[$1, default: 0] += 1 }

RANGE
Task                          | Code
------------------------------|------------------------------------------
Closed range                  | 1...5
Half-open range               | 1..<5
Partial from                  | 1...
Partial thru                  | ...5
Partial up to                 | ..<5
Contains value                | range.contains(3)
Lower bound                   | range.lowerBound
Upper bound                   | range.upperBound
Count                         | range.count
Convert to Array              | Array(1...5)
Reverse iterate               | (1...5).reversed()
Stride with step              | stride(from: 0, to: 10, by: 2)
Random in range               | Int.random(in: 1...10)
Clamp                         | range.clamped(to: 0...100)
Array slice                   | arr[1...3]
Switch matching               | case 1...5:
Pattern match                 | range ~= value

ANY / ANYOBJECT
Task                          | Code
------------------------------|------------------------------------------
Declare Any                   | var x: Any = 42
Declare AnyObject             | var x: AnyObject = MyClass()
Type check                    | x is String
Safe cast                     | x as? String
Force cast (unsafe)           | x as! String
Print type                    | type(of: x)
Switch on type                | switch x { case let s as String: }
AnyHashable key in Dict       | var d: [AnyHashable: Any] = [:]
Mixed array                   | let arr: [Any] = [1, "two", 3.0]
Filter nils from Any array    | arr.compactMap { $0 as? Int }

 */
