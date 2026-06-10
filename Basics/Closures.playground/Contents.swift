import UIKit

/*
 =======================================================================
   SWIFT — CLOSURES
   Async Escaping Blocks, Object Lifetimes, Captures & Memory
   Complete Study Notes + 100 Interview Q&A
 =======================================================================

 TABLE OF CONTENTS
 -----------------
 PART 1: CLOSURE FUNDAMENTALS
   A. What is a Closure?
   B. Closure Syntax — Full Spectrum
   C. Closure Types and Type Signatures
   D. Closures as First-Class Citizens
   E. Named Functions vs Closures vs Nested Functions
   F. Trailing Closure Syntax
   G. Multiple Trailing Closures (Swift 5.3+)

 PART 2: CAPTURE SEMANTICS
   A. What Does "Capture" Mean?
   B. Capturing Value Types vs Reference Types
   C. Capturing Variables by Reference (Default)
   D. Capturing by Value — Capture Lists
   E. Mutation Inside Closures
   F. Capturing self
   G. Capturing in Nested Closures

 PART 3: @escaping CLOSURES
   A. What is @escaping?
   B. Non-Escaping (Default) — Lifetime Guarantees
   C. Why @escaping Changes Everything
   D. How @escaping Holds Objects Beyond Function Lifetimes
   E. @escaping in Async Contexts (GCD, URLSession, Timers)
   F. @escaping in Stored Properties
   G. @escaping and ARC — Full Interaction
   H. withoutActuallyEscaping

 PART 4: ASYNCHRONOUS CLOSURES & OBJECT LIFETIMES
   A. The Core Problem — Async Escape
   B. GCD (DispatchQueue) Patterns
   C. URLSession Completion Handlers
   D. Timer and RunLoop Closures
   E. NotificationCenter Closures
   F. OperationQueue Closures
   G. Animation Closures
   H. Lifetime Timeline Diagrams

 PART 5: CAPTURE LISTS IN DEPTH
   A. Capture List Syntax
   B. [weak self] — Full Mechanics
   C. [unowned self] — Full Mechanics
   D. Capturing Other Objects Weakly
   E. Value Capture in Capture Lists
   F. guard let self Pattern (Swift 5.3+)
   G. Capture Lists in Async/Await

 PART 6: @autoclosure
   A. What is @autoclosure?
   B. Syntax and Use Cases
   C. @autoclosure + @escaping
   D. ARC and @autoclosure

 PART 7: CLOSURES IN SWIFT CONCURRENCY
   A. Closures vs async Functions
   B. Task Closures and Lifetimes
   C. @Sendable Closures
   D. Actor-Isolated Closures
   E. Structured vs Unstructured Concurrency

 PART 8: PERFORMANCE & OPTIMIZATION
   A. Heap Allocation of Closures
   B. Context Object (Closure Box)
   C. Inline vs Out-of-Line Closures
   D. Stack Promotion of Closure Contexts
   E. @inline(__always) and Closure Inlining
   F. Avoiding Unnecessary Captures

 PART 9: COMMON PATTERNS & PITFALLS
   A. Completion Handler Pyramid of Doom
   B. Closure-Based Delegation
   C. Builder Pattern with Closures
   D. Result Type with Closures
   E. Common Mistakes & Fixes

 PART 10: 100 INTERVIEW Q&A
   - Basic        (Q1–Q25)
   - Intermediate (Q26–Q65)
   - Hard/Advanced (Q66–Q100)

 =======================================================================
 PART 1: CLOSURE FUNDAMENTALS
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS A CLOSURE?
 -----------------------------------------------------------------------
 A closure is a SELF-CONTAINED block of functionality that can
 be passed around and used in your code. It "closes over" variables
 and constants from the surrounding context — capturing and storing
 references to those values.

 THREE FORMS of closures in Swift:
   1. Global functions    — named, do NOT capture values
   2. Nested functions    — named, CAN capture values from enclosing function
   3. Closure expressions — unnamed, lightweight, CAN capture values

 KEY PROPERTIES:
   - First-class citizens: can be stored in variables, passed as arguments,
     returned from functions
   - Reference types: closures are heap-allocated objects
   - Capture context: automatically retain values they use
     from the surrounding scope
   - Type-safe: fully typed function signatures

 FORMAL DEFINITION:
   A closure is a function + its captured environment (closed-over variables).
   This combination is called a "closure" because it "closes over"
   the free variables in the function body.

 -----------------------------------------------------------------------
 B. CLOSURE SYNTAX — FULL SPECTRUM
 -----------------------------------------------------------------------

 FULL SYNTAX:
   { (parameters) -> ReturnType in
       statements
   }

 PROGRESSION from verbose to concise:

   // 1. Full syntax
   let add: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
       return a + b
   }

   // 2. Type inferred from context
   let add: (Int, Int) -> Int = { a, b in
       return a + b
   }

   // 3. Implicit return (single expression)
   let add: (Int, Int) -> Int = { a, b in a + b }

   // 4. Shorthand argument names
   let add: (Int, Int) -> Int = { $0 + $1 }

   // 5. Operator function (ultimate shorthand)
   let numbers = [3, 1, 4, 1, 5]
   let sorted = numbers.sorted(by: <)    // < is (Int,Int)->Bool

 VOID CLOSURES:
   let greet: () -> Void = { print("Hello") }
   let greet: () -> Void = { print("Hello") }
   greet()

 THROWING CLOSURES:
   let riskyOp: (Int) throws -> Int = { n in
       guard n > 0 else { throw MyError.negative }
       return n * 2
   }

 ASYNC CLOSURES (Swift 5.5+):
   let asyncOp: () async -> String = {
       await fetchData()
   }

 ASYNC + THROWING:
   let asyncRisky: () async throws -> Data = {
       try await URLSession.shared.data(from: url).0
   }

 -----------------------------------------------------------------------
 C. CLOSURE TYPES AND TYPE SIGNATURES
 -----------------------------------------------------------------------
 A closure's TYPE is its complete function signature:
   (ParameterTypes) -> ReturnType

 EXAMPLES:
   () -> Void                    // takes nothing, returns nothing
   (Int) -> Int                  // takes Int, returns Int
   (Int, Int) -> Bool            // takes two Ints, returns Bool
   (String) -> Void              // takes String, returns nothing
   ([Int]) -> [String]           // takes array, returns array
   (Result<Data, Error>) -> Void // takes Result, returns nothing
   () -> () -> Int               // returns a closure that returns Int

 TYPE ALIASES for readability:
   typealias CompletionHandler = (Result<Data, Error>) -> Void
   typealias Transform<T, U>   = (T) -> U
   typealias Predicate<T>      = (T) -> Bool
   typealias VoidClosure       = () -> Void

 OPTIONAL CLOSURES:
   var onTap: (() -> Void)?      // nil by default, call with onTap?()
   var handler: ((Int) -> Bool)? // optional closure with parameters

 ESCAPING OPTIONAL CLOSURES:
   // Optional closures are implicitly @escaping
   var completion: ((Result<Data, Error>) -> Void)?
   // This is already escaping — no @escaping annotation needed
   // because Optional<T> is a generic type, not a direct param

 -----------------------------------------------------------------------
 D. CLOSURES AS FIRST-CLASS CITIZENS
 -----------------------------------------------------------------------

 STORED IN VARIABLES:
   var operation: (Int, Int) -> Int = { $0 + $1 }
   operation = { $0 * $1 }   // reassign
   let result = operation(3, 4)   // 12

 PASSED AS ARGUMENTS:
   func apply(_ value: Int, transform: (Int) -> Int) -> Int {
       return transform(value)
   }
   let doubled = apply(5) { $0 * 2 }   // 10

 RETURNED FROM FUNCTIONS:
   func makeMultiplier(by factor: Int) -> (Int) -> Int {
       return { $0 * factor }   // captures 'factor' from enclosing scope
   }
   let triple = makeMultiplier(by: 3)
   print(triple(4))   // 12
   // 'factor' (value 3) is captured and kept alive by the returned closure

 STORED IN COLLECTIONS:
   var operations: [(Int) -> Int] = []
   operations.append { $0 + 1 }
   operations.append { $0 * 2 }
   operations.append { $0 - 3 }
   let result = operations.reduce(5) { $1($0) }  // (5+1)*2-3 = 9

 -----------------------------------------------------------------------
 E. NAMED FUNCTIONS vs CLOSURES vs NESTED FUNCTIONS
 -----------------------------------------------------------------------

 GLOBAL FUNCTION:
   func double(_ x: Int) -> Int { x * 2 }
   // Named, globally scoped, does NOT capture anything
   // Can be passed as a closure: [1,2,3].map(double)

 NESTED FUNCTION:
   func outer() -> Int {
       var count = 0
       func inner() {    // named, but local
           count += 1    // CAPTURES count from outer
       }
       inner()
       inner()
       return count      // 2
   }
   // inner() captures 'count' by reference

 CLOSURE EXPRESSION:
   func outer2() -> () -> Int {
       var count = 0
       let increment = {   // unnamed closure
           count += 1      // CAPTURES count by reference
           return count
       }
       return increment    // captures 'count' — escapes outer2!
   }
   let counter = outer2()
   print(counter())    // 1
   print(counter())    // 2
   // 'count' persists because the closure holds a reference to it

 KEY DIFFERENCE:
   Named function: scope ends with function → no capture needed
   Closure/Nested: can capture and extend lifetime of local variables

 -----------------------------------------------------------------------
 F. TRAILING CLOSURE SYNTAX
 -----------------------------------------------------------------------
 When a closure is the LAST argument to a function, it can be
 written OUTSIDE the parentheses:

   // Normal syntax:
   UIView.animate(withDuration: 0.3, animations: {
       self.view.alpha = 0
   })

   // Trailing closure syntax:
   UIView.animate(withDuration: 0.3) {
       self.view.alpha = 0
   }

   // If closure is the ONLY argument:
   let doubled = [1, 2, 3].map({ $0 * 2 })
   let doubled = [1, 2, 3].map { $0 * 2 }    // trailing

   // Chained trailing closures:
   [1, 2, 3, 4, 5]
       .filter { $0 > 2 }
       .map { $0 * 10 }
       .forEach { print($0) }

 -----------------------------------------------------------------------
 G. MULTIPLE TRAILING CLOSURES (Swift 5.3+)
 -----------------------------------------------------------------------
 Multiple closure arguments can use trailing syntax:

   // Function signature:
   func loadData(
       url: URL,
       onSuccess: @escaping (Data) -> Void,
       onFailure: @escaping (Error) -> Void
   ) { ... }

   // Old syntax — all in parentheses:
   loadData(url: url, onSuccess: { data in
       process(data)
   }, onFailure: { error in
       handle(error)
   })

   // Swift 5.3+ multiple trailing closure syntax:
   loadData(url: url) { data in
       process(data)
   } onFailure: { error in
       handle(error)
   }
   // First trailing closure: no label
   // Subsequent: keep their argument labels

   // UIKit example:
   UIView.animate(withDuration: 0.3) {
       self.view.alpha = 0        // animations: closure
   } completion: { finished in
       self.view.removeFromSuperview()  // completion: closure
   }

 =======================================================================
 PART 2: CAPTURE SEMANTICS
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT DOES "CAPTURE" MEAN?
 -----------------------------------------------------------------------
 When a closure references a variable or constant from its surrounding
 scope, it CAPTURES that variable — creating a reference to it so
 the closure can use it even after the original scope has exited.

 WITHOUT CAPTURE:
   func makeAdder(x: Int) -> Int {
       return x + 10   // x used directly, no capture needed
   }

 WITH CAPTURE:
   func makeAdder(x: Int) -> (Int) -> Int {
       return { y in x + y }   // x CAPTURED from makeAdder's scope
   }
   let addFive = makeAdder(x: 5)
   // makeAdder has returned, x is "gone" from stack
   // BUT the closure captured x — it lives on the HEAP
   print(addFive(3))   // 8 — x=5 still accessible via closure

 THE CLOSURE CONTEXT (Heap Box):
   When a closure captures variables, Swift allocates a HEAP object
   called the "closure context" or "closure box" that contains:
   - All captured variables/references
   - The function pointer
   This box is reference-counted like any class instance.

 -----------------------------------------------------------------------
 B. CAPTURING VALUE TYPES vs REFERENCE TYPES
 -----------------------------------------------------------------------

 CAPTURING A VALUE TYPE (e.g., Int, struct):
   The closure captures the VARIABLE BINDING (a reference to where
   the variable is stored), NOT a copy of the value.
   Changes to the variable INSIDE the closure affect the variable.
   Changes to the variable OUTSIDE the closure are seen by the closure.

   var counter = 0
   let increment = { counter += 1 }

   increment()   // counter = 1
   increment()   // counter = 2
   counter = 10  // counter = 10
   increment()   // counter = 11
   print(counter) // 11 — all modifications see the same storage

 CAPTURING A REFERENCE TYPE (class):
   The closure captures the REFERENCE (pointer) to the object.
   Both the closure and external code share the SAME object.

   class Box { var value = 0 }
   let box = Box()
   let increment = { box.value += 1 }

   increment()         // box.value = 1
   box.value = 100     // box.value = 100
   increment()         // box.value = 101
   print(box.value)    // 101

   // IMPORTANT: 'box' (the reference) is captured strongly
   // Box instance's ARC count incremented by the closure

 -----------------------------------------------------------------------
 C. CAPTURING VARIABLES BY REFERENCE (DEFAULT)
 -----------------------------------------------------------------------
 Swift closures capture variables by REFERENCE by default.
 The closure holds a reference to the HEAP-ALLOCATED storage
 of the captured variable (called a "box" in Swift internals).

 HOW VARIABLE BOXING WORKS:
   When a local variable is captured by a closure, Swift
   "promotes" the variable from the stack to the heap:

   func makeCounter() -> () -> Int {
       var count = 0          // normally stack-allocated
       // But since captured by closure → HEAP-promoted (boxed)
       return {
           count += 1         // modifies the heap-allocated count
           return count
       }
   }

   let c1 = makeCounter()
   let c2 = makeCounter()    // INDEPENDENT counter — own heap box

   print(c1())  // 1
   print(c1())  // 2
   print(c2())  // 1  ← independent box
   print(c1())  // 3

 SHARED CAPTURE (two closures capturing same variable):
   func makeSharedCounters() -> (() -> Int, () -> Int) {
       var count = 0
       let increment = { count += 1; return count }
       let decrement = { count -= 1; return count }
       return (increment, decrement)
   }

   let (inc, dec) = makeSharedCounters()
   inc()   // count = 1
   inc()   // count = 2
   dec()   // count = 1
   // Both closures share the SAME heap box for count

 -----------------------------------------------------------------------
 D. CAPTURING BY VALUE — CAPTURE LISTS
 -----------------------------------------------------------------------
 Use a capture list to capture a COPY of a value at closure creation:

   var x = 10
   let closure = { [x] in    // captures CURRENT VALUE of x (10)
       print(x)
   }
   x = 99
   closure()   // Prints 10 — captured the value at creation time

 WITHOUT capture list:
   var x = 10
   let closure = { print(x) }   // captures variable BINDING
   x = 99
   closure()   // Prints 99 — sees current value of x

 CAPTURE LIST WITH CLASSES (creates another strong reference):
   var obj = MyClass()
   let closure = { [obj] in    // captures a COPY of the reference
       print(obj.name)          // still same object, new strong reference
   }
   obj = MyClass()   // 'obj' now points to new object
   closure()         // Still uses ORIGINAL obj (captured at creation)

 USE CASE — Snapshot for async work:
   func sendNotification(for user: User) {
       let userSnapshot = user   // or use capture list
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           [userSnapshot] in     // guaranteed to use THIS user's data
           display(userSnapshot.name)
       }
   }

 -----------------------------------------------------------------------
 E. MUTATION INSIDE CLOSURES
 -----------------------------------------------------------------------

 MUTATING CAPTURED VALUE TYPES:
   // The variable must be var, not let
   var total = 0
   let accumulate: (Int) -> Void = { total += $0 }
   accumulate(5)    // total = 5
   accumulate(3)    // total = 8

   // Captured let — cannot mutate:
   let fixed = 0
   let wrongClosure = { fixed += 1 }   // ERROR: cannot assign to 'fixed'

 MUTATING IN @escaping vs NON-ESCAPING:
   // Non-escaping: variable can be captured by mutable reference
   func withValue(_ action: (inout Int) -> Void) {
       var x = 0
       action(&x)
       print(x)
   }

   // Escaping: captured variable promoted to heap
   func accumulator() -> (Int) -> Int {
       var sum = 0
       return { n in   // @escaping — sum promoted to heap
           sum += n
           return sum
       }
   }

 -----------------------------------------------------------------------
 F. CAPTURING self
 -----------------------------------------------------------------------
 When a closure references any member of self (method, property),
 it captures SELF — the entire object.

 IMPLICIT self CAPTURE:
   class MyClass {
       var value = 0

       func doWork() {
           DispatchQueue.main.async {
               self.value += 1    // captures self strongly
           }
       }
   }

 EXPLICIT self CAPTURE (Swift 5.3+ requirement for @escaping):
   class MyClass {
       var value = 0

       func doWork() {
           DispatchQueue.main.async { [self] in
               value += 1    // [self] makes capture explicit
                             // reads as: "I know I'm capturing self"
           }
       }
   }

   // Or with weak:
   DispatchQueue.main.async { [weak self] in
       self?.value += 1
   }

 SHORTHAND SELF ACCESS (Swift 5.3+):
   After guard let self = self, you can use self directly:
   DispatchQueue.main.async { [weak self] in
       guard let self else { return }
       value += 1      // no 'self.' needed inside the guard scope
       doWork()        // same instance methods directly accessible
   }

 -----------------------------------------------------------------------
 G. CAPTURING IN NESTED CLOSURES
 -----------------------------------------------------------------------
 When closures are nested, inner closures capture variables from
 ALL enclosing scopes:

   func outerFunc() {
       var outerVar = "outer"

       let outerClosure = {
           var innerVar = "inner"

           let innerClosure = {
               // Captures BOTH outerVar and innerVar
               print(outerVar, innerVar)
           }

           innerVar = "modified inner"
           innerClosure()   // "outer modified inner"
       }

       outerVar = "modified outer"
       outerClosure()   // captures outerVar by reference
   }

 ARC IMPLICATION:
   If the innerClosure escapes, it holds:
   - Reference to innerVar's heap box
   - Reference to outerVar's heap box (transitively keeps
     outerClosure's captured environment alive)
   Each layer of nesting can extend object lifetimes further.

 =======================================================================
 PART 3: @escaping CLOSURES
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS @escaping?
 -----------------------------------------------------------------------
 A closure is said to "escape" a function when it is called AFTER
 the function returns. @escaping marks a closure parameter to
 indicate it will outlive the function call.

   func doLater(_ work: @escaping () -> Void) {
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           work()    // called AFTER doLater returns → ESCAPING
       }
   }

 NON-ESCAPING (default, no annotation):
   func doNow(_ work: () -> Void) {
       work()    // called BEFORE doNow returns → NON-ESCAPING
   }

 WHY THE ANNOTATION MATTERS:
   1. Memory: @escaping closures need to be heap-allocated
      (to survive beyond the stack frame)
   2. self capture: @escaping requires explicit self capture
      (compiler enforces this as a warning/error)
   3. ARC: @escaping closures retain all captured references
      for as long as the closure lives
   4. Optimization: non-escaping closures can be stack-allocated
      and don't need retain/release on captured values

 -----------------------------------------------------------------------
 B. NON-ESCAPING (DEFAULT) — LIFETIME GUARANTEES
 -----------------------------------------------------------------------
 Non-escaping closures (default, no @escaping):
   - Guaranteed to be called during the function's execution
   - OR NOT called at all (function may not invoke them)
   - NEVER called after the function returns
   - Can be stack-allocated (no heap allocation needed)
   - No retain/release on captured values needed

 GUARANTEES the compiler uses:
   func process(items: [Int], transform: (Int) -> Int) -> [Int] {
       return items.map(transform)
       // transform is called inside process, before process returns
       // After process returns: transform is GONE (stack deallocated)
   }

   // These are SAFE because of non-escaping guarantee:
   var result: Int
   process(items: [1,2,3]) { item in
       result = item   // capturing 'result' is safe — closure is non-escaping
       return item * 2
   }

 COMPILER BENEFIT — No self requirement:
   class MyClass {
       var values = [1, 2, 3]

       func transform() -> [Int] {
           return values.map { $0 * 2 }
           // No [self] needed — non-escaping closure
           // Compiler knows it won't outlive transform()
       }
   }

 -----------------------------------------------------------------------
 C. WHY @escaping CHANGES EVERYTHING
 -----------------------------------------------------------------------
 When @escaping is added, the closure can outlive the function.
 This has cascading implications:

 1. HEAP ALLOCATION REQUIRED:
    The closure context must live on the heap (not stack),
    because the stack frame is gone after function returns.

 2. ARC RETENTION:
    All captured references are retained for the closure's
    ENTIRE LIFETIME (potentially indefinitely if cycle exists).

 3. SELF CAPTURE BECOMES EXPLICIT:
    Swift requires you to write 'self.' or use capture list
    for @escaping closures referencing instance members.
    This forces developers to THINK about ownership.

 4. LIFETIME EXTENSION:
    Objects captured by @escaping closures live UNTIL the
    closure itself is deallocated — which may be much later
    than expected.

 5. CYCLE RISK:
    If self holds the closure AND the closure captures self
    → retain cycle → permanent leak.

 -----------------------------------------------------------------------
 D. HOW @escaping HOLDS OBJECTS BEYOND FUNCTION LIFETIMES
 -----------------------------------------------------------------------
 This is the CORE TOPIC. Let's trace exactly what happens:

 SCENARIO 1 — Temporary extension (no cycle):
   class DataLoader {
       var data: [String] = []

       func loadFromNetwork() {
           // fetchData is @escaping — survives loadFromNetwork return
           fetchData { [weak self] result in
               guard let self else { return }
               self.data = result          // self used here
           }
           // loadFromNetwork RETURNS HERE
           // The closure is now in a queue somewhere
           // It holds a STRONG reference to self (if no [weak self])
           // Or a WEAK reference (if [weak self])
       }
   }

   var loader: DataLoader? = DataLoader()
   loader?.loadFromNetwork()
   loader = nil    // Without [weak self]: loader stays alive until
                   // network request completes!
                   // With [weak self]: loader freed immediately

 SCENARIO 2 — Permanent extension (cycle):
   class ViewController {
       var onUpdate: (() -> Void)?    // stored closure property

       func setup() {
           onUpdate = {               // @escaping (optional = escaping)
               self.tableView.reloadData()  // strong self!
           }
           // VC → onUpdate (strong)
           // onUpdate → self (strong)
           // = PERMANENT CYCLE
           // VC.deinit NEVER called
       }
   }

 LIFETIME EXTENSION DIAGRAM:

   Time ──────────────────────────────────────────────────────►

   [function called]──[function returns]────────────────────────
                      ↑                                       ↑
   Non-escaping: closure alive during function only
   @escaping:    closure alive ─────────────────────────────► (until released)
                               ↑ closure keeps captured objects alive too!

   With [weak self]:  self can die anytime after function returns
   Without [weak self]: self lives at least as long as the closure

 -----------------------------------------------------------------------
 E. @escaping IN ASYNC CONTEXTS (GCD, URLSession, Timers)
 -----------------------------------------------------------------------

 GCD — DISPATCH QUEUE:
   class ImageProcessor {
       var processedImages: [UIImage] = []

       func processInBackground(image: UIImage) {
           // DispatchQueue.global().async takes @escaping closure
           DispatchQueue.global(qos: .userInitiated).async { [weak self] in
               let processed = self?.heavyProcess(image)
               DispatchQueue.main.async { [weak self] in
                   guard let self, let img = processed else { return }
                   self.processedImages.append(img)
                   // Two nested @escaping closures
                   // Each must use [weak self]
               }
           }
       }
       deinit { print("ImageProcessor freed") }
   }

 URLSESSION:
   class APIClient {
       func fetchUser(id: String,
                      completion: @escaping (Result<User, Error>) -> Void) {
           // URLSession.dataTask takes @escaping completion
           URLSession.shared.dataTask(with: makeURL(id)) { data, response, error in
               // This runs on URLSession's background thread
               // AFTER fetchUser has returned
               if let error = error {
                   completion(.failure(error))
                   return
               }
               guard let data = data else {
                   completion(.failure(APIError.noData))
                   return
               }
               do {
                   let user = try JSONDecoder().decode(User.self, from: data)
                   DispatchQueue.main.async {
                       completion(.success(user))
                   }
               } catch {
                   completion(.failure(error))
               }
           }.resume()
           // fetchUser returns HERE — before network completes
       }
   }

 URLSESSION + SELF:
   class ProfileViewModel {
       var user: User?

       func load() {
           URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
               guard let self, let data = data else { return }
               self.user = try? JSONDecoder().decode(User.self, from: data)
               // [weak self] critical: ViewModel may be released
               // before network returns
           }.resume()
       }
       deinit { print("ProfileViewModel freed") }
   }

 TIMER:
   class PollManager {
       var timer: Timer?
       var count = 0

       func startPolling() {
           // Timer.scheduledTimer closure is @escaping
           // Timer retained by RunLoop → closure retained by Timer
           timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                        repeats: true) { [weak self] _ in
               self?.poll()
           }
       }

       func poll() {
           count += 1
           print("Poll #\(count)")
       }

       func stop() {
           timer?.invalidate()
           timer = nil
       }

       deinit {
           timer?.invalidate()
           print("PollManager freed")
       }
   }

 -----------------------------------------------------------------------
 F. @escaping IN STORED PROPERTIES
 -----------------------------------------------------------------------
 Optional closure properties are IMPLICITLY @escaping.
 Any closure stored as a property can be called at any time.

   class Button {
       var onTap: (() -> Void)?        // implicitly @escaping
       var onLongPress: (() -> Void)?  // implicitly @escaping

       func tap() { onTap?() }
   }

   class ViewController {
       let button = Button()

       func setup() {
           button.onTap = {
               self.handleTap()    // CYCLE: VC→button→onTap→VC
           }

           // FIX:
           button.onTap = { [weak self] in
               self?.handleTap()
           }
       }
   }

 PATTERN — Closure-based delegation (replacing protocols):
   class NetworkService {
       var onSuccess: ((Data) -> Void)?
       var onFailure: ((Error) -> Void)?
       var onProgress: ((Double) -> Void)?

       func fetch(url: URL) {
           // All three stored closures are escaping
           // Must use [weak self] when assigning from VC
       }
   }

 -----------------------------------------------------------------------
 G. @escaping AND ARC — FULL INTERACTION
 -----------------------------------------------------------------------

 WHAT HAPPENS AT THE CALL SITE:
   func enqueue(_ work: @escaping () -> Void) {
       queue.append(work)    // closure stored → strong reference
   }

   enqueue {
       print(self.name)      // self retained by closure
   }
   // After enqueue returns:
   // - Closure is in 'queue' array (strongly)
   // - Closure strongly holds 'self'
   // - self.RC incremented by closure
   // - self lives until queue releases this closure

 REFERENCE COUNT TIMELINE:
   object created:           RC = 1
   captured by @escaping:    RC = 2
   function returns:         RC = 2 (closure still holds it)
   closure executed:         RC = 2
   closure released:         RC = 1
   original ref released:    RC = 0 → deinit

 -----------------------------------------------------------------------
 H. withoutActuallyEscaping
 -----------------------------------------------------------------------
 A special function that temporarily treats a non-escaping
 closure as escaping inside a controlled scope.

   func hasPositiveElement<C: Collection>(
       in collection: C,
       matching predicate: (C.Element) -> Bool
   ) -> Bool {
       withoutActuallyEscaping(predicate) { escapingPredicate in
           // Can now pass escapingPredicate to APIs requiring @escaping
           return collection.lazy.filter(escapingPredicate).first != nil
       }
   }

 USE CASE: When you know a closure won't actually escape but
 an API requires @escaping (e.g., lazy collections).
 WARNING: If the closure DOES escape the withoutActuallyEscaping
 scope, it's undefined behavior — Swift traps in debug mode.

 =======================================================================
 PART 4: ASYNCHRONOUS CLOSURES & OBJECT LIFETIMES
 =======================================================================

 -----------------------------------------------------------------------
 A. THE CORE PROBLEM — ASYNC ESCAPE
 -----------------------------------------------------------------------
 The fundamental issue: an @escaping closure captures objects
 that may have a DIFFERENT expected lifetime than the closure.

 THE THREE CATEGORIES:

 1. TEMPORARY EXTENSION (acceptable, fixable):
    Object expected to die → closure keeps it alive longer
    FIX: [weak self] — let the object die naturally

 2. UNINTENDED PERMANENT EXTENSION (bug):
    Object can NEVER die because closure and object hold each other
    FIX: [weak self] in closures stored on self

 3. INTENDED EXTENSION (correct):
    Closure should keep the object alive for its duration
    (e.g., a fire-and-forget background task)
    NO FIX NEEDED: this is the purpose of strong capture

 IDENTIFYING WHICH CATEGORY:
   Ask: "Should this object be allowed to die before this closure fires?"
   YES → [weak self]
   NO  → strong capture (intentional)
   SOMETIMES → [weak self] (handle nil case)

 -----------------------------------------------------------------------
 B. GCD (DISPATCHQUEUE) PATTERNS
 -----------------------------------------------------------------------

 PATTERN 1 — Simple background + main:
   class ViewModel {
       var items: [Item] = []

       func refresh() {
           DispatchQueue.global(qos: .background).async { [weak self] in
               let newItems = self?.fetchItems() ?? []
               DispatchQueue.main.async { [weak self] in
                   self?.items = newItems
                   self?.notifyObservers()
               }
           }
       }
   }

 PATTERN 2 — asyncAfter (delay):
   class Animator {
       func animateAfterDelay() {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               [weak self] in
               self?.startAnimation()
               // [weak self] needed: view may have been dismissed
               // in the 0.5 second window
           }
       }
   }

 PATTERN 3 — DispatchGroup:
   class BatchLoader {
       let group = DispatchGroup()
       var results: [Data] = []

       func loadAll(urls: [URL]) {
           for url in urls {
               group.enter()
               URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                   defer { self?.group.leave() }
                   if let data = data {
                       self?.results.append(data)
                   }
               }.resume()
           }

           group.notify(queue: .main) { [weak self] in
               self?.processResults()
           }
       }
   }

 PATTERN 4 — DispatchSemaphore (careful — can block):
   // Avoid with weak self — if self is nil, semaphore may never signal
   // Prefer structured concurrency (async/await) instead

 -----------------------------------------------------------------------
 C. URLSESSION COMPLETION HANDLERS
 -----------------------------------------------------------------------

 THE COMPLETE PATTERN:
   class UserService {
       private var activeTask: URLSessionDataTask?

       func fetchUser(
           id: String,
           completion: @escaping (Result<User, Error>) -> Void
       ) {
           // Cancel any existing request
           activeTask?.cancel()

           var request = URLRequest(url: makeURL(id: id))
           request.httpMethod = "GET"

           activeTask = URLSession.shared.dataTask(with: request) {
               // This closure is @escaping — called on background thread
               // after fetchUser has long since returned
               data, response, error in

               // Check for cancellation
               if let error = error as? URLError,
                  error.code == .cancelled { return }

               // Always call completion on main thread
               DispatchQueue.main.async {
                   if let error = error {
                       completion(.failure(error))
                       return
                   }
                   guard let data = data,
                         let httpResponse = response as? HTTPURLResponse,
                         (200...299).contains(httpResponse.statusCode)
                   else {
                       completion(.failure(APIError.badResponse))
                       return
                   }
                   do {
                       let user = try JSONDecoder().decode(User.self, from: data)
                       completion(.success(user))
                   } catch {
                       completion(.failure(error))
                   }
               }
           }
           activeTask?.resume()
       }

       func cancel() {
           activeTask?.cancel()
           activeTask = nil
       }
   }

 CALLER PATTERN WITH [weak self]:
   class ProfileViewController: UIViewController {
       let service = UserService()

       override func viewDidLoad() {
           super.viewDidLoad()
           loadProfile()
       }

       func loadProfile() {
           service.fetchUser(id: "123") { [weak self] result in
               guard let self else { return }
               switch result {
               case .success(let user):
                   self.updateUI(with: user)
               case .failure(let error):
                   self.showError(error)
               }
           }
       }

       deinit {
           service.cancel()   // cancel if VC is dismissed mid-request
           print("ProfileVC freed")
       }
   }

 -----------------------------------------------------------------------
 D. TIMER AND RUNLOOP CLOSURES
 -----------------------------------------------------------------------

 TIMER OWNERSHIP CHAIN:
   RunLoop  ──strong──►  Timer  ──strong──►  Closure  ──strong──►  self
   self     ──strong──►  Timer (if stored as property)

   RESULT: If self stores the Timer AND Timer's closure captures self
   → multiple cycles → self NEVER deallocated

 CORRECT TIMER PATTERN:
   class CountdownController {
       private var timer: Timer?
       private var remaining: Int = 10

       func start() {
           timer = Timer.scheduledTimer(
               withTimeInterval: 1.0,
               repeats: true
           ) { [weak self] _ in
               guard let self else { return }
               self.remaining -= 1
               self.updateDisplay()
               if self.remaining <= 0 {
                   self.stop()
               }
           }
       }

       func stop() {
           timer?.invalidate()
           timer = nil
       }

       deinit {
           stop()   // safety net: ensure timer invalidated
           print("CountdownController freed")
       }
   }

 CADisplayLink (similar pattern):
   class AnimationController {
       private var displayLink: CADisplayLink?

       func startAnimation() {
           displayLink = CADisplayLink(target: self,
                                       selector: #selector(step))
           // WARNING: CADisplayLink target is STRONGLY held by the link
           // And the link is held by the RunLoop
           // → self retained as long as displayLink runs
           // MUST invalidate in stop() or deinit
           displayLink?.add(to: .main, forMode: .default)
       }

       @objc func step() { /* animate */ }

       func stopAnimation() {
           displayLink?.invalidate()
           displayLink = nil
       }

       deinit {
           stopAnimation()
       }
   }

 -----------------------------------------------------------------------
 E. NOTIFICATIONCENTER CLOSURES
 -----------------------------------------------------------------------

 BLOCK-BASED OBSERVER (returns opaque observer object):
   class MyViewController: UIViewController {
       private var observers: [NSObjectProtocol] = []

       override func viewDidLoad() {
           super.viewDidLoad()

           // addObserver(forName:) returns an observer token
           // The closure is @escaping (stored by NotificationCenter)
           let observer = NotificationCenter.default.addObserver(
               forName: UIApplication.didEnterBackgroundNotification,
               object: nil,
               queue: .main
           ) { [weak self] notification in
               self?.saveState()
           }
           observers.append(observer)
       }

       deinit {
           // MUST remove observers to break the cycle:
           // NC → observer token → closure → self (if strong)
           observers.forEach {
               NotificationCenter.default.removeObserver($0)
           }
           print("VC freed")
       }
   }

 SELECTOR-BASED OBSERVER (simpler, no closure cycle risk):
   override func viewDidLoad() {
       super.viewDidLoad()
       NotificationCenter.default.addObserver(
           self,                                        // no closure
           selector: #selector(handleBackground),
           name: UIApplication.didEnterBackgroundNotification,
           object: nil
       )
   }

   @objc func handleBackground() { saveState() }

   deinit {
       NotificationCenter.default.removeObserver(self)
   }

 -----------------------------------------------------------------------
 F. OPERATIONQUEUE CLOSURES
 -----------------------------------------------------------------------

   class DataPipeline {
       let queue = OperationQueue()

       func process(data: Data) {
           queue.addOperation { [weak self] in
               // Block-based operation — @escaping internally
               guard let self else { return }
               let processed = self.transform(data)
               OperationQueue.main.addOperation { [weak self] in
                   self?.display(processed)
               }
           }
       }

       func cancel() {
           queue.cancelAllOperations()
       }

       deinit {
           cancel()
           print("DataPipeline freed")
       }
   }

 -----------------------------------------------------------------------
 G. ANIMATION CLOSURES
 -----------------------------------------------------------------------

 UIView.animate — non-escaping animations, @escaping completion:
   class CardView: UIView {
       func flip(completion: @escaping (Bool) -> Void) {
           UIView.animate(
               withDuration: 0.3,
               animations: {
                   // NON-ESCAPING: called synchronously within animate
                   // No [weak self] needed here
                   self.transform = CGAffineTransform(scaleX: -1, y: 1)
               },
               completion: { [weak self] finished in
                   // ESCAPING: called after animation completes
                   // [weak self] needed
                   self?.isFlipped.toggle()
                   completion(finished)
               }
           )
       }
   }

 SPRING ANIMATION:
   UIView.animate(
       withDuration: 0.5,
       delay: 0,
       usingSpringWithDamping: 0.7,
       initialSpringVelocity: 0.5,
       options: []
   ) {
       // animations: non-escaping — no [weak self] needed
       self.view.transform = .identity
   } completion: { [weak self] _ in
       // completion: escaping — [weak self] recommended
       self?.onAnimationComplete()
   }

 -----------------------------------------------------------------------
 H. LIFETIME TIMELINE DIAGRAMS
 -----------------------------------------------------------------------

 CASE 1: Strong capture, no cycle (one-shot async):
   ┌─────────────────────────────────────────────────────────┐
   │ Time ────────────────────────────────────────────────►  │
   │                                                         │
   │ self  [====================================] nil        │
   │              ↑ RC=1                       ↑ external nil'd
   │ closure      [captured: RC=2]──────────── done → RC=1  │
   │                              ↑ fires here              │
   │ function ──► returns                                   │
   │                                                         │
   │ Result: self freed AFTER closure fires → correct       │
   └─────────────────────────────────────────────────────────┘

 CASE 2: Weak capture (recommended):
   ┌─────────────────────────────────────────────────────────┐
   │ self  [================] nil ← freed at natural time   │
   │              RC=1           ↑ external nil → RC=0      │
   │ closure      [weak self]─── fires → self == nil → skip │
   │                              ↑ weak load returns nil   │
   │ Result: self freed naturally, closure handles nil      │
   └─────────────────────────────────────────────────────────┘

 CASE 3: Retain cycle (bug):
   ┌─────────────────────────────────────────────────────────┐
   │ self  [===================================== NEVER FREE]│
   │ closure [=============================================] │
   │ self → closure → self → closure ... ↺ CYCLE            │
   │ external nil → RC: self=1 (held by closure)            │
   │                     closure=1 (held by self)           │
   │ Result: PERMANENT LEAK                                 │
   └─────────────────────────────────────────────────────────┘

 =======================================================================
 PART 5: CAPTURE LISTS IN DEPTH
 =======================================================================

 -----------------------------------------------------------------------
 A. CAPTURE LIST SYNTAX
 -----------------------------------------------------------------------

 POSITION: Before parameters, after opening brace:
   { [captureItems] (params) -> ReturnType in
       body
   }

   // With parameters:
   let closure = { [weak self] (x: Int, y: Int) -> Int in
       self?.transform(x + y) ?? 0
   }

   // Without explicit params (using $0, $1):
   let closure = { [weak self] in
       self?.handleValue($0)
   }

   // In trailing closure:
   button.onTap = { [weak self] in
       self?.handleTap()
   }

 CAPTURE LIST ITEMS:
   [weak object]          → capture object weakly (Optional)
   [unowned object]       → capture object unowned (non-Optional)
   [object]               → capture object as additional strong ref
   [self]                 → capture self explicitly (strong, Swift 5.3+)
   [value = expression]   → evaluate expression now, capture result
   [weak self = expr]     → evaluate expr, capture result weakly
   [x = x]                → force-copy value type at closure creation

 MULTIPLE CAPTURES:
   let closure = { [weak self, weak delegate, unowned manager, count = self.count] in
       // self: weak Optional
       // delegate: weak Optional
       // manager: unowned non-Optional
       // count: snapshot of self.count at closure creation
   }

 -----------------------------------------------------------------------
 B. [weak self] — FULL MECHANICS
 -----------------------------------------------------------------------
 [weak self] in a capture list:
   1. Captures self as a WEAK OPTIONAL (Self?)
   2. Does NOT increment self's ARC count
   3. If self is deallocated: the captured weak self becomes nil
   4. Accessing self inside closure requires Optional unwrapping

 SAFE USAGE PATTERNS:
   // Pattern 1: Optional chaining (simple, for simple calls)
   { [weak self] in
       self?.updateUI()
       self?.tableView.reloadData()
   }

   // Pattern 2: guard let (for multiple self uses)
   { [weak self] in
       guard let self else { return }
       updateUI()          // no 'self.' needed (Swift 5.3+)
       tableView.reloadData()
       title = "Done"
   }

   // Pattern 3: guard let with fallback
   { [weak self] in
       guard let self else {
           defaultHandler()   // handle nil case
           return
       }
       self.processResult()
   }

   // Pattern 4: map on Optional
   { [weak self] value in
       self.map { strongSelf in
           strongSelf.process(value)
       }
   }

 WHEN TO USE:
   ✓ Delegate closures stored on delegate (not owner)
   ✓ Completion handlers where VC may be dismissed
   ✓ Timer closures when timer stored on self
   ✓ Any stored closure on self that references self
   ✓ Long-running async operations where self may die

 -----------------------------------------------------------------------
 C. [unowned self] — FULL MECHANICS
 -----------------------------------------------------------------------
 [unowned self] in a capture list:
   1. Captures self as UNOWNED (non-Optional, non-retained)
   2. Does NOT increment self's ARC count
   3. If self is deallocated: accessing it causes a CRASH
   4. No Optional unwrapping needed

 SAFE USAGE — Only when self GUARANTEED alive:
   class ViewController {
       lazy var handler: () -> Void = { [unowned self] in
           // 'handler' is stored on self
           // self ALWAYS outlives handler (handler lives inside self)
           // When self is freed, handler is freed first
           // → self is never nil when this closure runs
           self.handleAction()
       }
   }

 ANOTHER SAFE CASE:
   class ResourceOwner {
       func startWork() {
           // This closure is stored in a local var, not on self
           // But we call it synchronously within startWork's scope
           // self guaranteed alive here
           let work: () -> Void = { [unowned self] in
               self.doWork()
           }
           work()
       }
   }

 RISKY USAGE (should use weak instead):
   class ViewController {
       func loadData() {
           service.fetchData { [unowned self] result in
               // DANGEROUS: VC may be popped before network returns
               self.handle(result)   // CRASH if VC is gone
           }
       }
   }

 RULE: If in doubt between weak and unowned → use WEAK.
 The nil return is far better than a crash.

 -----------------------------------------------------------------------
 D. CAPTURING OTHER OBJECTS WEAKLY
 -----------------------------------------------------------------------
 You can capture ANY object weakly, not just self:

   class ViewController {
       let viewModel: MyViewModel

       func setup() {
           viewModel.onUpdate = { [weak self, weak viewModel] data in
               guard let self, let viewModel else { return }
               self.update(with: viewModel.processData(data))
           }
       }
   }

   // Capturing a specific property's object:
   let delegate = self.delegate
   let closure = { [weak delegate] in
       delegate?.performAction()
   }

   // Renaming captures for clarity:
   let closure = { [weak vc = viewController, weak service = networkService] in
       vc?.reload()
       service?.cancel()
   }

 -----------------------------------------------------------------------
 E. VALUE CAPTURE IN CAPTURE LISTS
 -----------------------------------------------------------------------
 Capture a snapshot of a value at closure creation time:

   var index = 0
   let closures = (0..<5).map { i -> () -> Void in
       let captured = i   // each loop iteration: different value
       return { print(captured) }
   }
   closures.forEach { $0() }   // Prints: 0 1 2 3 4

   // WITHOUT value capture (common bug):
   var closures2: [() -> Void] = []
   for i in 0..<5 {
       closures2.append { print(i) }   // captures 'i' by reference
   }
   // In Swift, for-in loop creates NEW 'i' each iteration
   // So this actually works correctly in Swift (unlike C/JS)
   closures2.forEach { $0() }   // Prints: 0 1 2 3 4 (correct in Swift)

   // Explicit snapshot with capture list:
   var mutableValue = "start"
   let snapshot = { [mutableValue] in
       print(mutableValue)   // always prints "start"
   }
   mutableValue = "changed"
   snapshot()   // "start" — captured at creation

 -----------------------------------------------------------------------
 F. guard let self PATTERN (Swift 5.3+)
 -----------------------------------------------------------------------

 EVOLUTION:
   // Pre-Swift 5.3 (ugly):
   { [weak self] in
       guard let strongSelf = self else { return }
       strongSelf.doA()
       strongSelf.doB()
   }

   // Swift 4.2 (slightly better):
   { [weak self] in
       guard let self = self else { return }
       self.doA()
       self.doB()
   }

   // Swift 5.3+ (cleanest):
   { [weak self] in
       guard let self else { return }  // shadows outer 'self'
       doA()        // implicit self — no 'self.' needed
       doB()
   }

 ASYNC CONSIDERATION:
   { [weak self] in
       guard let self else { return }
       doA()                    // self strong here
       await someAsyncWork()    // suspension point!
       // After await: self may have been released
       // The local 'self' constant kept it alive DURING someAsyncWork
       // But on resume: need to re-check if still needed
       doB()                    // self still strong (same guard scope)
   }

   // For truly safe async usage:
   { [weak self] in
       guard let self else { return }
       doA()
       let result = await someAsyncWork()
       // At this point: 'self' constant from guard is still strong
       // because it's still in scope — so doB is always safe
       // UNLESS self should be allowed to die between suspensions
       doB()
   }

 -----------------------------------------------------------------------
 G. CAPTURE LISTS IN ASYNC/AWAIT
 -----------------------------------------------------------------------

 In Swift async functions and Task closures:
   class ViewModel {
       var data: [Item] = []

       func refresh() {
           Task { [weak self] in
               guard let self else { return }
               let items = await fetchItems()
               // After await: check if self still alive needed?
               // 'self' constant from guard IS still strong here
               // because guard let creates a strong local reference
               // that persists for the entire do block
               self.data = items
           }
       }
   }

 ACTOR-ISOLATED CLOSURES:
   @MainActor
   class MainViewModel: ObservableObject {
       @Published var items: [Item] = []

       func load() {
           Task {
               // Running on @MainActor context
               // self is implicitly captured strongly here
               // (MainActor isolates access — no race conditions)
               let fetched = await fetchData()
               items = fetched   // safe
 }
}
}

