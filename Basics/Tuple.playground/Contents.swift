import Foundation

/*
 TUPLES IN SWIFT — COMPLETE GUIDE + INTERVIEW Q&A
 =================================================


 WHAT IS A TUPLE?
 ================
 A Tuple is a lightweight way to group multiple values
 into a single compound value. The values can be of
 different types and do not need to be the same type.

 Syntax:
   let tuple = (value1, value2, value3)


 BASIC EXAMPLES
 ==============

 Simple Tuple:
   let person = ("Alice", 30)
   print(person.0)   // Alice
   print(person.1)   // 30

 Named Tuple:
   let person = (name: "Alice", age: 30)
   print(person.name)   // Alice
   print(person.age)    // 30

 Decomposing a Tuple:
   let (name, age) = ("Alice", 30)
   print(name)   // Alice
   print(age)    // 30

 Ignoring a value with _:
   let (name, _) = ("Alice", 30)
   print(name)   // Alice


 COMMON USES OF TUPLES
 =====================

 1. Returning Multiple Values from a Function
    ------------------------------------------
    func getMinMax(arr: [Int]) -> (min: Int, max: Int) {
        return (arr.min()!, arr.max()!)
    }
    let result = getMinMax(arr: [3, 1, 8, 2])
    print(result.min)   // 1
    print(result.max)   // 8

 2. Swapping Values
    ----------------
    var a = 5
    var b = 10
    (a, b) = (b, a)
    print(a)   // 10
    print(b)   // 5

 3. Using Tuples in Switch Statements
    ------------------------------------
    let point = (2, 0)
    switch point {
    case (0, 0): print("Origin")
    case (_, 0): print("On X-axis")
    case (0, _): print("On Y-axis")
    default:     print("Somewhere else")
    }
    // Output: On X-axis

 4. Using Tuples as Dictionary Keys (Hashable workaround)
    -------------------------------------------------------
    // Tuples are not directly Hashable, but you can use
    // a struct instead. Tuples work well for temporary grouping.

 5. HTTP Response Handling
    -----------------------
    func fetchData() -> (statusCode: Int, message: String) {
        return (200, "Success")
    }
    let response = fetchData()
    print(response.statusCode)   // 200
    print(response.message)      // Success

 6. Grouping Related Data Temporarily
    ------------------------------------
    let coordinates = (latitude: 37.7749, longitude: -122.4194)
    print(coordinates.latitude)    // 37.7749
    print(coordinates.longitude)   // -122.4194

 7. Tuple in a Loop
    -----------------
    let employees = [("Alice", 50000), ("Bob", 60000)]
    for (name, salary) in employees {
        print("\(name) earns \(salary)")
    }
    // Alice earns 50000
    // Bob earns 60000

 8. Comparing Tuples
    ------------------
    // Swift can compare tuples with up to 6 elements
    let t1 = (1, "apple")
    let t2 = (1, "banana")
    print(t1 < t2)   // true (compares element by element)

 9. Optional Tuple Return
    -----------------------
    func divide(_ a: Int, _ b: Int) -> (result: Int, remainder: Int)? {
        guard b != 0 else { return nil }
        return (a / b, a % b)
    }
    if let answer = divide(10, 3) {
        print("Result: \(answer.result), Remainder: \(answer.remainder)")
    }
    // Result: 3, Remainder: 1

 10. Tuple as a Lightweight Model (Temporary)
     ------------------------------------------
     let userProfile = (id: 101, name: "Alice", isAdmin: true)
     print(userProfile.isAdmin)   // true


 TUPLE TYPE ALIAS
 ================
 typealias HTTPResponse = (statusCode: Int, body: String)

 func getResponse() -> HTTPResponse {
     return (200, "OK")
 }
 let res = getResponse()
 print(res.statusCode)   // 200
 print(res.body)         // OK


 LIMITATIONS OF TUPLES
 =====================
 - Cannot conform to protocols
 - Not Hashable (cannot be used as Dictionary keys directly)
 - Not suitable for complex or reusable data models
 - No methods or computed properties
 - Best for temporary, lightweight grouping only
 - Use struct or class for anything more complex


 TUPLE vs STRUCT
 ===============

 Feature              | Tuple                    | Struct
 ---------------------|--------------------------|---------------------------
 Syntax               | Lightweight, inline      | Formal declaration needed
 Conformance          | No protocol support      | Full protocol support
 Reusability          | Low                      | High
 Named properties     | Optional                 | Always named
 Methods              | Not supported            | Supported
 Hashable             | No                       | Yes (with Hashable)
 Best for             | Temporary grouping       | Reusable data models


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS
 ================================================================

 Q1. What is a Tuple in Swift?
 ------------------------------
 A: A Tuple is a compound value that groups multiple values
    of different or same types into a single unit.
    Example:
      let user = (name: "Alice", age: 30)


 Q2. How do you access elements of a Tuple?
 --------------------------------------------
 A: By index or by name (if named).
    Example:
      let t = (name: "Bob", age: 25)
      print(t.0)      // Bob
      print(t.name)   // Bob
      print(t.1)      // 25
      print(t.age)    // 25


 Q3. Can a Tuple hold different data types?
 -------------------------------------------
 A: Yes. Tuples can hold any combination of types.
    Example:
      let mixed = (42, "Hello", true, 3.14)


 Q4. How are Tuples different from Arrays?
 ------------------------------------------
 A: Arrays hold values of the same type and are ordered
    collections. Tuples hold a fixed number of values
    that can be of different types.
    Array:  [1, 2, 3]          — same type, variable size
    Tuple:  (1, "hello", true) — mixed types, fixed size


 Q5. What is Tuple decomposition?
 ----------------------------------
 A: Breaking a Tuple into individual constants or variables.
    Example:
      let (city, population) = ("New York", 8_000_000)
      print(city)        // New York
      print(population)  // 8000000


 Q6. How do you ignore a value in a Tuple?
 -------------------------------------------
 A: Use underscore _ to skip a value.
    Example:
      let (_, population) = ("New York", 8_000_000)
      print(population)   // 8000000


 Q7. Can you return a Tuple from a function?
 ---------------------------------------------
 A: Yes. This is one of the most common uses of Tuples.
    Example:
      func getUserInfo() -> (String, Int) {
          return ("Alice", 30)
      }
      let info = getUserInfo()
      print(info.0)   // Alice
      print(info.1)   // 30


 Q8. Are Tuples value types or reference types in Swift?
 --------------------------------------------------------
 A: Tuples are VALUE TYPES in Swift. They are copied
    when assigned to a new variable or passed to a function.
    Example:
      var t1 = (x: 1, y: 2)
      var t2 = t1
      t2.x = 99
      print(t1.x)   // 1 — t1 is not affected


 Q9. Can Tuples be compared in Swift?
 --------------------------------------
 A: Yes, but only if all elements are Comparable and the
    Tuple has 6 or fewer elements. Comparison is done
    element by element from left to right.
    Example:
      print((1, "apple") < (2, "apple"))   // true
      print((1, "banana") < (1, "cherry")) // true


 Q10. Can Tuples conform to protocols?
 ---------------------------------------
 A: No. Tuples cannot conform to protocols like Hashable,
    Equatable, or Codable. For such requirements,
    use a struct instead.


 Q11. What is a named Tuple and why use it?
 -------------------------------------------
 A: A named Tuple assigns labels to each element,
    making code more readable.
    Example:
      let response = (statusCode: 200, message: "OK")
      print(response.statusCode)   // 200
      print(response.message)      // OK


 Q12. Can you use a Tuple as a Dictionary key?
 ----------------------------------------------
 A: No. Tuples are not Hashable, so they cannot be used
    directly as Dictionary keys. Use a struct conforming
    to Hashable instead.


 Q13. What is a typealias for a Tuple and when is it useful?
 ------------------------------------------------------------
 A: typealias gives a Tuple type a reusable name,
    improving readability across a codebase.
    Example:
      typealias Coordinate = (lat: Double, lon: Double)
      let location: Coordinate = (37.7749, -122.4194)
      print(location.lat)   // 37.7749


 Q14. How do Tuples work in a switch statement?
 -----------------------------------------------
 A: Switch can match against Tuple patterns, including
    wildcard _ matching.
    Example:
      let status = (200, "OK")
      switch status {
      case (200, _):         print("Success")
      case (404, _):         print("Not Found")
      case (500, let msg):   print("Server Error: \(msg)")
      default:               print("Unknown")
      }
      // Output: Success


 Q15. When should you use a Tuple vs a Struct?
 ----------------------------------------------
 A: Use Tuple when:
      - Grouping a small number of values temporarily
      - Returning multiple values from a function
      - No need for reuse, methods, or protocol conformance

    Use Struct when:
      - Data model is reused across the codebase
      - You need methods, computed properties
      - You need protocol conformance (Codable, Hashable)
      - More than 3-4 related properties


 Q16. Can you have a Tuple inside a Tuple?
 ------------------------------------------
 A: Yes. Tuples can be nested.
    Example:
      let nested = ((1, 2), (3, 4))
      print(nested.0.0)   // 1
      print(nested.1.1)   // 4


 Q17. Can you mutate a Tuple element?
 --------------------------------------
 A: Yes, if the Tuple is declared with var.
    Example:
      var point = (x: 0, y: 0)
      point.x = 10
      print(point.x)   // 10

    Not allowed with let:
      let point = (x: 0, y: 0)
      point.x = 10   // Error — cannot mutate a let Tuple


 Q18. Can Tuples be used in arrays?
 ------------------------------------
 A: Yes. Arrays can hold Tuples.
    Example:
      let points = [(x: 1, y: 2), (x: 3, y: 4)]
      for p in points {
          print("x: \(p.x), y: \(p.y)")
      }
      // x: 1, y: 2
      // x: 3, y: 4


 ================================================================
 QUICK CHEAT SHEET
 ================================================================

 Task                          | Code
 ------------------------------|------------------------------------
 Create Tuple                  | let t = (1, "hello")
 Named Tuple                   | let t = (id: 1, name: "Alice")
 Access by index               | t.0, t.1
 Access by name                | t.id, t.name
 Decompose                     | let (a, b) = t
 Ignore element                | let (a, _) = t
 Return from function          | func f() -> (Int, String)
 Swap variables                | (a, b) = (b, a)
 Typealias                     | typealias Point = (x: Int, y: Int)
 Nested Tuple                  | let n = ((1, 2), (3, 4))
 Compare Tuples                | (1, "a") < (2, "b")
 Tuple in switch               | switch (x, y) { case (0, 0): ... }
 */
