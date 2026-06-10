import UIKit

/*
 
 =======================================================================
   SWIFT — ARC, STRONG CYCLES, WEAK & UNOWNED REFERENCES
   Complete Study Notes + 100 Interview Q&A (Including Hard Questions)
 =======================================================================

 TABLE OF CONTENTS
 -----------------
 PART 1: AUTOMATIC REFERENCE COUNTING (ARC)
   A. What is ARC?
   B. How ARC Works — Step by Step
   C. Runtime Mechanics — The Object Header
   D. Strong References — The Default
   E. ARC and Closures
   F. ARC in Multi-Threaded Contexts
   G. ARC vs Garbage Collection
   H. Swift 5.9+ Ownership Additions

 PART 2: STRONG REFERENCE CYCLES
   A. What is a Strong Reference Cycle?
   B. How Cycles Form — Mechanics
   C. Class-to-Class Cycles
   D. Class-to-Closure Cycles (Capture Lists)
   E. Three-Node and Complex Cycles
   F. Detecting Cycles — Tools
   G. Consequences of Retain Cycles

 PART 3: WEAK REFERENCES
   A. What is a Weak Reference?
   B. Zeroing Mechanics — How weak nil-ing Works
   C. Rules and Restrictions for weak
   D. When to Use weak
   E. weak in Delegates, Closures, Collections
   F. weak in Protocols
   G. Swift 5.7+ any & weak

 PART 4: UNOWNED REFERENCES
   A. What is an Unowned Reference?
   B. unowned vs weak — Full Comparison
   C. unowned Safe vs unowned(unsafe)
   D. unowned in Closures
   E. unowned + Lifetime Guarantees
   F. unowned(unsafe) — When and Why
   G. Common Crash Scenarios

 PART 5: SIDE-BY-SIDE COMPARISON TABLE

 PART 6: 100 INTERVIEW Q&A
   - Basic        (Q1–Q25)
   - Intermediate (Q26–Q65)
   - Hard/Advanced (Q66–Q100)

 =======================================================================
 PART 1: AUTOMATIC REFERENCE COUNTING (ARC)
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS ARC?
 -----------------------------------------------------------------------
 ARC (Automatic Reference Counting) is Swift's (and Obj-C's)
 memory management strategy. It automatically tracks how many
 STRONG references point to each class instance and frees
 the instance's memory when that count reaches zero.

 KEY FACTS:
   - Applies ONLY to reference types (class instances, closures)
   - Value types (struct, enum) do NOT use ARC
   - Deterministic: objects are freed IMMEDIATELY when count = 0
   - Compile-time driven: the Swift compiler inserts retain/release
     calls at compile time — not at runtime like a GC
   - No stop-the-world pauses (unlike Garbage Collection)
   - Thread-safe: reference counting operations are atomic

 WHAT ARC MANAGES:
   ✓ class instances
   ✓ closures (function objects stored on the heap)
   ✓ Any protocol type backed by a class
   ✗ struct instances (stack-allocated, no ARC needed)
   ✗ enum cases (value semantics)
   ✗ primitive types (Int, Double, Bool, etc.)

 -----------------------------------------------------------------------
 B. HOW ARC WORKS — STEP BY STEP
 -----------------------------------------------------------------------

 STEP 1 — ALLOCATION:
   When a class instance is created with init(), Swift:
   1. Allocates heap memory for the instance
   2. Initializes the object header (see Part 1C)
   3. Sets the initial reference count to 1
   4. Calls the designated initializer

 STEP 2 — RETAIN (increment count):
   Every time a new strong reference is created:
   - Assigning to a var/let
   - Passing to a function
   - Capturing in a closure (without [weak] or [unowned])
   Swift calls swift_retain() which atomically increments
   the reference count by 1.

 STEP 3 — RELEASE (decrement count):
   Every time a strong reference goes out of scope:
   - Function returns (local var released)
   - Variable is reassigned
   - Object containing the reference is deallocated
   Swift calls swift_release() which atomically decrements
   the reference count by 1.

 STEP 4 — DEALLOCATION:
   When reference count reaches 0:
   1. swift_release() detects count == 0
   2. deinit() is called on the instance
   3. All stored properties are released
      (if properties hold references, THEIR counts decrement)
   4. Memory is freed back to the heap allocator

 EXAMPLE — counting references:
   class Person {
       let name: String
       init(_ name: String) { self.name = name }
       deinit { print("\(name) is being deallocated") }
   }

   // Count = 0 (no instance yet)
   var ref1: Person? = Person("Alice")  // Count = 1
   var ref2 = ref1                      // Count = 2
   var ref3 = ref1                      // Count = 3

   ref1 = nil                           // Count = 2
   ref2 = nil                           // Count = 1
   ref3 = nil                           // Count = 0 → deinit called
   // Prints: "Alice is being deallocated"

 COMPILE-TIME INSERTION:
   The Swift compiler analyzes ownership at compile time
   and inserts retain/release calls in the generated code:

   // Swift source:
   func greet(_ person: Person) {
       print(person.name)
   }

   // Compiler-generated pseudo-code:
   func greet(_ person: Person) {
       swift_retain(person)         // entering scope
       print(person.name)
       swift_release(person)        // exiting scope
   }

 -----------------------------------------------------------------------
 C. RUNTIME MECHANICS — THE OBJECT HEADER
 -----------------------------------------------------------------------
 Every heap-allocated Swift class instance has a 16-byte header
 consisting of TWO 8-byte words:

 WORD 1: ISA POINTER (8 bytes)
   - Points to the class's type metadata
   - Contains the class's method table (vtable)
   - Used for dynamic dispatch and type checking
   - On 64-bit systems, some bits encode flags

 WORD 2: REFERENCE COUNT WORD (8 bytes)
   Encodes THREE separate counts in one 64-bit integer:

   ┌─────────────────────────────────────────────────────────┐
   │  Strong RC  │  Unowned RC  │  Weak RC  │  Flags/State  │
   └─────────────────────────────────────────────────────────┘

   STRONG COUNT:
     Number of strong references. When reaches 0:
     → deinit() is called
     → object's body is freed
     → unowned count decremented by 1 (see below)

   UNOWNED COUNT:
     Number of unowned references + 1 (the +1 keeps the
     SIDE TABLE alive while strong count > 0).
     When reaches 0:
     → The object's HEADER memory is freed
     → (Body already freed when strong count hit 0)

   WEAK COUNT:
     Stored in a SIDE TABLE (separate heap allocation).
     Created lazily when the first weak reference is made.
     Tracks weak references.
     When object is deallocated (strong = 0):
     → All weak references atomically zeroed to nil
     → Side table entry preserved until weak count = 0
     → Side table memory freed when weak count = 0

 SIDE TABLE:
   A separate small heap allocation created when:
   - The first weak reference to an object is created
   - The object stores extra metadata

   The side table contains:
   - Pointer back to the object
   - Weak reference count
   - Object flags (deiniting, deallocating, etc.)

   weak var reference: SomeClass?
   // Stores POINTER TO SIDE TABLE, not to object directly
   // Side table allows zeroing even if object header is freed

 TWO-PHASE DEALLOCATION:
   Phase 1 (Strong count → 0):
     - deinit() called
     - Object's instance data (properties) released
     - Object body memory freed
     - Object transitions to DEAD state in side table
     - Weak references see this → zeroed to nil

   Phase 2 (Unowned count → 0, after Phase 1):
     - Object header memory freed
     - Side table entry freed (if no more weak refs)

 OBJECT STATES (in side table flags):
   live            — normal, strong count > 0
   deiniting       — deinit() is currently running
   deinited        — deinit() complete, body being freed
   freed           — body memory freed, header still exists
   dead            — header freed, side table may remain

 -----------------------------------------------------------------------
 D. STRONG REFERENCES — THE DEFAULT
 -----------------------------------------------------------------------
 In Swift, ALL references are strong by default.
 A strong reference increments the object's reference count.

 RULES OF STRONG REFERENCES:
   1. Every assignment of a class instance is a strong reference
   2. Every function parameter is a strong reference (for duration of call)
   3. Every capture in a closure is a strong reference (unless overridden)
   4. Every stored property of class type is a strong reference

 EXAMPLE:
   class Dog {
       var name: String
       init(_ name: String) { self.name = name }
       deinit { print("\(name) deallocated") }
   }

   class Owner {
       var name: String
       var dog: Dog?           // strong reference to Dog
       init(_ name: String) { self.name = name }
       deinit { print("\(name) deallocated") }
   }

   var owner: Owner? = Owner("Bob")    // Owner RC = 1
   owner?.dog = Dog("Rex")             // Dog RC = 1

   owner = nil
   // Owner RC = 0 → Owner.deinit called
   // Owner.dog (strong) released → Dog RC = 0 → Dog.deinit called
   // Prints: "Bob deallocated"
   // Prints: "Rex deallocated"

 STRONG REFERENCE LIFETIME:
   var a: MyClass? = MyClass()    // RC = 1
   do {
       var b = a                  // RC = 2
       var c = a                  // RC = 3
       // b and c go out of scope here
   }                              // RC = 1 (b and c released)
   a = nil                        // RC = 0 → deallocated

 -----------------------------------------------------------------------
 E. ARC AND CLOSURES
 -----------------------------------------------------------------------
 Closures are reference types. When a closure captures a variable,
 it creates a STRONG reference to it by default.

 HOW CLOSURE CAPTURE WORKS:
   class Counter {
       var count = 0
       func increment() { count += 1 }
   }

   var counter: Counter? = Counter()  // RC = 1

   let closure = {
       counter?.increment()           // closure strongly captures 'counter'
   }                                  // RC = 2 (counter + closure)

   counter = nil                      // RC = 1 (closure still holds it)
   // Counter is NOT deallocated — closure keeps it alive!

   // Only when closure is released:
   // (closure goes out of scope or set to nil)
   // RC = 0 → Counter deallocated

 CAPTURE LIST SYNTAX:
   let closure = { [weak counter] in
       counter?.increment()    // weak — won't prevent deallocation
   }

   let closure2 = { [unowned counter] in
       counter.increment()     // unowned — assumes counter still alive
   }

   // Multiple captures:
   let closure3 = { [weak self, unowned manager] in
       self?.doWork()
       manager.notify()
   }

 ARC COST OF CLOSURES:
   Each closure that captures reference types:
   - Allocates a heap closure context
   - Retains all captured reference-type values
   - Releases them when the closure is deallocated
   For performance: prefer value-type captures where possible

 -----------------------------------------------------------------------
 F. ARC IN MULTI-THREADED CONTEXTS
 -----------------------------------------------------------------------
 ARC's retain/release operations are ATOMIC (thread-safe).
 This means reference counting itself doesn't cause data races.

 HOWEVER: Object access (reading/writing properties) is NOT
 automatically thread-safe. ARC only protects the count, not
 the data inside the object.

 THREAD-SAFE COUNTING:
   // On 64-bit ARM/x86:
   // swift_retain uses an atomic fetch-and-add instruction
   // swift_release uses an atomic fetch-and-subtract
   // If result is 0 → trigger deallocation
   // This is lock-free and extremely fast (~1-2ns)

 ARC PERFORMANCE:
   - Atomic operations are more expensive than non-atomic
   - In tight loops with many retain/release: can be measurable
   - Optimization: compiler sometimes elides retain/release
     when it can prove the object stays alive
   - @inline(__always) on short functions helps compiler
     see across call boundaries

 -----------------------------------------------------------------------
 G. ARC vs GARBAGE COLLECTION
 -----------------------------------------------------------------------

 FEATURE              ARC                    GARBAGE COLLECTION
 ─────────────────────────────────────────────────────────────
 Timing               Deterministic          Non-deterministic
 Pause times          Zero                   Stop-the-world pauses
 Overhead             Per-operation (small)  Periodic (can be large)
 Memory freed         Immediately at RC=0    When GC runs
 Cycles               NOT auto-collected     Collected (usually)
 Deterministic deinit YES                    NO
 Implementation       Compile-time           Runtime
 Thread safety        Atomic counting        GC manages it

 ARC WEAKNESS: Cannot collect RETAIN CYCLES automatically.
 GC WEAKNESS: Non-deterministic, unpredictable pauses.

 Swift's solution to cycles: weak and unowned references.

 -----------------------------------------------------------------------
 H. SWIFT 5.9+ OWNERSHIP ADDITIONS
 -----------------------------------------------------------------------
 Swift 5.9 added explicit ownership tools that complement ARC:

 consume operator:
   var x = MyObject()
   let y = consume x    // x's lifetime ends here
   // Using x after this = compile error
   // No retain/release for this transfer — it's a MOVE

 borrowing parameter modifier:
   func inspect(_ x: borrowing MyObject) {
       // Read-only, no ARC increment for this call
       print(x.name)
   }

 consuming parameter modifier:
   func use(_ x: consuming MyObject) {
       // Takes ownership — caller loses access
       // No retain/release — direct ownership transfer
   }

 ~Copyable (noncopyable types):
   struct Handle: ~Copyable {
       // Cannot be copied — only moved
       // Prevents accidental ARC overhead
   }

 =======================================================================
 PART 2: STRONG REFERENCE CYCLES
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS A STRONG REFERENCE CYCLE?
 -----------------------------------------------------------------------
 A strong reference cycle (retain cycle) occurs when two or more
 objects hold STRONG references to each other, forming a closed
 loop. Neither object's reference count can ever reach zero,
 so neither is ever deallocated. This is a MEMORY LEAK.

 SIMPLEST FORM (two-node cycle):
   Object A  ──strong──►  Object B
   Object A  ◄──strong──  Object B

   A's RC never reaches 0 because B holds it.
   B's RC never reaches 0 because A holds it.
   Even if ALL external references are removed, the cycle
   keeps both alive forever (until app terminates).

 CONSEQUENCE:
   - Memory grows over time (leak)
   - deinit is NEVER called (resources not cleaned up)
   - In UIViewController: VC never released → UI bugs
   - In network layers: completion handlers held forever
   - Can eventually cause app crash (out of memory)

 -----------------------------------------------------------------------
 B. HOW CYCLES FORM — MECHANICS
 -----------------------------------------------------------------------
 Cycles form when ownership is mutual and bidirectional.
 Common patterns:

 PATTERN 1: Parent-Child bidirectional reference
   Parent has child: strong (wants to keep child alive)
   Child has parent: strong (WRONG — creates cycle)
   FIX: Child should have weak/unowned reference to parent

 PATTERN 2: Delegation
   Object holds delegate: strong (WRONG — delegate often owns object)
   FIX: Delegate reference should be weak

 PATTERN 3: Closure capturing self
   Object has closure property
   Closure strongly captures self
   = object → closure → object

 PATTERN 4: Observer pattern
   Subject holds strong reference to observer
   Observer holds strong reference to subject

 -----------------------------------------------------------------------
 C. CLASS-TO-CLASS CYCLES
 -----------------------------------------------------------------------

 EXAMPLE 1 — Parent-Child Cycle:

   class Person {
       let name: String
       var apartment: Apartment?          // strong

       init(name: String) { self.name = name }
       deinit { print("\(name) deinitialized") }
   }

   class Apartment {
       let unit: String
       var tenant: Person?                // strong ← CYCLE!

       init(unit: String) { self.unit = unit }
       deinit { print("Apartment \(unit) deinitialized") }
   }

   var john: Person?    = Person(name: "John")    // Person RC = 1
   var apt88: Apartment? = Apartment(unit: "88")  // Apt RC = 1

   john!.apartment = apt88   // Apt RC = 2
   apt88!.tenant   = john    // Person RC = 2

   john   = nil    // Person RC = 1 (still held by apt88.tenant)
   apt88  = nil    // Apt RC = 1 (still held by john.apartment)

   // Neither deinit is called!
   // Both instances leaked forever!

 FIX (using weak — see Part 3):
   class Apartment {
       let unit: String
       weak var tenant: Person?            // weak ← BREAKS CYCLE
       init(unit: String) { self.unit = unit }
       deinit { print("Apartment \(unit) deinitialized") }
   }
   // Now: john = nil → Person RC = 0 → deinit
   //       apt88.tenant automatically = nil

 EXAMPLE 2 — Delegate Cycle:

   // WRONG — creates cycle
   class NetworkManager {
       var delegate: NetworkDelegate?     // strong ← CYCLE RISK
   }

   class ViewController: NetworkDelegate {
       var network = NetworkManager()
       // VC → NetworkManager (strong)
       // NetworkManager.delegate → VC (strong) = CYCLE
   }

   // FIX:
   class NetworkManager {
       weak var delegate: (any NetworkDelegate)?  // weak
   }

 EXAMPLE 3 — Linked List Cycle:

   class Node {
       var value: Int
       var next: Node?        // strong — fine for forward links
       var previous: Node?    // strong ← CYCLE if doubly-linked!

       init(_ value: Int) { self.value = value }
   }

   // FIX: Use weak for backward links:
   class Node {
       var value: Int
       var next: Node?
       weak var previous: Node?   // weak backward reference
       init(_ value: Int) { self.value = value }
   }

 -----------------------------------------------------------------------
 D. CLASS-TO-CLOSURE CYCLES (CAPTURE LISTS)
 -----------------------------------------------------------------------
 Closures are reference types. Capturing self in a closure
 stored as a property creates a cycle:
   Object → closure property (strong)
   Closure → self (strong capture)
   = Object → Closure → Object

 EXAMPLE — Timer/Callback Cycle:

   class DataLoader {
       var onComplete: (() -> Void)?      // stored closure
       var data: [String] = []

       func load() {
           onComplete = {
               self.process()             // self captured strongly!
           }
           // DataLoader → onComplete (strong)
           // onComplete closure → self (strong)
           // CYCLE!
       }

       func process() { print("Processing \(data.count) items") }
       deinit { print("DataLoader deallocated") }
   }

   var loader: DataLoader? = DataLoader()
   loader?.load()
   loader = nil   // DataLoader NOT deallocated — cycle!

 FIX — Using [weak self]:
   func load() {
       onComplete = { [weak self] in
           self?.process()    // self is now weak — no cycle
       }
   }

 FIX — Using [unowned self] (when self is guaranteed alive):
   func load() {
       onComplete = { [unowned self] in
           self.process()     // unowned — no cycle, no Optional
       }
   }

 EXAMPLE — Escaping Closure Cycle:

   class ViewController: UIViewController {
       var viewModel = MyViewModel()

       override func viewDidLoad() {
           super.viewDidLoad()

           // WRONG — strong capture
           viewModel.fetchData {
               self.tableView.reloadData()    // strong self!
           }

           // CORRECT — weak capture
           viewModel.fetchData { [weak self] in
               self?.tableView.reloadData()
           }
       }
   }

 EXAMPLE — Timer Cycle:

   class TimerOwner {
       var timer: Timer?

       func start() {
           timer = Timer.scheduledTimer(
               withTimeInterval: 1.0,
               repeats: true
           ) { [weak self] _ in
               self?.tick()             // weak — no cycle
           }
       }

       func tick() { print("tick") }

       func stop() {
           timer?.invalidate()
           timer = nil                  // break the strong reference
       }

       deinit {
           timer?.invalidate()          // safety net
           print("TimerOwner deallocated")
       }
   }

 NOTE: Timer itself is retained by the RunLoop.
       The closure captures self → use [weak self] always.

 -----------------------------------------------------------------------
 E. THREE-NODE AND COMPLEX CYCLES
 -----------------------------------------------------------------------

 THREE-NODE CYCLE:
   A → B (strong)
   B → C (strong)
   C → A (strong)
   = All three trapped. None deallocated.

   class A { var b: B?; deinit { print("A gone") } }
   class B { var c: C?; deinit { print("B gone") } }
   class C { var a: A?; deinit { print("C gone") } }

   var a: A? = A()
   var b: B? = B()
   var c: C? = C()

   a!.b = b   // B RC = 2
   b!.c = c   // C RC = 2
   c!.a = a   // A RC = 2

   a = nil    // A RC = 1 — still alive!
   b = nil    // B RC = 1 — still alive!
   c = nil    // C RC = 1 — still alive!
   // None of A, B, C deallocated — all leaked!

 FIX: Break ONE link in the cycle with weak:
   class C { weak var a: A? }   // break cycle here

 COMPLEX GRAPH:
   In real apps, cycles can span many objects:
   VC → ViewModel (strong)
   ViewModel → NetworkService (strong)
   NetworkService → Delegate (strong)
   Delegate → VC (strong)
   = 4-node cycle

   Always identify the "weakest" ownership link —
   usually the back-reference or observer — and make it weak.

 -----------------------------------------------------------------------
 F. DETECTING CYCLES — TOOLS
 -----------------------------------------------------------------------

 1. XCODE MEMORY GRAPH DEBUGGER:
    - Run app in Xcode
    - Click "Debug Memory Graph" button (grid icon in debug bar)
    - Shows ALL live objects and their reference relationships
    - Cycles appear as closed loops in the graph
    - Look for objects that should have been deallocated

 2. INSTRUMENTS — LEAKS TEMPLATE:
    - Product → Profile → Leaks
    - Real-time leak detection
    - Shows leaked objects and their allocation callstack
    - Can detect cycles in running apps

 3. INSTRUMENTS — ALLOCATIONS TEMPLATE:
    - Track total memory usage over time
    - Generation analysis: allocations that persist across
      multiple "mark generation" snapshots are likely leaks

 4. DEINIT DEBUG PRINTS:
    deinit { print("\(type(of: self)) deallocated") }
    Add to suspected types. If not printed when expected
    → likely a retain cycle.

 5. SANITIZERS:
    - Address Sanitizer: detects some memory issues
    - Thread Sanitizer: not specifically for cycles but
      detects race conditions in ARC operations

 6. XCODE 14+ MEMORY REPORT:
    - Monitor memory usage in the debug navigator
    - Sudden memory growth suggests a cycle

 -----------------------------------------------------------------------
 G. CONSEQUENCES OF RETAIN CYCLES
 -----------------------------------------------------------------------

 1. MEMORY LEAKS:
    - Heap memory never freed
    - App memory grows monotonically
    - Eventually system kills app (jetsam)

 2. deinit NEVER CALLED:
    - File handles not closed
    - Database connections not released
    - Notification center observers not removed
    - Timers not invalidated (keep firing!)
    - Sensors (camera, GPS) not stopped

 3. UIVIEWCONTROLLER LEAKS:
    - VCs stay in memory after dismissal/pop
    - viewWillAppear/viewDidDisappear fire multiple times
    - Duplicate notifications, duplicate timers
    - Background tasks continue unexpectedly

 4. NETWORK LAYER LEAKS:
    - Completion closures held in memory
    - Response handlers never released
    - Retained objects keep network connections alive

 5. NOTIFICATION CENTER LEAKS:
    If observer not removed (because deinit not called):
    - Duplicate notifications fired
    - Crash: message sent to deallocated object (iOS < 9)
    - Memory grows unbounded

 =======================================================================
 PART 3: WEAK REFERENCES
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS A WEAK REFERENCE?
 -----------------------------------------------------------------------
 A weak reference is a reference that does NOT increment the
 object's strong reference count. It does not prevent ARC
 from deallocating the referenced object.

 When the referenced object is deallocated:
   → The weak reference is AUTOMATICALLY SET TO NIL.
 This is called ZEROING.

 SYNTAX:
   weak var propertyName: ClassName?

 RULES:
   1. Must be declared as var (not let) — because it can become nil
   2. Must be Optional — because it can be nil when object deallocated
   3. Only applies to class types — not structs or enums
   4. Accessing a zeroed weak reference returns nil safely (no crash)

 -----------------------------------------------------------------------
 B. ZEROING MECHANICS — HOW weak NIL-ING WORKS
 -----------------------------------------------------------------------
 When you create a weak reference, Swift:
   1. Does NOT increment the strong reference count
   2. Creates (or finds) the object's SIDE TABLE
   3. Increments the WEAK count in the side table
   4. Stores a pointer to the SIDE TABLE in your weak var
      (NOT a direct pointer to the object)

 When the object's strong count reaches 0:
   1. deinit() is called
   2. Object body is freed (Phase 1 deallocation)
   3. Side table state → "dead"
   4. All weak references atomically zeroed to nil
      (by checking the side table pointer they hold)
   5. Weak count decremented
   6. When weak count = 0: side table freed (Phase 2)

 WHY POINTER TO SIDE TABLE (not object):
   After the object body is freed (Phase 1), the object's
   memory may be reused. A direct pointer would be dangling.
   The side table persists until ALL weak references are
   cleared, allowing safe zeroing.

 THREAD SAFETY OF ZEROING:
   Zeroing uses atomic operations. Even if multiple threads
   access a weak reference simultaneously:
   - Each read either returns nil or a retained value
   - No partial/torn reads possible
   - No dangling pointer access

 EXAMPLE — Zeroing in action:
   class Server {
       deinit { print("Server gone") }
   }

   var server: Server? = Server()       // Strong RC = 1
   weak var weakServer: Server? = server // Weak RC in side table = 1
                                         // Strong RC still = 1

   print(weakServer)    // Optional(Server)

   server = nil         // Strong RC = 0
                        // → deinit called ("Server gone")
                        // → weakServer automatically = nil

   print(weakServer)    // nil  ← zeroed automatically, no crash

 -----------------------------------------------------------------------
 C. RULES AND RESTRICTIONS FOR weak
 -----------------------------------------------------------------------

 RULE 1: Must be Optional
   weak var ref: MyClass?     // ✓
   weak var ref: MyClass      // ✗ compile error

 RULE 2: Must be var
   weak let ref: MyClass?     // ✗ compile error
   weak var ref: MyClass?     // ✓

 RULE 3: Only class types
   weak var ref: MyStruct?    // ✗ compile error (struct)
   weak var ref: MyClass?     // ✓

 RULE 4: Protocol types need class constraint
   // Without class constraint — weak NOT allowed:
   protocol MyProtocol { }
   weak var ref: (any MyProtocol)?  // ✗ may not be class

   // With class constraint — weak allowed:
   protocol MyProtocol: AnyObject { }
   weak var ref: (any MyProtocol)?  // ✓

   // Or using modern any + existential:
   protocol MyDelegate: AnyObject { }
   weak var delegate: (any MyDelegate)?  // ✓

 RULE 5: Cannot be non-optional (unlike unowned)
   // If you need non-optional semantics → use unowned

 ACCESSING A WEAK REFERENCE:
   guard let strongRef = weakRef else { return }
   strongRef.doSomething()   // Use strongRef — guaranteed non-nil here

   // Or with optional chaining:
   weakRef?.doSomething()

 -----------------------------------------------------------------------
 D. WHEN TO USE weak
 -----------------------------------------------------------------------
 USE weak WHEN:
   1. The referenced object might become nil before you
      access the reference (truly optional lifetime)
   2. You're breaking a retain cycle where the back-reference
      might outlive the forward-reference
   3. Delegate pattern (delegate may be released)
   4. Closures capturing self in a VC (VC may be popped)
   5. Any observer/subscriber pattern

 DO NOT USE weak WHEN:
   1. The object is guaranteed to outlive the reference
      (use unowned for better performance + non-optional API)
   2. The type is a value type (struct/enum) — not allowed
   3. You need a strong reference to keep the object alive

 HEURISTIC — "Weak or Unowned?":
   Ask: "Can the referenced object be nil when I access this?"
   YES → use weak (Optional, safe nil return)
   NO  → use unowned (non-Optional, performance benefit)
   UNSURE → use weak (safer)

 -----------------------------------------------------------------------
 E. weak IN DELEGATES, CLOSURES, COLLECTIONS
 -----------------------------------------------------------------------

 DELEGATE PATTERN:
   // Protocol must be AnyObject (class-bound)
   protocol DataSourceDelegate: AnyObject {
       func didUpdate(items: [String])
   }

   class DataSource {
       weak var delegate: (any DataSourceDelegate)?

       func fetchAndNotify() {
           let items = ["a", "b", "c"]
           delegate?.didUpdate(items: items)
           // If delegate is nil: nothing happens (safe)
       }
   }

   class ViewController: DataSourceDelegate {
       let dataSource = DataSource()

       init() {
           dataSource.delegate = self   // No cycle: weak reference
       }

       func didUpdate(items: [String]) {
           print("Updated: \(items)")
       }
   }

 CLOSURE PATTERN:
   class MyViewController: UIViewController {
       var service = NetworkService()

       override func viewDidLoad() {
           super.viewDidLoad()

           // ✓ Correct — weak self
           service.fetch { [weak self] result in
               guard let self else { return }
               self.handleResult(result)
           }
       }

       // Note: guard let self = self (Swift 5.3+)
       // creates a NEW strong reference for the closure scope.
       // After guard, 'self' is a strong local reference.
       // The original weak reference may be released
       // at any point BETWEEN await suspension points,
       // but within synchronous code after guard: it's safe.
   }

 COLLECTION OF WEAK REFERENCES:
   Swift arrays/dictionaries do NOT support weak references
   directly. Use wrapper types:

   // Wrapper approach:
   class WeakRef<T: AnyObject> {
       weak var value: T?
       init(_ value: T) { self.value = value }
   }

   var weakObservers: [WeakRef<Observer>] = []

   func addObserver(_ observer: Observer) {
       weakObservers.append(WeakRef(observer))
   }

   func notify() {
       weakObservers.removeAll { $0.value == nil }  // prune dead refs
       weakObservers.forEach { $0.value?.update() }
   }

   // NSHashTable approach (Foundation):
   var weakSet = NSHashTable<MyClass>.weakObjects()
   weakSet.add(myObject)   // Does not retain myObject

   // NSMapTable approach:
   var weakMap = NSMapTable<NSString, MyClass>(
       keyOptions: .strongMemory,
       valueOptions: .weakMemory
   )

 -----------------------------------------------------------------------
 F. weak IN PROTOCOLS
 -----------------------------------------------------------------------

 For weak to work with protocols, the protocol must be
 CLASS-BOUND (AnyObject constraint):

   // ✓ Correct — AnyObject makes it class-bound
   protocol ViewDelegate: AnyObject {
       func viewDidUpdate()
   }

   class MyView {
       weak var delegate: (any ViewDelegate)?
   }

   // ✗ Wrong — non-class protocol, can't be weak
   protocol SomeProtocol {
       func doSomething()
   }
   // weak var ref: (any SomeProtocol)?  ← compile error

   // In Swift 5.7+: use 'any' keyword for existentials
   weak var delegate: (any ViewDelegate)?   // modern syntax

 -----------------------------------------------------------------------
 G. SWIFT 5.7+ any & weak
 -----------------------------------------------------------------------
 Swift 5.7 introduced the 'any' keyword for existential types.
 For weak references to protocols:

   // Old style (still works but deprecated in some contexts):
   weak var delegate: ViewDelegate?

   // New style (explicit existential):
   weak var delegate: (any ViewDelegate)?

   // In function signatures:
   func setDelegate(_ d: any ViewDelegate) {
       self.delegate = d   // weak assignment
   }

 =======================================================================
 PART 4: UNOWNED REFERENCES
 =======================================================================

 -----------------------------------------------------------------------
 A. WHAT IS AN UNOWNED REFERENCE?
 -----------------------------------------------------------------------
 An unowned reference does NOT increment the strong reference
 count (like weak), but unlike weak:
   - It is NON-OPTIONAL
   - It does NOT automatically become nil when the object deallocates
   - Accessing it after the object is deallocated causes a CRASH

 USE unowned WHEN:
   You are certain the referenced object will ALWAYS outlive
   the reference. The reference will NEVER be accessed after
   the object is deallocated.

 SYNTAX:
   unowned var propertyName: ClassName    // non-optional
   unowned let propertyName: ClassName    // can be let!

 EXAMPLE:
   class Country {
       let name: String
       var capitalCity: City!             // implicitly unwrapped

       init(name: String, capitalName: String) {
           self.name = name
           self.capitalCity = City(name: capitalName, country: self)
       }
       deinit { print("\(name) deallocated") }
   }

   class City {
       let name: String
       unowned let country: Country       // ← unowned, not weak

       init(name: String, country: Country) {
           self.name = name
           self.country = country
       }
       deinit { print("\(name) deallocated") }
   }

   var france: Country? = Country(name: "France", capitalName: "Paris")
   // Country RC = 1, City RC = 1
   // City.country is unowned → Country RC stays 1

   france = nil
   // Country RC = 0 → Country.deinit → capitalCity released
   // City RC = 0 → City.deinit
   // Prints: "France deallocated"
   // Prints: "Paris deallocated"
   // No cycle! No crash! Perfect.

 -----------------------------------------------------------------------
 B. unowned vs weak — FULL COMPARISON
 -----------------------------------------------------------------------

 FEATURE              weak                    unowned
 ─────────────────────────────────────────────────────────────
 Optional             YES (must be Optional)  NO (non-Optional)
 Can be let           NO (must be var)        YES
 Auto-nil on dealloc  YES (zeroed)            NO (dangling — crash)
 Performance          Side table overhead     Slightly faster (no side table*)
 Crash on misuse      NO (returns nil)        YES (trap on access after dealloc)
 Use when             Object may become nil   Object always outlives reference
 Typical use          Delegates, closures     Parent-child where child ≠ outlive parent

 * unowned(safe) still uses some side table metadata.
   unowned(unsafe) does NOT use the side table.

 MEMORY LAYOUT:
   weak:   stores pointer to SIDE TABLE
   unowned(safe): stores direct pointer + checks side table on access
   unowned(unsafe): stores raw pointer, zero overhead, zero safety

 -----------------------------------------------------------------------
 C. unowned SAFE vs unowned(unsafe)
 -----------------------------------------------------------------------

 unowned (default = unowned safe):
   - Accesses ARE checked against the side table
   - If object is deallocated → SWIFT TRAP (controlled crash)
   - Better debugging experience
   - Slight runtime overhead (side table lookup on access)

   unowned var ref: MyClass     // default = safe

 unowned(unsafe):
   - NO runtime check
   - NO side table involvement
   - Accessing after dealloc → UNDEFINED BEHAVIOR
   - Like a raw C pointer — fastest but most dangerous
   - Used for C interop or extreme performance hotpaths

   unowned(unsafe) var ref: MyClass   // no safety net

 EXAMPLE — Safe crash message:
   class A {
       unowned var b: B
       init(b: B) { self.b = b }
   }
   class B { deinit { print("B gone") } }

   var b: B? = B()
   let a = A(b: b!)
   b = nil          // B deallocated: "B gone"
   // a.b is now dangling (unowned safe)
   print(a.b)       // ← TRAP: "error: attempted to read an unowned
                    // reference but object 0x... was already deallocated"

 EXAMPLE — Unsafe (undefined behavior):
   class A {
       unowned(unsafe) var b: B
       init(b: B) { self.b = b }
   }
   // After b is deallocated:
   // a.b = garbage memory — no crash guaranteed
   // May crash, may return corrupt data, may appear to work
   // = undefined behavior

 -----------------------------------------------------------------------
 D. unowned IN CLOSURES
 -----------------------------------------------------------------------
 unowned in capture lists for closures where:
   1. The closure cannot outlive self
   2. self is guaranteed alive whenever the closure runs

 CLASSIC EXAMPLE — Credit Card that cannot outlive Customer:
   class Customer {
       let name: String
       var card: CreditCard?

       init(name: String) { self.name = name }
       deinit { print("\(name) deallocated") }
   }

   class CreditCard {
       let number: UInt64
       unowned let customer: Customer     // card never outlives customer

       init(number: UInt64, customer: Customer) {
           self.number = number
           self.customer = customer
       }
       deinit { print("Card #\(number) deallocated") }
   }

   var customer: Customer? = Customer(name: "Alice")
   customer!.card = CreditCard(number: 1234, customer: customer!)

   customer = nil
   // "Alice deallocated"
   // "Card #1234 deallocated"
   // Perfect: no cycle, no crash

 CLOSURE CAPTURE WITH unowned:
   class ResourceManager {
       var process: (() -> Void)?

       func setup() {
           process = { [unowned self] in
               // self guaranteed alive while process is alive
               // (ResourceManager owns process)
               self.doWork()
           }
       }

       func doWork() { print("Working") }
       deinit { print("ResourceManager gone") }
   }

   // ResourceManager → process (strong)
   // process → self (unowned, no increment)
   // No cycle! ResourceManager can be deallocated.

   var rm: ResourceManager? = ResourceManager()
   rm?.setup()
   rm?.process?()   // "Working"
   rm = nil         // "ResourceManager gone" ← deinit called!

 -----------------------------------------------------------------------
 E. unowned + LIFETIME GUARANTEES
 -----------------------------------------------------------------------
 Use unowned ONLY when you can guarantee the referenced object
 outlives the reference. Common safe scenarios:

 SAFE USE 1: Parent-child where parent always outlives child
   class Form {
       var button: SubmitButton?
       deinit { print("Form gone") }
   }
   class SubmitButton {
       unowned let form: Form   // button always destroyed before form
       init(form: Form) { self.form = form }
   }

 SAFE USE 2: Closure captured in an instance that self owns
   class ViewController {
       lazy var handler: () -> Void = { [unowned self] in
           self.handleTap()    // safe: handler can't outlive VC
       }
       func handleTap() { print("tapped") }
   }

 SAFE USE 3: Initialization-time circular reference
   class Node {
       let value: Int
       unowned var parent: Tree   // always initialized with tree
       init(value: Int, parent: Tree) {
           self.value = value
           self.parent = parent
       }
   }

 UNSAFE USE — Closure escaping after object deallocation:
   class DataFetcher {
       func fetch(completion: @escaping () -> Void) {
           DispatchQueue.global().async {
               // Work done
               completion()    // called after DataFetcher may be gone!
           }
       }
   }

   class ViewController {
       var fetcher = DataFetcher()

       func loadData() {
           fetcher.fetch { [unowned self] in  // DANGER!
               self.reload()   // self might be deallocated!
           }
       }
   }
   // FIX: Use [weak self] here — VC may be popped before fetch completes

 -----------------------------------------------------------------------
 F. unowned(unsafe) — WHEN AND WHY
 -----------------------------------------------------------------------
 Used for:
   1. C/Objective-C interoperability
   2. Extreme performance-critical code where overhead matters
   3. Bridging with legacy ObjC code that doesn't use side tables

   // ObjC bridging example:
   class ObjCWrapper {
       unowned(unsafe) var delegate: AnyObject?
       // Matches ObjC's __unsafe_unretained semantics
   }

 PERFORMANCE:
   strong:           atomic retain + release = ~2-4ns each
   weak:             + side table access = ~5-10ns extra
   unowned(safe):    + side table check on read = ~2-3ns extra
   unowned(unsafe):  zero overhead — raw pointer read

 For 99% of apps: the performance difference is irrelevant.
 Use unowned(unsafe) only if profiling proves it necessary.

 -----------------------------------------------------------------------
 G. COMMON CRASH SCENARIOS
 -----------------------------------------------------------------------

 CRASH 1 — Accessing unowned after deallocation:
   var obj: MyClass? = MyClass()
   let ref: MyClass = { [unowned obj = obj!] in return obj }()
   // Simplified: unowned reference to an already-deallocated object
   // Accessing ref → TRAP

 CRASH 2 — Race condition with unowned in async code:
   class Loader {
       unowned var vc: ViewController
       func load() {
           DispatchQueue.global().async {
               // vc might be deallocated by the time this runs
               self.vc.update()  // CRASH if vc is gone
           }
       }
   }
   // FIX: Use weak var vc: ViewController?

 CRASH 3 — unowned in escaping closure:
   func startTimer(for object: MyClass) {
       DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
           [unowned object] in          // DANGER if object gone in 5s
           object.doSomething()
       }
       // FIX: Use [weak object]
   }

 CRASH 4 — Multithreaded deallocation:
   Thread 1: reading unowned ref
   Thread 2: last strong ref released (object being deallocated)
   = Thread 1 reads dangling pointer → undefined behavior
   // unowned(safe) traps here. unowned(unsafe) → UB.
   // FIX: weak + nil check, or ensure proper lifetime management

 =======================================================================
 PART 5: SIDE-BY-SIDE COMPARISON TABLE
 =======================================================================

 PROPERTY           strong          weak              unowned
 ───────────────────────────────────────────────────────────────────
 RC increment       YES             NO                NO
 Can be nil         YES             YES (auto-nil)    NO (non-optional)
 Must be var        NO              YES               NO (can be let)
 Must be Optional   NO              YES               NO
 Deallocated access N/A (kept alive) nil (safe)       CRASH (trap)
 Side table         NO              YES               YES (safe) / NO (unsafe)
 Performance        baseline        small overhead    minimal overhead
 Use for            default         cycles / optional same-lifetime back-refs
 Typical example    child in parent delegate pattern  credit card → customer

 DECISION TREE:
   Reference to a class instance?
   └─ YES: Reference keeps it alive? (ownership)
            ├─ YES → strong (default)
            └─ NO: May the object be nil when accessed?
                    ├─ YES or UNSURE → weak (Optional, safe)
                    └─ NO (guaranteed alive) → unowned (non-Optional)

 =======================================================================
 PART 6: 100 INTERVIEW Q&A
 =======================================================================

 ────────────────────────────────────────────────────────────────────
 SECTION 1: BASIC QUESTIONS (Q1–Q25)
 ────────────────────────────────────────────────────────────────────

 Q1. What is ARC?
 A:  Automatic Reference Counting. Swift's memory management
     strategy that automatically tracks the number of strong
     references to each class instance and deallocates the
     instance when the count reaches zero. Compiler-driven:
     retain/release calls are inserted at compile time.

 ---

 Q2. Does ARC apply to structs?
 A:  No. ARC applies only to reference types: class instances
     and closures. Structs and enums are value types stored
     on the stack (or inline) and don't need reference counting.

 ---

 Q3. What is a strong reference?
 A:  The default reference type in Swift. Creates a strong
     reference that increments the object's reference count,
     preventing ARC from deallocating the object as long as
     the reference exists.

 ---

 Q4. What is a retain cycle?
 A:  When two or more objects hold strong references to each
     other, forming a cycle. Neither object's reference count
     can reach zero, so neither is ever deallocated. This
     causes a memory leak.

 ---

 Q5. What is a weak reference?
 A:  A reference that does NOT increment the object's reference
     count. Must be Optional and var. Automatically set to nil
     (zeroed) when the referenced object is deallocated.

 ---

 Q6. What is an unowned reference?
 A:  A reference that does NOT increment the object's reference
     count. Non-optional, can be let. Does NOT automatically
     become nil when the object deallocates. Accessing it after
     deallocation causes a runtime crash (trap).

 ---

 Q7. When should you use weak vs unowned?
 A:  weak: when the referenced object might become nil before
          you access the reference. Always safe.
     unowned: when you are certain the referenced object will
              always outlive the reference. Non-optional API.
     When in doubt: use weak (safer).

 ---

 Q8. Can weak be declared as let?
 A:  No. weak must be var because its value can change
     (automatically set to nil when the object deallocates).
     Declaring weak let is a compile error.

 ---

 Q9. Can unowned be declared as let?
 A:  Yes. unowned can be let because it doesn't automatically
     change — it either always points to the same object
     (while that object is alive) or crashes.

 ---

 Q10. Must a weak reference be Optional?
 A:   Yes. weak var must be Optional (T?) because it can
      become nil automatically when the referenced object
      is deallocated.

 ---

 Q11. Can you use weak with a struct type?
 A:   No. weak only works with class types and class-bound
      protocol types. Structs are value types and don't
      participate in ARC.

 ---

 Q12. What happens when the last strong reference to an
      object is removed?
 A:   ARC immediately calls deinit() on the object, releases
      all stored properties, and frees the memory. This is
      deterministic — it happens immediately, not at a
      future GC pause.

 ---

 Q13. What is deinit and when is it called?
 A:   deinit is a special deinitializer method on classes,
      called immediately when the instance's ARC count drops
      to zero. Use it to clean up resources (observers, timers,
      file handles). Cannot be called manually.

 ---

 Q14. Can structs have deinit?
 A:   No. deinit is only for class types. Structs don't have
      reference counting, so there's no equivalent. ~Copyable
      structs (Swift 5.9+) can have deinit as a special case.

 ---

 Q15. What is a retain cycle in a closure?
 A:   When a closure captures self strongly and self holds
      a strong reference to the closure (as a stored property).
      Creates a cycle: Object → closure → object.
      Fix: capture list [weak self] or [unowned self].

 ---

 Q16. How do you break a retain cycle in a closure?
 A:   Use a capture list:
      { [weak self] in self?.doWork() }      // weak — Optional
      { [unowned self] in self.doWork() }    // unowned — non-Optional
      [weak self] is safer for closures that may outlive self.

 ---

 Q17. What is the & symbol used for in the context of ARC?
 A:   & is used for inout parameters (not directly ARC-related).
      For ARC, the key operators are the capture list [ ] in
      closures (weak/unowned). & for inout is about exclusive
      memory access, separate from ARC.

 ---

 Q18. What keyword do you use to detect if a class instance is
      still alive in debug mode?
 A:   deinit print statement is the most common approach.
      Also: Xcode Memory Graph Debugger visually shows live
      objects. Instruments Leaks template reports leaked objects.

 ---

 Q19. What is the difference between memory leak and dangling pointer?
 A:   Memory leak: memory is allocated but never freed
                   (object referenced but inaccessible externally).
                   Happens with retain cycles.
      Dangling pointer: reference to memory that has ALREADY been freed.
                   Happens with unowned after deallocation.
                   ARC (with strong/weak) prevents dangling pointers.

 ---

 Q20. Does weak work with value types wrapped in a class?
 A:   weak works with the class WRAPPER, not the value type
      inside. You make a class hold the value, then weak-reference
      the class:
      class Box<T> { var value: T; init(_ v: T) { value = v } }
      weak var boxRef: Box<Int>?   // ✓

 ---

 Q21. What is NSHashTable and when would you use it?
 A:   NSHashTable is a Foundation collection that supports
      weak memory options: NSHashTable.weakObjects().
      Objects stored with weak memory are not retained and
      are removed when deallocated. Use instead of [WeakRef<T>]
      when you need a set of weakly-held objects.

 ---

 Q22. Can you have an array of weak references in Swift?
 A:   Not directly. Swift arrays strongly retain their elements.
      To store weak references, use a wrapper:
      struct Weak<T: AnyObject> { weak var value: T? }
      var arr: [Weak<MyClass>] = []
      Or use NSHashTable<MyClass>.weakObjects().

 ---

 Q23. What is the difference between ARC and manual retain/release?
 A:   Manual retain/release (MRC, pre-ARC Obj-C) required the
      programmer to call retain, release, and autorelease
      explicitly. Error-prone: over-release = crash,
      under-release = leak. ARC automates this at compile time,
      inserting calls based on compiler analysis. No manual calls.

 ---

 Q24. What type must a protocol be to allow weak references?
 A:   The protocol must be class-bound (AnyObject constraint):
      protocol MyProtocol: AnyObject { }
      weak var ref: (any MyProtocol)?  // ✓

 ---

 Q25. Does ARC handle cycles between a class and a closure?
 A:   No. ARC cannot break reference cycles automatically.
      Cycles between classes and closures must be broken
      manually using [weak self] or [unowned self] in
      the closure's capture list.

 ────────────────────────────────────────────────────────────────────
 SECTION 2: INTERMEDIATE QUESTIONS (Q26–Q65)
 ────────────────────────────────────────────────────────────────────

 Q26. Explain the object header layout for a Swift class instance.
 A:   Every class instance has a 16-byte header:
      Word 1: isa pointer (points to class type metadata/vtable)
      Word 2: reference count word encoding:
        - Strong reference count
        - Unowned reference count
        - Weak reference count (via side table pointer)
      The count word is a packed 64-bit integer with multiple
      sub-fields plus state flags.

 ---

 Q27. What is the side table in Swift's ARC implementation?
 A:   A separate small heap allocation created lazily when the
      first weak reference to an object is made. It contains:
      - Pointer back to the object
      - Weak reference count
      - Object lifecycle state flags
      weak variables store a pointer to the SIDE TABLE, not
      the object directly. This allows atomic zeroing of weak
      references even after the object's body is freed.

 ---

 Q28. Explain two-phase deallocation in Swift's ARC.
 A:   Phase 1 (Strong count → 0):
        - deinit() called
        - Object's stored properties released
        - Object body memory freed
        - Side table state → "dead"
        - Weak references zeroed
      Phase 2 (Unowned count → 0, after Phase 1):
        - Object header memory freed
     - Side table freed (if weak count also = 0)
    This two-phase approach ensures weak references can be
    safely zeroed even after the object body is freed,
    because the side table outlives the body.

---

Q29. Why is a weak reference stored as a pointer to the
side table rather than a pointer to the object?
A:   After Phase 1 deallocation, the object's body memory
is freed and may be reused immediately. A direct pointer
would become a dangling pointer. The side table persists
until ALL weak references are gone (Phase 2), so storing
a pointer to the side table allows safe zeroing:
- Read side table state → "dead" → return nil
- No dangling pointer access ever occurs
- Thread-safe: atomic state check in side table

---

Q30. What is the retain/release cost in terms of performance?
A:   On modern 64-bit hardware:
- swift_retain:  atomic fetch-and-add  ≈ 1–3 ns
- swift_release: atomic fetch-and-sub  ≈ 1–3 ns
- weak access:   + side table lookup   ≈ 5–10 ns extra
- unowned(safe): + side table check    ≈ 2–3 ns extra
In tight loops processing millions of objects, ARC
overhead can be measurable. For 99% of apps it is
negligible. Use profiling (Instruments Time Profiler)
to confirm before optimizing.

---

Q31. How does the Swift compiler eliminate redundant
retain/release calls?
A:   The compiler applies several optimizations:
1. ARC optimization pass: removes paired retain/release
  when it can prove the object stays alive between them
2. Guaranteed Self: in methods, self is known alive
  for the method's duration — no retain/release needed
3. Inlining: when a function is inlined, the compiler
  sees across call boundaries and can elide calls
4. Ownership annotations (borrowing/consuming in Swift 5.9):
  explicitly tell the compiler not to insert retain/release
Use -O (optimization) builds to get these benefits.

---

Q32. What is the difference between a memory leak and
a zombie object?
A:   Memory leak: an object is allocated but can never be
reached or deallocated. Its memory is permanently lost.
Caused by retain cycles.
Zombie object: an object that HAS been deallocated but
is still being messaged (Objective-C concept). In Swift:
similar to accessing an unowned reference after
deallocation — the memory is freed but the pointer
still exists. Xcode's "Zombie Objects" debugging mode
overrides dealloc to keep the memory marked as zombie
for debugging purposes.

---

Q33. How do you use Xcode's Memory Graph Debugger to
find a retain cycle?
A:   1. Run app in Xcode (Debug configuration)
2. Navigate to the screen with the suspected leak
3. Navigate AWAY from that screen
4. Click "Debug Memory Graph" (grid icon in debug bar)
5. Look for objects that should have been deallocated
  (e.g., a popped ViewController still present)
6. Click the suspicious object in the left panel
7. Xcode shows a reference graph — look for cycles
  (arrows pointing back to the same object)
8. The backtrace panel shows where the reference
  was created

---

Q34. Why does [weak self] require guard let or optional
chaining to use self?
A:   [weak self] captures self as Optional (Self?). Inside
the closure, self could have been deallocated at any
time before or during execution. Using self? (optional
chaining) or guard let self = self (rebinding) makes
this nil possibility explicit and safe.
Without this, you'd be force-unwrapping an Optional
that might be nil = crash.

---

Q35. What is the semantics of guard let self = self in
a [weak self] closure?
A:   guard let self = self else { return } creates a NEW
strong reference to self for the REMAINDER of the
closure's scope. This means:
- If self is nil at the guard line → return early
- If self is non-nil at the guard line → a strong
 reference is created, keeping self alive for the
 rest of the closure (synchronous code)
IMPORTANT: between await suspension points in async
closures, this guarantee weakens — self could be
released between suspensions. Re-check after each await.

---

Q36. Is [weak self] always necessary in closures that
reference self?
A:   No. [weak self] is needed ONLY when:
1. The closure is ESCAPING (can outlive current scope)
2. AND self holds a strong reference to the closure
  (creating a potential cycle)
Non-escaping closures: no cycle risk, [weak self] not needed.
Escaping closures stored ELSEWHERE (not in self):
[weak self] prevents the closure keeping self alive
longer than expected, even if not a formal cycle.

---

Q37. What is a capture list and how does it differ from
a parameter list?
A:   Capture list: defined INSIDE the closure, BEFORE parameters,
using [ ]. Controls HOW variables from the enclosing
scope are captured.
{ [weak self, unowned manager] (param1, param2) -> ReturnType in
   // body
}
Parameter list: the closure's own parameters (param1, param2).
Capture list items: how external variables are captured
(strong by default, weak/unowned to break cycles, or
by value to freeze a copy).

---

Q38. How do you capture a value type by value (copy) in a closure?
A:   Include it in the capture list without weak/unowned:
var count = 0
let closure = { [count] in
   print(count)   // count is COPIED at closure creation
}
count = 99
closure()   // Prints 0, not 99 — captured the value at creation

Without capture list:
let closure2 = { print(count) }
count = 99
closure2()   // Prints 99 — captured the reference (var binding)

---

Q39. Can a struct cause a retain cycle?
A:   Structs themselves don't participate in ARC. However:
1. A struct CAN CONTAIN a class reference → that class
  participates in ARC normally
2. A struct property holding a closure that captures
  a class instance → the class is retained
3. A struct inside a class, which the struct's closure
  captures via self → the CLASS is in a cycle
The cycle is always between class instances and/or closures,
not between structs themselves.

---

Q40. What is the difference between [weak self] and
[weak self = someOtherObject]?
A:   [weak self]: captures self (the current instance) weakly.
[weak self = someOtherObject]: captures 'someOtherObject'
weakly but binds it to the name 'self' inside the closure.
This is rarely used but allows aliasing:
{ [weak controller = self.childController] in
   controller?.reload()
}
More commonly used to rename captures for clarity.

---

Q41. What happens if you capture [weak self] in a non-escaping closure?
A:   It works but is unnecessary. Non-escaping closures can't
outlive the function call, so there's no cycle risk.
The compiler may even warn: "Weak capture of 'self' in
non-escaping closure." Use [weak self] only for escaping
closures where cycles are possible.

---

Q42. How does ARC handle closures stored in arrays or dictionaries?
A:   Each closure stored in a collection is a strong reference
to that closure object. The closure strongly retains all
captured reference-type variables (unless weak/unowned).
If the array is on a class instance, and the closures
capture that instance, you have a cycle:
self.handlers.append { [weak self] in self?.handle() }
Always use [weak self] when storing closures in self's
properties if they capture self.

---

Q43. What is the unowned(safe) vs unowned(unsafe) distinction
in terms of what happens at runtime when the object
is deallocated?
A:   unowned(safe) (default unowned):
 - Object transitions to "freed" state in side table
 - On access: side table state checked
 - If freed → Swift runtime trap (controlled crash with
   useful error message and stack trace)
unowned(unsafe):
 - No side table involvement
 - On access after dealloc: raw pointer read
 - Undefined behavior: may crash, may return garbage,
   may appear to work (memory reuse)
 - No useful error message

---

Q44. Explain the classic "Apartment and Tenant" retain
cycle example and how to fix it.
A:   class Person {
   var apartment: Apartment?  // strong
}
class Apartment {
   var tenant: Person?        // strong ← CYCLE
}
Both hold strong refs → neither deallocates.

FIX: Make one reference weak (the "less owning" side):
class Apartment {
   weak var tenant: Person?   // weak — Apartment doesn't own Person
}
Now: when external Person ref is nil → Person RC = 0
→ Person.deinit → apartment released
→ Apartment RC = 0 → Apartment.deinit

---

Q45. What is the classic "Customer and CreditCard" example
and why is unowned appropriate there?
A:   A credit card cannot exist without a customer.
The card's lifetime is strictly shorter than or equal
to the customer's lifetime.
class Customer {
   var card: CreditCard?
}
class CreditCard {
   unowned let customer: Customer  // always alive while card exists
}
unowned is correct (not weak) because:
- card.customer is NEVER nil (initialized with customer)
- customer ALWAYS outlives the card
- Non-optional API matches the real-world constraint

---

Q46. How does ARC interact with Protocol-Oriented Programming?
A:   Protocols don't add ARC overhead themselves. But:
- Protocol types backed by classes: ARC applies
- Protocol types backed by structs: no ARC
- Existential boxes (any Protocol): if the concrete
 type is a class → ARC for the boxed instance
- Protocol composition (A & B): if A or B are class-bound
 → ARC applies to the instance
- any AnyObject: always reference-counted

---

Q47. Why does a Timer create a retain cycle and how
do you fix it?
A:   Timer is retained by the RunLoop. Timer's block/closure
captures its target strongly. If the target also holds
the Timer (as a property):
Target → timer (strong)
Timer (RunLoop) → target (strong via block capture)
= cycle

FIX 1: [weak self] in timer closure:
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
   [weak self] _ in self?.tick()
}

FIX 2: Invalidate timer in deinit/viewWillDisappear:
timer?.invalidate()
timer = nil
Invalidating removes timer from RunLoop, breaking the cycle.
BOTH fixes together are safest.

---

Q48. What is an autoreleasepool and when do you use it in Swift?
A:   autoreleasepools are a legacy Objective-C mechanism for
deferring release of objects. In Swift + ARC, most objects
are released deterministically. However, autoreleasepools
are still needed when:
1. Calling Obj-C APIs that return autoreleased objects
2. Creating many short-lived objects in a tight loop
  (prevents memory buildup before main pool drains)
3. In background threads (which have no automatic pool)

autoreleasepool {
   for _ in 0..<10_000 {
       let image = UIImage(named: "large")
       process(image)   // image released at end of block
   }
}
Without autoreleasepool: all 10,000 images live
simultaneously → peak memory spike.
With autoreleasepool: each iteration's pool drains → low memory.

---

Q49. How does weak work across multiple threads?
A:   Swift's weak reference access is THREAD-SAFE.
- Loading a weak reference: atomic read of side table state
- If alive: atomically retains the object and returns it
- If dead: returns nil
This prevents time-of-check to time-of-use (TOCTOU) bugs:
Thread 1: reads weak → non-nil (atomic retain bumps RC)
Thread 2: releases last strong ref → RC goes to 1 (not 0)
Thread 1: safely uses the object
Thread 1: releases its copy → RC = 0 → dealloc
The atomic retain during weak load ensures no dangling access.

---

Q50. What is the ownership of self inside a mutating
method on a struct vs a class method?
A:   Class method: self is a STRONG REFERENCE. ARC retains
self for the duration of the method (guaranteed alive).
No retain/release visible to the programmer but done
by the compiler.
Struct mutating method: self is a copy (or inout pointer
to original). No ARC involved — value semantics.
The mutating method has exclusive write access via
Swift's exclusivity rule, not ARC.

---

Q51. Can you have a weak reference to a Swift enum or tuple?
A:   No. weak only applies to class types (reference types).
Enums and tuples are value types and have no reference
identity. If you need a weak-like pattern with a value
type, wrap it in a class:
class Container { var value: MyEnum }
weak var ref: Container?

---

Q52. How does ARC behave inside a for-in loop iterating
over an array of class instances?
A:   Each element accessed in the loop body is temporarily
strongly retained for that iteration. The compiler inserts:
- retain at start of each loop body
- release at end of each loop body
This prevents deallocation during iteration even if
the array is mutated (though mutating during iteration
is generally unsafe). After the loop, all temporary
retains are released.

---

Q53. What does @objc dynamic do in relation to ARC?
A:   @objc dynamic enables Objective-C dynamic dispatch
(runtime method lookup via objc_msgSend instead of
Swift's vtable). This doesn't change ARC behavior
directly, but: Objective-C runtime's messaging uses
autorelease pools for some return values. Methods
marked @objc dynamic may interact with the ObjC
autorelease pool. KVO (which requires @objc dynamic)
internally manages strong references to observers.

---

Q54. What is an implicitly unwrapped Optional (IUO) in the
context of ARC and retain cycles?
A:   An IUO (Type!) is a special Optional that automatically
unwraps on use. From an ARC perspective, it behaves
like a strong reference (not weak). Example:
class ViewController {
   var childVC: ChildViewController!   // strong, IUO
}
IUOs can participate in retain cycles just like regular
strong references. They don't break cycles. Using IUO
for mutual references does NOT solve the cycle problem —
use weak or unowned instead.

---

Q55. How does Swift's ownership model (SE-0377, Swift 5.9)
reduce ARC overhead?
A:   New parameter modifiers tell the compiler explicitly
about ownership transfer:
borrowing: "I only need to read this — don't retain/release"
func inspect(_ x: borrowing MyClass) { }
// No retain/release call at call site
consuming: "I take ownership — you lose it"
func use(_ x: consuming MyClass) { }
// Ownership transferred — no copy needed
Without these: the compiler must conservatively insert
retain/release at every call boundary. With them:
the compiler eliminates ARC calls in many hotpaths,
particularly in tight loops or functional chains.

---

Q56. What is the difference between weak self and
[self] (capture by copy) in a closure?
A:   weak self: captures self as Optional weak reference.
         Self can become nil during closure execution.
         Does NOT prevent deallocation.
[self] (explicit strong capture, Swift 5.3+):
         Explicitly captures self strongly.
         Equivalent to the default implicit capture.
         Useful for clarity or to satisfy the compiler
         when using self in @Sendable closures.
         DOES prevent deallocation (same as default).
Neither [self] nor implicit capture breaks cycles.
Only [weak self] or [unowned self] break cycles.

---

Q57. How do you implement a safe observer pattern with
weak references to avoid memory issues?
A:   class EventEmitter {
   private var listeners: [WeakRef<AnyObject>] = []
   private var handlers: [ObjectIdentifier: () -> Void] = [:]

   func addListener(_ listener: AnyObject,
                    handler: @escaping () -> Void) {
       listeners.append(WeakRef(listener))
       handlers[ObjectIdentifier(listener)] = handler
   }

   func emit() {
       listeners = listeners.filter { $0.value != nil }
       for listener in listeners {
           guard let obj = listener.value else { continue }
           handlers[ObjectIdentifier(obj)]?()
       }
   }
}
Key points:
- Weak references: listeners don't keep observers alive
- Pruning: remove nil entries before iterating
- Identity: use ObjectIdentifier for handler mapping

---

Q58. How does ARC interact with Swift concurrency (actors)?
A:   Actors are classes under the hood — ARC manages their
memory normally. However:
1. Actor isolation ensures only ONE task accesses the
  actor at a time, so ARC operations on actor-isolated
  properties are serialized.
2. Sendable checking ensures values crossing actor
  boundaries are either value types (no ARC) or
  thread-safe reference types.
3. Closures in async tasks: [weak self] still needed
  if the task might outlive self:
  Task { [weak self] in
      await self?.doWork()
  }
4. Isolated tasks on MainActor don't need [weak self]
  if the VC/VM is guaranteed alive for the task's duration.

---

Q59. What is the difference between weak self in a
completion handler vs in a stored closure?
A:   Completion handler (escaping, called once, then released):
[weak self] prevents VC being kept alive for the
duration of the network call. After callback fires,
closure is released → no long-term cycle.
Risk without [weak self]: VC stays alive until
network completes (minor leak, not permanent).

Stored closure (stored as property, indefinite lifetime):
[weak self] prevents a permanent cycle:
self.onUpdate = { [weak self] in self?.refresh() }
Without [weak self]: permanent leak — object can NEVER
be deallocated.
Stored closures are MUCH more critical to fix than
one-time completion handlers.

---

Q60. How does the Swift runtime handle a weak reference
load atomically?
A:   The weak load (swift_weakLoadStrong) performs:
1. Load the side table pointer atomically
2. If nil (no side table): return nil
3. If side table exists: check state flags
4. If state = live or deiniting: attempt atomic strong retain
  (increment strong count with compare-and-swap)
5. If CAS succeeds: return the retained object
6. If CAS fails (race: count hit 0): return nil
This ensures that the returned value is either nil or
a fully retained object — never a dangling pointer.
The caller must release this temporary strong reference
when done (swift_release).

---

Q61. Can you store an unowned reference in a collection?
A:   Not directly with the unowned modifier. The runtime
requires unowned references to be on stack or in
object properties — not in Array/Dictionary elements.
Workarounds:
1. Use a wrapper struct:
  struct UnownedRef<T: AnyObject> {
      unowned var value: T
  }
  var arr: [UnownedRef<MyClass>] = []
2. Use NSPointerArray with .weakMemory (weak semantics)
3. Use NSMapTable with appropriate memory options
Note: unowned in collections is an unusual pattern —
reconsider your design if you find yourself needing it.

---

Q62. What is the "zombie objects" debugging feature in Xcode
and how does it relate to ARC?
A:   Zombie Objects (enabled via Edit Scheme → Diagnostics):
- Overrides dealloc/deinit to NOT free memory
- Instead, overwrites the object with a "zombie" marker
- If the zombie is messaged (accessed after dealloc):
 Xcode catches it and prints which zombie class was hit
- Specific to Objective-C objects / NSObject subclasses
- For pure Swift classes: use AddressSanitizer instead
Relation to ARC: catches over-releases and dangling
pointer access that ARC should prevent but can fail
at in unsafe code or bridged ObjC APIs.

---

Q63. How does @escaping affect ARC behavior in async functions?
A:   In Swift async functions, closures passed as parameters
are implicitly non-escaping for synchronous code paths.
For async contexts:
- Closures in async functions run on an executor
- They ARE effectively escaping (survive suspension points)
- ARC retains captured values across suspension points
- [weak self] is important for long-running async tasks
With structured concurrency (async let, TaskGroup):
- The task captures its closure's values for its lifetime
- If VC is popped: task may still run, accessing
 dangling strong self
- Use [weak self] or Task cancellation to handle this

---

Q64. What is the isKnownUniquelyReferenced function and
how does it relate to ARC?
A:   isKnownUniquelyReferenced(&ref) returns true if the
given reference has exactly ONE strong reference.
Used to implement Copy-on-Write (CoW):
mutating func append(_ value: Int) {
   if !isKnownUniquelyReferenced(&storage) {
       storage = Storage(copying: storage)  // ARC copy
   }
   storage.buffer.append(value)
}
It accesses the strong reference count from the object
header WITHOUT going through the normal retain/release
path. Only works on Swift-native class types (not ObjC).
Returns false for ObjC objects (conservative).

---

Q65. How do you diagnose a memory leak in a Swift app
using Instruments?
A:   1. Product → Profile → Choose "Leaks" template
2. Run app and exercise the suspected flow
3. In Leaks track: look for red "X" marks (leaked allocations)
4. Click a leak: see the class type and allocation callstack
5. In Allocations track: use "Mark Generation" to take
  snapshots before and after suspected leak-causing action
6. Compare generations: objects that grew and weren't freed
  are likely leaked
7. Use "Generations" analysis to find the allocation site
8. Cross-reference with Memory Graph Debugger in Xcode
  for reference cycle visualization

────────────────────────────────────────────────────────────────────
SECTION 3: HARD / ADVANCED QUESTIONS (Q66–Q100)
────────────────────────────────────────────────────────────────────

Q66. Explain how swift_retain and swift_release are
implemented at the assembly level on ARM64.
A:   swift_retain (simplified ARM64):
 LDR  X1, [X0, #8]      // Load ref count word (offset 8 = after isa)
 ADD  X1, X1, #4        // Add increment (strong count is in upper bits)
 STR  X1, [X0, #8]      // Store back
In practice: uses LDADD (atomic load-add) or LDAR/STLR
pair for acquire-release memory ordering:
 LDADD X1, X2, [X0]     // atomic fetch-and-add
swift_release similarly but decrements and checks for
zero to trigger deallocation.
The reference count word bit layout (Apple's implementation):
 Bits 0-1: extra flags
 Bits 2-31: strong reference count (biased by +1)
 Bits 32-62: unowned reference count
 Bit 63: "use slow path" flag (side table present)

---

Q67. What is the "immortal" reference count and why do
some Swift objects have it?
A:   Certain objects are "immortal" — they should never be
deallocated. Examples: metatypes, global string literals,
static singletons. Swift sets their reference count to
a special IMMORTAL value (maximum count / special flag bit).
swift_retain and swift_release detect this value and
skip the increment/decrement entirely. This makes
immortal objects free to retain/release, used in:
- String literals (stored in .rodata segment)
- Class metadata objects
- _EmptyArrayStorage singleton
Implementation: Bit 63 (or a sentinel count value)
signals the immortal state to the ARC runtime.

---

Q68. Explain the "guaranteed self" optimization in ARC.
A:   Swift's ownership system includes a guarantee: within
a class method or property accessor, self is KNOWN to
be alive for the entire duration of the call.
The compiler exploits this to eliminate retain/release
calls on self within method bodies:
// Without optimization:
func doWork() {
   swift_retain(self)
   print(self.name)
   swift_release(self)
}
// With guaranteed self optimization:
func doWork() {
   print(self.name)   // no retain/release needed
}
This is safe because: the caller holds a strong reference
to self while calling the method. That reference keeps
self alive for the call's duration without additional retain.
Significant ARC reduction in tight method-call chains.

---

Q69. What is the "Swift retain count" vs "ObjC retain count"
discrepancy and when does it matter?
A:   [obj retainCount] in Objective-C returns a count that
DOES NOT match Swift's internal count directly because:
1. Swift's count is BIASED: stored as (actual_count + 1)
  to allow atomic check-for-zero on release
2. Side table interacts with the count
3. Compiler elisions mean the "in-flight" count varies
4. Immortal objects return UINT_MAX
WHEN IT MATTERS:
- Debugging: don't trust retainCount for cycle detection
 Use Memory Graph Debugger instead
- ObjC bridging: ObjC tools may misread Swift counts
- Never use retainCount in production logic —
 it is explicitly documented as unreliable

---

Q70. What happens to reference counting when a Swift class
conforms to Objective-C protocols via @objc?
A:   When a Swift class is exposed to ObjC (@objc, NSObject
subclass, or @objc protocol conformance):
1. The class gets an ObjC-compatible object layout
2. retain/release/autorelease ObjC methods are bridged
  to swift_retain/swift_release
3. ObjC APIs that return +1 (retain) or +0 (autorelease)
  objects interact with Swift's ARC via CF bridging
4. CF types bridged with as or as! use toll-free bridging:
  same memory, different retain/release semantics
5. CFRetain/CFRelease bypass Swift ARC — use Unmanaged<T>
  to bridge manually when needed
Gotcha: @objc dynamic methods may trigger ObjC's autorelease
pool for their return values even in Swift callers.

---

Q71. How does the Swift compiler handle ARC in generic
code and what are the performance implications?
A:   Generic functions must handle BOTH value types (no ARC)
and reference types (ARC needed). The compiler:
1. In optimized builds: specializes generics for each
  concrete type used (monomorphization). Reference-type
  specializations get ARC calls; value-type don't.
2. In unoptimized/large builds: uses "existential containers"
  or "type metadata" to dispatch retain/release through
  a value witness table (vwt).
3. Protocol constraints: if T: AnyObject, the compiler
  knows T is a reference type → can emit direct ARC calls
IMPLICATION: Generic code over value types is ARC-free
after specialization. Generic code over unconstrained T
may have extra metadata dispatch overhead in debug builds.

---

Q72. What is a "strong reference to a weak storage" pattern
and when would you use it?
A:   A pattern where a property stores a weak reference but
reads are made safe by immediately creating a strong
local copy:
class Cache {
   private weak var _value: ExpensiveObject?
   var value: ExpensiveObject {
       if let existing = _value { return existing }
       let new = ExpensiveObject()
       _value = new
       return new   // WRONG: returned strong ref released immediately
   }
}
The pattern is tricky: the returned strong reference
must be held by the CALLER, otherwise the object
is immediately released and _value becomes nil again.
CORRECT USE: Return the strong reference and let the
caller hold it. This creates a "cache that doesn't
prevent deallocation" — useful for memory-sensitive
caches where recreation is acceptable.

---

Q73. Explain how ARC interacts with Swift's Sendable
and actor isolation.
A:   Actors are classes → ARC manages their memory.
ISOLATION + ARC interaction:
1. Actor's internal state: accessed on the actor's
  serial executor. ARC operations on stored properties
  happen serially → no concurrent ARC races on the
  actor's properties themselves.
2. Crossing actor boundaries: captured values must be
  Sendable. Sendable value types: copied (ARC for any
  class properties inside). Sendable reference types:
  must be immutable or internally synchronized.
3. Non-Sendable classes: cannot cross actor boundaries.
  Prevents sharing mutable reference-counted objects
  across concurrent contexts — eliminates races at ARC
  AND data levels simultaneously.
4. Task captures: a Task's closure captures values with
  standard ARC. If the task outlives the VC, strong self
  keeps VC alive. Use [weak self] in Task closures.

---

Q74. What is the difference in ARC behavior between
a class stored in an Optional vs a non-Optional?
A:   Non-Optional strong reference:
var obj: MyClass = MyClass()   // always holds strong ref
RC never goes to 0 while obj is in scope.

Optional strong reference:
var obj: MyClass? = MyClass()  // strong ref, but can be nil
Setting obj = nil explicitly releases the strong reference.
RC decrements; if zero → deallocation.

Optional weak:
weak var obj: MyClass? = instance  // no RC increment
Automatically nil'd on deallocation.

ARC OVERHEAD:
Optional itself (the enum wrapper) has no additional ARC
cost for class types — the Optional's .some case holds
the class reference directly, and the compiler optimizes
Optional<AnyObject> to a nullable pointer internally.

---

Q75. How do you handle ARC correctly when bridging between
Swift and C using UnsafePointer?
A:   When passing Swift objects to C APIs:
Method 1: Unmanaged — manual retain/release
 let obj = MyClass()
 let ptr = Unmanaged.passRetained(obj).toOpaque()
 // Pass ptr to C API — obj's RC +1, not tracked by ARC
 // Later:
 let obj2 = Unmanaged<MyClass>.fromOpaque(ptr).takeRetainedValue()
 // takeRetainedValue: ARC takes over, RC -1 on release

Method 2: withExtendedLifetime
 withExtendedLifetime(obj) {
     let ptr = Unmanaged.passUnretained(obj).toOpaque()
     cFunction(ptr)
     // obj guaranteed alive for this block
 }

Method 3: @_silgen_name / bridging headers
 For tight integration, use bridging headers to let
 Clang/Swift coordinate ARC annotations.

DANGER: Passing a Swift object pointer to C without
retaining it → dangling pointer if Swift releases it.
ALWAYS retain before passing to C, release after.

---

Q76. What is "ARC forwarding" and how does it affect
performance in functional-style Swift code?
A:   ARC forwarding occurs when a value is passed through
a chain of functions. Without optimization, each
function boundary inserts retain/release:
func a(_ x: MyClass) { b(x) }
func b(_ x: MyClass) { c(x) }
func c(_ x: MyClass) { x.doWork() }
// Generates: retain entering a, release exiting a
//            retain entering b, release exiting b
//            retain entering c, release exiting c
With consuming parameter modifier (Swift 5.9):
func a(_ x: consuming MyClass) { b(x) }
// Ownership forwarded — no retain/release at boundary
The compiler's ARC optimization pass (arc-contract) also
eliminates many of these via "forwarding": detecting that
a retain + release can be removed as a pair when the
object's lifetime spans the entire chain.

---

Q77. How does weak interact with value types that contain
class references (mixed types)?
A:   You cannot directly make a value type (struct/enum)
reference weak. But:
1. A struct CONTAINING a class property: the class property
  participates in ARC normally. The struct itself does not.
2. A weak reference to a class that CONTAINS a struct:
  the weak reference is to the class; the struct inside
  is part of the class's memory and lives/dies with it.
3. Indirect enum (has class-like heap allocation):
  still cannot be directly weak — it's a value type.
4. Any/AnyObject existentials:
  weak var any: (any SomeProtocol)? works ONLY if
  SomeProtocol: AnyObject — because only then is
  the existential guaranteed to be a class type.

---

Q78. Explain the memory safety guarantees (or lack thereof)
provided by unowned(unsafe) compared to C pointers.
A:   unowned(unsafe) is semantically identical to a C raw pointer:
- No bounds checking
- No nil check on access
- No type safety beyond the Swift type system's static checks
- After deallocation: memory may be reused for another object
 of a DIFFERENT type — type-confused access
COMPARED TO C POINTERS:
Similarities:
- Both can dangled after the pointed-to memory is freed
- Both have zero runtime overhead
- Both risk undefined behavior on misuse
Differences:
- Swift's type system prevents casting unowned(unsafe) to
 arbitrary types without explicit unsafe operations
- Swift's memory model (SE-0458 strict flag) can warn about
 unowned(unsafe) uses
- In practice: use unowned(unsafe) ONLY for ObjC bridging
 or proven-safe performance-critical code with testing.

---

Q79. What are the ARC implications of using lazy stored
properties on class instances?
A:   A lazy property is initialized on first access.
For reference-type lazy properties on classes:
class MyClass {
   lazy var helper: Helper = Helper(owner: self)
}
ARC implications:
1. Helper is NOT retained until first access
2. Helper's init captures self → if Helper stores self
  strongly → CYCLE potential
3. After initialization: lazy var is a strong reference
  (normal ARC)
4. Thread safety: lazy is NOT thread-safe in Swift.
  Concurrent first access → multiple Helper instances
  may be created → ARC counts inflated → race condition.
FIX for thread safety: use a computed property with
a dispatch_once-like mechanism, or ensure single-threaded
first access. For cycle: make Helper hold unowned/weak
reference back to owner.

---

Q80. How does ARC handle circular references in a tree
data structure and what is the recommended pattern?
A:   Tree structures have two types of references:
PARENT → CHILD: parent owns children (strong)
CHILD → PARENT: back-reference (back-pointer)

Back-pointer determines the fix:
Option 1: weak var parent: TreeNode?
 - Parent might be nil (root has no parent)
 - Optional API matches reality
 - Correct for trees where nodes can be roots
Option 2: unowned var parent: TreeNode
 - Non-optional — every non-root node has a parent
 - Use when child ALWAYS has a parent (non-root nodes)
 - More expressive API

FULL EXAMPLE:
class TreeNode {
   var value: Int
   var children: [TreeNode] = []      // strong: parent owns children
   weak var parent: TreeNode?         // weak: child doesn't own parent

   init(_ value: Int) { self.value = value }

   func addChild(_ child: TreeNode) {
       children.append(child)
       child.parent = self
   }
   deinit { print("Node \(value) freed") }
}

var root: TreeNode? = TreeNode(1)
let child = TreeNode(2)
root?.addChild(child)
root = nil
// Node 1 freed (no cycle — child.parent is weak)
// Node 2 freed (root released children array)

---

Q81. What is the Swift runtime's behavior when deinit
is called while a weak reference is being read
on another thread?
A:   This is handled by the weak reference protocol's
atomic operations:
Thread A: reading weak ref (swift_weakLoadStrong)
 1. Loads side table pointer
 2. Checks state: LIVE
 3. Attempts compare-and-swap to increment strong count
Thread B: releasing last strong ref simultaneously
 1. Decrements strong count → 0
 2. Attempts to transition state to DEINITING
RACE RESOLUTION:
- CAS operations serialize the "last increment wins"
- If Thread A's CAS completes first: strong count > 0
 Thread B's release sees count > 0 → doesn't start deinit yet
 Thread A uses the object safely → releases → count = 0 → deinit
- If Thread B's transition completes first: deinit starts
 Thread A's CAS fails → returns nil (safe)
Either way: no crash, no dangling pointer.

---

Q82. How do capture lists interact with async/await and
actor isolation?
A:   In async closures and Task bodies:
1. [weak self] in async contexts:
  Task { [weak self] in
      await self?.loadData()    // self checked at each await
      // self might be nil after any await point
      // because another thread could release it between suspensions
  }
2. [weak self] + guard in async:
  Task { [weak self] in
      guard let self else { return }
      await self.fetchData()    // 'self' strong here but...
      // After await: self may have been released
      // The local 'self' constant kept it alive DURING fetchData
      // but the next line after await starts fresh
      self.updateUI()          // safe only if still alive
  }
3. Actor isolation + self:
  In actor-isolated methods, self is the actor.
  Actors use unowned self internally for isolation —
  the actor's lifetime is managed by the caller.
  [weak self] is still needed in non-isolated closures
  that might outlive the actor.

---

Q83. What is the "shorthand argument names" ARC subtlety
with closures in Swift?
A:   When using $0, $1 shorthand arguments in closures,
the closure still captures the enclosing scope's self
if self's methods/properties are used:
button.tapHandler = { [weak self] in
   self?.handleTap($0)    // $0 is the tap gesture parameter
}
vs:
button.tapHandler = { [weak self] gesture in
   self?.handleTap(gesture)
}
Both are equivalent from ARC perspective.
The subtle point: if $0 itself is a reference type
passed from the caller, ARC retains it for the
closure's duration. This is usually correct but
can be surprising if $0 should be weakly held:
// If the button passes self as $0:
button.tapHandler = { [weak view = $0 as? MyView] in
   view?.refresh()   // weak capture of the argument
}

---

Q84. How does deinit interact with property observers
(willSet/didSet) during deallocation?
A:   During deallocation, stored properties are released
directly by the runtime WITHOUT triggering willSet/didSet.
The deallocation path does NOT call property observers.
This is important:
- willSet/didSet side effects DO NOT run at dealloc time
- Any cleanup you expect in didSet won't happen on dealloc
- Must put cleanup logic in deinit directly
EXAMPLE:
class Logger {
   var logFile: FileHandle? {
       willSet { logFile?.closeFile() }   // NOT called on dealloc
   }
   deinit {
       logFile?.closeFile()    // Must explicitly close here
   }
}
ARC's deallocation path directly calls each property's
deinit (for class properties) without going through
the synthesized setter.

---

Q85. What is "lifetime extension" via withExtendedLifetime
and when is it needed?
A:   The Swift compiler can optimize code by ending an object's
lifetime early if it determines the object is no longer
USED — even if the variable binding is still in scope.
Example where this is a problem:
var obj = MyObject()
let ptr = UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
callCFunction(ptr)    // compiler may have released obj BEFORE this!
// Because 'obj' variable isn't "used" after ptr creation

FIX: withExtendedLifetime guarantees obj lives until
the closure completes:
withExtendedLifetime(obj) {
   callCFunction(ptr)   // obj GUARANTEED alive here
}
Also useful in:
- C-interop with unretained pointers
- Low-level performance code with manual lifetime management
- Testing ARC optimization behavior

---

Q86. How does ARC handle protocol existentials (any Protocol)
and what are the boxing implications?
A:   A protocol existential (any Protocol value) is stored in
an "existential container" — a fixed-size buffer of 3 words:
Word 1-3: inline value buffer (for small values)
         OR pointer to heap box (for large values)
Word 4: pointer to value witness table (VWT)
Word 5: pointer to protocol conformance table (PCT)

ARC IMPLICATIONS:
1. If the concrete type is a class: the inline buffer
  stores the class reference directly → ARC retains the class
2. If the concrete type is a large struct: the existential
  BOXES it on the heap → ARC manages the box
3. Small structs (fits in 3 words): stored inline → no heap
  allocation, no ARC overhead
4. Protocol composition (any A & B): may require separate boxes
  for each protocol's conformance → more overhead

PERFORMANCE IMPACT:
Frequent boxing/unboxing of existentials in tight loops
can cause significant ARC overhead + heap allocation.
Prefer generics (func f<T: Protocol>(_ x: T)) over
existentials (func f(_ x: any Protocol)) for performance-critical code.

---

Q87. Explain how ARC interacts with Swift's value witness
table (VWT) for retain/release of generic types.
A:   The Value Witness Table (VWT) is a per-type table of
function pointers for type-specific memory operations:
- initializeWithCopy: copy-initialize a value
- assignWithCopy: copy-assign a value
- initializeWithTake: move-initialize a value
- destroy: destroy a value (release for classes)
- size, stride, alignment metadata

For REFERENCE TYPES (classes):
- initializeWithCopy → swift_retain + pointer copy
- assignWithCopy → swift_retain new + swift_release old + copy
- destroy → swift_release

For VALUE TYPES without class fields:
- All operations are simple memory copies / no ARC

For VALUE TYPES WITH class fields (struct with class property):
- VWT operations call the class field's retain/release
- The struct itself has no independent ARC, but propagates
 ARC calls to its class-typed stored properties

Generic functions call through VWT:
func copy<T>(_ value: T) -> T {
   // Calls vwt.initializeWithCopy — ARC if T is a class
}

---

Q88. What is the ARC behavior of a class with multiple
inheritance levels and deinit chaining?
A:   Swift classes support single inheritance. deinit is
called in reverse initialization order:
1. Most-derived deinit called first
2. Automatically calls super's deinit (no explicit super.deinit())
3. Up the inheritance chain to NSObject/AnyObject
4. Each level's stored properties released after its deinit
5. ARC releases all strong references in each level

class Animal {
   var name: String
   deinit { print("Animal deinit: \(name)") }
}
class Dog: Animal {
   var breed: String
   deinit { print("Dog deinit: \(breed)") }
   // super.deinit called automatically after this
}
class GoldenRetriever: Dog {
   deinit { print("GoldenRetriever deinit") }
   // Calls Dog.deinit then Animal.deinit automatically
}
// Output on deallocation:
// "GoldenRetriever deinit"
// "Dog deinit: Golden"
// "Animal deinit: Buddy"

---

Q89. How does Swift's LLVM IR represent retain and release
operations and what optimizations does LLVM apply?
A:   In Swift's LLVM IR, ARC operations appear as:
call void @swift_retain(%swift.refcounted* %obj)
call void @swift_release(%swift.refcounted* %obj)
call %swift.refcounted* @swift_weakLoadStrong(...)

LLVM OPTIMIZATIONS applied by the ARC optimizer pass:
1. Retain/release pairing elimination:
  Consecutive retain + release on the same object
  with no observable use in between → REMOVED
2. Retain sinking / Release hoisting:
  Move retains closer to uses, releases closer to last use
  to minimize the "live range" of retains
3. Code motion across conditionals:
  Merge retain/release calls from if/else branches
  into a single call after the branch
4. Clang __attribute__((ns_returns_retained)):
  Signals to LLVM that a function returns a +1 object
  → avoids double-retain at call sites
5. OSSA (Ownership SSA) in Swift 5.x compiler:
  Intermediate representation that tracks ownership
  explicitly, enabling more aggressive ARC elimination

---

Q90. What are the memory implications of using
withCheckedContinuation in Swift concurrency?
A:   withCheckedContinuation bridges callback-based APIs to
async/await. ARC implications:
1. The continuation object is heap-allocated
2. It strongly captures the resumption context
3. The callback closure that calls continuation.resume()
  must retain the continuation until resume() is called
4. resume() must be called EXACTLY ONCE:
  - Not called: continuation leaked (memory leak +
    task never completes = task leak)
  - Called twice: crash (checked variant traps on this)
ARC PATTERN:
let result = await withCheckedContinuation { continuation in
   someAsyncAPI { [continuation] value in
       // continuation captured strongly — correct
       // 'continuation' has value semantics but internally
       // references heap-allocated state
       continuation.resume(returning: value)
       // After resume: continuation's internal state freed
   }
}
withCheckedContinuation (vs withUnsafeContinuation):
Checked variant verifies single-resume and not-leaked —
small overhead but catches ARC/lifetime bugs in debug builds.

---

Q91. How does the "semantic arc optimizer" in the Swift
compiler differ from standard LLVM ARC optimization?
A:   Swift has TWO levels of ARC optimization:
LEVEL 1: Swift's Semantic ARC Optimizer (in SIL — Swift IR):
 - Operates on Swift Intermediate Language (SIL)
 - Understands Swift semantics: ownership, borrowing,
   guaranteed parameters, inout exclusivity
 - Can eliminate retains on "guaranteed" parameters
   (parameters the callee doesn't own)
 - Performs "borrow introduction": turns short-lived
   strong references into borrows (no retain/release)
 - OSSA (Ownership SSA) form enables precise tracking

LEVEL 2: LLVM ARC Optimizer (in LLVM IR):
 - More conservative: doesn't know Swift semantics
 - Treats retain/release as generic function calls
 - Uses alias analysis to prove retain/release pairs safe
 - Performs code motion and elimination on the IR level

The two-level approach catches more opportunities than
either level alone. Swift 5.7+ OSSA form enables the
Swift-level optimizer to be significantly more aggressive.

---

Q92. What is the ARC behavior difference between
class final and non-final classes?
A:   NON-FINAL class:
 - Methods dispatched via vtable (dynamic dispatch)
 - Compiler cannot always see the exact type
 - Cannot always prove aliasing rules → more conservative ARC
 - retain/release calls less likely to be optimized away

final class (or @_optimize(none) disabled):
 - No subclassing possible → compiler knows exact type
 - Static dispatch → inlining possible
 - Better ARC optimization: compiler can see through
   method calls and prove object liveness
 - Can elide retain/release more aggressively

PERFORMANCE RECOMMENDATION:
Mark classes as final when subclassing is not needed.
This enables both ARC optimization AND faster dispatch.
Protocol-oriented design with final classes gives best
of both worlds: polymorphism via protocols, performance
via final ARC optimization.

---

Q93. What is the implication of calling objc_loadWeakRetained
vs swift_weakLoadStrong in a mixed Swift/ObjC codebase?
A:   objc_loadWeakRetained (Objective-C ARC):
 - Loads weak reference and retains if non-nil
 - Uses ObjC runtime's weak reference tables (hash table)
 - Per-object weak tracking (not per-side-table)
 - Slower than Swift's mechanism for large weak ref counts

swift_weakLoadStrong (Swift ARC):
 - Loads weak reference via side table
 - Per-object side table (created lazily)
 - Atomic CAS-based retain during load
 - Faster for typical Swift object weak ref patterns

MIXED CODEBASE IMPLICATIONS:
1. NSObject subclasses in Swift: use ObjC weak tables
  (bridged from Swift weak storage to ObjC mechanism)
2. Pure Swift classes: use Swift side tables
3. @objc marked Swift classes: hybrid behavior
4. If you profile weak-heavy code in a mixed app:
  ObjC weak tables can be a bottleneck due to global
  hash table lock contention under concurrent access.
  Prefer pure Swift classes for high-concurrency code.

---

Q94. How should you structure ownership to avoid retain
cycles in a reactive/Combine-based architecture?
A:   Combine uses closures and publishers — prime cycle territory.

PATTERN 1: sink with [weak self]:
cancellable = publisher
   .sink { [weak self] value in
       self?.handle(value)
   }

PATTERN 2: Operator chain cycle risk:
// WRONG — self retains the chain via AnyCancellable
// Chain captures self via closure → cycle
self.cancellable = self.subject
   .map { self.transform($0) }    // strong self!
   .sink { self.process($0) }     // strong self!

// FIX:
self.cancellable = self.subject
   .map { [weak self] in self?.transform($0) }
   .compactMap { $0 }
   .sink { [weak self] in self?.process($0) }

PATTERN 3: Store cancellables in Set<AnyCancellable>:
// AnyCancellable stored in self → self → AnyCancellable
// → closure → self = CYCLE
// Fix: [weak self] in all closures in the chain

PATTERN 4: @Published + onReceive (SwiftUI):
.onReceive(viewModel.$data) { [weak viewModel] data in
   // Usually fine — SwiftUI manages the subscription
   // but explicit weak is safer
}

ARCHITECTURAL FIX:
Use a coordinator/store object that neither the View
nor the ViewModel strongly owns — breaks the graph
topology that leads to cycles.

---

Q95. What is the behavior of ARC when using property
wrappers that wrap class types?
A:   Property wrappers are structs that hold a wrappedValue.
ARC for the wrapped class type propagates through the struct:
@propertyWrapper
     func setCheck(_ condition: @autoclosure @escaping () -> Bool) {
         check = condition   // escaping @autoclosure
 struct Logged<T: AnyObject> {
    var wrappedValue: T {       // T is a class → ARC manages T
        didSet { log(wrappedValue) }
    }
    init(wrappedValue: T) { self.wrappedValue = wrappedValue }
 }
 class Owner {
    @Logged var helper: Helper = Helper()
    // Owner.helper → Logged<Helper> struct (inline in Owner)
    // Logged._wrappedValue: Helper (strong reference)
    // No cycle unless Helper also references Owner
 }
 CYCLE RISK with property wrappers:
  If the wrapper stores a CLOSURE that captures owner:
  @propertyWrapper
  struct Observed<T: AnyObject> {
      var wrappedValue: T
      var onChange: ((T) -> Void)?       // closure stored in wrapper
      // If onChange captures the Owner → CYCLE:
      // Owner → @Observed struct → onChange closure → Owner
  }
  class Owner {
      @Observed(onChange: { [weak owner = ???] newVal in
          // Can't easily reference Owner here at init time
      })
      var helper: Helper = Helper()
  }
  FIX: Set the closure AFTER initialization:
  class Owner {
      @Observed var helper: Helper = Helper()
      init() {
          _helper.onChange = { [weak self] newVal in
              self?.handleChange(newVal)   // weak — no cycle
          }
      }
  }
  KEY INSIGHT: Property wrappers are structs stored INLINE
  in the enclosing type. The wrapper itself adds no ARC cost.
  ARC cost comes from the class values the wrapper HOLDS.

 ---

 Q96. How does ARC behave with recursive closures
  that capture themselves?
 A:   A closure cannot directly capture itself because at the
  point of creation the closure doesn't exist yet.
  Naive attempt causes a compiler error or cycle:
  // This doesn't compile directly:
  var recurse: (() -> Void)?
  recurse = {
      recurse?()   // captures 'recurse' variable, not closure itself
  }
  ARC ANALYSIS:
  var recurse: (() -> Void)?  // optional strong reference to closure
  recurse = { recurse?() }   // closure captures 'recurse' variable
                             // via reference to the binding, not value
  CYCLE: the variable 'recurse' holds the closure (strong)
         the closure captures the variable binding (strong)
         = CYCLE if recurse is a property of a class instance

  FIX 1: Use [weak] on the variable via a wrapper:
  class Runner {
      var recurse: (() -> Void)?

      func setup() {
          recurse = { [weak self] in
              self?.recurse?()   // self weak — no cycle
          }
      }
      deinit { print("Runner freed") }
  }

  FIX 2: Use a Y-combinator pattern for pure functions:
  func makeRecursive<T>(_ f: @escaping (@escaping (T) -> T) -> (T) -> T) -> (T) -> T {
      var result: ((T) -> T)!
      result = f { x in result(x) }
      return result
  }
  // result is implicitly unwrapped — use with care

 ---

 Q97. What are the ARC implications of using @autoclosure
  and how can it create unexpected retains?
 A:   @autoclosure wraps an expression in a closure automatically.
  The closure is an escaping closure → ARC retains all captured values.
  func assert(_ condition: @autoclosure () -> Bool,
              _ message: @autoclosure () -> String) { }

  ARC SUBTLETY:
  assert(expensiveObject.isValid, expensiveObject.debugDescription)
  // Both arguments are wrapped in closures
  // Each closure retains 'expensiveObject' strongly
  // For the duration of the assert call
  // In Release builds: assert is a no-op but closures
  // may STILL be created and immediately discarded
  // depending on compiler optimization level

  CYCLE RISK with stored @autoclosure:
  class Validator {
      var check: (() -> Bool)?   // stored closure
     }
 }
 class Form {
     var validator = Validator()
     var data: String = ""
     func setup() {
         validator.setCheck(self.data.isEmpty)
         // self.data.isEmpty wrapped in closure → retains self
         // Form → validator → check → self = CYCLE
     }
 }
 FIX: Use [weak self] by passing an explicit closure:
 validator.check = { [weak self] in self?.data.isEmpty ?? true }

---

Q98. How does Swift's optimizer handle ARC for local
 variables that never escape their function scope?
A:   For local variables that are PROVABLY non-escaping:
 the compiler applies STACK PROMOTION — allocating the
 object on the STACK instead of the heap, eliminating
 ARC entirely.
 CONDITIONS for stack promotion:
 1. Object never passed to an escaping closure
 2. Object never stored in a long-lived container
 3. Object doesn't cross thread boundaries
 4. Object's lifetime fits within the function scope
 5. Class is final (so size is known statically)
 RESULT: No heap allocation, no retain/release.
 The object is destroyed when the function returns
 (stack frame popped) — zero ARC overhead.
 HOW TO VERIFY:
 Use -Xfrontend -emit-sil in Xcode build settings
 to inspect SIL output. Stack-promoted objects show
 alloc_stack instead of alloc_ref in the SIL.
 PRACTICAL IMPACT:
 Local helper objects in performance-critical functions
 (parsers, renderers) can be zero-ARC if designed correctly:
 - Declare as final class
 - Don't escape (no @escaping captures)
 - Don't store in instance properties
 Many standard library algorithms use this internally.

---

Q99. What is the ARC behavior difference between
 [weak self] in a Swift async Task vs a Combine sink,
 and which is more dangerous without it?
A:   COMBINE SINK without [weak self]:
 subscription = publisher.sink { value in
     self.process(value)   // strong self retained by closure
 }
 DANGER LEVEL: HIGH if stored in self
 CYCLE: self → AnyCancellable → sink closure → self
 LIFETIME: self kept alive as long as subscription lives
 SYMPTOM: VC never deallocated; deinit never called

 SWIFT ASYNC TASK without [weak self]:
 Task {
     await self.loadData()   // strong self retained by task
 }
 DANGER LEVEL: MEDIUM-LOW
 CYCLE: No permanent cycle — Task completes and releases
 LIFETIME: self kept alive until task completes
 SYMPTOM: VC lives longer than expected (brief leak)
           Not a permanent leak unless task runs forever

 COMPARISON:
 Combine sink:  PERMANENT cycle if stored in self's property
               MUST use [weak self]
 Task:          TEMPORARY extension of self's lifetime
               [weak self] recommended but not always critical
               EXCEPTION: infinite tasks (polling, streams)
               → treat like Combine → MUST use [weak self]

 RULE OF THUMB:
 Any closure/task that runs REPEATEDLY or INDEFINITELY
 and captures self → MUST use [weak self]
 One-shot tasks → [weak self] recommended but not critical
 Stored closures on self → ALWAYS [weak self]

---

Q100. Design a fully ARC-safe observer system in Swift that:
  (a) doesn't retain observers, (b) auto-cleans dead refs,
  (c) is thread-safe, (d) supports typed payloads.
A:
 // ── Typed Weak Observer Container ──────────────────────────────

 // Thread-safe lock wrapper
 final class Lock {
     private var unfairLock = os_unfair_lock()
     func withLock<T>(_ body: () -> T) -> T {
         os_unfair_lock_lock(&unfairLock)
         defer { os_unfair_lock_unlock(&unfairLock) }
         return body()
     }
 }

 // Weak reference wrapper
 private final class WeakBox<T: AnyObject> {
     weak var value: T?
     let id: ObjectIdentifier
     init(_ value: T) {
         self.value = value
         self.id = ObjectIdentifier(value)
     }
 }

 // Typed observable event bus
 final class EventBus<Payload> {
     private var observers: [WeakBox<AnyObject>] = []
     private var handlers:  [ObjectIdentifier: (Payload) -> Void] = [:]
     private let lock = Lock()

     // (a) Weak storage — does NOT retain observer
     func subscribe(_ observer: AnyObject,
                    handler: @escaping (Payload) -> Void) {
         lock.withLock {
             let box = WeakBox(observer)
             observers.append(box)
             handlers[box.id] = handler
         }
     }

     // Remove a specific observer
     func unsubscribe(_ observer: AnyObject) {
         let id = ObjectIdentifier(observer)
         lock.withLock {
             observers.removeAll { $0.id == id }
             handlers.removeValue(forKey: id)
         }
     }

     // (b) Auto-clean + (c) thread-safe emit
     func emit(_ payload: Payload) {
         let snapshot: [(WeakBox<AnyObject>, (Payload) -> Void)]
         lock.withLock {
             // (b) Prune dead refs BEFORE iterating
             observers.removeAll { $0.value == nil }
             observers.forEach { box in
                 if box.value == nil {
                     handlers.removeValue(forKey: box.id)
                 }
             }
             // Snapshot to release lock during callbacks
             snapshot = observers.compactMap { box in
                 guard let _ = box.value,
                       let handler = handlers[box.id]
                 else { return nil }
                 return (box, handler)
             }
         }
         // Call handlers OUTSIDE lock — prevents deadlock
         snapshot.forEach { box, handler in
             guard box.value != nil else { return }
             handler(payload)
         }
     }
 }

 // ── USAGE ───────────────────────────────────────────────────────

 // (d) Typed payload
 struct UserEvent {
     let userId: String
     let action: String
 }

 let bus = EventBus<UserEvent>()

 class AnalyticsService {
     init(bus: EventBus<UserEvent>) {
         bus.subscribe(self) { [weak self] event in
             self?.track(event)   // [weak self] — belt+suspenders
         }
     }
     func track(_ event: UserEvent) {
         print("Track: \(event.userId) did \(event.action)")
     }
     deinit { print("AnalyticsService freed") }
 }

 class LoginViewController {
     let analytics: AnalyticsService
     let bus: EventBus<UserEvent>

     init(bus: EventBus<UserEvent>) {
         self.bus = bus
         self.analytics = AnalyticsService(bus: bus)
         // ✓ No cycle:
         // bus does NOT retain analytics (WeakBox)
         // analytics does NOT retain bus (bus passed in)
     }
     func userDidLogin(id: String) {
         bus.emit(UserEvent(userId: id, action: "login"))
     }
     deinit { print("LoginVC freed") }
 }

 var vc: LoginViewController? = LoginViewController(bus: bus)
 vc?.userDidLogin(id: "user123")   // "Track: user123 did login"

 vc = nil
 // "AnalyticsService freed"  ← deinit called (no cycle)
 // "LoginVC freed"           ← deinit called (no cycle)

 bus.emit(UserEvent(userId: "x", action: "test"))
 // No output — dead WeakBoxes pruned automatically (b)

 // ARC SAFETY ANALYSIS:
 // ✓ (a) WeakBox.value is weak — doesn't retain observers
 // ✓ (b) removeAll{$0.value == nil} prunes dead refs
 // ✓ (c) os_unfair_lock protects mutation + reads
 // ✓ (d) EventBus<Payload> is fully generic / typed
 // ✓ No retain cycle anywhere in the graph

=======================================================================
END OF NOTES
=======================================================================
QUICK REFERENCE CHEAT SHEET
=======================================================================

ARC FUNDAMENTALS:
✓ ARC applies to:       class instances and closures ONLY
✓ ARC does NOT apply:   struct, enum, Int, Double, Bool, tuple
✓ Object deallocated:   when strong reference count = 0
✓ deinit called:        immediately when RC = 0
✓ Thread safety:        retain/release are atomic (lock-free)
✓ Cycles:               NOT auto-collected — use weak/unowned

OBJECT HEADER (16 bytes):
Word 1: isa pointer (vtable/metadata)
Word 2: RC word (strong | unowned | flags)
Side table (lazy): weak count + lifecycle state

THREE-WAY REFERENCE COMPARISON:
strong   → RC++, RC-- on release, object kept alive
weak     → no RC change, Optional, auto-nil on dealloc, side table
unowned  → no RC change, non-Optional, CRASH if accessed after dealloc

DECISION RULE:
Does this reference NEED to keep the object alive?
YES  → strong (default)
NO   → Does the object EVER become nil before access?
     YES / UNSURE → weak  (safe, Optional)
     NO (guaranteed alive) → unowned (fast, non-Optional)

RETAIN CYCLE PATTERNS + FIXES:
Class ↔ Class:       make one side weak (usually back-ref / delegate)
Class ↔ Closure:     use [weak self] or [unowned self] in capture list
Delegate:            always weak var delegate: (any Protocol)?
Timer:               [weak self] in block + invalidate in deinit
Notification:        removeObserver in deinit or viewDidDisappear
Combine sink:        [weak self] in all closures stored on self
async Task:          [weak self] for long-running or infinite tasks

TWO-PHASE DEALLOCATION:
Phase 1: strong RC → 0
→ deinit() called
→ body memory freed
→ weak refs zeroed to nil
Phase 2: unowned RC → 0 (after Phase 1)
→ header memory freed
→ side table freed (if weak RC also = 0)

weak ZEROING MECHANISM:
weak var stores pointer to SIDE TABLE (not object)
When object dies: side table state → "dead"
Reading weak ref: atomic CAS retain or nil — no dangling pointer ever

CAPTURE LIST SYNTAX:
{ [weak self] in self?.method() }            // weak, Optional
{ [unowned self] in self.method() }          // unowned, non-Optional
{ [weak self, unowned mgr] in ... }          // multiple captures
{ [value] in print(value) }                  // value copy at creation
{ [weak self = other] in self?.method() }    // renamed capture

WHEN [weak self] IS REQUIRED:
✓ Escaping closure stored as property of self
✓ Combine sink stored in self's cancellable set
✓ Timer block when timer stored on self
✓ Delegate callback that self holds
✗ Non-escaping closures (e.g., map, filter, sort)
✗ [weak self] without self being in a cycle (often unnecessary)

DEBUGGING TOOLKIT:
1. deinit { print("\(type(of:self)) freed") }  ← first line of defense
2. Xcode Memory Graph Debugger                 ← visualize cycles
3. Instruments → Leaks template               ← detect leaked objects
4. Instruments → Allocations → Generations    ← confirm leaks over time
5. Address Sanitizer                           ← use-after-free detection
6. Thread Sanitizer                            ← ARC race conditions

ARC PERFORMANCE TIPS:
✓ final class: enables ARC + dispatch optimizations
✓ borrowing parameters: eliminate retain/release at call boundaries
✓ consuming parameters: transfer ownership without copy
✓ ~Copyable types: prevent accidental copies entirely
✓ autoreleasepool in loops: control peak memory in ObjC-heavy code
✓ Stack promotion: local final class objects with no escape = zero ARC
✓ isKnownUniquelyReferenced: implement CoW to avoid unnecessary copies

COMMON BUGS & SYMPTOMS:
VC not deallocated after pop  → retain cycle (check delegate, closures)
deinit never called           → cycle somewhere — use Memory Graph
Timer keeps firing after gone → timer not invalidated + cycle
Memory grows steadily         → repeated leak in loop/navigation
Crash "unowned was deallocated"→ unowned accessed after object freed
Crash "bad access"            → unowned(unsafe) or dangling pointer
Closure called on dead VC     → missing [weak self] in async work

=======================================================================

 */
