import UIKit

/*
 VARIABLES, CONSTANTS, TYPE INFERENCE & MUTABILITY IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — VARIABLES
 ================================================================

 WHAT IS A VARIABLE?
 ===================
 A variable is a named storage location whose value
 can be changed after it is first assigned.
 Declared using the var keyword.

 Syntax:
   var variableName: Type = value
   var variableName = value   // Type inferred


 EXAMPLES
 ========

 Basic Variable:
   var age = 25
   print(age)       // Output: 25
   age = 30
   print(age)       // Output: 30

 String Variable:
   var name = "Alice"
   name = "Bob"
   print(name)      // Output: Bob

 Explicit Type:
   var score: Int = 100
   score = 200
   print(score)     // Output: 200

 Float Variable:
   var temperature: Float = 36.6
   print(temperature)   // Output: 36.6

 Boolean Variable:
   var isLoggedIn: Bool = false
   isLoggedIn = true
   print(isLoggedIn)    // Output: true

 Multiple Variables on One Line:
   var x = 1, y = 2, z = 3
   print(x, y, z)       // Output: 1 2 3

 Variable Without Initial Value (Explicit Type Required):
   var score: Int
   score = 95
   print(score)         // Output: 95


 ================================================================
 PART 2 — CONSTANTS
 ================================================================

 WHAT IS A CONSTANT?
 ===================
 A constant is a named storage location whose value
 cannot be changed once it is assigned.
 Declared using the let keyword.
 Swift recommends using let by default.

 Syntax:
   let constantName: Type = value
   let constantName = value   // Type inferred


 EXAMPLES
 ========

 Basic Constant:
   let pi = 3.14159
   print(pi)       // Output: 3.14159

 String Constant:
   let appName = "MyApp"
   print(appName)  // Output: MyApp

 Explicit Type:
   let maxRetries: Int = 3
   print(maxRetries)   // Output: 3

 Constant Must Be Initialized Before Use:
   let taxRate: Double
   taxRate = 0.08
   print(taxRate)      // Output: 0.08
   // Note: Can assign once but cannot reassign after

 Reassigning a Constant Causes Error:
   let country = "USA"
   country = "UK"      // Error: Cannot assign to value — 'country' is a 'let' constant


 ================================================================
 PART 3 — TYPE INFERENCE
 ================================================================

 WHAT IS TYPE INFERENCE?
 =======================
 Type inference is Swift's ability to automatically
 determine the type of a variable or constant based
 on the value assigned to it. You do not always need
 to explicitly declare the type.


 HOW IT WORKS
 ============

 Integer Inference:
   let count = 10
   // Swift infers count as Int
   print(type(of: count))   // Output: Int

 Double Inference:
   let price = 9.99
   // Swift infers price as Double
   print(type(of: price))   // Output: Double

 String Inference:
   let greeting = "Hello"
   // Swift infers greeting as String
   print(type(of: greeting))   // Output: String

 Boolean Inference:
   let isActive = true
   // Swift infers isActive as Bool
   print(type(of: isActive))   // Output: Bool

 Float — Explicit Type Needed:
   let value: Float = 3.14
   print(type(of: value))   // Output: Float
   // Without : Float, Swift would infer Double

 Array Inference:
   let numbers = [1, 2, 3]
   print(type(of: numbers))   // Output: Array<Int>

 Dictionary Inference:
   let user = ["name": "Alice", "city": "NY"]
   print(type(of: user))   // Output: Dictionary<String, String>

 Mixed Array — Explicit Type Needed:
   let mixed: [Any] = [1, "hello", true]
   print(mixed)   // Output: [1, "hello", true]


 TYPE ANNOTATION vs TYPE INFERENCE
 ==================================

 Feature              | Type Annotation         | Type Inference
 ---------------------|-------------------------|---------------------------
 Syntax               | var x: Int = 10         | var x = 10
 Type specified by    | Developer               | Swift compiler
 Verbosity            | More explicit           | Cleaner and shorter
 Required when        | No initial value        | Value provided at declaration
 Overrides inference  | Yes                     | Not applicable
 Example              | let rate: Float = 1.5   | let rate = 1.5 (becomes Double)


 EXPLICIT TYPE ANNOTATION EXAMPLES
 ==================================

   var count: Int = 0
   var name: String = "Alice"
   var price: Double = 9.99
   var isValid: Bool = true
   var rating: Float = 4.5
   var initial: Character = "A"


 ================================================================
 PART 4 — MUTABILITY
 ================================================================

 WHAT IS MUTABILITY?
 ===================
 Mutability refers to whether the value of a variable
 or constant can be changed after it is initially set.

   var = Mutable   (value can change)
   let = Immutable (value cannot change)


 MUTABILITY WITH VALUE TYPES (Struct, Int, String, Array)
 ========================================================

 With var — Mutable:
   var numbers = [1, 2, 3]
   numbers.append(4)
   print(numbers)   // Output: [1, 2, 3, 4]

 With let — Immutable:
   let numbers = [1, 2, 3]
   numbers.append(4)   // Error: Cannot use mutating member on immutable value

 String Mutability:
   var message = "Hello"
   message += " World"
   print(message)   // Output: Hello World

   let greeting = "Hi"
   greeting += " there"   // Error: Cannot use mutating member on immutable value


 MUTABILITY WITH REFERENCE TYPES (Class)
 ========================================
 With classes, let means the reference cannot change
 but the object's properties CAN still change.

   class User {
       var name: String
       init(name: String) { self.name = name }
   }

   let user = User(name: "Alice")
   user.name = "Bob"        // Allowed — property is var
   print(user.name)         // Output: Bob
   user = User(name: "Eve") // Error — cannot reassign let reference


 MUTABILITY IN STRUCTS
 ======================
 Structs are value types. With let, no property
 can be changed even if declared as var inside.

   struct Point {
       var x: Int
       var y: Int
   }

   var p1 = Point(x: 1, y: 2)
   p1.x = 10
   print(p1.x)   // Output: 10

   let p2 = Point(x: 1, y: 2)
   p2.x = 10     // Error — cannot mutate properties of a let struct


 MUTABILITY IN DICTIONARIES
 ============================
   var dict = ["key": "value"]
   dict["newKey"] = "newValue"
   print(dict)   // Output: ["key": "value", "newKey": "newValue"]

   let dict2 = ["key": "value"]
   dict2["newKey"] = "newValue"   // Error — cannot mutate a let dictionary


 MUTATING FUNCTIONS IN STRUCTS
 ==============================
 To modify a struct's property inside a method,
 mark the method with mutating keyword.

   struct Counter {
       var count = 0
       mutating func increment() {
           count += 1
       }
   }

   var c = Counter()
   c.increment()
   print(c.count)   // Output: 1

   let c2 = Counter()
   c2.increment()   // Error — cannot call mutating function on let


 ================================================================
 PART 5 — VARIABLES vs CONSTANTS vs MUTABILITY SUMMARY
 ================================================================

 Feature                  | var                       | let
 -------------------------|---------------------------|---------------------------
 Keyword                  | var                       | let
 Mutable?                 | Yes                       | No
 Must initialize?         | No (if type annotated)    | No (if type annotated)
 Reassignable?            | Yes                       | No
 Value type mutation      | Allowed                   | Not allowed
 Reference type mutation  | Allowed                   | Properties can still change
 Struct properties        | Can change if var struct  | Cannot change even if var inside
 Best practice            | Only when change needed   | Default choice in Swift
 Compiler warning         | Warns if never mutated    | No warning


 ================================================================
 PART 6 — TYPE INFERENCE CHEAT SHEET
 ================================================================

 Value Assigned           | Inferred Type
 -------------------------|----------------
 10                       | Int
 3.14                     | Double
 "Hello"                  | String
 true / false             | Bool
 [1, 2, 3]                | [Int]
 ["a", "b"]               | [String]
 ["key": 1]               | [String: Int]
 (1, "hello")             | (Int, String)
 nil                      | Requires explicit Optional type
 1.5 (without annotation) | Double (not Float)


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 --------------------------------------------------------------
 VARIABLES
 --------------------------------------------------------------

 Q1. What is a variable in Swift?
 ----------------------------------
 A: A variable is declared with var and holds a value
    that can be changed after assignment.
    Example:
      var city = "New York"
      city = "London"
      print(city)
      // Output: London


 Q2. Can you declare a variable without assigning a value?
 ----------------------------------------------------------
 A: Yes, but you must provide an explicit type annotation. As swift is a strongly typed language hence need to define every variable type explicitly.
    Example:
      var score: Int
      score = 100
      print(score)
      // Output: 100


 Q3. Can a variable change its type after declaration?
 ------------------------------------------------------
 A: No. Swift is type-safe. Once a type is set, it cannot
    change.
    Example:
      var number = 10
      number = "hello"   // Error: Cannot assign String to Int


 Q4. Can you declare multiple variables in one line?
 ----------------------------------------------------
 A: Yes.
    Example:
      var a = 1, b = 2, c = 3
      print(a, b, c)
      // Output: 1 2 3


 --------------------------------------------------------------
 CONSTANTS
 --------------------------------------------------------------

 Q5. What is a constant in Swift?
 ----------------------------------
 A: A constant is declared with let and cannot be
    reassigned after its initial value is set.
    Example:
      let maxScore = 100
      print(maxScore)
      // Output: 100


 Q6. Why does Swift recommend using let by default?
 ---------------------------------------------------
 A: Immutability makes code safer and more predictable.
    It helps the compiler optimize performance and prevents
    accidental value changes.


 Q7. Can you declare a let constant without an initial value?
 -------------------------------------------------------------
 A: Yes, but it must be assigned exactly once before use.
    Example:
      let result: Int
      result = 42
      print(result)
      // Output: 42


 Q8. What happens if you try to change a constant?
 --------------------------------------------------
 A: You get a compile-time error.
    Example:
      let name = "Alice"
      name = "Bob"
      // Error: Cannot assign to value — 'name' is a 'let' constant


 --------------------------------------------------------------
 TYPE INFERENCE
 --------------------------------------------------------------

 Q9. What is type inference in Swift?
 --------------------------------------
 A: Type inference allows Swift to automatically deduce
    the type of a variable or constant from its assigned value.
    Example:
      let age = 25
      print(type(of: age))
      // Output: Int


 Q10. What type does Swift infer for a decimal number?
 ------------------------------------------------------
 A: Swift infers Double, not Float.
    Example:
      let value = 3.14
      print(type(of: value))
      // Output: Double

    To get Float, you must explicitly annotate:
      let value: Float = 3.14
      print(type(of: value))
      // Output: Float


 Q11. Does type inference affect performance?
 ---------------------------------------------
 A: No. Type inference is resolved at compile time,
    not runtime. There is no performance overhead.


 Q12. Can type inference work with complex types?
 -------------------------------------------------
 A: Yes.
    Example:
      let scores = [90, 85, 78]
      print(type(of: scores))
      // Output: Array<Int>

      let profile = ["name": "Alice", "role": "Admin"]
      print(type(of: profile))
      // Output: Dictionary<String, String>


 Q13. What is the difference between type annotation
      and type inference?
 ----------------------------------------------------
 A: Type annotation is when you explicitly specify the type.
    Type inference is when Swift deduces it from the value.
    Example:
      let a: Int = 10      // Type annotation
      let b = 10           // Type inference — both are Int


 Q14. When must you use type annotation instead of inference?
 -------------------------------------------------------------
 A: - When declaring without an initial value
    - When you want Float instead of Double
    - When working with protocols or specific subtypes
    Example:
      var count: Int       // No value yet
      let ratio: Float = 1.5   // Force Float not Double


 --------------------------------------------------------------
 MUTABILITY
 --------------------------------------------------------------

 Q15. What is mutability in Swift?
 -----------------------------------
 A: Mutability is whether a value can change after creation.
    var is mutable, let is immutable.
    Example:
      var count = 0
      count += 1
      print(count)
      // Output: 1

      let max = 100
      max += 1
      // Error: Cannot assign to value — 'max' is a 'let' constant


 Q16. Can you change the property of a let class instance?
 ----------------------------------------------------------
 A: Yes. For reference types (class), let prevents
    reassigning the reference, but properties can change.
    Example:
      class Car {
          var speed = 0
      }
      let car = Car()
      car.speed = 100
      print(car.speed)
      // Output: 100


 Q17. Can you change the property of a let struct instance?
 -----------------------------------------------------------
 A: No. For value types (struct), let makes everything
    immutable, including its properties.
    Example:
      struct Point {
          var x = 0
          var y = 0
      }
      let p = Point()
      p.x = 5
      // Error: Cannot assign to property — 'p' is a 'let' constant


 Q18. What is a mutating function in Swift?
 -------------------------------------------
 A: A method inside a struct that modifies the struct's
    own properties must be marked mutating.
    Example:
      struct Counter {
          var count = 0
          mutating func increment() {
              count += 1
          }
      }
      var c = Counter()
      c.increment()
      print(c.count)
      // Output: 1


 Q19. What happens if you call a mutating function on a let struct?
 -------------------------------------------------------------------
 A: You get a compile-time error.
    Example:
      let c = Counter()
      c.increment()
      // Error: Cannot use mutating member on immutable value


 Q20. Can a let array have its elements changed?
 ------------------------------------------------
 A: No. A let array cannot be mutated in any way.
    Example:
      let items = ["a", "b"]
      items.append("c")
      // Error: Cannot use mutating member on immutable value

      var items2 = ["a", "b"]
      items2.append("c")
      print(items2)
      // Output: ["a", "b", "c"]


 Q21. What compiler warning appears if you use var unnecessarily?
 -----------------------------------------------------------------
 A: Swift warns: "Immutable value — change var to let"
    This encourages using let wherever mutation is not needed.
    Example:
      var name = "Alice"   // Warning if name is never changed
      // Swift suggests: let name = "Alice"


 Q22. What is the difference between mutability in
      value types and reference types?
 ----------------------------------------------------
 A: Value Types (Int, String, Array, Struct):
      let = fully immutable, nothing can change
      var = can reassign and mutate

    Reference Types (Class):
      let = reference is fixed, but object properties can change
      var = both the reference and properties can change

    Example Value Type:
      var str = "Hello"
      str = "World"
      print(str)        // Output: World

      let str2 = "Hello"
      str2 = "World"    // Error

    Example Reference Type:
      class Box { var value = 0 }
      let box = Box()
      box.value = 99
      print(box.value)  // Output: 99
      box = Box()       // Error — cannot reassign let reference


 ================================================================
 QUICK REFERENCE CHEAT SHEET
 ================================================================

 Concept                   | Keyword | Mutable | Example
 --------------------------|---------|---------|----------------------
 Variable                  | var     | Yes     | var x = 10
 Constant                  | let     | No      | let x = 10
 Type Inferred Int         | —       | —       | let x = 5 → Int
 Type Inferred Double      | —       | —       | let x = 3.14 → Double
 Type Inferred String      | —       | —       | let x = "hi" → String
 Type Inferred Bool        | —       | —       | let x = true → Bool
 Force Float               | —       | —       | let x: Float = 1.5
 Mutable Array             | var     | Yes     | var arr = [1,2,3]
 Immutable Array           | let     | No      | let arr = [1,2,3]
 Mutable Struct            | var     | Yes     | var p = Point()
 Immutable Struct          | let     | No      | let p = Point()
 Mutable Class Property    | var+let | Yes     | let obj = MyClass()
 Mutating Struct Method    | —       | Yes     | mutating func update()

 */
