import UIKit

/*
 FUNCTIONS & CLOSURES IN SWIFT
 ===========================================================
 PARAMETER LABELS, ESCAPING vs NON-ESCAPING,
 TRAILING CLOSURES, AUTOCLOSURES
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — FUNCTIONS FUNDAMENTALS
 ================================================================

 WHAT IS A FUNCTION?
 ====================
 A function is a named, reusable block of code that
 performs a specific task. Functions can accept input
 (parameters), produce output (return values), and
 be stored, passed, and returned like any other value.

 FUNCTION ANATOMY
 =================
   func functionName(label parameter: Type) -> ReturnType {
       // body
       return value
   }

   //  func        — keyword
   //  functionName — what you call it
   //  label       — what the caller sees (argument label)
   //  parameter   — what the function uses internally
   //  Type        — parameter type
   //  ReturnType  — what it gives back

 BASIC FUNCTION
 ===============
   func greet() {
       print("Hello, Swift!")
   }
   greet()
   // Output: Hello, Swift!

 FUNCTION WITH PARAMETERS
 =========================
   func greet(name: String) {
       print("Hello, \(name)!")
   }
   greet(name: "Alice")
   // Output: Hello, Alice!

 FUNCTION WITH RETURN VALUE
 ===========================
   func add(a: Int, b: Int) -> Int {
       return a + b
   }
   let result = add(a: 3, b: 4)
   print(result)
   // Output: 7

 FUNCTION WITH MULTIPLE RETURN VALUES (TUPLE)
 =============================================
   func minMax(array: [Int]) -> (min: Int, max: Int) {
       var min = array[0]
       var max = array[0]
       for value in array {
           if value < min { min = value }
           if value > max { max = value }
       }
       return (min, max)
   }
   let result2 = minMax(array: [3, 1, 8, 2, 9, 4])
   print(result2.min)
   // Output: 1
   print(result2.max)
   // Output: 9
   print(result2)
   // Output: (min: 1, max: 9)

 FUNCTION WITH OPTIONAL RETURN
 ==============================
   func findFirst(_ array: [Int],
                  where condition: (Int) -> Bool) -> Int? {
       for item in array {
           if condition(item) { return item }
       }
       return nil
   }
   let first = findFirst([2, 5, 8, 11, 14]) { $0 > 7 }
   print(first ?? "none")
   // Output: 8

   let none = findFirst([1, 2, 3]) { $0 > 99 }
   print(none ?? "none")
   // Output: none

 IMPLICIT RETURN (SINGLE EXPRESSION)
 =====================================
   // Single-expression functions can omit return:
   func square(_ n: Int) -> Int { n * n }
   func cube(_ n: Int)   -> Int { n * n * n }
   func isEven(_ n: Int) -> Bool { n % 2 == 0 }

   print(square(5))
   // Output: 25
   print(cube(3))
   // Output: 27
   print(isEven(4))
   // Output: true

 VOID FUNCTION (NO RETURN VALUE)
 ================================
   // These are equivalent:
   func doWork1()       { print("Working") }
   func doWork2() -> () { print("Working") }
   func doWork3() -> Void { print("Working") }

   doWork1()
   // Output: Working

 VARIADIC PARAMETERS
 ====================
   // Variadic — accepts zero or more values of a type:
   func sum(_ numbers: Int...) -> Int {
       return numbers.reduce(0, +)
   }
   func average(_ numbers: Double...) -> Double {
       guard !numbers.isEmpty else { return 0 }
       return numbers.reduce(0, +) / Double(numbers.count)
   }

   print(sum(1, 2, 3, 4, 5))
   // Output: 15
   print(sum())
   // Output: 0
   print(average(10.0, 20.0, 30.0))
   // Output: 20.0

   // Variadic with other params — variadic must come last:
   func log(level: String, messages: String...) {
       for msg in messages {
           print("[\(level)] \(msg)")
       }
   }
   log(level: "INFO", messages: "App started", "DB connected")
   // Output: [INFO] App started
   //         [INFO] DB connected

 DEFAULT PARAMETER VALUES
 =========================
   func createUser(name: String,
                    role: String = "member",
                    active: Bool = true) -> String {
       return "\(name) | \(role) | active: \(active)"
   }

   print(createUser(name: "Alice"))
   // Output: Alice | member | active: true
   print(createUser(name: "Bob", role: "admin"))
   // Output: Bob | admin | active: true
   print(createUser(name: "Carol", role: "guest", active: false))
   // Output: Carol | guest | active: false

 inout PARAMETERS
 =================
   // inout — modifies the original variable:
   func swapValues(_ a: inout Int, _ b: inout Int) {
       let temp = a
       a = b
       b = temp
   }

   var x = 10
   var y = 20
   swapValues(&x, &y)
   print(x)
   // Output: 20
   print(y)
   // Output: 10

   func doubleInPlace(_ n: inout Int) {
       n *= 2
   }
   var val = 7
   doubleInPlace(&val)
   print(val)
   // Output: 14

 FUNCTIONS AS FIRST-CLASS VALUES
 =================================
   // Functions are types — can be stored and passed:
   func add2(_ a: Int, _ b: Int) -> Int { a + b }
   func multiply(_ a: Int, _ b: Int) -> Int { a * b }
   func subtract(_ a: Int, _ b: Int) -> Int { a - b }

   // Store in variable:
   var operation: (Int, Int) -> Int = add2
   print(operation(3, 4))
   // Output: 7

   operation = multiply
   print(operation(3, 4))
   // Output: 12

   // Store in array:
   let operations: [(Int, Int) -> Int] = [add2, multiply, subtract]
   for op in operations {
       print(op(10, 3))
   }
   // Output: 13
   //         30
   //         7

   // Pass as parameter:
   func apply(_ a: Int, _ b: Int,
               using op: (Int, Int) -> Int) -> Int {
       return op(a, b)
   }
   print(apply(5, 3, using: add2))
   // Output: 8
   print(apply(5, 3, using: multiply))
   // Output: 15

   // Return from function:
   func makeMultiplier(factor: Int) -> (Int) -> Int {
       return { x in x * factor }
   }
   let triple = makeMultiplier(factor: 3)
   print(triple(7))
   // Output: 21
   print(triple(10))
   // Output: 30

 NESTED FUNCTIONS
 =================
   func processNumbers(_ numbers: [Int]) -> [Int] {
       // Helper nested inside:
       func isValid(_ n: Int) -> Bool {
           return n > 0 && n < 100
       }
       func transform(_ n: Int) -> Int {
           return n * 2 + 1
       }

       return numbers.filter(isValid).map(transform)
   }

   let input = [-5, 3, 150, 7, 42, 0, 99, 101]
   print(processNumbers(input))
   // Output: [7, 15, 85, 199]


 ================================================================
 PART 2 — PARAMETER LABELS IN DEPTH
 ================================================================

 WHAT ARE PARAMETER LABELS?
 ============================
 Every function parameter has TWO names:
   1. Argument label — used by the CALLER at the call site
   2. Parameter name — used INSIDE the function body

   func functionName(argumentLabel parameterName: Type)
   //                 ↑ caller uses  ↑ body uses

 This gives Swift functions readable, English-like call sites
 while keeping concise names inside the function body.

 THE THREE LABEL CONFIGURATIONS
 ================================

   // Config 1: Same name for both (most common):
   func greet(name: String) {
       print("Hello, \(name)!")     // uses 'name' internally
   }
   greet(name: "Alice")             // caller uses 'name'
   // Output: Hello, Alice!

   // Config 2: Different argument label and parameter name:
   func greet2(to person: String) {
       print("Hello, \(person)!")   // uses 'person' internally
   }
   greet2(to: "Bob")                // caller uses 'to'
   // Output: Hello, Bob!

   // Config 3: Omit argument label with underscore _:
   func greet3(_ person: String) {
       print("Hello, \(person)!")
   }
   greet3("Carol")                  // no label at call site
   // Output: Hello, Carol!

 PARAMETER LABELS — FULL EXAMPLE
 =================================
   // Without labels — hard to read:
   // func move(10, 20)  ← what does 10 and 20 mean?

   // With labels — reads like English:
   func move(from origin: String, to destination: String) {
       print("Moving from \(origin) to \(destination)")
   }
   move(from: "New York", to: "San Francisco")
   // Output: Moving from New York to San Francisco

   func insert(_ value: Int, at index: Int) {
       print("Inserting \(value) at index \(index)")
   }
   insert(42, at: 3)
   // Output: Inserting 42 at index 3

   func repeat(action: String, times count: Int) {
       for i in 1...count {
           print("\(i). \(action)")
       }
   }
   repeat(action: "Push-up", times: 3)
   // Output: 1. Push-up
   //         2. Push-up
   //         3. Push-up

 MIXING LABELED AND UNLABELED PARAMETERS
 =========================================
   func formatName(_ firstName: String,
                    _ lastName: String,
                    title: String = "") -> String {
       if title.isEmpty {
           return "\(firstName) \(lastName)"
       }
       return "\(title) \(firstName) \(lastName)"
   }

   print(formatName("John", "Smith"))
   // Output: John Smith
   print(formatName("John", "Smith", title: "Dr."))
   // Output: Dr. John Smith

 LABEL DESIGN BEST PRACTICES
 =============================
   // Rule 1: Labels should form a grammatical phrase:
   func addItem(_ item: String, to list: String) {
       print("Adding \(item) to \(list)")
   }
   addItem("milk", to: "shopping list")
   // Output: Adding milk to shopping list

   // Rule 2: Omit label when type is obvious from function name:
   func sqrt(_ number: Double) -> Double { number.squareRoot() }
   print(sqrt(16))
   // Output: 4.0

   // Rule 3: Use prepositions for clarity:
   func convert(_ value: Double, from source: String,
                 to target: String) -> String {
       return "\(value) \(source) → \(target)"
   }
   print(convert(100, from: "USD", to: "EUR"))
   // Output: 100.0 USD → EUR

   // Rule 4: Match Swift Standard Library style:
   func contains(_ element: Int, in array: [Int]) -> Bool {
       return array.contains(element)
   }
   print(contains(3, in: [1, 2, 3, 4, 5]))
   // Output: true

 PARAMETER LABELS IN INITIALIZERS
 ===================================
   struct Measurement {
       let value: Double
       let unit:  String

       // Labels in init work same as functions:
       init(_ value: Double, unit: String) {
           self.value = value
           self.unit  = unit
       }

       func converted(to targetUnit: String,
                       factor: Double) -> Measurement {
           return Measurement(value * factor, unit: targetUnit)
       }
   }

   let meters  = Measurement(5.0, unit: "m")
   let cm      = meters.converted(to: "cm", factor: 100)
   print(cm.value)
   // Output: 500.0
   print(cm.unit)
   // Output: cm

 EXTERNAL AND INTERNAL LABELS SIDE BY SIDE
 ===========================================
   func configure(
       _ view: String,           // no external label
       width w: Double,          // external: width, internal: w
       height h: Double,         // external: height, internal: h
       backgroundColor bg: String = "white",
       isHidden hidden: Bool = false
   ) -> String {
       return "\(view) \(w)x\(h) bg:\(bg) hidden:\(hidden)"
   }

   let result3 = configure("Button",
                             width: 100,
                             height: 44,
                             backgroundColor: "blue",
                             isHidden: false)
   print(result3)
   // Output: Button 100.0x44.0 bg:blue hidden:false

 PARAMETER LABELS IN PROTOCOLS
 ================================
   protocol Drawable {
       func draw(at x: Double, y: Double)
       func resize(by factor: Double)
       func setColor(to color: String)
   }

   struct Canvas: Drawable {
       var items: [String] = []

       mutating func draw(at x: Double, y: Double) {
           items.append("Drawn at (\(x), \(y))")
           print("Canvas: drawing at (\(x), \(y))")
       }
       mutating func resize(by factor: Double) {
           print("Canvas: resizing by \(factor)")
       }
       mutating func setColor(to color: String) {
           print("Canvas: color set to \(color)")
       }
   }

   var canvas = Canvas()
   canvas.draw(at: 10, y: 20)
   // Output: Canvas: drawing at (10.0, 20.0)
   canvas.resize(by: 1.5)
   // Output: Canvas: resizing by 1.5
   canvas.setColor(to: "red")
   // Output: Canvas: color set to red

 OVERLOADING WITH DIFFERENT LABELS
 ====================================
   // Functions can be overloaded using different labels:
   struct DataProcessor {
       func process(_ number: Int) -> String {
           return "Int: \(number)"
       }
       func process(_ number: Double) -> String {
           return "Double: \(number)"
       }
       func process(_ text: String) -> String {
           return "String: \(text)"
       }
       func process(csv text: String) -> [String] {
           return text.split(separator: ",").map(String.init)
       }
       func process(json text: String) -> String {
           return "JSON parsed: \(text.count) chars"
       }
   }

   let dp = DataProcessor()
   print(dp.process(42))
   // Output: Int: 42
   print(dp.process(3.14))
   // Output: Double: 3.14
   print(dp.process("hello"))
   // Output: String: hello
   print(dp.process(csv: "a,b,c"))
   // Output: ["a", "b", "c"]
   print(dp.process(json: "{\"key\":\"value\"}"))
   // Output: JSON parsed: 15 chars


 ================================================================
 PART 3 — CLOSURES IN DEPTH
 ================================================================

 WHAT IS A CLOSURE?
 ===================
 A closure is a self-contained block of code that
 can be stored in a variable, passed as a parameter,
 or returned from a function. Closures "capture"
 (remember) variables from their surrounding context.

 THREE FORMS OF CLOSURES
 ========================
   // 1. Global functions — named, no capture:
   func doubled(_ n: Int) -> Int { n * 2 }

   // 2. Nested functions — named, can capture:
   func outer() {
       var count = 0
       func increment() { count += 1; print(count) }
       increment()
   }

   // 3. Closure expressions — unnamed, inline:
   let double2 = { (n: Int) -> Int in n * 2 }

 CLOSURE SYNTAX PROGRESSION
 ============================
   // Full closure syntax:
   let fullClosure = { (a: Int, b: Int) -> Int in
       return a + b
   }
   print(fullClosure(3, 4))
   // Output: 7

   // Infer types from context:
   let numbers2 = [3, 1, 4, 1, 5, 9, 2, 6]
   let sorted3 = numbers2.sorted(by: { (a: Int, b: Int) -> Bool in
       return a < b
   })
   print(sorted3)
   // Output: [1, 1, 2, 3, 4, 5, 6, 9]

   // Type inference — omit types:
   let sorted4 = numbers2.sorted(by: { a, b in a < b })
   print(sorted4)
   // Output: [1, 1, 2, 3, 4, 5, 6, 9]

   // Implicit return — omit return:
   let sorted5 = numbers2.sorted(by: { a, b in a < b })
   print(sorted5)
   // Output: [1, 1, 2, 3, 4, 5, 6, 9]

   // Shorthand argument names $0, $1:
   let sorted6 = numbers2.sorted(by: { $0 < $1 })
   print(sorted6)
   // Output: [1, 1, 2, 3, 4, 5, 6, 9]

   // Operator function (most concise):
   let sorted7 = numbers2.sorted(by: <)
   print(sorted7)
   // Output: [1, 1, 2, 3, 4, 5, 6, 9]

 CLOSURES CAPTURING VALUES
 ==========================
   // Closures capture variables from surrounding scope:
   func makeCounter(start: Int = 0,
                     step:  Int = 1) -> () -> Int {
       var current = start       // captured by closure
       return {
           let value = current
           current += step
           return value
       }
   }

   let counter1 = makeCounter()
   print(counter1())   // Output: 0
   print(counter1())   // Output: 1
   print(counter1())   // Output: 2
   print(counter1())   // Output: 3

   let counter2 = makeCounter(start: 10, step: 5)
   print(counter2())   // Output: 10
   print(counter2())   // Output: 15

   // counter1 and counter2 have INDEPENDENT captured state:
   print(counter1())   // Output: 4   (continues from where left off)

 CLOSURE CAPTURE LIST
 =====================
   // Capture list controls HOW values are captured:
   var multiplier = 3

   // Without capture list — captures by reference:
   let multiplyRef = { (n: Int) -> Int in n * multiplier }

   // With capture list — captures by VALUE at creation time:
   let multiplyVal = { [multiplier] (n: Int) -> Int in n * multiplier }

   multiplier = 10

   print(multiplyRef(5))   // uses current value of multiplier
   // Output: 50            (multiplier is now 10)

   print(multiplyVal(5))   // uses captured value at creation
   // Output: 15            (captured when multiplier was 3)

 CLOSURES AS FUNCTION PARAMETERS
 =================================
   func transform(_ values: [Int],
                   using t: (Int) -> Int) -> [Int] {
       return values.map(t)
   }

   let doubled2 = transform([1, 2, 3, 4, 5]) { $0 * 2 }
   print(doubled2)
   // Output: [2, 4, 6, 8, 10]

   let squared = transform([1, 2, 3, 4, 5]) { $0 * $0 }
   print(squared)
   // Output: [1, 4, 9, 16, 25]

   func doTwice(_ action: () -> Void) {
       action()
       action()
   }
   doTwice { print("Swift is awesome") }
   // Output: Swift is awesome
   //         Swift is awesome

 MAP, FILTER, REDUCE WITH CLOSURES
 ===================================
   let scores = [88, 72, 95, 61, 84, 90, 55, 77]

   // map — transform each element:
   let grade = scores.map { score -> String in
       switch score {
       case 90...100: return "A"
       case 80..<90:  return "B"
       case 70..<80:  return "C"
       case 60..<70:  return "D"
       default:       return "F"
       }
   }
   print(grade)
   // Output: ["B", "C", "A", "D", "B", "A", "F", "C"]

   // filter — keep elements matching condition:
   let passing = scores.filter { $0 >= 70 }
   print(passing)
   // Output: [88, 72, 95, 84, 90, 77]

   // reduce — combine all elements into one value:
   let total = scores.reduce(0) { sum, score in sum + score }
   print(total)
   // Output: 622
   let average2 = Double(total) / Double(scores.count)
   print(String(format: "Average: %.1f", average2))
   // Output: Average: 77.8

   // Chaining:
   let topStudentAvg = scores
       .filter { $0 >= 80 }
       .map    { Double($0) }
       .reduce(0, +) / Double(scores.filter { $0 >= 80 }.count)
   print(String(format: "Top student avg: %.1f", topStudentAvg))
   // Output: Top student avg: 89.3


 ================================================================
 PART 4 — TRAILING CLOSURES IN DEPTH
 ================================================================

 WHAT IS A TRAILING CLOSURE?
 =============================
 When a closure is the LAST argument to a function,
 it can be written OUTSIDE the parentheses. This is
 called trailing closure syntax and improves readability
 for closures with multiple lines.

 TRAILING CLOSURE — BASIC
 =========================
   func doOperation(value: Int,
                     operation: (Int) -> Int) -> Int {
       return operation(value)
   }

   // Standard syntax:
   let r1 = doOperation(value: 10, operation: { $0 * 3 })
   print(r1)
   // Output: 30

   // Trailing closure syntax:
   let r2 = doOperation(value: 10) { $0 * 3 }
   print(r2)
   // Output: 30

   // Trailing closure with multiple lines:
   let r3 = doOperation(value: 10) { value in
       let doubled3 = value * 2
       let plusTen  = doubled3 + 10
       return plusTen
   }
   print(r3)
   // Output: 30

 TRAILING CLOSURE — ONLY ARGUMENT
 ==================================
   func execute(_ block: () -> Void) {
       print("Before")
       block()
       print("After")
   }

   // When closure is the ONLY argument,
   // parentheses can be omitted entirely:
   execute {
       print("Executing")
   }
   // Output: Before
   //         Executing
   //         After

   // Without trailing syntax:
   execute({ print("Executing") })
   // Output: Before
   //         Executing
   //         After

 MULTIPLE TRAILING CLOSURES
 ============================
   // Swift 5.3+: Multiple trailing closures use
   // the first without a label, rest with labels:
   func loadData(
       from url: String,
       onSuccess: (String) -> Void,
       onFailure: (String) -> Void
   ) {
       if url.starts(with: "https") {
           onSuccess("Data from \(url)")
       } else {
           onFailure("Insecure URL: \(url)")
       }
   }

   // Standard syntax:
   loadData(
       from: "https://api.example.com",
       onSuccess: { data in print("Success: \(data)") },
       onFailure: { error in print("Error: \(error)") }
   )
   // Output: Success: Data from https://api.example.com

   // Multiple trailing closure syntax:
   loadData(from: "https://api.example.com") { data in
       print("Success: \(data)")
   } onFailure: { error in
       print("Error: \(error)")
   }
   // Output: Success: Data from https://api.example.com

   loadData(from: "http://insecure.com") { data in
       print("Success: \(data)")
   } onFailure: { error in
       print("Error: \(error)")
   }
   // Output: Error: Insecure URL: http://insecure.com

 TRAILING CLOSURES WITH STANDARD LIBRARY
 =========================================
   let items2 = [5, 3, 8, 1, 9, 2, 7, 4, 6]

   // sorted — trailing closure:
   let asc = items2.sorted { $0 < $1 }
   print(asc)
   // Output: [1, 2, 3, 4, 5, 6, 7, 8, 9]

   // filter — trailing closure:
   let evens = items2.filter { $0 % 2 == 0 }
   print(evens)
   // Output: [8, 2, 4, 6]

   // forEach — trailing closure:
   [1, 2, 3].forEach { print("Item: \($0)") }
   // Output: Item: 1
   //         Item: 2
   //         Item: 3

   // compactMap — trailing closure:
   let strings = ["1", "two", "3", "four", "5"]
   let ints = strings.compactMap { Int($0) }
   print(ints)
   // Output: [1, 3, 5]

 TRAILING CLOSURE READABILITY PATTERNS
 ========================================
   // Animation-style API using trailing closure:
   struct Animator2 {
       static func animate(duration: Double,
                            animations: () -> Void,
                            completion: ((Bool) -> Void)? = nil) {
           print("Animating for \(duration)s")
           animations()
           completion?(true)
       }
   }

   Animator2.animate(duration: 0.3) {
       print("Moving view to new position")
       print("Fading in content")
   } completion: { finished in
       print("Animation complete: \(finished)")
   }
   // Output: Animating for 0.3s
   //         Moving view to new position
   //         Fading in content
   //         Animation complete: true

   // Builder-style pattern with trailing closure:
   struct AlertBuilder {
       var title:   String = ""
       var message: String = ""
       var actions: [String] = []

       mutating func configure(_ block: (inout AlertBuilder) -> Void) {
           block(&self)
       }
   }

   var alert = AlertBuilder()
   alert.configure { config in
       config.title   = "Delete Item"
       config.message = "Are you sure?"
       config.actions = ["Cancel", "Delete"]
   }
   print(alert.title)
   // Output: Delete Item
   print(alert.actions)
   // Output: ["Cancel", "Delete"]


 ================================================================
 PART 5 — ESCAPING CLOSURES IN DEPTH
 ================================================================

 WHAT IS AN ESCAPING CLOSURE?
 ==============================
 A closure is "escaping" when it can OUTLIVE the function
 that receives it — meaning the closure is stored and called
 AFTER the function has returned.
 Mark with @escaping keyword on the parameter type.

 NON-ESCAPING vs ESCAPING TIMELINE
 ===================================
   // NON-ESCAPING:
   // func call ──► function starts
   //               closure runs inside function
   //               function ends
   //               closure is gone
   //
   // ESCAPING:
   // func call ──► function starts
   //               closure stored (property, array, async)
   //               function ends  ← closure outlives this
   //               closure runs later
   //               closure is eventually freed

 NON-ESCAPING CLOSURE (DEFAULT)
 ================================
   // All closure parameters are non-escaping by default.
   // Closure MUST finish before the function returns.
   func performNow(action: () -> Void) {
       print("Before action")
       action()                    // runs NOW — inline
       print("After action")
   }   // action is done by here — non-escaping

   performNow {
       print("Action executing")
   }
   // Output: Before action
   //         Action executing
   //         After action

   // Non-escaping closures:
   // - Cannot be stored in a property
   // - Cannot be passed to another @escaping function
   // - No need for [weak self] (no cycle risk)
   // - Compiler can optimize better (no heap allocation needed)

 ESCAPING CLOSURE — STORED IN PROPERTY
 ========================================
   class EventHandler {
       var onComplete: (() -> Void)?     // stored property

       // @escaping — closure will be stored and called later:
       func register(completion: @escaping () -> Void) {
           onComplete = completion        // stored — outlives function
           print("Completion registered")
       }

       func trigger() {
           print("Triggering...")
           onComplete?()
       }

       deinit { print("EventHandler freed") }
   }

   var handler: EventHandler? = EventHandler()
   handler!.register {
       print("Completion fired!")
   }
   // Output: Completion registered

   handler!.trigger()
   // Output: Triggering...
   //         Completion fired!

   handler = nil
   // Output: EventHandler freed

 ESCAPING CLOSURE — ASYNC OPERATIONS
 =====================================
   func fetchData(from url: String,
                   completion: @escaping (String?, Error?) -> Void) {
       print("Starting fetch from \(url)")
       // Simulate async — closure runs AFTER function returns:
       DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
           if url.contains("error") {
               completion(nil, NSError(domain: "NetError",
                                        code: 404, userInfo: nil))
           } else {
               completion("Response data from \(url)", nil)
           }
       }
       print("Function returning — closure will run later")
   }

   fetchData(from: "https://api.example.com") { data, error in
       if let data = data {
           print("Got: \(data)")
       } else if let error = error {
           print("Error: \(error.localizedDescription)")
       }
   }
   // Output: Starting fetch from https://api.example.com
   //         Function returning — closure will run later
   //         Got: Response data from https://api.example.com

 ESCAPING CLOSURE — STORED IN ARRAY
 ====================================
   class TaskScheduler {
       private var pendingTasks: [() -> Void] = []

       func schedule(_ task: @escaping () -> Void) {
           pendingTasks.append(task)    // stored in array
           print("Task scheduled. Pending: \(pendingTasks.count)")
       }

       func runAll() {
           print("Running \(pendingTasks.count) tasks")
           pendingTasks.forEach { $0() }
           pendingTasks.removeAll()
       }
   }

   let scheduler = TaskScheduler()
   scheduler.schedule { print("Task 1: send email") }
   // Output: Task scheduled. Pending: 1
   scheduler.schedule { print("Task 2: generate report") }
   // Output: Task scheduled. Pending: 2
   scheduler.schedule { print("Task 3: update database") }
   // Output: Task scheduled. Pending: 3

   scheduler.runAll()
   // Output: Running 3 tasks
   //         Task 1: send email
   //         Task 2: generate report
   //         Task 3: update database

 ESCAPING + [weak self] — CYCLE PREVENTION
 ==========================================
   class DownloadManager {
       var fileName = "data.json"
       var onComplete: ((String) -> Void)?

       func startDownload() {
           // [weak self] — avoids retain cycle:
           onComplete = { [weak self] result in
               guard let self = self else {
                   print("DownloadManager was freed")
                   return
               }
               print("Downloaded \(result) for \(self.fileName)")
           }
           print("Download started for \(fileName)")
       }

       func completeDownload(with result: String) {
           onComplete?(result)
       }

       deinit { print("DownloadManager freed") }
   }

   var dm: DownloadManager? = DownloadManager()
   dm!.startDownload()
   // Output: Download started for data.json

   dm!.completeDownload(with: "1024 bytes")
   // Output: Downloaded 1024 bytes for data.json

   dm = nil
   // Output: DownloadManager freed ✓
   // No leak — [weak self] prevented cycle

 ESCAPING vs NON-ESCAPING — self REQUIREMENT
 =============================================
   class Processor2 {
       var label = "CPU"

       // Non-escaping — self implicit (no [weak self] needed):
       func runSync(action: () -> Void) {
           action()
       }

       // @escaping — self must be explicit:
       func runAsync(action: @escaping () -> Void) {
           DispatchQueue.global().async {
               action()
           }
       }

       func start() {
           // Non-escaping — implicit self:
           runSync {
               print("Sync: \(label)")     // no self. needed
           }

           // @escaping — explicit self required:
           runAsync { [weak self] in
               guard let self = self else { return }
               print("Async: \(self.label)")  // self. required
           }
       }

       deinit { print("Processor2 freed") }
   }

   var proc: Processor2? = Processor2()
   proc!.start()
   // Output: Sync: CPU
   //         Async: CPU
   proc = nil
   // Output: Processor2 freed ✓

 ESCAPING WITH COMPLETIONHANDLER PATTERN
 =========================================
   enum NetworkError: Error {
       case invalidURL
       case noData
       case serverError(Int)
   }

   struct APIClient {
       typealias Handler<T> = (Result<T, NetworkError>) -> Void

       func get<T: Decodable>(url: String,
                               completion: @escaping Handler<T>) {
           guard url.starts(with: "https") else {
               completion(.failure(.invalidURL))
               return
           }
           // Simulate success:
           print("GET \(url)")
           // In real code, URLSession would call completion async
       }

       func post(url: String,
                  body: String,
                  completion: @escaping Handler<String>) {
           guard url.starts(with: "https") else {
               completion(.failure(.invalidURL))
               return
           }
           print("POST to \(url) body:\(body)")
           completion(.success("Created"))
       }
   }

   let client = APIClient()
   client.post(url: "https://api.example.com/users",
                body: "{\"name\":\"Alice\"}") { result in
       switch result {
       case .success(let msg): print("Post result: \(msg)")
       case .failure(let err): print("Post error: \(err)")
       }
   }
   // Output: POST to https://api.example.com/users
   //         body:{"name":"Alice"}
   //         Post result: Created

   client.post(url: "http://insecure.com",
                body: "data") { result in
       switch result {
       case .success(let msg): print("Post result: \(msg)")
       case .failure(let err): print("Post error: \(err)")
       }
   }
   // Output: Post error: invalidURL


 ================================================================
 PART 6 — NON-ESCAPING CLOSURES IN DEPTH
 ================================================================

 WHAT IS A NON-ESCAPING CLOSURE?
 =================================
 A non-escaping closure is guaranteed to execute
 within the scope of the function that receives it.
 This is the DEFAULT for all closure parameters.
 Benefits:
   - Compiler can optimize memory (no heap allocation)
   - No retain cycles — [weak self] not needed
   - Self can be used implicitly
   - Compiler can inline the closure at call site

 NON-ESCAPING — GUARANTEED EXECUTION WITHIN FUNCTION
 =====================================================
   func withLogging(label: String,
                     action: () -> Void) {
       print("[\(label)] START")
       action()              // must run before return
       print("[\(label)] END")
   }   // action is guaranteed done by here

   withLogging(label: "DB") {
       print("  Querying database")
       print("  Processing results")
   }
   // Output: [DB] START
   //         Querying database
   //         Processing results
   //         [DB] END

 NON-ESCAPING — SAFE IMPLICIT self
 ====================================
   class ImageProcessor {
       var filter = "Sepia"
       var brightness = 1.0

       // Non-escaping — self implicit:
       func applyFilter(to pixels: [Int],
                         transform: ([Int]) -> [Int]) -> [Int] {
           print("Applying \(filter) filter")  // implicit self
           return transform(pixels)
       }

       func process() {
           let pixels = [100, 150, 200, 250]
           let result4 = applyFilter(to: pixels) { p in
               // No [weak self] needed — non-escaping
               print("Processing with brightness \(brightness)")
               return p.map { Int(Double($0) * brightness) }
           }
           print(result4)
       }
   }

   let imgProc = ImageProcessor()
   imgProc.process()
   // Output: Applying Sepia filter
   //         Processing with brightness 1.0
   //         [100, 150, 200, 250]

 NON-ESCAPING — DEFER AND RESULT BUILDER STYLE
 ================================================
   func measure(label: String,
                 block: () -> Void) {
       let start = 0    // simplified (no Date)
       block()
       let elapsed = 0  // simplified
       print("\(label): \(elapsed)ms (block ran synchronously)")
   }

   measure(label: "Sort") {
       var arr = [5, 3, 8, 1, 9]
       arr.sort()
       print("Sorted: \(arr)")
   }
   // Output: Sorted: [5, 3, 8, 1, 9] → [1, 3, 5, 8, 9]
   //         Sort: 0ms (block ran synchronously)

   // Non-escaping closures used in:
   // - map, filter, reduce
   // - sort, sorted
   // - forEach
   // - withUnsafePointer
   // - DispatchQueue.sync (sync is non-escaping)
   // - Custom higher-order functions

 NON-ESCAPING WITH withoutActuallyEscaping
 ==========================================
   // When you KNOW a closure won't escape but the compiler
   // can't verify it — use withoutActuallyEscaping:

   func customFilter<T>(_ array: [T],
                         matching predicate: (T) -> Bool) -> [T] {
       // We need to pass to a function expecting @escaping,
       // but we know it won't actually escape:
       var result5: [T] = []
       withoutActuallyEscaping(predicate) { escapingPredicate in
           // escapingPredicate is treated as @escaping here
           // but we guarantee it won't actually escape
           result5 = array.filter(escapingPredicate)
       }
       return result5
   }

   let filtered = customFilter([1, 2, 3, 4, 5, 6]) { $0 % 2 == 0 }
   print(filtered)
   // Output: [2, 4, 6]


 ================================================================
 PART 7 — AUTOCLOSURES IN DEPTH
 ================================================================

 WHAT IS AN AUTOCLOSURE?
 ========================
 @autoclosure automatically wraps an expression in
 a closure — the caller writes a plain expression,
 Swift wraps it in { } automatically.
 Benefits:
   - Cleaner call sites (no braces needed by caller)
   - Lazy evaluation — expression only runs when called
   - Used for assert, precondition, short-circuit logic

 AUTOCLOSURE — BASIC
 ====================
   // Without @autoclosure — caller must write { }:
   func evaluateManual(condition: () -> Bool) {
       if condition() {
           print("Condition passed")
       } else {
           print("Condition failed")
       }
   }
   evaluateManual(condition: { 2 + 2 == 4 })
   // Output: Condition passed

   // With @autoclosure — caller writes plain expression:
   func evaluate(condition: @autoclosure () -> Bool) {
       if condition() {
           print("Condition passed")
       } else {
           print("Condition failed")
       }
   }
   evaluate(condition: 2 + 2 == 4)   // no braces!
   // Output: Condition passed
   evaluate(condition: 1 > 5)
   // Output: Condition failed

 AUTOCLOSURE — LAZY EVALUATION
 ================================
   // Key benefit: expression NOT evaluated until closure is called.
   // This enables short-circuit behavior and deferred work.

   var expensiveCallCount = 0
   func expensiveCalculation() -> Int {
       expensiveCallCount += 1
       print("Expensive calculation running (#\(expensiveCallCount))")
       return 42
   }

   func executeIf(_ condition: Bool,
                   then action: @autoclosure () -> Void) {
       if condition {
           action()    // only evaluated when condition is true
       }
   }

   expensiveCallCount = 0
   executeIf(false, then: expensiveCalculation())
   print("Call count when false: \(expensiveCallCount)")
   // Output: Call count when false: 0   ← NOT evaluated

   executeIf(true, then: expensiveCalculation())
   // Output: Expensive calculation running (#1)
   print("Call count when true: \(expensiveCallCount)")
   // Output: Call count when true: 1    ← evaluated once

 AUTOCLOSURE — CUSTOM ASSERT
 =============================
   func myAssert(_ condition: @autoclosure () -> Bool,
                  _ message: @autoclosure () -> String,
                  file: String = #file,
                  line: Int    = #line) {
       if !condition() {
           print("ASSERTION FAILED: \(message())")
           print("  File: \(file), Line: \(line)")
           // In production: fatalError(message())
       }
   }

   let x2 = 5
   myAssert(x2 > 0, "x2 must be positive")
   // Output: (nothing — condition passes)

   myAssert(x2 > 10, "x2 must be greater than 10")
   // Output: ASSERTION FAILED: x2 must be greater than 10
   //         File: main.swift, Line: ...

   // Both arguments are @autoclosure:
   // condition: x2 > 10  → wrapped as { x2 > 10 }
   // message: "x2 must..." → wrapped as { "x2 must..." }
   // Message string is ONLY built if condition fails

 AUTOCLOSURE — SHORT-CIRCUIT LOGIC
 ====================================
   func logIfDebug(isDebug: Bool,
                    message: @autoclosure () -> String) {
       guard isDebug else { return }
       print("[DEBUG] \(message())")    // only evaluated in debug
   }

   let debugMode = true
   logIfDebug(isDebug: debugMode,
               message: "Current state: \([1,2,3].map { $0 * 2 })")
   // Output: [DEBUG] Current state: [2, 4, 6]

   logIfDebug(isDebug: false,
               message: "This is never computed")
   // Output: (nothing — message never evaluated)

 AUTOCLOSURE — STANDARD LIBRARY EXAMPLES
 =========================================
   // assert — both are @autoclosure:
   // func assert(_ condition: @autoclosure () -> Bool,
   //             _ message:   @autoclosure () -> String = "")

   // precondition:
   // func precondition(_ condition: @autoclosure () -> Bool,
   //                   _ message:   @autoclosure () -> String = "")

   // ?? (nil coalescing) — right side is @autoclosure:
   // func ?? <T>(optional: T?,
   //             defaultValue: @autoclosure () -> T) -> T

   var name2: String? = nil
   print(name2 ?? "Anonymous")    // "Anonymous" only if nil
   // Output: Anonymous

   name2 = "Alice"
   print(name2 ?? "Anonymous")    // "Anonymous" NOT evaluated
   // Output: Alice

 AUTOCLOSURE — STORED (ESCAPING)
 =================================
   // To store an autoclosure, add @escaping:
   class LazyLogger {
       var messages: [() -> String] = []

       // @autoclosure @escaping — wraps and stores:
       func enqueue(_ message: @autoclosure @escaping () -> String) {
           messages.append(message)
           print("Message enqueued (\(messages.count) pending)")
       }

       func flushAll() {
           messages.forEach { print("[LOG] \($0())") }
           messages.removeAll()
       }
   }

   let logger2 = LazyLogger()
   let status = "running"
   logger2.enqueue("Server status: \(status)")
   // Output: Message enqueued (1 pending)
   logger2.enqueue("Memory: \(1024) MB")
   // Output: Message enqueued (2 pending)
   logger2.enqueue("CPU cores: \(8)")
   // Output: Message enqueued (3 pending)

   logger2.flushAll()
   // Output: [LOG] Server status: running
   //         [LOG] Memory: 1024 MB
   //         [LOG] CPU cores: 8

 AUTOCLOSURE vs REGULAR CLOSURE COMPARISON
 ==========================================
   // Regular closure parameter — caller must use { }:
   func runIfTrue1(_ condition: Bool,
                    action: () -> Void) {
       if condition { action() }
   }
   runIfTrue1(true, action: { print("Ran") })
   // Output: Ran

   // @autoclosure — caller uses plain expression:
   func runIfTrue2(_ condition: Bool,
                    action: @autoclosure () -> Void) {
       if condition { action() }
   }
   runIfTrue2(true, action: print("Ran"))
   // Output: Ran

   // Multiple @autoclosure:
   func choose(_ condition: @autoclosure () -> Bool,
                ifTrue:  @autoclosure () -> String,
                ifFalse: @autoclosure () -> String) -> String {
       return condition() ? ifTrue() : ifFalse()
   }

   let score2 = 85
   let result6 = choose(score2 >= 60,
                         ifTrue:  "Pass",
                         ifFalse: "Fail")
   print(result6)
   // Output: Pass


 ================================================================
 PART 8 — ADVANCED CLOSURE PATTERNS
 ================================================================

 CURRYING AND PARTIAL APPLICATION
 ==================================
   // Currying — transform (a, b) -> c into a -> (b -> c):
   func add3(_ a: Int) -> (Int) -> Int {
       return { b in a + b }
   }

   let addFive2 = add3(5)      // partially applied
   let addTen2  = add3(10)

   print(addFive2(3))
   // Output: 8
   print(addTen2(3))
   // Output: 13

   [1, 2, 3, 4, 5].map(addFive2).forEach { print($0) }
   // Output: 6
   //         7
   //         8
   //         9
   //         10

   // Multi-level currying:
   func multiply2(_ a: Int) -> (Int) -> (Int) -> Int {
       return { b in
           return { c in a * b * c }
       }
   }
   let result7 = multiply2(2)(3)(4)
   print(result7)
   // Output: 24

 FUNCTION COMPOSITION
 =====================
   // Compose two functions: (B -> C) and (A -> B) into (A -> C)
   func compose<A, B, C>(_ f: @escaping (B) -> C,
                           _ g: @escaping (A) -> B) -> (A) -> C {
       return { a in f(g(a)) }
   }

   let double4  = { (n: Int) -> Int in n * 2 }
   let addOne   = { (n: Int) -> Int in n + 1 }
   let square2  = { (n: Int) -> Int in n * n }

   let doubleThenAddOne = compose(addOne, double4)
   print(doubleThenAddOne(5))
   // Output: 11   (5 * 2 = 10, 10 + 1 = 11)

   let squareThenDouble = compose(double4, square2)
   print(squareThenDouble(4))
   // Output: 32   (4 * 4 = 16, 16 * 2 = 32)

   // Pipe operator — reverse compose direction:
   infix operator |>: AdditionPrecedence
   func |> <A, B>(_ value: A, _ transform: (A) -> B) -> B {
       return transform(value)
   }

   let result8 = 5 |> double4 |> addOne |> square2
   print(result8)
   // Output: 121   (5*2=10, 10+1=11, 11*11=121)

 MEMOIZATION WITH CLOSURES
 ==========================
   // Cache expensive function results:
   func memoize<T: Hashable, U>(_ f: @escaping (T) -> U)
       -> (T) -> U {
       var cache: [T: U] = [:]
       return { input in
           if let cached = cache[input] {
               print("Cache HIT for \(input)")
               return cached
           }
           print("Cache MISS for \(input) — computing")
           let result9 = f(input)
           cache[input] = result9
           return result9
       }
   }

   // Fibonacci — slow without memoization:
   func slowFib(_ n: Int) -> Int {
       if n <= 1 { return n }
       return slowFib(n - 1) + slowFib(n - 2)
   }

   // Memoized version:
   let fastFib = memoize(slowFib)
   print(fastFib(10))
   // Output: Cache MISS for 10 — computing
   //         55
   print(fastFib(10))
   // Output: Cache HIT for 10
   //         55
   print(fastFib(7))
   // Output: Cache MISS for 7 — computing
   //         13

 CLOSURE AS STRATEGY PATTERN
 ==============================
   struct Sorter<T> {
       var strategy: (T, T) -> Bool

       func sort(_ array: [T]) -> [T] {
           return array.sorted(by: strategy)
       }
   }

   // Different strategies:
   let ascendingInt  = Sorter<Int>  { $0 < $1 }
   let descendingInt = Sorter<Int>  { $0 > $1 }
   let byLength      = Sorter<String> { $0.count < $1.count }
   let alphabetical  = Sorter<String> { $0 < $1 }

   let nums = [5, 2, 8, 1, 9, 3]
   print(ascendingInt.sort(nums))
   // Output: [1, 2, 3, 5, 8, 9]
   print(descendingInt.sort(nums))
   // Output: [9, 8, 5, 3, 2, 1]

   let words = ["banana", "kiwi", "apple", "fig", "mango"]
   print(byLength.sort(words))
   // Output: ["fig", "kiwi", "apple", "mango", "banana"]
   print(alphabetical.sort(words))
   // Output: ["apple", "banana", "fig", "kiwi", "mango"]

 CLOSURE AS MIDDLEWARE/PIPELINE
 ================================
   typealias Middleware = (String) -> String

   func pipeline(_ middlewares: [Middleware]) -> Middleware {
       return { input in
           middlewares.reduce(input) { current, mw in mw(current) }
       }
   }

   let trim      : Middleware = { $0.trimmingCharacters(in: .whitespaces) }
   let lowercase : Middleware = { $0.lowercased() }
   let removeSpaces: Middleware = { $0.replacingOccurrences(of: " ", with: "_") }
   let addPrefix : Middleware = { "user_\($0)" }

   let processUsername = pipeline([trim, lowercase, removeSpaces, addPrefix])
   print(processUsername("  Alice Smith  "))
   // Output: user_alice_smith
   print(processUsername("  Bob Jones  "))
   // Output: user_bob_jones

 RECURSIVE CLOSURES
 ====================
   // Closures cannot directly recurse — use var:
   // func or use a named var with explicit type:
 var factorial: (Int) -> Int = { _ in 0 }  // placeholder type

 factorial = { n in
     n <= 1 ? 1 : n * factorial(n - 1)     // recursive call OK
 }

 print(factorial(5))
 // Output: 120
 print(factorial(6))
 // Output: 720
 print(factorial(0))
 // Output: 1

 // Recursive closure — Fibonacci:
 var fib: (Int) -> Int = { _ in 0 }
 fib = { n in
     n <= 1 ? n : fib(n - 1) + fib(n - 2)
 }
 print(fib(10))
 // Output: 55

CLOSURE RETURNING CLOSURE (HIGHER ORDER)
==========================================
 // Function factory — returns specialized closures:
 func makeValidator(min: Int,
                     max: Int,
                     label: String) -> (Int) -> String {
     return { value in
         switch value {
         case ..<min:
             return "\(label) too low: \(value) (min: \(min))"
         case (max + 1)...:
             return "\(label) too high: \(value) (max: \(max))"
         default:
             return "\(label) OK: \(value)"
         }
     }
 }

 let validateAge    = makeValidator(min: 0,    max: 150,  label: "Age")
 let validateScore  = makeValidator(min: 0,    max: 100,  label: "Score")
 let validatePort   = makeValidator(min: 1024, max: 65535, label: "Port")

 print(validateAge(25))
 // Output: Age OK: 25
 print(validateAge(200))
 // Output: Age too high: 200 (max: 150)
 print(validateScore(-5))
 // Output: Score too low: -5 (min: 0)
 print(validatePort(8080))
 // Output: Port OK: 8080
 print(validatePort(80))
 // Output: Port too low: 80 (min: 1024)

CLOSURES WITH RESULT TYPE
==========================
 typealias TaskResult = Result<String, Error>
 typealias AsyncTask  = (@escaping (TaskResult) -> Void) -> Void

 enum TaskError: Error {
     case timeout
     case cancelled
     case serverError(String)
 }

 func runTask(named name: String,
               shouldFail: Bool = false) -> AsyncTask {
     return { completion in
         print("Running task: \(name)")
         DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
             if shouldFail {
                 completion(.failure(TaskError.serverError(name)))
             } else {
                 completion(.success("\(name) completed"))
             }
         }
     }
 }

 func sequential(_ tasks: [AsyncTask],
                  completion: @escaping ([TaskResult]) -> Void) {
     var results: [TaskResult] = []
     func runNext(index: Int) {
         guard index < tasks.count else {
             completion(results)
             return
         }
         tasks[index] { result in
             results.append(result)
             runNext(index: index + 1)
         }
     }
     runNext(index: 0)
 }

 let tasks: [AsyncTask] = [
     runTask(named: "Fetch"),
     runTask(named: "Parse"),
     runTask(named: "Save",  shouldFail: true),
     runTask(named: "Notify")
 ]

 sequential(tasks) { results in
     for result in results {
         switch result {
         case .success(let msg): print("✓ \(msg)")
         case .failure(let err): print("✗ \(err)")
         }
     }
 }
 // Output: Running task: Fetch
 //         Running task: Parse
 //         Running task: Save
 //         Running task: Notify
 //         ✓ Fetch completed
 //         ✓ Parse completed
 //         ✗ serverError("Save")
 //         ✓ Notify completed


================================================================
PART 9 — COMBINING ALL CLOSURE FEATURES
================================================================

COMBINING TRAILING + ESCAPING + AUTOCLOSURE
=============================================
 class ConditionalExecutor {
     private var conditions: [() -> Bool]     = []
     private var actions:    [() -> Void]     = []
     private var logMessages:[@autoclosure () -> String] = []

     // Trailing + escaping:
     func addRule(
         condition: @escaping () -> Bool,
         action:    @escaping () -> Void
     ) {
         conditions.append(condition)
         actions.append(action)
     }

     // Autoclosure + escaping:
     func log(_ message: @autoclosure @escaping () -> String) {
         logMessages.append(message)
     }

     func evaluate() {
         for (i, condition) in conditions.enumerated() {
             if condition() {
                 actions[i]()
             }
         }
         logMessages.forEach { print("[LOG] \($0())") }
     }
 }

 let executor = ConditionalExecutor()
 var temperature = 35.0
 var humidity    = 80.0

 // Trailing closure syntax for multi-line rules:
 executor.addRule(condition: { temperature > 30 }) {
     print("Alert: High temperature \(temperature)°C")
 }
 executor.addRule(condition: { humidity > 70 }) {
     print("Alert: High humidity \(humidity)%")
 }
 executor.addRule(condition: { temperature < 0 }) {
     print("Alert: Freezing conditions")
 }

 // Autoclosure for log messages:
 executor.log("Evaluation run at temp=\(temperature), hum=\(humidity)")
 executor.log("Conditions checked: \(3)")

 executor.evaluate()
 // Output: Alert: High temperature 35.0°C
 //         Alert: High humidity 80.0%
 //         [LOG] Evaluation run at temp=35.0, hum=80.0
 //         [LOG] Conditions checked: 3

COMBINING PARAMETER LABELS + ESCAPING + TRAILING
=================================================
 struct EventSystem {
     typealias Handler = (String) -> Void

     private var handlers: [String: [Handler]] = [:]

     mutating func on(event name: String,
                       handler: @escaping Handler) {
         handlers[name, default: []].append(handler)
         print("Handler registered for '\(name)'")
     }

     func emit(event name: String,
                with data: String = "") {
         guard let eventHandlers = handlers[name] else {
             print("No handlers for '\(name)'")
             return
         }
         print("Emitting '\(name)' to \(eventHandlers.count) handler(s)")
         eventHandlers.forEach { $0(data) }
     }
 }

 var events = EventSystem()

 // Parameter labels make this read like English:
 events.on(event: "login") { user in
     print("  [Auth] User logged in: \(user)")
 }
 events.on(event: "login") { user in
     print("  [Analytics] Tracking login for: \(user)")
 }
 events.on(event: "logout") { user in
     print("  [Auth] User logged out: \(user)")
 }
 // Output: Handler registered for 'login'
 //         Handler registered for 'login'
 //         Handler registered for 'logout'

 events.emit(event: "login", with: "alice@example.com")
 // Output: Emitting 'login' to 2 handler(s)
 //         [Auth] User logged in: alice@example.com
 //         [Analytics] Tracking login for: alice@example.com

 events.emit(event: "logout", with: "alice@example.com")
 // Output: Emitting 'logout' to 1 handler(s)
 //         [Auth] User logged out: alice@example.com

 events.emit(event: "signup")
 // Output: No handlers for 'signup'

FULL PATTERN — NETWORK LAYER WITH ALL FEATURES
================================================
 enum HTTPMethod: String { case GET, POST, PUT, DELETE }
 enum HTTPError: Error {
     case badURL, noData, httpError(Int), decodingError
 }

 struct Request {
     let url:    String
     let method: HTTPMethod
     let body:   String?
 }

 class HTTPClient {
     typealias CompletionHandler = (Result<String, HTTPError>) -> Void

     private var middleware: [(String) -> String] = []
     private var requestLog: [Request] = []

     // Parameter labels for clarity:
     func use(middleware transform: @escaping (String) -> String) {
         self.middleware.append(transform)
         print("Middleware added (\(self.middleware.count) total)")
     }

     // Trailing + escaping + parameter labels:
     func request(
         _ method: HTTPMethod,
         url: String,
         body: String? = nil,
         completion: @escaping CompletionHandler
     ) {
         guard url.starts(with: "https") else {
             completion(.failure(.badURL))
             return
         }
         let req = Request(url: url, method: method, body: body)
         requestLog.append(req)

         // Apply middleware to URL:
         let processedURL = middleware.reduce(url) { $1($0) }
         print("\(method.rawValue) \(processedURL)")

         // Simulate async response:
         DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
             let response = "Response for \(method.rawValue) \(url)"
             completion(.success(response))
         }
     }

     // Autoclosure for conditional logging:
     func debugLog(_ message: @autoclosure () -> String,
                    enabled: Bool = true) {
         guard enabled else { return }
         print("[HTTP Debug] \(message())")
     }

     var requestCount: Int { requestLog.count }
 }

 let http = HTTPClient()

 http.use(middleware: { url in
     url.replacingOccurrences(of: "example.com", with: "api.example.com")
 })
 // Output: Middleware added (1 total)

 http.use(middleware: { url in
     url + "?version=2"
 })
 // Output: Middleware added (2 total)

 http.debugLog("Client configured with \(2) middlewares")
 // Output: [HTTP Debug] Client configured with 2 middlewares

 http.request(.GET, url: "https://example.com/users") { result in
     switch result {
     case .success(let data): print("Got: \(data)")
     case .failure(let err):  print("Error: \(err)")
     }
 }
 // Output: GET https://api.example.com/users?version=2
 //         Got: Response for GET https://example.com/users

 http.request(.POST,
              url: "https://example.com/users",
              body: "{\"name\":\"Alice\"}") { result in
     switch result {
     case .success(let data): print("Created: \(data)")
     case .failure(let err):  print("Error: \(err)")
     }
 }
 // Output: POST https://api.example.com/users?version=2
 //         Created: Response for POST https://example.com/users

 http.debugLog("Total requests: \(http.requestCount)",
                enabled: http.requestCount > 0)
 // Output: [HTTP Debug] Total requests: 2


================================================================
PART 10 — INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
================================================================

================================================================
SECTION 1 — BASIC LEVEL
================================================================

Q1. What is a parameter label in Swift?
-----------------------------------------
A: A parameter label is the name used by the caller
  at the call site. It is separate from the internal
  parameter name used inside the function body.
  Example:
    func send(message text: String) {
        print("Sending: \(text)")   // 'text' used inside
    }
    send(message: "Hello")          // 'message' used outside
    // Output: Sending: Hello


Q2. How do you omit the argument label?
-----------------------------------------
A: Use underscore _ as the external label.
  The caller then passes the value with no label.
  Example:
    func double(_ n: Int) -> Int { n * 2 }
    print(double(5))
    // Output: 10

    func add(_ a: Int, _ b: Int) -> Int { a + b }
    print(add(3, 4))
    // Output: 7


Q3. What is a trailing closure?
---------------------------------
A: When a closure is the last argument, it can be
  placed outside the parentheses. If it is the only
  argument, the parentheses can be omitted entirely.
  Example:
    func apply(value: Int, transform: (Int) -> Int) -> Int {
        return transform(value)
    }
    // Standard:
    let r1 = apply(value: 5, transform: { $0 * 3 })
    print(r1)
    // Output: 15

    // Trailing:
    let r2 = apply(value: 5) { $0 * 3 }
    print(r2)
    // Output: 15


Q4. What is the difference between
   escaping and non-escaping closures?
-----------------------------------------
A: Non-escaping — must complete before function returns.
                 Default for all closure parameters.
  @escaping     — can outlive the function (stored,
                  called asynchronously later).
  Example:
    // Non-escaping — runs inside function:
    func runNow(action: () -> Void) { action() }
    runNow { print("Now") }
    // Output: Now

    // @escaping — stored, runs after function:
    var stored: (() -> Void)?
    func storeIt(action: @escaping () -> Void) {
        stored = action       // stored — outlives function
    }
    storeIt { print("Later") }
    stored?()
    // Output: Later


Q5. What is an @autoclosure?
------------------------------
A: @autoclosure wraps a caller's expression in { }
  automatically. Caller writes a plain expression,
  Swift creates the closure. Enables lazy evaluation.
  Example:
    func check(_ value: @autoclosure () -> Bool) {
        print(value() ? "Pass" : "Fail")
    }
    check(2 + 2 == 4)    // no braces at call site
    // Output: Pass
    check(1 > 5)
    // Output: Fail


Q6. Can closures capture values?
----------------------------------
A: Yes. Closures capture and store references to
  variables from their surrounding scope.
  Changes to the variable are reflected in the closure.
  Example:
    func makeAdder(amount: Int) -> (Int) -> Int {
        return { n in n + amount }   // 'amount' captured
    }
    let addTen3 = makeAdder(amount: 10)
    print(addTen3(5))
    // Output: 15
    print(addTen3(20))
    // Output: 30


Q7. What are shorthand argument names?
----------------------------------------
A: $0, $1, $2 etc. refer to the first, second,
  and third closure parameters. They allow very
  concise inline closures.
  Example:
    let doubled3 = [1, 2, 3, 4, 5].map { $0 * 2 }
    print(doubled3)
    // Output: [2, 4, 6, 8, 10]

    let sorted8 = [5, 2, 8, 1].sorted { $0 < $1 }
    print(sorted8)
    // Output: [1, 2, 5, 8]

    let sum2 = [1, 2, 3, 4, 5].reduce(0) { $0 + $1 }
    print(sum2)
    // Output: 15


Q8. What is a variadic parameter?
------------------------------------
A: A parameter that accepts zero or more values of
  the same type, passed as a comma-separated list.
  Inside the function it is treated as an Array.
  Example:
    func total(_ numbers: Double...) -> Double {
        numbers.reduce(0, +)
    }
    print(total(1.5, 2.5, 3.0))
    // Output: 7.0
    print(total())
    // Output: 0.0


Q9. What does inout do?
------------------------
A: inout allows a function to modify the original
  variable passed to it. Caller uses & prefix.
  The function gets a reference — changes persist.
  Example:
    func triple(_ n: inout Int) { n *= 3 }
    var num2 = 4
    triple(&num2)
    print(num2)
    // Output: 12


Q10. Can functions be stored in variables?
-------------------------------------------
A: Yes. Functions are first-class citizens.
  They can be stored in variables, arrays,
  passed as arguments, or returned from functions.
  Example:
    func square3(_ n: Int) -> Int { n * n }
    var op: (Int) -> Int = square3
    print(op(6))
    // Output: 36
    op = { $0 + 100 }
    print(op(6))
    // Output: 106


Q11. What happens if you omit return in
    a single-expression function?
-------------------------------------------
A: Swift infers the implicit return — no keyword needed.
  Applies to functions and closures with one expression.
  Example:
    func isPositive(_ n: Int) -> Bool { n > 0 }
    func sumTwo(_ a: Int, _ b: Int) -> Int { a + b }

    print(isPositive(5))
    // Output: true
    print(sumTwo(3, 7))
    // Output: 10


Q12. What is a default parameter value?
-----------------------------------------
A: A value assigned to a parameter that is used
  if the caller does not supply one.
  Enables flexible, overloaded-style APIs.
  Example:
    func greet4(name: String,
                 greeting: String = "Hello") -> String {
        return "\(greeting), \(name)!"
    }
    print(greet4(name: "Alice"))
    // Output: Hello, Alice!
    print(greet4(name: "Bob", greeting: "Hi"))
    // Output: Hi, Bob!


Q13. What is the type of a closure that
    takes two Ints and returns a Bool?
-------------------------------------------
A: (Int, Int) -> Bool
  Example:
    let compare: (Int, Int) -> Bool = { $0 < $1 }
    print(compare(3, 7))
    // Output: true

    func test(op: (Int, Int) -> Bool) {
        print(op(5, 3))
    }
    test(op: compare)
    // Output: false
    test(op: >)
    // Output: true


Q14. When do you need [weak self] in
    a closure?
-------------------------------------------
A: When a closure captures self AND is @escaping
  (stored or used asynchronously). Without [weak self],
  both self and the closure hold strong references
  to each other — a retain cycle — causing a memory leak.
  Example:
    class Timer2 {
        var onTick: (() -> Void)?
        var count = 0
        func setup() {
            onTick = { [weak self] in   // prevents cycle
                self?.count += 1
                print("Tick: \(self?.count ?? 0)")
            }
        }
        deinit { print("Timer2 freed") }
    }
    var t: Timer2? = Timer2()
    t!.setup()
    t!.onTick?()
    // Output: Tick: 1
    t = nil
    // Output: Timer2 freed ✓


Q15. What is a capture list?
------------------------------
A: A capture list [x, y] inside a closure specifies
  how values from the outer scope are captured.
  Without it: captured by reference (shared, mutable).
  With it:    captured by value (copy at creation time).
  Example:
    var score3 = 50
    let byRef  = { print("Ref:  \(score3)") }
    let byVal  = { [score3] in print("Val:  \(score3)") }

    score3 = 100
    byRef()       // sees updated value
    // Output: Ref:  100
    byVal()       // sees captured value (50)
    // Output: Val:  50


================================================================
SECTION 2 — INTERMEDIATE LEVEL
================================================================

Q16. What is the difference between
    a function and a closure in Swift?
-------------------------------------------
A: Functions are named and declared with func.
  Closures are unnamed inline blocks assigned
  to variables or passed as arguments.
  Both are first-class values with the same type system.
  Closures have additional syntactic shortcuts.
  Example:
    // Named function:
    func addNums(_ a: Int, _ b: Int) -> Int { a + b }

    // Closure expression (same behavior):
    let addClosure: (Int, Int) -> Int = { $0 + $1 }

    // Both have the same type:
    let ops: [(Int, Int) -> Int] = [addNums, addClosure]
    ops.forEach { print($0(3, 4)) }
    // Output: 7
    //         7


Q17. How does multiple trailing closure
    syntax work?
-------------------------------------------
A: Swift 5.3+ allows multiple trailing closures.
  The first closure has no label (trailing).
  Subsequent closures use their parameter labels.
  Example:
    func animate(
        duration: Double,
        animations: () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        animations()
        completion?(true)
    }

    // Multiple trailing closures:
    animate(duration: 0.3) {
        print("Animating")
    } completion: { done in
        print("Done: \(done)")
    }
    // Output: Animating
    //         Done: true


Q18. Why does @escaping require explicit
    self in closures?
-------------------------------------------
A: Because @escaping closures can outlive self.
  Swift forces you to write self explicitly as a
  reminder that you might be creating a strong
  reference to self that outlives the current scope.
  Non-escaping closures don't require it because
  they are guaranteed to finish before self could
  ever be freed.
  Example:
    class View2 {
        var color = "blue"

        func updateSync(action: () -> Void) {
            action()               // non-escaping
        }
        func updateAsync(action: @escaping () -> Void) {
            DispatchQueue.main.async { action() }
        }

        func run() {
            // Non-escaping — implicit self:
            updateSync {
                print(color)       // no self. needed
            }

            // @escaping — must write self (or [weak self]):
            updateAsync { [weak self] in
                print(self?.color ?? "gone")
            }
        }
    }
    View2().run()
    // Output: blue
    //         blue


Q19. What is the difference between
    capturing by reference and by value?
-------------------------------------------
A: By reference (default) — closure shares the variable.
  Both the outer scope and the closure see all changes.
  By value (capture list [x]) — closure gets a copy
  at the moment of creation. Future changes to x
  in outer scope do not affect closure's copy.
  Example:
    var n = 10
    let refClosure = {        print("ref: \(n)") }
    let valClosure = { [n] in print("val: \(n)") }

    n = 999
    refClosure()     // sees 999
    // Output: ref: 999
    valClosure()     // sees 10 (captured at creation)
    // Output: val: 10


Q20. What problem does @autoclosure solve?
-------------------------------------------
A: It removes the need for the caller to wrap an
  expression in braces, making call sites cleaner.
  It also enables lazy evaluation — the expression
  is only computed when the closure is called.
  Example:
    // Without @autoclosure — caller must use { }:
    func logManual(_ condition: Bool,
                    msg: () -> String) {
        if condition { print(msg()) }
    }
    logManual(true, msg: { "Server: \([1,2,3].count) items" })
    // Output: Server: 3 items

    // With @autoclosure — cleaner:
    func logAuto(_ condition: Bool,
                  msg: @autoclosure () -> String) {
        if condition { print(msg()) }
    }
    logAuto(true, msg: "Server: \([1,2,3].count) items")
    // Output: Server: 3 items

    // Lazy — msg NOT evaluated when condition is false:
    logAuto(false, msg: "Expensive: \([Int](repeating:0, count:1000000).count)")
    // Output: (nothing — expression never computed)


Q21. When should you use [unowned self]
    vs [weak self] in a closure?
-------------------------------------------
A: [weak self]   — when self CAN become nil.
                  Access through optional — safe.
  [unowned self] — when self will ALWAYS be alive
                   as long as the closure exists.
                   Access is non-optional — crash if wrong.
  Example:
    class Parent3 {
        // Child always freed before Parent — use unowned:
        lazy var describe: () -> String = { [unowned self] in
            "Parent: \(self.name)"
        }
        var name: String
        init(name: String) { self.name = name }
        deinit { print("Parent3 freed") }
    }
    var par: Parent3? = Parent3(name: "Root")
    print(par!.describe())
    // Output: Parent: Root
    par = nil
    // Output: Parent3 freed ✓


Q22. How do closures enable the delegate pattern?
---------------------------------------------------
A: Instead of a formal protocol + delegate property,
  you store the callback as a closure property.
  Simpler for one-off responses. The delegate pattern
  is better for multiple methods; closures are better
  for single-action callbacks.
  Example:
    class Button2 {
        var onTap:      (() -> Void)?
        var onLongPress: ((Double) -> Void)?

        func tap()             { onTap?() }
        func longPress(_ dur: Double) { onLongPress?(dur) }
    }
    class Screen {
        let button = Button2()
        init() {
            button.onTap = { [weak self] in
                print("Button tapped in \(type(of: self!))")
            }
            button.onLongPress = { duration in
                print("Long press: \(duration)s")
            }
        }
    }
    let screen = Screen()
    screen.button.tap()
    // Output: Button tapped in Screen
    screen.button.longPress(2.5)
    // Output: Long press: 2.5s


Q23. Can you pass a function where a
    closure is expected?
-------------------------------------------
A: Yes. A named function that matches the closure
  type can be passed directly without braces.
  Example:
    func isOdd(_ n: Int) -> Bool { n % 2 != 0 }
    func double5(_ n: Int) -> Int { n * 2 }

    let numbers3 = [1, 2, 3, 4, 5, 6, 7, 8]
    print(numbers3.filter(isOdd))
    // Output: [1, 3, 5, 7]
    print(numbers3.map(double5))
    // Output: [2, 4, 6, 8, 10, 12, 14, 16]

    // Operators are functions too:
    print(numbers3.sorted(by: >))
    // Output: [8, 7, 6, 5, 4, 3, 2, 1]


Q24. What is a @discardableResult function?
---------------------------------------------
A: @discardableResult suppresses the compiler warning
  when a function's return value is not used.
  Without it, ignoring a return value causes a warning.
  Example:
    @discardableResult
    func saveData(_ data: String) -> Bool {
        print("Saving: \(data)")
        return true
    }
    saveData("payload")          // no warning — discard OK
    // Output: Saving: payload

    let saved = saveData("other")  // can still use result
    print(saved)
    // Output: Saving: other
    //         true


Q25. What is the difference between
    map, flatMap, and compactMap?
-------------------------------------------
A: map       — transforms each element. Returns [T].
  compactMap — transforms, drops nil results. Returns [T].
  flatMap    — transforms then flattens nested arrays.
               Also removes nils for optionals (deprecated
               in favor of compactMap for that case).
  Example:
    let raw = ["1", "two", "3", "four", "5", "6"]

    let mapped      = raw.map { Int($0) }
    print(mapped)
    // Output: [Optional(1), nil, Optional(3), nil, Optional(5), Optional(6)]

    let compacted   = raw.compactMap { Int($0) }
    print(compacted)
    // Output: [1, 3, 5, 6]

    let nested = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]
    let flat   = nested.flatMap { $0 }
    print(flat)
    // Output: [1, 2, 3, 4, 5, 6, 7, 8, 9]

    let flat2  = nested.flatMap { $0.filter { $0 % 2 == 0 } }
    print(flat2)
    // Output: [2, 4, 6, 8]


Q26. What is a throwing closure and
    how do you use rethrows?
-------------------------------------------
A: A throwing closure has type (T) throws -> U.
  rethrows means the function only throws if the
  closure it receives throws — otherwise non-throwing.
  Example:
    enum ParseError: Error { case invalid(String) }

    func parseAll<T>(_ items: [String],
                     using parser: (String) throws -> T)
                     rethrows -> [T] {
        try items.map { try parser($0) }
    }

    // Non-throwing parser — no try needed at call site:
    let ints2 = try? parseAll(["1","2","3"]) { s in
        guard let n = Int(s) else {
            throw ParseError.invalid(s)
        }
        return n
    }
    print(ints2 ?? [])
    // Output: [1, 2, 3]

    let fail = try? parseAll(["1","two","3"]) { s in
        guard let n = Int(s) else {
            throw ParseError.invalid(s)
        }
        return n
    }
    print(fail ?? [])
    // Output: []   (nil → coalesced to [])


================================================================
SECTION 3 — ADVANCED LEVEL
================================================================

Q27. What is the difference between
    @escaping and withoutActuallyEscaping?
-------------------------------------------
A: @escaping — marks a closure parameter as able to
              outlive the function. Required by
              compiler to store/pass to async code.
  withoutActuallyEscaping — used when you need to
              pass a non-escaping closure to an API
              that requires @escaping, but you KNOW
              it won't actually escape. Unsafe if misused.
  Example:
    // Problem: filter wants @escaping internally,
    // but our closure parameter is non-escaping:
    func customSearch<T>(_ array: [T],
                          predicate: (T) -> Bool) -> [T] {
        var result10: [T] = []
        withoutActuallyEscaping(predicate) { escaped in
            result10 = array.filter(escaped)
            // escaped is treated as @escaping within this block
            // but we guarantee it won't actually escape
        }
        return result10
    }
    let evens2 = customSearch([1,2,3,4,5,6]) { $0 % 2 == 0 }
    print(evens2)
    // Output: [2, 4, 6]


Q28. How does function overloading interact
    with closures and parameter labels?
-------------------------------------------
A: Swift uses parameter labels, parameter types,
  and return types to disambiguate overloads.
  Closures with different signatures create distinct
  overloads. Labels are part of the function signature.
  Example:
    func process2(value: Int, handler: (Int) -> Int) -> Int {
        return handler(value)
    }
    func process2(value: Int,
                   handler: (Int) -> String) -> String {
        return handler(value)
    }
    func process2(text: String,
                   handler: (String) -> String) -> String {
        return handler(text)
    }

    print(process2(value: 5)  { $0 * 10 })       // -> Int
    // Output: 50
    print(process2(value: 5)  { "val:\($0)" })    // -> String
    // Output: val:5
    print(process2(text: "hi") { $0.uppercased() })
    // Output: HI


Q29. How does Swift handle memory for
    closures that capture values?
-------------------------------------------
A: When a closure captures a value type (Int, struct),
  it stores a copy (or a box on the heap if mutable).
  When it captures a reference type (class), it stores
  a reference — incrementing ARC count.
  Captured var values are heap-boxed to share mutations.
  Example:
    // Captured var — heap boxed (shared between closure + scope):
    var counter3 = 0
    let increment2 = { counter3 += 1 }
    let getCount   = { counter3 }

    increment2()
    increment2()
    increment2()
    print(getCount())        // both closures share counter3
    // Output: 3
    print(counter3)          // outer scope also sees change
    // Output: 3

    // Captured let — no boxing needed (immutable):
    let base = 100
    let addBase = { (n: Int) in n + base }   // base copied
    print(addBase(42))
    // Output: 142


Q30. What is a result builder and how
    do closures relate to it?
-------------------------------------------
A: A @resultBuilder transforms a series of expressions
  inside a closure-like block into a single value.
  Used in SwiftUI (ViewBuilder), HTML builders etc.
  Each expression in the block is collected into
  a result by the builder's buildBlock method.
  Example:
    @resultBuilder
    struct StringConcatenator {
        static func buildBlock(_ parts: String...) -> String {
            parts.joined(separator: " ")
        }
        static func buildOptional(_ part: String?) -> String {
            part ?? ""
        }
        static func buildEither(first: String) -> String { first }
        static func buildEither(second: String) -> String { second }
    }

    func buildSentence(
        @StringConcatenator content: () -> String
    ) -> String {
        content()
    }

    let show = true
    let sentence = buildSentence {
        "Swift"
        "is"
        if show { "really" } else { "not" }
        "powerful"
    }
    print(sentence)
    // Output: Swift is really powerful


Q31. How do closures work with
    async/await?
-------------------------------------------
A: Closures can be async — marked with async keyword.
  They must be awaited. Swift Concurrency uses
  structured tasks instead of @escaping completion
  handlers. Closures in async context follow
  Sendable rules for safe data passing.
  Example:
    func loadUser(id: Int) async -> String {
        // Simulate async work:
        return "User #\(id): Alice"
    }

    // Async closure stored as a property:
    struct AsyncLoader {
        var load: (Int) async -> String

        func run(id: Int) async {
            let result11 = await load(id)
            print(result11)
        }
    }

    let loader = AsyncLoader(load: loadUser)
    Task {
        await loader.run(id: 42)
        // Output: User #42: Alice
    }

    // Async closure inline:
    let processor: (Int) async -> String = { id in
        await loadUser(id: id)
    }
    Task {
        let result12 = await processor(99)
        print(result12)
        // Output: User #99: Alice
    }


Q32. Explain the difference between
    lazy var using a closure vs
    a computed property.
-------------------------------------------
A: lazy var with closure — initializer runs ONCE
  on first access, result stored. No re-computation.
  Type is NOT a closure — it's the return type of { }().

  Computed property — re-runs the getter EVERY access.
  No stored value. Can have a setter.
  Example:
    class Report {
        var data = [1, 2, 3, 4, 5]

        // lazy var — computed ONCE, then stored:
        lazy var expensiveSum: Int = {
            print("Computing sum (once only)")
            return data.reduce(0, +)
        }()

        // Computed property — runs every time:
        var currentSum: Int {
            print("Computing current sum")
            return data.reduce(0, +)
        }
    }

    let report = Report()
    print(report.expensiveSum)
    // Output: Computing sum (once only)
    //         15
    print(report.expensiveSum)
    // Output: 15              (no recomputation)

    print(report.currentSum)
    // Output: Computing current sum
    //         15
    print(report.currentSum)
    // Output: Computing current sum  (recomputed)
    //         15


Q33. How do you implement retry logic
    using closures?
-------------------------------------------
A: Store the operation as a closure and call it
  multiple times. Combine with @escaping and
  async patterns for real-world use.
  Example:
    enum RetryError: Error {
        case maxRetriesExceeded(Int)
        case operationFailed(String)
    }

    func retry<T>(
        times maxAttempts: Int,
        delay: Double = 0.0,
        operation: () throws -> T
    ) throws -> T {
        var lastError: Error?
        for attempt in 1...maxAttempts {
            do {
                let result13 = try operation()
                print("Succeeded on attempt \(attempt)")
                return result13
            } catch {
                lastError = error
                print("Attempt \(attempt) failed: \(error)")
            }
        }
        throw RetryError.maxRetriesExceeded(maxAttempts)
    }

    var attemptCount = 0
    do {
        let value = try retry(times: 3) { () -> String in
            attemptCount += 1
            if attemptCount < 3 {
                throw RetryError.operationFailed("Not ready")
            }
            return "Success on attempt \(attemptCount)"
        }
        print(value)
    } catch {
        print("All retries failed: \(error)")
    }
    // Output: Attempt 1 failed: operationFailed("Not ready")
    //         Attempt 2 failed: operationFailed("Not ready")
    //         Succeeded on attempt 3
    //         Success on attempt 3


Q34. What is the difference between
    @escaping on a closure parameter
    and storing a closure in a property?
-------------------------------------------
A: @escaping on a parameter tells the compiler the
  closure MAY outlive the function call — enabling
  storage or async use.
  Storing in a property requires @escaping because
  the property definitely outlives the function call.
  Both require [weak self] consideration.
  Example:
    class Worker2 {
        // Property that stores a closure — implicitly escaping:
        var completionBlock: (() -> Void)?
        var transformBlock: ((Int) -> Int)?

        // Must be @escaping to assign to property:
        func setCompletion(_ block: @escaping () -> Void) {
            completionBlock = block
        }
        func setTransform(_ block: @escaping (Int) -> Int) {
            transformBlock = block
        }
        func run() {
            print(transformBlock?(10) ?? 0)
            completionBlock?()
        }
        deinit { print("Worker2 freed") }
    }
    var w: Worker2? = Worker2()
    w!.setTransform { $0 * 5 }
    w!.setCompletion { print("Complete!") }
    w!.run()
    // Output: 50
    //         Complete!
    w = nil
    // Output: Worker2 freed


Q35. How do you create a thread-safe
    closure-based cache?
-------------------------------------------
A: Use a concurrent DispatchQueue with barrier writes.
  Read operations run concurrently.
  Write operations use barrier to ensure exclusivity.
  Example:
    final class ThreadSafeCache2<K: Hashable, V> {
        private var store: [K: V] = [:]
        private let queue = DispatchQueue(
            label: "cache.queue",
            attributes: .concurrent
        )

        func get(_ key: K) -> V? {
            queue.sync { store[key] }
        }

        func set(_ key: K, value: V) {
            queue.async(flags: .barrier) { [weak self] in
                self?.store[key] = value
            }
        }

        func remove(_ key: K) {
            queue.async(flags: .barrier) { [weak self] in
                self?.store.removeValue(forKey: key)
            }
        }

        var count: Int {
            queue.sync { store.count }
        }
    }

    let cache2 = ThreadSafeCache2<String, Int>()
    cache2.set("a", value: 1)
    cache2.set("b", value: 2)
    cache2.set("c", value: 3)
    print(cache2.get("b") ?? -1)
    // Output: 2
    print(cache2.count)
    // Output: 3
    cache2.remove("b")
    print(cache2.count)
    // Output: 2


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q36. How does Swift compile non-escaping
    closures differently from escaping ones?
-------------------------------------------
A: Non-escaping closures:
  - May be allocated on the STACK (no heap needed)
  - Compiler can inline the closure body
  - No retain/release for captured values needed
  - Passed as a thin function pointer + context

  @escaping closures:
  - Allocated on the HEAP (must outlive the call)
  - Captured values are reference-counted
  - ARC retain/release inserted around captures
  - Passed as a heap-allocated closure object

  Example (demonstrates lifetime difference):
    class HeavyObject {
        let data = Array(repeating: 0, count: 1000)
        deinit { print("HeavyObject freed") }
    }

    // Non-escaping — HeavyObject freed after function:
    func withNonEscaping(action: () -> Void) {
        let obj = HeavyObject()   // on stack context
        _ = obj.data.count
        action()
    }   // obj freed here — guaranteed

    // @escaping — HeavyObject may live longer:
    func withEscaping(action: @escaping () -> Void) {
        let obj = HeavyObject()
        _ = obj.data.count
        DispatchQueue.global().async {
            action()
        }
    }   // obj may still be alive (captured by action)

    withNonEscaping { print("non-escaping done") }
    // Output: HeavyObject freed
    //         non-escaping done


Q37. What is the role of @convention
    in closure types?
-------------------------------------------
A: @convention specifies the calling convention of
  a function type:
  @convention(swift)  — default Swift closure (context ptr)
  @convention(c)      — C function pointer (no context)
  @convention(block)  — Objective-C block

  Example:
    // @convention(c) — can be used as C function pointer:
    let cStyleFunction: @convention(c) (Int, Int) -> Int = { a, b in
        return a + b
    }
    // No capture allowed in @convention(c) — no context pointer

    typealias CCallback = @convention(c) (Int32) -> Void

    func registerCallback(_ cb: CCallback) {
        cb(42)
    }
    registerCallback { code in
        print("C callback called with: \(code)")
    }
    // Output: C callback called with: 42

    // @convention(block) — Obj-C interop:
    // typealias ObjCBlock = @convention(block) (String) -> Void


Q38. How do you implement a Promise/Future
    using closures?
-------------------------------------------
A: Wrap an async operation in a class that stores
  @escaping completion handlers. Call handlers when
  the value resolves. Chain using then/catch style.
  Example:
    final class Promise<T> {
        private var value:    T?
        private var error:    Error?
        private var handlers: [(Result<T, Error>) -> Void] = []
        private var resolved = false

        func resolve(_ value: T) {
            guard !resolved else { return }
            resolved  = true
            self.value = value
            let result14 = Result<T, Error>.success(value)
            handlers.forEach { $0(result14) }
            handlers.removeAll()
        }

        func reject(_ error: Error) {
            guard !resolved else { return }
            resolved   = true
            self.error  = error
            let result14 = Result<T, Error>.failure(error)
            handlers.forEach { $0(result14) }
            handlers.removeAll()
        }

        @discardableResult
        func then(_ handler: @escaping (T) -> Void) -> Promise<T> {
            if let value = value {
                handler(value)
            } else {
                handlers.append { result14 in
                    if case .success(let v) = result14 {
                        handler(v)
                    }
                }
            }
            return self
        }

        @discardableResult
        func `catch`(_ handler: @escaping (Error) -> Void)
            -> Promise<T> {
            if let error = error {
                handler(error)
            } else {
                handlers.append { result14 in
                    if case .failure(let e) = result14 {
                        handler(e)
                    }
                }
            }
            return self
        }
    }

    func fetchUser2(id: Int) -> Promise<String> {
        let promise = Promise<String>()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            if id > 0 {
                promise.resolve("User \(id): Alice")
            } else {
                promise.reject(NSError(domain: "UserError",
                                        code: -1, userInfo: nil))
            }
        }
        return promise
    }

    fetchUser2(id: 1)
        .then  { print("Resolved: \($0)") }
        .catch { print("Rejected: \($0)") }
    // Output: Resolved: User 1: Alice

    fetchUser2(id: -1)
        .then  { print("Resolved: \($0)") }
        .catch { print("Rejected: \($0.localizedDescription)") }
    // Output: Rejected: The operation couldn't be completed.


Q39. How does @autoclosure interact with
    short-circuit evaluation operators?
-------------------------------------------
A: The && and || operators use @autoclosure for their
  right-hand side. This ensures the right side is
  ONLY evaluated if needed (short-circuit semantics).
  You can build custom operators with the same pattern.
  Example:
    // How && works internally (simplified):
    // func && (lhs: Bool,
    //          rhs: @autoclosure () -> Bool) -> Bool {
    //     lhs ? rhs() : false
    // }

    var sideEffectCount = 0
    func check2(_ label: String, _ value: Bool) -> Bool {
        sideEffectCount += 1
        print("Checking \(label): \(value)")
        return value
    }

    sideEffectCount = 0
    let result15 = check2("A", true) && check2("B", true)
    print("Result: \(result15), checks: \(sideEffectCount)")
    // Output: Checking A: true
    //         Checking B: true
    //         Result: true, checks: 2

    sideEffectCount = 0
    let result16 = check2("A", false) && check2("B", true)
    print("Result: \(result16), checks: \(sideEffectCount)")
    // Output: Checking A: false
    //         Result: false, checks: 1   ← B never checked

    // Custom short-circuit with @autoclosure:
    func ifBoth(_ a: Bool,
                 and b: @autoclosure () -> Bool) -> Bool {
        guard a else { return false }
        return b()              // b only evaluated if a is true
    }
    print(ifBoth(false, and: check2("lazy", true)))
    // Output: false            (check2 never called)


Q40. How do you implement a type-safe
    event system using closures and generics?
-------------------------------------------
A: Use a generic Event<T> type where T is the
  payload. Store @escaping closures keyed by a
  token (for unsubscription). Use an actor or
  lock for thread safety.
  Example:
    final class Event2<Payload> {
        private var handlers:  [UUID: (Payload) -> Void] = [:]
        private let lock = NSLock()

        @discardableResult
        func subscribe(
            _ handler: @escaping (Payload) -> Void
        ) -> UUID {
            let token = UUID()
            lock.lock()
            handlers[token] = handler
            lock.unlock()
            return token
        }

        func unsubscribe(_ token: UUID) {
            lock.lock()
            handlers.removeValue(forKey: token)
            lock.unlock()
            print("Unsubscribed token \(token.uuidString.prefix(8))")
        }

        func emit(_ payload: Payload) {
            lock.lock()
            let current = handlers
            lock.unlock()
            current.values.forEach { $0(payload) }
        }
    }

    // Strongly typed events:
    struct UserLoggedIn  { let userId: String; let timestamp: Double }
    struct PurchaseMade  { let itemId: String; let amount: Double }

    let loginEvent    = Event2<UserLoggedIn>()
    let purchaseEvent = Event2<PurchaseMade>()

    let t1 = loginEvent.subscribe { event in
        print("[Auth]      User \(event.userId) logged in")
    }
    let t2 = loginEvent.subscribe { event in
        print("[Analytics] Track login for \(event.userId)")
    }
    let t3 = purchaseEvent.subscribe { event in
        print("[Payment]   \(event.itemId) for $\(event.amount)")
    }

    loginEvent.emit(UserLoggedIn(userId: "alice", timestamp: 1000))
    // Output: [Auth]      User alice logged in
    //         [Analytics] Track login for alice

    purchaseEvent.emit(PurchaseMade(itemId: "PRO_PLAN",
                                     amount: 29.99))
    // Output: [Payment]   PRO_PLAN for $29.99

    loginEvent.unsubscribe(t2)
    // Output: Unsubscribed token xxxxxxxx

    loginEvent.emit(UserLoggedIn(userId: "bob", timestamp: 2000))
    // Output: [Auth]      User bob logged in
    //         (Analytics handler removed — not called)


================================================================
PART 11 — COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

FUNCTION SYNTAX
Task                               | Code
-----------------------------------|------------------------------------------
Basic function                     | func name() { }
With parameter                     | func name(label param: Type) { }
With return                        | func name() -> Type { return val }
Implicit return                    | func name() -> Type { expression }
Multiple return (tuple)            | func name() -> (a: T, b: T)
Omit label                         | func name(_ param: Type) { }
Default value                      | func name(param: Type = default) { }
Variadic                           | func name(_ values: Type...) { }
inout                              | func name(_ x: inout Type) { }
Throws                             | func name() throws -> Type { }
Rethrows                           | func name(f: () throws -> T) rethrows
Discard result                     | @discardableResult func name() -> T

PARAMETER LABELS
Task                               | Code                  | Call site
-----------------------------------|------------------------|------------------
Same label and name                | (name: String)         | f(name: "x")
Different label/name               | (to name: String)      | f(to: "x")
No external label                  | (_ name: String)       | f("x")
Preposition style                  | (from a: T, to b: T)   | f(from: x, to: y)
Init with label                    | init(with value: T)    | Type(with: x)
Protocol with label                | func draw(at x: T)     | obj.draw(at: val)

CLOSURE SYNTAX LEVELS
Full syntax                        | { (a: Int, b: Int) -> Bool in return a < b }
Type inference                     | { (a, b) in return a < b }
Implicit return                    | { (a, b) in a < b }
Shorthand args                     | { $0 < $1 }
Operator function                  | (<)
Trailing (last arg)                | array.sorted { $0 < $1
 
 
 */