// Non-isolated Task needing weak:
class ViewController {
var viewModel = ViewModel()

func setup() {
 Task { [weak self] in
     // Not MainActor-isolated
     // VC may be popped before task completes
     let data = await viewModel.fetch()
     await MainActor.run { [weak self] in
         self?.update(with: data)
     }
 }
}
}

=======================================================================
PART 6: @autoclosure
=======================================================================

-----------------------------------------------------------------------
A. WHAT IS @autoclosure?
-----------------------------------------------------------------------
@autoclosure wraps an expression passed as an argument into a
closure AUTOMATICALLY at the call site. The expression is NOT
evaluated until the closure is called.

WITHOUT @autoclosure:
func logIfDebug(_ message: () -> String) {
if isDebug { print(message()) }
}
logIfDebug({ "Heavy computation: \(computeValue())" })
// Verbose call site — explicit closure braces

WITH @autoclosure:
func logIfDebug(_ message: @autoclosure () -> String) {
if isDebug { print(message()) }
}
logIfDebug("Heavy computation: \(computeValue())")
// Clean call site — expression auto-wrapped into closure
// computeValue() only runs if isDebug is true

KEY PROPERTY: LAZY EVALUATION
The expression is only evaluated when the closure is CALLED,
not when the function is called. This enables:
- Short-circuit evaluation
- Deferred / conditional computation
- Performance: skip expensive work when not needed

