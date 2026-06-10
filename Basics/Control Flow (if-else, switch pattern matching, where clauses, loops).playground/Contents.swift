import UIKit

/*
 CONTROL FLOW IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 if-else, switch, pattern matching, where clauses, loops
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 PART 1 — WHAT IS CONTROL FLOW?
 ================================================================

 WHAT IS CONTROL FLOW?
 =====================
 Control flow determines the order in which code executes.
 Swift provides a rich set of control flow tools:

   1. if / else if / else   — conditional branching
   2. guard                 — early exit with condition
   3. switch                — multi-way branching with
                              powerful pattern matching
   4. where                 — adding conditions to patterns
   5. for-in                — iterate over sequences
   6. while                 — repeat while condition is true
   7. repeat-while          — repeat at least once

 SUMMARY TABLE
 =============
 Construct        | Purpose
 -----------------|----------------------------------------------
 if / else        | Branch on Boolean condition
 guard            | Early exit when condition is false
 switch           | Multi-case pattern matching
 where            | Extra condition on patterns
 for-in           | Iterate over sequences / ranges
 while            | Loop while condition is true
 repeat-while     | Loop at least once, check at end
 stride           | Loop with custom step value


 ================================================================
 PART 2 — IF / ELSE IF / ELSE
 ================================================================

 WHAT IS IF-ELSE?
 ================
 if evaluates a Boolean condition and executes the
 associated block if true. else handles the false case.
 Conditions do not need parentheses in Swift.

 BASIC IF
 =========
   let temperature = 30

   if temperature > 25 {
       print("It's hot")
   }
   // Output: It's hot

 IF-ELSE
 ========
   let score = 55

   if score >= 60 {
       print("Passed")
   } else {
       print("Failed")
   }
   // Output: Failed

 IF-ELSE IF-ELSE
 ================
   let marks = 82

   if marks >= 90 {
       print("Grade A")
   } else if marks >= 80 {
       print("Grade B")
   } else if marks >= 70 {
       print("Grade C")
   } else if marks >= 60 {
       print("Grade D")
   } else {
       print("Grade F")
   }
   // Output: Grade B

 NESTED IF
 ==========
   let age = 20
   let hasID = true

   if age >= 18 {
       if hasID {
           print("Entry allowed")
       } else {
           print("ID required")
       }
   } else {
       print("Too young")
   }
   // Output: Entry allowed

 COMPOUND CONDITIONS (AND &&)
 ==============================
   let username = "admin"
   let password = "secret"

   if username == "admin" && password == "secret" {
       print("Login successful")
   } else {
       print("Login failed")
   }
   // Output: Login successful

 COMPOUND CONDITIONS (OR ||)
 =============================
   let isWeekend = false
   let isHoliday = true

   if isWeekend || isHoliday {
       print("Day off")
   } else {
       print("Work day")
   }
   // Output: Day off

 COMPOUND CONDITIONS (NOT !)
 ============================
   let isLoggedIn = false

   if !isLoggedIn {
       print("Please log in")
   }
   // Output: Please log in

 OPTIONAL BINDING WITH IF LET
 ==============================
   let name: String? = "Alice"

   if let unwrapped = name {
       print("Hello, \(unwrapped)")
   } else {
       print("No name")
   }
   // Output: Hello, Alice

   let empty: String? = nil
   if let unwrapped = empty {
       print("Hello, \(unwrapped)")
   } else {
       print("No name provided")
   }
   // Output: No name provided

 IF LET SHORTHAND (Swift 5.7+)
 ==============================
   let username: String? = "Bob"

   if let username {
       print("User: \(username)")
   }
   // Output: User: Bob

 MULTIPLE OPTIONAL BINDING
 ===========================
   let firstName: String? = "John"
   let lastName: String? = "Doe"

   if let first = firstName, let last = lastName {
       print("\(first) \(last)")
   }
   // Output: John Doe

   let firstName2: String? = "Jane"
   let lastName2: String? = nil

   if let first = firstName2, let last = lastName2 {
       print("\(first) \(last)")
   } else {
       print("Missing name part")
   }
   // Output: Missing name part

 OPTIONAL BINDING WITH CONDITION
 =================================
   let age: Int? = 20

   if let age = age, age >= 18 {
       print("Adult — age \(age)")
   } else {
       print("Not eligible")
   }
   // Output: Adult — age 20

   let age2: Int? = 15
   if let age2 = age2, age2 >= 18 {
       print("Adult")
   } else {
       print("Not eligible")
   }
   // Output: Not eligible

 IF CASE PATTERN MATCHING
 =========================
   enum Status { case active, inactive, pending }
   let status = Status.active

   if case .active = status {
       print("User is active")
   }
   // Output: User is active

 IF CASE WITH ASSOCIATED VALUE
 ==============================
   enum Shape {
       case circle(radius: Double)
       case rectangle(width: Double, height: Double)
   }
   let s = Shape.circle(radius: 5.0)

   if case .circle(let r) = s {
       print("Circle with radius \(r)")
   }
   // Output: Circle with radius 5.0

 TERNARY OPERATOR
 =================
   let speed = 120
   let message = speed > 100 ? "Too fast" : "OK"
   print(message)
   // Output: Too fast

   let value = 7
   print(value % 2 == 0 ? "Even" : "Odd")
   // Output: Odd

 NIL COALESCING ??
 ==================
   let nickname: String? = nil
   let displayName = nickname ?? "Anonymous"
   print(displayName)
   // Output: Anonymous

   let nickname2: String? = "Ace"
   let displayName2 = nickname2 ?? "Anonymous"
   print(displayName2)
   // Output: Ace

 CHAINED NIL COALESCING
 =======================
   let a: String? = nil
   let b: String? = nil
   let c: String? = "Found"

   let result = a ?? b ?? c ?? "Default"
   print(result)
   // Output: Found


 ================================================================
 PART 3 — GUARD
 ================================================================

 WHAT IS GUARD?
 ==============
 guard requires a condition to be true to continue execution.
 If the condition is false, the else block runs and must
 exit the current scope using return, break, continue,
 or throw.
 Guard is used for early exit — it makes the happy path
 the main path, improving readability.

 BASIC GUARD
 ============
   func greet(name: String?) {
       guard let name = name else {
           print("No name provided")
           return
       }
       print("Hello, \(name)!")
   }
   greet(name: "Alice")
   // Output: Hello, Alice!
   greet(name: nil)
   // Output: No name provided

 GUARD SHORTHAND (Swift 5.7+)
 ==============================
   func greet2(name: String?) {
       guard let name else {
           print("No name")
           return
       }
       print("Hi, \(name)!")
   }
   greet2(name: "Bob")
   // Output: Hi, Bob!

 MULTIPLE GUARD CONDITIONS
 ==========================
   func register(username: String?, age: Int?) {
       guard let username = username,
             let age = age,
             !username.isEmpty,
             age >= 18 else {
           print("Invalid registration data")
           return
       }
       print("Registered: \(username), age \(age)")
   }
   register(username: "Alice", age: 25)
   // Output: Registered: Alice, age 25

   register(username: nil, age: 25)
   // Output: Invalid registration data

   register(username: "Bob", age: 16)
   // Output: Invalid registration data

 GUARD VERSUS IF-LET
 ====================
   // if let — bound variable only inside if block:
   func withIfLet(name: String?) {
       if let name = name {
           print("Inside if: \(name)")
       }
       // name not accessible here
   }

   // guard let — bound variable available after guard:
   func withGuard(name: String?) {
       guard let name = name else { return }
       // name accessible here and below
       print("After guard: \(name)")
       print("Length: \(name.count)")
   }
   withGuard(name: "Alice")
   // Output: After guard: Alice
   //         Length: 5

 GUARD WITH THROW
 =================
   enum ValidationError: Error {
       case emptyUsername
       case ageTooYoung
   }

   func validate(username: String, age: Int) throws {
       guard !username.isEmpty else {
           throw ValidationError.emptyUsername
       }
       guard age >= 18 else {
           throw ValidationError.ageTooYoung
       }
       print("Valid: \(username), \(age)")
   }

   do { try validate(username: "Alice", age: 20) }
   catch { print("Error: \(error)") }
   // Output: Valid: Alice, 20

   do { try validate(username: "", age: 20) }
   catch ValidationError.emptyUsername { print("Empty username") }
   catch { print("Error: \(error)") }
   // Output: Empty username

 GUARD WITH ENUM PATTERN
 ========================
   enum Connection { case wifi, cellular, none }

   func loadData(connection: Connection) {
       guard case .wifi = connection else {
           print("WiFi required")
           return
       }
       print("Loading on WiFi")
   }
   loadData(connection: .wifi)
   // Output: Loading on WiFi
   loadData(connection: .cellular)
   // Output: WiFi required


 ================================================================
 PART 4 — SWITCH
 ================================================================

 WHAT IS SWITCH?
 ===============
 switch matches a value against multiple patterns.
 Each case executes when its pattern matches.
 Switch in Swift:
   - Must be exhaustive (cover all cases)
   - Does NOT fall through by default
   - Supports powerful pattern matching
   - Can match ranges, tuples, types, and more

 BASIC SWITCH
 =============
   let day = "Monday"

   switch day {
   case "Monday":
       print("Start of the week")
   case "Friday":
       print("End of the week")
   case "Saturday", "Sunday":
       print("Weekend")
   default:
       print("Midweek")
   }
   // Output: Start of the week

 SWITCH WITH INT
 ================
   let code = 404

   switch code {
   case 200:       print("OK")
   case 201:       print("Created")
   case 400:       print("Bad Request")
   case 404:       print("Not Found")
   case 500:       print("Server Error")
   default:        print("Unknown: \(code)")
   }
   // Output: Not Found

 SWITCH WITH ENUM
 =================
   enum Direction { case north, south, east, west }
   let dir = Direction.east

   switch dir {
   case .north: print("Going North")
   case .south: print("Going South")
   case .east:  print("Going East")
   case .west:  print("Going West")
   }
   // Output: Going East
   // No default needed — enum is exhaustive

 SWITCH WITH RANGE
 ==================
   let temperature = 28

   switch temperature {
   case ..<0:
       print("Freezing")
   case 0..<10:
       print("Cold")
   case 10..<20:
       print("Cool")
   case 20..<30:
       print("Warm")
   case 30...:
       print("Hot")
   default:
       print("Unknown")
   }
   // Output: Warm

 SWITCH WITH MULTIPLE VALUES PER CASE
 ======================================
   let vowel: Character = "e"

   switch vowel {
   case "a", "e", "i", "o", "u":
       print("\(vowel) is a vowel")
   default:
       print("\(vowel) is a consonant")
   }
   // Output: e is a vowel

 SWITCH WITH TUPLE
 ==================
   let point = (1, 0)

   switch point {
   case (0, 0):      print("Origin")
   case (_, 0):      print("On X-axis")
   case (0, _):      print("On Y-axis")
   case (-2...2, -2...2): print("Near origin")
   default:          print("Elsewhere")
   }
   // Output: On X-axis

   let point2 = (1, 1)
   switch point2 {
   case (0, 0):      print("Origin")
   case (_, 0):      print("On X-axis")
   case (0, _):      print("On Y-axis")
   case (-2...2, -2...2): print("Near origin")
   default:          print("Elsewhere")
   }
   // Output: Near origin

 SWITCH WITH VALUE BINDING
 ==========================
   let coordinate = (3, -3)

   switch coordinate {
   case (let x, 0):
       print("On X-axis at x=\(x)")
   case (0, let y):
       print("On Y-axis at y=\(y)")
   case (let x, let y):
       print("At (\(x), \(y))")
   }
   // Output: At (3, -3)

   let p = (5, 0)
   switch p {
   case (let x, 0):
       print("On X-axis at x=\(x)")
   case (0, let y):
       print("On Y-axis at y=\(y)")
   case (let x, let y):
       print("At (\(x), \(y))")
   }
   // Output: On X-axis at x=5

 SWITCH WITH WHERE CLAUSE
 =========================
   let number = 15

   switch number {
   case let n where n < 0:
       print("Negative: \(n)")
   case let n where n == 0:
       print("Zero")
   case let n where n % 2 == 0:
       print("Positive even: \(n)")
   case let n where n % 2 != 0:
       print("Positive odd: \(n)")
   default:
       print("Other: \(number)")
   }
   // Output: Positive odd: 15

 SWITCH WITH ASSOCIATED VALUES
 ==============================
   enum Measurement {
       case distance(meters: Double)
       case weight(kg: Double)
       case temperature(celsius: Double)
   }

   let m = Measurement.distance(meters: 42.5)

   switch m {
   case .distance(let meters):
       print("Distance: \(meters)m")
   case .weight(let kg):
       print("Weight: \(kg)kg")
   case .temperature(let c):
       print("Temp: \(c)°C")
   }
   // Output: Distance: 42.5m

 SWITCH WITH TYPE PATTERN (ANY)
 ================================
   let items: [Any] = [1, "hello", 3.14, true, [1, 2, 3]]

   for item in items {
       switch item {
       case let i as Int:      print("Int: \(i)")
       case let s as String:   print("String: \(s)")
       case let d as Double:   print("Double: \(d)")
       case let b as Bool:     print("Bool: \(b)")
       case let a as [Int]:    print("Array: \(a)")
       default:                print("Unknown")
       }
   }
   // Output: Int: 1
   //         String: hello
   //         Double: 3.14
   //         Bool: true
   //         Array: [1, 2, 3]

 SWITCH WITH OPTIONAL PATTERN
 ==============================
   let values: [Int?] = [1, nil, 3, nil, 5]

   for val in values {
       switch val {
       case let x?:
           print("Value: \(x)")
       case nil:
           print("Nil")
       }
   }
   // Output: Value: 1
   //         Nil
   //         Value: 3
   //         Nil
   //         Value: 5

 SWITCH — EXHAUSTIVENESS
 ========================
   enum Planet { case mercury, venus, earth, mars }
   let p = Planet.earth

   switch p {
   case .mercury: print("Mercury")
   case .venus:   print("Venus")
   case .earth:   print("Earth")
   case .mars:    print("Mars")
   }
   // Output: Earth
   // No default needed — all cases covered

   // If a case is missing:
   // switch p {
   // case .mercury: print("Mercury")
   // }
   // Compile Error: Switch must be exhaustive


 ================================================================
 PART 5 — WHERE CLAUSES
 ================================================================

 WHAT ARE WHERE CLAUSES?
 ========================
 where adds an extra condition to a pattern.
 Used in switch cases, for loops, generics,
 and protocol conformance.
 A where clause must evaluate to a Bool.

 WHERE IN SWITCH
 ================
   let score = 87

   switch score {
   case let s where s >= 90:    print("A — \(s)")
   case let s where s >= 80:    print("B — \(s)")
   case let s where s >= 70:    print("C — \(s)")
   case let s where s >= 60:    print("D — \(s)")
   default:                     print("F — \(score)")
   }
   // Output: B — 87

 WHERE WITH TUPLE IN SWITCH
 ===========================
   let point = (3, 4)

   switch point {
   case let (x, y) where x == y:
       print("On the diagonal: (\(x), \(y))")
   case let (x, y) where x > 0 && y > 0:
       print("Quadrant I: (\(x), \(y))")
   case let (x, y) where x < 0 && y > 0:
       print("Quadrant II: (\(x), \(y))")
   case let (x, y) where x < 0 && y < 0:
       print("Quadrant III: (\(x), \(y))")
   default:
       print("Other: \(point)")
   }
   // Output: Quadrant I: (3, 4)

 WHERE WITH ENUM IN SWITCH
 ==========================
   enum Vehicle {
       case car(speed: Int)
       case bicycle(gears: Int)
       case truck(weight: Int)
   }

   let v = Vehicle.car(speed: 200)

   switch v {
   case .car(let speed) where speed > 150:
       print("Sports car: \(speed)km/h")
   case .car(let speed):
       print("Regular car: \(speed)km/h")
   case .bicycle(let gears) where gears > 10:
       print("Pro bike: \(gears) gears")
   case .bicycle(let gears):
       print("Basic bike: \(gears) gears")
   case .truck(let weight) where weight > 5000:
       print("Heavy truck: \(weight)kg")
   case .truck(let weight):
       print("Light truck: \(weight)kg")
   }
   // Output: Sports car: 200km/h

 WHERE IN FOR LOOP
 ==================
   let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

   for n in numbers where n % 2 == 0 {
       print(n)
   }
   // Output: 2
   //         4
   //         6
   //         8
   //         10

 WHERE IN FOR LOOP WITH ENUM ARRAY
 ===================================
   enum Status { case active, inactive, pending }
   let statuses: [Status] = [.active, .inactive,
                               .active, .pending, .active]

   for case .active in statuses {
       print("Active user found")
   }
   // Output: Active user found
   //         Active user found
   //         Active user found

 WHERE WITH FOR CASE AND CONDITION
 ===================================
   let scores: [Int?] = [95, nil, 72, nil, 88, 45, nil]

   for case let score? in scores where score >= 70 {
       print("Passing score: \(score)")
   }
   // Output: Passing score: 95
   //         Passing score: 72
   //         Passing score: 88

 WHERE IN GENERICS
 ==================
   func printIfEqual<T>(_ a: T, _ b: T) where T: Equatable {
       if a == b {
           print("\(a) equals \(b)")
       } else {
           print("\(a) does not equal \(b)")
       }
   }
   printIfEqual(5, 5)
   // Output: 5 equals 5
   printIfEqual("hello", "world")
   // Output: hello does not equal world

   func sumAll<T>(_ items: [T]) -> T
       where T: Numeric {
       items.reduce(0, +)
   }
   print(sumAll([1, 2, 3, 4, 5]))
   // Output: 15
   print(sumAll([1.5, 2.5, 3.0]))
   // Output: 7.0

 WHERE IN PROTOCOL EXTENSION
 =============================
   extension Collection where Element: Numeric {
       func sum() -> Element {
           reduce(0, +)
       }
   }
   print([1, 2, 3, 4, 5].sum())
   // Output: 15
   print([1.5, 2.5, 3.0].sum())
   // Output: 7.0

   extension Collection where Element: Comparable {
       func clamp(min minVal: Element,
                  max maxVal: Element) -> [Element] {
           map { Swift.max(minVal, Swift.min(maxVal, $0)) }
       }
   }
   print([1, 5, 10, 15, 20].clamp(min: 3, max: 12))
   // Output: [3, 5, 10, 12, 12]

 WHERE IN CONDITIONAL CONFORMANCE
 ==================================
   struct Pair<A, B> {
       var first: A
       var second: B
   }
   extension Pair: Equatable where A: Equatable,
                                    B: Equatable {
       static func == (lhs: Pair, rhs: Pair) -> Bool {
           lhs.first == rhs.first && lhs.second == rhs.second
       }
   }
   let p1 = Pair(first: 1, second: "a")
   let p2 = Pair(first: 1, second: "a")
   let p3 = Pair(first: 2, second: "b")
   print(p1 == p2)    // Output: true
   print(p1 == p3)    // Output: false


 ================================================================
 PART 6 — FOR-IN LOOPS
 ================================================================

 WHAT IS A FOR-IN LOOP?
 =======================
 for-in iterates over sequences — arrays, ranges,
 dictionaries, sets, strings, and anything conforming
 to the Sequence protocol.

 BASIC FOR-IN OVER ARRAY
 ========================
   let fruits = ["Apple", "Banana", "Cherry"]
   for fruit in fruits {
       print(fruit)
   }
   // Output: Apple
   //         Banana
   //         Cherry

 FOR-IN OVER RANGE
 ==================
   for i in 1...5 {
       print(i)
   }
   // Output: 1
   //         2
   //         3
   //         4
   //         5

   for i in 1..<5 {
       print(i)
   }
   // Output: 1
   //         2
   //         3
   //         4

 FOR-IN OVER DICTIONARY
 =======================
   let capitals = ["France": "Paris",
                    "Japan": "Tokyo",
                    "India": "Delhi"]

   for (country, capital) in capitals.sorted(by: { $0.key < $1.key }) {
       print("\(country): \(capital)")
   }
   // Output: France: Paris
   //         India: Delhi
   //         Japan: Tokyo

 FOR-IN OVER STRING
 ===================
   for char in "Swift" {
       print(char)
   }
   // Output: S
   //         w
   //         i
   //         f
   //         t

 FOR-IN WITH ENUMERATED (INDEX + VALUE)
 =======================================
   let colors = ["Red", "Green", "Blue"]
   for (index, color) in colors.enumerated() {
       print("\(index): \(color)")
   }
   // Output: 0: Red
   //         1: Green
   //         2: Blue

 FOR-IN WITH WHERE CLAUSE
 ========================
   for i in 1...20 where i % 3 == 0 {
       print(i)
   }
   // Output: 3
   //         6
   //         9
   //         12
   //         15
   //         18

 FOR-IN IGNORING THE VALUE (_)
 ==============================
   for _ in 1...3 {
       print("Hello")
   }
   // Output: Hello
   //         Hello
   //         Hello

 FOR-IN WITH STRIDE
 ===================
   // Step by 2:
   for i in stride(from: 0, to: 10, by: 2) {
       print(i)
   }
   // Output: 0
   //         2
   //         4
   //         6
   //         8

   // Count down:
   for i in stride(from: 10, through: 0, by: -2) {
       print(i)
   }
   // Output: 10
   //         8
   //         6
   //         4
   //         2
   //         0

 FOR-IN REVERSED
 ================
   for i in (1...5).reversed() {
       print(i)
   }
   // Output: 5
   //         4
   //         3
   //         2
   //         1

 FOR-IN WITH ZIP
 ================
   let names = ["Alice", "Bob", "Eve"]
   let scores = [90, 85, 92]

   for (name, score) in zip(names, scores) {
       print("\(name): \(score)")
   }
   // Output: Alice: 90
   //         Bob: 85
   //         Eve: 92

 FOR-IN OVER SET (UNORDERED)
 ============================
   let uniqueNums: Set = [3, 1, 4, 1, 5, 9]
   for n in uniqueNums.sorted() {
       print(n)
   }
   // Output: 1
   //         3
   //         4
   //         5
   //         9

 FOR-IN WITH FOR CASE (OPTIONAL ARRAY)
 ======================================
   let optionals: [Int?] = [1, nil, 3, nil, 5]
   for case let value? in optionals {
       print(value)
   }
   // Output: 1
   //         3
   //         5

 FOR-IN WITH FOR CASE (ENUM ARRAY)
 ===================================
   enum Event {
       case tap(x: Int, y: Int)
       case swipe(direction: String)
   }
   let events: [Event] = [
       .tap(x: 10, y: 20),
       .swipe(direction: "left"),
       .tap(x: 30, y: 40)
   ]
   for case .tap(let x, let y) in events {
       print("Tap at (\(x), \(y))")
   }
   // Output: Tap at (10, 20)
   //         Tap at (30, 40)

 FOR-IN OVER LAZY SEQUENCE
 ===========================
   // lazy delays computation until needed
   let result = (1...1_000_000)
       .lazy
       .filter { $0 % 2 == 0 }
       .prefix(5)

   for n in result {
       print(n)
   }
   // Output: 2
   //         4
   //         6
   //         8
   //         10

 NESTED FOR-IN
 ==============
   let rows = 3
   let cols = 3

   for row in 1...rows {
       for col in 1...cols {
           print("\(row),\(col)", terminator: " ")
       }
       print()
   }
   // Output: 1,1 1,2 1,3
   //         2,1 2,2 2,3
   //         3,1 3,2 3,3

 MULTIPLICATION TABLE
 =====================
   for i in 1...5 {
       for j in 1...5 {
           print(String(format: "%3d", i * j),
                 terminator: "")
       }
       print()
   }
   // Output:   1  2  3  4  5
   //           2  4  6  8 10
   //           3  6  9 12 15
   //           4  8 12 16 20
   //           5 10 15 20 25


 ================================================================
 PART 7 — WHILE LOOP
 ================================================================

 WHAT IS A WHILE LOOP?
 =====================
 while repeats a block of code as long as the condition
 is true. The condition is checked BEFORE each iteration.
 If the condition is false initially, the body never runs.

 BASIC WHILE
 ============
   var count = 1

   while count <= 5 {
       print(count)
       count += 1
   }
   // Output: 1
   //         2
   //         3
   //         4
   //         5

 WHILE WITH OPTIONAL CHAINING
 ==============================
   var stack = [3, 2, 1]

   while !stack.isEmpty {
       let top = stack.removeLast()
       print("Popped: \(top)")
   }
   print("Stack empty")
   // Output: Popped: 1
   //         Popped: 2
   //         Popped: 3
   //         Stack empty

 WHILE FOR USER INPUT SIMULATION
 ==================================
   var attempts = 0
   let maxAttempts = 3
   var authenticated = false

   while attempts < maxAttempts && !authenticated {
       attempts += 1
       let input = "wrongpass"   // simulated input
       if input == "secret" {
           authenticated = true
           print("Access granted")
       } else {
           print("Attempt \(attempts) failed")
       }
   }
   if !authenticated {
       print("Account locked after \(attempts) attempts")
   }
   // Output: Attempt 1 failed
   //         Attempt 2 failed
   //         Attempt 3 failed
   //         Account locked after 3 attempts

 INFINITE WHILE WITH BREAK
 ===========================
   var value = 1

   while true {
       if value > 5 { break }
       print(value)
       value += 1
   }
   // Output: 1
   //         2
   //         3
   //         4
   //         5

 WHILE WITH CONTINUE
 ====================
   var n = 0
   while n < 10 {
       n += 1
       if n % 2 == 0 { continue }
       print(n)
   }
   // Output: 1
   //         3
   //         5
   //         7
   //         9

 COLLATZ SEQUENCE (PRACTICAL WHILE)
 ====================================
   var num = 12
   var steps = 0

   print(num, terminator: " ")
   while num != 1 {
       if num % 2 == 0 {
           num /= 2
       } else {
           num = num * 3 + 1
       }
       steps += 1
       print(num, terminator: " ")
   }
   print("\nSteps: \(steps)")
   // Output: 12 6 3 10 5 16 8 4 2 1
   //         Steps: 9


 ================================================================
 PART 8 — REPEAT-WHILE LOOP
 ================================================================

 WHAT IS REPEAT-WHILE?
 =====================
 repeat-while executes the body at least once before
 checking the condition. The condition is evaluated
 AFTER the body runs. Similar to do-while in C/Java.

 BASIC REPEAT-WHILE
 ===================
   var i = 1

   repeat {
       print(i)
       i += 1
   } while i <= 5
   // Output: 1
   //         2
   //         3
   //         4
   //         5

 REPEAT-WHILE RUNS AT LEAST ONCE
 ================================
   var x = 100  // condition false from start

   repeat {
       print("Ran at least once: \(x)")
       x += 1
   } while x < 5
   // Output: Ran at least once: 100
   // (body runs once even though 100 < 5 is false)

   // Compare with while — never runs:
   var y = 100
   while y < 5 {
       print("While body")   // never executes
       y += 1
   }
   // Output: (nothing)

 REPEAT-WHILE FOR MENU SIMULATION
 ===================================
   var choice = 0
   var attempts = 0

   repeat {
       attempts += 1
       choice = attempts == 1 ? 2 :
                attempts == 2 ? 3 : 0   // simulated choices
       print("Menu choice: \(choice)")
   } while choice != 0
   print("Exited menu")
   // Output: Menu choice: 2
   //         Menu choice: 3
   //         Menu choice: 0
   //         Exited menu

 REPEAT-WHILE WITH BREAK
 ========================
   var counter = 0
   repeat {
       counter += 1
       print("Counter: \(counter)")
       if counter == 3 { break }
   } while counter < 10
   // Output: Counter: 1
   //         Counter: 2
   //         Counter: 3


 ================================================================
 PART 9 — SWITCH PATTERN MATCHING IN DEPTH
 ================================================================

 EXPRESSION PATTERN (~=)
 ========================
   // ~= is the pattern matching operator used by switch
   let r = 1...10
   print(r ~= 5)
   // Output: true
   print(r ~= 15)
   // Output: false

   // Used implicitly in switch:
   let n = 7
   switch n {
   case 1...5: print("Low")
   case 6...10: print("Medium")
   default: print("High")
   }
   // Output: Medium

 CUSTOM ~= OPERATOR
 ===================
   struct EvenMatcher {}
   let evens = EvenMatcher()

   func ~= (matcher: EvenMatcher, value: Int) -> Bool {
       return value % 2 == 0
   }

   switch 8 {
   case evens: print("Even number")
   default:    print("Odd number")
   }
   // Output: Even number

   switch 7 {
   case evens: print("Even number")
   default:    print("Odd number")
   }
   // Output: Odd number

 TUPLE PATTERN MATCHING
 ========================
   let http = (method: "POST", statusCode: 201)

   switch http {
   case ("GET", 200):
       print("Successful GET")
   case ("POST", 200), ("POST", 201):
       print("Successful POST: \(http.statusCode)")
   case (_, 400):
       print("Bad request")
   case (_, 401):
       print("Unauthorized")
   case (_, 404):
       print("Not found")
   case (let method, let code) where code >= 500:
       print("Server error: \(method) \(code)")
   default:
       print("Unhandled: \(http.method) \(http.statusCode)")
   }
   // Output: Successful POST: 201

 MATCHING OPTIONALS IN SWITCH
 ==============================
   let score: Int? = 95

   switch score {
   case .none:
       print("No score")
   case .some(let s) where s >= 90:
       print("Excellent: \(s)")
   case .some(let s) where s >= 70:
       print("Good: \(s)")
   case .some(let s):
       print("Score: \(s)")
   }
   // Output: Excellent: 95

   let score2: Int? = nil
   switch score2 {
   case .none:       print("No score")
   case .some(let s): print("Score: \(s)")
   }
   // Output: No score

 PATTERN MATCHING WITH IS (TYPE CHECK)
 =======================================
   class Animal { var name: String; init(_ n: String) { name = n } }
   class Dog: Animal { func bark() -> String { "Woof" } }
   class Cat: Animal { func meow() -> String { "Meow" } }

   let pets: [Animal] = [Dog("Rex"), Cat("Whiskers"), Dog("Buddy")]

   for pet in pets {
       switch pet {
       case is Dog:
           print("\(pet.name) is a dog")
       case is Cat:
           print("\(pet.name) is a cat")
       default:
           print("Unknown animal: \(pet.name)")
       }
   }
   // Output: Rex is a dog
   //         Whiskers is a cat
   //         Buddy is a dog

 DOWNCAST PATTERN (AS)
 ======================
   for pet in pets {
       switch pet {
       case let dog as Dog:
           print("\(dog.name) says: \(dog.bark())")
       case let cat as Cat:
           print("\(cat.name) says: \(cat.meow())")
       default:
           print("Unknown")
       }
   }
   // Output: Rex says: Woof
   //         Whiskers says: Meow
   //         Buddy says: Woof

 NESTED PATTERN MATCHING
 ========================
   enum Outer {
       case inner(Int, String)
       case other
   }

   let val = Outer.inner(42, "hello")

   switch val {
   case .inner(let n, let s) where n > 10 && s.count > 3:
       print("Large inner: \(n), \(s)")
   case .inner(let n, _):
       print("Inner: \(n)")
   case .other:
       print("Other")
   }
   // Output: Large inner: 42, hello

 SWITCH WITH COMPLEX ENUM
 =========================
   enum AppState {
       case loading
       case loaded(items: [String], count: Int)
       case error(message: String, retryable: Bool)
       case empty
   }

   let states: [AppState] = [
       .loading,
       .loaded(items: ["A", "B", "C"], count: 3),
       .error(message: "Timeout", retryable: true),
       .empty,
       .error(message: "Auth failed", retryable: false)
   ]

   for state in states {
       switch state {
       case .loading:
           print("Loading...")
       case .loaded(let items, let count):
           print("Loaded \(count) items: \(items.joined(separator: ","))")
       case .error(let msg, true):
           print("Retryable error: \(msg)")
       case .error(let msg, false):
           print("Fatal error: \(msg)")
       case .empty:
           print("No items found")
       }
   }
   // Output: Loading...
   //         Loaded 3 items: A,B,C
   //         Retryable error: Timeout
   //         No items found
   //         Fatal error: Auth failed


 ================================================================
 PART 10 — COMBINING CONTROL FLOW
 ================================================================

 EXAMPLE 1 — FizzBuzz
 =====================
   for i in 1...20 {
       switch (i % 3 == 0, i % 5 == 0) {
       case (true, true):   print("FizzBuzz")
       case (true, false):  print("Fizz")
       case (false, true):  print("Buzz")
       case (false, false): print(i)
       }
   }
   // Output: 1
   //         2
   //         Fizz
   //         4
   //         Buzz
   //         Fizz
   //         7
   //         8
   //         Fizz
   //         Buzz
   //         11
   //         Fizz
   //         13
   //         14
   //         FizzBuzz
   //         16
   //         17
   //         Fizz
   //         19
   //         Buzz

 EXAMPLE 2 — PRIME NUMBER CHECK
 ================================
   func isPrime(_ n: Int) -> Bool {
       guard n >= 2 else { return false }
       guard n != 2 else { return true }
       guard n % 2 != 0 else { return false }
       var i = 3
       while i * i <= n {
           if n % i == 0 { return false }
           i += 2
       }
       return true
   }

   for n in 2...30 where isPrime(n) {
       print("\(n) is prime")
   }
   // Output: 2 is prime
   //         3 is prime
   //         5 is prime
   //         7 is prime
   //         11 is prime
   //         13 is prime
   //         17 is prime
   //         19 is prime
   //         23 is prime
   //         29 is prime

 EXAMPLE 3 — PATTERN MATCH A JSON-LIKE STRUCTURE
 =================================================
   let response: [String: Any] = [
       "status": 200,
       "data": ["name": "Alice", "age": 30],
       "error": NSNull()
   ]

   if let status = response["status"] as? Int {
       switch status {
       case 200..<300:
           if let data = response["data"] as? [String: Any],
              let name = data["name"] as? String {
               print("Success: \(name)")
           }
       case 400..<500:
           print("Client error: \(status)")
       case 500...:
           print("Server error: \(status)")
       default:
           print("Unexpected status: \(status)")
       }
   }
   // Output: Success: Alice

 EXAMPLE 4 — NESTED LOOP WITH LABELED BREAK AND WHERE
 ======================================================
   let grid = [
       [1,  2,  3,  4,  5],
       [6,  7,  8,  9,  10],
       [11, 12, 13, 14, 15],
       [16, 17, 18, 19, 20]
   ]

   var found: (row: Int, col: Int, value: Int)? = nil

   search: for (row, rowData) in grid.enumerated() {
       for (col, value) in rowData.enumerated()
           where value % 7 == 0 {
           found = (row, col, value)
           break search
       }
   }

   if let f = found {
       print("First multiple of 7: \(f.value) at [\(f.row)][\(f.col)]")
   }
   // Output: First multiple of 7: 7 at [1][1]

 EXAMPLE 5 — SWITCH DRIVEN STATE MACHINE
 =========================================
   enum GameState {
       case menu
       case playing(level: Int, lives: Int)
       case paused(level: Int, lives: Int)
       case gameOver(score: Int)
       case victory(score: Int, stars: Int)
   }

   func describe(_ state: GameState) -> String {
       switch state {
       case .menu:
           return "Main Menu"
       case .playing(let level, let lives) where lives > 1:
           return "Playing Level \(level) — \(lives) lives"
       case .playing(let level, _):
           return "Playing Level \(level) — LAST LIFE!"
       case .paused(let level, let lives):
           return "Paused at Level \(level) — \(lives) lives"
       case .gameOver(let score):
           return "Game Over — Score: \(score)"
       case .victory(let score, let stars) where stars == 3:
           return "Perfect Victory! Score: \(score) ⭐⭐⭐"
       case .victory(let score, let stars):
           return "Victory! Score: \(score) — \(stars) stars"
       }
   }

   let states: [GameState] = [
       .menu,
       .playing(level: 1, lives: 3),
       .playing(level: 2, lives: 1),
       .paused(level: 2, lives: 1),
       .gameOver(score: 450),
       .victory(score: 980, stars: 3),
       .victory(score: 720, stars: 2)
   ]

   for state in states {
       print(describe(state))
   }
   // Output: Main Menu
   //         Playing Level 1 — 3 lives
   //         Playing Level 2 — LAST LIFE!
   //         Paused at Level 2 — 1 lives
   //         Game Over — Score: 450
   //         Perfect Victory! Score: 980 ⭐⭐⭐
   //         Victory! Score: 720 — 2 stars


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 SECTION 1 — BASIC LEVEL
 ================================================================

 Q1. What is the difference between if-else and switch?
 ------------------------------------------------------
 A: if-else evaluates Boolean conditions — flexible
    but verbose for many conditions.
    switch matches a value against multiple patterns —
    cleaner, exhaustive, and supports advanced matching.
    Example:
      let x = 3

      // if-else:
      if x == 1 { print("One") }
      else if x == 2 { print("Two") }
      else if x == 3 { print("Three") }
      else { print("Other") }
      // Output: Three

      // switch (cleaner):
      switch x {
      case 1: print("One")
      case 2: print("Two")
      case 3: print("Three")
      default: print("Other")
      }
      // Output: Three


 Q2. Does Swift's switch fall through by default?
 -------------------------------------------------
 A: No. Each case exits after running.
    Fallthrough must be explicit with fallthrough keyword.
    Example:
      let n = 2
      switch n {
      case 2: print("Two")   // only this runs
      case 3: print("Three")
      default: print("Other")
      }
      // Output: Two


 Q3. Can switch cases match ranges?
 -----------------------------------
 A: Yes. Use closed or half-open ranges.
    Example:
      let temp = 22
      switch temp {
      case ..<0:    print("Freezing")
      case 0..<15:  print("Cold")
      case 15..<25: print("Mild")
      case 25...:   print("Hot")
      default:      print("Unknown")
      }
      // Output: Mild


 Q4. What is the difference between while
     and repeat-while?
 -----------------------------------------
 A: while checks condition BEFORE the body.
    repeat-while checks condition AFTER the body.
    repeat-while always runs at least once.
    Example:
      var x = 100
      while x < 5 { print("while"); x += 1 }
      // Output: (nothing — condition false at start)

      var y = 100
      repeat { print("repeat"); y += 1 } while y < 5
      // Output: repeat  (runs once despite false condition)


 Q5. What does guard do?
 ------------------------
 A: guard provides early exit when a condition is false.
    Keeps the happy path unindented. Variables bound
    in guard let are available after the guard block.
    Example:
      func check(_ n: Int?) {
          guard let n = n, n > 0 else {
              print("Invalid")
              return
          }
          print("Valid: \(n)")
      }
      check(5)
      // Output: Valid: 5
      check(nil)
      // Output: Invalid


 Q6. What is the difference between if let
     and guard let?
 ------------------------------------------
 A: if let  — binds value inside the if block only
    guard let — binds value for the rest of the function
    Example:
      func withIfLet(_ s: String?) {
          if let s = s { print("if let: \(s)") }
          // s not available here
      }
      func withGuard(_ s: String?) {
          guard let s = s else { return }
          // s available here and below
          print("guard let: \(s)")
          print("Length: \(s.count)")
      }
      withIfLet("Hello")
      // Output: if let: Hello
      withGuard("Hello")
      // Output: guard let: Hello
      //         Length: 5


 Q7. Can you use for-in over a Dictionary?
 ------------------------------------------
 A: Yes. Iteration gives (key, value) tuples.
    Example:
      let d = ["a": 1, "b": 2, "c": 3]
      for (key, value) in d.sorted(by: { $0.key < $1.key }) {
          print("\(key): \(value)")
      }
      // Output: a: 1
      //         b: 2
      //         c: 3


 Q8. What does the _ mean in a for-in loop?
 -------------------------------------------
 A: It ignores the loop variable when you don't need it.
    Example:
      var sum = 0
      for _ in 1...5 { sum += 10 }
      print(sum)
      // Output: 50


 Q9. What is stride and why use it?
 ------------------------------------
 A: stride creates a sequence with a custom step value,
    for use when you need steps other than 1.
    stride(from:to:by:) — excludes end value
    stride(from:through:by:) — includes end value
    Example:
      for i in stride(from: 0, to: 10, by: 3) {
          print(i)
      }
      // Output: 0, 3, 6, 9

      for i in stride(from: 5, through: 0, by: -1) {
          print(i)
      }
      // Output: 5, 4, 3, 2, 1, 0


 Q10. Can switch match multiple values in one case?
 ---------------------------------------------------
 A: Yes. Separate values with commas.
    Example:
      let day = "Saturday"
      switch day {
      case "Saturday", "Sunday":
          print("Weekend")
      default:
          print("Weekday")
      }
      // Output: Weekend


 Q11. What does the where clause do in a for loop?
 --------------------------------------------------
 A: Filters iterations — only runs the body when
    the where condition is true.
    Example:
      for i in 1...10 where i % 2 == 0 {
          print(i)
      }
      // Output: 2, 4, 6, 8, 10


 Q12. What is enumerated() and why use it?
 ------------------------------------------
 A: enumerated() gives both the index and value
    of each element in a sequence.
    Example:
      let items = ["a", "b", "c"]
      for (i, item) in items.enumerated() {
          print("\(i): \(item)")
      }
      // Output: 0: a
      //         1: b
      //         2: c


 Q13. What is the difference between a closed
      range (1...5) and a half-open range (1..<5)?
 -------------------------------------------------
 A: 1...5 includes both 1 and 5 (5 elements)
    1..<5 includes 1, excludes 5 (4 elements)
    Example:
      print(Array(1...5))
      // Output: [1, 2, 3, 4, 5]
      print(Array(1..<5))
      // Output: [1, 2, 3, 4]


 Q14. What is the ternary operator in Swift?
 --------------------------------------------
 A: condition ? valueIfTrue : valueIfFalse
    A compact one-line if-else expression.
    Example:
      let score = 75
      let grade = score >= 60 ? "Pass" : "Fail"
      print(grade)
      // Output: Pass


 Q15. When does a while loop body never execute?
 ------------------------------------------------
 A: When the condition is false before the first check.
    Example:
      var x = 10
      while x < 5 {
          print("Never runs")
          x += 1
      }
      print("Done")
      // Output: Done


 ================================================================
 SECTION 2 — INTERMEDIATE LEVEL
 ================================================================

 Q16. What is the where clause in a switch case?
 ------------------------------------------------
 A: Adds an extra condition to a pattern.
    The case matches only if BOTH the pattern AND
    the where condition are true.
    Example:
      let n = 42
      switch n {
      case let x where x % 2 == 0 && x > 10:
          print("Large even: \(x)")
      case let x where x % 2 == 0:
          print("Small even: \(x)")
      default:
          print("Odd: \(n)")
      }
      // Output: Large even: 42


 Q17. How does switch handle tuples?
 ------------------------------------
 A: switch can match on tuples, ignoring individual
    components with _ or matching partial values.
    Example:
      let status = (200, "OK")
      switch status {
      case (200, _):    print("Success: \(status.1)")
      case (404, _):    print("Not found")
      case (500, _):    print("Server error")
      default:          print("Unknown: \(status.0)")
      }
      // Output: Success: OK


 Q18. How do you pattern match on Optional values
      in a switch?
 ------------------------------------------------
 A: Use .some(let x) and .none, or the shorthand x?
    Example:
      let val: Int? = 42
      switch val {
      case let x? where x > 10:  print("Big: \(x)")
      case let x?:                print("Small: \(x)")
      case nil:                   print("Nil")
      }
      // Output: Big: 42


 Q19. What is for case and when do you use it?
 ----------------------------------------------
 A: for case filters elements by pattern during iteration.
    Only elements matching the pattern are processed.
    Example:
      let data: [Any] = [1, "hello", 2, "world", 3]
      for case let s as String in data {
          print("String: \(s)")
      }
      // Output: String: hello
      //         String: world


 Q20. What is the difference between for-in with where
      and for-in with if inside?
 ------------------------------------------------------
 A: where — filters BEFORE entering the loop body,
             cleaner and more declarative
    if inside — enters the body then decides,
                allows else and more complex logic
    Example:
      // where — only matching items are processed:
      for i in 1...10 where i % 2 == 0 {
          print("where: \(i)")
      }
      // Output: where: 2
      //         where: 4
      //         where: 6
      //         where: 8
      //         where: 10

      // if inside — enter body for all, branch inside:
      for i in 1...10 {
          if i % 2 == 0 {
              print("if: \(i)")
          }
      }
      // Output: if: 2
      //         if: 4
      //         if: 6
      //         if: 8
      //         if: 10

      // if inside — allows else:
      for i in 1...5 {
          if i % 2 == 0 {
              print("\(i) is even")
          } else {
              print("\(i) is odd")
          }
      }
      // Output: 1 is odd
      //         2 is even
      //         3 is odd
      //         4 is even
      //         5 is odd


 Q21. What is value binding in a switch case?
 ---------------------------------------------
 A: Value binding extracts and names the matched value
    using let or var inside the case pattern.
    Example:
      let point = (3, -3)
      switch point {
      case (let x, 0), (0, let x):
          print("On axis at \(x)")
      case (let x, let y) where x == y:
          print("Diagonal at \(x)")
      case (let x, let y) where x == -y:
          print("Anti-diagonal at \(x), \(y)")
      case (let x, let y):
          print("General point: \(x), \(y)")
      }
      // Output: Anti-diagonal at 3, -3


 Q22. How do you use switch to match against
      a class hierarchy?
 --------------------------------------------
 A: Use as pattern to downcast and match types.
    Example:
      class Vehicle { var speed: Int = 0 }
      class Car: Vehicle {
          var brand: String = ""
          init(brand: String, speed: Int) {
              self.brand = brand
              super.init()
              self.speed = speed
          }
      }
      class Truck: Vehicle {
          var payload: Int = 0
          init(payload: Int, speed: Int) {
              self.payload = payload
              super.init()
              self.speed = speed
          }
      }

      let vehicles: [Vehicle] = [
          Car(brand: "Tesla", speed: 200),
          Truck(payload: 5000, speed: 90),
          Car(brand: "BMW", speed: 180)
      ]

      for v in vehicles {
          switch v {
          case let car as Car where car.speed > 190:
              print("Fast car: \(car.brand) at \(car.speed)km/h")
          case let car as Car:
              print("Car: \(car.brand) at \(car.speed)km/h")
          case let truck as Truck:
              print("Truck: \(truck.payload)kg at \(truck.speed)km/h")
          default:
              print("Unknown vehicle")
          }
      }
      // Output: Fast car: Tesla at 200km/h
      //         Truck: 5000kg at 90km/h
      //         Car: BMW at 180km/h


 Q23. Can you use where in a generic function?
 ----------------------------------------------
 A: Yes. where constrains generic type parameters.
    Example:
      func areEqual<T>(_ a: T, _ b: T) -> Bool
          where T: Equatable {
          return a == b
      }
      print(areEqual(3, 3))
      // Output: true
      print(areEqual("hi", "bye"))
      // Output: false

      func largest<T>(_ a: T, _ b: T) -> T
          where T: Comparable {
          return a > b ? a : b
      }
      print(largest(10, 20))
      // Output: 20
      print(largest("apple", "orange"))
      // Output: orange


 Q24. How does optional binding work with
      multiple conditions?
 --------------------------------------------
 A: Chain multiple conditions with commas.
    All must be true for the block to execute.
    Example:
      let username: String? = "Alice"
      let age: Int? = 22

      if let username = username,
         let age = age,
         !username.isEmpty,
         age >= 18 {
          print("Welcome, \(username)! Age: \(age)")
      } else {
          print("Validation failed")
      }
      // Output: Welcome, Alice! Age: 22

      let username2: String? = ""
      if let username2 = username2,
         let age = age,
         !username2.isEmpty,
         age >= 18 {
          print("Welcome")
      } else {
          print("Validation failed")
      }
      // Output: Validation failed


 Q25. How do you iterate in reverse over
      a collection?
 --------------------------------------------
 A: Use .reversed() on the collection or range.
    Example:
      for i in (1...5).reversed() {
          print(i)
      }
      // Output: 5
      //         4
      //         3
      //         2
      //         1

      let arr = ["a", "b", "c", "d"]
      for item in arr.reversed() {
          print(item)
      }
      // Output: d
      //         c
      //         b
      //         a


 Q26. What is the difference between where
      in a switch and where in a for loop?
 --------------------------------------------
 A: switch where — adds extra condition to a specific case,
                   evaluated after the pattern matches
    for where     — filters which iterations execute,
                    evaluated before the loop body runs
    Example:
      // switch where — condition after pattern match:
      let score = 85
      switch score {
      case let s where s >= 80:
          print("Grade B: \(s)")
      default:
          print("Other: \(score)")
      }
      // Output: Grade B: 85

      // for where — filter before body:
      for s in [90, 55, 80, 70, 45] where s >= 60 {
          print("Pass: \(s)")
      }
      // Output: Pass: 90
      //         Pass: 80
      //         Pass: 70


 Q27. Can you match String patterns in switch?
 ----------------------------------------------
 A: Yes. You can match exact strings or use where
    for prefix/suffix/contains checks.
    Example:
      let command = "play"
      switch command {
      case "play":  print("Playing")
      case "pause": print("Paused")
      case "stop":  print("Stopped")
      default:      print("Unknown: \(command)")
      }
      // Output: Playing

      // With where for prefix matching:
      let input = "play rock music"
      switch input {
      case let s where s.hasPrefix("play"):
          print("Play command: \(s)")
      case let s where s.hasPrefix("stop"):
          print("Stop command: \(s)")
      default:
          print("Unknown command: \(input)")
      }
      // Output: Play command: play rock music


 Q28. How does lazy affect a for-in loop?
 -----------------------------------------
 A: lazy makes the sequence compute elements only
    when needed, improving performance for large
    collections when only a subset is needed.
    Example:
      // Without lazy — processes all 1,000,000 elements:
      let eagerResult = (1...1_000_000)
          .filter { $0 % 2 == 0 }
          .prefix(3)

      // With lazy — stops after finding 3:
      let lazyResult = (1...1_000_000)
          .lazy
          .filter { $0 % 2 == 0 }
          .prefix(3)

      for n in lazyResult {
          print(n)
      }
      // Output: 2
      //         4
      //         6


 Q29. How do you use zip with for-in?
 -------------------------------------
 A: zip pairs elements from two sequences together.
    Stops at the shorter sequence.
    Example:
      let keys = ["name", "age", "city"]
      let values = ["Alice", "30", "New York"]

      for (key, value) in zip(keys, values) {
          print("\(key): \(value)")
      }
      // Output: name: Alice
      //         age: 30
      //         city: New York

      // zip stops at shorter:
      let a = [1, 2, 3, 4, 5]
      let b = ["one", "two", "three"]
      for (n, word) in zip(a, b) {
          print("\(n) — \(word)")
      }
      // Output: 1 — one
      //         2 — two
      //         3 — three


 Q30. How does guard differ from if-else in
      readability and intent?
 --------------------------------------------
 A: guard expresses "this must be true to continue."
    It documents preconditions and keeps the happy path
    at the left margin (less indentation).
    if-else is for two equally valid branches.
    Example:
      // if-else — both paths equally indented:
      func processIfElse(_ val: Int?) {
          if let val = val {
              if val > 0 {
                  print("Processing: \(val)")
                  // more code here — deeply nested
              } else {
                  print("Must be positive")
              }
          } else {
              print("No value")
          }
      }

      // guard — happy path stays flat:
      func processGuard(_ val: Int?) {
          guard let val = val else {
              print("No value")
              return
          }
          guard val > 0 else {
              print("Must be positive")
              return
          }
          print("Processing: \(val)")
          // more code here — not nested
      }

      processGuard(5)
      // Output: Processing: 5
      processGuard(-1)
      // Output: Must be positive
      processGuard(nil)
      // Output: No value


 ================================================================
 SECTION 3 — ADVANCED LEVEL
 ================================================================

 Q31. What is the ~= operator and how does
      switch use it?
 --------------------------------------------
 A: ~= is the pattern matching operator.
    switch implicitly uses ~= to check if a value
    matches a pattern. You can overload it.
    Example:
      // Built-in ~= for ranges:
      let r = 1...10
      print(r ~= 5)
      // Output: true

      // Swift uses ~= implicitly in switch:
      let n = 7
      switch n {
      case 1...5:  print("Low")
      case 6...10: print("Medium")
      default:     print("High")
      }
      // Output: Medium

      // Custom ~= overload:
      func ~= (pattern: String, value: Int) -> Bool {
          return value.description == pattern
      }
      switch 42 {
      case "42":   print("Matched string pattern")
      default:     print("No match")
      }
      // Output: Matched string pattern


 Q32. How does switch interact with protocols?
 ----------------------------------------------
 A: Switch can check and cast to protocol types
    using is and as patterns.
    Example:
      protocol Drawable { func draw() -> String }
      protocol Resizable { func resize(by: Double) -> String }

      struct Circle: Drawable, Resizable {
          func draw() -> String { "Drawing circle" }
          func resize(by f: Double) -> String {
              "Resizing circle by \(f)"
          }
      }
      struct Line: Drawable {
          func draw() -> String { "Drawing line" }
      }

      let shapes: [Any] = [Circle(), Line(), Circle()]
      for shape in shapes {
          switch shape {
          case let r as Resizable & Drawable:
              print(r.draw())
              print(r.resize(by: 2.0))
          case let d as Drawable:
              print(d.draw())
          default:
              print("Unknown shape")
          }
      }
      // Output: Drawing circle
      //         Resizing circle by 2.0
      //         Drawing line
      //         Drawing circle
      //         Resizing circle by 2.0


 Q33. How do you use where in a protocol extension?
 ---------------------------------------------------
 A: where constrains which types receive the extension.
    Example:
      extension Sequence where Element: Numeric {
          func sum() -> Element { reduce(0, +) }
          func average() -> Double {
              let s = reduce(0.0) { $0 + Double("\($1)")! ?? 0 }
              return s / Double(Array(self).count)
          }
      }

      extension Sequence where Element: Comparable {
          func sorted_desc() -> [Element] {
              sorted(by: >)
          }
          func minMax() -> (min: Element, max: Element)? {
              guard let first = self.min(),
                    let last  = self.max() else { return nil }
              return (first, last)
          }
      }

      print([3, 1, 4, 1, 5, 9, 2].sum())
      // Output: 25

      print([3, 1, 4, 1, 5, 9, 2].sorted_desc())
      // Output: [9, 5, 4, 3, 2, 1, 1]

      if let mm = [3, 1, 4, 1, 5, 9].minMax() {
          print("Min: \(mm.min) Max: \(mm.max)")
      }
      // Output: Min: 1 Max: 9


 Q34. How does for-in work with custom Sequence types?
 -----------------------------------------------------
 A: Conform to Sequence and IteratorProtocol.
    Implement makeIterator() and next().
    Example:
      struct Countdown: Sequence {
          let start: Int
          func makeIterator() -> CountdownIterator {
              return CountdownIterator(current: start)
          }
      }

      struct CountdownIterator: IteratorProtocol {
          var current: Int
          mutating func next() -> Int? {
              guard current >= 0 else { return nil }
              defer { current -= 1 }
              return current
          }
      }

      for n in Countdown(start: 5) {
          print(n)
      }
      // Output: 5
      //         4
      //         3
      //         2
      //         1
      //         0


 Q35. What is the difference between for-in
      and forEach?
 --------------------------------------------
 A: for-in    — language construct, supports break/continue
    forEach   — method on Sequence, closure-based,
                return acts as continue, break not available
    Example:
      // for-in — break and continue work:
      for i in 1...5 {
          if i == 3 { break }
          print("for: \(i)")
      }
      // Output: for: 1
      //         for: 2

      // forEach — only return (acts as continue):
      (1...5).forEach { i in
          if i == 3 { return }    // like continue
          print("forEach: \(i)")
      }
      // Output: forEach: 1
      //         forEach: 2
      //         forEach: 4
      //         forEach: 5

      // forEach — break is NOT allowed:
      // (1...5).forEach { if $0 == 3 { break } }
      // Error: 'break' is only inside a loop


 Q36. How do you switch over multiple associated
      values using tuple destructuring?
 --------------------------------------------
 A: Extract all associated values as a tuple
    and apply switch patterns.
    Example:
      enum APIResponse {
          case success(statusCode: Int, body: String)
          case failure(statusCode: Int, reason: String)
      }

      func handle(_ response: APIResponse) {
          switch response {
          case .success(200, let body):
              print("OK: \(body)")
          case .success(201, let body):
              print("Created: \(body)")
          case .success(let code, _) where code >= 202:
              print("Other success: \(code)")
          case .failure(401, _):
              print("Unauthorized — please login")
          case .failure(404, let reason):
              print("Not found: \(reason)")
          case .failure(let code, let reason) where code >= 500:
              print("Server error \(code): \(reason)")
          default:
              print("Unhandled response")
          }
      }

      handle(.success(statusCode: 200, body: "User data"))
      // Output: OK: User data
      handle(.failure(statusCode: 401, reason: "Token expired"))
      // Output: Unauthorized — please login
      handle(.failure(statusCode: 503, reason: "Overloaded"))
      // Output: Server error 503: Overloaded


 Q37. What is conditional conformance with where?
 -------------------------------------------------
 A: A type conditionally conforms to a protocol
    only when its generic parameter meets a requirement.
    Example:
      struct Stack<Element> {
          private var items: [Element] = []
          mutating func push(_ item: Element) {
              items.append(item)
          }
          mutating func pop() -> Element? {
              items.popLast()
          }
          var top: Element? { items.last }
      }

      // Stack is Equatable only when Element is Equatable:
      extension Stack: Equatable where Element: Equatable {
          static func == (lhs: Stack, rhs: Stack) -> Bool {
              lhs.items == rhs.items
          }
      }

      var s1 = Stack<Int>()
      s1.push(1); s1.push(2)

      var s2 = Stack<Int>()
      s2.push(1); s2.push(2)

      var s3 = Stack<Int>()
      s3.push(1); s3.push(9)

      print(s1 == s2)
      // Output: true
      print(s1 == s3)
      // Output: false


 Q38. How do you express an exhaustive switch
      over an open enum or external type?
 --------------------------------------------
 A: Add a default case. The compiler cannot guarantee
    exhaustiveness for enums from other modules
    (@frozen vs non-frozen).
    In Swift 5+, use @unknown default to get a warning
    when new cases are added.
    Example:
      // @unknown default — warns on new cases:
      enum Direction { case north, south, east, west }
      let d = Direction.north

      switch d {
      case .north: print("North")
      case .south: print("South")
      case .east:  print("East")
      case .west:  print("West")
      @unknown default:
          print("Unknown direction")
      }
      // Output: North
      // If a new case is added in future, compiler warns


 Q39. How does if-let work with computed properties?
 ----------------------------------------------------
 A: if let unwraps any Optional expression including
    computed properties that return Optional.
    Example:
      struct Config {
          var rawTimeout: String = "30"

          var timeout: Int? {
              return Int(rawTimeout)
          }
      }

      var config = Config()
      if let t = config.timeout {
          print("Timeout: \(t)s")
      }
      // Output: Timeout: 30s

      config.rawTimeout = "invalid"
      if let t = config.timeout {
          print("Timeout: \(t)s")
      } else {
          print("Invalid timeout")
      }
      // Output: Invalid timeout


 Q40. How do switch and guard work together?
 --------------------------------------------
 A: guard with enum pattern for early exit,
    switch for full handling when you need all cases.
    Example:
      enum Permission { case read, write, admin }

      func performAction(action: String,
                         permission: Permission) {
          guard case .admin = permission else {
              // Only admin can write
              if action == "write" {
                  print("Write denied — admin required")
                  return
              }
              print("Reading: \(action)")
              return
          }
          // Admin path:
          switch action {
          case "write":  print("Admin writing")
          case "delete": print("Admin deleting")
          default:       print("Admin action: \(action)")
          }
      }

      performAction(action: "write", permission: .read)
      // Output: Write denied — admin required

      performAction(action: "view", permission: .read)
      // Output: Reading: view

      performAction(action: "delete", permission: .admin)
      // Output: Admin deleting


 ================================================================
 SECTION 4 — EXPERT LEVEL
 ================================================================

 Q41. How does Swift optimize switch statements
      compared to if-else chains?
 --------------------------------------------
 A: Swift compiles switch to jump tables or binary
    search trees depending on the case density.
    Dense integer ranges — O(1) jump table
    Sparse / string cases — O(log n) binary search
    if-else chains — O(n) linear evaluation

    Practical implication: switch is generally
    faster than long if-else chains for many branches.
    Example:
      // Switch — potentially O(1) for dense Int ranges:
      let code = 200
      switch code {
      case 200: print("OK")
      case 201: print("Created")
      case 400: print("Bad Request")
      case 404: print("Not Found")
      case 500: print("Server Error")
      default:  print("Other: \(code)")
      }
      // Output: OK

      // Long if-else — always O(n) evaluation:
      if code == 200 { print("OK") }
      else if code == 201 { print("Created") }
      // ... up to 500 — each condition evaluated in order


 Q42. How do you build a decision tree using
      nested switch?
 --------------------------------------------
 A: Nest switch statements for hierarchical decisions.
    Example:
      enum Tier   { case free, pro, enterprise }
      enum Action { case read, write, delete, admin }

      func canPerform(tier: Tier, action: Action) -> Bool {
          switch tier {
          case .free:
              switch action {
              case .read:  return true
              default:     return false
              }
          case .pro:
              switch action {
              case .read, .write: return true
              default:            return false
              }
          case .enterprise:
              return true    // all actions allowed
          }
      }

      print(canPerform(tier: .free, action: .read))
      // Output: true
      print(canPerform(tier: .free, action: .write))
      // Output: false
      print(canPerform(tier: .pro, action: .write))
      // Output: true
      print(canPerform(tier: .pro, action: .delete))
      // Output: false
      print(canPerform(tier: .enterprise, action: .admin))
      // Output: true


 Q43. How do where clauses work with
      associated type constraints?
 --------------------------------------------
 A: In protocols with associated types, where clauses
    constrain what the associated types must be.
    Example:
      protocol Container {
          associatedtype Item
          var items: [Item] { get }
      }

      // Extension only for containers of Comparable items:
      extension Container where Item: Comparable {
          func sortedItems() -> [Item] {
              items.sorted()
          }
          func minItem() -> Item? {
              items.min()
          }
          func maxItem() -> Item? {
              items.max()
          }
      }

      struct NumberBox: Container {
          var items: [Int]
      }

      let box = NumberBox(items: [5, 3, 8, 1, 9, 2])
      print(box.sortedItems())
      // Output: [1, 2, 3, 5, 8, 9]
      print(box.minItem() ?? -1)
      // Output: 1
      print(box.maxItem() ?? -1)
      // Output: 9


 Q44. How does for-in work with AsyncSequence?
 ----------------------------------------------
 A: for await in iterates over async sequences —
    sequences that produce values asynchronously.
    Example:
      struct Counter: AsyncSequence {
          typealias Element = Int
          let limit: Int

          struct AsyncIterator: AsyncIteratorProtocol {
              var current = 1
              let limit: Int
              mutating func next() async -> Int? {
                  guard current <= limit else { return nil }
                  defer { current += 1 }
                  return current
              }
          }
          func makeAsyncIterator() -> AsyncIterator {
              AsyncIterator(current: 1, limit: limit)
          }
      }

      Task {
          for await n in Counter(limit: 5) {
              print("Async: \(n)")
          }
      }
      // Output: Async: 1
      //         Async: 2
      //         Async: 3
      //         Async: 4
      //         Async: 5


 Q45. How do you implement a custom
      pattern matching operator?
 --------------------------------------------
 A: Overload ~= with the pattern type on the left
    and the matched value on the right.
    Example:
      // Match Int against a closure predicate:
      func ~= (predicate: (Int) -> Bool, value: Int) -> Bool {
          predicate(value)
      }

      let isEven: (Int) -> Bool = { $0 % 2 == 0 }
      let isPrime: (Int) -> Bool = { n in
          guard n >= 2 else { return false }
          guard n != 2 else { return true }
          guard n % 2 != 0 else { return false }
          var i = 3
          while i * i <= n { if n % i == 0 { return false }; i += 2 }
          return true
      }

      let number = 7
      switch number {
      case isPrime:  print("\(number) is prime")
      case isEven:   print("\(number) is even")
      default:       print("\(number) is odd composite")
      }
      // Output: 7 is prime

      let number2 = 8
      switch number2 {
      case isPrime:  print("\(number2) is prime")
      case isEven:   print("\(number2) is even")
      default:       print("\(number2) is odd composite")
      }
      // Output: 8 is even


 Q46. How does where interact with
      multiple generic constraints?
 --------------------------------------------
 A: Use commas or multiple where conditions.
    Example:
      func merge<K, V>(_ dicts: [K: V]...) -> [K: V]
          where K: Hashable, V: Equatable {
          var result: [K: V] = [:]
          for dict in dicts {
              for (key, value) in dict {
                  if result[key] == nil {
                      result[key] = value
                  }
              }
          }
          return result
      }

      let merged = merge(["a": 1, "b": 2],
                         ["b": 99, "c": 3],
                         ["d": 4])
      print(merged.sorted(by: { $0.key < $1.key })
                  .map { "\($0.key):\($0.value)" })
      // Output: ["a:1", "b:2", "c:3", "d:4"]


 Q47. What are the performance characteristics
      of while vs for-in vs forEach?
 --------------------------------------------
 A: for-in   — preferred for sequences, compiler-optimized,
                bridge to C for arrays in optimized builds
    while     — preferred when loop count is not known upfront,
                slightly more control
    forEach   — closure overhead — slightly slower in some
                cases, but negligible for most use cases

    Best practice:
    - Use for-in for known sequences
    - Use while for unknown termination conditions
    - Use forEach when passing the loop as a value
    Example:
      let arr = Array(1...1000000)

      // for-in — fastest for arrays:
      var sum1 = 0
      for n in arr { sum1 += n }
      print(sum1)
      // Output: 500000500000

      // forEach — clean but closure overhead:
      var sum2 = 0
      arr.forEach { sum2 += $0 }
      print(sum2)
      // Output: 500000500000

      // reduce — functional, compiles well:
      let sum3 = arr.reduce(0, +)
      print(sum3)
      // Output: 500000500000


 Q48. How do you use if expressions (Swift 5.9+)?
 -------------------------------------------------
 A: In Swift 5.9+, if and switch can be used as
    expressions — returning values directly.
    Example:
      let score = 82

      // if as expression (Swift 5.9+):
      let grade = if score >= 90 { "A" }
                  else if score >= 80 { "B" }
                  else if score >= 70 { "C" }
                  else { "F" }
      print(grade)
      // Output: B

      // switch as expression (Swift 5.9+):
      let desc = switch score {
      case 90...:     "Excellent"
      case 80..<90:   "Good"
      case 70..<80:   "Average"
      default:        "Needs work"
      }
      print(desc)
      // Output: Good

      // In a return statement:
      func classify(_ n: Int) -> String {
          switch n {
          case ..<0:   "Negative"
          case 0:      "Zero"
          default:     "Positive"
          }
      }
      print(classify(-5))
      // Output: Negative
      print(classify(0))
      // Output: Zero
      print(classify(7))
      // Output: Positive


 Q49. How do nested where clauses in generics work?
 ---------------------------------------------------
 A: Chain multiple where constraints in a single clause.
    Example:
      // Two associated types both constrained:
      func zip_match<S1: Sequence, S2: Sequence>(
          _ s1: S1,
          _ s2: S2
      ) -> [(S1.Element, S2.Element)]
          where S1.Element: Equatable,
                S2.Element: Equatable,
                S1.Element == S2.Element {
          zip(s1, s2).filter { $0.0 == $0.1 }
      }

      let matches = zip_match([1, 2, 3, 4], [1, 9, 3, 8])
      print(matches)
      // Output: [(1, 1), (3, 3)]


 Q50. How does pattern matching in switch handle
      recursive types?
 --------------------------------------------
 A: For indirect enums, use recursive switch calls
    to traverse the recursive structure.
    Example:
      indirect enum JSON {
          case null
          case bool(Bool)
          case number(Double)
          case string(String)
          case array([JSON])
          case object([String: JSON])
      }

      func describe(_ json: JSON, indent: Int = 0) -> String {
          let pad = String(repeating: "  ", count: indent)
          switch json {
          case .null:
              return "\(pad)null"
          case .bool(let b):
              return "\(pad)\(b)"
          case .number(let n):
              return "\(pad)\(n)"
          case .string(let s):
              return "\(pad)\"\(s)\""
          case .array(let items):
              let inner = items.map {
                  describe($0, indent: indent + 1)
              }.joined(separator: ",\n")
              return "\(pad)[\n\(inner)\n\(pad)]"
          case .object(let dict):
              let inner = dict.sorted(by: { $0.key < $1.key })
                  .map { "\(pad)  \"\($0.key)\": "
                         + describe($0.value) }
                  .joined(separator: ",\n")
              return "\(pad){\n\(inner)\n\(pad)}"
          }
      }

      let json = JSON.object([
          "name":   .string("Alice"),
          "age":    .number(30),
          "active": .bool(true),
          "scores": .array([.number(95), .number(87)])
      ])
      print(describe(json))
      // Output:
      // {
      //   "active": true,
      //   "age": 30.0,
      //   "name": "Alice",
      //   "scores": [
      //     95.0,
      //     87.0
      //   ]
      // }


 ================================================================
 PART 11 — COMPLETE QUICK REFERENCE CHEAT SHEET
 ================================================================

 IF / ELSE
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Basic if                          | if condition { }
 if-else                           | if condition { } else { }
 if-else if-else                   | if a { } else if b { } else { }
 Ternary                           | condition ? valueIfTrue : valueIfFalse
 Nil coalescing                    | value ?? default
 Chained nil coalescing            | a ?? b ?? c ?? default
 Optional binding                  | if let x = optional { }
 Optional binding shorthand        | if let x { } (Swift 5.7+)
 Multiple optional binding         | if let a = a, let b = b, condition { }
 Optional binding + condition      | if let x = val, x > 0 { }
 If case enum match                | if case .enumCase = value { }
 If case with associated value     | if case .case(let x) = value { }
 If as expression (Swift 5.9+)     | let x = if cond { a } else { b }

 GUARD
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Basic guard                       | guard condition else { return }
 Guard let                         | guard let x = optional else { return }
 Guard let shorthand               | guard let x else { return } (Swift 5.7+)
 Multiple guard conditions         | guard let a = a, let b = b, cond else { }
 Guard throw                       | guard condition else { throw error }
 Guard with enum                   | guard case .value = enum else { return }

 SWITCH
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Basic switch                      | switch value { case a: ... default: ... }
 Multiple values per case          | case "a", "b", "c":
 Range in case                     | case 1...5:
 Half-open range                   | case 1..<5:
 One-sided range                   | case ..<0: / case 10...:
 Tuple matching                    | case (0, 0):
 Wildcard in tuple                 | case (_, 0):
 Value binding                     | case let x:
 Binding + where                   | case let x where x > 10:
 Associated value extraction       | case .enumCase(let value):
 Type check pattern                | case is MyType:
 Downcast pattern                  | case let x as MyType:
 Optional pattern                  | case let x?:
 Fallthrough                       | fallthrough
 @unknown default                  | @unknown default:
 Switch as expression (5.9+)       | let x = switch val { case a: v1 ... }

 WHERE CLAUSES
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Where in switch case              | case let x where x > 10:
 Where in for loop                 | for x in seq where condition { }
 Where in generic function         | func f<T>(_ x: T) where T: Equatable { }
 Where multiple constraints        | where T: Equatable, T: Comparable
 Where in protocol extension       | extension Sequence where Element: Numeric
 Where conditional conformance     | extension T: Equatable where U: Equatable
 Where associated type constraint  | where S.Element: Comparable

 FOR-IN LOOPS
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Iterate array                     | for item in array { }
 Iterate range                     | for i in 1...5 { }
 Iterate dictionary                | for (key, value) in dict { }
 Iterate string                    | for char in string { }
 Ignore value                      | for _ in 1...n { }
 With index                        | for (i, val) in array.enumerated() { }
 With where filter                 | for x in seq where condition { }
 Reversed                          | for i in (1...5).reversed() { }
 Stride with step                  | for i in stride(from: 0, to: 10, by: 2) { }
 Stride inclusive                  | for i in stride(from: 0, through: 10, by: 2) { }
 Zip two sequences                 | for (a, b) in zip(seq1, seq2) { }
 Optional filter                   | for case let x? in optionals { }
 Enum case filter                  | for case .value(let x) in enums { }
 Lazy sequence                     | for x in seq.lazy.filter { }.prefix(n) { }
 Async sequence                    | for await x in asyncSeq { }
 Nested for-in                     | for i in a { for j in b { } }

 WHILE LOOPS
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Basic while                       | while condition { }
 Infinite loop with break          | while true { if cond { break } }
 While with continue               | while cond { if skip { continue } }
 While with optional               | while let x = next() { }

 REPEAT-WHILE LOOPS
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Basic repeat-while                | repeat { } while condition
 Always runs at least once         | repeat { body } while false
 With break                        | repeat { if cond { break } } while true

 PATTERN MATCHING
 Task                              | Code
 ----------------------------------|---------------------------------------------
 Custom ~= operator                | func ~= (pattern: P, value: V) -> Bool { }
 Match in if                       | if case pattern = value { }
 Match in guard                    | guard case pattern = value else { }
 Match in for                      | for case pattern in sequence { }
 Match range                       | switch x { case 1...5: }
 Match tuple                       | switch (a,b) { case (1, _): }
 Match type                        | switch x { case is MyType: }
 Match and cast                    | switch x { case let y as MyType: }
 Match optional                    | switch x { case let v?: }
 Match with condition              | switch x { case let v where v > 0: }


 */
