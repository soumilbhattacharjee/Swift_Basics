import UIKit


/*
 CONTROL TRANSFER IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 continue, break, fallthrough, return, throw
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 PART 1 — WHAT IS CONTROL TRANSFER?
 ================================================================

 WHAT IS CONTROL TRANSFER?
 ==========================
 Control transfer statements change the order in which
 code is executed by transferring control from one part
 of code to another.

 Swift has five control transfer statements:
   1. continue   — skip current iteration, continue loop
   2. break      — exit a loop or switch statement entirely
   3. fallthrough — continue to the next case in a switch
   4. return     — exit a function and optionally return a value
   5. throw      — transfer control to an error handler

 SUMMARY TABLE
 =============
 Statement     | Used In              | Effect
 --------------|----------------------|----------------------------------
 continue      | Loops                | Skip rest of current iteration
 break         | Loops / switch       | Exit loop or switch entirely
 fallthrough   | switch               | Fall into the next case
 return        | Functions / closures | Exit function, return value
 throw         | Throwing functions   | Transfer to error handler


 ================================================================
 PART 2 — CONTINUE
 ================================================================

 WHAT IS CONTINUE?
 =================
 continue skips the remaining code in the current loop
 iteration and moves to the next iteration.
 Works in for, while, and repeat-while loops.

 BASIC CONTINUE IN FOR LOOP
 ===========================
   for i in 1...10 {
       if i % 2 == 0 {
           continue       // skip even numbers
       }
       print(i)
   }
   // Output: 1
   //         3
   //         5
   //         7
   //         9

 CONTINUE IN WHILE LOOP
 =======================
   var i = 0
   while i < 10 {
       i += 1
       if i % 3 == 0 {
           continue       // skip multiples of 3
       }
       print(i)
   }
   // Output: 1
   //         2
   //         4
   //         5
   //         7
   //         8
   //         10

 CONTINUE IN REPEAT-WHILE LOOP
 ==============================
   var count = 0
   repeat {
       count += 1
       if count == 3 || count == 6 {
           continue
       }
       print(count)
   } while count < 8
   // Output: 1
   //         2
   //         4
   //         5
   //         7
   //         8

 CONTINUE SKIPPING STRINGS
 ==========================
   let words = ["apple", "banana", "skip", "cherry", "skip", "date"]
   for word in words {
       if word == "skip" {
           continue
       }
       print(word)
   }
   // Output: apple
   //         banana
   //         cherry
   //         date

 CONTINUE WITH LABELED STATEMENT
 ================================
 Labeled continue skips the current iteration of a
 specific outer loop, not just the innermost loop.

   outer: for i in 1...3 {
       for j in 1...3 {
           if j == 2 {
               continue outer    // skip to next i iteration
           }
           print("i=\(i) j=\(j)")
       }
   }
   // Output: i=1 j=1
   //         i=2 j=1
   //         i=3 j=1

 WITHOUT LABEL (for comparison)
 ================================
   for i in 1...3 {
       for j in 1...3 {
           if j == 2 {
               continue          // only skips inner loop
           }
           print("i=\(i) j=\(j)")
       }
   }
   // Output: i=1 j=1
   //         i=1 j=3
   //         i=2 j=1
   //         i=2 j=3
   //         i=3 j=1
   //         i=3 j=3

 PRACTICAL EXAMPLE — FILTER PROCESSING
 =======================================
   let scores = [72, -1, 88, -1, 95, 60, -1, 45]
   var total = 0
   var validCount = 0

   for score in scores {
       if score < 0 {
           continue      // skip invalid scores
       }
       total += score
       validCount += 1
   }
   print("Total: \(total), Count: \(validCount)")
   // Output: Total: 360, Count: 5

   print("Average: \(total / validCount)")
   // Output: Average: 72


 ================================================================
 PART 3 — BREAK
 ================================================================

 WHAT IS BREAK?
 ==============
 break immediately exits the nearest enclosing loop
 or switch statement. Execution continues with the
 first line of code after the loop or switch.

 BREAK IN FOR LOOP
 ==================
   for i in 1...10 {
       if i == 5 {
           break         // stop at 5
       }
       print(i)
   }
   // Output: 1
   //         2
   //         3
   //         4

 BREAK IN WHILE LOOP
 ====================
   var n = 0
   while true {
       n += 1
       if n == 4 {
           break
       }
       print(n)
   }
   print("Exited at \(n)")
   // Output: 1
   //         2
   //         3
   //         Exited at 4

 BREAK IN REPEAT-WHILE
 ======================
   var x = 10
   repeat {
       print(x)
       x -= 3
       if x < 0 {
           break
       }
   } while true
   // Output: 10
   //         7
   //         4
   //         1

 BREAK IN SWITCH
 ================
   let code = 200
   switch code {
   case 200:
       print("OK")
       break          // optional here — switch ends anyway
   case 404:
       print("Not Found")
   default:
       print("Unknown")
   }
   // Output: OK

 BREAK TO SKIP A SWITCH CASE
 ============================
   let value = 5
   switch value {
   case 1...10:
       if value == 5 {
           break      // exit switch early — do nothing for 5
       }
       print("Value in 1-10: \(value)")
   default:
       print("Other")
   }
   // Output: (nothing printed — break exited switch)

 BREAK WITH LABELED STATEMENT
 ==============================
 Labeled break exits a specific outer loop or switch.

   outer: for i in 1...5 {
       for j in 1...5 {
           if i == 2 && j == 3 {
               break outer       // exit both loops entirely
           }
           print("i=\(i) j=\(j)")
       }
   }
   print("Done")
   // Output: i=1 j=1
   //         i=1 j=2
   //         i=1 j=3
   //         i=1 j=4
   //         i=1 j=5
   //         i=2 j=1
   //         i=2 j=2
   //         Done

 WITHOUT LABEL (for comparison)
 ================================
   for i in 1...3 {
       for j in 1...3 {
           if j == 2 {
               break          // only exits inner loop
           }
           print("i=\(i) j=\(j)")
       }
   }
   // Output: i=1 j=1
   //         i=2 j=1
   //         i=3 j=1

 PRACTICAL EXAMPLE — SEARCH AND STOP
 =====================================
   let users = ["Alice", "Bob", "Eve", "Charlie", "Dave"]
   var found = false

   for user in users {
       if user == "Eve" {
           found = true
           break       // no need to search further
       }
   }
   print(found ? "Found Eve" : "Not found")
   // Output: Found Eve

 BREAK IN NESTED SWITCH AND LOOP
 ================================
   let commands = ["start", "stop", "pause", "stop", "resume"]
   var processed: [String] = []

   for cmd in commands {
       switch cmd {
       case "stop":
           processed.append(cmd)
           break           // exits switch — loop continues
       case "start", "pause", "resume":
           processed.append(cmd)
       default:
           break
       }
   }
   print(processed)
   // Output: ["start", "stop", "pause", "stop", "resume"]


 ================================================================
 PART 4 — FALLTHROUGH
 ================================================================

 WHAT IS FALLTHROUGH?
 ====================
 fallthrough causes execution to continue into the
 NEXT case in a switch statement regardless of whether
 that case's condition matches.

 IMPORTANT: Swift switch does NOT fall through by default.
 You must explicitly use fallthrough to get this behavior.
 This is the OPPOSITE of C, Java, and other languages.

 BASIC FALLTHROUGH
 ==================
   let x = 1
   switch x {
   case 1:
       print("One")
       fallthrough
   case 2:
       print("Two (fell through from One or matched Two)")
       fallthrough
   case 3:
       print("Three (fell through)")
   case 4:
       print("Four")
   default:
       print("Other")
   }
   // Output: One
   //         Two (fell through from One or matched Two)
   //         Three (fell through)

 WITHOUT FALLTHROUGH (default Swift behavior)
 =============================================
   let x = 1
   switch x {
   case 1: print("One")
   case 2: print("Two")
   case 3: print("Three")
   default: print("Other")
   }
   // Output: One   ← only One, no fallthrough

 FALLTHROUGH CHAIN
 ==================
   let grade = "B"
   switch grade {
   case "A":
       print("Excellent")
       fallthrough
   case "B":
       print("Good — qualifies for honor roll")
       fallthrough
   case "C":
       print("Passed")
   case "D", "F":
       print("Failed")
   default:
       print("Invalid grade")
   }
   // Output: Good — qualifies for honor roll
   //         Passed

 NOTE ON FALLTHROUGH BEHAVIOR
 =============================
 fallthrough does NOT check the next case's condition.
 It blindly falls into the next case body.
 Example:
   let n = 10
   switch n {
   case 10:
       print("Ten")
       fallthrough
   case 20:
       print("This prints even though n is not 20")
   default:
       print("Default")
   }
   // Output: Ten
   //         This prints even though n is not 20

 FALLTHROUGH CANNOT BIND VALUES
 ================================
   let val = 5
   switch val {
   case 5:
       print("Five")
       fallthrough
   case let x where x > 3:    // Error if trying to bind x after fallthrough
       print("Greater than 3")
   default:
       break
   }
   // Note: fallthrough cannot be used when the next case
   // uses value binding (let/var patterns)

 PRACTICAL EXAMPLE — CUMULATIVE LOGGING
 ========================================
   let logLevel = 1   // 1 = error, 2 = warning, 3 = info

   switch logLevel {
   case 1:
       print("[ERROR] Something went wrong")
       fallthrough
   case 2:
       print("[WARNING] Check this issue")
       fallthrough
   case 3:
       print("[INFO] System running")
   default:
       print("Unknown log level")
   }
   // Output: [ERROR] Something went wrong
   //         [WARNING] Check this issue
   //         [INFO] System running

 FALLTHROUGH IS RARE IN SWIFT
 ==============================
 In most Swift code, fallthrough is rarely used.
 Swift encourages exhaustive switches without fallthrough.
 Prefer multiple comma-separated patterns instead:

   // Instead of fallthrough:
   switch x {
   case 1:
       print("One")
       fallthrough
   case 2:
       print("Handling")
   default: break
   }

   // Prefer this:
   switch x {
   case 1, 2:
       print("Handling one or two")
   default: break
   }
   // Output: Handling one or two (if x == 1)


 ================================================================
 PART 5 — RETURN
 ================================================================

 WHAT IS RETURN?
 ===============
 return exits a function, method, closure, or computed
 property. It can optionally return a value.
 In functions that return a value, return must provide
 a value of the matching type.

 BASIC RETURN
 =============
   func greet(name: String) -> String {
       return "Hello, \(name)!"
   }
   print(greet(name: "Alice"))
   // Output: Hello, Alice!

 EARLY RETURN — INPUT VALIDATION
 ================================
   func divide(_ a: Double, _ b: Double) -> Double {
       if b == 0 {
           return 0      // early return for invalid input
       }
       return a / b
   }
   print(divide(10, 2))
   // Output: 5.0
   print(divide(10, 0))
   // Output: 0.0

 RETURN IN VOID FUNCTION
 ========================
   func printIfPositive(_ n: Int) {
       if n <= 0 {
           return       // exit early, print nothing
       }
       print("Positive: \(n)")
   }
   printIfPositive(5)
   // Output: Positive: 5
   printIfPositive(-3)
   // Output: (nothing)

 IMPLICIT RETURN (SINGLE EXPRESSION)
 =====================================
   // In Swift, if the function body is a single expression,
   // return is implicit
   func square(_ n: Int) -> Int {
       n * n              // implicit return
   }
   print(square(4))
   // Output: 16

   func fullName(first: String, last: String) -> String {
       "\(first) \(last)"  // implicit return
   }
   print(fullName(first: "John", last: "Doe"))
   // Output: John Doe

 RETURN IN COMPUTED PROPERTY
 ============================
   struct Circle {
       var radius: Double
       var area: Double {
           return Double.pi * radius * radius
       }
       var circumference: Double {
           Double.pi * 2 * radius  // implicit return
       }
   }
   let c = Circle(radius: 5)
   print(String(format: "%.2f", c.area))
   // Output: 78.54
   print(String(format: "%.2f", c.circumference))
   // Output: 31.42

 RETURN IN CLOSURE
 ==================
   let doubled = [1, 2, 3, 4, 5].map { value -> Int in
       return value * 2
   }
   print(doubled)
   // Output: [2, 4, 6, 8, 10]

   // Implicit return in closure:
   let tripled = [1, 2, 3].map { $0 * 3 }
   print(tripled)
   // Output: [3, 6, 9]

 MULTIPLE RETURN POINTS
 =======================
   func classify(_ score: Int) -> String {
       if score >= 90 { return "A" }
       if score >= 80 { return "B" }
       if score >= 70 { return "C" }
       if score >= 60 { return "D" }
       return "F"
   }
   print(classify(95))   // Output: A
   print(classify(82))   // Output: B
   print(classify(55))   // Output: F

 RETURNING TUPLES
 =================
   func minMax(of array: [Int]) -> (min: Int, max: Int)? {
       guard !array.isEmpty else { return nil }
       return (array.min()!, array.max()!)
   }
   if let result = minMax(of: [3, 1, 4, 1, 5, 9, 2]) {
       print("Min: \(result.min), Max: \(result.max)")
   }
   // Output: Min: 1, Max: 9

   print(minMax(of: []))
   // Output: nil

 RETURNING OPTIONALS
 ====================
   func findUser(id: Int) -> String? {
       let users = [1: "Alice", 2: "Bob", 3: "Eve"]
       return users[id]
   }
   print(findUser(id: 2) ?? "Not found")
   // Output: Bob
   print(findUser(id: 99) ?? "Not found")
   // Output: Not found

 RETURNING CLOSURES
 ===================
   func makeMultiplier(by factor: Int) -> (Int) -> Int {
       return { number in
           return number * factor
       }
   }
   let triple = makeMultiplier(by: 3)
   print(triple(7))
   // Output: 21

   let double = makeMultiplier(by: 2)
   print(double(9))
   // Output: 18

 RETURNING RESULT TYPE
 ======================
   func safeDivide(_ a: Int, _ b: Int) -> Result<Int, Error> {
       guard b != 0 else {
           return .failure(
               NSError(domain: "Math", code: 0,
                       userInfo: [NSLocalizedDescriptionKey:
                                  "Division by zero"])
           )
       }
       return .success(a / b)
   }
   switch safeDivide(10, 2) {
   case .success(let v): print("Result: \(v)")
   case .failure(let e): print("Error: \(e.localizedDescription)")
   }
   // Output: Result: 5

   switch safeDivide(10, 0) {
   case .success(let v): print("Result: \(v)")
   case .failure(let e): print("Error: \(e.localizedDescription)")
   }
   // Output: Error: Division by zero

 RETURN IN SWITCH
 =================
   func httpMessage(for code: Int) -> String {
       switch code {
       case 200: return "OK"
       case 201: return "Created"
       case 400: return "Bad Request"
       case 401: return "Unauthorized"
       case 404: return "Not Found"
       case 500: return "Internal Server Error"
       default:  return "Unknown Status"
       }
   }
   print(httpMessage(for: 404))
   // Output: Not Found
   print(httpMessage(for: 200))
   // Output: OK

 @discardableResult
 ==================
   // Suppress warning when caller ignores return value
   @discardableResult
   func logAndReturn(_ message: String) -> String {
       print("LOG: \(message)")
       return message
   }
   logAndReturn("App started")    // no warning
   // Output: LOG: App started

   let msg = logAndReturn("Step complete")
   print(msg)
   // Output: LOG: Step complete
   //         Step complete

 NEVER RETURN TYPE
 ==================
   // A function that never returns (crashes or loops forever)
   func crash() -> Never {
       fatalError("This should never happen")
   }

   func requirePositive(_ n: Int) -> Int {
       guard n > 0 else {
           fatalError("n must be positive, got \(n)")
       }
       return n
   }


 ================================================================
 PART 6 — THROW
 ================================================================

 WHAT IS THROW?
 ==============
 throw transfers control from a function to an error
 handler. A function must be marked throws to throw.
 The caller must use try to call a throwing function.
 Errors are caught with do-catch.

 DEFINING AN ERROR
 ==================
   enum NetworkError: Error {
       case noConnection
       case timeout(seconds: Int)
       case invalidURL(String)
       case serverError(code: Int, message: String)
   }

 BASIC THROW AND CATCH
 ======================
   func fetchData(from url: String) throws -> String {
       guard url.hasPrefix("https") else {
           throw NetworkError.invalidURL(url)
       }
       return "Data from \(url)"
   }

   do {
       let data = try fetchData(from: "https://example.com")
       print(data)
   } catch NetworkError.invalidURL(let url) {
       print("Invalid URL: \(url)")
   } catch {
       print("Unknown error: \(error)")
   }
   // Output: Data from https://example.com

   do {
       let data = try fetchData(from: "http://example.com")
       print(data)
   } catch NetworkError.invalidURL(let url) {
       print("Invalid URL: \(url)")
   } catch {
       print("Unknown error: \(error)")
   }
   // Output: Invalid URL: http://example.com

 MULTIPLE THROWS
 ================
   func connect(host: String, timeout: Int) throws -> String {
       guard !host.isEmpty else {
           throw NetworkError.invalidURL("Empty host")
       }
       guard timeout > 0 else {
           throw NetworkError.timeout(seconds: timeout)
       }
       guard host != "unreachable" else {
           throw NetworkError.noConnection
       }
       return "Connected to \(host)"
   }

   do {
       print(try connect(host: "example.com", timeout: 30))
   } catch {
       print("Error: \(error)")
   }
   // Output: Connected to example.com

   do {
       print(try connect(host: "", timeout: 30))
   } catch NetworkError.invalidURL(let u) {
       print("Invalid URL: \(u)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Invalid URL: Empty host

   do {
       print(try connect(host: "unreachable", timeout: 30))
   } catch NetworkError.noConnection {
       print("No connection available")
   } catch {
       print("Error: \(error)")
   }
   // Output: No connection available

 CATCH ALL ERRORS
 =================
   do {
       let result = try fetchData(from: "ftp://old.com")
       print(result)
   } catch {
       print("Caught: \(error)")
   }
   // Output: Caught: invalidURL("ftp://old.com")

 CATCH WITH WHERE CLAUSE
 ========================
   do {
       try connect(host: "server", timeout: 0)
   } catch NetworkError.timeout(let sec) where sec <= 0 {
       print("Timeout must be positive, got \(sec)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Timeout must be positive, got 0

 TRY? — CONVERT TO OPTIONAL
 ============================
   let data1 = try? fetchData(from: "https://example.com")
   print(data1 ?? "nil")
   // Output: Data from https://example.com

   let data2 = try? fetchData(from: "ftp://bad.com")
   print(data2 ?? "nil")
   // Output: nil

 TRY! — FORCE TRY (UNSAFE)
 ===========================
   let data3 = try! fetchData(from: "https://safe.com")
   print(data3)
   // Output: Data from https://safe.com

   let data4 = try! fetchData(from: "ftp://bad.com")
   // CRASH: Fatal error — fetchData threw an error

 RETHROWING FUNCTIONS
 =====================
   // A function that rethrows only if its closure throws
   func process(_ value: Int,
                using transform: (Int) throws -> Int) rethrows -> Int {
       return try transform(value)
   }

   // Non-throwing closure — no try needed by caller
   let result1 = process(5) { $0 * 2 }
   print(result1)
   // Output: 10

   // Throwing closure — caller must use try
   enum TransformError: Error { case negative }
   let result2 = try? process(-3) { n throws -> Int in
       guard n >= 0 else { throw TransformError.negative }
       return n * 2
   }
   print(result2 ?? "nil")
   // Output: nil

 THROWING INITIALIZER
 =====================
   enum ConfigError: Error {
       case missingKey(String)
       case invalidValue(String)
   }

   struct Config {
       var host: String
       var port: Int

       init(dict: [String: String]) throws {
           guard let host = dict["host"] else {
               throw ConfigError.missingKey("host")
           }
           guard let portStr = dict["port"],
                 let port = Int(portStr) else {
               throw ConfigError.invalidValue("port")
           }
           self.host = host
           self.port = port
       }
   }

   do {
       let config = try Config(dict: ["host": "localhost",
                                       "port": "8080"])
       print("Host: \(config.host), Port: \(config.port)")
   } catch ConfigError.missingKey(let key) {
       print("Missing key: \(key)")
   } catch ConfigError.invalidValue(let key) {
       print("Invalid value for: \(key)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Host: localhost, Port: 8080

   do {
       let config = try Config(dict: ["host": "localhost"])
       print(config.host)
   } catch ConfigError.missingKey(let key) {
       print("Missing key: \(key)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Missing key: port

 THROWING COMPUTED PROPERTY (Swift 5.5+)
 =========================================
   struct File {
       var path: String

       var contents: String {
           get throws {
               guard !path.isEmpty else {
                   throw ConfigError.missingKey("path")
               }
               return "Contents of \(path)"
           }
       }
   }

   let file = File(path: "readme.txt")
   if let contents = try? file.contents {
       print(contents)
   }
   // Output: Contents of readme.txt

 DEFER WITH THROW
 ================
   // defer always runs even when throw occurs
   func openFile(name: String) throws {
       print("Opening \(name)")
       defer {
           print("Closing \(name)")  // always runs
       }
       guard name != "locked.txt" else {
           throw ConfigError.missingKey("Access denied")
       }
       print("Reading \(name)")
   }

   do {
       try openFile(name: "data.txt")
   } catch {
       print("Error: \(error)")
   }
   // Output: Opening data.txt
   //         Reading data.txt
   //         Closing data.txt

   do {
       try openFile(name: "locked.txt")
   } catch {
       print("Error: \(error)")
   }
   // Output: Opening locked.txt
   //         Closing locked.txt
   //         Error: missingKey("Access denied")

 ERROR HANDLING IN ASYNC FUNCTIONS
 ===================================
   enum APIError: Error {
       case invalidResponse
       case decodingFailed
   }

   func fetchUser(id: Int) async throws -> String {
       guard id > 0 else {
           throw APIError.invalidResponse
       }
       return "User \(id)"
   }

   // Usage:
   Task {
       do {
           let user = try await fetchUser(id: 1)
           print(user)
       } catch APIError.invalidResponse {
           print("Invalid response")
       } catch {
           print("Error: \(error)")
       }
   }
   // Output: User 1

 CHAINING THROWING FUNCTIONS
 ============================
   func validateInput(_ input: String) throws -> String {
       guard !input.isEmpty else {
           throw ConfigError.invalidValue("input cannot be empty")
       }
       return input.trimmingCharacters(in: .whitespaces)
   }

   func parseNumber(_ input: String) throws -> Int {
       let trimmed = try validateInput(input)
       guard let number = Int(trimmed) else {
           throw ConfigError.invalidValue("not a number: \(trimmed)")
       }
       return number
   }

   func doubleNumber(_ input: String) throws -> Int {
       return try parseNumber(input) * 2
   }

   do {
       print(try doubleNumber("  21  "))
   } catch {
       print("Error: \(error)")
   }
   // Output: 42

   do {
       print(try doubleNumber("abc"))
   } catch ConfigError.invalidValue(let msg) {
       print("Invalid: \(msg)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Invalid: not a number: abc

   do {
       print(try doubleNumber("   "))
   } catch ConfigError.invalidValue(let msg) {
       print("Invalid: \(msg)")
   } catch {
       print("Error: \(error)")
   }
   // Output: Invalid: input cannot be empty


 ================================================================
 PART 7 — LABELED STATEMENTS (BREAK AND CONTINUE)
 ================================================================

 WHAT ARE LABELED STATEMENTS?
 ==============================
 Labels name a loop or switch so that break or continue
 can target that specific loop, not just the innermost one.
 Syntax: labelName: loop { }

 LABELED BREAK EXAMPLE
 =======================
   search: for i in 1...5 {
       for j in 1...5 {
           if i * j > 6 {
               print("First product > 6: \(i) * \(j) = \(i*j)")
               break search
           }
       }
   }
   // Output: First product > 6: 2 * 4 = 8

 LABELED CONTINUE EXAMPLE
 ==========================
   gameLoop: for round in 1...3 {
       for player in ["Alice", "Bob", "Eve"] {
           if player == "Bob" {
               continue gameLoop   // Bob skips, next round
           }
           print("Round \(round): \(player) plays")
       }
   }
   // Output: Round 1: Alice plays
   //         Round 2: Alice plays
   //         Round 3: Alice plays

 LABELED SWITCH WITH BREAK
 ===========================
   outer: for number in 1...5 {
       switch number {
       case 3:
           print("Found 3 — breaking outer loop")
           break outer
       default:
           print("Number: \(number)")
       }
   }
   // Output: Number: 1
   //         Number: 2
   //         Found 3 — breaking outer loop

 WITHOUT LABEL (switch break does not exit loop)
 ================================================
   for number in 1...5 {
       switch number {
       case 3:
           print("Found 3 — only breaks switch")
           break           // exits switch, NOT the loop
       default:
           print("Number: \(number)")
       }
   }
   // Output: Number: 1
   //         Number: 2
   //         Found 3 — only breaks switch
   //         Number: 4
   //         Number: 5


 ================================================================
 PART 8 — DEFER (BONUS — RELATED TO CONTROL TRANSFER)
 ================================================================

 WHAT IS DEFER?
 ==============
 defer schedules code to run when the current scope exits,
 regardless of how it exits — normal return, break,
 continue, or throw. Multiple defers run in LIFO order
 (last in, first out).

 BASIC DEFER
 ============
   func processFile() {
       print("Start")
       defer { print("Cleanup") }
       print("Working")
       print("Done")
   }
   processFile()
   // Output: Start
   //         Working
   //         Done
   //         Cleanup

 DEFER WITH EARLY RETURN
 ========================
   func validate(value: Int) -> String {
       defer { print("validate() finished") }
       guard value > 0 else {
           return "Invalid"    // defer still runs
       }
       return "Valid: \(value)"
   }
   print(validate(value: 5))
   // Output: validate() finished
   //         Valid: 5

   print(validate(value: -1))
   // Output: validate() finished
   //         Invalid

 MULTIPLE DEFERS — LIFO ORDER
 =============================
   func multiDefer() {
       defer { print("First defer — runs last") }
       defer { print("Second defer — runs second") }
       defer { print("Third defer — runs first") }
       print("Function body")
   }
   multiDefer()
   // Output: Function body
   //         Third defer — runs first
   //         Second defer — runs second
   //         First defer — runs last

 DEFER IN LOOP
 ==============
   for i in 1...3 {
       defer { print("Deferred \(i)") }
       print("Loop \(i)")
   }
   // Output: Loop 1
   //         Deferred 1
   //         Loop 2
   //         Deferred 2
   //         Loop 3
   //         Deferred 3


 ================================================================
 PART 9 — SUMMARY COMPARISON TABLE
 ================================================================

 Statement    | Where Used        | What Happens                  | Can target outer scope?
 -------------|-------------------|-------------------------------|------------------------
 continue     | Loops             | Skips current iteration       | Yes — with label
 break        | Loops / switch    | Exits loop or switch          | Yes — with label
 fallthrough  | switch only       | Falls to next case            | No
 return       | Functions         | Exits function, returns value | No
 throw        | Throwing funcs    | Transfers to error handler    | Yes — up call stack
 defer        | Any scope         | Runs on scope exit            | No


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 SECTION 1 — BASIC LEVEL
 ================================================================

 Q1. What are control transfer statements in Swift?
 ---------------------------------------------------
 A: Statements that change the order of execution:
    continue, break, fallthrough, return, throw.
    Example:
      for i in 1...5 {
          if i == 3 { continue }
          if i == 5 { break }
          print(i)
      }
      // Output: 1
      //         2
      //         4


 Q2. What does continue do in a loop?
 --------------------------------------
 A: Skips the rest of the current iteration and
    moves to the next one.
    Example:
      for i in 1...5 {
          if i % 2 == 0 { continue }
          print(i)
      }
      // Output: 1
      //         3
      //         5


 Q3. What does break do in a loop?
 -----------------------------------
 A: Immediately exits the loop entirely.
    Example:
      for i in 1...5 {
          if i == 3 { break }
          print(i)
      }
      // Output: 1
      //         2


 Q4. What does break do in a switch statement?
 ----------------------------------------------
 A: Exits the switch statement. In Swift, break in a
    switch is optional — each case exits by default.
    Use break to explicitly do nothing in a case.
    Example:
      let x = 5
      switch x {
      case 5:
          print("Five")
          break        // optional — same effect without it
      default:
          print("Other")
      }
      // Output: Five


 Q5. Does Swift switch fall through by default?
 -----------------------------------------------
 A: No. Swift switch does NOT fall through by default.
    Each case exits automatically after its code runs.
    This is different from C, Java, and other languages.
    Example:
      let x = 1
      switch x {
      case 1: print("One")
      case 2: print("Two")
      default: print("Other")
      }
      // Output: One  (only One — no fallthrough)


 Q6. What is fallthrough in Swift?
 ----------------------------------
 A: Explicitly causes execution to continue into the
    next switch case, regardless of that case's condition.
    Example:
      let x = 1
      switch x {
      case 1:
          print("One")
          fallthrough
      case 2:
          print("Two — fell through")
      default:
          print("Default")
      }
      // Output: One
      //         Two — fell through


 Q7. What does return do in a function?
 ----------------------------------------
 A: Exits the function and optionally returns a value.
    Example:
      func greet(_ name: String) -> String {
          return "Hello, \(name)!"
      }
      print(greet("Bob"))
      // Output: Hello, Bob!


 Q8. What is throw used for?
 -----------------------------
 A: throw transfers control to an error handler when
    something goes wrong. The function must be marked
    throws and the caller must use do-catch or try?.
    Example:
      enum SimpleError: Error { case failed }
      func doWork() throws {
          throw SimpleError.failed
      }
      do {
          try doWork()
      } catch {
          print("Caught: \(error)")
      }
      // Output: Caught: failed


 Q9. What is the difference between break and continue?
 -------------------------------------------------------
 A: break  — exits the loop entirely
    continue — skips the current iteration, loop continues
    Example:
      for i in 1...5 {
          if i == 3 {
              print("break at \(i):")
              break
          }
      }
      // Output: break at 3:

      for i in 1...5 {
          if i == 3 { continue }
          print(i)
      }
      // Output: 1, 2, 4, 5


 Q10. What keyword marks a function as one that can throw?
 ---------------------------------------------------------
 A: throws placed after the parameter list.
    Example:
      func riskyFunc() throws -> String {
          return "OK"
      }
      let result = try? riskyFunc()
      print(result ?? "nil")
      // Output: OK


 Q11. What is try? and what does it return?
 -------------------------------------------
 A: try? converts a throwing call to an Optional.
    Returns nil if an error is thrown.
    Example:
      enum Err: Error { case bad }
      func fail() throws -> Int { throw Err.bad }
      func succeed() throws -> Int { return 42 }

      print(try? fail())
      // Output: nil
      print(try? succeed())
      // Output: Optional(42)


 Q12. What is try! and when is it dangerous?
 --------------------------------------------
 A: try! force-unwraps a throwing call.
    Crashes at runtime if an error is thrown.
    Example:
      print(try! succeed())
      // Output: 42

      print(try! fail())
      // CRASH: Fatal error — threw an error


 Q13. Can you use continue in a switch statement?
 -------------------------------------------------
 A: Not directly. continue only works in loops.
    If a switch is inside a loop, continue skips
    to the next loop iteration.
    Example:
      for i in 1...5 {
          switch i {
          case 3: continue    // skips loop iteration 3
          default: print(i)
          }
      }
      // Output: 1
      //         2
      //         4
      //         5


 Q14. What is implicit return in Swift?
 ---------------------------------------
 A: If a function body is a single expression,
    the return keyword can be omitted.
    Example:
      func double(_ n: Int) -> Int { n * 2 }
      print(double(5))
      // Output: 10

      func welcome(_ name: String) -> String {
          "Welcome, \(name)!"
      }
      print(welcome("Alice"))
      // Output: Welcome, Alice!


 Q15. What is the Error protocol?
 ----------------------------------
 A: A protocol that types conform to in order to be
    thrown and caught. Usually implemented with enum.
    Example:
      enum AppError: Error {
          case notFound
          case invalidInput
      }
      func find(id: Int) throws -> String {
          guard id > 0 else {
              throw AppError.invalidInput
          }
          return "Item \(id)"
      }
      do {
          print(try find(id: -1))
      } catch AppError.invalidInput {
          print("Invalid input")
      } catch {
          print("Error: \(error)")
      }
      // Output: Invalid input


 ================================================================
 SECTION 2 — INTERMEDIATE LEVEL
 ================================================================

 Q16. What are labeled statements and why use them?
 ---------------------------------------------------
 A: Labels name a loop or switch so break or continue
    can target that specific scope, not just the nearest.
    Example:
      outer: for i in 1...3 {
          for j in 1...3 {
              if j == 2 { continue outer }
              print("i=\(i) j=\(j)")
          }
      }
      // Output: i=1 j=1
      //         i=2 j=1
      //         i=3 j=1


 Q17. What is the difference between labeled break
      and unlabeled break in a nested loop?
 -----------------------------------------------
 A: Unlabeled break exits the innermost loop only.
    Labeled break exits the named outer loop.
    Example:
      // Unlabeled — only exits inner loop:
      for i in 1...3 {
          for j in 1...3 {
              if j == 2 { break }
              print("i=\(i) j=\(j)")
          }
      }
      // Output: i=1 j=1, i=2 j=1, i=3 j=1

      // Labeled — exits outer loop entirely:
      outer: for i in 1...3 {
          for j in 1...3 {
              if j == 2 { break outer }
              print("i=\(i) j=\(j)")
          }
      }
      // Output: i=1 j=1


 Q18. What does fallthrough NOT do compared to C/Java?
 ------------------------------------------------------
 A: In C/Java, switch falls through every case by default.
    In Swift, fallthrough is explicit and rare.
    Also, Swift's fallthrough does NOT re-evaluate the
    next case condition — it blindly executes it.
    Example:
      let n = 1
      switch n {
      case 1:
          print("Matched 1")
          fallthrough
      case 99:
          print("This runs even though n is not 99")
      default:
          print("Default")
      }
      // Output: Matched 1
      //         This runs even though n is not 99


 Q19. Can fallthrough be used with value binding?
 -------------------------------------------------
 A: No. If the next case uses let/var binding,
    you cannot fall through into it.
    Example:
      let x = 1
      switch x {
      case 1:
          fallthrough
      case let y where y > 0:    // Error — cannot fallthrough
          print(y)               // into value-binding case
      default: break
      }
      // Compile error: Expression not allowed on
      // fallthrough destination


 Q20. What happens to defer when an error is thrown?
 ----------------------------------------------------
 A: defer still executes even when a throw occurs,
    ensuring cleanup code always runs.
    Example:
      func readFile() throws {
          defer { print("File closed") }
          print("File opened")
          throw NetworkError.noConnection
      }
      do {
          try readFile()
      } catch {
          print("Error caught: \(error)")
      }
      // Output: File opened
      //         File closed
      //         Error caught: noConnection


 Q21. What is the difference between return and throw
      for error handling?
 ------------------------------------------------------
 A: return — normal exit, returns a value or nothing
    throw  — exceptional exit, signals an error to caller

    return is for expected outcomes.
    throw is for unexpected failures.
    Example:
      // return approach:
      func divide(_ a: Int, _ b: Int) -> Int? {
          guard b != 0 else { return nil }
          return a / b
      }
      print(divide(10, 0) ?? "nil")
      // Output: nil

      // throw approach (richer context):
      enum MathError: Error { case divisionByZero }
      func safeDivide(_ a: Int, _ b: Int) throws -> Int {
          guard b != 0 else { throw MathError.divisionByZero }
          return a / b
      }
      do {
          print(try safeDivide(10, 0))
      } catch MathError.divisionByZero {
          print("Cannot divide by zero")
      }
      // Output: Cannot divide by zero


 Q22. Can a function both throw and return a value?
 ---------------------------------------------------
 A: Yes. A throwing function can return a value on
    success and throw on failure.
    Example:
      func parse(age: String) throws -> Int {
          guard let n = Int(age) else {
              throw ConfigError.invalidValue("Not a number: \(age)")
          }
          guard n >= 0 && n <= 150 else {
              throw ConfigError.invalidValue("Out of range: \(n)")
          }
          return n
      }
      do {
          print(try parse(age: "25"))
      } catch { print("Error: \(error)") }
      // Output: 25

      do {
          print(try parse(age: "abc"))
      } catch { print("Error: \(error)") }
      // Output: Error: invalidValue("Not a number: abc")


 Q23. What is rethrows?
 ------------------------
 A: rethrows marks a function that only throws if
    one of its closure parameters throws. If a
    non-throwing closure is passed, no try is needed.
    Example:
      func applyTwice(_ n: Int,
                      _ f: (Int) throws -> Int)
                      rethrows -> Int {
          return try f(try f(n))
      }

      // Non-throwing closure — no try needed
      let result1 = applyTwice(3) { $0 + 1 }
      print(result1)
      // Output: 5

      // Throwing closure — try needed
      enum Err: Error { case overflow }
      let result2 = try? applyTwice(999) { n throws -> Int in
          guard n < 1000 else { throw Err.overflow }
          return n + 1
      }
      print(result2 ?? "nil")
      // Output: nil


 Q24. How do you propagate an error up the call stack?
 ------------------------------------------------------
 A: A throwing function that calls another throwing
    function with try propagates the error upward.
    The error travels up until a do-catch handles it.
    Example:
      func step1() throws -> Int {
          throw AppError.notFound
      }
      func step2() throws -> Int {
          return try step1() + 1    // propagates error
      }
      func step3() throws -> Int {
          return try step2() * 2    // propagates error
      }
      do {
          print(try step3())
      } catch AppError.notFound {
          print("Error propagated to top: notFound")
      }
      // Output: Error propagated to top: notFound


 Q25. Can continue be used outside a loop?
 ------------------------------------------
 A: No. continue is only valid inside a loop
    (for, while, repeat-while).
    Using it outside a loop causes a compile error.
    Example:
      continue    // Error: 'continue' is only allowed
                  // inside a loop


 Q26. Can break be used outside a loop or switch?
 -------------------------------------------------
 A: No. break is only valid inside loops or switch.
    Using it outside causes a compile error.
    Example:
      break       // Error: 'break' is only allowed
                  // inside a loop, if, do, or switch


 Q27. What is @discardableResult and how does it
      relate to return?
 -----------------------------------------------
 A: Normally Swift warns when a returned value is ignored.
    @discardableResult suppresses this warning.
    Example:
      @discardableResult
      func updateDatabase() -> Bool {
          print("Database updated")
          return true
      }
      updateDatabase()          // no warning
      // Output: Database updated

      let success = updateDatabase()
      print(success)
      // Output: Database updated
      //         true


 Q28. How do you use multiple catch clauses?
 --------------------------------------------
 A: List multiple catch clauses from specific to general.
    Example:
      enum DBError: Error {
          case connectionFailed
          case queryFailed(String)
          case timeout
      }
      func queryDB(sql: String) throws -> String {
          throw DBError.queryFailed("Syntax error in: \(sql)")
      }
      do {
          print(try queryDB(sql: "SELCT *"))
      } catch DBError.connectionFailed {
          print("Cannot connect")
      } catch DBError.queryFailed(let msg) {
          print("Query failed: \(msg)")
      } catch DBError.timeout {
          print("Query timed out")
      } catch {
          print("Unknown DB error: \(error)")
      }
      // Output: Query failed: Syntax error in: SELCT *


 Q29. Can you catch multiple error types in one clause?
 ------------------------------------------------------
 A: Yes. Separate patterns with commas.
    Example:
      do {
          try queryDB(sql: "DROP TABLE")
      } catch DBError.connectionFailed, DBError.timeout {
          print("Infrastructure problem")
      } catch {
          print("Other error: \(error)")
      }
      // Output: Other error: queryFailed(...)


 Q30. What does a catch block without a pattern match?
 ------------------------------------------------------
 A: It catches all errors — equivalent to catch let error.
    Example:
      do {
          try queryDB(sql: "BAD")
      } catch {
          print("Error: \(error)")
          // error is automatically bound
      }
      // Output: Error: queryFailed("Syntax error in: BAD")


 ================================================================
 SECTION 3 — ADVANCED LEVEL
 ================================================================

 Q31. How does continue work in a forEach vs for loop?
 ------------------------------------------------------
 A: continue works in for loops.
    forEach is a closure — return acts like continue.
    You cannot use continue inside forEach.
    Example:
      // for loop — continue works:
      for i in 1...5 {
          if i == 3 { continue }
          print(i)
      }
      // Output: 1, 2, 4, 5

      // forEach — use return to skip:
      (1...5).forEach { i in
          if i == 3 { return }   // acts like continue
          print(i)
      }
      // Output: 1, 2, 4, 5

      // forEach — break does NOT work:
      // (1...5).forEach { if $0 == 3 { break } } // Error


 Q32. Can you use break in forEach?
 ------------------------------------
 A: No. break cannot be used in forEach because it
    is a closure, not a loop. Use a for loop instead.
    Example:
      // Error — break not allowed in closure:
      // (1...5).forEach { if $0 == 3 { break } }

      // Use for loop instead:
      for i in 1...5 {
          if i == 3 { break }
          print(i)
      }
      // Output: 1
      //         2


 Q33. How do continue and break behave differently
      in a repeat-while loop?
 --------------------------------------------------
 A: continue — goes back to the loop body (re-evaluates
               condition at the end after the body runs)
    break     — exits the loop immediately

    Example:
      var i = 0
      repeat {
          i += 1
          if i == 3 { continue }
          print(i)
      } while i < 5
      // Output: 1, 2, 4, 5
      // (3 is skipped, but condition i < 5 is still checked)

      var j = 0
      repeat {
          j += 1
          if j == 3 { break }
          print(j)
      } while j < 5
      // Output: 1, 2


 Q34. What is the Never return type?
 -------------------------------------
 A: Never is used for functions that never return.
    They either loop forever, crash, or throw.
    Example:
      func fatalMistake() -> Never {
          fatalError("This should not happen")
      }

      func assertPositive(_ n: Int) -> Int {
          guard n > 0 else {
              fatalError("Expected positive, got \(n)")
          }
          return n
      }
      // Never-returning functions can appear in any
      // branch without the compiler needing a return.


 Q35. How do throw, try, and do-catch work together?
 ----------------------------------------------------
 A: throw — function signals an error and exits
    try   — caller acknowledges the function can throw
    do-catch — caller handles the error
    Example:
      enum ParseError: Error { case invalidFormat }
      func parseDate(_ str: String) throws -> String {
          guard str.count == 10 else {
              throw ParseError.invalidFormat
          }
          return "Parsed: \(str)"
      }
      do {
          let d = try parseDate("2024-01-15")
          print(d)
      } catch ParseError.invalidFormat {
          print("Bad date format")
      }
      // Output: Parsed: 2024-01-15

      do {
          let d = try parseDate("bad")
          print(d)
      } catch ParseError.invalidFormat {
          print("Bad date format")
      }
      // Output: Bad date format


 Q36. What is the difference between try, try?, and try!?
 ---------------------------------------------------------
 A: try    — use in do-catch, propagates error upward
    try?   — wraps result in Optional, nil on error
    try!   — force unwraps, crashes on error

    Example:
      func risky() throws -> Int { return 42 }
      func riskier() throws -> Int { throw AppError.notFound }

      // try — must be in do-catch or throws context
      do {
          let v = try risky()
          print(v)              // Output: 42
      } catch { }

      // try? — returns Optional
      print(try? risky())       // Output: Optional(42)
      print(try? riskier())     // Output: nil

      // try! — crashes on error
      print(try! risky())       // Output: 42
      // try! riskier()         // CRASH


 Q37. Can return appear in a guard statement?
 ---------------------------------------------
 A: Yes. guard requires an else clause that must
    exit the current scope — return is the most
    common exit in functions.
    Example:
      func process(name: String?) -> String {
          guard let n = name, !n.isEmpty else {
              return "No name"
          }
          return "Hello, \(n)!"
      }
      print(process(name: "Alice"))
      // Output: Hello, Alice!
      print(process(name: nil))
      // Output: No name
      print(process(name: ""))
      // Output: No name


 Q38. What exits are valid inside a guard else clause?
 ------------------------------------------------------
 A: return, break, continue, throw, or a Never function.
    The guard must ensure execution cannot continue.
    Example:
      // return — most common in functions
      func f(_ x: Int?) -> Int {
          guard let x = x else { return -1 }
          return x
      }

      // throw — in throwing functions
      func g(_ x: Int?) throws -> Int {
          guard let x = x else { throw AppError.notFound }
          return x
      }

      // break — in loops
      for i in [1, nil, 3] as [Int?] {
          guard let n = i else { break }
          print(n)
      }
      // Output: 1


 // continue — in loops
 for i in [1, nil, 3] as [Int?] {
     guard let n = i else { continue }
     print(n)
 }
 // Output: 1
 //         3


Q39. Can a closure use return to exit a function?
--------------------------------------------------
A: No. return inside a closure exits the closure,
not the enclosing function.
Use a flag variable or restructure with a loop
if you need the function to exit early.
Example:
 func findFirst(in arr: [Int], matching condition: (Int) -> Bool) -> Int? {
     var result: Int? = nil
     arr.forEach { n in
         if condition(n) {
             result = n
             return    // exits closure ONLY, not findFirst
         }
     }
     return result
 }
 print(findFirst(in: [3, 7, 2, 9], matching: { $0 > 5 }) ?? -1)
 // Output: 7

 // Better approach — use a for loop with return:
 func findFirstFast(in arr: [Int],
                    matching condition: (Int) -> Bool) -> Int? {
     for n in arr {
         if condition(n) { return n }   // exits function
     }
     return nil
 }
 print(findFirstFast(in: [3, 7, 2, 9], matching: { $0 > 5 }) ?? -1)
 // Output: 7


Q40. How does throw interact with defer in a call stack?
---------------------------------------------------------
A: When a throw is issued, all pending defer blocks
in the current scope execute first (LIFO order),
then the error propagates up to the caller.
Each frame in the call stack runs its defers
before passing the error upward.
Example:
 func level3() throws {
     defer { print("defer level3") }
     throw AppError.notFound
 }
 func level2() throws {
     defer { print("defer level2") }
     try level3()
 }
 func level1() {
     defer { print("defer level1") }
     do {
         try level2()
     } catch {
         print("Caught at level1: \(error)")
     }
 }
 level1()
 // Output: defer level3
 //         defer level2
 //         defer level1
 //         Caught at level1: notFound


Q41. Can fallthrough be chained multiple times?
------------------------------------------------
A: Yes. Each fallthrough falls into the very next case.
You can chain them one after another.
Example:
 let level = 1
 switch level {
 case 1:
     print("Bronze reward")
     fallthrough
 case 2:
     print("Silver reward")
     fallthrough
 case 3:
     print("Gold reward")
 case 4:
     print("Diamond reward")
 default:
     break
 }
 // Output: Bronze reward
 //         Silver reward
 //         Gold reward


Q42. What is the difference between throw and fatalError?
----------------------------------------------------------
A: throw — recoverable error, caller can catch and handle
fatalError — unrecoverable, immediately crashes app,
            returns Never, no catching possible

Use throw for expected failure conditions.
Use fatalError for programmer errors / impossible states.
Example:
 // throw — recoverable:
 func loadConfig() throws -> String {
     throw ConfigError.missingKey("host")
 }
 let config = try? loadConfig()
 print(config ?? "Using defaults")
 // Output: Using defaults

 // fatalError — unrecoverable:
 // fatalError("Config file missing — cannot continue")
 // CRASH immediately — cannot be caught


Q43. How does continue behave in a nested loop
 with a label versus without?
----------------------------------------------
A: Without label — continue applies to innermost loop only
With label — continue skips to next iteration of
            the named outer loop
Example:
 // Without label:
 for i in 1...3 {
     for j in 1...3 {
         if j == 2 { continue }
         print("no-label i=\(i) j=\(j)")
     }
 }
 // Output: no-label i=1 j=1
 //         no-label i=1 j=3
 //         no-label i=2 j=1
 //         no-label i=2 j=3
 //         no-label i=3 j=1
 //         no-label i=3 j=3

 // With label:
 outer: for i in 1...3 {
     for j in 1...3 {
         if j == 2 { continue outer }
         print("labeled i=\(i) j=\(j)")
     }
 }
 // Output: labeled i=1 j=1
 //         labeled i=2 j=1
 //         labeled i=3 j=1


Q44. Can throw be used outside a throws function?
--------------------------------------------------
A: No. throw can only be used inside a function,
method, or closure marked as throws.
Using throw outside a throws context is a
compile-time error.
Example:
 // Error:
 // throw AppError.notFound    // Cannot throw outside throwing function

 // Correct:
 func f() throws {
     throw AppError.notFound   // OK inside throws function
 }
 do { try f() } catch { print(error) }
 // Output: notFound


Q45. What is a typed throw in Swift 6?
---------------------------------------
A: Swift 6 introduces typed throws — you can specify
the exact error type a function throws.
Declared as throws(ErrorType).
Example:
 enum MathError: Error {
     case overflow
     case divisionByZero
 }

 // Typed throw — only MathError can be thrown
 func divide(_ a: Int, _ b: Int) throws(MathError) -> Int {
     guard b != 0 else { throw MathError.divisionByZero }
     return a / b
 }

 // Caller knows exactly what error type to expect
 do {
     let result = try divide(10, 0)
     print(result)
 } catch MathError.divisionByZero {
     print("Division by zero")
 } catch MathError.overflow {
     print("Overflow")
 }
 // Output: Division by zero
 // Note: No need for a generic catch — all cases covered


Q46. How do you use break to exit a switch that is
 inside a loop, without exiting the loop?
--------------------------------------------------
A: An unlabeled break in a switch exits only the switch.
The loop continues to its next iteration.
Example:
 for i in 1...5 {
     switch i {
     case 3:
         print("Skipping 3")
         break          // exits switch only — loop continues
     default:
         print(i)
     }
 }
 // Output: 1
 //         2
 //         Skipping 3
 //         4
 //         5


Q47. How do you exit the LOOP from inside a switch
 that is nested in a loop?
--------------------------------------------------
A: Use a labeled break targeting the loop.
Example:
 loop: for i in 1...5 {
     switch i {
     case 3:
         print("Breaking loop at 3")
         break loop     // exits the for loop
     default:
         print(i)
     }
 }
 print("After loop")
 // Output: 1
 //         2
 //         Breaking loop at 3
 //         After loop


Q48. What is the execution order of multiple defers?
-----------------------------------------------------
A: LIFO — Last In First Out. The last defer declared
runs first. Like a stack.
Example:
 func ordered() {
     defer { print("First defer — runs last") }
     defer { print("Second defer — runs middle") }
     defer { print("Third defer — runs first") }
     print("Function body")
 }
 ordered()
 // Output: Function body
 //         Third defer — runs first
 //         Second defer — runs middle
 //         First defer — runs last


Q49. Can you throw inside a defer block?
-----------------------------------------
A: No. throw is not allowed inside a defer block.
defer is meant for cleanup only.
Example:
 func badDefer() throws {
     defer {
         // throw AppError.notFound   // Error: not allowed
         print("Cleanup")
     }
     throw AppError.notFound
 }
 do { try badDefer() } catch { print(error) }
 // Output: Cleanup
 //         notFound


Q50. How do continue, break, and return each
 interact with defer?
--------------------------------------------------
A: All three trigger pending defer blocks before exiting.
Example:
 // continue + defer in loop:
 for i in 1...3 {
     defer { print("defer \(i)") }
     if i == 2 { continue }
     print("body \(i)")
 }
 // Output: body 1
 //         defer 1
 //         defer 2      ← defer runs even on continue
 //         body 3
 //         defer 3

 // return + defer in function:
 func earlyReturn() -> String {
     defer { print("cleanup") }
     return "done"
 }
 print(earlyReturn())
 // Output: cleanup
 //         done

 // break + defer in loop:
 for i in 1...3 {
     defer { print("defer \(i)") }
     if i == 2 { break }
     print("body \(i)")
 }
 // Output: body 1
 //         defer 1
 //         defer 2      ← defer runs even on break


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q51. How does Swift's error handling model compare
 to exception handling in other languages?
-------------------------------------------------
A: Swift throws:
- Checked at compile time (must use try)
- Errors are values (enums conforming to Error)
- Explicit propagation — every throwing call is marked
- No performance overhead from stack unwinding
- Exhaustive catching is encouraged

Java/C++ exceptions:
- Unchecked (except Java checked exceptions)
- Can propagate silently without try
- Stack unwinding — performance cost
- Catching all exceptions is common and sometimes lazy

Example showing explicit propagation in Swift:
 func a() throws { try b() }  // must acknowledge throw
 func b() throws { try c() }
 func c() throws { throw AppError.notFound }

 do { try a() }
 catch { print("Caught: \(error)") }
 // Output: Caught: notFound
 // Every function in the chain explicitly declares throws


Q52. How do you implement retry logic using throw?
---------------------------------------------------
A: Use a loop, catch the error, retry up to a limit.
Example:
 enum RetryError: Error {
     case maxAttemptsReached
     case temporaryFailure(attempt: Int)
 }

 var attempt = 0
 func unreliableTask() throws -> String {
     attempt += 1
     if attempt < 3 {
         throw RetryError.temporaryFailure(attempt: attempt)
     }
     return "Success on attempt \(attempt)"
 }

 func withRetry(maxAttempts: Int,
                task: () throws -> String) throws -> String {
     var lastError: Error?
     for i in 1...maxAttempts {
         do {
             return try task()
         } catch {
             lastError = error
             print("Attempt \(i) failed: \(error)")
         }
     }
     throw RetryError.maxAttemptsReached
 }

 do {
     let result = try withRetry(maxAttempts: 5,
                                 task: unreliableTask)
     print(result)
 } catch RetryError.maxAttemptsReached {
     print("All attempts exhausted")
 } catch {
     print("Error: \(error)")
 }
 // Output: Attempt 1 failed: temporaryFailure(attempt: 1)
 //         Attempt 2 failed: temporaryFailure(attempt: 2)
 //         Success on attempt 3


Q53. How can you convert a completion-handler based
 function into one that throws?
---------------------------------------------
A: Use a wrapper that uses continuation or
a synchronous approach with Result.
Example:
 // Old completion-handler style:
 func fetchData(completion: (Result<String, Error>) -> Void) {
     completion(.success("Server data"))
 }

 // Wrapper that throws:
 func fetchDataThrowing() throws -> String {
     var result: Result<String, Error>?
     fetchData { result = $0 }
     switch result! {
     case .success(let data): return data
     case .failure(let error): throw error
     }
 }

 do {
     print(try fetchDataThrowing())
 } catch {
     print("Error: \(error)")
 }
 // Output: Server data

 // Modern async/await approach (preferred):
 func fetchDataAsync() async throws -> String {
     return try await withCheckedThrowingContinuation { cont in
         fetchData { result in
             cont.resume(with: result)
         }
     }
 }


Q54. How do labeled statements interact with
 Swift concurrency (async/await)?
----------------------------------------------
A: Labels work the same way in async contexts.
continue and break target loops, even in async code.
Example:
 func processItems() async {
     let items = [1, 2, 3, 4, 5]
     outer: for item in items {
         for multiplier in 1...3 {
             let result = item * multiplier
             if result > 8 {
                 print("Stopping at \(item) x \(multiplier) = \(result)")
                 break outer
             }
             print("\(item) x \(multiplier) = \(result)")
         }
     }
 }
 // When called:
 // Output: 1 x 1 = 1
 //         1 x 2 = 2
 //         1 x 3 = 3
 //         2 x 1 = 2
 //         2 x 2 = 4
 //         2 x 3 = 6
 //         3 x 1 = 3
 //         3 x 2 = 6
 //         3 x 3 = 9
 //         Stopping at 3 x 3 = 9


Q55. How does return behave differently in
 a computed property vs a function?
-----------------------------------------------
A: Both use return the same way.
Swift 5.1+ supports implicit return in both.
Example:
 struct Rectangle {
     var width: Double
     var height: Double

     // Explicit return:
     var area: Double {
         return width * height
     }

     // Implicit return (Swift 5.1+):
     var perimeter: Double {
         2 * (width + height)
     }

     // Explicit return in function:
     func scale(by factor: Double) -> Rectangle {
         return Rectangle(width: width * factor,
                           height: height * factor)
     }

     // Implicit return in function:
     func isSquare() -> Bool {
         width == height
     }
 }
 let r = Rectangle(width: 4, height: 5)
 print(r.area)
 // Output: 20.0
 print(r.perimeter)
 // Output: 18.0
 print(r.isSquare())
 // Output: false

 let scaled = r.scale(by: 2)
 print(scaled.area)
 // Output: 80.0


Q56. How does throw work with async throws functions?
------------------------------------------------------
A: Mark the function async throws. Call with try await.
Example:
 enum FetchError: Error {
     case badID
     case serverDown
 }

 func fetchProfile(id: Int) async throws -> String {
     guard id > 0 else {
         throw FetchError.badID
     }
     guard id != 999 else {
         throw FetchError.serverDown
     }
     return "Profile for user \(id)"
 }

 Task {
     do {
         let profile = try await fetchProfile(id: 42)
         print(profile)
     } catch FetchError.badID {
         print("Invalid user ID")
     } catch FetchError.serverDown {
         print("Server unavailable")
     } catch {
         print("Unknown: \(error)")
     }
 }
 // Output: Profile for user 42

 Task {
     do {
         let profile = try await fetchProfile(id: -1)
         print(profile)
     } catch FetchError.badID {
         print("Invalid user ID")
     } catch {
         print("Error: \(error)")
     }
 }
 // Output: Invalid user ID


Q57. What is the difference between throw and
 assertionFailure / preconditionFailure?
----------------------------------------------
A: throw       — recoverable, caught by do-catch,
             propagates up the call stack
assertionFailure — only crashes in DEBUG builds,
                  stripped in RELEASE builds
preconditionFailure — crashes in BOTH debug and
                     release builds, returns Never

Use throw for business logic errors.
Use preconditionFailure for truly impossible states.
Use assertionFailure for debug-only invariant checks.
Example:
 func processAge(_ age: Int) throws {
     guard age >= 0 else {
         throw AppError.invalidInput     // recoverable
     }
     print("Age: \(age)")
 }

 func assertPositive(_ n: Int) {
     assert(n > 0, "Must be positive")  // debug only
     print(n)
 }

 func requirePositiveAlways(_ n: Int) -> Int {
     precondition(n > 0, "Must be positive") // always
     return n
 }


Q58. Can you use return to exit a do-catch block?
--------------------------------------------------
A: return exits the enclosing function, not just
the do-catch block.
Example:
 func safeLoad(id: Int) -> String {
     do {
         guard id > 0 else {
             throw AppError.invalidInput
         }
         return "Item \(id)"    // exits function on success
     } catch AppError.invalidInput {
         return "Invalid ID"    // exits function on error
     } catch {
         return "Unknown error"
     }
 }
 print(safeLoad(id: 5))
 // Output: Item 5
 print(safeLoad(id: -1))
 // Output: Invalid ID


Q59. How do you use throw with Result to provide
 rich error context?
----------------------------------------------
A: Convert between throwing functions and Result
using Result's initializer.
Example:
 func riskyOperation(input: Int) throws -> String {
     guard input > 0 else {
         throw AppError.invalidInput
     }
     return "Processed: \(input)"
 }

 // Wrap throwing call in Result:
 let result = Result { try riskyOperation(input: 5) }
 switch result {
 case .success(let val): print(val)
 case .failure(let err): print("Error: \(err)")
 }
 // Output: Processed: 5

 let result2 = Result { try riskyOperation(input: -1) }
 switch result2 {
 case .success(let val): print(val)
 case .failure(let err): print("Error: \(err)")
 }
 // Output: Error: invalidInput

 // Convert Result back to throwing:
 func fromResult() throws -> String {
     return try result.get()
 }
 do {
     print(try fromResult())
 } catch {
     print("Error: \(error)")
 }
 // Output: Processed: 5


Q60. How does fallthrough relate to Swift's
 design philosophy?
-------------------------------------------------
A: Swift's design philosophy is safety and explicitness.
Accidental fallthrough in C-style languages is a
common source of bugs. Swift requires explicit
fallthrough to prevent accidental code execution.
The comma-separated pattern (case 1, 2:) covers most
real-world use cases without needing fallthrough.

Example showing the safer Swift approach:
 let x = 2
 // C-style (risky — easy to forget break):
 // switch(x) {
 //   case 1:
 //   case 2: printf("one or two"); break;
 //   case 3: printf("three"); break;
 // }

 // Swift style (safe — explicit, no accidents):
 switch x {
 case 1, 2:
     print("One or two")
 case 3:
     print("Three")
 default:
     print("Other")
 }
 // Output: One or two

 // fallthrough only when intentionally cascading:
 switch x {
 case 2:
     print("Exactly two")
     fallthrough
 case 1, 2, 3:
     print("Also in 1-3 range")
 default:
     break
 }
 // Output: Exactly two
 //         Also in 1-3 range


================================================================
PART 10 — PRACTICAL REAL-WORLD EXAMPLES
================================================================

EXAMPLE 1 — PROCESSING A PIPELINE WITH ALL FIVE
=================================================
enum PipelineError: Error {
  case emptyInput
  case parseFailure(String)
  case outOfRange(Int)
}

func runPipeline(inputs: [String]) throws -> [Int] {
  var results: [Int] = []

  for (index, input) in inputs.enumerated() {

      // continue — skip empty strings
      if input.trimmingCharacters(in: .whitespaces).isEmpty {
          print("Skipping empty input at index \(index)")
          continue
      }

      // throw — signal parse failure
      guard let number = Int(input) else {
          throw PipelineError.parseFailure(input)
      }

      // continue — skip negatives with a note
      if number < 0 {
          print("Skipping negative: \(number)")
          continue
      }

      // break — stop if we exceed limit
      if results.count >= 5 {
          print("Limit reached — stopping")
          break
      }

      results.append(number)
  }

  // return — return collected results
  return results
}

do {
  let output = try runPipeline(
      inputs: ["10", "", "20", "-5", "30",
               "40", "50", "60", "70"]
  )
  print("Results: \(output)")
} catch PipelineError.emptyInput {
  print("No input provided")
} catch PipelineError.parseFailure(let s) {
  print("Parse failed: \(s)")
} catch PipelineError.outOfRange(let n) {
  print("Out of range: \(n)")
}
// Output: Skipping empty input at index 1
//         Skipping negative: -5
//         Limit reached — stopping
//         Results: [10, 20, 30, 40, 50]


EXAMPLE 2 — STATE MACHINE USING THROW AND RETURN
==================================================
enum OrderError: Error {
  case invalidTransition(from: String, to: String)
}

enum OrderStatus {
  case draft, confirmed, shipped, delivered, cancelled

  mutating func transition(to next: OrderStatus) throws {
      let valid: [(OrderStatus, OrderStatus)] = [
          (.draft, .confirmed),
          (.draft, .cancelled),
          (.confirmed, .shipped),
          (.confirmed, .cancelled),
          (.shipped, .delivered)
      ]
      guard valid.contains(where: {
          $0.0 == self && $0.1 == next
      }) else {
          throw OrderError.invalidTransition(
              from: "\(self)", to: "\(next)"
          )
      }
      self = next
  }
}

var status = OrderStatus.draft
do {
  try status.transition(to: .confirmed)
  print("Status: \(status)")
  try status.transition(to: .shipped)
  print("Status: \(status)")
  try status.transition(to: .draft)      // invalid
} catch OrderError.invalidTransition(let from, let to) {
  print("Cannot transition from \(from) to \(to)")
}
// Output: Status: confirmed
//         Status: shipped
//         Cannot transition from shipped to draft


EXAMPLE 3 — SEARCH WITH LABELED BREAK
=======================================
let matrix = [
  [1,  2,  3,  4],
  [5,  6,  7,  8],
  [9,  10, 11, 12],
  [13, 14, 15, 16]
]
let target = 11
var foundAt: (row: Int, col: Int)? = nil

search: for (row, rowArray) in matrix.enumerated() {
  for (col, value) in rowArray.enumerated() {
      if value == target {
          foundAt = (row, col)
          break search
      }
  }
}

if let pos = foundAt {
  print("Found \(target) at row \(pos.row), col \(pos.col)")
} else {
  print("\(target) not found")
}
// Output: Found 11 at row 2, col 2


EXAMPLE 4 — DEFERRED RESOURCE CLEANUP
=======================================
class DatabaseConnection {
  let name: String
  init(_ name: String) {
      self.name = name
      print("Opened connection: \(name)")
  }
  func close() {
      print("Closed connection: \(name)")
  }
  func query(_ sql: String) throws -> String {
      guard sql.hasPrefix("SELECT") else {
          throw DBError.queryFailed("Only SELECT allowed")
      }
      return "Results for: \(sql)"
  }
}

func runQuery(sql: String) throws -> String {
  let db = DatabaseConnection("MainDB")
  defer { db.close() }                   // always runs

  let result = try db.query(sql)         // may throw
  return result                          // may return
}

do {
  let r = try runQuery(sql: "SELECT * FROM users")
  print(r)
} catch {
  print("Query error: \(error)")
}
// Output: Opened connection: MainDB
//         Closed connection: MainDB
//         Results for: SELECT * FROM users

do {
  let r = try runQuery(sql: "DROP TABLE users")
  print(r)
} catch {
  print("Query error: \(error)")
}
// Output: Opened connection: MainDB
//         Closed connection: MainDB
//         Query error: queryFailed("Only SELECT allowed")


EXAMPLE 5 — COMBINING CONTINUE, BREAK,
       RETURN AND THROW IN A REPORT
========================================
enum ReportError: Error {
  case noData
  case tooManyErrors(count: Int)
}

func generateReport(from data: [String?]) throws -> String {
  guard !data.isEmpty else {
      throw ReportError.noData
  }

  var lines: [String] = []
  var errorCount = 0

  for (index, item) in data.enumerated() {

      // continue — skip nil entries
      guard let value = item else {
          print("Skipping nil at index \(index)")
          continue
      }

      // continue — skip empty strings
      guard !value.isEmpty else {
          print("Skipping empty at index \(index)")
          continue
      }

      // throw — too many bad entries
      if value == "ERROR" {
          errorCount += 1
          if errorCount > 2 {
              throw ReportError.tooManyErrors(count: errorCount)
          }
          continue
      }

      // break — stop after collecting 5 valid lines
      if lines.count == 5 {
          print("Report limit reached")
          break
      }

      lines.append("Line \(lines.count + 1): \(value)")
  }

  // return — final assembled report
  return lines.joined(separator: "\n")
}

let data: [String?] = [
  "Alpha", nil, "Beta", "", "ERROR",
  "Gamma", "Delta", "ERROR", "Epsilon",
  "Zeta", "Eta"
]

do {
  let report = try generateReport(from: data)
  print(report)
} catch ReportError.noData {
  print("No data provided")
} catch ReportError.tooManyErrors(let count) {
  print("Too many errors: \(count)")
} catch {
  print("Error: \(error)")
}
// Output: Skipping nil at index 1
//         Skipping empty at index 3
//         Skipping empty at index 3
//         Report limit reached
//         Line 1: Alpha
//         Line 2: Beta
//         Line 3: Gamma
//         Line 4: Delta
//         Line 5: Epsilon


================================================================
COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

CONTINUE
Task                               | Code
-----------------------------------|-------------------------------------
Skip current iteration             | continue
Skip in while                      | while cond { if x { continue } }
Skip in repeat-while               | repeat { if x { continue } } while cond
Skip outer loop iteration          | continue outerLabel
Skip in forEach (use return)       | arr.forEach { if x { return } }

BREAK
Task                               | Code
-----------------------------------|-------------------------------------
Exit loop                          | break
Exit switch                        | break
Exit outer loop                    | break outerLabel
Exit switch inside loop            | break (exits switch only)
Exit loop from inside switch       | break loopLabel

FALLTHROUGH
Task                               | Code
-----------------------------------|-------------------------------------
Continue to next case              | fallthrough
Chain multiple cases               | case 1: ... fallthrough; case 2: ...
Prefer over fallthrough            | case 1, 2: ... (comma pattern)
Does NOT re-check next condition   | blindly executes next case body

RETURN
Task                               | Code
-----------------------------------|-------------------------------------
Return value                       | return value
Return nothing (Void)              | return
Implicit return (single expr)      | func f() -> T { expression }
Early exit guard                   | guard cond else { return }
Return optional                    | return nil / return value
Return tuple                       | return (a, b)
Return closure                     | return { ... }
Return Never                       | func f() -> Never { fatalError() }
Suppress unused warning            | @discardableResult

THROW
Task                               | Code
-----------------------------------|-------------------------------------
Define error                       | enum E: Error { case bad }
Mark function as throwing          | func f() throws -> T { }
Throw an error                     | throw MyError.case
Call throwing function             | try f()
Safe call — returns Optional       | try? f()
Unsafe call — crashes on error     | try! f()
Handle error                       | do { try f() } catch { }
Catch specific case                | catch MyError.case { }
Catch with condition               | catch MyError.case where x > 0 { }
Catch multiple                     | catch E.a, E.b { }
Catch all                          | catch { print(error) }
Rethrowing function                | func f(closure: () throws -> T) rethrows -> T
Throwing initializer               | init() throws { }
Propagate error upward             | func f() throws { try g() }
Convert throw to Optional          | let r = try? f()
Convert throw to Result            | let r = Result { try f() }
Result get() throws                | try result.get()
Async throwing function            | func f() async throws -> T { }
Typed throw (Swift 6)              | func f() throws(MyError) -> T { }

DEFER
Task                               | Code
-----------------------------------|-------------------------------------
Cleanup on scope exit              | defer { cleanup() }
Always runs — even on throw        | defer runs before error propagates
Always runs — even on return       | defer runs before function exits
Always runs — even on break        | defer runs before loop exit
Multiple defers — LIFO order       | last declared runs first
Cannot throw inside defer          | throw not allowed in defer body

LABELED STATEMENTS
Task                               | Code
-----------------------------------|-------------------------------------
Label a loop                       | myLoop: for x in collection { }
Break outer loop                   | break myLoop
Continue outer loop                | continue myLoop
Label a switch                     | mySwitch: switch value { }
Break labeled switch               | break mySwitch

 */