-----------------------------------------------------------------------
B. SYNTAX AND USE CASES
-----------------------------------------------------------------------

STANDARD LIBRARY EXAMPLES:
// assert — only evaluates in debug builds
func assert(_ condition: @autoclosure () -> Bool,
     _ message: @autoclosure () -> String = "") { }

// ?? operator
func ?? <T>(optional: T?,
     defaultValue: @autoclosure () -> T) -> T {
switch optional {
case .some(let value): return value
case .none: return defaultValue()  // only called if nil
}
}
// Usage: expensiveDefault() only called if result is nil
let value = result ?? expensiveDefault()

CUSTOM USE CASE — Lazy logging:
enum LogLevel { case debug, info, warning, error }
var currentLevel = LogLevel.warning

func log(_ level: LogLevel,
  _ message: @autoclosure () -> String) {
guard level >= currentLevel else { return }
print("[\(level)] \(message())")  // message() only if level passes
}

log(.debug, "Value: \(expensiveToString())")
// expensiveToString() NOT called if .debug < .warning

CUSTOM USE CASE — Assertion with context:
func require(_ condition: @autoclosure () -> Bool,
      _ message: @autoclosure () -> String,
      file: StaticString = #file,
      line: UInt = #line) {
if !condition() {
 fatalError(message(), file: file, line: line)
}
}
require(array.count > 0, "Array must not be empty")

-----------------------------------------------------------------------
C. @autoclosure + @escaping
-----------------------------------------------------------------------
By default, @autoclosure is NON-ESCAPING.
Combine with @escaping to store the auto-wrapped closure:

class LazyEvaluator {
var computations: [() -> String] = []

func enqueue(_ value: @autoclosure @escaping () -> String) {
 computations.append(value)   // stored → must be @escaping
}

func runAll() {
 computations.forEach { print($0()) }
}
}

let evaluator = LazyEvaluator()
evaluator.enqueue("Result: \(computeExpensiveValue())")
// computeExpensiveValue() NOT yet called — wrapped in closure
evaluator.runAll()   // called here

ARC IMPLICATION:
An @autoclosure @escaping wraps the expression AND retains
all values the expression references. This can create
unexpected strong captures:

class Form {
var validator = Validator()

func setup() {
 // CYCLE RISK:
 validator.condition = self.data.isEmpty
 // = validator.condition = { self.data.isEmpty }
 // Form → validator → condition closure → self (Form)
 // CYCLE!

 // FIX: Pass explicit closure with [weak self]:
 validator.condition = { [weak self] in
     self?.data.isEmpty ?? true
 }
}
}

-----------------------------------------------------------------------
D. ARC AND @autoclosure
-----------------------------------------------------------------------
Each @autoclosure parameter:
1. Creates a heap-allocated closure object (if escaping)
2. Retains all reference-type values in the expression
3. Released when the function call completes (if non-escaping)
OR when the stored closure is released (if @escaping)

PERFORMANCE NOTE:
In Debug builds, @autoclosure closures may not be optimized away.
In Release builds: inlined and stack-allocated when non-escaping.
For truly hot paths: manual if-guards may be faster than
@autoclosure due to closure overhead.

=======================================================================
PART 7: CLOSURES IN SWIFT CONCURRENCY
=======================================================================

-----------------------------------------------------------------------
A. CLOSURES vs async FUNCTIONS
-----------------------------------------------------------------------

CALLBACK CLOSURE STYLE (pre-async/await):
func fetchUser(id: String,
        completion: @escaping (Result<User, Error>) -> Void) {
URLSession.shared.dataTask(with: makeURL(id)) { data, _, error in
 // Nested @escaping closure
 // 'completion' is @escaping — kept alive until called
 // If never called → completion handler leaked
 if let error = error {
     completion(.failure(error))
     return
 }
 // ... parse and call completion(.success(user))
}.resume()
}
// Caller:
fetchUser(id: "1") { [weak self] result in
self?.handle(result)
}

ASYNC/AWAIT STYLE (modern):
func fetchUser(id: String) async throws -> User {
let (data, _) = try await URLSession.shared.data(from: makeURL(id))
return try JSONDecoder().decode(User.self, from: data)
}
// Caller:
Task { [weak self] in
guard let self else { return }
let user = try? await fetchUser(id: "1")
handle(user)
}

KEY DIFFERENCES:
Callbacks:     manual @escaping, manual [weak self], manual threading
async/await:   structured lifetime, compiler-managed, cleaner captures

WHEN CLOSURES STILL NEEDED IN ASYNC WORLD:
- Callback-based APIs (UIKit delegates, NotificationCenter)
- Protocol conformances requiring closure properties
- Combine publisher subscriptions
- Objective-C APIs
- Animation closures (UIView.animate)

-----------------------------------------------------------------------
B. TASK CLOSURES AND LIFETIMES
-----------------------------------------------------------------------

Task { } creates an unstructured task. The closure is @escaping.

TASK LIFETIME vs SELF LIFETIME:
class ViewController: UIViewController {
override func viewDidLoad() {
 super.viewDidLoad()

 // Task runs independently of VC's lifetime
 Task {
     await loadContent()   // if VC dismissed, still runs
 }

 // Safe version — VC can die without consequence:
 Task { [weak self] in
     let data = await fetchData()
     await MainActor.run { [weak self] in
         self?.display(data)
     }
 }
}
}

TASK STORAGE AND CANCELLATION:
class DataController {
private var loadTask: Task<Void, Never>?

func startLoading() {
 loadTask?.cancel()   // cancel previous
 loadTask = Task { [weak self] in
     guard let self else { return }
     let data = await fetchData()
     guard !Task.isCancelled else { return }
     await MainActor.run { [weak self] in
         self?.data = data
     }
 }
}

func cancelLoading() {
 loadTask?.cancel()
 loadTask = nil
}

deinit {
 cancelLoading()
 print("DataController freed")
}
}

Task vs Task.detached:
Task { }           // inherits actor context, task priority, locals
Task.detached { }  // no inheritance — fully independent
            // Must capture ALL needed values explicitly
            // Higher risk of capturing self strongly

Task.detached { [weak self] in   // always [weak self] for detached
await self?.process()
}

-----------------------------------------------------------------------
C. @Sendable CLOSURES
-----------------------------------------------------------------------
A @Sendable closure can be safely passed across concurrency boundaries
(actors, threads). Swift 5.5+ enforces Sendable checking.

RULES FOR @Sendable CLOSURES:
1. All captured values must be Sendable
2. Value types (Int, String, struct): Sendable by default
3. Classes: must be Sendable (immutable or internally synchronized)
4. Closures that capture non-Sendable types: compile error when
crossing concurrency boundaries

EXAMPLE:
actor DataStore {
var items: [Item] = []

func process(transform: @Sendable (Item) -> Item) {
 // @Sendable ensures 'transform' is safe to call from actor
 items = items.map(transform)
}
}

// This works — closure captures only value types:
store.process { item in
Item(value: item.value * 2)   // pure value transformation
}

// This fails — closure captures non-Sendable class:
let formatter = NSDateFormatter()   // non-Sendable
store.process { item in
Item(name: formatter.string(from: item.date))
// ERROR: formatter is not Sendable
}

// FIX: Capture value type snapshot:
let formatString = formatter.string(from: Date())   // String is Sendable
store.process { item in
Item(name: formatString)
}

-----------------------------------------------------------------------
D. ACTOR-ISOLATED CLOSURES
-----------------------------------------------------------------------

CLOSURES ON ACTORS:
actor Counter {
var count = 0

func increment() {
 // This closure runs on the actor's executor
 let work = { [unowned self] in
     self.count += 1   // safe — actor-isolated
 }
 work()
}
}

CROSSING ACTOR BOUNDARIES:
@MainActor
class UI {
func update() {
 // This closure is MainActor-isolated
 let closure: @MainActor () -> Void = {
     self.label.text = "Updated"   // safe — on MainActor
 }
 closure()
}
}

// Passing closures FROM actor TO background:
actor Processor {
func doWork(callback: @escaping @Sendable () -> Void) {
 Task.detached {
     await heavyWork()
     callback()   // callback must be @Sendable
 }
}
}

-----------------------------------------------------------------------
E. STRUCTURED vs UNSTRUCTURED CONCURRENCY
-----------------------------------------------------------------------

STRUCTURED (async let, TaskGroup) — lifetime tied to scope:
func loadAll() async throws -> [Item] {
async let first = fetchItem(id: "1")   // closure-free
async let second = fetchItem(id: "2")
// Both tasks run concurrently
// Both CANCELLED if loadAll throws or is cancelled
return try await [first, second]
}
// No @escaping, no capture lists, no retain cycles
// Lifetime is SCOPED — tasks die with the scope

