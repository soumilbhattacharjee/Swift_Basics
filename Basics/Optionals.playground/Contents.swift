import UIKit

/*
 OPTIONALS IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — WHAT IS AN OPTIONAL?
 ================================================================

 WHAT IS AN OPTIONAL?
 ====================
 An Optional is a type in Swift that can hold either
 a value OR no value at all (nil).
 It is Swift's safe way of handling the absence of a value.
 Declared by adding ? after the type.

 Syntax:
   var name: String?       // Optional String — can be nil
   var age: Int? = 25      // Optional Int with value

 Without Optional:
   var name: String        // Must always have a value

 With Optional:
   var name: String?       // Can have a value or be nil


 WHY OPTIONALS EXIST
 ====================
 In many languages, null/nil can be assigned to any variable,
 causing crashes. Swift forces you to handle the nil case
 explicitly, making code safer and crash-resistant.


 VISUAL REPRESENTATION
 ======================
 Optional is like a box:
   - Box with something inside = has a value
   - Empty box                 = nil

   Optional<String>
   ┌─────────────┐     ┌─────────────┐
   │  "Alice"    │  or │    nil      │
   └─────────────┘     └─────────────┘


 ================================================================
 PART 2 — DECLARING OPTIONALS
 ================================================================

 EXAMPLES
 ========

 Optional with no value (nil by default):
   var nickname: String?
   print(nickname)
   // Output: nil

 Optional with a value:
   var nickname: String? = "Ace"
   print(nickname)
   // Output: Optional("Ace")

 Optional Int:
   var score: Int? = 99
   print(score)
   // Output: Optional(99)

 Setting Optional back to nil:
   var score: Int? = 99
   score = nil
   print(score)
   // Output: nil

 Non-Optional for comparison:
   var count: Int = 0
   // count = nil   // Error: Non-optional cannot be nil


 ================================================================
 PART 3 — UNWRAPPING OPTIONALS
 ================================================================

 To use the value inside an Optional, you must UNWRAP it.
 There are several ways to do this.


 ----------------------------------------------------------
 METHOD 1 — FORCE UNWRAPPING ( ! )
 ----------------------------------------------------------
 Forcefully extracts the value using !
 WARNING: Crashes at runtime if the value is nil

   var name: String? = "Alice"
   print(name!)
   // Output: Alice

   var empty: String? = nil
   print(empty!)
   // CRASH: Fatal error — unexpectedly found nil while unwrapping


 WHEN TO USE:
   Only when you are 100% certain the value is not nil.
   Avoid in production code when possible.


 ----------------------------------------------------------
 METHOD 2 — OPTIONAL BINDING (if let)
 ----------------------------------------------------------
 Safely unwraps an Optional. If it has a value,
 the value is bound to a constant inside the if block.

   var username: String? = "Alice"

   if let name = username {
       print("Hello, \(name)")
   } else {
       print("No username found")
   }
   // Output: Hello, Alice

   var username2: String? = nil

   if let name = username2 {
       print("Hello, \(name)")
   } else {
       print("No username found")
   }
   // Output: No username found


 SHORTHAND (Swift 5.7+):
   if let username {
       print("Hello, \(username)")
   }
   // Same as: if let username = username


 ----------------------------------------------------------
 METHOD 3 — OPTIONAL BINDING (guard let)
 ----------------------------------------------------------
 Unwraps an Optional early. If nil, exits the current scope.
 The unwrapped value is available after the guard statement.

   func greetUser(name: String?) {
       guard let unwrapped = name else {
           print("No name provided")
           return
       }
       print("Hello, \(unwrapped)")
   }

   greetUser(name: "Bob")
   // Output: Hello, Bob

   greetUser(name: nil)
   // Output: No name provided


 KEY DIFFERENCE — if let vs guard let:
   if let    — unwrapped value lives only inside the if block
   guard let — unwrapped value is available after the guard block


 ----------------------------------------------------------
 METHOD 4 — NIL COALESCING OPERATOR ( ?? )
 ----------------------------------------------------------
 Provides a default value if the Optional is nil.

 Syntax:
   optionalValue ?? defaultValue

   var displayName: String? = nil
   let name = displayName ?? "Guest"
   print(name)
   // Output: Guest

   var displayName2: String? = "Alice"
   let name2 = displayName2 ?? "Guest"
   print(name2)
   // Output: Alice

 Chaining ?? :
   var a: String? = nil
   var b: String? = nil
   var c: String? = "Found"
   print(a ?? b ?? c ?? "Default")
   // Output: Found


 ----------------------------------------------------------
 METHOD 5 — OPTIONAL CHAINING ( ?. )
 ----------------------------------------------------------
 Safely calls properties, methods, or subscripts
 on an Optional. If the Optional is nil, the whole
 chain returns nil instead of crashing.

 Syntax:
   optionalValue?.property
   optionalValue?.method()

   var name: String? = "alice"
   print(name?.uppercased())
   // Output: Optional("ALICE")

   var name2: String? = nil
   print(name2?.uppercased())
   // Output: nil

   // Combined with ?? for clean output:
   print(name2?.uppercased() ?? "No name")
   // Output: No name


 OPTIONAL CHAINING ON OBJECTS:
   class Address {
       var city = "New York"
   }
   class Person {
       var address: Address?
   }

   let person = Person()
   print(person.address?.city)
   // Output: nil

   person.address = Address()
   print(person.address?.city)
   // Output: Optional("New York")

   print(person.address?.city ?? "Unknown")
   // Output: New York


 ----------------------------------------------------------
 METHOD 6 — IMPLICITLY UNWRAPPED OPTIONALS ( ! after type )
 ----------------------------------------------------------
 Declared with ! instead of ?
 Automatically unwrapped when accessed.
 Used when a value is guaranteed to exist after initial setup.

   var label: String! = "Hello"
   print(label)
   // Output: Hello   (no Optional wrapper shown)

   var label2: String! = nil
   print(label2)
   // CRASH: Fatal error — unexpectedly found nil

 COMMON USE CASE:
   IBOutlets in UIKit are implicitly unwrapped:
   @IBOutlet weak var titleLabel: UILabel!


 ----------------------------------------------------------
 METHOD 7 — OPTIONAL PATTERN MATCHING (switch / if case)
 ----------------------------------------------------------
   let value: Int? = 42

   switch value {
   case .some(let v):
       print("Value is \(v)")
   case .none:
       print("No value")
   }
   // Output: Value is 42

   if case .some(let v) = value {
       print("Got \(v)")
   }
   // Output: Got 42


 ================================================================
 PART 4 — OPTIONAL TYPES IN DETAIL
 ================================================================

 HOW OPTIONALS WORK INTERNALLY
 ==============================
 An Optional in Swift is actually an enum under the hood:

   enum Optional<Wrapped> {
       case none           // represents nil
       case some(Wrapped)  // represents a value
   }

   var name: String? = "Alice"
   // Is equivalent to:
   var name: Optional<String> = .some("Alice")

   var empty: String? = nil
   // Is equivalent to:
   var empty: Optional<String> = .none


 OPTIONAL IN PRINT OUTPUT
 =========================
 When you print an Optional directly, Swift wraps
 the value in Optional():

   var x: Int? = 10
   print(x)          // Output: Optional(10)
   print(x!)         // Output: 10
   print(x ?? 0)     // Output: 10


 ================================================================
 PART 5 — OPTIONAL CHAINING DEEP DIVE
 ================================================================

 CHAINING MULTIPLE LEVELS
 =========================
   class Engine {
       var horsepower = 200
   }
   class Car {
       var engine: Engine?
   }
   class Garage {
       var car: Car?
   }

   let garage = Garage()
   print(garage.car?.engine?.horsepower)
   // Output: nil

   garage.car = Car()
   garage.car?.engine = Engine()
   print(garage.car?.engine?.horsepower)
   // Output: Optional(200)

   print(garage.car?.engine?.horsepower ?? 0)
   // Output: 200


 CALLING METHODS VIA OPTIONAL CHAINING
 =======================================
   var numbers: [Int]? = [3, 1, 4, 1, 5]
   print(numbers?.sorted())
   // Output: Optional([1, 1, 3, 4, 5])

   var numbers2: [Int]? = nil
   print(numbers2?.sorted())
   // Output: nil


 ================================================================
 PART 6 — MULTIPLE OPTIONAL BINDING
 ================================================================

 BINDING MULTIPLE OPTIONALS IN ONE if let
 =========================================
   var firstName: String? = "Alice"
   var lastName: String? = "Smith"

   if let first = firstName, let last = lastName {
       print("\(first) \(last)")
   }
   // Output: Alice Smith

   var firstName2: String? = "Alice"
   var lastName2: String? = nil

   if let first = firstName2, let last = lastName2 {
       print("\(first) \(last)")
   } else {
       print("Missing name info")
   }
   // Output: Missing name info


 COMBINING OPTIONAL BINDING WITH A CONDITION
 ============================================
   var age: Int? = 20

   if let a = age, a >= 18 {
       print("Access granted — age is \(a)")
   } else {
       print("Access denied")
   }
   // Output: Access granted — age is 20

   var age2: Int? = 15

   if let a = age2, a >= 18 {
       print("Access granted — age is \(a)")
   } else {
       print("Access denied")
   }
   // Output: Access denied


 ================================================================
 PART 7 — OPTIONAL FUNCTIONS AND RETURN TYPES
 ================================================================

 FUNCTION RETURNING AN OPTIONAL
 ================================
   func findUser(id: Int) -> String? {
       let users = [1: "Alice", 2: "Bob"]
       return users[id]
   }

   print(findUser(id: 1))
   // Output: Optional("Alice")

   print(findUser(id: 99))
   // Output: nil

   if let user = findUser(id: 2) {
       print("Found: \(user)")
   }
   // Output: Found: Bob


 OPTIONAL PARAMETERS
 ====================
   func greet(name: String?) {
       print("Hello, \(name ?? "Stranger")")
   }

   greet(name: "Alice")
   // Output: Hello, Alice

   greet(name: nil)
   // Output: Hello, Stranger


 ================================================================
 PART 8 — OPTIONAL MAP AND FLATMAP
 ================================================================

 map ON OPTIONAL
 ================
 Transforms the value inside an Optional if it exists.
 If nil, returns nil.

   let number: Int? = 5
   let doubled = number.map { $0 * 2 }
   print(doubled)
   // Output: Optional(10)

   let empty: Int? = nil
   let result = empty.map { $0 * 2 }
   print(result)
   // Output: nil


 flatMap ON OPTIONAL
 ====================
 Used when the transform itself returns an Optional.
 Prevents double-wrapping (Optional(Optional(value))).

   let str: String? = "123"
   let number = str.flatMap { Int($0) }
   print(number)
   // Output: Optional(123)

   let str2: String? = "abc"
   let number2 = str2.flatMap { Int($0) }
   print(number2)
   // Output: nil


 ================================================================
 PART 9 — COMMON OPTIONAL PATTERNS
 ================================================================

 PATTERN 1 — Try to convert String to Int safely:
   let input = "42"
   if let number = Int(input) {
       print("Converted: \(number)")
   } else {
       print("Conversion failed")
   }
   // Output: Converted: 42

 PATTERN 2 — Safe Dictionary lookup:
   let scores = ["Alice": 95, "Bob": 88]
   if let score = scores["Alice"] {
       print("Score: \(score)")
   }
   // Output: Score: 95

 PATTERN 3 — API response handling:
   func getStatusMessage(code: Int) -> String? {
       let messages = [200: "OK", 404: "Not Found", 500: "Error"]
       return messages[code]
   }
   print(getStatusMessage(code: 200) ?? "Unknown status")
   // Output: OK

   print(getStatusMessage(code: 301) ?? "Unknown status")
   // Output: Unknown status

 PATTERN 4 — Chained Optional operations:
   let input: String? = "  Hello World  "
   let result = input?.trimmingCharacters(in: .whitespaces)
                      .lowercased()
   print(result ?? "no input")
   // Output: hello world

 PATTERN 5 — Assigning Optional via nil coalescing:
   var savedName: String? = nil
   var displayName = savedName ?? "Anonymous"
   print(displayName)
   // Output: Anonymous


 ================================================================
 PART 10 — OPTIONAL SUMMARY TABLE
 ================================================================

 Method               | Symbol | Safe? | Returns          | Use When
 ---------------------|--------|-------|------------------|----------------------------
 Force Unwrap         | !      | No    | Value or crash   | Certain value exists
 Optional Binding     | if let | Yes   | Value or skip    | Need value in a block
 Guard Let            | guard  | Yes   | Value or exit    | Early exit pattern
 Nil Coalescing       | ??     | Yes   | Value or default | Need fallback value
 Optional Chaining    | ?.     | Yes   | Value or nil     | Chained property access
 Implicit Unwrap      | !type  | No    | Auto unwrapped   | IBOutlets, post-init setup
 Pattern Matching     | switch | Yes   | Matched case     | Exhaustive nil handling
 map                  | .map   | Yes   | Optional result  | Transform if not nil
 flatMap              | .flatMap| Yes  | Optional result  | Avoid double Optional

 OPTIONALS IN SWIFT — EXTENDED INTERVIEW Q&A
 ===========================================================
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 SECTION 1 — BASIC LEVEL QUESTIONS
 ================================================================

 Q1. What is an Optional in Swift?
 -----------------------------------
 A: An Optional is a type that can hold either a value
    or nil. It is Swift's way of representing the absence
    of a value safely. Declared with ? after the type.
    Example:
      var name: String? = "Alice"
      print(name)
      // Output: Optional("Alice")

      var empty: String? = nil
      print(empty)
      // Output: nil


 Q2. Why does Swift have Optionals?
 ------------------------------------
 A: To handle absence of a value at compile time rather
    than crashing at runtime. Swift forces you to deal
    with nil explicitly, making apps safer and more reliable.


 Q3. How do you declare an Optional variable?
 ---------------------------------------------
 A: By adding ? after the type.
    Example:
      var age: Int?
      var name: String? = "Bob"
      print(age)
      // Output: nil
      print(name)
      // Output: Optional("Bob")


 Q4. What is the default value of an Optional variable
      if not assigned?
 ------------------------------------------------------
 A: nil
    Example:
      var score: Int?
      print(score)
      // Output: nil


 Q5. Can a non-Optional variable be assigned nil?
 -------------------------------------------------
 A: No. Assigning nil to a non-Optional causes a
    compile-time error.
    Example:
      var name: String = "Alice"
      name = nil
      // Error: Non-optional type 'String' cannot be nil


 Q6. What is the difference between String and String??
 -------------------------------------------------------
 A: String must always hold a String value.
    String? can hold a String or nil.
    Example:
      var a: String = "Hello"
      var b: String? = nil
      print(a)    // Output: Hello
      print(b)    // Output: nil


 Q7. How do you assign a value to an Optional?
 ----------------------------------------------
 A: Same as any variable — just assign a value.
    Example:
      var number: Int? = 42
      print(number)
      // Output: Optional(42)


 Q8. How do you set an Optional back to nil?
 --------------------------------------------
 A: Simply assign nil.
    Example:
      var value: Int? = 10
      value = nil
      print(value)
      // Output: nil


 Q9. What does Optional look like when printed?
 -----------------------------------------------
 A: It wraps the value in Optional().
    Example:
      var x: Int? = 5
      print(x)
      // Output: Optional(5)

      var y: Int? = nil
      print(y)
      // Output: nil


 Q10. What is force unwrapping?
 --------------------------------
 A: Using ! to extract the value from an Optional.
    Crashes at runtime if the Optional is nil.
    Example:
      var name: String? = "Alice"
      print(name!)
      // Output: Alice

      var empty: String? = nil
      print(empty!)
      // CRASH: Fatal error — unexpectedly found nil


 Q11. What is optional binding?
 --------------------------------
 A: A safe way to unwrap an Optional using if let or guard let.
    If the Optional has a value, it is bound to a constant.
    Example:
      var score: Int? = 95
      if let s = score {
          print("Score: \(s)")
      } else {
          print("No score")
      }
      // Output: Score: 95


 Q12. What is the nil coalescing operator?
 ------------------------------------------
 A: The ?? operator. Returns the Optional's value if
    it exists, or a default value if it is nil.
    Example:
      var username: String? = nil
      print(username ?? "Guest")
      // Output: Guest

      var username2: String? = "Alice"
      print(username2 ?? "Guest")
      // Output: Alice


 Q13. What is optional chaining?
 ---------------------------------
 A: Using ?. to safely access properties or methods
    on an Optional. Returns nil if the Optional is nil.
    Example:
      var text: String? = "hello"
      print(text?.uppercased())
      // Output: Optional("HELLO")

      var text2: String? = nil
      print(text2?.uppercased())
      // Output: nil


 Q14. What is an implicitly unwrapped Optional?
 ------------------------------------------------
 A: Declared with ! after the type. Automatically
    unwrapped when used. Crashes if nil at access time.
    Example:
      var label: String! = "Swift"
      print(label)
      // Output: Swift


 Q15. What is the difference between ? and ! in Swift Optionals?
 ----------------------------------------------------------------
 A: ? — Optional, must be explicitly unwrapped
    ! — Force unwrap or implicitly unwrapped Optional
    Example:
      var a: String? = "Hello"    // needs unwrapping
      var b: String! = "World"    // auto-unwrapped
      print(a ?? "")              // Output: Hello
      print(b)                    // Output: World


 Q16. Can an Optional hold any type in Swift?
 ---------------------------------------------
 A: Yes. Any type can be Optional — Int, String,
    custom classes, structs, enums, closures, etc.
    Example:
      var number: Int? = 10
      var name: String? = "Alice"
      var flag: Bool? = true
      var list: [Int]? = [1, 2, 3]
      print(number, name, flag, list)
      // Output: Optional(10) Optional("Alice")
      //         Optional(true) Optional([1, 2, 3])


 Q17. Is Optional a keyword in Swift?
 --------------------------------------
 A: No. Optional is a generic enum defined in
    the Swift Standard Library.
    Optional<Wrapped> with cases .some and .none.


 Q18. Can you use Optional with a custom struct?
 ------------------------------------------------
 A: Yes.
    Example:
      struct Point {
          var x: Int
          var y: Int
      }
      var p: Point? = Point(x: 3, y: 4)
      print(p?.x ?? 0)
      // Output: 3

      p = nil
      print(p?.x ?? 0)
      // Output: 0


 Q19. What happens if you print an Optional
      String without unwrapping?
 -------------------------------------------
 A: Swift shows the Optional wrapper or a warning.
    Example:
      var name: String? = "Alice"
      print(name)
      // Output: Optional("Alice")
      // Warning: Expression implicitly coerced from
      //          'String?' to 'Any'


 Q20. Can you compare an Optional to nil directly?
 --------------------------------------------------
 A: Yes.
    Example:
      var value: Int? = nil
      if value == nil {
          print("No value")
      }
      // Output: No value

      var value2: Int? = 10
      if value2 != nil {
          print("Has value")
      }
      // Output: Has value


 ================================================================
 SECTION 2 — INTERMEDIATE LEVEL QUESTIONS
 ================================================================

 Q21. What is the difference between if let and guard let?
 ----------------------------------------------------------
 A: if let:   unwrapped value is scoped inside the if block
    guard let: unwrapped value is available after the guard

    if let example:
      var name: String? = "Alice"
      if let n = name {
          print(n)    // available here only
      }

    guard let example:
      func printName(_ name: String?) {
          guard let n = name else {
              print("nil — exiting")
              return
          }
          print(n)    // available here and below
      }
      printName("Bob")
      // Output: Bob
      printName(nil)
      // Output: nil — exiting


 Q22. How do you unwrap multiple Optionals in one if let?
 ---------------------------------------------------------
 A: Separate them with commas. All must be non-nil
    for the block to execute.
    Example:
      var first: String? = "Alice"
      var last: String? = "Smith"
      if let f = first, let l = last {
          print("\(f) \(l)")
      }
      // Output: Alice Smith

      var middle: String? = nil
      if let f = first, let m = middle, let l = last {
          print("\(f) \(m) \(l)")
      } else {
          print("One or more values missing")
      }
      // Output: One or more values missing


 Q23. Can you add a condition inside an if let?
 -----------------------------------------------
 A: Yes. Add a comma after the binding followed by
    a Boolean condition.
    Example:
      var age: Int? = 21
      if let a = age, a >= 18 {
          print("Adult — age \(a)")
      } else {
          print("Underage or nil")
      }
      // Output: Adult — age 21

      var age2: Int? = 15
      if let a = age2, a >= 18 {
          print("Adult")
      } else {
          print("Underage or nil")
      }
      // Output: Underage or nil


 Q24. What is shorthand optional binding in Swift 5.7+?
 -------------------------------------------------------
 A: You can reuse the same name without repeating it.
    Example:
      var username: String? = "Alice"

      // Old style:
      if let username = username {
          print(username)
      }

      // New shorthand (Swift 5.7+):
      if let username {
          print(username)
      }
      // Output: Alice


 Q25. How do you chain multiple ?? operators?
 ---------------------------------------------
 A: Chain with multiple ??.
    Swift evaluates left to right and returns the
    first non-nil value.
    Example:
      var a: String? = nil
      var b: String? = nil
      var c: String? = "Found"
      print(a ?? b ?? c ?? "Default")
      // Output: Found


 Q26. Can optional chaining be used to call methods?
 ----------------------------------------------------
 A: Yes. The method call returns an Optional result.
    Example:
      var text: String? = "swift"
      print(text?.capitalized)
      // Output: Optional("Swift")

      var arr: [Int]? = [3, 1, 2]
      print(arr?.sorted())
      // Output: Optional([1, 2, 3])


 Q27. Can optional chaining be used to set a property?
 ------------------------------------------------------
 A: Yes. If the Optional is nil, the assignment
    is silently ignored.
    Example:
      class Car {
          var color = "Red"
      }
      var car: Car? = Car()
      car?.color = "Blue"
      print(car?.color ?? "No car")
      // Output: Blue

      var car2: Car? = nil
      car2?.color = "Green"   // silently ignored
      print(car2?.color ?? "No car")
      // Output: No car


 Q28. What does optional chaining return when used
      on a function that returns Void?
 -------------------------------------------------
 A: It returns Void? (an Optional Void).
    If the Optional was nil, it returns nil.
    If it was non-nil, it returns Optional(()).
    Example:
      class Printer {
          func printMessage() {
              print("Hello")
          }
      }
      var p: Printer? = Printer()
      let result = p?.printMessage()
      // Output: Hello
      print(result)
      // Output: Optional(())

      var p2: Printer? = nil
      let result2 = p2?.printMessage()
      print(result2)
      // Output: nil


 Q29. How do you use optional chaining with subscripts?
 -------------------------------------------------------
 A: Use ?[] syntax.
    Example:
      var dict: [String: String]? = ["key": "value"]
      print(dict?["key"] ?? "Not found")
      // Output: value

      var dict2: [String: String]? = nil
      print(dict2?["key"] ?? "Not found")
      // Output: Not found


 Q30. How does map work on an Optional?
 ---------------------------------------
 A: Transforms the wrapped value if present.
    Returns nil if the Optional is nil.
    Example:
      let num: Int? = 5
      print(num.map { $0 * 2 })
      // Output: Optional(10)

      let empty: Int? = nil
      print(empty.map { $0 * 2 })
      // Output: nil


 Q31. What is flatMap on an Optional?
 --------------------------------------
 A: Like map but used when the transform itself returns
    an Optional. Avoids double-wrapping.
    Example:
      let str: String? = "42"
      print(str.map { Int($0) })
      // Output: Optional(Optional(42)) — double wrapped

      print(str.flatMap { Int($0) })
      // Output: Optional(42) — flat

      let str2: String? = "abc"
      print(str2.flatMap { Int($0) })
      // Output: nil


 Q32. What is the difference between map and flatMap
      on Optionals?
 ----------------------------------------------------
 A: map:     wraps result in Optional — can double-wrap
    flatMap: flattens result — avoids Optional(Optional(value))
    Example:
      let x: Int? = 3
      let mapResult = x.map { Optional($0 * 2) }
      print(mapResult)
      // Output: Optional(Optional(6))

      let flatResult = x.flatMap { Optional($0 * 2) }
      print(flatResult)
      // Output: Optional(6)


 Q33. Can you use try? to produce an Optional?
 ----------------------------------------------
 A: Yes. try? converts a throwing function's result
    into an Optional. Returns nil on error.
    Example:
      enum MyError: Error { case failed }
      func riskyTask(fail: Bool) throws -> String {
          if fail { throw MyError.failed }
          return "Success"
      }

      let result = try? riskyTask(fail: false)
      print(result)
      // Output: Optional("Success")

      let result2 = try? riskyTask(fail: true)
      print(result2)
      // Output: nil


 Q34. What is the difference between try? and try!?
 ---------------------------------------------------
 A: try?  — returns Optional, nil on error (safe)
    try!  — force unwraps result, crashes on error (unsafe)
    Example:
      let r1 = try? riskyTask(fail: false)
      print(r1 ?? "nil")
      // Output: Success

      let r2 = try! riskyTask(fail: false)
      print(r2)
      // Output: Success

      let r3 = try! riskyTask(fail: true)
      // CRASH: Fatal error — riskyTask threw an error


 Q35. How do Optionals interact with type casting?
 --------------------------------------------------
 A: as? returns an Optional of the target type.
    Returns nil if the cast fails.
    Example:
      let value: Any = "Hello"
      let str = value as? String
      print(str ?? "Not a String")
      // Output: Hello

      let num = value as? Int
      print(num ?? -1)
      // Output: -1


 Q36. Can you use Optional with closures?
 -----------------------------------------
 A: Yes. A closure can be Optional.
    Example:
      var completion: (() -> Void)? = nil
      completion?()   // safely does nothing

      completion = { print("Done") }
      completion?()
      // Output: Done


 Q37. Can you store an Optional in a collection?
 ------------------------------------------------
 A: Yes.
    Example:
      let values: [Int?] = [1, nil, 3, nil, 5]
      for v in values {
          print(v ?? 0)
      }
      // Output: 1
      //         0
      //         3
      //         0
      //         5


 Q38. How do you filter out nil values from an
      Optional array?
 ------------------------------------------------
 A: Use compactMap.
    Example:
      let numbers: [Int?] = [1, nil, 3, nil, 5]
      let nonNil = numbers.compactMap { $0 }
      print(nonNil)
      // Output: [1, 3, 5]


 Q39. What is compactMap and how does it relate
      to Optionals?
 ---------------------------------------------
 A: compactMap transforms each element and removes
    nil results from the output array.
    Example:
      let strings = ["1", "two", "3", "four", "5"]
      let numbers = strings.compactMap { Int($0) }
      print(numbers)
      // Output: [1, 3, 5]


 Q40. Can you return an Optional from a function?
 -------------------------------------------------
 A: Yes.
    Example:
      func findIndex(of item: String,
                     in list: [String]) -> Int? {
          return list.firstIndex(of: item)
      }
      let index = findIndex(of: "Bob",
                            in: ["Alice", "Bob", "Eve"])
      print(index ?? -1)
      // Output: 1

      let index2 = findIndex(of: "Zara",
                             in: ["Alice", "Bob"])
      print(index2 ?? -1)
      // Output: -1


 ================================================================
 SECTION 3 — ADVANCED LEVEL QUESTIONS
 ================================================================

 Q41. How are Optionals implemented internally in Swift?
 --------------------------------------------------------
 A: Optional is a generic enum:
      enum Optional<Wrapped> {
          case none
          case some(Wrapped)
      }
    var x: Int? = 5 is sugar for Optional<Int>.some(5)
    var x: Int? = nil is sugar for Optional<Int>.none
    Example:
      let a: Optional<Int> = .some(99)
      let b: Optional<Int> = .none
      print(a)   // Output: Optional(99)
      print(b)   // Output: nil


 Q42. What is optional pattern matching in a switch?
 ----------------------------------------------------
 A: Match .some(value) and .none cases in a switch.
    Example:
      let score: Int? = 85
      switch score {
      case .some(let s) where s >= 90:
          print("Grade: A")
      case .some(let s) where s >= 80:
          print("Grade: B")
      case .some(let s):
          print("Grade: C or below — \(s)")
      case .none:
          print("No score available")
      }
      // Output: Grade: B


 Q43. Can you use if case with Optionals?
 -----------------------------------------
 A: Yes.
    Example:
      let value: Int? = 10
      if case .some(let v) = value {
          print("Value is \(v)")
      }
      // Output: Value is 10

      if case let v? = value {
          print("Shorthand: \(v)")
      }
      // Output: Shorthand: 10


 Q44. What is the ? pattern in a switch statement?
 --------------------------------------------------
 A: The x? pattern matches a non-nil Optional and
    binds the unwrapped value.
    Example:
      let number: Int? = 7
      switch number {
      case let n?:
          print("Got \(n)")
      case nil:
          print("Got nil")
      }
      // Output: Got 7


 Q45. Can Optionals be nested? What is Optional<Optional<Int>>?
 --------------------------------------------------------------
 A: Yes but avoid it. Nested Optionals can arise from
    flatMap or dictionary lookups in nested structures.
    Example:
      var outer: Int?? = Optional(Optional(5))
      print(outer)
      // Output: Optional(Optional(5))

      if let inner = outer, let value = inner {
          print(value)
      }
      // Output: 5


 Q46. How does a Dictionary lookup return an Optional?
 ------------------------------------------------------
 A: Dictionary subscripting returns an Optional because
    the key may not exist.
    Example:
      let capitals = ["France": "Paris", "Japan": "Tokyo"]
      let city = capitals["France"]
      print(city)
      // Output: Optional("Paris")

      let missing = capitals["Germany"]
      print(missing ?? "Unknown")
      // Output: Unknown


 Q47. How do you chain optional properties on
      deeply nested objects?
 ---------------------------------------------
 A: Use optional chaining.
    Example:
      class Engine { var hp = 200 }
      class Car { var engine: Engine? }
      class Garage { var car: Car? }

      let g = Garage()
      print(g.car?.engine?.hp)
      // Output: nil

      g.car = Car()
      g.car?.engine = Engine()
      print(g.car?.engine?.hp ?? 0)
      // Output: 200


 Q48. How do Optionals work with protocols?
 -------------------------------------------
 A: A protocol type can be Optional.
    Example:
      protocol Greetable {
          func greet() -> String
      }
      struct Person: Greetable {
          func greet() -> String { return "Hello!" }
      }
      var g: Greetable? = Person()
      print(g?.greet() ?? "No greeter")
      // Output: Hello!

      g = nil
      print(g?.greet() ?? "No greeter")
      // Output: No greeter


 Q49. Can you use Optionals with generic functions?
 ---------------------------------------------------
 A: Yes.
    Example:
      func printIfNotNil<T>(_ value: T?) {
          if let v = value {
              print("Value: \(v)")
          } else {
              print("Value is nil")
          }
      }
      printIfNotNil(42)
      // Output: Value: 42

      printIfNotNil(nil as String?)
      // Output: Value is nil


 Q50. What is the difference between Optional
      and ImplicitlyUnwrappedOptional in Swift?
 ----------------------------------------------
 A: Optional<T>  — declared as T?, requires explicit unwrapping
    IUO            — declared as T!, auto-unwrapped on access
    Both can be nil. IUO crashes if nil when accessed.
    Note: In Swift 4+, IUO behaves as Optional in most contexts.
    Example:
      var a: String? = "Safe"
      var b: String! = "Risky"
      print(a?.count ?? 0)   // Output: 4
      print(b.count)         // Output: 5


 Q51. How do you safely check and unwrap an Optional
      in a single expression using a ternary?
 ----------------------------------------------------
 A: Use nil coalescing or conditional expressions.
    Example:
      let val: Int? = 10
      let result = val != nil ? "Has value: \(val!)" : "Nil"
      print(result)
      // Output: Has value: 10

      // Better approach:
      let result2 = val.map { "Has value: \($0)" } ?? "Nil"
      print(result2)
      // Output: Has value: 10


 Q52. How does Optional interact with Equatable?
 ------------------------------------------------
 A: Two Optionals of an Equatable type can be compared.
    Example:
      let a: Int? = 5
      let b: Int? = 5
      let c: Int? = nil
      print(a == b)    // Output: true
      print(a == c)    // Output: false
      print(c == nil)  // Output: true


 Q53. How does Optional interact with Comparable?
 -------------------------------------------------
 A: Optionals are not directly Comparable in Swift.
    You must unwrap first before comparing magnitudes.
    Example:
      let x: Int? = 3
      let y: Int? = 7
      if let a = x, let b = y {
          print(a < b)
      }
      // Output: true


 Q54. Can you extend Optional in Swift?
 ---------------------------------------
 A: Yes. You can add methods to Optional using extensions.
    Example:
      extension Optional where Wrapped == String {
          var isNilOrEmpty: Bool {
              return self == nil || self == ""
          }
      }
      var name: String? = nil
      print(name.isNilOrEmpty)
      // Output: true

      name = ""
      print(name.isNilOrEmpty)
      // Output: true

      name = "Alice"
      print(name.isNilOrEmpty)
      // Output: false


 Q55. What is Optional.zip / combining two Optionals?
 -----------------------------------------------------
 A: Swift does not have Optional.zip built-in but you
    can combine two Optionals using if let or flatMap.
    Example:
      let a: Int? = 3
      let b: Int? = 4
      let sum = a.flatMap { x in b.map { y in x + y } }
      print(sum ?? 0)
      // Output: 7

      let c: Int? = nil
      let sum2 = c.flatMap { x in b.map { y in x + y } }
      print(sum2 ?? 0)
      // Output: 0


 Q56. Can you use Optional in a where clause?
 ---------------------------------------------
 A: Yes.
    Example:
      let values: [Int?] = [1, nil, 3, nil, 5]
      let nonNils = values.compactMap { $0 }
                          .filter { $0 > 2 }
      print(nonNils)
      // Output: [3, 5]


 Q57. What happens when you force unwrap a nil Optional
      in a release build?
 ------------------------------------------------------
 A: The app crashes with:
    Fatal error: Unexpectedly found nil while
    unwrapping an Optional value
    This crash appears in both debug and release builds.


 Q58. How does guard let differ from if let
      in terms of early exit?
 --------------------------------------------
 A: guard let requires an else clause with an exit
    (return, break, continue, throw). The unwrapped
    value is available throughout the remaining scope.
    Example:
      func process(value: Int?) -> String {
          guard let v = value else {
              return "nil received"
          }
          return "Processed: \(v * 2)"
      }
      print(process(value: 10))
      // Output: Processed: 20
      print(process(value: nil))
      // Output: nil received


 Q59. Can guard let be used outside a function?
 -----------------------------------------------
 A: No. guard requires a scope to exit from (function,
    loop, or closure). It cannot be used at the top level
    of a playground or module without an enclosing scope.


 Q60. Can you use guard let without else?
 -----------------------------------------
 A: No. guard always requires an else clause.
    Without else, it is a compile-time error.
    Example:
      guard let x = someOptional  // Error — missing else clause


 Q61. What happens to the original Optional after
      it is unwrapped with if let?
 -----------------------------------------------
 A: The original Optional is unchanged. if let creates
    a new constant with the unwrapped value.
    Example:
      var number: Int? = 42
      if let n = number {
          print(n)       // Output: 42
      }
      print(number)      // Output: Optional(42)
      // original Optional still wraps the value


 Q62. Can you reassign inside an if let block?
 ----------------------------------------------
 A: The unwrapped constant is immutable inside
    the if let block unless you use if var.
    Example:
      var score: Int? = 10
      if var s = score {
          s += 5
          print(s)       // Output: 15
      }
      print(score)       // Output: Optional(10)
      // original not changed


 Q63. What is if var in the context of Optionals?
 -------------------------------------------------
 A: Like if let but creates a mutable copy you can
    change inside the block.
    Example:
      var price: Double? = 9.99
      if var p = price {
          p *= 1.1
          print(p)       // Output: 10.989
      }
      print(price)       // Output: Optional(9.99)


 Q64. How do you convert an Optional to a non-Optional
      with a default — avoiding force unwrap?
 ------------------------------------------------------
 A: Use ?? (nil coalescing).
    Example:
      let raw: Int? = nil
      let value: Int = raw ?? 0
      print(value)
      // Output: 0

      let raw2: Int? = 55
      let value2: Int = raw2 ?? 0
      print(value2)
      // Output: 55


 Q65. What is Optional binding with as? (type casting)?
 -------------------------------------------------------
 A: as? returns an Optional. You can bind it with if let.
    Example:
      let items: [Any] = [1, "Hello", true, 3.14]
      for item in items {
          if let str = item as? String {
              print("String: \(str)")
          } else if let num = item as? Int {
              print("Int: \(num)")
          }
      }
      // Output: Int: 1
      //         String: Hello


 Q66. How does Optional work with lazy properties?
 --------------------------------------------------
 A: Lazy properties themselves are not Optional but you
    can have a lazy Optional property.
    Example:
      class DataLoader {
          lazy var data: String? = {
              return "Loaded Data"
          }()
      }
      let loader = DataLoader()
      print(loader.data ?? "Nothing")
      // Output: Loaded Data


 Q67. Can you use Optional with @escaping closures?
 ---------------------------------------------------
 A: Yes. Commonly used as Optional callback parameters.
    Example:
      func fetch(completion: ((String?) -> Void)?) {
          completion?("Data received")
      }
      fetch { result in
          print(result ?? "No result")
      }
      // Output: Data received

      fetch(completion: nil)
      // silently does nothing


 Q68. How can you write a generic function that
      accepts an Optional and returns a default?
 ----------------------------------------------
 A: Use generics with Optional.
    Example:
      func unwrap<T>(_ optional: T?, default value: T) -> T {
          return optional ?? value
      }
      print(unwrap(nil, default: "Hello"))
      // Output: Hello
      print(unwrap(42, default: 0))
      // Output: 42


 Q69. How do Optional and Result type relate?
 ---------------------------------------------
 A: Optional handles presence/absence of a value.
    Result handles success/failure with an error.
    try? converts a Result-like throwing expression
    to an Optional, losing error details.
    Example:
      enum AppError: Error { case notFound }
      func fetch() throws -> String {
          throw AppError.notFound
      }
      let result: String? = try? fetch()
      print(result ?? "nil")
      // Output: nil
      // Error detail is lost — use Result for error info


 Q70. How do you handle Optional in a forEach loop?
 ---------------------------------------------------
 A: Use compactMap to remove nils first.
    Example:
      let numbers: [Int?] = [1, nil, 2, nil, 3]
      numbers.compactMap { $0 }.forEach {
          print($0)
      }
      // Output: 1
      //         2
      //         3


 ================================================================
 SECTION 4 — EXPERT LEVEL QUESTIONS
 ================================================================

 Q71. What is the memory layout of an Optional in Swift?
 --------------------------------------------------------
 A: For reference types, Optional<T> is represented
    as a nullable pointer — same size as a pointer.
    For value types, Swift uses a special representation
    to minimize overhead. The compiler optimizes
    Optional<T> to avoid extra memory in many cases.


 Q72. How does Swift optimize Optional<Bool>?
 ---------------------------------------------
 A: Swift uses a special bit-packing trick for certain
    types like Bool, where Optional<Bool> fits in a
    single byte (true, false, nil = 3 states, 1 byte).


 Q73. When is Optional<T> the same size as T?
 ---------------------------------------------
 A: For class types and types with extra bit patterns
    (like pointers), Swift optimizes Optional<T> to
    occupy the same space as T, using nil as a special
    bit pattern (e.g., null pointer for classes).
    Example:
      import Foundation
      print(MemoryLayout<String>.size)
      print(MemoryLayout<String?>.size)
      // Both may be 16 bytes on 64-bit platforms
      // depending on Swift version and platform


 Q74. Can you extend Optional to add a custom
      unwrap-with-error behavior?
 -----------------------------------------------
 A: Yes.
    Example:
      enum UnwrapError: Error {
          case foundNil(String)
      }
      extension Optional {
          func unwrap(or errorMessage: String) throws -> Wrapped {
              guard let value = self else {
                  throw UnwrapError.foundNil(errorMessage)
              }
              return value
          }
      }
      let name: String? = nil
      do {
          let n = try name.unwrap(or: "Name was nil")
          print(n)
      } catch {
          print(error)
      }
      // Output: foundNil("Name was nil")


 Q75. What is the relationship between Optional
      and Functional Programming in Swift?
 -----------------------------------------------
 A: Optional is a Monad in functional programming.
    map  = functor operation (transform if present)
    flatMap = monadic bind (chain Optional-returning operations)
    Example:
      let str: String? = "123"
      let result = str
          .flatMap { Int($0) }
          .map { $0 * 2 }
      print(result ?? 0)
      // Output: 246


 Q76. Can you chain map and flatMap on Optionals?
 -------------------------------------------------
 A: Yes.
    Example:
      let input: String? = "  42  "
      let result = input
          .map { $0.trimmingCharacters(in: .whitespaces) }
          .flatMap { Int($0) }
          .map { $0 * $0 }
      print(result ?? 0)
      // Output: 1764  (42 * 42)


 Q77. How does Swift handle Optional in
      string interpolation?
 ---------------------------------------------------
 A: Swift warns when you interpolate an Optional directly
    because it prints Optional("value") or nil.
    Example:
      var name: String? = "Alice"
      print("Hello \(name)")
      // Output: Hello Optional("Alice")
      // Warning: String interpolation produces a
      //          debug description for an Optional value

      print("Hello \(name ?? "Guest")")
      // Output: Hello Alice


 Q78. What is Optional.init(_ some:)?
 --------------------------------------
 A: The Optional type provides an initializer that
    wraps a non-nil value.
    Example:
      let x = Optional(5)
      print(x)
      // Output: Optional(5)

      let y: Int? = Optional(10)
      print(y!)
      // Output: 10


 Q79. Can Optional conform to CustomStringConvertible?
 ------------------------------------------------------
 A: Optional already provides a debug description.
    You can extend it conditionally for custom printing.
    Example:
      extension Optional: CustomStringConvertible
          where Wrapped: CustomStringConvertible {
          public var description: String {
              switch self {
              case .some(let v): return v.description
              case .none:        return "Nothing here"
              }
          }
      }
      var name: String? = "Alice"
      print(name.description)
      // Output: Alice

      var empty: String? = nil
      print(empty.description)
      // Output: Nothing here


 Q80. How do you write a safe subscript that
      returns an Optional to avoid index out of bounds?
 -----------------------------------------------------
 A: Extend Array with a safe subscript.
    Example:
      extension Array {
          subscript(safe index: Int) -> Element? {
              guard index >= 0 && index < count else {
                  return nil
              }
              return self[index]
          }
      }
      let arr = [10, 20, 30]
      print(arr[safe: 1] ?? -1)
      // Output: 20
      print(arr[safe: 10] ?? -1)
      // Output: -1


 Q81. How do you test Optional properties in unit tests?
 --------------------------------------------------------
 A: Use XCTAssertNil, XCTAssertNotNil, and XCTUnwrap.
    Example:
      import XCTest
      class Tests: XCTestCase {
          func testOptional() throws {
              var value: Int? = 42
              XCTAssertNotNil(value)

              let unwrapped = try XCTUnwrap(value)
              XCTAssertEqual(unwrapped, 42)

              value = nil
              XCTAssertNil(value)
          }
      }


 Q82. What is XCTUnwrap?
 ------------------------
 A: XCTUnwrap safely unwraps an Optional in a test.
    If the Optional is nil, the test fails with an error
    rather than crashing.
    Example:
      func testName() throws {
          let name: String? = "Alice"
          let unwrapped = try XCTUnwrap(name)
          XCTAssertEqual(unwrapped, "Alice")
      }


 Q83. How do Optionals affect ABI stability in Swift?
 -----------------------------------------------------
 A: Optional is part of Swift's ABI and is stable.
    The compiler uses spare bits in types (e.g., class
    references) to represent nil without extra memory.
    This is part of Swift's ABI stability guarantee
    introduced in Swift 5.


 Q84. How do you avoid Pyramid of Doom with Optionals?
 ------------------------------------------------------
 A: The pyramid of doom is deeply nested if let blocks.
    Avoid using:
    - Multiple bindings in one if let
    - guard let for early exit
    - Optional chaining

    Pyramid of Doom (avoid):
      if let a = optA {
          if let b = optB {
              if let c = optC {
                  print("\(a) \(b) \(c)")
              }
          }
      }

    Better with multiple bindings:
      if let a = optA, let b = optB, let c = optC {
          print("\(a) \(b) \(c)")
      }
      // Output: values printed if all non-nil

    Best with guard let:
      func process() {
          guard let a = optA,
                let b = optB,
                let c = optC else { return }
          print("\(a) \(b) \(c)")
      }


 Q85. How do you safely unwrap an Optional
      and throw an error if nil?
 -------------------------------------------
 A: Use guard let with throw in an else clause.
    Example:
      enum DataError: Error { case missingValue }
      func process(input: String?) throws -> String {
          guard let value = input else {
              throw DataError.missingValue
          }
          return value.uppercased()
      }
      do {
          let result = try process(input: "hello")
          print(result)
      } catch {
          print("Error: \(error)")
      }
      // Output: HELLO

      do {
          let result = try process(input: nil)
          print(result)
      } catch {
          print("Error: \(error)")
      }
      // Output: Error: missingValue


 Q86. How do you use Optional in Combine or async/await?
 --------------------------------------------------------
 A: Optionals integrate naturally with async functions
    and Combine pipelines.
    Example (async/await):
      func fetchUsername() async -> String? {
          return "Alice"
      }
      Task {
          let name = await fetchUsername()
          print(name ?? "No user")
      }
      // Output: Alice

    Example (Combine - conceptual):
      // publisher.compactMap { $0 } removes nil values
      // from a stream of Optional values


 Q87. What is the difference between Optional
      and throwing functions for error handling?
 ---------------------------------------------
 A: Optional: returns nil — no error information
    throws:    returns error — carries error details

    Use Optional when:
    - Absence is expected and normal
    - Caller does not need to know why it failed

    Use throws when:
    - Failure carries meaningful error context
    - Caller needs to handle different error types

    Example Optional:
      func divide(_ a: Int, _ b: Int) -> Int? {
          guard b != 0 else { return nil }
          return a / b
      }
      print(divide(10, 2) ?? "failed")
      // Output: 5
      print(divide(10, 0) ?? "failed")
      // Output: failed

    Example throws:
      enum MathError: Error { case divisionByZero }
      func divide(_ a: Int, _ b: Int) throws -> Int {
          guard b != 0 else { throw MathError.divisionByZero }
          return a / b
      }


 Q88. Can you use Optional with @propertyWrapper?
 -------------------------------------------------
 A: Yes. Property wrappers can wrap Optional types.
    Example:
      @propertyWrapper
      struct Clamped {
          private var value: Int? = nil
          var wrappedValue: Int? {
              get { value }
              set { value = newValue.map { max(0, min($0, 100)) } }
          }
      }
      struct Player {
          @Clamped var score: Int?
      }
      var player = Player()
      player.score = 150
      print(player.score ?? -1)
      // Output: 100

      player.score = -10
      print(player.score ?? -1)
      // Output: 0


 Q89. How does Optional interact with Codable?
 ----------------------------------------------
 A: Optional properties in Codable types can be
    absent from JSON. They decode to nil if missing.
    Example:
      struct User: Codable {
          var name: String
          var email: String?
      }
      let json = #"{"name": "Alice"}"#
      let data = json.data(using: .utf8)!
      let user = try! JSONDecoder().decode(User.self,
                                           from: data)
      print(user.name)
      // Output: Alice
      print(user.email ?? "No email")
      // Output: No email


 Q90. What is the best practice for using Optionals
      in Swift?
 ----------------------------------------------------
 A: 1. Use let with Optional — prefer constants
    2. Use guard let for early exit / validation
    3. Use ?? to provide sensible defaults
    4. Use optional chaining over force unwrapping
    5. Use compactMap to clean Optional arrays
    6. Avoid ! force unwrap unless guaranteed non-nil
    7. Avoid implicitly unwrapped Optional except
       for IBOutlets or post-init guaranteed values
    8. Prefer Optional over sentinel values like -1 or ""
    9. Use if let for short scoped Optional use
    10. Use flatMap to chain Optional-returning operations


 ================================================================
 COMPLETE QUICK REFERENCE CHEAT SHEET
 ================================================================

 Concept                              | Code
 -------------------------------------|----------------------------------------
 Declare Optional                     | var x: Int?
 Declare with value                   | var x: Int? = 10
 Default value nil                    | var x: Int?  → nil
 Set to nil                           | x = nil
 Force unwrap (unsafe)                | x!
 Optional binding                     | if let v = x { }
 Optional binding mutable             | if var v = x { }
 Guard unwrap                         | guard let v = x else { return }
 Nil coalescing                       | x ?? defaultValue
 Chain nil coalescing                 | a ?? b ?? c ?? "default"
 Optional chaining property           | obj?.property
 Optional chaining method             | obj?.method()
 Optional chaining subscript          | obj?[key]
 Optional chaining setter             | obj?.property = value
 Implicit unwrap declaration          | var x: String! = "val"
 Pattern match some                   | if case .some(let v) = x { }
 Pattern match shorthand              | if case let v? = x { }
 Switch Optional                      | switch x { case .some(v): case .none: }
 Transform value                      | x.map { $0 * 2 }
 Chain Optional transforms            | x.flatMap { transform }
 Remove nils from array               | array.compactMap { $0 }
 Safe array subscript                 | arr[safe: index]
 try? converts throw to Optional      | let r = try? riskyFunc()
 as? type cast to Optional            | let s = value as? String
 Codable Optional property            | var email: String?
 Extend Optional                      | extension Optional where Wrapped == ...
 Short binding (Swift 5.7+)           | if let x { }
 Test not nil                         | XCTAssertNotNil(x)
 Safe test unwrap                     | let v = try XCTUnwrap(x)
 String interpolation safe            | "\(x ?? defaultValue)"
 Optional closure call                | closure?()
 Optional in dictionary lookup        | dict["key"] returns T?
 Print type of Optional               | type(of: x) → Optional<Int>
 Optional is value type               | copied on assignment


 */

