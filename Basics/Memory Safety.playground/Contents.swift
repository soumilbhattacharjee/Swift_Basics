import UIKit

/*
 =======================================================================
   SWIFT — MEMORY SAFETY: ACCESS CONFLICTS & VALUE TYPE COPYING
   Complete Study Notes + 100 Interview Q&A (Including Hard Questions)
 =======================================================================

 TABLE OF CONTENTS
 -----------------
 PART 1: CORE CONCEPTS
   A. What is Memory Safety in Swift?
   B. Dimensions of Memory Safety
   C. Exclusive Access to Memory
   D. Memory Access Properties
   E. Access Conflicts — Types & Triggers
   F. inout Parameters
   G. Copy-In Copy-Out
   H. Value Types & Copying Behavior
   I. Copy-on-Write (CoW)
   J. mutating Keyword
   K. Ownership Model (Swift 5.9+/6.x)
   L. Concurrency & Memory Safety
   M. Debugging Tools

 PART 2: 100 INTERVIEW Q&A
   - Basic (Q1–Q25)
   - Intermediate (Q26–Q65)
   - Hard / Advanced (Q66–Q100)

 =======================================================================
 PART 1: CORE CONCEPTS
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS MEMORY SAFETY IN SWIFT?
 -----------------------------------------------------------------------
 Swift is designed so that memory-unsafe behavior is impossible by default.
 It prevents:
   - Data races (two concurrent accesses, one is a write)
   - Use-after-free errors
   - Out-of-bounds access
   - Uninitialized variable access
   - Invalid type reinterpretation

 Swift enforces memory safety through:
   1. Strong static type system
   2. Automatic Reference Counting (ARC)
   3. Exclusive access to memory (the Exclusivity Rule)
   4. Bounds checking for arrays
   5. Initialization before use
   6. Swift 6 strict concurrency checking

 KEY QUOTE (swift.org):
 "Swift requires that variables are initialized before they are used,
 memory is automatically managed, and array accesses are bounds-checked."

 -----------------------------------------------------------------------
 B. DIMENSIONS OF MEMORY SAFETY
 -----------------------------------------------------------------------
 Swift provides safety across 5 key dimensions:

 1. LIFETIME SAFETY
    - All accesses to a value must happen within its valid lifetime.
    - Reference types: ARC prevents use-after-free.
    - Value types: memory exclusivity enforces this.

 2. BOUNDS SAFETY
    - Array/collection indices are checked at runtime.
    - Accessing index beyond bounds causes a runtime trap.

 3. TYPE SAFETY
    - All accesses use the correct or compatible type.
    - No implicit reinterpretation of memory (unlike C/C++).

 4. INITIALIZATION SAFETY
    - Variables must be initialized before use.
    - Swift compiler enforces this at compile time.

 5. STRICT CONCURRENCY (Swift 6)
    - Data race freedom enforced by the compiler.
    - Actors, Sendable, and isolation rules apply.

 -----------------------------------------------------------------------
 C. EXCLUSIVE ACCESS TO MEMORY (THE EXCLUSIVITY RULE)
 -----------------------------------------------------------------------
 DEFINITION:
 When a memory location is being written to, NO other access
 (read OR write) to that same location can occur simultaneously.

 INTRODUCED: Swift 4 (SE-0176)
 ENFORCED BY DEFAULT: Swift 5+ in Release builds

 WHY IT MATTERS:
 Without exclusive access, overlapping accesses could produce:
   - Partial writes
   - Inconsistent state
   - Undefined behavior

 THE RULE:
 "There must be only one access to a variable at any given instant
 when that access is a write (or non-atomic)."

 EXAMPLE — No Conflict (instantaneous, non-overlapping):
   var x = 10
   var y = x + 5   // read x — instantaneous, fine
   x = y           // write x — instantaneous, fine

 EXAMPLE — Conflict (overlapping long-term accesses):
   var stepSize = 1
   func increment(_ number: inout Int) {
       number += stepSize  // ERROR: simultaneous read of stepSize
                           // while it's being written via &stepSize
   }
   increment(&stepSize)    // stepSize is both inout (write) and
                           // read inside the function

 -----------------------------------------------------------------------
 D. MEMORY ACCESS PROPERTIES
 -----------------------------------------------------------------------
 Every memory access has THREE characteristics:

 1. READ vs WRITE (or non-atomic)
    - Read: does not modify the value
    - Write: modifies the value
    - Non-atomic: special case, unsafe code only

 2. DURATION
    - INSTANTANEOUS: starts and finishes with no other code running
      in between. Most accesses are instantaneous.
    - LONG-TERM: starts, other code can run, then it ends.
      Examples: inout parameters, mutating methods on structs.

 3. MEMORY LOCATION
    - The specific variable or property being accessed.

 CONFLICT CONDITION (all 3 must be true):
   a) At least one access is a WRITE (or non-atomic)
   b) Both accesses target the SAME memory location
   c) Their TIME DURATIONS overlap

 NOTE: Conflicts can happen on a SINGLE thread —
 this is NOT just a multithreading issue!

 -----------------------------------------------------------------------
 E. ACCESS CONFLICTS — TYPES & TRIGGERS
 -----------------------------------------------------------------------

 --- TYPE 1: inout Parameter Conflict ---

 Passing a variable as inout gives the function LONG-TERM WRITE access.
 The write access begins after all non-inout args are evaluated
 and lasts for the ENTIRE duration of the function call.

 CONFLICT: Reading/writing the original variable during this period.

 // BAD — Conflict
 var stepSize = 1
 func increment(_ number: inout Int) {
     number += stepSize  // reads stepSize while it's being written
 }
 increment(&stepSize)   // RUNTIME ERROR

 // FIX — Use a local copy
 let localStep = stepSize
 increment(&stepSize)
 // or restructure to avoid the conflict

 --- TYPE 2: Passing Same Variable to Multiple inout Parameters ---

 // BAD — Conflict
 func balance(_ x: inout Int, _ y: inout Int) {
     let sum = x + y
     x = sum / 2
     y = sum - x
 }
 var score = 42
 balance(&score, &score)   // ERROR: two simultaneous writes to 'score'

 // FIX — Use distinct variables
 var score1 = 42
 var score2 = 42
 balance(&score1, &score2)   // OK

 --- TYPE 3: Struct mutating Method Conflicts ---

 Swift gives a mutating method LONG-TERM WRITE access to self.
 Accessing self or its properties during that call can conflict.

 struct Player {
     var name: String
     var health: Int

     mutating func shareHealth(with teammate: inout Player) {
         teammate.health += health / 2
     }
 }

 var oscar = Player(name: "Oscar", health: 100)
 oscar.shareHealth(with: &oscar)   // ERROR: write conflict on oscar

 // FIX — Use distinct instances
 var teammate = Player(name: "Amy", health: 50)
 oscar.shareHealth(with: &teammate)   // OK

 --- TYPE 4: Properties of Structs (inout) ---

 Accessing two properties of the SAME struct as inout simultaneously
 is treated as conflicting because structs are stored as a single
 memory block (even different properties).

 func swap(_ a: inout Int, _ b: inout Int) {
     let temp = a; a = b; b = temp
 }

 var player = (name: "Alice", score: 5, level: 10)
 swap(&player.score, &player.level)   // ERROR (global/stored vars)

 // NOTE: This IS safe if the struct is a local variable
 // because the compiler can prove no overlap.

 -----------------------------------------------------------------------
 F. INOUT PARAMETERS — DEEP DIVE
 -----------------------------------------------------------------------

 DEFINITION:
 inout allows a function to modify the caller's variable directly.
 Without inout, parameters are constants (let) inside functions.

 SYNTAX:
   func functionName(_ param: inout Type) { ... }
   functionName(&variableName)

 RULES:
   - Can only pass variables (var), not constants (let) or literals
   - Must prefix with & at call site
   - Cannot pass computed properties that have no setter
   - Cannot pass global constants

 HOW IT WORKS INTERNALLY — Copy-In Copy-Out:
   1. A copy of the argument is made (copy IN)
   2. The copy is passed into the function
   3. The function modifies the copy
   4. On return, the modified copy is written back (copy OUT)

 OPTIMIZATION:
 The compiler may optimize to pass a direct reference (pass-by-reference)
 when safe, but the SEMANTIC guarantee is always copy-in-copy-out.

 EXAMPLE — Basic inout:
   func doubleValue(_ n: inout Int) {
       n *= 2
   }
   var x = 5
   doubleValue(&x)
   print(x)  // 10

 EXAMPLE — Swap using inout:
   func swapValues<T>(_ a: inout T, _ b: inout T) {
       let temp = a
       a = b
       b = temp
   }
   var a = "hello"
   var b = "world"
   swapValues(&a, &b)
   print(a, b)  // world hello

 EXAMPLE — inout with struct:
   struct Counter {
       var count = 0
   }
   func increment(_ c: inout Counter) {
       c.count += 1
   }
   var myCounter = Counter()
   increment(&myCounter)
   print(myCounter.count)  // 1

 WHAT YOU CANNOT DO WITH inout:
   - let myConst = 5; increment(&myConst)   // ERROR — can't pass let
   - increment(&5)                           // ERROR — can't pass literal
   - Capture inout in a non-escaping closure that outlives the call

 INOUT + CLOSURES:
   inout parameters can be captured by closures, but only
   non-escaping closures. Escaping closures cannot capture inout
   because the inout lifetime ends when the function returns.

   func modify(_ x: inout Int, using closure: () -> Void) {
       x += 1
       closure()
   }

   // ERROR if closure is @escaping and captures x

 -----------------------------------------------------------------------
 G. COPY-IN COPY-OUT vs PASS-BY-REFERENCE
 -----------------------------------------------------------------------

 Copy-In Copy-Out (the formal model):
   1. Value is COPIED when function is called
   2. Function works on its local copy
   3. On function return, copy is written back to original

 Pass-By-Reference (compiler optimization):
   - When safe, the compiler passes a direct reference
   - This is an optimization detail, not observable behavior
   - The programmer should always think in copy-in-copy-out terms

 IMPORTANT IMPLICATION:
 Even with copy-in copy-out, EXCLUSIVE ACCESS still applies
 during the entire function call. The original variable is
 "locked for writing" from the moment you call the function
 until it returns.

 EXAMPLE showing when copy-in/out matters:
   var value = 42
   func modify(_ n: inout Int) {
       n = 100
       // If we crash here, 'value' might not be updated yet
       // (depends on when copy-out happens)
   }
   modify(&value)
   // value is updated after function returns

 -----------------------------------------------------------------------
 H. VALUE TYPES & COPYING BEHAVIOR
 -----------------------------------------------------------------------

 DEFINITION:
 Value types (struct, enum, tuples) hold UNIQUE COPIES of their data.
 When assigned or passed, each variable gets its OWN independent copy.

 REFERENCE TYPES vs VALUE TYPES:
   Value Types:    struct, enum, Int, Double, String, Array,
                   Dictionary, Set, Bool, tuples
   Reference Types: class, closures, functions

 FUNDAMENTAL RULE:
   var a = [1, 2, 3]
   var b = a          // b is a COPY of a
   b.append(4)
   print(a)  // [1, 2, 3] — a is unchanged
   print(b)  // [1, 2, 3, 4]

 WHY VALUE TYPES ARE MEMORY SAFE:
   - No shared mutable state between variables
   - Changes to one copy cannot affect another
   - Thread-safe to pass copies to concurrent tasks
   - No need for locks when passing values across threads

 STRUCTS:
   struct Point {
       var x: Double
       var y: Double
   }
   var p1 = Point(x: 1.0, y: 2.0)
   var p2 = p1         // full copy
   p2.x = 99.0
   print(p1.x)  // 1.0 — unchanged

 ENUMS:
   enum Direction {
       case north, south, east, west
   }
   var dir1 = Direction.north
   var dir2 = dir1     // copy
   dir2 = .south
   // dir1 is still .north

 -----------------------------------------------------------------------
 I. COPY-ON-WRITE (COW)
 -----------------------------------------------------------------------

 DEFINITION:
 Copy-on-Write is an optimization where actual copying of the
 underlying buffer is deferred until a mutation occurs.
 If no mutation, multiple variables can share the same storage.

 WHICH TYPES USE COW:
   - Array
   - Dictionary
   - Set
   - String
   - (Custom types can implement CoW manually)

 HOW COW WORKS:
   1. Two variables share the same underlying buffer
   2. When one variable is about to be MUTATED,
      Swift checks if the buffer has more than 1 owner
   3. If YES (shared) → make a copy, then mutate the copy
   4. If NO (unique) → mutate in place (no copy needed)

 EXAMPLE:
   var a = [1, 2, 3]    // a has unique ownership of buffer
   var b = a            // b and a now SHARE the same buffer
                        // No copy yet!
   b.append(4)          // NOW b copies the buffer before mutating
   print(a)  // [1, 2, 3]
   print(b)  // [1, 2, 3, 4]

 HOW TO CHECK OWNERSHIP (isKnownUniquelyReferenced):
   import Foundation
   class Holder {
       var buffer: [Int] = []
   }
   // isKnownUniquelyReferenced(&holder) returns true if only
   // one Swift variable references this object

 IMPLEMENTING CUSTOM COW:
   final class ArrayStorage {
       var buffer: [Int]
       init(_ buffer: [Int]) { self.buffer = buffer }
   }

   struct CowArray {
       private var storage: ArrayStorage

       init(_ buffer: [Int]) {
           storage = ArrayStorage(buffer)
       }

       var buffer: [Int] {
           get { storage.buffer }
           set {
               if !isKnownUniquelyReferenced(&storage) {
                   storage = ArrayStorage(newValue)
               } else {
                   storage.buffer = newValue
               }
           }
       }
   }

   var arr1 = CowArray([1, 2, 3])
   var arr2 = arr1             // Shared storage
   arr2.buffer.append(4)       // Triggers copy on arr2's storage
   print(arr1.buffer)  // [1, 2, 3]
   print(arr2.buffer)  // [1, 2, 3, 4]

 PERFORMANCE CHARACTERISTICS:
   - CoW is very efficient for read-heavy workloads
   - Frequent mutation causes repeated copies → overhead
   - Best for large collections passed around read-only
   - Worst case: modify in a loop — copy every iteration

 PERFORMANCE TIP — Avoid CoW copies in loops:
   // BAD — may trigger CoW copy inside loop
   var numbers = [Int](repeating: 0, count: 1000)
   for i in 0..<numbers.count {
       numbers[i] = i * 2   // safe if uniquely referenced
   }

   // SAFE — ensuring unique reference before loop
   // (Usually the compiler handles this, but be aware)

 -----------------------------------------------------------------------
 J. THE mutating KEYWORD
 -----------------------------------------------------------------------

 DEFINITION:
 In Swift, methods on value types cannot modify self by default.
 The mutating keyword marks a method as one that will modify self.

 WHY NEEDED:
 Value types are passed as constants (let) unless marked mutating.
 Swift needs to know upfront if a method will mutate to enforce
 exclusive access rules.

 EXAMPLE:
   struct BankAccount {
       var balance: Double

       mutating func deposit(_ amount: Double) {
           balance += amount
       }

       mutating func withdraw(_ amount: Double) {
           guard amount <= balance else { return }
           balance -= amount
       }

       func getBalance() -> Double {
           return balance  // non-mutating — just reading
       }
   }

   var account = BankAccount(balance: 100.0)
   account.deposit(50.0)
   print(account.balance)  // 150.0

 CANNOT CALL mutating ON let:
   let account = BankAccount(balance: 100.0)
   account.deposit(50.0)  // ERROR: cannot use mutating member
                          // on immutable value

 MUTATING + ENUMS:
   enum TrafficLight {
       case red, yellow, green

       mutating func next() {
           switch self {
           case .red:    self = .green
           case .green:  self = .yellow
           case .yellow: self = .red
           }
       }
   }
   var light = TrafficLight.red
   light.next()
   print(light)  // green

 HOW MUTATING RELATES TO MEMORY SAFETY:
 When a mutating method is called, Swift gives the struct instance
 LONG-TERM WRITE ACCESS for the duration of the method.
 This is the same mechanism as inout — it prevents conflicting
 access to self from within the method.

 -----------------------------------------------------------------------
 K. OWNERSHIP MODEL (Swift 5.9 / 5.11 / 6.x)
 -----------------------------------------------------------------------

 BACKGROUND:
 Swift's ownership model (inspired by Rust) gives developers
 explicit control over when values are copied vs moved.

 KEY NEW KEYWORDS:
   consuming   — Takes ownership; original cannot be used after
   borrowing   — Read-only, non-owning access; no copy needed
   copy        — Explicitly copies a noncopyable value

 NONCOPYABLE TYPES (~Copyable):
   struct UniqueHandle: ~Copyable {
       var id: Int
   }

   // This struct CANNOT be copied — only moved.
   // Prevents accidental duplication of unique resources.

 CONSUMING PARAMETERS:
   func process(_ data: consuming MyData) {
       // Takes ownership; caller can no longer use 'data'
   }

 BORROWING PARAMETERS:
   func inspect(_ data: borrowing MyData) {
       // Read-only access; no ownership transfer, no copy
   }

 MOVE OPERATOR (consume):
   var source = MyData()
   let dest = consume source  // source is now invalid
   // using source here would be a compile error

 WHY IT MATTERS:
   - Eliminates hidden/unexpected copies
   - Enables move semantics for performance-critical code
   - Allows types like file handles to guarantee single ownership
   - Provides compile-time guarantees about value lifetimes

 SE-0390: Noncopyable structs and enums
 SE-0377: borrowing and consuming parameter ownership modifiers
 SE-0366: consume operator to end the lifetime of a variable binding
 SE-0458: Strict memory safety opt-in flag (-strict-memory-safety)

 -----------------------------------------------------------------------
 L. CONCURRENCY & MEMORY SAFETY
 -----------------------------------------------------------------------

 SWIFT 6 — STRICT CONCURRENCY:
   - Data race safety is enforced at COMPILE TIME
   - Every value passed across concurrency boundaries must be Sendable
   - Non-Sendable types cannot cross actor isolation boundaries

 SENDABLE:
   // Sendable = safe to share across concurrency domains
   struct Config: Sendable {
       let apiKey: String   // immutable → safe
       let timeout: Int
   }

 ACTORS:
   - Actors serialize access to their mutable state
   - No two concurrent tasks can access an actor's state simultaneously
   - Swift compiler enforces actor isolation

   actor BankAccount {
       var balance: Double = 0

       func deposit(_ amount: Double) {
           balance += amount  // safe — only one task at a time
       }
   }

   let account = BankAccount()
   await account.deposit(100)  // must await actor access

 @MainActor:
   @MainActor
   class ViewModel {
       var title: String = ""  // always accessed on main thread
   }

 TASK ISOLATION:
   // Value types are safe across tasks because they're copied
   func process() async {
       let numbers = [1, 2, 3, 4]
       async let result = Task {
           return numbers.map { $0 * 2 }
           // 'numbers' is safely copied into the task
       }
   }

 -----------------------------------------------------------------------
 M. DEBUGGING TOOLS
 -----------------------------------------------------------------------

 1. THREAD SANITIZER (TSan)
    - Detects data races in multi-threaded code
    - Enable in Xcode: Edit Scheme → Diagnostics → Thread Sanitizer
    - Works at runtime; catches overlapping accesses across threads

 2. ADDRESS SANITIZER (ASan)
    - Detects memory access violations
    - Buffer overflows, use-after-free, etc.
    - Enable in Xcode: Edit Scheme → Diagnostics → Address Sanitizer

 3. INSTRUMENTS
    - Leaks template: finds memory leaks (unreleased objects)
    - Allocations template: tracks all memory allocations over time
    - Profile in Xcode: Product → Profile → Choose template

 4. XCODE MEMORY GRAPH DEBUGGER
    - Visual graph of all live objects and their reference counts
    - Helps identify retain cycles

 5. -strict-memory-safety COMPILER FLAG (SE-0458, Swift 6)
    - Opt-in module-level flag
    - Emits warnings for ALL uses of unsafe constructs
    - swiftc -strict-memory-safety MyFile.swift

 =======================================================================
 PART 2: 100 INTERVIEW Q&A
 =======================================================================

 ------------------------------------------------------------
 SECTION 1: BASIC QUESTIONS (Q1–Q25)
 ------------------------------------------------------------

 Q1. What is memory safety in Swift?
 A: Memory safety means Swift prevents code from accessing memory
    in undefined, incorrect, or conflicting ways. It ensures
    variables are initialized before use, memory is managed
    automatically via ARC, arrays are bounds-checked, and
    conflicting memory accesses are detected at compile or
    runtime.

 ---

 Q2. What is ARC and how does it contribute to memory safety?
 A: ARC (Automatic Reference Counting) automatically tracks
    how many references exist to a class instance. When the
    count reaches zero, the instance is deallocated. This
    prevents memory leaks and use-after-free bugs without
    requiring manual memory management.

 ---

 Q3. What is the difference between a value type and a reference type in Swift?
 A: Value types (struct, enum) store unique copies of data. Each
    assignment or function call creates an independent copy.
    Reference types (class) store a reference to a shared
    instance in memory. Multiple variables can point to the
    same object.

 ---

 Q4. Which Swift types are value types?
 A: struct, enum, Int, Double, Float, Bool, String, Array,
    Dictionary, Set, tuples, and other built-in primitives.

 ---

 Q5. What is the mutating keyword used for?
 A: It marks a method on a value type (struct or enum) as one
    that will modify self. Without it, the compiler treats
    self as immutable inside the method.

 ---

 Q6. Can you call a mutating method on a let constant?
 A: No. let constants are immutable, so calling mutating methods
    on them produces a compile error:
    "Cannot use mutating member on immutable value."

 ---

 Q7. What is an inout parameter?
 A: An inout parameter allows a function to modify the caller's
    variable. The variable is passed with &, the function
    modifies it, and changes are written back after the
    function returns.

 ---

 Q8. What symbol is used to pass a variable as inout?
 A: The ampersand (&) prefix:   functionName(&myVariable)

 ---

 Q9. Can you pass a constant (let) as an inout parameter?
 A: No. inout requires a mutable variable (var). Passing a
    constant or literal causes a compile error.

 ---

 Q10. What is Copy-on-Write (CoW)?
 A: CoW is an optimization where two variables that share the
    same value type's underlying storage only make a copy when
    one of them is about to be mutated. If no mutation occurs,
    they continue sharing storage, saving memory and time.

 ---

 Q11. Which standard Swift types use Copy-on-Write?
 A: Array, Dictionary, Set, and String all use CoW internally.

 ---

 Q12. What is an access conflict in Swift?
 A: A memory access conflict occurs when two accesses to the
    same memory location overlap in time, and at least one of
    them is a write access.

 ---

 Q13. What are the three conditions required for a memory access conflict?
 A:
   1. At least one access is a write (or non-atomic)
   2. Both accesses target the same memory location
   3. Their durations overlap in time

 ---

 Q14. What is instantaneous memory access?
 A: An access that completes atomically with no other code
    running between its start and end. Most simple reads and
    writes are instantaneous. Two instantaneous accesses cannot
    conflict.

 ---

 Q15. What is long-term memory access?
 A: An access whose duration spans the execution of other code.
    Other code can run between when it starts and when it ends.
    inout parameters and mutating methods create long-term accesses.

 ---

 Q16. When was the Exclusivity Rule introduced in Swift?
 A: It was introduced with Swift 4 (SE-0176) and enabled by
    default in Release builds starting with Swift 5.

 ---

 Q17. What happens when a memory access conflict is detected in Swift?
 A: In single-threaded code, Swift either catches it at compile
    time (error) or triggers a runtime trap (crash with
    "simultaneous accesses" message). In multithreaded code,
    Thread Sanitizer is needed to detect conflicts.

 ---

 Q18. Can access conflicts happen on a single thread?
 A: Yes. Access conflicts are not exclusively a multithreading
    problem. A single thread can have overlapping accesses,
    for example via inout parameters accessing the same variable.

 ---

 Q19. What is the difference between struct and class regarding memory?
 A: struct (value type) — copied on assignment, each variable
    has independent storage.
    class (reference type) — shared via reference, multiple
    variables can point to the same object in memory.

 ---

 Q20. What is a retain cycle and how can you avoid it?
 A: A retain cycle occurs when two class instances hold strong
    references to each other, preventing ARC from deallocating
    either. Avoid with weak or unowned references.

    class A { var b: B? }
    class B { weak var a: A? }   // weak breaks the cycle

 ---

 Q21. What is weak vs unowned reference?
 A:
   weak   — Optional reference, automatically set to nil when
             the referenced object is deallocated.
   unowned — Non-optional reference, assumes the object always
             exists while the reference is used. Crashes if
             accessed after deallocation.

 ---

 Q22. Does passing a value type to a function create a copy?
 A: Conceptually yes — each function parameter gets its own
    copy of the value. In practice, the compiler may optimize
    this away if it can prove the original won't be modified.
    With inout, the parameter references the original.

 ---

 Q23. Why are value types safer for concurrency?
 A: Because each task/thread works on its own copy of the data.
    One task cannot mutate another task's copy, eliminating
    data races by design.

 ---

 Q24. What tool in Xcode detects data races at runtime?
 A: Thread Sanitizer (TSan).
    Enabled via: Edit Scheme → Diagnostics → Thread Sanitizer.

 ---

 Q25. What tool in Xcode detects memory leaks?
 A: Instruments with the Leaks template.
    Also: the Memory Graph Debugger in Xcode debugger toolbar.

 ------------------------------------------------------------
 SECTION 2: INTERMEDIATE QUESTIONS (Q26–Q65)
 ------------------------------------------------------------

 Q26. Why does passing the same variable to two inout parameters cause an error?
 A: It creates two simultaneous write accesses to the same
    memory location, violating the exclusivity rule.

    func balance(_ x: inout Int, _ y: inout Int) { ... }
    var n = 5
    balance(&n, &n)   // ERROR

 ---

 Q27. Explain why this code produces an error:
      var stepSize = 1
      func increment(_ number: inout Int) {
          number += stepSize
      }
      increment(&stepSize)

 A: When increment(&stepSize) is called, Swift establishes a
    long-term write access to stepSize (via inout). Inside the
    function, reading stepSize for the addition creates a
    simultaneous read access. This overlaps with the write,
    violating exclusive access.

    FIX:
    let localStep = stepSize   // capture a local copy
    increment(&stepSize)
    // or: avoid referencing stepSize inside the function

 ---

 Q28. What is the fix for the self-conflict in mutating methods?
 A: Use separate instances. A mutating method holds long-term
    write access to self, so passing self to an inout parameter
    of that same method conflicts.

    // Instead of oscar.shareHealth(with: &oscar)
    var teammate = Player(name: "Bob", health: 50)
    oscar.shareHealth(with: &teammate)

 ---

 Q29. Why can't you capture an inout parameter in an escaping closure?
 A: The inout parameter's write access ends when the function
    returns. An escaping closure could be called after the
    function returns, accessing memory that is no longer
    validly "in scope" for writing. Swift prevents this
    at compile time.

 ---

 Q30. Is inout the same as pass-by-reference?
 A: Semantically no — the formal model is copy-in copy-out.
    Practically, the compiler may implement it as pass-by-
    reference as an optimization, but the programmer should
    reason using copy-in-copy-out semantics.

 ---

 Q31. What happens to the original value if a function with inout throws an error?
 A: If an inout function throws, the copy-out step does NOT
    happen — the original variable retains its value from
    before the call. The modified local copy is discarded.

 ---

 Q32. When exactly does the write-back (copy-out) happen for inout?
 A: At the point of normal function return. The modified local
    copy is written back to the original variable. If the
    function exits abnormally (throw, trap), write-back may
    not occur.

 ---

 Q33. Can you pass a computed property as inout?
 A: Only if the property has both a getter AND a setter.
    For computed properties with a setter, Swift uses copy-in
    copy-out to read the current value, let the function modify
    it, and write it back via the setter.
    Read-only computed properties cannot be passed as inout.

 ---

 Q34. Can you implement CoW in a custom struct?
 A: Yes. You use a class as the internal storage holder and
    check isKnownUniquelyReferenced before mutating.
    If the reference is shared, copy the storage first.

    struct MyArray {
        private var storage: ArrayStorage
        mutating func append(_ value: Int) {
            if !isKnownUniquelyReferenced(&storage) {
                storage = storage.copy()
            }
            storage.buffer.append(value)
        }
    }

 ---

 Q35. What is isKnownUniquelyReferenced?
 A: A Swift standard library function that returns true if a
    given object has exactly one strong reference (i.e., it is
    exclusively owned). Used to implement CoW in custom types.
    Note: only works on Swift-native class types, not ObjC.

 ---

 Q36. What is the performance implication of CoW when modifying an array in a loop?
 A: If the array is uniquely referenced, mutations are O(1)
    amortized. If the array is shared (e.g., copied into
    another variable), each mutation triggers a full O(n) copy
    first. To avoid this, ensure unique ownership before loops.

 ---

 Q37. How does Swift know if two accesses overlap in time?
 A: The compiler (for static cases) or the runtime exclusivity
    checker tracks the start and end of long-term accesses.
    When a new access starts, it checks if any conflicting
    long-term access is already active.

 ---

 Q38. How do actors prevent data races?
 A: Actors serialize access to their mutable state. Only one
    task can execute actor-isolated code at a time. The compiler
    enforces that external access to actor state goes through
    await calls, which schedule on the actor's executor.

 ---

 Q39. What is the Sendable protocol?
 A: Sendable marks a type as safe to share across concurrency
    boundaries (e.g., between actors or tasks). A type is
    Sendable if it has no shared mutable state.
    Examples: value types with all-Sendable properties,
    immutable classes, @unchecked Sendable (manual safety).

 ---

 Q40. Can a struct with a class property be Sendable?
 A: Only if the class property is also Sendable (e.g., immutable
    class or Sendable class). If the class property is mutable
    and non-Sendable, the struct is not automatically Sendable.

 ---

 Q41. What is @unchecked Sendable?
 A: It is a way to declare Sendable conformance when the
    programmer guarantees safety (e.g., via locks or serialized
    access) but the compiler cannot verify it automatically.
    Using it opts out of compiler checks — use cautiously.

 ---

 Q42. Explain the difference between weak and unowned with an example.
 A:
    class Owner {
        var pet: Pet?
    }
    class Pet {
        weak var owner: Owner?      // Optional, set to nil on dealloc
        // unowned var owner: Owner! // Non-optional; crash if dealloc'd
    }

    Use weak when the referenced object can become nil.
    Use unowned when you're certain the object lives as long
    as the reference.

 ---

 Q43. What is a memory leak in Swift and how does ARC cause them?
 A: A memory leak happens when objects are allocated but never
    deallocated. In ARC, this occurs when two objects hold
    strong references to each other (retain cycle), preventing
    the reference count from reaching zero.

 ---

 Q44. How does Swift 6 strict concurrency affect memory safety?
 A: Swift 6 makes data race safety a compile-time guarantee.
    All values crossing concurrency boundaries must be Sendable.
    Non-Sendable types are isolated to their actor or task.
    This eliminates entire categories of runtime memory bugs.

 ---

 Q45. Can a struct property cause an access conflict?
 A: Yes. Accessing two properties of a struct stored in global
    or instance storage via inout simultaneously can conflict,
    because the compiler treats the whole struct's memory as
    one unit for exclusivity purposes.

    // Safe: local struct variable
    var point = (x: 1, y: 2)
    swap(&point.x, &point.y)   // OK for local vars

    // Unsafe: global or stored property
    // May conflict for global or stored vars

 ---

 Q46. What is structured concurrency?
 A: Structured concurrency (introduced in Swift 5.5) ensures
    that child tasks are always awaited before their parent
    scope exits. This prevents dangling references and ensures
    memory captured by tasks is valid for the task's lifetime.

    async let a = fetchData()
    async let b = fetchMore()
    let results = await (a, b)  // both awaited before continuing

 ---

 Q47. What happens if you access an array out of bounds in Swift?
 A: Swift performs bounds checking at runtime and traps (crashes)
    with a "Index out of range" error. This is intentional —
    Swift never allows undefined behavior from out-of-bounds
    access, unlike C/C++.

 ---

 Q48. Can enums with associated values cause memory issues?
 A: Generally no — enum associated values are value types.
    However, if an associated value is a reference type (class),
    normal ARC rules apply and retain cycles are possible.

 ---

 Q49. What is the @noescape attribute and why does it matter for inout?
 A: @noescape (now the default for function parameters) means
    the closure won't outlive the function call. This allows
    inout parameters to be safely captured by non-escaping
    closures because the closure won't be called after the
    inout's write access has ended.

 ---

 Q50. Explain what happens in memory when you append to an Array.
 A:
   1. Swift checks if the array's buffer is uniquely referenced
   2. If yes and there's capacity: append in place (O(1))
   3. If yes but no capacity: allocate new buffer (2x size),
      copy elements, append (amortized O(1))
   4. If shared (CoW): first copy the buffer (O(n)), then append

 ---

 Q51. What is the difference between heap and stack in Swift?
 A:
   Stack: Fast LIFO memory. Value types (structs, enums,
          primitives) are typically stored here. Automatic
          cleanup when scope exits.
   Heap:  Dynamic, slower. Reference types (classes) live here.
          ARC manages lifetime.

   Note: Large value types or those captured by closures may
   be placed on the heap.

 ---

 Q52. Can a value type contain a reference type?
 A: Yes. A struct can have a class property. In this case,
    copying the struct copies the reference, not the underlying
    object. Both struct copies point to the same class instance.
    This is called a "shallow copy."

    struct Container {
        var obj: SomeClass   // both copies share this instance
    }

 ---

 Q53. How does the withUnsafeMutablePointer function relate to memory safety?
 A: It provides a raw pointer to a value for use with unsafe
    code (e.g., C interop). The closure receives an
    UnsafeMutablePointer. This BYPASSES Swift's safety
    guarantees — misuse can cause crashes or corruption.
    The -strict-memory-safety flag will warn about uses of this.

 ---

 Q54. What is the memory layout of a Swift struct?
 A: Struct properties are laid out contiguously in memory.
    The compiler may add padding for alignment. No object
    header is needed (unlike classes). The total size is the
    sum of all properties' sizes plus alignment padding.

 ---

 Q55. Why does Swift use ARC instead of garbage collection?
 A:
   - ARC is deterministic: objects are freed immediately when
     reference count hits zero.
   - No GC pause times affecting UI.
   - Lower memory overhead (no GC heap metadata).
   - Better for real-time systems (games, audio, etc.).

 ---

 Q56. What is the difference between strong, weak, and unowned in ARC?
 A:
   strong  — Increments reference count. Default.
   weak    — Does NOT increment ref count. Optional. Nil on dealloc.
   unowned — Does NOT increment ref count. Non-optional.
             Assumes object lives as long as the reference.
             Crash if accessed after dealloc.

 ---

 Q57. Can tuples cause memory access conflicts?
 A: Yes, similar to structs. Passing tuple elements as inout
    parameters simultaneously can conflict if the tuple is
    stored (not local). Local tuples can sometimes be optimized
    by the compiler to allow simultaneous property access.

 ---

 Q58. What is -O (whole-module optimization) and how does it relate to CoW?
 A: With whole-module optimization, the compiler can prove
    uniqueness of references across module boundaries, allowing
    it to eliminate CoW copies that would otherwise be needed.
    This makes CoW effectively free in many real-world scenarios.

 ---

 Q59. How does Swift ensure initialization safety?
 A: The compiler performs definite initialization analysis.
    It tracks all code paths and ensures every variable is
    written before it is read. If any code path leaves a
    variable uninitialized before use, it's a compile error.

 ---

 Q60. What is the relationship between CoW and memory exclusivity?
 A: They work together. CoW lazily defers copies until mutation
    is needed. The exclusivity rule then ensures that once
    mutation begins, it has exclusive access. Together they
    provide both performance (CoW) and safety (exclusivity).

 ---

 Q61. What is deinit and how does it relate to memory safety?
 A: deinit is called when a class instance's ARC count reaches
    zero, just before deallocation. It allows cleanup of
    resources (file handles, observers). Proper deinit prevents
    resource leaks beyond just memory.

    class ResourceHolder {
        deinit {
            cleanup()  // guaranteed to run before deallocation
        }
    }

 ---

 Q62. What does withExtendedLifetime do?
 A: It ensures an object remains alive (ARC count > 0) for
    the duration of a closure. Used when the optimizer might
    prematurely deallocate an object before a dependent
    operation completes.

    withExtendedLifetime(myObject) {
        performUnsafeOperation(myObject)
    }

 ---

 Q63. What is a dangling pointer and how does Swift prevent it?
 A: A dangling pointer refers to memory that has already been
    freed. Swift prevents this with:
    - ARC (objects live as long as strong references exist)
    - Exclusivity rule (no access after value is invalidated)
    - Bounded lifetimes for unsafe pointers (withUnsafePointer)

 ---

 Q64. How does Swift handle memory for closures that capture variables?
 A: Closures capture variables by reference (for reference
    types) or by value (for value types, using [value] capture
    list). Captured reference types are retained by the closure,
    potentially causing retain cycles if not using [weak self].

    class VC {
        var onAction: (() -> Void)?
        func setup() {
            onAction = { [weak self] in
                self?.handleAction()  // safe — no retain cycle
            }
        }
    }

 ---

 Q65. What is the @discardableResult attribute and how is it related to memory?
 A: @discardableResult suppresses the compiler warning when a
    function's return value is not used. Indirectly, ignoring
    a returned reference can affect object lifetimes — if you
    ignore the return, ARC may immediately deallocate the object.

 ------------------------------------------------------------
 SECTION 3: HARD / ADVANCED QUESTIONS (Q66–Q100)
 ------------------------------------------------------------

 Q66. Can the Swift compiler prove the absence of data races at compile time in Swift 6?
 A: Yes, within the limits of the actor model. Swift 6's strict
    concurrency checking verifies at compile time that:
    - All values crossing actor/task boundaries are Sendable
    - Actor-isolated state is only accessed with await
    - Non-Sendable values don't escape their isolation domain
    It cannot prove safety for @unchecked Sendable or unsafe code.

 ---

 Q67. Explain the "law of exclusivity" in terms of the Swift ownership manifesto.
 A: The ownership manifesto (basis for SE-0176) states that at
    any point in execution, a variable has exactly ONE of:
    - Many simultaneous immutable borrows (reads), OR
    - Exactly ONE mutable borrow (write)
    These are mutually exclusive. This mirrors read-write lock
    semantics but enforced statically/dynamically by the compiler.

 ---

 Q68. What is the difference between noncopyable types and move-only types?
 A: They refer to the same concept in Swift. A type marked
    ~Copyable (or conforming to ~Copyable) cannot be copied —
    it can only be "consumed" (moved). After consumption, the
    original binding is invalid.

    struct UniqueResource: ~Copyable {
        var handle: Int
    }
    var r1 = UniqueResource(handle: 1)
    let r2 = consume r1   // r1 is now invalid
    // using r1 here = compile error

 ---

 Q69. How does the consume operator interact with if-else branches?
 A: After a consume, the variable is considered "partially
    initialized" or "consumed." The compiler enforces that you
    don't use the consumed binding in any branch. You can re-
    initialize it:

    var x = MyNoncopyable()
    let y = consume x
    x = MyNoncopyable()  // re-initialize — now valid again
    use(x)

 ---

 Q70. What happens to inout parameters during a thrown error in a try/catch context?
 A: If a function with inout parameters throws, the write-back
    (copy-out) does NOT occur. The inout variable retains its
    original value from before the function call. This is the
    defined behavior for copy-in copy-out semantics.

 ---

 Q71. Can you have an inout parameter in an async function?
 A: Yes, but with important restrictions. The inout parameter
    establishes a long-term write access for the entire async
    function's execution. The original variable remains
    "locked for writing" across all await suspension points,
    which can cause conflicts with other concurrent accesses.
    Best practice: avoid inout in async functions; prefer
    returning new values.

 ---

 Q72. What is the @_semantics("array.mutate_unknown") annotation and how does it relate to CoW?
 A: This is an internal Swift stdlib annotation used to tell
    the optimizer that an array mutation may have unknown
    effects (e.g., it might call user code). This prevents
    the optimizer from incorrectly eliding CoW copies. It's
    a low-level implementation detail of how stdlib guarantees
    CoW correctness under optimization.

 ---

 Q73. Explain how the Swift runtime implements the exclusivity runtime check.
 A: Swift maintains a per-thread stack (or thread-local storage)
    of currently active long-term accesses. Each access is
    described by: (memory address, access type, source location).
    When a new long-term access starts, the runtime scans
    existing active accesses for conflicts. If found, it traps.
    The check is O(active accesses) per access start/end.

 ---

 Q74. What is the -enforce-exclusivity compiler flag?
 A: Controls when the exclusivity rule is enforced:
    - unchecked: no runtime checking (unsafe, maximum performance)
    - checked: runtime checking enabled (default for Release)
    - The compile-time checks are always performed regardless.
    Used as: -enforce-exclusivity=checked

 ---

 Q75. Explain how CoW interacts with the exclusivity rule when an array is passed as inout.
 A: When you pass an Array as inout:
    1. Swift establishes long-term write access on the Array variable
    2. Inside the function, any mutation of the array triggers
       CoW if the buffer is shared
    3. The exclusivity check prevents the original array from
       being accessed (read or write) while the inout is active
    4. CoW happens at the buffer level; exclusivity happens at
       the variable level — they operate at different layers

 ---

 Q76. What is the difference between withUnsafeBytes and withUnsafeBufferPointer?
 A:
   withUnsafeBytes: Provides raw byte access to a value's
                    memory representation. Used for binary
                    serialization, hashing, etc.
   withUnsafeBufferPointer: Provides typed pointer access to
                            a contiguous collection's storage.
                            Used for performance-critical iteration.
   Both are unsafe — violating their usage rules causes UB.

 ---

 Q77. How does Swift prevent use-after-free for value types?
 A: Value types stored on the stack are automatically
    deallocated when their scope exits. The compiler's definite
    initialization and scope analysis ensures:
    - Variables are initialized before use
    - Bindings are invalidated after consume
    - No pointer to stack memory escapes the scope
    There's no way to get a dangling pointer to a value type
    without using explicitly unsafe APIs.

 ---

 Q78. What is the "overlapping access to a captured variable" error?
 A: This occurs when a closure captures a variable that is also
    being accessed as inout by the surrounding scope.

    var total = 0
    func compute(_ n: inout Int, action: () -> Void) {
        n += 1
        action()
    }
    compute(&total) {
        print(total)  // ERROR: reading 'total' while it's inout
    }

    FIX: Capture a copy in the closure:
    compute(&total) { [total] in print(total) }

 ---

 Q79. Can actors have inout parameters?
 A: Actor-isolated functions can technically have inout parameters,
    but the combination is very restrictive. The inout parameter
    creates a long-term write access, and any await inside the
    function creates a suspension point. The combination means
    the variable being passed as inout is locked during potentially
    long async operations. In practice, avoid inout in actor
    functions.

 ---

 Q80. What is the copy() method on noncopyable types?
 A: The copy keyword (SE-0390) explicitly copies a value that
    would otherwise be consumed. It is only available on types
    that conform to both Copyable (the default) and is used
    to explicitly mark a point where a copy is made.
    For ~Copyable types, copy is not available — which is the
    whole point.

 ---

 Q81. Explain "triviality" in Swift's memory model.
 A: A type is "trivially copyable" (trivial) if it can be
    copied just by copying its bytes, with no additional logic.
    Types like Int, Double, Bool are trivial. Swift can use
    memcpy-level operations for trivial types, avoiding
    ARC operations. Non-trivial types have copy constructors
    (for CoW) or reference counting (for classes).

 ---

 Q82. What is the difference between memory safety and type safety in Swift?
 A:
   Memory safety: Prevents accessing memory at wrong addresses,
                  out of bounds, after deallocation, or with
                  conflicting accesses.
   Type safety:   Prevents interpreting memory using the wrong
                  type. A value of type Int cannot be treated as
                  a String without explicit conversion.
   Both work together: Swift's type system prevents many memory
   errors by making invalid operations unrepresentable.

 ---

 Q83. How does the @inline(never) attribute relate to memory access?
 A: Prevents the compiler from inlining a function. This can
    affect exclusivity checking — when a function is inlined,
    the compiler has more context to prove accesses are safe.
    With @inline(never), the compiler must be more conservative
    and may require runtime checks that could otherwise be
    eliminated.

 ---

 Q84. What is "source stability" in the context of Swift's memory model changes?
 A: Swift maintains ABI and source stability for APIs. For the
    ownership model, this means new modifiers (consuming,
    borrowing) are additive and do not break existing code.
    The default behavior (unmarked parameters are implicitly
    borrowing/copying) maintains backward compatibility.

 ---

 Q85. When does Swift generate a "simultaneous accesses" runtime error vs a compile-time error?
 A:
   Compile-time: When the compiler can statically prove a
                 conflict will occur (e.g., same variable to
                 two inout parameters in the same call site).
   Runtime:      When the conflict depends on runtime values
                 (e.g., inout inside a recursion or when
                 aliasing is not statically provable).

 ---

 Q86. Explain the memory implications of using value types in an Objective-C bridged context.
 A: When Swift value types cross the ObjC bridge, they are
    "boxed" into heap objects. This:
    - Introduces heap allocation
    - May trigger CoW copies
    - Interacts with ObjC's retain/release, not Swift's ARC
    The exclusivity guarantees still apply on the Swift side,
    but the boxing creates reference-type semantics for ObjC.

 ---

 Q87. What is the difference between @escaping and non-escaping closures from a memory perspective?
 A: Non-escaping closures:
    - Cannot outlive the function call
    - Stack-allocated (no heap closure context needed)
    - Can capture inout parameters safely
    - Can access local variables without ARC overhead
   
    Escaping closures:
    - Can outlive the function call
    - Heap-allocated closure context
    - Must strongly retain (or weakly reference) captured vars
    - Cannot capture inout parameters

 ---

 Q88. What is unmanaged<T> and when is it used?
 A: Unmanaged<T> allows you to work with objects without ARC
    managing them. It's used for C APIs that return raw object
    pointers (Core Foundation, etc.) with manual retain/release.

    let obj = Unmanaged.passRetained(myObject)
    // ARC does NOT track this
    // Must call .release() or .takeRetainedValue() manually

 ---

 Q89. How does the optimizer eliminate CoW copies in practice?
 A: Through techniques like:
    1. Stack promotion: storing objects on the stack when the
       compiler proves they don't escape
    2. Uniqueness analysis: proving a reference is unique,
       allowing in-place mutation
    3. Dead store elimination: removing copies whose results
       are never read
    4. Whole-module optimization: cross-function uniqueness proof

 ---

 Q90. What is contiguous memory access and why does it matter for performance?
 A: Contiguous memory means elements are stored in adjacent
    memory locations (like C arrays). This maximizes CPU
    cache utilization. Swift's Array guarantees contiguous
    storage. withContiguousStorageIfAvailable() provides
    temporary guaranteed-contiguous access to collections
    that may not normally guarantee it (like ArraySlice).

 ---

 Q91. Explain how Swift's memory model handles recursive data structures.
 A: Recursive value types (struct A { var child: A }) are
    impossible because the size would be infinite. Swift
    requires an indirection using a reference type:
    struct A { var child: Box<A>? }
    class Box<T> { var value: T }
    Or using indirect enum:
    indirect enum Tree { case leaf; case node(Tree, Tree) }
    The indirect keyword wraps associated values in a heap box.

 ---

 Q92. What is the SE-0458 "-strict-memory-safety" flag and what does it catch?
 A: SE-0458 (introduced January 2025) adds an opt-in compiler
    flag that emits warnings for all uses of:
    - Unsafe types (UnsafePointer, UnsafeRawPointer, etc.)
    - Unsafe functions (withUnsafeBytes, etc.)
    - Types/operations bridging to C with unsafe semantics
    - @unchecked Sendable declarations
    Enables gradual adoption of stricter safety standards
    per module.

 ---

 Q93. How does the exclusive access rule interact with property wrappers?
 A: Property wrappers can complicate exclusivity. When you
    access a wrapped property, the getter/setter of the wrapper
    is invoked. If the wrapper's storage (the _projectedValue
    or _wrappedValue) is accessed via inout simultaneously,
    it can create access conflicts.
    The compiler tracks accesses to the underlying storage,
    not just the sugar syntax.

 ---

 Q94. What are the memory implications of using @propertyWrapper with a class backing?
 A: If a property wrapper uses a class as its storage, copying
    the wrapper copies the reference, not the underlying data.
    This breaks value-type semantics. The wrapper appears to
    behave like a value type but shares state.
    Best practice: use a struct or CoW class as wrapper storage.

 ---

 Q95. How does Swift's memory model handle large value types vs small ones differently?
 A: The compiler

 */