UNSTRUCTURED (Task { }, Task.detached { }) — escape scope:
func startBackground() {
Task {   // escaping — outlives startBackground
 await doLongWork()
}
// startBackground returns, task keeps running
// [weak self] needed if self used inside
}

RECOMMENDATION:
Prefer structured concurrency (async let, TaskGroup) to eliminate
capture list complexity entirely. Use Task { } with [weak self]
only when structured approach isn't suitable.

=======================================================================
PART 8: PERFORMANCE & OPTIMIZATION
=======================================================================

-----------------------------------------------------------------------
A. HEAP ALLOCATION OF CLOSURES
-----------------------------------------------------------------------
Every closure that CAPTURES values from its surrounding scope
requires a HEAP ALLOCATION for the closure context object.
Non-capturing closures: no heap allocation (just a function pointer).

CAPTURING vs NON-CAPTURING:
// NON-CAPTURING — no heap allocation, just function pointer:
let double: (Int) -> Int = { $0 * 2 }
[1, 2, 3].map { $0 * 2 }   // no captures — no allocation

// CAPTURING — heap allocation for closure context:
let multiplier = 3
let multiply: (Int) -> Int = { $0 * multiplier }
// Heap box created: { multiplier: 3 }
// ARC manages the box

HEAP ALLOCATION COST:
- malloc/free: ~50-100ns
- ARC retain/release: ~1-3ns each
- For closures in tight loops: significant cumulative cost
- Optimization: compiler may stack-promote if closure doesn't escape

-----------------------------------------------------------------------
B. CONTEXT OBJECT (CLOSURE BOX)
-----------------------------------------------------------------------
The closure context ("closure box") is a heap object containing:

struct ClosureContext {
// Header:
var refCount: Int        // ARC reference count
var metadata: UnsafeRawPointer  // type metadata

// Captured variables (example):
var capturedSelf: MyClass   // strong reference
var capturedCount: Int      // copied value
var capturedWeak: Weak<OtherClass>  // weak side-table ref
}

MULTIPLE CLOSURES SHARING A BOX:
func makeCounters() -> (() -> Int, () -> Int) {
var count = 0
// BOTH closures share the SAME heap box for 'count'
return ({ count += 1; return count },
     { count -= 1; return count })
}
// Only ONE allocation for count — shared between closures

INDEPENDENT BOXES:
func makeIndependent() -> [() -> Int] {
return (0..<3).map { i in
 var count = i    // each closure gets its OWN box
 return { count += 1; return count }
}
}
// THREE separate heap allocations

-----------------------------------------------------------------------
C. INLINE vs OUT-OF-LINE CLOSURES
-----------------------------------------------------------------------

INLINE CLOSURES (compiled directly, no allocation):
[1, 2, 3].sorted { $0 < $1 }
// In optimized builds: compiler inlines the closure body
// directly into the call — zero overhead

OUT-OF-LINE CLOSURES (heap-allocated context):
let predicate: (Int) -> Bool = { $0 > self.threshold }
// 'self.threshold' captured → heap context created
array.filter(predicate)

COMPILER OPTIMIZATION — inline non-escaping:
func apply(_ x: Int, _ f: (Int) -> Int) -> Int { f(x) }
let result = apply(5) { $0 * 2 }
// In Release: entire closure inlined → same as writing 5 * 2
// Zero closure overhead

WHEN OPTIMIZATION FAILS:
// @escaping: cannot be inlined (unknown lifetime)
func store(_ f: @escaping () -> Void) { queue.append(f) }
// Dynamic dispatch (protocol existential): cannot inline
// Large closures: may not be worth inlining

-----------------------------------------------------------------------
D. STACK PROMOTION OF CLOSURE CONTEXTS
-----------------------------------------------------------------------
If the compiler proves a closure's context NEVER escapes the
current function, it can allocate the context on the STACK:

func processLocally(items: [Int]) -> [Int] {
let factor = 2
// factor captured but closure never escapes
return items.map { $0 * factor }
// Compiler: alloc_stack for closure context (not heap)
}

CONDITIONS FOR STACK PROMOTION:
1. Closure is non-escaping
2. Closure doesn't outlive the enclosing function
3. All captured values have known, bounded lifetimes
4. No retain/release needed on the stack context

RESULT: Zero allocation cost, zero ARC cost for such closures.
This is why non-escaping closures (map, filter, forEach) are
extremely fast in Swift.

-----------------------------------------------------------------------
E. @inline(__always) AND CLOSURE INLINING
-----------------------------------------------------------------------

@inline(__always)
func transform(_ x: Int, _ f: (Int) -> Int) -> Int {
f(x)
}
// Forces inlining of this function — closure may also be inlined
// through the call chain

@inline(never)
func debugTransform(_ x: Int, _ f: (Int) -> Int) -> Int {
print("Transforming \(x)")
return f(x)
}
// Prevents inlining — useful for debugging or code size reduction

FOR CLOSURE-HEAVY CODE:
- Use @inline(__always) on small wrapper functions
- Prefer non-escaping closures where possible
- Use value types in closures to avoid ARC on captures
- Profile with Instruments before optimizing

-----------------------------------------------------------------------
F. AVOIDING UNNECESSARY CAPTURES
-----------------------------------------------------------------------

CAPTURE ONLY WHAT YOU NEED:
// BAD — captures entire self:
DispatchQueue.global().async {
let result = self.heavyCompute()   // self retained for duration
DispatchQueue.main.async {
 self.label.text = result
}
}

// BETTER — capture only needed values:
let data = self.inputData        // copy value type
DispatchQueue.global().async {
let result = compute(data)    // data copied — no self needed
DispatchQueue.main.async { [weak self] in
 self?.label.text = result
}
}

AVOID CAPTURING LARGE OBJECTS:
// BAD — entire model captured:
let model = self.model
{ [model] in process(model) }

// BETTER — capture only the needed field:
let id = self.model.id
{ process(id) }   // only Int captured, not entire model

=======================================================================
PART 9: COMMON PATTERNS & PITFALLS
=======================================================================

-----------------------------------------------------------------------
A. COMPLETION HANDLER PYRAMID OF DOOM
-----------------------------------------------------------------------

THE PROBLEM — Nested @escaping closures:
func loadProfile() {
authService.login(user: user) { [weak self] token in
 guard let self else { return }
 self.userService.fetchProfile(token: token) { [weak self] profile in
     guard let self else { return }
     self.imageService.loadAvatar(url: profile.avatarURL) { [weak self] image in
         guard let self else { return }
         self.cacheService.save(image: image) { [weak self] success in
             guard let self else { return }
             self.updateUI(profile: profile, avatar: image)
         }
     }
 }
}
}

SOLUTION 1 — Async/await (best):
func loadProfile() async throws {
let token   = try await authService.login(user: user)
let profile = try await userService.fetchProfile(token: token)
let image   = try await imageService.loadAvatar(url: profile.avatarURL)
try await cacheService.save(image: image)
await MainActor.run { updateUI(profile: profile, avatar: image) }
}

SOLUTION 2 — Combine:
authService.loginPublisher(user: user)
.flatMap { token in self.userService.fetchProfilePublisher(token: token) }
.flatMap { profile in self.imageService.loadAvatarPublisher(url: profile.avatarURL) }
.receive(on: DispatchQueue.main)
.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
 self?.updateUI(profile: $0, avatar: $1)
})
.store(in: &cancellables)

SOLUTION 3 — Named functions to flatten:
func loadProfile() {
authService.login(user: user) { [weak self] token in
 self?.handleToken(token)
}
}
private func handleToken(_ token: String) {
userService.fetchProfile(token: token) { [weak self] profile in
 self?.handleProfile(profile)
}
}
private func handleProfile(_ profile: Profile) {
imageService.loadAvatar(url: profile.avatarURL) { [weak self] image in
 self?.updateUI(profile: profile, avatar: image)
}
}

-----------------------------------------------------------------------
B. CLOSURE-BASED DELEGATION
-----------------------------------------------------------------------
Modern alternative to the protocol-delegate pattern:

// Protocol-delegate (traditional):
protocol ButtonDelegate: AnyObject {
func didTap(_ button: Button)
func didLongPress(_ button: Button)
}
class Button {
weak var delegate: (any ButtonDelegate)?
}

// Closure-based (modern, more flexible):
class Button {
var onTap: (() -> Void)?
var onLongPress: (() -> Void)?
var onDoubleTap: (() -> Void)?

func tap() { onTap?() }
}

// Usage — no protocol conformance needed:
button.onTap = { [weak self] in
self?.handleTap()
}
button.onLongPress = { [weak self] in
self?.showContextMenu()
}

WHEN TO PREFER CLOSURES OVER PROTOCOLS:
✓ Few callbacks (1-3 events)
✓ Callbacks differ per instance (not per class)
✓ Ad-hoc composition at setup time
✗ Many methods → closures become unwieldy
✗ Multiple conformers needed for the same events
✗ When the protocol carries semantic meaning

-----------------------------------------------------------------------
C. BUILDER PATTERN WITH CLOSURES
-----------------------------------------------------------------------

class AlertBuilder {
private var title: String = ""
private var message: String = ""
private var actions: [(String, () -> Void)] = []

@discardableResult
func title(_ title: String) -> Self {
 self.title = title
 return self
}

@discardableResult
func message(_ message: String) -> Self {
 self.message = message
 return self
}

@discardableResult
func action(_ title: String,
         handler: @escaping () -> Void) -> Self {
 actions.append((title, handler))
 return self
}

func build() -> UIAlertController {
 let alert = UIAlertController(
     title: title,
     message: message,
     preferredStyle: .alert
 )
 for (title, handler) in actions {
     alert.addAction(UIAlertAction(title: title,
                                   style: .default) { _ in
         handler()
     })
 }
 return alert
}
}

// Usage:
let alert = AlertBuilder()
.title("Confirm")
.message("Are you sure?")
.action("Yes") { [weak self] in self?.confirm() }
.action("No") { }
.build()
present(alert, animated: true)

-----------------------------------------------------------------------
D. RESULT TYPE WITH CLOSURES
-----------------------------------------------------------------------

BEFORE Result (old pattern):
func fetch(completion: @escaping (Data?, Error?) -> Void) {
// completion(data, nil) or completion(nil, error)
// Caller must handle both possibly-nil — confusing
}

WITH Result (modern pattern):
func fetch(completion: @escaping (Result<Data, Error>) -> Void) {
// completion(.success(data)) or completion(.failure(error))
// Exhaustive switch — one or the other, never both
}

// Caller:
fetch { [weak self] result in
guard let self else { return }
switch result {
case .success(let data):
 process(data)
case .failure(let error):
 showError(error)
}
}

RESULT + ASYNC (bridging):
// Bridge old callback to async:
func fetchAsync() async throws -> Data {
try await withCheckedThrowingContinuation { continuation in
 fetch { result in
     continuation.resume(with: result)
 }
}
}

-----------------------------------------------------------------------
E. COMMON MISTAKES & FIXES
-----------------------------------------------------------------------

MISTAKE 1 — Missing [weak self] in stored closure:
// WRONG:
self.onUpdate = { self.reload() }   // cycle!
// FIX:
self.onUpdate = { [weak self] in self?.reload() }

MISTAKE 2 — Using [unowned self] where weak is safer:
// WRONG:
service.fetch { [unowned self] result in   // VC may be popped!
self.handle(result)
}
// FIX:
service.fetch { [weak self] result in
self?.handle(result)
}

MISTAKE 3 — Forgetting [weak self] in nested closures:
// WRONG — outer has [weak self] but inner doesn't:
DispatchQueue.global().async { [weak self] in
let data = self?.getData()
DispatchQueue.main.async {
 self?.display(data)   // ERROR: 'self' undefined here
}
}
// FIX — each nested closure needs its own capture:
DispatchQueue.global().async { [weak self] in
let data = self?.getData()
DispatchQueue.main.async { [weak self] in
 self?.display(data)
}
}

MISTAKE 4 — Calling completion handler multiple times:
func fetch(completion: @escaping (Result<Data, Error>) -> Void) {
URLSession.shared.dataTask(with: url) { data, response, error in
 if let error = error {
     completion(.failure(error))
     // Missing return! Falls through!
 }
 if let data = data {
     completion(.success(data))   // called TWICE!
 }
}.resume()
}
// FIX: Always return after calling completion:
if let error = error {
 completion(.failure(error))
 return   // ← critical
}

MISTAKE 5 — Forgetting to call completion handler:
func process(input: String,
      completion: @escaping (String) -> Void) {
guard input.count > 0 else {
 return   // WRONG: completion never called if empty!
}
completion(input.uppercased())
}
// FIX:
guard input.count > 0 else {
 completion("")   // always call completion
 return
}

MISTAKE 6 — Retaining completed tasks:
class TaskManager {
var tasks: [() -> Void] = []   // strong references

func run() {
 tasks.forEach { $0() }
 // WRONG: tasks still held after running
 // FIX:
 tasks.removeAll()   // release closures after execution
}
}

MISTAKE 7 — Capturing mutable state incorrectly:
var results: [Int] = []
let group = DispatchGroup()

for i in 0..<10 {
group.enter()
DispatchQueue.global().async {
 results.append(i)    // RACE CONDITION: concurrent writes!
 group.leave()
}
}
// FIX: Use serial queue or actor:
let serialQueue = DispatchQueue(label: "results")
for i in 0..<10 {
group.enter()
DispatchQueue.global().async {
 serialQueue.async {
     results.append(i)   // serialized
     group.leave()
 }
}
}

MISTAKE 8 — Ignoring the @escaping return path:
func loadData(_ completion: @escaping (Data) -> Void) {
if let cached = cache.get() {
 completion(cached)
 return
}
network.fetch { data in
 self.cache.set(data)
 completion(data)   // both paths call completion — correct
}
// If network.fetch never calls back → completion leaked
}

=======================================================================
PART 10: 100 INTERVIEW Q&A
=======================================================================

────────────────────────────────────────────────────────────────────
SECTION 1: BASIC QUESTIONS (Q1–Q25)
────────────────────────────────────────────────────────────────────

Q1. What is a closure in Swift?
A:  A self-contained block of functionality that can be
passed around and used in code. It "closes over" and
captures variables from its surrounding scope. Closures
are reference types, heap-allocated when they capture
values. Three forms: global functions (no capture),
nested functions (capture enclosing scope), and closure
expressions (unnamed, lightweight).

---

Q2. What is the difference between a closure and a function?
A:  Functions are named declarations at global or type scope.
Closures are anonymous expressions that can be stored in
variables, passed as arguments, or returned from functions.
All functions ARE closures (they're a special case), but
not all closures are functions. Key practical difference:
closures can capture variables from surrounding scope;
global functions cannot (they have no surrounding scope).

---

Q3. What does @escaping mean?
A:  @escaping marks a closure parameter to indicate it will
be called AFTER the function it was passed to returns.
The closure "escapes" the function's lifetime. Requires
heap allocation of the closure context, explicit self
capture in instance methods, and ARC management of
all captured references.

---

Q4. Are closures in Swift value types or reference types?
A:  Reference types. Closures are heap-allocated objects
with ARC reference counting. Assigning a closure to
another variable creates a SHARED reference, not a copy.
This is why closures can maintain shared mutable state
across multiple references to the same closure.

---

Q5. What is a capture list and why do you use one?
A:  A capture list is written inside [ ] at the start of
a closure body. It controls HOW variables from the
enclosing scope are captured:
[weak obj]    — capture weakly (Optional, no ARC retain)
[unowned obj] — capture unowned (non-Optional, no retain)
[value]       — capture a copy of value at closure creation
Used to break retain cycles ([weak]/[unowned]) or to
snapshot values ([value]) before they change.

---

Q6. What is the difference between [weak self] and [unowned self]?
A:  [weak self]: self becomes Optional inside closure.
Auto-nils if self is deallocated. Safe — returns nil
instead of crashing. Use when self MIGHT be nil.
[unowned self]: self is non-Optional. Does NOT auto-nil.
CRASHES if self is deallocated before closure runs.
Use ONLY when self is GUARANTEED to outlive the closure.
When in doubt: use [weak self].

---

Q7. Why do you need [weak self] in an escaping closure that
captures self?
A:  Without [weak self]:
- The closure retains self strongly
- If self also holds the closure (directly or indirectly)
→ retain cycle → neither is ever deallocated
- Even without a cycle: self lives longer than expected
With [weak self]:
- Closure doesn't prevent self from being deallocated
- self can be released at its natural time
- Closure handles nil case gracefully

---

Q8. Can a non-escaping closure create a retain cycle?
A:  Generally no. Non-escaping closures are called during
the function and released when the function returns.
They can't form a persistent cycle because they don't
outlive the function call. The compiler also doesn't
require explicit self capture for non-escaping closures,
reflecting this safety.

---

Q9. What is trailing closure syntax?
A:  When a closure is the last argument to a function, it
can be written after the closing parenthesis:
// Normal: array.sorted(by: { $0 < $1 })
// Trailing: array.sorted { $0 < $1 }
If closure is the only argument: parentheses can be omitted.
Swift 5.3+ supports multiple trailing closures.

---

Q10. What are shorthand argument names ($0, $1, etc.)?
A:   Swift automatically provides shorthand names for closure
parameters: $0 for first, $1 for second, etc. When used,
the explicit parameter list and 'in' keyword can be omitted:
let doubled = [1,2,3].map { $0 * 2 }
Limit to simple single-expression closures — for complex
bodies, explicit parameter names improve readability.

---

Q11. What does it mean for a closure to "capture" a variable?
A:   When a closure references a variable from its enclosing
scope, it captures — retains access to — that variable.
The variable is promoted from stack to heap (if needed)
so it outlives its original scope. The closure holds a
reference to the heap-stored variable, seeing all changes
to it and able to modify it.

---

Q12. Do closures capture value types by value or by reference?
A:   By REFERENCE to the variable binding (not the value itself).
The variable is heap-promoted and the closure holds a
reference to that heap storage. Changes inside the closure
affect the variable; changes outside are seen by the closure.
To capture by VALUE (snapshot), use a capture list: [x].

---

Q13. What is an optional closure property and is it escaping?
A:   An optional closure property (var onTap: (() -> Void)?)
is implicitly @escaping. Because it's a property, the
closure can be called at any time — it has escaped the
any particular function's scope. No explicit @escaping
annotation is needed on property declarations.

---

Q14. How does implicit return work in closures?
A:   Single-expression closures can omit the return keyword.
The expression's value is returned automatically:
let doubled = [1,2,3].map { $0 * 2 }   // implicit return
Multi-statement closures require explicit return.
This also applies to computed properties and functions
(Swift 5.1+).

---

Q15. What is the difference between map, filter, and
reduce closures in Swift?
A:   map:    transforms each element → new array of same count
    [1,2,3].map { $0 * 2 } = [2,4,6]
filter: keeps elements satisfying predicate → smaller/equal array
    [1,2,3,4].filter { $0 > 2 } = [3,4]
reduce: combines elements into a single value
    [1,2,3,4].reduce(0) { $0 + $1 } = 10
All three take non-escaping closures → no [weak self] needed,
no heap allocation for non-capturing bodies.

---

Q16. What is @autoclosure?
A:   A parameter attribute that automatically wraps an expression
passed as an argument into a closure. The expression is NOT
evaluated until the closure is called — enabling lazy evaluation:
func log(_ msg: @autoclosure () -> String) {
if verbose { print(msg()) }
}
log("Heavy: \(compute())")  // compute() only runs if verbose = true

---

Q17. Why must a weak reference in a closure be Optional?
A:   Because the object it references may be deallocated at
any point. Optional models the possibility of nil — if
the object is gone, the weak reference returns nil rather
than causing a crash. This is enforced by the compiler:
weak var ref must always be Optional.

---

Q18. What happens if you call a completion handler twice?
A:   The callback fires twice, often causing:
- UI updates applied twice (duplicate data)
- Counters/state incremented twice
- Dispatch group leave() called twice → undercount crash
- Continuation resumed twice (async/await crash)
Always add return after calling completion to prevent fall-through.

---

Q19. What happens if you never call a completion handler?
A:   The closure is never released (remains in memory as long
as the function holding it exists). In async/await: using
withCheckedContinuation — the task hangs forever (task leak).
The caller never proceeds past the await. In callback style:
the caller's completion never fires — UI stuck, spinner spins
forever, resources never cleaned up.

---

Q20. What is the 'in' keyword in a closure?
A:   It separates the closure's parameter/return type declaration
from its body:
{ (x: Int, y: Int) -> Int in
x + y
}
Everything before 'in': signature.
Everything after 'in': body.
Can be omitted when using shorthand argument names ($0, $1).

---

Q21. Can you return a closure from a function?
A:   Yes. Functions can return closures as their return type:
func makeMultiplier(_ factor: Int) -> (Int) -> Int {
return { $0 * factor }   // captures factor from enclosing scope
}
let triple = makeMultiplier(3)
triple(4)   // 12
The returned closure captures 'factor' — extending its lifetime
beyond makeMultiplier's return.

---

Q22. What is a higher-order function?
A:   A function that takes one or more functions/closures as
parameters OR returns a function/closure. Examples:
map, filter, reduce, sorted, forEach (take closures).
makeMultiplier (returns a closure).
Higher-order functions are a core functional programming
concept and are extensively used in Swift's standard library.

---

Q23. What is the difference between forEach and a for-in loop?
A:   for-in: control flow statements (break, continue, return
from OUTER function) work normally.
forEach: takes a closure. break and continue don't compile.
return exits the CLOSURE (like continue in for-in), not
the outer function. forEach closures are non-escaping.
Prefer for-in when control flow is needed; forEach for
simple side effects.

---

Q24. What is a lazy closure in Swift?
A:   lazy properties are initialized using a closure that runs
ONCE on first access:
class MyClass {
lazy var expensiveValue: [Int] = {
    return (0..<1000).map { $0 * $0 }
}()   // note: () at the end — immediately invoked
}
The closure captures self implicitly (non-escaping context).
NOT thread-safe by default — concurrent first access may
run the initializer multiple times.

---

Q25. What does @discardableResult do with closure-returning functions?
A:   @discardableResult suppresses the "result of call is unused"
warning when a function's return value (including a closure)
is not used:
@discardableResult
func configure(_ block: (Self) -> Void) -> Self {
block(self)
return self
}
configure { view in view.alpha = 0.5 }   // return value ignored — no warning

────────────────────────────────────────────────────────────────────
SECTION 2: INTERMEDIATE QUESTIONS (Q26–Q65)
────────────────────────────────────────────────────────────────────

Q26. Explain exactly what happens in memory when a closure
captures a local variable.
A:   1. Compiler detects: local variable is referenced in closure
2. Variable is "heap-promoted": a reference-counted heap box
is allocated to hold the variable's storage
3. The original stack binding becomes a pointer to the heap box
4. The closure context object holds a reference to the heap box
5. When the function returns: stack binding gone, but heap box
lives on (retained by closure)
6. When the closure is deallocated: heap box RC decremented
7. When box RC = 0: box freed, variable destroyed
Multiple closures capturing the same variable share ONE heap box.

---

Q27. What is the difference between capturing a value type
in a capture list vs without one?
A:   WITHOUT capture list (default):
var x = 10
let c = { print(x) }   // captures the BINDING (reference to box)
x = 99
c()   // prints 99 — sees latest value
WITH capture list:
var x = 10
let c = { [x] in print(x) }  // copies VALUE of x at closure creation
x = 99
c()   // prints 10 — snapshot taken at creation
Use capture list when you need to snapshot a value's
current state for async/deferred use.

---

Q28. Why does the compiler require explicit self in
@escaping closures but not non-escaping ones?
A:   For @escaping closures, the closure can outlive self.
The compiler forces you to write 'self.' or a capture
list to make you CONSCIOUSLY acknowledge:
"I am capturing self, which will keep it alive."
For non-escaping closures: self is guaranteed alive for
the entire call (function can't return before closure completes).
No risk of extending lifetime → no explicit acknowledgment needed.
This is a deliberate design choice to surface cycle risks.

---

Q29. What is the retain cycle between a ViewController
and a closure stored as a property?
A:   class VC {
var handler: (() -> Void)?   // VC strongly holds handler
func setup() {
    handler = { self.doWork() }  // handler strongly holds VC
}
}
CYCLE:  VC → handler (strong)
    handler → self/VC (strong capture)
RESULT: VC.deinit never called. VC, handler, and all their
    properties leaked forever.
FIX:    handler = { [weak self] in self?.doWork() }

---

Q30. How do you break a retain cycle between self and a Timer?
A:   Timer retained by RunLoop. Timer closure captures self.
If self also stores the timer → multi-path cycle.
TWO-PART FIX:
1. [weak self] in timer closure:
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
   [weak self] _ in self?.tick()
}
2. Invalidate timer to break RunLoop's strong reference:
func stop() {
   timer?.invalidate()
   timer = nil
}
deinit { stop() }
BOTH needed for complete cycle prevention.

---

Q31. What is withoutActuallyEscaping and when would
you use it?
A:   A Swift stdlib function that temporarily treats a
non-escaping closure AS IF it were @escaping within
a controlled block. Used when:
- An API requires @escaping but you know the closure
won't actually escape (e.g., lazy collections)
- Implementing custom higher-order functions that
use APIs internally requiring @escaping
Safety guarantee: if the closure truly escapes the
withoutActuallyEscaping block, Swift traps in debug.
Only use when you can mathematically guarantee no escape.

---

Q32. What is the difference between a closure and a
curried function?
A:   A curried function is a function that returns another function,
effectively taking its arguments one at a time:
func add(_ x: Int) -> (Int) -> Int { { y in x + y } }
let add5 = add(5)
add5(3)   // 8
This is implemented USING closures: the returned inner
function IS a closure that captures x. Currying is a
pattern; closures are the mechanism. Swift 3 removed
automatic currying syntax — now done manually.

---

Q33. How does the @escaping attribute affect the caller
vs the callee?
A:   CALLEE (function receiving the closure):
- @escaping: can store the closure, pass it to async APIs,
call it after returning. Must retain it.
- Non-escaping: must call within function scope only.
Gets optimization benefits.
CALLER (passing the closure):
- @escaping: compiler requires explicit self.
Knows closure will live beyond the call.
Must use capture lists for cycle prevention.
- Non-escaping: implicit self OK. No cycle risk.
Compiler can make strong guarantees about lifetimes.

---

Q34. What does guard let self = self do in a weak closure?
A:   Creates a new STRONG reference to self for the remainder
of the closure's scope. Before the guard:
self is Optional (weak). After the guard: self is
non-Optional strong (local constant). This:
1. Checks self is still alive (exits if nil)
2. Creates a strong reference preventing deallocation
during the rest of the synchronous closure body
3. In Swift 5.3+: shadows 'self' so no 'self.' needed
CAVEAT: In async closures, self may be released between
await suspension points even after the guard.

---

Q35. Why is [weak self] often used in UIKit completion
handlers even when there's no obvious cycle?
A:   Even without a formal cycle, [weak self] prevents:
1. UNEXPECTED LIFETIME EXTENSION: the VC stays alive
until the network completes even if the user has
already left the screen — wasting memory
2. STALE UPDATES: the completion may fire on a VC that
has been dismissed and repurposed, causing incorrect
UI updates
3. PRECAUTIONARY: architecture may change, introducing
cycles later. [weak self] is cheap defensive code.
4. THREADING: weak self forces nil-check before UI updates,
adding a natural guard against nil UI elements.

---

Q36. Explain how multiple trailing closure syntax works
and when to use it.
A:   Swift 5.3+: when a function has multiple closure
parameters, they can be written as trailing closures:
UIView.animate(withDuration: 0.3) {
view.alpha = 0         // animations: (no label)
} completion: { finished in
cleanup()              // completion: (labeled)
}
RULES:
- First trailing closure: no argument label
- Subsequent: keep their parameter labels
- If only ONE closure argument, can omit parentheses entirely
USE WHEN: Function has 2-3 closure parameters that benefit
from visual separation. Avoid when it harms readability.

---

Q37. What is the semantics of capturing self in a lazy property?
A:   lazy properties are initialized with a closure-like syntax:
lazy var x = expensiveInit()
or:
lazy var x: Type = {
return computation(self.otherProperty)
}()
self is captured IMPLICITLY in the initializer block.
This is NON-ESCAPING (the closure runs immediately on first
access and is then discarded). NO CYCLE: the closure is
not stored — it's called once and released. [weak self]
is NOT needed in lazy initializers.

---

Q38. How do you pass a closure as a Combine publisher
without creating a retain cycle?
A:   Using sink with [weak self]:
cancellable = publisher
.receive(on: DispatchQueue.main)
.sink { [weak self] value in
    self?.handle(value)
}
Store the AnyCancellable in a Set on self:
publisher.sink { [weak self] value in
self?.handle(value)
}.store(in: &cancellables)
CYCLE if: self → cancellables → sink closure → self
FIX: [weak self] in ALL closure arguments to operators.
Also: operators like map, filter, etc.:
.map { [weak self] value in self?.transform(value) }

---

Q39. What is the difference between DispatchQueue.sync
and DispatchQueue.async regarding closures?
A:   sync:  Closure runs BEFORE sync returns. Blocking.
   Closure is NON-ESCAPING (conceptually) — caller
   waits for it. No [weak self] needed for cycle safety
   (closure completes before function returns).
async: Closure runs AFTER async returns. Non-blocking.
   Closure IS escaping — lives beyond the call.
   [weak self] needed if self held in closure
   and async closure stored somewhere.
WARNING: Calling sync on current queue = DEADLOCK.

---

Q40. How do closures interact with Swift's Result type?
A:   Result<Success, Failure> is commonly returned via
@escaping completion handlers:
func fetch(completion: @escaping (Result<Data, Error>) -> Void)
Benefits over (Data?, Error?) callbacks:
- Exhaustive: either success or failure, never both
- Type-safe: success and failure types are explicit
- Composable: Result has map, flatMap, mapError methods
Bridge to async/await:
withCheckedThrowingContinuation { cont in
fetch { result in cont.resume(with: result) }
}

---

Q41. What is the difference between an escaping closure
and a non-escaping closure in terms of optimizer impact?
A:   NON-ESCAPING:
- Can be stack-allocated (no heap cost)
- Caller's variables can be passed as borrows (no retain/release)
- Compiler can inline the closure body
- No ARC overhead for captured values
- Function calls through closure can be devirtualized
@ESCAPING:
- Must be heap-allocated
- Captured values must be retained (ARC cost)
- Cannot inline in most cases
- Cannot be stack-promoted
- Compiler must be conservative about lifetimes
PERFORMANCE IMPACT: For high-frequency calls (animations,
scrolling callbacks), non-escaping is measurably faster.

---

Q42. How does compactMap differ from map in its closure usage?
A:   map: transforms each element, keeps all results (including nil
 for Optional-returning transforms → gives [T?])
compactMap: transforms each element, REMOVES nil results
        → gives [T] (non-optional array)
Both use non-escaping closures. compactMap is equivalent to:
map { transform($0) }.filter { $0 != nil }.map { $0! }
but more efficient. Common use:
let strs = ["1", "two", "3"]
let ints = strs.compactMap { Int($0) }   // [1, 3]

---

Q43. Explain the difference between flatMap for sequences
vs flatMap for Optionals.
A:   flatMap on sequences:
[[1,2],[3,4]].flatMap { $0 }   // [1,2,3,4]
Takes closure returning a Sequence, flattens one level.
flatMap on Optional (now called compactMap for collections):
Optional(5).flatMap { n in n > 3 ? Optional(n) : nil }
Chains Optional transformations, prevents double-Optional.
Both use non-escaping closures. The Optional variant was
renamed to flatMap on Optional and compactMap on collections
in Swift 4.1 to reduce confusion.

---

Q44. What is the purpose of @_implicitSelfCapture?
A:   An internal Swift attribute (not public API) that allows
implicit self capture in closures without the usual
@escaping requirement for explicit self. Used internally
by Swift compiler for things like withObservationTracking.
Not intended for external use. Mentioned here for
completeness — in production code, always use explicit
[weak self] or [self] as appropriate.

---

Q45. How do you implement memoization using closures in Swift?
A:   func memoize<Input: Hashable, Output>(
_ function: @escaping (Input) -> Output
) -> (Input) -> Output {
var cache: [Input: Output] = [:]
return { input in
    if let cached = cache[input] { return cached }
    let result = function(input)
    cache[input] = result
    return result
}
}
// Usage:
let memoFib: (Int) -> Int = memoize { n in
n <= 1 ? n : memoFib(n-1) + memoFib(n-2)
}
// The returned closure captures 'cache' strongly
// Cache lives as long as the returned closure is held

---

Q46. What is a @Sendable closure and when is it required?
A:   @Sendable marks a closure that can be safely sent across
concurrency boundaries (actors, threads). Required when:
- Passing closures to Task { }, Task.detached { }
- Passing closures across actor boundaries
- Storing closures in Sendable types
RULES: All captured values must be Sendable.
Value types (Sendable by default), immutable classes,
actors, and @unchecked Sendable types are OK.
Mutable non-Sendable classes captured → compile error.

---

Q47. How does the @MainActor annotation affect closures
and captures?
A:   @MainActor closures run on the main thread:
let update: @MainActor () -> Void = {
label.text = "Updated"   // safe — on main thread
}
CAPTURE IMPLICATIONS:
- Closures passed to @MainActor functions are isolated
- Self is implicitly @MainActor if the class is
- Calling non-MainActor async code requires await
- @MainActor closures in Task { } run on main thread
UIViewController is @MainActor → all methods and
closures with implicit self are main-thread-safe.

---

Q48. What is the difference between a closure capturing
a class instance vs a struct instance?
A:   CLASS instance captured:
- Closure captures the REFERENCE (pointer)
- Closure and external code share the SAME object
- Mutations visible across all references
- ARC: RC incremented (unless weak/unowned)
STRUCT instance captured:
- Struct is stored in a HEAP BOX (if variable) or
copied into the closure context (if value snapshot)
- Closure has its own copy of the struct's VALUE
- Mutations inside closure don't affect external struct
(and vice versa unless they share the same heap box via reference capture)
- No ARC cost for the struct itself (only for any class
 properties the struct contains)

---

Q49. How do you safely cancel a network request when a
ViewController is dismissed mid-flight?
A:   PATTERN:
class ViewController: UIViewController {
   private var task: URLSessionDataTask?

   func load() {
       task = URLSession.shared.dataTask(with: url) {
           [weak self] data, _, error in
           guard let self else { return }
           DispatchQueue.main.async { [weak self] in
               self?.display(data)
           }
       }
       task?.resume()
   }

   deinit {
       task?.cancel()       // cancels in-flight request
       print("VC freed")
   }
}
KEY POINTS:
- [weak self] prevents VC from living until request completes
- task?.cancel() in deinit ensures network is released
- guard let self early-exits if VC is gone before callback
- Modern alternative: use async/await + task cancellation

---

Q50. What is the difference between capturing a variable
by reference vs by value in a loop?
A:   REFERENCE capture (default):
var closures: [() -> Int] = []
var x = 0
for _ in 0..<3 {
   closures.append { x }   // all share SAME heap box for x
}
x = 99
closures.forEach { print($0()) }   // 99, 99, 99

VALUE capture (capture list):
var closures: [() -> Int] = []
var x = 0
for i in 0..<3 {
   closures.append { [x] in x }   // each captures snapshot
   x += 1
}
closures.forEach { print($0()) }   // 0, 1, 2

NOTE: Swift for-in loop creates a new binding each
iteration for the loop variable itself — so:
for i in 0..<3 { closures.append { i } }
prints 0, 1, 2 correctly (each i is a new binding).
This differs from C/JavaScript where the loop variable
is shared.

---

Q51. How does a closure affect the lifetime of a captured
optional variable?
A:   The closure captures the VARIABLE BINDING (the Optional
container), not the wrapped value:
var obj: MyClass? = MyClass()    // obj = Optional<MyClass>
let closure = { print(obj?.name) }  // captures 'obj' binding
obj = nil      // obj is now .none, but binding still exists
closure()      // prints nil — sees obj = nil
obj = MyClass("new")   // closure sees new value too
closure()      // prints "new"

IMPORTANT DISTINCTION:
var ref: MyClass? = MyClass()
let c1 = { print(ref) }          // captures binding — sees changes
let c2 = { [ref] in print(ref) } // captures VALUE of ref at creation
ref = nil
c1()   // nil
c2()   // Optional(MyClass) — snapshotted before nil

---

Q52. What is a throwing closure and how do you call it?
A:   A closure with throws in its type signature:
let risky: (Int) throws -> Int = { n in
   guard n > 0 else { throw MyError.invalid }
   return n * 2
}
CALLING — must use try:
do {
   let result = try risky(-1)
} catch {
   print(error)
}

IN HIGHER-ORDER FUNCTIONS (rethrows):
func transform<T, U>(
   _ value: T,
   _ f: (T) throws -> U
) rethrows -> U {
   try f(value)
}
// rethrows: only throws if the closure throws
// Callers don't need try if they pass a non-throwing closure

---

Q53. What is rethrows and how does it differ from throws?
A:   throws: function ALWAYS potentially throws — callers must use try.
rethrows: function throws ONLY IF the closure argument throws.
If caller passes a non-throwing closure: no try needed.
If caller passes a throwing closure: try required.

Example:
func apply<T>(_ x: T, _ f: (T) throws -> T) rethrows -> T {
   try f(x)
}
apply(5) { $0 * 2 }          // no try needed — closure doesn't throw
try apply(5) { n throws in   // try needed — closure throws
   guard n > 0 else { throw Err.negative }
   return n
}

---

Q54. How do closures interact with inout parameters?
A:   Non-escaping closures CAN capture inout parameters:
func increment(value: inout Int, by: Int, using f: () -> Void) {
   value += by
   f()   // non-escaping — value still in scope
}

@escaping closures CANNOT capture inout parameters:
func store(_ value: inout Int, in f: @escaping () -> Void) {
   // ERROR: escaping closure cannot capture inout parameter
   // value might be out of scope when closure runs
}
REASON: inout uses copy-in/copy-out semantics. If the closure
escapes, the original variable may no longer exist when
the closure tries to write back — undefined behavior.
FIX: Capture a copy: let copy = value; then capture copy.

---

Q55. What is the behavior of defer with closures?
A:   defer schedules a block to run when the CURRENT SCOPE exits,
regardless of how (return, throw, or fall-through):
func process() throws {
   let resource = acquireResource()
   defer { release(resource) }   // always runs on scope exit
   try doRisky()                 // may throw
   // defer block runs even if doRisky() throws
}
defer blocks are NON-ESCAPING — they run before scope exit.
Cannot contain return, break, continue, or throw that
would leave the defer block itself. Multiple defers:
execute in REVERSE ORDER (LIFO).

---

Q56. How do you implement a once-only closure execution?
A:   Using a flag:
class Once {
   private var executed = false
   private let lock = NSLock()

   func run(_ work: () -> Void) {
       lock.lock()
       defer { lock.unlock() }
       guard !executed else { return }
       executed = true
       work()
   }
}

Or using DispatchOnce equivalent:
var token: Bool = false
func runOnce(_ work: () -> Void) {
   guard !token else { return }
   token = true
   work()
}

THREAD-SAFE WITH lazy:
class MyClass {
   lazy var setup: Void = {
       print("Setup runs once")
   }()
}
// lazy guarantees single initialization
// (though not thread-safe — race on first access)

---

Q57. Explain how closures enable the "strategy" design pattern.
A:   The strategy pattern defines a family of algorithms,
encapsulates each, and makes them interchangeable.
Closures are a lightweight way to implement this:

struct Sorter<T> {
   var compare: (T, T) -> Bool   // strategy closure

   func sort(_ array: [T]) -> [T] {
       array.sorted(by: compare)
   }
}

let ascending  = Sorter<Int>(compare: <)
let descending = Sorter<Int>(compare: >)
let byAbsValue = Sorter<Int>(compare: { abs($0) < abs($1) })

ascending.sort([3,1,4,1,5])    // [1,1,3,4,5]
descending.sort([3,1,4,1,5])   // [5,4,3,1,1]
byAbsValue.sort([-5,2,-1,3])   // [-1,2,3,-5]

ADVANTAGE OVER PROTOCOLS:
No new type declarations needed. Strategies are
anonymous, composable, and injected at call site.
Perfect for 1-2 method "protocols."

---

Q58. What is the retain count behavior when you store
a closure in an array?
A:   Storing a closure in an array creates a STRONG reference
to that closure object. The array "retains" the closure.
If the closure captures objects:
- Those objects are retained BY the closure
- The array → closure → captured objects chain is all strong
EXAMPLE:
class Processor { var handlers: [() -> Void] = [] }
class Worker {
   func register(to p: Processor) {
       p.handlers.append { self.doWork() }
       // p.handlers → closure → self (strong)
       // If Processor lives long → Worker lives long
   }
}
FIX: p.handlers.append { [weak self] in self?.doWork() }
CLEANUP: Always call handlers.removeAll() when done
to release all closure contexts and their captures.

---

Q59. How do you handle thread safety when a closure
modifies shared state?
A:   PROBLEM: Multiple threads calling closures that write
the same variable → data race → undefined behavior.

SOLUTION 1: Serial DispatchQueue:
let queue = DispatchQueue(label: "com.app.safe")
var shared: [Int] = []
func append(_ value: Int) {
   queue.async { shared.append(value) }
}

SOLUTION 2: Actor (Swift 5.5+):
actor SafeStore {
   var items: [Int] = []
   func append(_ value: Int) { items.append(value) }
}

SOLUTION 3: NSLock / os_unfair_lock:
let lock = NSLock()
func appendSafe(_ value: Int) {
   lock.lock()
   defer { lock.unlock() }
   shared.append(value)
}

SOLUTION 4: Atomic property wrapper (DIY or library).

RECOMMENDATION: Actor for new Swift code; serial
queue for existing Objective-C-style code.

---

Q60. What is the difference between a stored closure
and a computed property that returns a closure?
A:   STORED CLOSURE (evaluated once, result retained):
class MyClass {
   var transform: (Int) -> Int = { $0 * 2 }
   // 'transform' holds a specific closure object
   // Same closure every time it's called
   // Can be reassigned: transform = { $0 + 1 }
}

COMPUTED PROPERTY RETURNING CLOSURE (evaluated each time):
class MyClass {
   var transform: (Int) -> Int {
       return { $0 * self.multiplier }
       // NEW closure created each time 'transform' is accessed
       // Captures 'self.multiplier' at access time
   }
}

KEY DIFFERENCE:
Stored: one allocation, same closure, can be changed.
Computed: new allocation per access, fresh capture each time.
For closures that should reflect current state: computed.
For stable, assignable behavior: stored.

---

Q61. What is function composition using closures in Swift?
A:   Combining two functions f and g into a new function
h(x) = g(f(x)):
func compose<A, B, C>(
   _ f: @escaping (A) -> B,
   _ g: @escaping (B) -> C
) -> (A) -> C {
   return { x in g(f(x)) }
   // Returned closure captures BOTH f and g strongly
}

let double = { (x: Int) in x * 2 }
let addOne = { (x: Int) in x + 1 }
let doubleThenAddOne = compose(double, addOne)
doubleThenAddOne(5)   // 11

Custom operator:
infix operator >>>: AdditionPrecedence
func >>> <A, B, C>(f: @escaping (A) -> B,
                   g: @escaping (B) -> C) -> (A) -> C {
   { g(f($0)) }
}
let transform = double >>> addOne >>> double
transform(3)   // ((3*2)+1)*2 = 14

---

Q62. How do closures work as initializer arguments vs
stored as properties?
A:   AS INITIALIZER ARGUMENT (non-escaping):
struct View {
   init(configure: (inout View) -> Void) {
       configure(&self)   // called during init — non-escaping
   }                      // no [weak self] needed, no cycle
}
View { view in view.backgroundColor = .red }

STORED AS PROPERTY (escaping):
class Button {
   var onTap: (() -> Void)?   // stored → implicitly escaping
   init(onTap: (() -> Void)? = nil) {
       self.onTap = onTap   // stored for later use
   }
}
// Cycle risk if onTap captures the Button's owner
// who also owns the Button

---

Q63. What are the ARC implications of chained Combine
operators and closures?
A:   Each Combine operator that takes a closure (map, filter,
flatMap, sink) creates a closure that is:
- Retained by the operator (part of the pipeline)
- Retains all captured values
CHAIN:
publisher
   .map { [weak self] in self?.transform($0) }
   .compactMap { $0 }
   .sink { [weak self] in self?.handle($0) }
   .store(in: &cancellables)

RETENTION CHAIN:
cancellables → AnyCancellable → sink → map → source publisher
Each closure in the chain is retained by the next stage.
[weak self] in EACH closure prevents self being retained
by the entire pipeline.

RULE: Every closure in a Combine chain stored on self
must use [weak self]. Not just the terminal sink.

---

Q64. How do you bridge a delegate callback to an
async/await continuation?
A:   Using withCheckedContinuation (or withCheckedThrowingContinuation):

// Original delegate-based API:
protocol ImagePickerDelegate {
   func didPick(_ image: UIImage?)
}

// Bridge to async:
class AsyncImagePicker: NSObject, ImagePickerDelegate {
   private var continuation: CheckedContinuation<UIImage?, Never>?

   func pickImage() async -> UIImage? {
       return await withCheckedContinuation { cont in
           self.continuation = cont
           // Show picker UI
           showPicker()
       }
   }

   func didPick(_ image: UIImage?) {
       continuation?.resume(returning: image)
       continuation = nil   // important: release continuation
   }
}

ARC NOTES:
- Continuation is heap-allocated, retained until resume()
- Must resume EXACTLY ONCE or task hangs / crashes
- Set continuation = nil after resume to release it
- self retained by picker UI until dismissed

---

Q65. What is the performance difference between using
protocol delegation vs closure delegation at scale?
A:   PROTOCOL DELEGATION:
- Virtual dispatch via witness table: ~1-2ns per call
- No closure allocation
- No ARC on the call itself (weak delegate pointer)
CLOSURE DELEGATION:
- Direct function pointer call: ~0-1ns (faster dispatch)
- But: closure context heap-allocated once at setup
- ARC retain/release on closure context per call (if escaping)
AT SCALE (millions of calls):
- Protocol dispatch and closure dispatch are comparable
- Closure's ARC overhead can accumulate in tight loops
- For performance-critical paths: use protocol + final class
- For ergonomics and flexibility: closures are fine
PROFILING VERDICT: In practice, the difference is negligible
for typical UIKit/SwiftUI usage. Choose based on API clarity.

────────────────────────────────────────────────────────────────────
SECTION 3: HARD / ADVANCED QUESTIONS (Q66–Q100)
────────────────────────────────────────────────────────────────────

Q66. Explain exactly how the Swift compiler represents
a closure at the SIL (Swift Intermediate Language) level.
A:   In SIL, a closure consists of TWO parts:
1. FUNCTION REFERENCE: a pointer to a SIL function
  (thin function — no closure context embedded)
  Declared as: sil @closureBody : $(Int) -> Int
2. CONTEXT OBJECT: a heap-allocated struct containing
  all captured values, managed by ARC.
  alloc_ref $ClosureContext
  store capturedValue to context.field

These are combined into a THICK FUNCTION VALUE:
%closure = partial_apply [callee_guaranteed]
              @closureBody(%context)
              : $(ClosureContext, Int) -> Int
// partial_apply: binds the context, producing a value
// with signature (Int) -> Int

The thick function value has two words:
Word 1: function pointer (to the specialized body)
Word 2: pointer to the heap context (or nil if no captures)

NON-CAPTURING CLOSURE (no context):
%closure = function_ref @closureBody
// Just a thin function pointer — zero overhead

CALLING:
%result = apply %closure(%arg)
// Expands to: call the function with context + argument

---

Q67. What is partial_apply in Swift's SIL and how does
it relate to closures capturing self?
A:   partial_apply is the SIL instruction that creates a closure
by "partially applying" some arguments to a function.
When a method is referenced as a closure on self:
let closure = self.someMethod
// SIL:
// %method = function_ref @MyClass.someMethod
// %context = copy_value %self   // retain self
// %closure = partial_apply %method(%context)
// closure now: calls someMethod with self already bound
LIFETIME IMPLICATION:
self is RETAINED by partial_apply. The resulting closure
holds a strong reference to self. This is why:
button.action = self.handleTap   // retains self!
is a cycle if button is stored on self. Even method
references (not just explicit closures) create captures.
FIX: Use explicit closure with [weak self]:
button.action = { [weak self] in self?.handleTap() }

---

Q68. How does the Swift optimizer handle closure contexts
for non-escaping closures at the SIL optimization level?
A:   For non-escaping closures, the optimizer applies
CLOSURE CONTEXT STACK PROMOTION:
1. SIL optimizer detects: partial_apply context never escapes
2. Converts: alloc_ref (heap) → alloc_stack (stack)
3. Removes: ARC retain/release on the context
4. Result: zero heap allocation, zero ARC cost

ESCAPE ANALYSIS in SIL:
The optimizer tracks every use of the closure value:
- Passed to non-escaping parameter: safe to stack-promote
- Stored to heap location: must remain heap-allocated
- Passed to @escaping parameter: cannot stack-promote

OPTIMIZATION PIPELINE:
1. CapturePromotion: promotes captured variables
2. ClosureSpecialization: inlines closure into caller
3. DeadCodeElimination: removes unused closures entirely

RESULT IN PRACTICE:
[1,2,3].map { $0 * 2 }
In Release: entire map + closure inlined, context on stack
or eliminated entirely. Same assembly as hand-written loop.

---

Q69. What is closure specialization and how does it
improve performance?
A:   CLOSURE SPECIALIZATION is a compiler optimization where
the generic function accepting a closure is specialized
for a specific closure implementation:
// Generic:
func apply<T>(_ x: T, _ f: (T) -> T) -> T { f(x) }
// Called with specific closure:
apply(5) { $0 * 2 }

WITHOUT specialization:
- f is called through an indirect function pointer
- Context passed as opaque pointer
- Dynamic dispatch — cannot inline or optimize

WITH specialization (SIL ClosureSpecialization pass):
// Compiler generates specialized version:
func apply_specialized(_ x: Int) -> Int { x * 2 }
// Closure body INLINED into apply
// No function pointer, no context object
// Same as if you wrote: 5 * 2

TRIGGER CONDITIONS:
- Call site visible to compiler (same module or @inlinable)
- Closure is non-escaping
- Concrete type visible (not protocol existential)

---

Q70. Explain the "closure context sharing" optimization and
when it applies.
A:   When MULTIPLE closures capture the SAME set of variables,
the Swift compiler may share a single closure context:
func makeOps() -> (() -> Void, () -> Void) {
   var count = 0
   let inc = { count += 1 }   // captures count
   let dec = { count -= 1 }   // captures count
   return (inc, dec)
}
NAIVE APPROACH: Two heap contexts, each with copy of count.
SHARING OPTIMIZATION:
- ONE heap context: { count: 0 }
- Both inc and dec hold pointers to the SAME context
- Mutations to count visible to both — correct semantics
- ONE allocation instead of two — memory efficient
HOW IT WORKS IN SIL:
Both partial_apply instructions receive the same
%context value. The context is reference-counted once.
inc retains context (RC=2), dec retains context (RC=2 still? No:
alloc_ref creates with RC=1, each partial_apply retains: RC=3).
Released when both closures are released.

---

Q71. What is the difference between a @convention(c),
@convention(block), and @convention(swift) closure?
A:   Swift has three calling conventions for closures:

@convention(swift) — DEFAULT:
- Thick function: function pointer + context pointer
- Full ARC management
- Used for all regular Swift closures

@convention(c) — C FUNCTION POINTER:
- Thin function: only a function pointer (no context)
- NO captures allowed (no context to hold them)
- Used when passing to C APIs expecting function pointers
let cFunc: @convention(c) (Int) -> Int = { $0 * 2 }
// Works only if no values captured

@convention(block) — OBJECTIVE-C BLOCK:
- Obj-C block layout: isa + flags + invoke pointer + descriptor + captures
- ARC managed via _Block_copy / _Block_release
- Used for ObjC APIs expecting blocks
let block: @convention(block) (Int) -> Int = { $0 * 2 }
// Automatically bridged when calling ObjC APIs

BRIDGING:
Swift closures auto-bridge to @convention(block) when
passed to ObjC APIs. @convention(c) requires explicit
annotation and PROHIBITS captures.

---

Q72. How does the Swift runtime resolve a thick function
value call at the assembly level?
A:   A thick function value is two words: [fn_ptr | context_ptr]
Calling it on ARM64:
// Assume closure stored at address X
LDR  X8, [X]          // Load fn_ptr into X8
LDR  X20, [X, #8]     // Load context_ptr into X20 (self reg)
BLRL X8               // Call fn_ptr

Inside the function body, X20 holds the context pointer.
Captured variables accessed as offsets from X20:
LDR  X0, [X20, #16]   // Load first captured value
LDR  X1, [X20, #24]   // Load second captured value

NON-CAPTURING CLOSURE (thin function):
// No context needed — just a direct call
BL   closureBody       // statically linked, no indirection

PERFORMANCE IMPLICATION:
- Non-capturing: zero overhead (direct branch)
- Capturing non-escaping: usually inlined by optimizer
- Capturing escaping: two loads + indirect branch + ARC = ~5-10ns

---

Q73. What is the "deinitBarrier" concept in closures
and why does it matter?
A:   When a class instance is being deallocated (deinit running),
its properties are in a partially-destroyed state.
A "deinit barrier" prevents closures that reference the
instance from executing DURING the deinit phase.
HOW IT WORKS:
1. When deinit starts, the object's state transitions to
  "deiniting" in the side table
2. Any attempt to load a weak reference to this object
  returns nil (zeroing happens)
3. Strong references held by the closures still work
  (they kept the object alive past the final release)
4. The issue arises if a closure is scheduled on a queue
  and CAPTURES a strong reference that is released concurrently
PRACTICAL RULE:
- Any closure dispatched to another queue that uses self
 should use [weak self] to prevent holding self through
 the deinit race window
- Don't dispatch to a queue from deinit with self access:
 deinit {
     DispatchQueue.main.async {
         self.cleanup()  // DANGEROUS: self is being destroyed
     }
 }
 // FIX: Do cleanup synchronously in deinit directly

---

Q74. How do you implement a "debounce" pattern using
closures and ensure no retain cycles?
A:   func debounce(
   interval: TimeInterval,
   queue: DispatchQueue = .main,
   action: @escaping () -> Void
) -> () -> Void {
   var workItem: DispatchWorkItem?
   return {
       workItem?.cancel()
       let newItem = DispatchWorkItem { action() }
       workItem = newItem
       queue.asyncAfter(deadline: .now() + interval,
                        execute: newItem)
   }
}

// Usage in ViewController:
class SearchVC: UIViewController {
   lazy var debouncedSearch: () -> Void = debounce(
       interval: 0.3
   ) { [weak self] in
       self?.performSearch()
   }

   func textDidChange() {
       debouncedSearch()
   }
}

ARC ANALYSIS:
- debounce returns a closure capturing workItem (a var)
- action captured with [weak self] — no cycle
- debouncedSearch is lazy — stored on VC but action
 doesn't retain VC (weak self)
- DispatchWorkItem captures action — released after execution
 or cancellation

---

Q75. What happens to a closure's captured variables when
the closure is copied (assigned to multiple variables)?
A:   Closures are REFERENCE TYPES. Copying a closure doesn't
copy the closure context — it shares it:
var count = 0
let original = { count += 1; print(count) }
let copy = original    // copy = reference to SAME closure

original()   // 1 — modifies shared count
copy()       // 2 — sees count=1, modifies same count
original()   // 3

CONTRAST WITH VALUE TYPE behavior:
If closures were value types, copy() would print 1,1,1
(its own count). But they're reference types → shared state.

FORCE-COPY SEMANTICS (impossible directly):
You cannot clone a closure's captured context in Swift.
To get independent state: call the factory function again:
let counter1 = makeCounter()
let counter2 = makeCounter()   // fresh counter — own box

---

Q76. How do closures interact with Swift's ownership
system (borrowing/consuming) in Swift 5.9+?
A:   CONSUMING CLOSURES:
func use(_ f: consuming () -> Void) {
   f()
   // f is consumed — cannot call again
   // No retain/release for this transfer
}

BORROWING CLOSURES:
func inspect(_ f: borrowing () -> Void) {
   f()
   // f is borrowed — caller retains ownership
   // No ARC increment for this parameter
}

NONCOPYABLE CAPTURES (~Copyable):
struct Handle: ~Copyable {
   consuming func use() { /* one-time use */ }
}
let handle = Handle()
let closure = { consume handle }   // 'consume' keyword
// handle cannot be used after this point
// closure OWNS handle — only one can exist

PRACTICAL IMPACT:
consuming closures enable MOVE SEMANTICS for closures —
transferring ownership without ARC retain/release cost.
Used in high-performance code to eliminate ARC overhead
at closure-passing boundaries.

---

Q77. How does Swift handle closures in protocol
existentials (any) vs generics (<T: Protocol>)?
A:   GENERIC APPROACH (preferred for closures):
func process<T: Runnable>(_ runner: T, work: (T) -> Void) {
   work(runner)
}
// Closure type is concrete: (ConcreteRunner) -> Void
// Compiler can specialize: inline closure, no existential box
// Zero overhead for non-capturing closures

EXISTENTIAL APPROACH:
func process(_ runner: any Runnable, work: (any Runnable) -> Void) {
   work(runner)
}
// Closure type is existential: (any Runnable) -> Void
// Runner may be boxed in existential container
// Cannot inline — dynamic dispatch

CLOSURE STORED IN EXISTENTIAL:
var handler: (any Runnable) -> Void = { runner in
   runner.run()   // dynamic dispatch through protocol witness table
}
// The closure itself is a thick function (normal)
// The argument's method calls go through witness table

PERFORMANCE RULE:
For closures called frequently: use generics for
monomorphization. Use existentials only when type
erasure is genuinely needed (heterogeneous collections).

---

Q78. What is the memory layout difference between a
closure capturing one variable vs ten variables?
A:   CLOSURE CONTEXT LAYOUT (heap object):
┌──────────────────────────────────┐
│ isa pointer (8 bytes)            │  ← type metadata
│ reference count (8 bytes)        │  ← ARC
│ captured var 1 (size of type)    │
│ captured var 2 (size of type)    │
│ ...                              │
│ captured var N (size of type)    │
└──────────────────────────────────┘

ONE VARIABLE (e.g., one Int = 8 bytes):
Context size = 16 (header) + 8 = 24 bytes
One heap allocation

TEN VARIABLES (mix of types):
Context size = 16 (header) + sum(sizeof each capture)
Still ONE heap allocation — just larger
e.g., 4 Ints + 2 class refs + 4 Strings:
= 16 + (4×8) + (2×8) + (4×16) = 16 + 32 + 16 + 64 = 128 bytes

PERFORMANCE IMPLICATION:
More captures = larger context = more memory per closure instance.
But still ONE allocation regardless of capture count.
Capture only what you need — both for performance and clarity.

---

Q79. How do you implement "once per object lifetime" callback
using closures and @noescape semantics?
A:   class Initializer {
   private var initialized = false

   func initialize(using block: () -> Void) {
       // Non-escaping block — runs now or never
       guard !initialized else { return }
       initialized = true
       block()
   }
}

// For thread-safe once execution:
final class Once {
   private let _lock = NSLock()
   private var _hasRun = false

   func run(_ block: () -> Void) {
       _lock.lock()
       let shouldRun = !_hasRun
       if shouldRun { _hasRun = true }
       _lock.unlock()
       if shouldRun { block() }
   }
}

// Swift actor version (modern):
actor OnceActor {
   private var hasRun = false
   func run(_ block: @Sendable () async -> Void) async {
       guard !hasRun else { return }
       hasRun = true
       await block()
   }
}

---

Q80. What happens when a closure captures a variable
that is itself a closure?
A:   The outer closure captures the inner closure as a
REFERENCE TYPE — the inner closure object is retained:
let inner: () -> Void = { print("inner") }
var outer: () -> Void = {
   inner()   // outer captures 'inner' strongly
             // inner's ARC count incremented by outer's context
}
ARC CHAIN: outer context → inner closure object

MUTATION:
var handler: () -> Void = { print("A") }
let wrapper = { handler() }   // captures 'handler' binding (heap box)
handler = { print("B") }      // changes the box's contents
wrapper()   // prints "B" — wrapper sees the updated handler

NESTED CLOSURE CYCLE (rare but possible):
var a: (() -> Void)?
var b: (() -> Void)?
a = { b?() }   // a captures b's binding
b = { a?() }   // b captures a's binding
// a's box → b closure; b's box → a closure
// If a and b are properties of same object: potential cycle
// FIX: [weak] capture of the variable binding

---

Q81. How do you implement type-safe event handling with
closures and generics, avoiding retain cycles?
A:   final class TypedEvent<Payload> {
   private struct Handler {
       weak var owner: AnyObject?
       let call: (Payload) -> Void
       var isAlive: Bool { owner != nil }
   }

   private var handlers: [Handler] = []
   private let lock = os_unfair_lock_t.allocate(capacity: 1)

   deinit { lock.deallocate() }

   func subscribe<Owner: AnyObject>(
       _ owner: Owner,
       handler: @escaping (Owner, Payload) -> Void
   ) {
       let h = Handler(owner: owner) { [weak owner] payload in
           guard let owner else { return }
           handler(owner, payload)
       }
       // (lock operations omitted for brevity)
       handlers.append(h)
   }

   func emit(_ payload: Payload) {
       handlers.removeAll { !$0.isAlive }
       handlers.forEach { $0.call(payload) }
   }
}

// Usage:
let didLoad = TypedEvent<[Item]>()
didLoad.subscribe(self) { vc, items in
   vc.display(items)   // strongly typed, no retain cycle
}
didLoad.emit([Item()])

---

Q82. Explain how closures interact with copy-on-write
(CoW) value types.
A:   CoW types (Array, Dictionary, String) use a shared
reference-counted buffer internally. When captured by
a closure:

SCENARIO 1 — Shared buffer, no mutation:
var array = [1, 2, 3]
let read = { print(array.count) }
// array's buffer RC incremented (closure holds array,
// array holds buffer strongly)
// No copy of array data — just reference to same buffer
// Reading: zero copy cost

SCENARIO 2 — Closure mutates CoW type:
var array = [1, 2, 3]
let append = { array.append(4) }
// array captured by reference (heap box holds the array value)
// On mutation inside closure: isKnownUniquelyReferenced checks
// If NOT unique (other references exist) → COPY triggered
// If unique → in-place mutation

SCENARIO 3 — Value capture snapshot (no mutation sharing):
var array = [1, 2, 3]
let snap = { [array] in print(array) }
// [array] creates a COPY of the Array struct (not buffer)
// The copy shares the buffer until either side mutates
// On snap's access: no copy (read-only)
// If snap mutated array internally: new buffer created for snap's copy
array.append(99)   // snap's captured copy NOT affected

---

Q83. What is the behavior of @escaping closures with
respect to Swift's memory exclusivity rules?
A:   Swift enforces EXCLUSIVE ACCESS: only one access
(read or write) to a variable at a time.
@escaping closures can violate this if not careful:

VIOLATION EXAMPLE:
var value = 0
func modifyWith(_ f: @escaping () -> Void) {
   value += 1         // write access BEGINS
   f()                // calls closure that also writes value?
   value += 1         // write access ongoing
}
modifyWith { value += 1 }   // EXCLUSIVE ACCESS VIOLATION
// Two overlapping write accesses to 'value'

RUNTIME DETECTION:
Swift's runtime (with exclusivity checking enabled)
detects this and traps: "Simultaneous accesses to 0x...,
but modification requires exclusive access."

WITH CLOSURES AND inout:
func modify(_ value: inout Int, using f: @escaping () -> Void) {
   // ERROR at compile time: inout + escaping → rejected
   // Cannot escape a reference to inout parameter
}

SAFE PATTERN:
func modify(_ value: inout Int, using f: (inout Int) -> Void) {
   f(&value)   // non-escaping: safe, exclusive access guaranteed
}

---

Q84. How do you implement retry logic with exponential
backoff using closures?
A:   func retry<T>(
   attempts: Int,
   delay: TimeInterval = 1.0,
   operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
   completion: @escaping (Result<T, Error>) -> Void
) {
   operation { result in
       switch result {
       case .success:
           completion(result)
       case .failure(let error):
           guard attempts > 1 else {
               completion(.failure(error))
               return
           }
           DispatchQueue.global().asyncAfter(
               deadline: .now() + delay
           ) {
               retry(
                   attempts: attempts - 1,
                   delay: delay * 2,   // exponential backoff
                   operation: operation,
                   completion: completion
               )
           }
       }
   }
}

// Usage:
retry(attempts: 3, delay: 1.0, operation: { completion in
   apiClient.fetchData { result in completion(result) }
}) { [weak self] result in
   self?.handle(result)
}

ARC NOTES:
- operation and completion are @escaping — heap-allocated
- Each recursive retry retains both closures
- Stack depth: O(1) (each retry is async — no stack growth)
- [weak self] in outer completion prevents VC retention

---

Q85. What is the ARC behavior of a @escaping closure
passed through multiple function calls?
A:   SCENARIO: Closure passed through a chain of functions:
func a(_ f: @escaping () -> Void) { b(f) }
func b(_ f: @escaping () -> Void) { c(f) }
func c(_ f: @escaping () -> Void) { queue.async(execute: f) }

ARC AT EACH BOUNDARY:
- Passing f to a: retain (RC=2, caller had RC=1)
- Inside a, passing to b: retain (RC=3)
- Inside b, passing to c: retain (RC=4)
- queue.async stores f: retain (RC=5)
- c returns: release (RC=4)
- b returns: release (RC=3)
- a returns: release (RC=2)
- Caller releases: RC=1 (queue holds it)
- When queue fires f: executes
- queue releases f: RC=0 → closure deallocated

OPTIMIZATION (consuming parameters, Swift 5.9):
func a(_ f: consuming @escaping () -> Void) { b(f) }
// No retain at a's boundary — ownership transferred
// RC stays at 1 throughout the chain until queue stores it

---

Q86. What are the implications of using [self] explicit
capture in Swift 5.3+ vs implicit capture?
A:   IMPLICIT CAPTURE (pre-Swift 5.3, still works):
someEscapingFunction {
   self.doWork()   // implicitly captures self strongly
}
// Compiler warns in some contexts but allows it

EXPLICIT [self] CAPTURE (Swift 5.3+):
someEscapingFunction { [self] in
   doWork()   // explicit: "I know I'm capturing self"
}
DIFFERENCES:
1. SEMANTICS: Both create strong reference — no ARC difference
2. SENDABLE: [self] may be required for @Sendable closures
  to satisfy the compiler's Sendable checking
3. CLARITY: [self] makes the capture intention explicit
  — useful for code review and cycle auditing
4. ACTOR ISOLATION: In actor-isolated contexts, [self] can
  help the compiler verify isolation correctness
5. NO CYCLE PREVENTION: [self] does NOT prevent cycles.
  For cycle prevention: use [weak self] or [unowned self]

---

Q87. How do you implement a closure-based state machine
without retain cycles?
A:   enum State { case idle, loading, loaded([Item]), failed(Error) }

class StateMachine {
   private(set) var state: State = .idle {
       didSet { notifyObservers(state) }
   }
   private var observers: [String: (State) -> Void] = [:]

   func addObserver(id: String,
                    handler: @escaping (State) -> Void) {
       observers[id] = handler
   }

   func removeObserver(id: String) {
       observers.removeValue(forKey: id)
   }

   private func notifyObservers(_ state: State) {
       observers.values.forEach { $0(state) }
   }

   func transition(to newState: State) {
       state = newState
   }
}

// Usage — no cycle:
class ViewController {
   let machine = StateMachine()
   let id = "vc_observer"

   func setup() {
       machine.addObserver(id: id) { [weak self] state in
           self?.render(state)   // [weak self] breaks potential cycle
       }
   }

   deinit {
       machine.removeObserver(id: id)   // clean up
   }
}

---

Q88. How does Swift's strict concurrency checking (Swift 6)
affect closure capture and @Sendable requirements?
A:   Swift 6 enforces COMPLETE CONCURRENCY SAFETY at compile time.
Effects on closures:

1. ALL closures crossing concurrency boundaries must be @Sendable:
  Task { nonSendableClosure() }
  // ERROR in Swift 6: closure captures non-Sendable type

2. Captures of non-Sendable types in @Sendable closures:
  class MyVC { var data: [Item] = [] }
  Task { [self] in   // ERROR: MyVC is not Sendable
      data.append(item)
  }
  // FIX: Use @MainActor class or actor

3. @MainActor classes are Sendable from the main actor perspective:
  @MainActor class MyVC {
      func load() {
          Task { @MainActor [self] in
              data = await fetch()  // safe — on MainActor
          }
      }
  }

4. Isolation regions: Swift 6 tracks which region each
  closure's captures belong to. Crossing regions without
  proper synchronization is a compile error.

MIGRATION STRATEGY:
- Add @MainActor to ViewControllers and ViewModels
- Use actors for shared mutable state
- Replace class with struct where possible
- Use [weak self] defensively to reduce Sendable issues

---

Q89. What is the memory behavior of closures in a
recursive async context?
A:   RECURSIVE ASYNC with closures:
func processTree(node: TreeNode,
                work: @escaping (TreeNode) async -> Void) async {
   await work(node)
   for child in node.children {
       await processTree(node: child, work: work)  // recursive
   }
}

MEMORY BEHAVIOR:
- work closure retained for EACH recursive call
- Async stack frames suspended on heap (not call stack)
- Each await suspension stores the continuation on heap
- For a tree of depth N: N continuation frames alive simultaneously
- Each frame retains 'work' closure: RC grows to N+1

RISK: Deep trees with large captured contexts → O(N) memory
MITIGATION:
- Use iterative approaches with explicit stacks for deep trees
- TaskGroup for concurrent but bounded-depth traversal:
 await withTaskGroup(of: Void.self) { group in
     group.addTask { await work(node) }
     for child in node.children {
         group.addTask { [child] in
             await processTree(node: child, work: work)
         }
     }
 }
- Avoid capturing large objects in recursive closures

---

Q90. Explain how withCheckedContinuation and
withUnsafeContinuation differ in ARC behavior.
A:   BOTH create a continuation object (heap-allocated):
- Stores the async task's resumption state
- Strong reference until resume() is called

withCheckedContinuation:
- Tracks whether resume() was called
- DEBUG: traps if resume() called twice
- DEBUG: warns if continuation leaked (never resumed)
- Small overhead: atomic flag for checking
- ARC: continuation released on resume()

withUnsafeContinuation:
- NO tracking — developer's responsibility
- Calling resume() twice: UNDEFINED BEHAVIOR (likely crash)
- Never calling resume(): task hangs SILENTLY (no warning)
- Slightly faster: no checking overhead
- ARC: same — continuation released on resume()

RECOMMENDATION:
Always use withCheckedContinuation in development.
withUnsafeContinuation only for proven-correct,
performance-critical bridging code.

ARC PATTERN (correct):
await withCheckedContinuation { continuation in
   let cont = continuation   // strong ref — keeps task alive
   callback = { result in
       cont.resume(returning: result)
       // After resume: continuation releases the task state
       // callback's capture of cont also released here
       // (assuming callback is single-use and released)
   }
}
// After resume: the continuation and all its captures freed

---

Q91. How do you build a promise/future pattern using
closures in Swift without retain cycles?
A:   final class Promise<T> {
   private enum State {
       case pending
       case fulfilled(T)
       case rejected(Error)
   }

   private var state: State = .pending
   private var fulfillHandlers: [(T) -> Void] = []
   private var rejectHandlers:  [(Error) -> Void] = []
   private let lock = NSLock()

   func then(_ handler: @escaping (T) -> Void) -> Self {
       lock.lock()
       defer { lock.unlock() }
       switch state {
       case .pending:   fulfillHandlers.append(handler)
       case .fulfilled(let value): handler(value)
       case .rejected: break
       }
       return self
   }

   func resolve(_ value: T) {
       lock.lock()
       guard case .pending = state else { lock.unlock(); return }
       state = .fulfilled(value)
       let handlers = fulfillHandlers
       fulfillHandlers.removeAll()   // release closures
       rejectHandlers.removeAll()
       lock.unlock()
       handlers.forEach { $0(value) }
   }

   // reject() similarly
}

// Usage:
let promise = Promise<User>()
promise.then { [weak self] user in
   self?.display(user)   // [weak self] breaks cycle
}
apiClient.fetch { user in promise.resolve(user) }

ARC NOTES:
- Handlers stored strongly until promise resolves
- After resolve: handlers.removeAll() releases all closures
- [weak self] in handlers prevents VC being held by promise

---

Q92. How does structured concurrency's task tree affect
closure lifetime and cancellation?
A:   In structured concurrency, tasks form a TREE:
parent task → child tasks (async let, TaskGroup)
LIFETIME RULE: Children cannot outlive their parent.

CLOSURE LIFETIME IN TASK TREE:
func parentTask() async {
   async let childResult = childWork { [weak self] in
       self?.processResult()   // closure lifetime = child task lifetime
   }
   await childResult
   // Parent waits here — child task (and its closures)
   // guaranteed dead when parent moves past this point
}
// CONTRAST WITH unstructured Task:
func launchUnstructured() {
   Task {   // child does NOT block parent
       await longWork { [weak self] in   // must use weak self
           self?.handle()   // self may be gone
       }
   }
   // Parent continues immediately
}

CANCELLATION PROPAGATION:
- Cancelling parent → all child tasks cancelled
- Closures in cancelled tasks: should check Task.isCancelled
- Cancellation doesn't automatically release captures —
 the closure must EXIT for captures to be released
- Best practice: check Task.isCancelled at start of closure
 and after each await

---

Q93. What is the behavior difference between escaping
closures and async functions regarding error propagation?
A:   ESCAPING CLOSURE error propagation:
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
   // Error must be manually wrapped in Result
   // Caller must handle both cases explicitly
   // If completion never called: error silently lost
   // Multiple error paths: easy to miss one
}

ASYNC FUNCTION error propagation:
func fetchData() async throws -> Data {
   // throws: error propagates automatically up call stack
   // Compiler ensures all paths either return or throw
   // Structured: cannot silently drop errors
   // Caller: forced to handle with try/catch
}

CLOSURE vs ASYNC for errors:
Closures: error as parameter (Result or 2-parameter style)
Async: error via throws — same as synchronous Swift pattern

BRIDGING ERRORS:
func asyncBridge() async throws -> Data {
   try await withCheckedThrowingContinuation { cont in
       fetchData { result in
           cont.resume(with: result)   // Result bridges to throws
       }
   }
}

RULE: For new code, prefer async throws over Result callbacks.
Bridging is trivial; error handling is much cleaner.

---

Q94. How does @objc and dynamic dispatch interact with
closure-based callbacks vs selector-based callbacks?
A:   SELECTOR-BASED (@objc + #selector):
NotificationCenter.default.addObserver(
   self,
   selector: #selector(handleNotif),
   name: .someNotif,
   object: nil
)
@objc func handleNotif() { }
- Target (self) retained WEAKLY by NC in modern iOS
- No closure allocation
- No capture issues
- Method dispatch through ObjC runtime (dynamic)

CLOSURE-BASED (block observer):
let token = NotificationCenter.default.addObserver(
   forName: .someNotif,
   object: nil,
   queue: .main
) { [weak self] _ in
   self?.handleNotif()
}
- Token (observer object) retained STRONGLY by NC
- Token must be stored and removeObserver called in deinit
- Closure creates heap allocation
- [weak self] prevents cycle: self → token → closure → self

PERFORMANCE:
Selector: direct ObjC message send (~5ns)
Closure: indirect call through function pointer (~1-3ns)
For high-frequency notifications: closure slightly faster.
For correctness and simplicity: selector often safer.

---

Q95. How do you implement a "sink" — consuming a sequence
with a closure — ensuring memory safety?
A:   extension AsyncSequence {
   func sink(
       receiveValue: @escaping (Element) -> Void,
       receiveCompletion: @escaping (Error?) -> Void
   ) -> Task<Void, Never> {
       Task {
           do {
               for try await value in self {
                   guard !Task.isCancelled else { break }
                   receiveValue(value)
               }
               receiveCompletion(nil)
           } catch {
               receiveCompletion(error)
           }
       }
   }
}

// Usage:
class DataController {
   private var sinkTask: Task<Void, Never>?

   func subscribe(to stream: some AsyncSequence<Item, Error>) {
       sinkTask = stream.sink { [weak self] item in
           self?.process(item)
       } receiveCompletion: { [weak self] error in
           self?.handleCompletion(error)
       }
   }

   deinit {
       sinkTask?.cancel()   // stop consuming on dealloc
   }
}
ARC: sinkTask (Task) retained by controller.
Task's closure captures weak self → no cycle.
cancel() in deinit → Task finishes → closures released.

---

Q96. What are the implications of escaping closures in
property wrappers and SwiftUI's @State, @Binding?
A: SwiftUI is a property wrapper backed by a SwiftUI-managed
 storage box (not the struct itself). Closures in SwiftUI:

 @State CLOSURES:
 struct MyView: View {
     @State private var count = 0
     var body: some View {
         Button("Tap") {
             count += 1    // this closure is NON-ESCAPING
         }                 // view builder captures count by value
     }
 }
 // No [weak self] needed: SwiftUI View structs are value types.
 // No retain cycles possible — structs have no identity.

 @Binding CLOSURES:
 struct ChildView: View {
     @Binding var value: Int
     var body: some View {
         Button("Increment") { value += 1 }
         // Binding closure writes through to parent's @State
         // All closures in view body are non-escaping
     }
 }

 ESCAPING CLOSURES IN SWIFTUI (requires care):
 class ViewModel: ObservableObject {
     @Published var items: [Item] = []
     var onUpdate: (() -> Void)?   // stored → escaping

     func load() {
         Task { [weak self] in
             let data = await fetch()
             await MainActor.run { [weak self] in
                 self?.items = data
                 self?.onUpdate?()   // call stored closure
             }
         }
     }
 }
 // ViewModel is a class → ARC applies → [weak self] needed
 // View structs assigned to onUpdate: safe (value type, copied)
 // Class view model holding ViewModel → potential cycle if
 // onUpdate captures the ViewModel

---

Q97. How do you implement a closure-based animation
 sequencer that correctly manages memory?
A:   class AnimationSequencer {
     private var steps: [(@escaping () -> Void) -> Void] = []
     private var isRunning = false

     @discardableResult
     func add(
         _ animation: @escaping (@escaping () -> Void) -> Void
     ) -> Self {
         steps.append(animation)
         return self
     }

     func run(completion: @escaping () -> Void = {}) {
         guard !steps.isEmpty, !isRunning else {
             completion()
             return
         }
         isRunning = true
         runStep(index: 0, completion: completion)
     }

     private func runStep(index: Int,
                          completion: @escaping () -> Void) {
         guard index < steps.count else {
             isRunning = false
             completion()
             return
         }
         steps[index] { [weak self] in
             self?.runStep(index: index + 1,
                           completion: completion)
         }
     }

     deinit { print("AnimationSequencer freed") }
 }

 // Usage:
 class ViewController: UIViewController {
     lazy var sequencer = AnimationSequencer()

     func animate() {
         sequencer
             .add { next in
                 UIView.animate(withDuration: 0.3,
                                animations: { self.view.alpha = 0 },
                                completion: { _ in next() })
             }
             .add { next in
                 UIView.animate(withDuration: 0.3,
                                animations: { self.view.alpha = 1 },
                                completion: { _ in next() })
             }
             .run { [weak self] in
                 self?.onAnimationComplete()
             }
     }
 }

 ARC ANALYSIS:
 - steps array stores closures strongly (cleared when done if needed)
 - runStep uses [weak self] → no cycle (sequencer → self → sequencer)
 - animations closure captures self from ViewController context
 - completion: [weak self] → VC can be freed before animation ends
 - UIView.animate animations: non-escaping → no [weak self] needed
 - UIView.animate completion: escaping → [weak self] recommended

---

Q98. How do Swift closures interact with Objective-C
 blocks at the ABI level?
A:   Swift closures and ObjC blocks have DIFFERENT layouts
 but Swift auto-bridges between them.

 ObjC BLOCK LAYOUT (on heap):
 struct Block {
     void *isa;              // &_NSConcreteStackBlock / &_NSConcreteMallocBlock
     int  flags;             // reference count + flags
     int  reserved;
     void (*invoke)(void *); // function pointer
     struct BlockDescriptor *descriptor;
     // Captured variables follow here (variable length)
 }

 SWIFT CLOSURE LAYOUT:
 struct ThickFunction {
     void (*fnPtr)(/* params */, void *context);
     HeapObject *context;    // ARC-managed closure context
 }

 AUTO-BRIDGING (Swift → ObjC):
 When passing a Swift closure to an ObjC API expecting a block:
 - Swift runtime wraps the thick function in a Block layout
 - _Block_copy called when ObjC retains the block
 - _Block_release maps to swift_release on the context
 - Transparent to developer — just pass the Swift closure

 AUTO-BRIDGING (ObjC block → Swift):
 - ObjC block passed to Swift closure parameter
 - Swift wraps it in a thick function (fn + context)
 - _Block_copy called when Swift retains
 - Developers use it as a normal Swift closure

 PERFORMANCE NOTE:
 The bridging adds one indirection level. For extremely
 hot paths (game loops, audio callbacks), use
 @convention(c) function pointers to avoid ALL overhead.

---

Q99. What is the complete lifecycle of an @escaping closure
 from creation to deallocation, with all ARC events?
A:   COMPLETE LIFECYCLE TRACE:

 PHASE 1 — CREATION:
 let captured = SomeClass()    // captured.RC = 1
 let closure: () -> Void = {   // closure box allocated on heap
     captured.doWork()         // captured retained by box
 }                             // captured.RC = 2
                               // closureBox.RC = 1

 PHASE 2 — PASSING TO FUNCTION:
 func store(_ f: @escaping () -> Void) { queue.append(f) }
 store(closure)
 // Inside store: f parameter retains closure → closureBox.RC = 2
 // queue.append(f): queue retains → closureBox.RC = 3
 // f parameter released on store() return → closureBox.RC = 2

 PHASE 3 — CALLER RELEASES REFERENCE:
 // Let's say 'closure' var goes out of scope:
 // closureBox.RC = 1 (only queue holds it now)
 // captured.RC = 2 (closureBox still holds captured)

 PHASE 4 — ORIGINAL CAPTURED OBJECT RELEASED:
 // Let's say caller releases 'captured' var:
 // captured.RC = 1 (closureBox still holds it)
 // captured CANNOT be freed yet — closureBox retains it

 PHASE 5 — CLOSURE EXECUTES:
 // queue fires: queue.first?()
 // closureBox called: captured.doWork() runs
 // captured.RC still 1 during execution

 PHASE 6 — CLOSURE RELEASED FROM QUEUE:
 // queue.removeFirst() → closureBox.RC = 0
 // closureBox begins deallocation:
 //   releases captured → captured.RC = 0
 //   → captured.deinit() called
 //   → captured freed
 // closureBox memory freed

 SUMMARY TABLE:
 Event                          closureBox.RC  captured.RC
 closure created                1              2
 passed to store()              2              2
 store() returns                2              2 (queue holds it)
 closure var goes out of scope  1              2
 caller releases captured       1              1
 queue fires closure            1              1
 queue releases closure         0→deinit       0→deinit

---

Q100. Design a fully memory-safe, cancellable, closure-based
  async operation pipeline with proper [weak self] usage,
  cancellation propagation, error handling, and thread safety.
A:
 // ── Supporting Types ────────────────────────────────────────────

 enum PipelineError: Error {
     case cancelled
     case upstream(Error)
     case timeout
 }

 // ── Operation Token (cancellation handle) ───────────────────────

 final class CancellationToken {
     private let lock = NSLock()
     private var _isCancelled = false
     private var handlers: [() -> Void] = []

     var isCancelled: Bool {
         lock.lock(); defer { lock.unlock() }
         return _isCancelled
     }

     func cancel() {
         lock.lock()
         guard !_isCancelled else { lock.unlock(); return }
         _isCancelled = true
         let h = handlers; handlers = []
         lock.unlock()
         h.forEach { $0() }
     }

     func onCancel(_ handler: @escaping () -> Void) {
         lock.lock()
         if _isCancelled {
             lock.unlock(); handler(); return
         }
         handlers.append(handler)
         lock.unlock()
     }
 }

 // ── Pipeline Stage ───────────────────────────────────────────────

 final class Pipeline<Input, Output> {
     private let transform: (
         Input,
         CancellationToken,
         @escaping (Result<Output, Error>) -> Void
     ) -> Void

     init(
         transform: @escaping (
             Input,
             CancellationToken,
             @escaping (Result<Output, Error>) -> Void
         ) -> Void
     ) {
         self.transform = transform
     }

     // Chain a new stage
     func then<Next>(
         _ next: @escaping (
             Output,
             CancellationToken,
             @escaping (Result<Next, Error>) -> Void
         ) -> Void
     ) -> Pipeline<Input, Next> {
         Pipeline<Input, Next> { input, token, completion in
             guard !token.isCancelled else {
                 completion(.failure(PipelineError.cancelled))
                 return
             }
             self.transform(input, token) { result in
                 switch result {
                 case .failure(let e):
                     completion(.failure(PipelineError.upstream(e)))
                 case .success(let value):
                     guard !token.isCancelled else {
                         completion(.failure(PipelineError.cancelled))
                         return
                     }
                     next(value, token, completion)
                 }
             }
         }
     }

     // Execute the pipeline
     @discardableResult
     func run(
         input: Input,
         token: CancellationToken = CancellationToken(),
         completion: @escaping (Result<Output, Error>) -> Void
     ) -> CancellationToken {
         transform(input, token, completion)
         return token
     }
 }

 // ── Usage in ViewController ──────────────────────────────────────

 class FeedViewController: UIViewController {

     private var cancellationToken: CancellationToken?
     private var items: [Item] = []

     // Build the pipeline (no retain cycle — all stages
     // use [weak self] only in the final completion)
     private func makePipeline() -> Pipeline<String, [Item]> {
         Pipeline { query, token, completion in
             // Stage 1: Network fetch
             let task = URLSession.shared.dataTask(
                 with: makeSearchURL(query)
             ) { data, _, error in
                 if token.isCancelled {
                     completion(.failure(PipelineError.cancelled))
                     return
                 }
                 if let error = error {
                     completion(.failure(error)); return
                 }
                 guard let data = data else {
                     completion(.failure(PipelineError.cancelled))
                     return
                 }
                 completion(.success(data))
             }
             // Register cancellation handler
             token.onCancel { task.cancel() }
             task.resume()
         }
         .then { data, token, completion in
             // Stage 2: Parse on background queue
             DispatchQueue.global(qos: .userInitiated).async {
                 guard !token.isCancelled else {
                     completion(.failure(PipelineError.cancelled))
                     return
                 }
                 do {
                     let items = try JSONDecoder()
                         .decode([Item].self, from: data)
                     completion(.success(items))
                 } catch {
                     completion(.failure(error))
                 }
             }
         }
     }

     func search(query: String) {
         // Cancel previous search
         cancellationToken?.cancel()
         let token = CancellationToken()
         cancellationToken = token

         makePipeline().run(input: query, token: token) {
             [weak self] result in   // [weak self] — VC may be dismissed
             DispatchQueue.main.async { [weak self] in
                 guard let self else { return }
                 switch result {
                 case .success(let items):
                     self.items = items
                     self.tableView.reloadData()
                 case .failure(PipelineError.cancelled):
                     break   // ignore cancellation — expected
                 case .failure(let error):
                     self.showError(error)
                 }
             }
         }
     }

     deinit {
         cancellationToken?.cancel()   // cancel on dealloc
         print("FeedViewController freed")
     }
 }

 // ── ARC + MEMORY SAFETY AUDIT ────────────────────────────────────
 //
 // CancellationToken:
 //   ✓ NSLock protects concurrent cancel/onCancel calls
 //   ✓ Handlers array cleared on cancel → closures released
 //   ✓ No self references → no cycles
 //
 // Pipeline:
 //   ✓ transform stored strongly (it's the pipeline's purpose)
 //   ✓ .then() chains create new Pipeline — old one retained
 //     by the new stage's closure (intended — pipeline DAG)
 //   ✓ No self captures in stage closures → no VC cycle
 //
 // ViewController:
 //   ✓ [weak self] in run() completion → VC not held by pipeline
 //   ✓ cancellationToken?.cancel() in deinit → network cancelled
 //   ✓ Previous token cancelled before new search → no duplicate updates
 //   ✓ .cancelled error explicitly ignored → no spurious error UI
 //
 // Threading:
 //   ✓ Network callback on URLSession thread → dispatch to main
 //   ✓ Parsing on background QoS queue → never blocks main thread
 //   ✓ All UI updates on .main → thread-safe
 //   ✓ token.isCancelled checked at each stage boundary

=======================================================================
END OF NOTES
=======================================================================
QUICK REFERENCE CHEAT SHEET — CLOSURES
=======================================================================

CLOSURE SYNTAX SPECTRUM:
Full:          { (a: Int, b: Int) -> Int in return a + b }
Inferred:      { a, b in return a + b }
Implicit ret:  { a, b in a + b }
Shorthand:     { $0 + $1 }
Operator:      (+) as (Int, Int) -> Int

ESCAPING RULES:
Non-@escaping (default): called during function, stack-promotable,
                       no explicit self needed, no heap required
@escaping:               may outlive function, heap-allocated,
                       explicit self required, ARC on captures
Optional closures:       implicitly @escaping
Stored closure props:    implicitly @escaping

CAPTURE LIST QUICK REFERENCE:
[weak self]          → Optional, auto-nil, no RC, safe
[unowned self]       → non-Optional, CRASH if dead, no RC, fast
[self]               → explicit strong (Swift 5.3+), same as default
[value]              → snapshot copy at closure creation
[weak x = expr]      → evaluate expr now, hold result weakly
[x = x]              → force-copy of value type 'x' right now

guard let self PATTERN:
{ [weak self] in
  guard let self else { return }
  // self is strong for remainder of this scope
  doA()   // no self. needed (Swift 5.3+)
  doB()
}

ASYNC SUSPENSION CAVEAT:
guard let self creates strong ref for SYNCHRONOUS scope
After each 'await': same strong ref persists (still in scope)
But semantically: object might have been logically "done"
Use Task.isCancelled to exit early in long async chains

WHEN TO USE [weak self]:
✓ Closure stored as property on self
✓ Combine sink stored in self's cancellables
✓ Timer closure when timer stored on self
✓ Task { } for operations that should not outlive self
✓ Notification observer block closures
✓ Any escaping closure where self holds it (directly or indirectly)
✗ Non-escaping closures (map, filter, forEach, sort)
✗ Lazy property initializers (non-escaping, called once)
✗ defer blocks (non-escaping)
✗ SwiftUI View body closures (structs — no identity)

WHEN TO USE [unowned self]:
✓ lazy var stored on self that references self (self outlives lazy)
✓ Closures passed synchronously where self guaranteed alive
✓ Factory-returned closures when owner guaranteed to outlive them
✗ Network callbacks (VC may be dismissed)
✗ Timer closures (timer may outlive VC)
✗ Any situation where you are not 100% certain

CLOSURE vs ASYNC/AWAIT:
CLOSURES: callback hell, manual [weak self], manual threading,
        manual error propagation, easy to miss completion call
ASYNC:    structured lifetime, compiler-managed, clean error handling,
        automatic cancellation propagation, no capture lists needed
        (for structured concurrency)

STILL NEED CLOSURES FOR:
- UIKit animation completions
- NotificationCenter blocks
- DispatchQueue.async / Timer (non-async APIs)
- Protocol-based delegates
- Combine operators

@CONVENTION TYPES:
@convention(swift)   → thick function (fn ptr + context) — default
@convention(c)       → thin C function pointer — NO captures allowed
@convention(block)   → ObjC block — auto-bridged from Swift closures

PERFORMANCE HIERARCHY (fastest to slowest):
1. Non-capturing closure (inlined)          → 0 overhead
2. Non-escaping closure (stack context)     → ~0 (stack alloc)
3. Escaping closure (heap context)          → 1 malloc + ARC
4. Escaping + weak self (side table access) → + side table lookup
5. Protocol existential closure             → + dynamic dispatch
6. ObjC block bridging                      → + block copy/release

COMMON BUGS CHECKLIST:
□ Missing [weak self] in stored closure → retain cycle
□ [unowned self] in network callback → crash on VC dismiss
□ Completion called twice → duplicate state mutation
□ Completion never called → task/spinner stuck forever
□ Missing [weak self] in nested inner closure
□ Capturing mutable shared state without synchronization
□ Not cancelling tasks/timers in deinit
□ Using [self] thinking it breaks cycles (it doesn't)
□ lazy var thread-safety — concurrent first access race
□ @autoclosure @escaping capturing self without [weak self]

DEBUGGING CLOSURES:
□ Add deinit { print("\(type(of:self)) freed") } to all classes
□ Use Xcode Memory Graph Debugger to find cycle paths
□ Instruments → Leaks to detect leaked closure contexts
□ -Xfrontend -emit-sil to inspect closure capture decisions
□ Thread Sanitizer for concurrent capture races
□ Address Sanitizer for use-after-free on unowned captures

=======================================================================

 */
