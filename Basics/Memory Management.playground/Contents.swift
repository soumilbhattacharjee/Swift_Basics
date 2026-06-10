import UIKit

/*
 MEMORY MANAGEMENT IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ARC, strong, weak, unowned, cycles, closures, value types
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 PART 1 — WHAT IS MEMORY MANAGEMENT?
 ================================================================

 WHAT IS MEMORY MANAGEMENT?
 ===========================
 Memory management controls how memory is allocated,
 used, and freed during a program's lifetime.
 In Swift, this is handled automatically via
 Automatic Reference Counting (ARC).

 TWO TYPES OF MEMORY
 ====================
 Stack:
   - Stores value types (Int, Bool, struct, enum, tuple)
   - Allocation and deallocation are automatic and instant
   - LIFO (Last In First Out) — very fast
   - Size determined at compile time
   - Each thread has its own stack

 Heap:
   - Stores reference types (class instances, closures)
   - Managed by ARC
   - Size can grow and shrink at runtime
   - Shared across threads — requires synchronization
   - Slower than stack due to ARC overhead

 SUMMARY TABLE
 =============
 Feature            | Stack (Value Types)    | Heap (Reference Types)
 -------------------|------------------------|------------------------
 Types stored       | struct, enum, tuple    | class, closure
 Management         | Automatic by compiler  | ARC
 Speed              | Very fast              | Slower (ARC overhead)
 Thread safety      | Each thread own stack  | Shared, needs care
 Copies             | Independent copies     | Shared references
 Memory cycles      | Not possible           | Possible


 ================================================================
 PART 2 — AUTOMATIC REFERENCE COUNTING (ARC)
 ================================================================

 WHAT IS ARC?
 ============
 ARC automatically tracks and manages memory for
 class instances. It keeps a reference count for
 each class instance. When the count drops to zero,
 the instance is deallocated automatically.
 ARC was introduced in 2011, replacing manual
 retain/release (MRR) calls.

 HOW ARC WORKS
 =============
   - When you create a class instance, ARC allocates
     memory and sets the reference count to 1.
   - Each time you assign the instance to a new
     variable, constant, or property, the count increases.
   - When a variable, constant, or property goes out
     of scope, the count decreases.
   - When the count reaches 0, deinit is called
     and memory is freed.

 BASIC ARC EXAMPLE
 ==================
   class Person {
       let name: String
       init(name: String) {
           self.name = name
           print("Person \(name) initialized")
       }
       deinit {
           print("Person \(name) deinitialized")
       }
   }

   var ref1: Person? = Person(name: "Alice")
   // Output: Person Alice initialized
   // Reference count: 1

   var ref2 = ref1
   // Reference count: 2

   var ref3 = ref1
   // Reference count: 3

   ref1 = nil
   // Reference count: 2 — no deallocation yet

   ref2 = nil
   // Reference count: 1 — no deallocation yet

   ref3 = nil
   // Reference count: 0 — deallocated
   // Output: Person Alice deinitialized

 ARC WITH FUNCTION SCOPE
 ========================
   func createPerson() {
       let p = Person(name: "Bob")
       // Reference count: 1
       print("Inside function: \(p.name)")
   }   // p goes out of scope — count drops to 0

   createPerson()
   // Output: Person Bob initialized
   //         Inside function: Bob
   //         Person Bob deinitialized

 ARC DOES NOT APPLY TO VALUE TYPES
 ===================================
   struct Point {
       var x: Int
       var y: Int
   }

   var p1 = Point(x: 1, y: 2)
   var p2 = p1          // independent copy — no ARC
   p2.x = 99
   print(p1.x)          // p1 is unaffected
   // Output: 1
   print(p2.x)
   // Output: 99


 ================================================================
 PART 3 — STRONG REFERENCES
 ================================================================

 WHAT IS A STRONG REFERENCE?
 ============================
 By default, every reference to a class instance is strong.
 A strong reference increases the reference count by 1.
 The instance is kept alive as long as at least one
 strong reference exists.
 Strong references are the default — no keyword needed.

 BASIC STRONG REFERENCE
 =======================
   class Car {
       let model: String
       init(model: String) {
           self.model = model
           print("Car \(model) created")
       }
       deinit { print("Car \(model) destroyed") }
   }

   var car1: Car? = Car(model: "Tesla")
   // Output: Car Tesla created
   // Reference count: 1

   var car2: Car? = car1       // strong reference
   // Reference count: 2

   car1 = nil
   // Reference count: 1 — still alive

   car2 = nil
   // Reference count: 0
   // Output: Car Tesla destroyed

 STRONG REFERENCE IN PROPERTY
 ==============================
   class Engine {
       let horsepower: Int
       init(hp: Int) {
           self.horsepower = hp
           print("Engine \(hp)hp created")
       }
       deinit { print("Engine \(horsepower)hp destroyed") }
   }

   class SportsCar {
       let model: String
       var engine: Engine      // strong reference to Engine
       init(model: String, engine: Engine) {
           self.model = model
           self.engine = engine
           print("SportsCar \(model) created")
       }
       deinit { print("SportsCar \(model) destroyed") }
   }

   var myCar: SportsCar? = SportsCar(
       model: "Ferrari",
       engine: Engine(hp: 500)
   )
   // Output: Engine 500hp created
   //         SportsCar Ferrari created

   myCar = nil
   // Output: SportsCar Ferrari destroyed
   //         Engine 500hp destroyed
   // Engine is also deallocated because SportsCar held
   // the only strong reference to it


 ================================================================
 PART 4 — STRONG REFERENCE CYCLES
 ================================================================

 WHAT IS A STRONG REFERENCE CYCLE?
 ===================================
 A strong reference cycle (retain cycle) occurs when
 two or more class instances hold strong references
 to each other, preventing either from ever reaching
 a reference count of zero. This causes a memory leak.

 BASIC STRONG REFERENCE CYCLE
 ==============================
   class Person2 {
       let name: String
       var apartment: Apartment?      // strong reference
       init(name: String) {
           self.name = name
           print("Person2 \(name) initialized")
       }
       deinit { print("Person2 \(name) deinitialized") }
   }

   class Apartment {
       let unit: String
       var tenant: Person2?           // strong reference
       init(unit: String) {
           self.unit = unit
           print("Apartment \(unit) initialized")
       }
       deinit { print("Apartment \(unit) deinitialized") }
   }

   var alice: Person2? = Person2(name: "Alice")
   var apt: Apartment? = Apartment(unit: "4A")
   // Output: Person2 Alice initialized
   //         Apartment 4A initialized
   // alice ref count: 1
   // apt ref count: 1

   alice!.apartment = apt       // apt ref count: 2
   apt!.tenant = alice          // alice ref count: 2

   alice = nil                  // alice ref count: 1 — NOT freed
   apt = nil                    // apt ref count: 1 — NOT freed

   // MEMORY LEAK — neither deinit is called
   // Neither object is ever freed
   // Output: (nothing — deinit never called)

 VISUALIZING THE CYCLE
 ======================
   Before nil:
     alice (variable) ──strong──► Person2 instance
     apt (variable)   ──strong──► Apartment instance
     Person2.apartment ──strong──► Apartment instance
     Apartment.tenant  ──strong──► Person2 instance

   After alice = nil, apt = nil:
     Person2 instance ──strong──► Apartment instance
     Apartment instance ──strong──► Person2 instance
     Both have ref count 1 — neither can be freed


 ================================================================
 PART 5 — WEAK REFERENCES
 ================================================================

 WHAT IS A WEAK REFERENCE?
 ==========================
 A weak reference does NOT increase the reference count.
 It allows the referenced instance to be deallocated
 even while the weak reference still exists.
 When the instance is deallocated, the weak reference
 is automatically set to nil.
 Therefore, weak references are always Optional (var, not let).
 Use weak when the referenced object can become nil
 during the weak reference's lifetime.
 Declared with the weak keyword.

 SYNTAX
 =======
   weak var propertyName: TypeName?

 BASIC WEAK REFERENCE
 =====================
   class Person3 {
       let name: String
       weak var friend: Person3?      // weak reference
       init(name: String) {
           self.name = name
           print("Person3 \(name) initialized")
       }
       deinit { print("Person3 \(name) deinitialized") }
   }

   var alice: Person3? = Person3(name: "Alice")
   var bob:   Person3? = Person3(name: "Bob")
   // Output: Person3 Alice initialized
   //         Person3 Bob initialized

   alice!.friend = bob    // weak — does NOT increase bob's count
   bob!.friend = alice    // weak — does NOT increase alice's count

   // Bob's ref count: 1 (only the bob variable)
   // Alice's ref count: 1 (only the alice variable)

   bob = nil
   // Bob's ref count: 0 — deallocated
   // Output: Person3 Bob deinitialized

   print(alice!.friend)   // automatically set to nil
   // Output: nil

   alice = nil
   // Output: Person3 Alice deinitialized

 FIXING THE APARTMENT CYCLE WITH WEAK
 ======================================
   class Resident {
       let name: String
       var home: Unit?               // strong — Resident owns Unit
       init(name: String) {
           self.name = name
           print("Resident \(name) initialized")
       }
       deinit { print("Resident \(name) deinitialized") }
   }

   class Unit {
       let number: String
       weak var resident: Resident?  // weak — Unit does NOT own Resident
       init(number: String) {
           self.number = number
           print("Unit \(number) initialized")
       }
       deinit { print("Unit \(number) deinitialized") }
   }

   var john: Resident? = Resident(name: "John")
   var unit: Unit? = Unit(number: "12B")
   // Output: Resident John initialized
   //         Unit 12B initialized

   john!.home = unit           // unit ref count: 2
   unit!.resident = john       // weak — john ref count stays 1

   john = nil
   // john ref count: 0 — deallocated
   // Output: Resident John deinitialized
   // unit ref count: 1 — still alive (john variable gone,
   //   but unit variable still holds it)

   print(unit!.resident)       // automatically nil
   // Output: nil

   unit = nil
   // unit ref count: 0 — deallocated
   // Output: Unit 12B deinitialized
   // NO memory leak — both freed correctly


 ================================================================
 PART 6 — UNOWNED REFERENCES
 ================================================================

 WHAT IS AN UNOWNED REFERENCE?
 ==============================
 An unowned reference does NOT increase the reference count.
 Unlike weak, it is NOT optional and is NOT set to nil
 when the referenced instance is deallocated.
 If you access an unowned reference after the instance
 is deallocated, the program crashes (similar to force
 unwrapping nil).
 Use unowned when you are certain the referenced object
 will always outlive the unowned reference.
 Declared with the unowned keyword.

 SYNTAX
 =======
   unowned var/let propertyName: TypeName    // non-optional
   unowned(safe) var propertyName: TypeName  // default
   unowned(unsafe) var propertyName: TypeName // no ARC check

 BASIC UNOWNED REFERENCE
 ========================
   class Customer {
       let name: String
       var card: CreditCard?         // strong — Customer owns Card
       init(name: String) {
           self.name = name
           print("Customer \(name) initialized")
       }
       deinit { print("Customer \(name) deinitialized") }
   }

   class CreditCard {
       let number: String
       unowned let customer: Customer  // unowned — Card assumes Customer exists
       init(number: String, customer: Customer) {
           self.number = number
           self.customer = customer
           print("CreditCard \(number) initialized")
       }
       deinit { print("CreditCard \(number) deinitialized") }
   }

   var mark: Customer? = Customer(name: "Mark")
   // Output: Customer Mark initialized
   // mark ref count: 1

   mark!.card = CreditCard(number: "1234-5678",
                            customer: mark!)
   // Output: CreditCard 1234-5678 initialized
   // CreditCard ref count: 1 (mark.card holds it)
   // mark ref count still: 1 (unowned does NOT increase it)

   mark = nil
   // mark ref count: 0 — deallocated
   // Output: Customer Mark deinitialized
   //         CreditCard 1234-5678 deinitialized
   // When Customer is freed, it releases its card property,
   // CreditCard ref count drops to 0 — also freed
   // No cycle — no leak

 WHEN TO USE WEAK VS UNOWNED
 =============================
   Use weak when:
   - The reference CAN become nil during its lifetime
   - The referenced object can outlive or be outlived by
     the referencing object
   - Common: delegate patterns, child referencing parent

   Use unowned when:
   - The reference will NEVER be nil during its lifetime
   - The referenced object will always outlive the
     referencing object
   - Common: closures capturing self when self outlives closure

   Example comparison:
     class Dog {
         var name: String
         weak var owner: Owner?       // Dog can outlive Owner
         init(name: String) { self.name = name }
     }

     class Passport {
         unowned let citizen: Citizen // Passport cannot exist without Citizen
         init(citizen: Citizen) { self.citizen = citizen }
     }


 ================================================================
 PART 7 — STRONG REFERENCE CYCLES IN CLOSURES
 ================================================================

 WHAT IS A CLOSURE REFERENCE CYCLE?
 ====================================
 Closures are reference types. When a closure captures
 self (a class instance) strongly, and that instance
 holds a strong reference to the closure, a reference
 cycle is created.
 This is a very common source of memory leaks in Swift.

 BASIC CLOSURE REFERENCE CYCLE
 ================================
   class Timer {
       var name: String
       var tick: (() -> Void)?       // strong reference to closure

       init(name: String) {
           self.name = name
           print("Timer \(name) initialized")
       }

       func start() {
           // self captured strongly — creates cycle
           tick = {
               print("Tick from \(self.name)")
           }
       }

       deinit { print("Timer \(name) deinitialized") }
   }

   var timer: Timer? = Timer(name: "Main")
   // Output: Timer Main initialized

   timer!.start()
   // Cycle: Timer → tick closure → Timer (via self)

   timer = nil
   // Timer ref count: 1 — NOT freed — MEMORY LEAK
   // Output: (nothing — deinit never called)

 CAPTURE LIST — FIXING WITH WEAK SELF
 ======================================
   class SafeTimer {
       var name: String
       var tick: (() -> Void)?

       init(name: String) {
           self.name = name
           print("SafeTimer \(name) initialized")
       }

       func start() {
           // [weak self] — self captured weakly
           tick = { [weak self] in
               guard let self = self else {
                   print("Self is nil")
                   return
               }
               print("Tick from \(self.name)")
           }
       }

       deinit { print("SafeTimer \(name) deinitialized") }
   }

   var safeTimer: SafeTimer? = SafeTimer(name: "Safe")
   // Output: SafeTimer Safe initialized

   safeTimer!.start()
   safeTimer!.tick?()
   // Output: Tick from Safe

   safeTimer = nil
   // Ref count: 0 — no cycle — freed correctly
   // Output: SafeTimer Safe deinitialized

 CAPTURE LIST — FIXING WITH UNOWNED SELF
 =========================================
   class RequestManager {
       var url: String
       var onComplete: (() -> Void)?

       init(url: String) {
           self.url = url
           print("RequestManager \(url) initialized")
       }

       func fetch() {
           // [unowned self] — safe when self always outlives closure
           onComplete = { [unowned self] in
               print("Completed request to \(self.url)")
           }
       }

       deinit { print("RequestManager \(url) deinitialized") }
   }

   var manager: RequestManager? = RequestManager(url: "https://api.example.com")
   // Output: RequestManager https://api.example.com initialized

   manager!.fetch()
   manager!.onComplete?()
   // Output: Completed request to https://api.example.com

   manager = nil
   // Output: RequestManager https://api.example.com deinitialized

 CAPTURE LIST SYNTAX
 ====================
   // Single capture:
   { [weak self] in ... }
   { [unowned self] in ... }

   // Multiple captures:
   { [weak self, weak delegate] in ... }
   { [unowned self, weak other] in ... }

   // Capture and rename:
   { [weak self] in
       guard let self = self else { return }
       // use self
   }

   // Shorthand self rebinding (Swift 5.3+):
   { [weak self] in
       guard let self else { return }
       // use self directly
   }

 WHAT CAN BE CAPTURED IN A CAPTURE LIST
 ========================================
   class Example {
       var value = 10

       func demo() {
           var localVar = 100
           let localConst = 200

           // Capture class instance properties via self:
           let c1 = { [weak self] in
               print(self?.value ?? -1)
           }

           // Capture local variables by value at creation time:
           let c2 = { [localVar] in
               print(localVar)   // captures value 100
           }
           localVar = 999   // changing after capture
           c2()             // still prints 100
           // Output: 100

           // Capture local constant (same as normal capture):
           let c3 = { print(localConst) }
           c3()
           // Output: 200

           c1()
           // Output: 10
       }
   }


 ================================================================
 PART 8 — DEINIT
 ================================================================

 WHAT IS DEINIT?
 ===============
 deinit is a special method called automatically
 just before a class instance is deallocated.
 Used for cleanup: closing files, releasing resources,
 removing observers, etc.
 Only available on class types (not struct or enum).
 Cannot be called manually.
 Subclasses call their own deinit first, then the
 superclass deinit automatically.

 BASIC DEINIT
 =============
   class FileHandler {
       let filename: String

       init(filename: String) {
           self.filename = filename
           print("Opening \(filename)")
       }

       deinit {
           print("Closing \(filename)")
           // cleanup: close file handles, release resources
       }
   }

   var handler: FileHandler? = FileHandler(filename: "data.txt")
   // Output: Opening data.txt

   handler = nil
   // Output: Closing data.txt

 DEINIT IN INHERITANCE
 ======================
   class Base {
       init() { print("Base init") }
       deinit { print("Base deinit") }
   }

   class Child: Base {
       override init() {
           super.init()
           print("Child init")
       }
       deinit {
           print("Child deinit")
           // super.deinit() NOT needed — called automatically
       }
   }

   var obj: Child? = Child()
   // Output: Base init
   //         Child init

   obj = nil
   // Output: Child deinit   (subclass deinit first)
   //         Base deinit    (superclass deinit second)

 DEINIT FOR NOTIFICATION OBSERVER REMOVAL
 ==========================================
   import Foundation

   class ViewController {
       init() {
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(handleEvent),
               name: NSNotification.Name("MyEvent"),
               object: nil
           )
           print("ViewController initialized")
       }

       @objc func handleEvent() {
           print("Event received")
       }

       deinit {
           NotificationCenter.default.removeObserver(self)
           print("ViewController deinitialized — observer removed")
       }
   }

 DEINIT IS NOT GUARANTEED FOR GLOBALS
 ======================================
   // Global variables and singletons may never be deallocated
   // during normal program execution.
   // deinit for globals is called only when the program exits.


 ================================================================
 PART 9 — VALUE TYPES vs REFERENCE TYPES
 ================================================================

 VALUE TYPES (STRUCT, ENUM, TUPLE)
 ===================================
   - Stored on the stack (usually)
   - Copied on assignment — each variable has its own copy
   - No reference counting overhead
   - Thread-safe by default (each thread works on its own copy)
   - Cannot create reference cycles
   - Examples: Int, Double, Bool, String, Array, Dictionary,
               Set, struct, enum, tuple

 REFERENCE TYPES (CLASS, CLOSURE)
 ==================================
   - Stored on the heap
   - Shared on assignment — multiple variables point to same instance
   - Managed by ARC
   - Not inherently thread-safe
   - Can create reference cycles
   - Examples: class instances, closures, actors

 COPY BEHAVIOR COMPARISON
 =========================
   // Value type — independent copies:
   struct ValuePoint {
       var x: Int
       var y: Int
   }
   var vp1 = ValuePoint(x: 1, y: 2)
   var vp2 = vp1       // copy
   vp2.x = 99
   print(vp1.x)        // unchanged
   // Output: 1
   print(vp2.x)
   // Output: 99

   // Reference type — shared instance:
   class RefPoint {
       var x: Int
       var y: Int
       init(x: Int, y: Int) { self.x = x; self.y = y }
   }
   var rp1 = RefPoint(x: 1, y: 2)
   var rp2 = rp1       // shared reference
   rp2.x = 99
   print(rp1.x)        // ALSO changed
   // Output: 99

 COPY-ON-WRITE (COW)
 ====================
   Swift standard library value types (Array, Dictionary,
   String) use Copy-On-Write optimization. They share
   storage until one copy is modified, then a real copy
   is made. This avoids unnecessary copying.
   Example:
     var arr1 = [1, 2, 3, 4, 5]
     var arr2 = arr1          // shared storage (no copy yet)
     arr2.append(6)           // copy made NOW (COW triggers)
     print(arr1)
     // Output: [1, 2, 3, 4, 5]
     print(arr2)
     // Output: [1, 2, 3, 4, 5, 6]

 WHEN TO USE STRUCT VS CLASS
 ============================
   Use struct when:
   - Data is simple and self-contained
   - Copying is the right semantic
   - Thread safety is needed
   - No need for inheritance
   - Examples: Point, Size, Color, Configuration

   Use class when:
   - Shared mutable state is needed
   - Identity matters (two instances are different even
     if they have the same values)
   - Inheritance is needed
   - Objective-C interoperability
   - Examples: ViewControllers, NetworkManagers, Database

 CHECKING IDENTITY (===)
 ========================
   class Dog {
       var name: String
       init(name: String) { self.name = name }
   }

   let dog1 = Dog(name: "Rex")
   let dog2 = dog1        // same instance
   let dog3 = Dog(name: "Rex")  // different instance, same data

   print(dog1 === dog2)   // same identity
   // Output: true
   print(dog1 === dog3)   // different identity
   // Output: false
   print(dog1 !== dog3)
   // Output: true


 ================================================================
 PART 10 — MEMORY LAYOUT AND STACK vs HEAP
 ================================================================

 STACK ALLOCATION
 =================
   func calculateArea() -> Int {
       let width = 10      // on stack
       let height = 5      // on stack
       let area = width * height   // on stack
       return area
   }   // all stack variables freed instantly
   print(calculateArea())
   // Output: 50

   // Structs are typically on stack:
   struct Rectangle {
       var width: Double
       var height: Double
       var area: Double { width * height }
   }
   let rect = Rectangle(width: 4.0, height: 3.0)
   // rect is on stack — no ARC, no heap allocation
   print(rect.area)
   // Output: 12.0

 HEAP ALLOCATION
 ================
   class HeavyObject {
       var data: [Int]
       init(size: Int) {
           data = Array(1...size)
           print("HeavyObject allocated with \(size) elements")
       }
       deinit { print("HeavyObject deallocated") }
   }

   func createHeavy() {
       let heavy = HeavyObject(size: 1000)
       // heavy is on heap — ARC manages it
       print("Using heavy object with \(heavy.data.count) elements")
   }   // ref count drops to 0 here
   createHeavy()
   // Output: HeavyObject allocated with 1000 elements
   //         Using heavy object with 1000 elements
   //         HeavyObject deallocated

 STRUCT INSIDE CLASS (MIXED)
 ============================
   struct Config {          // value type
       var timeout: Int
       var retries: Int
   }
   class NetworkService {   // reference type (on heap)
       var config: Config   // Config is embedded in heap
       var name: String

       init(name: String, config: Config) {
           self.name = name
           self.config = config
           print("NetworkService \(name) created")
       }
       deinit { print("NetworkService \(name) destroyed") }
   }

   var service: NetworkService? = NetworkService(
       name: "API",
       config: Config(timeout: 30, retries: 3)
   )
   // Output: NetworkService API created

   // config is embedded in the heap memory of NetworkService
   // No separate heap allocation for Config

   service = nil
   // Output: NetworkService API destroyed


 ================================================================
 PART 11 — COMMON MEMORY MANAGEMENT PATTERNS
 ================================================================

 PATTERN 1 — DELEGATE PATTERN (WEAK)
 =====================================
   protocol DataDelegate: AnyObject {
       func didReceiveData(_ data: String)
   }

   class DataLoader {
       weak var delegate: DataDelegate?    // weak — prevents cycle

       func load() {
           // simulate loading
           delegate?.didReceiveData("Loaded data")
       }
   }

   class ViewController: DataDelegate {
       let loader = DataLoader()

       init() {
           loader.delegate = self  // if strong, cycle would form
           print("ViewController initialized")
       }

       func didReceiveData(_ data: String) {
           print("Received: \(data)")
       }

       func startLoading() {
           loader.load()
       }

       deinit { print("ViewController deinitialized") }
   }

   var vc: ViewController? = ViewController()
   // Output: ViewController initialized

   vc!.startLoading()
   // Output: Received: Loaded data

   vc = nil
   // Output: ViewController deinitialized
   // No cycle — delegate is weak

 PATTERN 2 — PARENT-CHILD (STRONG/WEAK)
 ========================================
   class ParentNode {
       var name: String
       var children: [ChildNode] = []     // strong — parent owns children

       init(name: String) {
           self.name = name
           print("Parent \(name) initialized")
       }
       deinit { print("Parent \(name) deinitialized") }
   }

   class ChildNode {
       var name: String
       weak var parent: ParentNode?       // weak — child does not own parent

       init(name: String, parent: ParentNode) {
           self.name = name
           self.parent = parent
           print("Child \(name) initialized")
       }
       deinit { print("Child \(name) deinitialized") }
   }

   var root: ParentNode? = ParentNode(name: "Root")
   // Output: Parent Root initialized

   let child1 = ChildNode(name: "Child1", parent: root!)
   let child2 = ChildNode(name: "Child2", parent: root!)
   // Output: Child Child1 initialized
   //         Child Child2 initialized

   root!.children = [child1, child2]

   root = nil
   // Parent freed — releases strong refs to children
   // Children freed — their weak parent ref was already weak
   // Output: Parent Root deinitialized
   //         Child Child1 deinitialized
   //         Child Child2 deinitialized

 PATTERN 3 — SINGLETON (WEAK CACHE)
 =====================================
   class ImageCache {
       static let shared = ImageCache()
       private var cache: [String: NSObject] = [:]   // strong refs
       private init() { print("ImageCache initialized") }

       func store(_ image: NSObject, forKey key: String) {
           cache[key] = image
       }
       func retrieve(forKey key: String) -> NSObject? {
           return cache[key]
       }
   }

   // NSMapTable equivalent — weak value cache (conceptual):
   class WeakCache<Value: AnyObject> {
       private var cache = NSMapTable<NSString, Value>
                               .strongToWeakObjects()

       func set(_ value: Value, forKey key: String) {
           cache.setObject(value, forKey: key as NSString)
       }
       func get(forKey key: String) -> Value? {
           cache.object(forKey: key as NSString)
       }
   }

 PATTERN 4 — CLOSURE IN ASYNC OPERATION
 =========================================
   class APIClient {
       var baseURL: String

       init(url: String) {
           self.baseURL = url
           print("APIClient initialized for \(url)")
       }

       func fetch(completion: @escaping (String) -> Void) {
           // Simulate async operation
           DispatchQueue.global().async { [weak self] in
               guard let self = self else {
                   print("APIClient was deallocated")
                   return
               }
               let result = "Data from \(self.baseURL)"
               DispatchQueue.main.async {
                   completion(result)
               }
           }
       }

       deinit { print("APIClient deinitialized") }
   }

   var client: APIClient? = APIClient(url: "https://api.example.com")
   // Output: APIClient initialized for https://api.example.com

   client!.fetch { data in
       print("Got: \(data)")
   }

   // If client is set to nil before callback fires:
   // client = nil
   // Output: APIClient deinitialized
   //         APIClient was deallocated

 PATTERN 5 — UNOWNED IN CLOSURE
 ================================
   class UserSession {
       var token: String

       init(token: String) {
           self.token = token
           print("Session initialized")
       }

       // unowned is safe here because the closure
       // is stored as a property of self — so self
       // always outlives the closure
       lazy var authHeader: () -> String = { [unowned self] in
           return "Bearer \(self.token)"
       }

       deinit { print("Session deinitialized") }
   }

   var session: UserSession? = UserSession(token: "abc123")
   // Output: Session initialized

   print(session!.authHeader())
   // Output: Bearer abc123

   session = nil
   // Output: Session deinitialized


 ================================================================
 PART 12 — DETECTING AND FIXING MEMORY LEAKS
 ================================================================

 COMMON CAUSES OF MEMORY LEAKS
 ===============================
   1. Strong reference cycles between class instances
   2. Closures strongly capturing self which holds the closure
   3. Delegates declared as strong instead of weak
   4. Timer targets holding strong references
   5. Notification observers not removed in deinit
   6. Caches holding strong references indefinitely
   7. Global/static variables holding instances

 HOW TO DETECT LEAKS
 ====================
   Tools:
   - Xcode Memory Graph Debugger (Debug > Memory Graph)
   - Instruments → Leaks template
   - Instruments → Allocations template
   - print in deinit to verify deallocation
   - isKnownUniquelyReferenced() for COW debugging

 USING DEINIT TO VERIFY
 ========================
   class Verifiable {
       let id: Int
       init(id: Int) {
           self.id = id
           print("Created \(id)")
       }
       deinit { print("Freed \(id)") }
   }

   // Good — deinit called:
   func goodTest() {
       let obj = Verifiable(id: 1)
       print("Using \(obj.id)")
   }
   goodTest()
   // Output: Created 1
   //         Using 1
   //         Freed 1

   // Bad — deinit NOT called (simulated leak):
   var leak: Verifiable? = Verifiable(id: 2)
   var cycle: Verifiable? = Verifiable(id: 3)
   // (no cycle setup here, just illustration)
   // Always check: if deinit is not printed, you have a leak

 TIMER MEMORY LEAK (COMMON PITFALL)
 ====================================
   import Foundation

   // PROBLEMATIC — Timer holds strong reference to target:
   class BadViewController {
       var timer: Timer?

       func viewDidLoad() {
           // self is captured strongly by Timer
           timer = Timer.scheduledTimer(
               timeInterval: 1.0,
               target: self,      // strong reference to self
               selector: #selector(tick),
               userInfo: nil,
               repeats: true
           )
       }

       @objc func tick() { print("Tick") }

       deinit {
           timer?.invalidate()
           print("BadViewController freed")
       }
   }
   // Cycle: BadViewController → timer → BadViewController (target)
   // Solution: invalidate timer before deallocation, or use
   // block-based Timer with [weak self]

   // FIXED — using block-based Timer:
   class GoodViewController {
       var timer: Timer?

       func viewDidLoad() {
           timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                         repeats: true) { [weak self] _ in
               self?.tick()
           }
       }

       @objc func tick() { print("Tick") }

       deinit {
           timer?.invalidate()
           print("GoodViewController freed")
       }
   }


 ================================================================
 PART 13 — ADVANCED ARC CONCEPTS
 ================================================================

 ISKNOWNUNIQUELYREFERENCED
 ==========================
   // Returns true if an object has exactly one strong reference
   // Used internally for Copy-On-Write implementations
   class Ref<T> {
       var value: T
       init(_ value: T) { self.value = value }
   }

   struct COWArray<T> {
       private var storage: Ref<[T]>

       init(_ array: [T] = []) {
           storage = Ref(array)
       }

       private mutating func ensureUnique() {
           if !isKnownUniquelyReferenced(&storage) {
               storage = Ref(storage.value)
               print("Copying storage")
           }
       }

       mutating func append(_ element: T) {
           ensureUnique()
           storage.value.append(element)
       }

       var count: Int { storage.value.count }
   }

   var arr1 = COWArray([1, 2, 3])
   var arr2 = arr1         // shared storage
   arr2.append(4)          // triggers copy
   // Output: Copying storage
   print(arr1.count)
   // Output: 3
   print(arr2.count)
   // Output: 4

 WITHEXTENDEDLIFETIME
 =====================
   // Forces an object to stay alive until after a block completes
   // Useful for unsafe interop where ARC might free too early
   class Resource {
       let id: Int
       init(id: Int) {
           self.id = id
           print("Resource \(id) created")
       }
       deinit { print("Resource \(id) freed") }
   }

   func useResource() {
       let res = Resource(id: 42)
       withExtendedLifetime(res) {
           // res guaranteed alive during this block
           print("Using resource \(res.id)")
       }
       // res may be freed after the block
   }
   useResource()
   // Output: Resource 42 created
   //         Using resource 42
   //         Resource 42 freed

 UNOWNED(UNSAFE)
 ================
   // Fastest option — no ARC check at all
   // Crashes without a useful error if accessed after dealloc
   // Use only when performance is critical and lifetime
   // is absolutely certain
   class Node {
       var value: Int
       unowned(unsafe) var next: Node?   // no runtime check

       init(value: Int) { self.value = value }
       deinit { print("Node \(value) freed") }
   }

 WEAK IN COLLECTIONS
 ====================
   // Standard array holds strong references:
   var objects = [Person(name: "Alice"), Person(name: "Bob")]
   // Both kept alive as long as array exists

   // Weak wrapper for weak collection entries:
   class Weak<T: AnyObject> {
       weak var value: T?
       init(_ value: T) { self.value = value }
   }

   var weakList: [Weak<Person>] = []
   var personA: Person? = Person(name: "Weak Alice")
   var personB: Person? = Person(name: "Weak Bob")
   // Output: Person Weak Alice initialized
   //         Person Weak Bob initialized

   weakList.append(Weak(personA!))
   weakList.append(Weak(personB!))

   personA = nil
   // Output: Person Weak Alice deinitialized

   for entry in weakList {
       print(entry.value?.name ?? "nil (freed)")
   }
   // Output: nil (freed)
   //         Weak Bob

   personB = nil
   // Output: Person Weak Bob deinitialized

 ARC AND SWIFT CONCURRENCY
 ==========================
   // In Swift 5.5+, actors provide safe shared state
   // ARC still manages instance lifetime
   // Sendable protocol ensures safe cross-actor passing

   actor Counter {
       private var count = 0

       func increment() {
           count += 1
       }

       func value() -> Int {
           return count
       }
   }

   Task {
       let counter = Counter()
       await counter.increment()
       await counter.increment()
       print("Count: \(await counter.value())")
   }
   // Output: Count: 2


 ================================================================
 PART 14 — MEMORY MANAGEMENT QUICK REFERENCE TABLE
 ================================================================

 REFERENCE TYPES COMPARISON
 ============================
 Reference Type | Increases Count | Auto-nil on Dealloc | Optional | Use When
 ---------------|-----------------|---------------------|----------|------------------
 strong         | Yes             | No                  | Optional | Default ownership
 weak           | No              | Yes                 | Always   | Can become nil
 unowned        | No              | No (crash)          | Never    | Will never be nil


 CYCLE SCENARIOS AND SOLUTIONS
 ==============================
 Scenario                          | Solution
 ----------------------------------|------------------------------------
 Two classes reference each other  | weak or unowned on one side
 Class holds closure, closure self | [weak self] or [unowned self]
 Delegate pattern                  | weak var delegate
 Parent-child tree                 | strong parent→child, weak child→parent
 Timer target                      | Block-based timer with [weak self]
 Notification observer             | Remove observer in deinit


 VALUE vs REFERENCE SUMMARY
 ============================
 Aspect              | Struct (Value)       | Class (Reference)
 --------------------|----------------------|----------------------
 Memory location     | Stack (usually)      | Heap
 Assignment          | Copies               | Shares
 ARC                 | No                   | Yes
 Thread safety       | Yes (by default)     | No (needs care)
 Mutation            | Requires mutating    | Direct
 Identity check      | N/A (===)            | ===
 Inheritance         | No                   | Yes
 deinit              | No                   | Yes
 Reference cycles    | Impossible           | Possible


 ================================================================
 INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 SECTION 1 — BASIC LEVEL
 ================================================================

 Q1. What is ARC in Swift?
 --------------------------
 A: ARC stands for Automatic Reference Counting.
    It automatically manages memory for class instances
    by tracking how many strong references exist.
    When the count drops to zero, the instance is freed.
    Example:
      class Dog {
          let name: String
          init(name: String) {
              self.name = name
              print("Dog \(name) created")
          }
          deinit { print("Dog \(name) freed") }
      }

      var d1: Dog? = Dog(name: "Rex")
      // Output: Dog Rex created
      var d2 = d1     // ref count: 2
      d1 = nil        // ref count: 1
      d2 = nil        // ref count: 0
      // Output: Dog Rex freed


 Q2. What is a strong reference?
 --------------------------------
 A: The default type of reference to a class instance.
    Increases the reference count by 1.
    The instance stays alive as long as strong references exist.
    Example:
      class Cat {
          let name: String
          init(name: String) { self.name = name }
          deinit { print("\(name) freed") }
      }
      var a: Cat? = Cat(name: "Whiskers")
      var b: Cat? = a     // strong — ref count 2
      a = nil             // ref count 1
      b = nil             // ref count 0
      // Output: Whiskers freed


 Q3. What is a weak reference?
 ------------------------------
 A: Does not increase reference count. Always Optional.
    Set to nil automatically when instance is deallocated.
    Use to prevent reference cycles.
    Example:
      class Node {
          let value: Int
          weak var next: Node?      // weak
          init(value: Int) { self.value = value }
          deinit { print("Node \(value) freed") }
      }
      var n1: Node? = Node(value: 1)
      var n2: Node? = Node(value: 2)
      n1!.next = n2    // weak — no count increase
      n2 = nil
      // Output: Node 2 freed
      print(n1!.next)  // automatically nil
      // Output: nil


 Q4. What is an unowned reference?
 -----------------------------------
 A: Does not increase reference count. Not Optional.
    Does NOT set itself to nil when instance is freed.
    Crashes if accessed after instance is deallocated.
    Use when the referenced instance always outlives
    the reference.
    Example:
      class Country {
          let name: String
          var capital: City?
          init(name: String) { self.name = name }
          deinit { print("Country \(name) freed") }
      }
      class City {
          let name: String
          unowned let country: Country   // unowned
          init(name: String, country: Country) {
              self.name = name
              self.country = country
          }
          deinit { print("City \(name) freed") }
      }
      var uk: Country? = Country(name: "UK")
      uk!.capital = City(name: "London", country: uk!)
      uk = nil
      // Output: Country UK freed
      //         City London freed


 Q5. What is a strong reference cycle?
 ---------------------------------------
 A: When two instances hold strong references to each other,
    preventing either from reaching a ref count of zero.
    Causes a memory leak.
    Example:
      class A {
          var b: B?
          deinit { print("A freed") }
      }
      class B {
          var a: A?
          deinit { print("B freed") }
      }
      var objA: A? = A()
      var objB: B? = B()
      objA!.b = objB    // A → B (strong)
      objB!.a = objA    // B → A (strong) — cycle!
      objA = nil
      objB = nil
      // Output: (nothing — both leaked)


 Q6. What is deinit?
 --------------------
 A: A method called automatically when a class instance
    is about to be deallocated. Used for cleanup.
    Cannot be called manually.
    Example:
      class Session {
          init() { print("Session started") }
          deinit { print("Session ended — cleanup") }
      }
      var s: Session? = Session()
      // Output: Session started
      s = nil
      // Output: Session ended — cleanup


 Q7. What is the difference between value types
     and reference types?
 -----------------------------------------------
 A: Value types — copied on assignment (struct, enum)
    Reference types — shared on assignment (class)
    Example:
      struct SPoint { var x: Int }
      class RPoint { var x: Int; init(x: Int) { self.x = x } }

      var sv1 = SPoint(x: 1)
      var sv2 = sv1         // copy
      sv2.x = 99
      print(sv1.x)          // unchanged: 1
      // Output: 1

      var rv1 = RPoint(x: 1)
      var rv2 = rv1         // shared
      rv2.x = 99
      print(rv1.x)          // changed: 99
      // Output: 99


 Q8. Does ARC work with structs?
 --------------------------------
 A: No. ARC only manages class instances (heap objects).
    Value types (struct, enum) are on the stack and
    managed automatically by the compiler.
    Example:
      struct NoARC {
          var value: Int
      }
      var s1 = NoARC(value: 10)
      var s2 = s1      // independent copy — no ARC involved
      s2.value = 99
      print(s1.value)
      // Output: 10     // s1 unaffected, no ref counting


 Q9. When is deinit called?
 ---------------------------
 A: When the last strong reference to the instance is
    removed and the reference count drops to zero.
    Example:
      class Tracker {
          init() { print("start") }
          deinit { print("end") }
      }
      do {
          let t = Tracker()   // ref count: 1
          print("using")
      }   // t goes out of scope — ref count: 0
      // Output: start
      //         using
      //         end


 Q10. What is a memory leak?
 -----------------------------
 A: When allocated memory can never be freed because
    nothing can reach a ref count of zero.
    Common cause: strong reference cycles.
    Example:
      class Leaker {
          var other: Leaker?
          deinit { print("freed") }
      }
      var a: Leaker? = Leaker()
      var b: Leaker? = Leaker()
      a!.other = b    // cycle
      b!.other = a    // cycle
      a = nil
      b = nil
      // Output: (nothing — both leaked forever)


 Q11. What keyword makes a reference weak?
 ------------------------------------------
 A: The weak keyword.
    Must be var (mutable) and Optional type.
    Example:
      class Example {
          weak var delegate: AnyObject?    // weak Optional
      }


 Q12. What keyword makes a reference unowned?
 ---------------------------------------------
 A: The unowned keyword.
    Can be let or var. Not Optional.
    Example:
      class Child {
          unowned let parent: Parent
          init(parent: Parent) { self.parent = parent }
      }


 Q13. What is the difference between weak
      and unowned?
 ---------------------------------------------
 A: weak    — Optional, auto-set to nil when freed,
              safe to access after deallocation (returns nil)
    unowned — Non-optional, NOT set to nil,
              crashes if accessed after deallocation
    Use weak when the reference might become nil.
    Use unowned when lifetime is guaranteed.
    Example:
      class Safe {
          weak var maybeGone: NSObject?     // Optional — safe
      }
      class Fast {
          unowned let alwaysHere: NSObject  // Non-optional — fast
          init(ref: NSObject) { alwaysHere = ref }
      }


 Q14. Can a struct have a deinit?
 ---------------------------------
 A: No. Only classes have deinit.
    Value types are cleaned up automatically by the
    compiler without needing custom deinitialization.
    Example:
      // struct NoDeInit {
      //     deinit { }    // Error: deinit only for class
      // }
      class HasDeInit {
          deinit { print("freed") }    // OK
      }


 Q15. What happens when you assign a class instance
      to a new variable?
 -------------------------------------------------
 A: Both variables point to the same instance.
    The reference count increases by 1.
    Example:
      class Box {
          var value: Int
          init(_ v: Int) { self.value = v }
      }
      var box1: Box? = Box(42)    // ref count: 1
      var box2 = box1              // ref count: 2
      box1 = nil                   // ref count: 1
      box2!.value = 99
      print(box2!.value)
      // Output: 99
      box2 = nil                   // ref count: 0 — freed


 ================================================================
 SECTION 2 — INTERMEDIATE LEVEL
 ================================================================

 Q16. How do you break a strong reference cycle?
 ------------------------------------------------
 A: Use weak or unowned on one side of the cycle.
    Example:
      class Parent {
          var child: Child2?
          deinit { print("Parent freed") }
      }
      class Child2 {
          weak var parent: Parent?   // weak breaks cycle
          deinit { print("Child2 freed") }
      }
      var p: Parent? = Parent()
      var c: Child2? = Child2()
      p!.child = c
      c!.parent = p   // weak — no cycle
      p = nil
      // Output: Parent freed
      c = nil
      // Output: Child2 freed


 Q17. What is a capture list in a closure?
 ------------------------------------------
 A: A capture list explicitly controls how values
    and references are captured by a closure.
    Written in square brackets before parameters.
    Example:
      class Counter {
          var count = 0
          lazy var increment: () -> Void = { [weak self] in
              self?.count += 1
          }
          deinit { print("Counter freed") }
      }
      var c: Counter? = Counter()
      c!.increment()
      c!.increment()
      print(c!.count)
      // Output: 2
      c = nil
      // Output: Counter freed


 Q18. When should you use [weak self] vs
      [unowned self] in a closure?
 ---------------------------------------------
 A: [weak self] — when self might be nil when closure runs.
                  Self is Optional inside the closure.
    [unowned self] — when self is guaranteed to be alive
                     when the closure executes.
    Example:
      class Presenter {
          var name = "Main"

          func fetchWithWeak() {
              // Self might be gone before callback fires:
              DispatchQueue.global().async { [weak self] in
                  guard let self = self else { return }
                  print("Weak: \(self.name)")
              }
          }

          func computeWithUnowned() {
              // Closure stored as property — self always alive:
              let compute = { [unowned self] in
                  print("Unowned: \(self.name)")
              }
              compute()
          }
      }
      let p = Presenter()
      p.computeWithUnowned()
      // Output: Unowned: Main


 Q19. Why must weak references always be var?
 ---------------------------------------------
 A: Because ARC must be able to set the weak reference
    to nil when the referenced instance is deallocated.
    let (constants) cannot be changed after initialization.
    Example:
      class Example {
          // weak let ref: NSObject?  // Error — let not allowed
          weak var ref: NSObject?     // var required
      }


 Q20. What is Copy-On-Write and which types use it?
 ---------------------------------------------------
 A: COW is an optimization where value types share
    underlying storage until one copy is mutated.
    Only then is a real copy made.
    Swift standard library uses it for Array, Dictionary,
    String, and Set.
    Example:
      var a = [1, 2, 3, 4, 5]
      var b = a          // no copy yet — shared storage
      print(a == b)
      // Output: true

      b.append(6)        // real copy happens NOW
      print(a.count)
      // Output: 5       // a unaffected
      print(b.count)
      // Output: 6


 Q21. How does the delegate pattern prevent
      memory cycles?
 ----------------------------------------------
 A: The delegate property is declared as weak,
    so it doesn't increase the reference count of
    the delegating object.
    Example:
      protocol SomeDelegate: AnyObject {
          func didFinish()
      }
      class Worker {
          weak var delegate: SomeDelegate?   // weak!
          func finish() {
              delegate?.didFinish()
          }
          deinit { print("Worker freed") }
      }
      class Boss: SomeDelegate {
          let worker = Worker()
          init() { worker.delegate = self }
          func didFinish() { print("Boss notified") }
          deinit { print("Boss freed") }
      }
      var boss: Boss? = Boss()
      boss!.worker.finish()
      // Output: Boss notified
     boss = nil
     // Output: Worker freed
     //         Boss freed
     // No cycle — delegate is weak


Q22. What is the difference between a memory
 leak and a dangling pointer?
----------------------------------------------
A: Memory leak — memory allocated but never freed.
             Instance still exists but nothing
             can reach or use it.
Dangling pointer — a reference that points to
                  memory that has already been freed.
                  Accessing it causes a crash.

In Swift:
- Memory leaks come from strong reference cycles.
- Dangling pointers come from unowned references
 accessed after deallocation, or unsafe pointers.
Example:
 // Memory leak — both objects forgotten:
 class A2 { var b: B2?; deinit { print("A freed") } }
 class B2 { var a: A2?; deinit { print("B freed") } }
 var a2: A2? = A2()
 var b2: B2? = B2()
 a2!.b = b2
 b2!.a = a2
 a2 = nil; b2 = nil
 // Output: (nothing — leaked)

 // Dangling pointer via unowned (crash risk):
 class Owner {
     var child: Owned?
     deinit { print("Owner freed") }
 }
 class Owned {
     unowned var owner: Owner
     init(owner: Owner) { self.owner = owner }
     deinit { print("Owned freed") }
 }
 var o: Owner? = Owner()
 o!.child = Owned(owner: o!)
 o = nil
 // Owner freed, then Owned freed — safe here
 // But if you stored a ref to child and accessed
 // child.owner after o = nil — CRASH


Q23. Can closures capture value types by reference?
----------------------------------------------------
A: By default, closures capture value types by reference
if the variable is mutable and in surrounding scope.
Use capture list to capture by value (copy).
Example:
 var counter = 0
 let increment = { counter += 1 }  // captures by reference
 increment()
 increment()
 print(counter)
 // Output: 2   (original variable modified)

 var x = 10
 let snapshot = { [x] in print(x) }  // captures by value
 x = 99
 snapshot()
 // Output: 10   (captured value of x at creation time)
 print(x)
 // Output: 99   (original unchanged)


Q24. What happens to captured variables
 when the closure outlives their scope?
----------------------------------------------
A: Swift extends the lifetime of captured variables
to match the lifetime of the closure.
The variable lives on the heap if needed.
Example:
 func makeCounter() -> () -> Int {
     var count = 0         // would normally die at end of func
     return {
         count += 1        // closure extends count's lifetime
         return count
     }
 }

 let counter1 = makeCounter()
 let counter2 = makeCounter()

 print(counter1())
 // Output: 1
 print(counter1())
 // Output: 2
 print(counter1())
 // Output: 3
 print(counter2())
 // Output: 1   (independent — its own count)


Q25. How do you use @escaping vs non-escaping
 closures with memory management?
----------------------------------------------
A: Non-escaping — closure runs before function returns.
              No need for [weak self] — no cycle risk.
@escaping     — closure can outlive the function.
               May need [weak self] to avoid cycles.
Example:
 class TaskRunner {
     var name = "Runner"

     // Non-escaping — no cycle risk:
     func runNow(task: () -> Void) {
         task()             // runs immediately
     }

     // @escaping — potential cycle:
     func runLater(task: @escaping () -> Void) {
         DispatchQueue.global().asyncAfter(
             deadline: .now() + 1) {
             task()         // runs after function returns
         }
     }

     func start() {
         // Non-escaping — safe without [weak self]:
         runNow {
             print("Now: \(self.name)")
         }

         // @escaping — use [weak self]:
         runLater { [weak self] in
             print("Later: \(self?.name ?? "gone")")
         }
     }

     deinit { print("TaskRunner freed") }
 }

 let runner = TaskRunner()
 runner.start()
 // Output: Now: Runner
 //         (after ~1s) Later: Runner


Q26. What is the difference between a strong
 capture and a weak capture in a closure?
----------------------------------------------
A: Strong capture — default, increases ref count,
                can create cycles with class instances.
Weak capture   — does not increase ref count,
                allows instance to be deallocated,
                becomes nil automatically.
Example:
 class Processor {
     var label = "CPU"
     deinit { print("Processor freed") }
 }

 var proc: Processor? = Processor()

 // Strong capture — proc kept alive by closure:
 let strong = { print(proc!.label) }

 // Weak capture — proc can be freed:
 let weak_c = { [weak proc] in
     print(proc?.label ?? "nil")
 }

 proc = nil
 // Strong closure prevented nothing here since
 // proc variable was set to nil, not the closure.

 // If stored as property, strong would cause cycle.
 weak_c()
 // Output: nil


================================================================
SECTION 3 — ADVANCED LEVEL
================================================================

Q27. How do you implement Copy-On-Write
 for a custom value type?
----------------------------------------------
A: Wrap the mutable storage in a class (reference type),
then use isKnownUniquelyReferenced to check if
copying is needed before mutation.
Example:
 final class StorageBuffer {
     var data: [Int]
     init(_ data: [Int]) { self.data = data }
     init(copying other: StorageBuffer) {
         self.data = other.data
         print("Buffer copied")
     }
 }

 struct COWBuffer {
     private var storage: StorageBuffer

     init(_ data: [Int]) {
         storage = StorageBuffer(data)
     }

     private mutating func ensureUnique() {
         if !isKnownUniquelyReferenced(&storage) {
             storage = StorageBuffer(copying: storage)
         }
     }

     mutating func append(_ value: Int) {
         ensureUnique()
         storage.data.append(value)
     }

     var count: Int { storage.data.count }
     var first: Int? { storage.data.first }
 }

 var buf1 = COWBuffer([1, 2, 3])
 var buf2 = buf1         // shared storage — no copy
 print(buf1.count)
 // Output: 3

 buf2.append(99)         // triggers copy
 // Output: Buffer copied

 print(buf1.count)
 // Output: 3
 print(buf2.count)
 // Output: 4


Q28. What is the three-way ownership model
 in Swift (strong / weak / unowned)?
----------------------------------------------
A: Swift models ownership like a tree:
- Strong: "I own this — keep it alive"
- Weak:   "I reference this — let it die if needed"
- Unowned: "This will always be alive while I exist"

Rules:
- Parent owns children with strong
- Children reference parent with weak
- Co-dependent objects where one always outlives
 the other use unowned
Example:
 class Company {
     var employees: [Employee] = []  // strong — owns them
     deinit { print("Company closed") }
 }
 class Employee {
     weak var company: Company?      // weak — can leave
     var contract: Contract?         // strong — owns contract
     init() { print("Employee hired") }
     deinit { print("Employee left") }
 }
 class Contract {
     unowned let employee: Employee  // unowned — contract tied to employee
     init(employee: Employee) { self.employee = employee }
     deinit { print("Contract void") }
 }

 var firm: Company? = Company()
 let emp = Employee()
 emp.company = firm
 emp.contract = Contract(employee: emp)
 firm!.employees.append(emp)

 firm = nil
 // Output: Company closed


Q29. How do actors and ARC interact in
 Swift concurrency?
----------------------------------------------
A: Actors are reference types managed by ARC,
just like classes. They add a serial executor
to serialize access to mutable state.
ARC tracks their lifetime the same way.
Example:
 actor BankAccount {
     private var balance: Double = 0

     init(initialBalance: Double) {
         self.balance = initialBalance
         print("Account created with \(initialBalance)")
     }

     func deposit(_ amount: Double) {
         balance += amount
     }

     func getBalance() -> Double { balance }

     deinit { print("Account closed") }
 }

 Task {
     var account: BankAccount? = BankAccount(initialBalance: 1000)
     // Output: Account created with 1000.0

     await account!.deposit(500)
     print("Balance: \(await account!.getBalance())")
     // Output: Balance: 1500.0

     account = nil
     // Output: Account closed
 }


Q30. What is an indirect enum and how does
 it affect memory?
----------------------------------------------
A: An indirect enum has cases that recursively
reference the same enum type. Swift places the
associated value on the heap for indirect cases
to allow the recursive structure to have
a finite, knowable size.
Example:
 indirect enum LinkedList<T> {
     case empty
     case node(value: T, next: LinkedList<T>)
 }

 let list = LinkedList.node(
     value: 1,
     next: .node(
         value: 2,
         next: .node(
             value: 3,
             next: .empty
         )
     )
 )

 func printList<T>(_ list: LinkedList<T>) {
     switch list {
     case .empty:
         print("end")
     case .node(let value, let next):
         print(value, terminator: " → ")
         printList(next)
     }
 }

 printList(list)
 // Output: 1 → 2 → 3 → end
 // Each .node case's associated value is on the heap
 // due to indirect — enabling recursive structure


Q31. How do you detect and fix a retain cycle
 in a closure stored as a property?
----------------------------------------------
A: Identify: if the class holds a closure, and the
closure captures self, you have a cycle.
Fix: use [weak self] or [unowned self] in capture list.
Example:
 // PROBLEM:
 class VideoPlayer {
     var onPlay: (() -> Void)?
     var title = "Movie"

     func setup() {
         onPlay = {                    // cycle!
             print("Playing \(self.title)")
         }
     }
     deinit { print("VideoPlayer freed") }
 }

 var player: VideoPlayer? = VideoPlayer()
 player!.setup()
 player = nil
 // Output: (nothing — leaked — deinit not called)

 // FIXED:
 class SafeVideoPlayer {
     var onPlay: (() -> Void)?
     var title = "Movie"

     func setup() {
         onPlay = { [weak self] in     // no cycle
             guard let self = self else { return }
             print("Playing \(self.title)")
         }
     }
     deinit { print("SafeVideoPlayer freed") }
 }

 var safePlayer: SafeVideoPlayer? = SafeVideoPlayer()
 safePlayer!.setup()
 safePlayer!.onPlay?()
 // Output: Playing Movie
 safePlayer = nil
 // Output: SafeVideoPlayer freed


Q32. How does memory management work with
 lazy stored properties?
----------------------------------------------
A: Lazy properties are initialized on first access.
If a lazy property is a closure, be careful
about capturing self — use [unowned self]
since self owns the lazy property and will
always outlive it.
Example:
 class DataProcessor {
     var source = "Database"

     // [unowned self] safe — self owns this property
     lazy var processor: () -> String = { [unowned self] in
         return "Processing from \(self.source)"
     }

     // BAD — would be [weak self] creating Optional mess
     // or strong self creating cycle
     lazy var badProcessor: () -> String = {
         return "Processing from \(self.source)"  // cycle!
     }

     deinit { print("DataProcessor freed") }
 }

 var dp: DataProcessor? = DataProcessor()
 print(dp!.processor())
 // Output: Processing from Database
 dp = nil
 // Output: DataProcessor freed


Q33. What is the difference between
 @objc weak and Swift weak?
----------------------------------------------
A: Swift weak — works with any Swift class.
            Auto-nil using Swift runtime.
@objc weak  — interoperates with Objective-C runtime.
             Requires the type to be an NSObject
             subclass or @objc protocol.
Example:
 import Foundation

 // Swift weak — any class:
 class PureSwift {
     deinit { print("PureSwift freed") }
 }
 var ps: PureSwift? = PureSwift()
 weak var wps: PureSwift? = ps
 ps = nil
 print(wps)
 // Output: nil

 // @objc weak — NSObject based:
 class ObjCClass: NSObject {
     deinit { print("ObjCClass freed") }
 }
 var oc: ObjCClass? = ObjCClass()
 weak var woc: ObjCClass? = oc
 oc = nil
 print(woc)
 // Output: nil


Q34. How does memory management work with
 protocol types (existentials)?
----------------------------------------------
A: A protocol type (existential) stores a class instance
behind a protocol interface. ARC still tracks the
underlying class instance. Weak works only if the
protocol is class-constrained (AnyObject or @objc).
Example:
 // Class-constrained protocol — weak works:
 protocol Identifiable: AnyObject {
     var id: String { get }
 }

 class User: Identifiable {
     var id: String
     init(id: String) { self.id = id }
     deinit { print("User \(id) freed") }
 }

 var user: User? = User(id: "u001")
 weak var weakUser: Identifiable? = user

 print(weakUser?.id ?? "nil")
 // Output: u001

 user = nil
 // Output: User u001 freed

 print(weakUser?.id ?? "nil")
 // Output: nil

 // Without AnyObject constraint — weak not allowed:
 // protocol Plain { var id: String { get } }
 // weak var w: Plain?   // Error: 'weak' not for non-class protocol


Q35. How does Swift handle memory for
 class instances in collections?
----------------------------------------------
A: Collections (Array, Dictionary, Set) hold
strong references to class instances.
The instance is kept alive as long as the
collection contains it.
Example:
 class Item {
     let name: String
     init(name: String) {
         self.name = name
         print("Item \(name) created")
     }
     deinit { print("Item \(name) freed") }
 }

 var items: [Item] = []
 var item1: Item? = Item(name: "First")
 var item2: Item? = Item(name: "Second")
 // Output: Item First created
 //         Item Second created

 items.append(item1!)
 items.append(item2!)
 // items array holds strong refs — ref count: 2 each

 item1 = nil    // ref count still 1 — array holds it
 item2 = nil    // ref count still 1 — array holds it
 // No deinit yet

 items.removeAll()
 // Output: Item First freed
 //         Item Second freed


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q36. What is the retain count of a newly
 created class instance and when does
 it actually reach zero?
----------------------------------------------
A: A new instance starts with a retain count of 1.
It reaches zero only when ALL strong references
to it are removed — variables set to nil, go out
of scope, or are overwritten.
Example:
 class Tracked {
     let id: Int
     init(_ id: Int) {
         self.id = id
         print("Created \(id) — count: 1")
     }
     deinit { print("Freed \(id) — count: 0") }
 }

 func test() {
     let a = Tracked(1)     // count: 1
     do {
         let b = a          // count: 2
         let c = a          // count: 3
         print("Inside — a,b,c ref \(a.id)")
     }                      // b,c out of scope — count: 1
     print("Outside — a ref \(a.id)")
 }                          // a out of scope — count: 0

 test()
 // Output: Created 1 — count: 1
 //         Inside — a,b,c ref 1
 //         Outside — a ref 1
 //         Freed 1 — count: 0


Q37. How does Swift ARC differ from
 Java's garbage collection?
----------------------------------------------
A: Swift ARC:
- Deterministic — freed exactly when last ref is removed
- No pause — no stop-the-world GC pause
- Compile-time — retain/release inserted at compile time
- Immediate deinit — called exactly when count hits 0
- Cannot collect cycles automatically (need weak/unowned)

Java GC:
- Non-deterministic — freed at GC's discretion
- Can pause — GC may pause all threads
- Runtime — GC runs on its own schedule
- finalize() called at GC's discretion (unreliable)
- Can collect cycles — GC handles cycles automatically

Example (Swift — deterministic deallocation):
 class ARC_Demo {
     init() { print("allocated") }
     deinit { print("deallocated immediately") }
 }
 do {
     let d = ARC_Demo()
     print("using")
 }   // deallocated HERE — deterministic
 print("after scope")
 // Output: allocated
 //         using
 //         deallocated immediately
 //         after scope


Q38. How would you implement a weak set
 or weak array in Swift?
----------------------------------------------
A: Wrap each element in a weak wrapper class,
then filter out nil entries as needed.
Example:
 class WeakRef<T: AnyObject> {
     weak var value: T?
     init(_ value: T) { self.value = value }
 }

 struct WeakSet<T: AnyObject> {
     private var refs: [WeakRef<T>] = []

     mutating func add(_ object: T) {
         compact()
         refs.append(WeakRef(object))
     }

     mutating func compact() {
         refs = refs.filter { $0.value != nil }
     }

     var allObjects: [T] {
         refs.compactMap { $0.value }
     }

     var count: Int { allObjects.count }
 }

 class Observer {
     let name: String
     init(name: String) {
         self.name = name
         print("Observer \(name) created")
     }
     deinit { print("Observer \(name) freed") }
 }

 var weakSet = WeakSet<Observer>()
 var obs1: Observer? = Observer(name: "A")
 var obs2: Observer? = Observer(name: "B")
 var obs3: Observer? = Observer(name: "C")
 // Output: Observer A created
 //         Observer B created
 //         Observer C created

 weakSet.add(obs1!)
 weakSet.add(obs2!)
 weakSet.add(obs3!)
 print(weakSet.count)
 // Output: 3

 obs2 = nil
 // Output: Observer B freed

 print(weakSet.allObjects.map { $0.name })
 // Output: ["A", "C"]

 obs1 = nil
 obs3 = nil
 // Output: Observer A freed
 //         Observer C freed

 print(weakSet.count)
 // Output: 0


Q39. How does memory management interact
 with Swift's withUnsafePointer family?
----------------------------------------------
A: Unsafe pointers bypass ARC. You are responsible
for ensuring the pointed-to object stays alive.
withUnsafePointer(to:) provides a scoped pointer
that is only valid inside the closure.
Example:
 var value = 42

 withUnsafePointer(to: &value) { ptr in
     print("Pointer to value: \(ptr)")
     print("Value via pointer: \(ptr.pointee)")
 }
 // Output: Pointer to value: 0x000... (memory address)
 //         Value via pointer: 42

 // DANGEROUS — storing pointer beyond closure:
 // var storedPtr: UnsafePointer<Int>?
 // withUnsafePointer(to: &value) { ptr in
 //     storedPtr = ptr    // ptr is invalid after closure!
 // }
 // storedPtr!.pointee   // UNDEFINED BEHAVIOR — crash possible

 // withExtendedLifetime ensures object lives during operation:
 class HeavyResource {
     var data = [Int](repeating: 0, count: 1000)
     deinit { print("HeavyResource freed") }
 }

 var res: HeavyResource? = HeavyResource()
 withExtendedLifetime(res) {
     // res guaranteed alive here even if ARC would free it
     print("Safe to use res")
 }
 res = nil
 // Output: Safe to use res
 //         HeavyResource freed


Q40. How would you explain the ARC runtime
 overhead and how to minimize it?
----------------------------------------------
A: ARC inserts retain/release calls at compile time.
Each retain and release is an atomic increment/
decrement — fast but not free.
Main costs:
- Each strong reference assignment = retain call
- Each reference going out of scope = release call
- Each heap allocation = ARC bookkeeping overhead

Ways to minimize:
1. Prefer value types (struct) — no ARC at all
2. Avoid unnecessary class instantiations in tight loops
3. Reuse objects instead of creating/destroying repeatedly
4. Use lazy properties to defer allocation
5. Use [unowned self] instead of [weak self] where safe
  (skips Optional unwrapping overhead)
6. Use final on classes to enable devirtualization

Example:
 // High ARC overhead — class in loop:
 class Pixel {
     var r: Int; var g: Int; var b: Int
     init(r: Int, g: Int, b: Int) {
         self.r = r; self.g = g; self.b = b
     }
 }
 var pixels1: [Pixel] = []
 for i in 0..<1000 {
     pixels1.append(Pixel(r: i, g: i, b: i))
     // 1000 heap allocations — 1000 ARC retains
 }
 print("Pixel count: \(pixels1.count)")
 // Output: Pixel count: 1000

 // Low overhead — struct in loop:
 struct PixelS {
     var r: Int; var g: Int; var b: Int
 }
 var pixels2: [PixelS] = []
 for i in 0..<1000 {
     pixels2.append(PixelS(r: i, g: i, b: i))
     // 0 heap allocations — no ARC
 }
 print("PixelS count: \(pixels2.count)")
 // Output: PixelS count: 1000


Q41. How does Swift handle memory for
 protocol witness tables and existentials?
----------------------------------------------
A: Small value types stored in protocol existentials
use an inline buffer (3 pointer-sized words).
Larger types use heap allocation.
Class types store a reference.
This is called the Existential Container.

Example:
 protocol Shape {
     func area() -> Double
 }

 // Small struct — may fit inline buffer:
 struct SmallCircle: Shape {
     var radius: Double           // 8 bytes — fits inline
     func area() -> Double { Double.pi * radius * radius }
 }

 // Large struct — may require heap allocation:
 struct LargePolygon: Shape {
     var vertices: [(Double, Double)]   // variable size
     func area() -> Double {
         return Double(vertices.count) * 0.5
     }
 }

 // Class — stores reference in existential:
 class CircleClass: Shape {
     var radius: Double
     init(r: Double) { radius = r }
     func area() -> Double { Double.pi * radius * radius }
 }

 let shapes: [Shape] = [
     SmallCircle(radius: 5),
     LargePolygon(vertices: [(0,0),(1,0),(1,1)]),
     CircleClass(r: 3)
 ]

 for shape in shapes {
     print(String(format: "Area: %.2f", shape.area()))
 }
 // Output: Area: 78.54
 //         Area: 1.50
 //         Area: 28.27


Q42. How do you handle memory in a
 producer-consumer pattern?
----------------------------------------------
A: Use weak references or actor isolation to prevent
cycles. Ensure the consumer doesn't outlive the
producer or use weak references to allow
independent lifetimes.
Example:
 class DataProducer {
     var consumers: [WeakRef<DataConsumer>] = []

     func addConsumer(_ c: DataConsumer) {
         consumers.append(WeakRef(c))
     }

     func produce(data: String) {
         consumers = consumers.filter { $0.value != nil }
         for consumer in consumers.compactMap({ $0.value }) {
             consumer.consume(data)
         }
     }
     deinit { print("Producer freed") }
 }

 class DataConsumer {
     let id: Int
     init(id: Int) {
         self.id = id
         print("Consumer \(id) created")
     }
     func consume(_ data: String) {
         print("Consumer \(id) got: \(data)")
     }
     deinit { print("Consumer \(id) freed") }
 }

 let producer = DataProducer()
 var c1: DataConsumer? = DataConsumer(id: 1)
 var c2: DataConsumer? = DataConsumer(id: 2)
 // Output: Consumer 1 created
 //         Consumer 2 created

 producer.addConsumer(c1!)
 producer.addConsumer(c2!)
 producer.produce(data: "Hello")
 // Output: Consumer 1 got: Hello
 //         Consumer 2 got: Hello

 c1 = nil
 // Output: Consumer 1 freed

 producer.produce(data: "World")
 // Output: Consumer 2 got: World
 // Consumer 1 was automatically removed from list


Q43. What happens in memory when you call
 super.init() in a subclass?
----------------------------------------------
A: Memory for the entire object (including superclass
stored properties) is allocated upfront when the
subclass initializer begins. super.init() then
initializes the superclass's stored properties.
ARC tracks the entire combined object as one unit.
Example:
 class Animal {
     var species: String
     init(species: String) {
         self.species = species
         print("Animal init: \(species)")
     }
     deinit { print("Animal deinit: \(species)") }
 }

 class Bird: Animal {
     var canFly: Bool
     init(species: String, canFly: Bool) {
         self.canFly = canFly       // subclass props first
         super.init(species: species) // then super.init
         print("Bird init: \(species) canFly=\(canFly)")
     }
     deinit {
         print("Bird deinit: \(species)")
         // super.deinit called automatically after this
     }
 }

 var bird: Bird? = Bird(species: "Eagle", canFly: true)
 // Output: Animal init: Eagle
 //         Bird init: Eagle canFly=true

 bird = nil
 // Output: Bird deinit: Eagle
 //         Animal deinit: Eagle


Q44. How does @autoclosure interact
 with memory management?
----------------------------------------------
A: @autoclosure wraps an expression in a closure
automatically. If the expression captures self
or other references, the same rules apply as
regular closures. The closure is non-escaping
by default — use @escaping @autoclosure for
stored closures.
Example:
 class Logger {
     var prefix = "LOG"

     func log(_ message: @autoclosure () -> String) {
         // Non-escaping — no cycle risk, no [weak self] needed
         print("\(prefix): \(message())")
     }

     func logLater(_ message: @escaping @autoclosure () -> String) {
         // Escaping — capture rules apply
         DispatchQueue.global().async { [weak self] in
             guard let self = self else { return }
             print("\(self.prefix): \(message())")
         }
     }

     deinit { print("Logger freed") }
 }

 var logger: Logger? = Logger()

 // Non-escaping @autoclosure — safe:
 logger!.log("Application started")
 // Output: LOG: Application started

 // Escaping @autoclosure:
 logger!.logLater("Async message")

 logger = nil
 // Output: Logger freed
 //         (async — may print before or after freed)


Q45. How does Swift's ownership model
 relate to SE-0377 (borrowing and consuming)?
----------------------------------------------
A: Swift 5.9 introduced ownership modifiers for
fine-grained control of value lifetimes:

borrowing  — function reads but does not own/consume.
            Caller retains ownership. No copy needed.
consuming  — function takes ownership. Caller cannot
            use value after the call.
copy       — explicit copy of a value.
~Copyable  — types that cannot be copied (move-only).

This enables performance optimization by avoiding
unnecessary copies of large value types.
Example:
 struct LargeData {
     var buffer: [Int] = Array(1...10000)
 }

 // borrowing — read only, no copy:
 func inspect(_ data: borrowing LargeData) {
     print("Data count: \(data.buffer.count)")
 }

 // consuming — takes ownership:
 func process(_ data: consuming LargeData) {
     print("Processing \(data.buffer.count) items")
     // data cannot be used after this function returns
 }

 var bigData = LargeData()
 inspect(bigData)
 // Output: Data count: 10000
 // bigData still usable — only borrowed

 process(bigData)
 // Output: Processing 10000 items
 // bigData consumed — cannot use again


================================================================
PART 15 — COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

ARC FUNDAMENTALS
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Default reference type             | strong (no keyword)
Declare weak reference             | weak var name: Type?
Declare unowned reference          | unowned var/let name: Type
Check if unique reference          | isKnownUniquelyReferenced(&obj)
Extend lifetime for unsafe ops     | withExtendedLifetime(obj) { }
Class cleanup on dealloc           | deinit { }
Reference count hits 0 → triggers  | deinit called, memory freed

STRONG REFERENCES
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Default — increases count          | var x: MyClass = instance
Keeps instance alive               | As long as one strong ref exists
Can create cycles                  | Two classes reference each other
Fix cycles                         | Use weak or unowned on one side

WEAK REFERENCES
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Declaration                        | weak var name: Type?
Increases count?                   | No
Becomes nil on dealloc?            | Yes — automatically
Must be Optional?                  | Yes — always
Must be var?                       | Yes — let not allowed
Common use cases                   | Delegates, parent references, observers

UNOWNED REFERENCES
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Declaration                        | unowned let/var name: Type
Increases count?                   | No
Becomes nil on dealloc?            | No — crashes if accessed after dealloc
Must be Optional?                  | No
Use when?                          | Referenced object always outlives reference
Unsafe variant                     | unowned(unsafe) — no ARC check at all

CLOSURE MEMORY MANAGEMENT
Task                               | Code
-----------------------------------|------------------------------------------
Capture self weakly                | { [weak self] in guard let self else { return } }
Capture self unowned               | { [unowned self] in self.method() }
Capture variable by value          | { [x] in print(x) }
Capture multiple                   | { [weak self, weak delegate] in }
Swift 5.3+ self rebind             | { [weak self] in guard let self else { return } }
Non-escaping closure               | func f(c: () -> Void) — no [weak self] needed
Escaping closure                   | func f(c: @escaping () -> Void) — consider [weak self]

REFERENCE CYCLE SCENARIOS
Scenario                           | Fix
-----------------------------------|------------------------------------------
Class A ↔ Class B strong cycle     | weak or unowned on one side
Class holds closure, closure→self  | [weak self] or [unowned self]
Delegate declared strong           | weak var delegate: Protocol?
Timer strong target                | Block-based timer + [weak self]
Notification observer not removed  | removeObserver in deinit
Parent ↔ child tree                | strong parent→child, weak child→parent

VALUE vs REFERENCE
Aspect                             | Struct/Enum (Value) | Class (Reference)
-----------------------------------|---------------------|--------------------
ARC managed?                       | No                  | Yes
Copied on assign?                  | Yes                 | No — shared
Thread safe by default?            | Yes                 | No
Can create cycles?                 | No                  | Yes
Has deinit?                        | No                  | Yes
Identity check (===)               | No                  | Yes

COPY-ON-WRITE
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Types using COW                    | Array, Dictionary, String, Set
Check if unique ref                | isKnownUniquelyReferenced(&storage)
Custom COW wrapper                 | Wrap [T] in class, check uniqueness before mutate
When copy happens                  | First mutation after sharing

SWIFT 5.9 OWNERSHIP
Task                               | Code
-----------------------------------|------------------------------------------
Borrow without copy                | func f(_ x: borrowing T)
Take ownership (consume)           | func f(_ x: consuming T)
Explicit copy                      | let y = copy x
Non-copyable type                  | struct T: ~Copyable { }

 REFERENCE TYPES, VALUE TYPES, STRONG & WEAK REFERENCE
 COUNTING AND ARC IMPLEMENTATION IN SWIFT
 ===========================================================
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 ===========================================================


 ================================================================
 PART 1 — FOUNDATIONAL CONCEPTS
 ================================================================

 WHAT IS A TYPE IN SWIFT?
 =========================
 A type defines the kind of data a variable holds
 and how it behaves when assigned, passed, or copied.
 Swift has two fundamental categories of types:

   1. Value Types  — struct, enum, tuple
                     Copied when assigned or passed
                     Stored on the STACK (usually)
                     No reference counting
                     Thread-safe by default

   2. Reference Types — class, closure, actor
                        Shared when assigned or passed
                        Stored on the HEAP
                        Managed by ARC
                        Not inherently thread-safe

 MASTER COMPARISON TABLE
 ========================
 Feature                  | Value Type          | Reference Type
 -------------------------|---------------------|----------------------
 Swift kinds              | struct, enum, tuple | class, closure, actor
 Storage location         | Stack (typically)   | Heap
 Assignment behavior      | Copies data         | Shares reference
 ARC involvement          | None                | Yes
 Thread safety            | Yes (by default)    | No (needs care)
 Identity check (===)     | Not applicable      | Yes
 Inheritance              | No                  | Yes
 deinit                   | No                  | Yes
 Reference cycles         | Impossible          | Possible
 Memory overhead          | Minimal             | ARC bookkeeping
 Mutability keyword       | mutating            | No keyword needed
 Protocol conformance     | Yes                 | Yes
 Generics                 | Yes                 | Yes


 ================================================================
 PART 2 — VALUE TYPES IN DEPTH
 ================================================================

 WHAT IS A VALUE TYPE?
 ======================
 A value type stores its data directly.
 When you assign a value type to another variable
 or pass it to a function, Swift makes a complete
 independent copy. Changes to the copy do NOT
 affect the original.

 STRUCT — THE PRIMARY VALUE TYPE
 =================================
   struct Point {
       var x: Int
       var y: Int
   }

   var p1 = Point(x: 1, y: 2)
   var p2 = p1         // independent copy made here
   p2.x = 99

   print(p1.x)         // p1 unchanged
   // Output: 1
   print(p2.x)         // p2 is different
   // Output: 99

 STRUCT WITH METHODS
 ====================
   struct Rectangle {
       var width: Double
       var height: Double

       // mutating — can modify self
       mutating func scale(by factor: Double) {
           width  *= factor
           height *= factor
       }

       func area() -> Double {
           return width * height
       }
   }

   var r1 = Rectangle(width: 4.0, height: 3.0)
   var r2 = r1                 // copy
   r2.scale(by: 2.0)

   print(r1.area())            // r1 unchanged
   // Output: 12.0
   print(r2.area())
   // Output: 48.0

 ENUM — VALUE TYPE
 ==================
   enum Compass { case north, south, east, west }

   var dir1 = Compass.north
   var dir2 = dir1             // copy
   dir2 = .south

   print(dir1)                 // unchanged
   // Output: north
   print(dir2)
   // Output: south

 ENUM WITH ASSOCIATED VALUES
 ============================
   enum Temperature {
       case celsius(Double)
       case fahrenheit(Double)

       func toCelsius() -> Double {
           switch self {
           case .celsius(let c):    return c
           case .fahrenheit(let f): return (f - 32) * 5 / 9
           }
       }
   }

   var t1 = Temperature.celsius(100)
   var t2 = t1                 // copy
   t2 = .fahrenheit(212)

   print(t1.toCelsius())
   // Output: 100.0
   print(t2.toCelsius())
   // Output: 100.0

 TUPLE — VALUE TYPE
 ===================
   var coords1 = (x: 10, y: 20)
   var coords2 = coords1       // copy
   coords2.x = 999

   print(coords1.x)            // unchanged
   // Output: 10
   print(coords2.x)
   // Output: 999

 PASSING VALUE TYPES TO FUNCTIONS
 ==================================
   struct Counter {
       var count = 0
       mutating func increment() { count += 1 }
   }

   func resetCounter(_ c: Counter) -> Counter {
       var copy = c            // function receives a copy
       copy.count = 0
       return copy
   }

   var myCounter = Counter()
   myCounter.increment()
   myCounter.increment()
   myCounter.increment()
   print(myCounter.count)
   // Output: 3

   let reset = resetCounter(myCounter)
   print(myCounter.count)      // original unchanged
   // Output: 3
   print(reset.count)
   // Output: 0

 VALUE TYPES IN COLLECTIONS
 ============================
   struct Pixel {
       var red: Int
       var green: Int
       var blue: Int
   }

   var pixels = [Pixel(red: 255, green: 0, blue: 0),
                 Pixel(red: 0, green: 255, blue: 0)]

   var pixelsCopy = pixels     // array copy (COW)
   pixelsCopy[0].red = 0

   print(pixels[0].red)        // original unchanged
   // Output: 255
   print(pixelsCopy[0].red)
   // Output: 0

 NESTED VALUE TYPES
 ===================
   struct Address {
       var street: String
       var city: String
   }

   struct Person {
       var name: String
       var address: Address    // value type inside value type
   }

   var person1 = Person(name: "Alice",
                        address: Address(street: "Main St",
                                         city: "Springfield"))
   var person2 = person1       // deep copy of everything

   person2.name = "Bob"
   person2.address.city = "Shelbyville"

   print(person1.name)
   // Output: Alice
   print(person1.address.city)
   // Output: Springfield
   print(person2.name)
   // Output: Bob
   print(person2.address.city)
   // Output: Shelbyville

 VALUE TYPE MUTABILITY RULES
 =============================
   // let — completely immutable, no properties can change:
   let immutablePoint = Point(x: 1, y: 2)
   // immutablePoint.x = 5    // Error: cannot assign to property

   // var — mutable, properties can change:
   var mutablePoint = Point(x: 1, y: 2)
   mutablePoint.x = 5          // OK
   print(mutablePoint.x)
   // Output: 5


 ================================================================
 PART 3 — REFERENCE TYPES IN DEPTH
 ================================================================

 WHAT IS A REFERENCE TYPE?
 ==========================
 A reference type stores a reference (pointer) to
 data on the heap. When you assign a reference type
 to another variable or pass it to a function, both
 variables point to the SAME instance. Changes through
 one variable are visible through all others.

 CLASS — THE PRIMARY REFERENCE TYPE
 =====================================
   class Car {
       var make: String
       var speed: Int

       init(make: String, speed: Int) {
           self.make = make
           self.speed = speed
           print("Car \(make) created")
       }

       deinit {
           print("Car \(make) destroyed")
       }
   }

   var car1: Car? = Car(make: "Tesla", speed: 0)
   // Output: Car Tesla created

   var car2 = car1             // car2 points to SAME instance
   car2?.speed = 200

   print(car1?.speed ?? -1)    // car1 also sees the change
   // Output: 200

   car1 = nil                  // ref count: 1 (car2 still holds)
   car2 = nil                  // ref count: 0 — freed
   // Output: Car Tesla destroyed

 REFERENCE IDENTITY CHECK (===)
 ================================
   class Dog {
       var name: String
       init(name: String) { self.name = name }
   }

   let dog1 = Dog(name: "Rex")
   let dog2 = dog1             // same instance
   let dog3 = Dog(name: "Rex") // different instance, same data

   print(dog1 === dog2)        // same identity
   // Output: true
   print(dog1 === dog3)        // different identity
   // Output: false
   print(dog1 !== dog3)
   // Output: true

   // Equality (==) checks value — identity (===) checks reference:
   // dog1 == dog3 would check name if Equatable conformance added

 CLASS INHERITANCE
 ==================
   class Vehicle {
       var speed: Int = 0
       func describe() { print("Vehicle at \(speed)km/h") }
       init(speed: Int) {
           self.speed = speed
           print("Vehicle init \(speed)")
       }
       deinit { print("Vehicle deinit \(speed)") }
   }

   class Motorcycle: Vehicle {
       var brand: String
       override func describe() {
           print("Motorcycle \(brand) at \(speed)km/h")
       }
       init(brand: String, speed: Int) {
           self.brand = brand
           super.init(speed: speed)
           print("Motorcycle init \(brand)")
       }
       deinit { print("Motorcycle deinit \(brand)") }
   }

   var moto: Motorcycle? = Motorcycle(brand: "Yamaha",
                                       speed: 120)
   // Output: Vehicle init 120
   //         Motorcycle init Yamaha

   moto!.describe()
   // Output: Motorcycle Yamaha at 120km/h

   moto = nil
   // Output: Motorcycle deinit Yamaha
   //         Vehicle deinit 120

 CLOSURES ARE REFERENCE TYPES
 ==============================
   func makeAdder(addAmount: Int) -> (Int) -> Int {
       return { x in x + addAmount }  // closure on heap
   }

   let addFive  = makeAdder(addAmount: 5)
   let addFive2 = addFive   // both refer to the SAME closure

   print(addFive(10))
   // Output: 15
   print(addFive2(10))      // same closure — same result
   // Output: 15

 FUNCTION PARAMETERS — VALUE vs REFERENCE BEHAVIOR
 ===================================================
   struct ValueStruct { var count = 0 }
   class RefClass    { var count = 0 }

   func modifyValue(_ v: ValueStruct) {
       var copy = v
       copy.count = 99       // modifies the copy only
   }

   func modifyRef(_ r: RefClass) {
       r.count = 99          // modifies the original
   }

   var vs = ValueStruct()
   var rc = RefClass()

   modifyValue(vs)
   print(vs.count)
   // Output: 0              // unaffected

   modifyRef(rc)
   print(rc.count)
   // Output: 99             // original modified

 inout SIMULATES REFERENCE BEHAVIOR FOR VALUE TYPES
 ====================================================
   func doubleValue(_ x: inout Int) {
       x *= 2
   }

   var number = 10
   doubleValue(&number)
   print(number)
   // Output: 20


 ================================================================
 PART 4 — COPY ON WRITE (COW)
 ================================================================

 WHAT IS COPY-ON-WRITE?
 =======================
 COW is an optimization for value types that delays
 the actual copy until the moment a mutation occurs.
 Until then, multiple variables share the same
 underlying storage. Swift uses COW for Array,
 Dictionary, String, and Set.

 COW BEHAVIOR IN ARRAY
 ======================
   var array1 = [1, 2, 3, 4, 5]
   var array2 = array1    // no copy yet — shared storage

   print(array1)
   // Output: [1, 2, 3, 4, 5]
   print(array2)
   // Output: [1, 2, 3, 4, 5]

   array2.append(6)       // COPY happens NOW (first mutation)

   print(array1)          // unaffected
   // Output: [1, 2, 3, 4, 5]
   print(array2)
   // Output: [1, 2, 3, 4, 5, 6]

 COW BEHAVIOR IN STRING
 =======================
   var str1 = "Hello"
   var str2 = str1        // no copy yet

   str2 += " World"       // copy happens here

   print(str1)
   // Output: Hello
   print(str2)
   // Output: Hello World

 COW BEHAVIOR IN DICTIONARY
 ============================
   var dict1 = ["a": 1, "b": 2]
   var dict2 = dict1      // shared storage

   dict2["c"] = 3         // copy happens now

   print(dict1.count)
   // Output: 2
   print(dict2.count)
   // Output: 3

 IMPLEMENTING CUSTOM COW
 ========================
   // COW requires:
   // 1. A class to hold the actual mutable storage (heap)
   // 2. A struct as the public interface (stack)
   // 3. isKnownUniquelyReferenced to detect sharing

   final class _Storage<T> {
       var elements: [T]
       init(_ elements: [T]) {
           self.elements = elements
           print("Storage created with \(elements.count) elements")
       }
       init(copying other: _Storage<T>) {
           self.elements = other.elements
           print("Storage COPIED with \(other.elements.count) elements")
       }
   }

   struct COWContainer<T> {
       private var storage: _Storage<T>

       init(_ elements: [T] = []) {
           storage = _Storage(elements)
       }

       // Call before every mutation:
       private mutating func ensureUniqueStorage() {
           if !isKnownUniquelyReferenced(&storage) {
               storage = _Storage(copying: storage)
           }
       }

       mutating func append(_ element: T) {
           ensureUniqueStorage()
           storage.elements.append(element)
       }

       mutating func removeLast() {
           ensureUniqueStorage()
           storage.elements.removeLast()
       }

       var count: Int    { storage.elements.count }
       var isEmpty: Bool { storage.elements.isEmpty }
       var first: T?     { storage.elements.first }

       subscript(index: Int) -> T {
           get { storage.elements[index] }
           set {
               ensureUniqueStorage()
               storage.elements[index] = newValue
           }
       }
   }

   // Test COW behavior:
   var container1 = COWContainer([10, 20, 30])
   // Output: Storage created with 3 elements

   var container2 = container1  // no copy — shared storage

   print(container1.count)
   // Output: 3
   print(container2.count)
   // Output: 3

   container2.append(40)        // COPY triggered here
   // Output: Storage COPIED with 3 elements

   print(container1.count)      // container1 unaffected
   // Output: 3
   print(container2.count)
   // Output: 4

   container2.append(50)        // no copy — already unique
   print(container2.count)
   // Output: 5

   // Assign again — shared storage:
   var container3 = container2
   container1.append(99)        // container1 unique — no copy
   // Output: (no copy message — container1 was unique)

   container3[0] = 999          // copy triggered for container3
   // Output: Storage COPIED with 5 elements


 ================================================================
 PART 5 — AUTOMATIC REFERENCE COUNTING (ARC) IN DETAIL
 ================================================================

 WHAT IS ARC?
 ============
 ARC (Automatic Reference Counting) is Swift's
 memory management system for class instances.
 It automatically inserts retain and release
 operations at compile time.

 ARC LIFECYCLE
 =============
   Step 1: You create a class instance.
           ARC allocates heap memory.
           Sets reference count to 1.

   Step 2: You assign the instance to another variable.
           ARC increments reference count.

   Step 3: A variable goes out of scope or is set to nil.
           ARC decrements reference count.

   Step 4: Reference count reaches zero.
           ARC calls deinit.
           ARC frees the heap memory.

 ARC COMPILE-TIME INSERTION
 ===========================
   // What you write:
   var obj = MyClass()
   var obj2 = obj
   obj = nil

   // What ARC inserts (conceptually):
   // swift_retain(obj)        ← count: 1 (on creation)
   // swift_retain(obj)        ← count: 2 (on obj2 = obj)
   // swift_release(obj)       ← count: 1 (on obj = nil)
   // swift_release(obj2)      ← count: 0 → deinit called
   //                            (when obj2 goes out of scope)

 STEP-BY-STEP ARC WALKTHROUGH
 ==============================
   class Battery {
       let capacity: Int
       init(capacity: Int) {
           self.capacity = capacity
           print("Battery(\(capacity)) created — count: 1")
       }
       deinit {
           print("Battery(\(capacity)) destroyed — count: 0")
       }
   }

   print("--- Step 1: create ---")
   var b1: Battery? = Battery(capacity: 3000)
   // count: 1
   // Output: Battery(3000) created — count: 1

   print("--- Step 2: second reference ---")
   var b2: Battery? = b1
   // count: 2 — no dealloc

   print("--- Step 3: third reference ---")
   var b3: Battery? = b1
   // count: 3 — no dealloc

   print("--- Step 4: remove first ---")
   b1 = nil
   // count: 2 — no dealloc
   print("Still alive — count would be 2")

   print("--- Step 5: remove second ---")
   b2 = nil
   // count: 1 — no dealloc
   print("Still alive — count would be 1")

   print("--- Step 6: remove last ---")
   b3 = nil
   // count: 0 → deinit called
   // Output: Battery(3000) destroyed — count: 0

   // Full output:
   // --- Step 1: create ---
   // Battery(3000) created — count: 1
   // --- Step 2: second reference ---
   // --- Step 3: third reference ---
   // --- Step 4: remove first ---
   // Still alive — count would be 2
   // --- Step 5: remove second ---
   // Still alive — count would be 1
   // --- Step 6: remove last ---
   // Battery(3000) destroyed — count: 0

 ARC WITH FUNCTION CALLS
 ========================
   class Token {
       let value: String
       init(value: String) {
           self.value = value
           print("Token(\(value)) created")
       }
       deinit { print("Token(\(value)) freed") }
   }

   func process(token: Token) {
       // token parameter is a strong reference — count +1
       print("Processing: \(token.value)")
   }   // token goes out of scope — count -1

   var t: Token? = Token(value: "ABC123")
   // Output: Token(ABC123) created
   // count: 1

   process(token: t!)
   // count temporarily 2 inside process
   // Output: Processing: ABC123
   // count back to 1 after process returns

   t = nil
   // count: 0
   // Output: Token(ABC123) freed

 ARC IN ARRAYS
 ==============
   class Image {
       let name: String
       init(name: String) {
           self.name = name
           print("Image(\(name)) created")
       }
       deinit { print("Image(\(name)) freed") }
   }

   var gallery: [Image] = []

   var img1: Image? = Image(name: "photo1")
   var img2: Image? = Image(name: "photo2")
   // Output: Image(photo1) created
   //         Image(photo2) created
   // img1 count: 1, img2 count: 1

   gallery.append(img1!)
   gallery.append(img2!)
   // img1 count: 2, img2 count: 2

   img1 = nil              // count: 1 — not freed (gallery holds)
   img2 = nil              // count: 1 — not freed
   print("Gallery still holds images")

   gallery.removeFirst()   // img1 count: 0 — freed
   // Output: Image(photo1) freed

   gallery.removeAll()     // img2 count: 0 — freed
   // Output: Image(photo2) freed


 ================================================================
 PART 6 — STRONG REFERENCE COUNTING IN DETAIL
 ================================================================

 WHAT IS STRONG REFERENCE COUNTING?
 =====================================
 Every reference to a class instance is strong by default.
 Strong reference = "I own this — keep it alive."
 Each strong reference increments the count by 1.
 Each strong reference removal decrements by 1.
 When count reaches 0 → deinit → memory freed.

 STRONG REFERENCE COUNT — LINE BY LINE
 =======================================
   class Server {
       let host: String
       init(host: String) {
           self.host = host
           print("Server(\(host)) CREATED — RC=1")
       }
       deinit { print("Server(\(host)) FREED — RC=0") }
   }

   // RC = Reference Count

   var s1: Server?          // RC = 0 (not yet created)
   s1 = Server(host: "api.example.com")
   // Output: Server(api.example.com) CREATED — RC=1
   // RC = 1

   var s2: Server? = s1     // s2 is strong reference
   // RC = 2

   var s3: Server? = s1     // s3 is strong reference
   // RC = 3

   var s4: Server? = s3     // s4 is strong reference to same object
   // RC = 4

   s1 = nil                 // RC = 3
   s3 = nil                 // RC = 2
   s4 = nil                 // RC = 1

   print("Server still alive — s2 holds it")

   s2 = nil                 // RC = 0 → freed
   // Output: Server(api.example.com) FREED — RC=0

 STRONG COUNT THROUGH PROPERTY CHAIN
 =====================================
   class Engine {
       let cc: Int
       init(cc: Int) {
           self.cc = cc
           print("Engine(\(cc)cc) created — RC=1")
       }
       deinit { print("Engine(\(cc)cc) freed") }
   }

   class Automobile {
       let model: String
       var engine: Engine         // strong reference

       init(model: String, engine: Engine) {
           self.model = model
           self.engine = engine   // RC of engine +1 = 2
           print("Automobile(\(model)) created")
       }
       deinit { print("Automobile(\(model)) freed") }
   }

   var eng: Engine? = Engine(cc: 2000)
   // eng RC = 1
   // Output: Engine(2000cc) created — RC=1

   var auto: Automobile? = Automobile(model: "Sedan", engine: eng!)
   // eng RC = 2 (auto.engine is strong)
   // Output: Automobile(Sedan) created

   eng = nil
   // eng variable removed — RC = 1 (auto.engine still holds)
   print("Engine still alive via auto.engine")

   auto = nil
   // auto freed — releases auto.engine — engine RC = 0
   // Output: Automobile(Sedan) freed
   //         Engine(2000cc) freed

 STRONG CYCLE FORMATION
 =======================
   class Employee {
       let name: String
       var manager: Manager?      // strong
       init(name: String) {
           self.name = name
           print("Employee(\(name)) RC=1")
       }
       deinit { print("Employee(\(name)) FREED") }
   }

   class Manager {
       let name: String
       var report: Employee?      // strong
       init(name: String) {
           self.name = name
           print("Manager(\(name)) RC=1")
       }
       deinit { print("Manager(\(name)) FREED") }
   }

   var emp: Employee? = Employee(name: "Alice")
   var mgr: Manager? = Manager(name: "Bob")
   // Output: Employee(Alice) RC=1
   //         Manager(Bob) RC=1

   emp!.manager = mgr    // mgr RC = 2
   mgr!.report  = emp    // emp RC = 2

   emp = nil             // emp RC = 1 — NOT freed (mgr holds)
   mgr = nil             // mgr RC = 1 — NOT freed (emp holds)

   // CYCLE: emp instance → mgr instance → emp instance
   // Neither deinit is ever called — MEMORY LEAK
   // Output: (nothing — both leaked)

 VISUALIZING STRONG COUNTS
 ===========================
   //
   //  Before nil:
   //
   //  emp (var) ──[strong RC+1]──► Employee("Alice") [RC=2]
   //  mgr (var) ──[strong RC+1]──► Manager("Bob")   [RC=2]
   //                               Employee ──[strong RC+1]──► Manager
   //                               Manager  ──[strong RC+1]──► Employee
   //
   //  After emp=nil, mgr=nil:
   //
   //  emp (var) = nil              Employee("Alice") [RC=1]
   //  mgr (var) = nil              Manager("Bob")   [RC=1]
   //                               Employee ──[strong]──► Manager [RC=1]
   //                               Manager  ──[strong]──► Employee [RC=1]
   //
   //  Stranded cycle — neither can reach RC=0


 ================================================================
 PART 7 — WEAK REFERENCE COUNTING IN DETAIL
 ================================================================

 WHAT IS A WEAK REFERENCE COUNT?
 =================================
 A weak reference does NOT increment the strong
 reference count. The object tracks weak references
 separately in a side table. When the strong count
 reaches zero, the object is freed and all weak
 references are automatically set to nil.

 WEAK REFERENCE RULES
 =====================
   1. Declared with weak keyword
   2. Must be Optional (can become nil)
   3. Must be var (ARC sets it to nil)
   4. Does not prevent deallocation
   5. Never causes a crash on access (returns nil)
   6. Only valid for class types (reference types)

 WEAK REFERENCE COUNT — LINE BY LINE
 =====================================
   class Session {
       let id: String
       init(id: String) {
           self.id = id
           print("Session(\(id)) created — strong RC=1")
       }
       deinit { print("Session(\(id)) freed — strong RC=0") }
   }

   var strong1: Session? = Session(id: "S001")
   // strong RC = 1
   // Output: Session(S001) created — strong RC=1

   weak var weak1: Session? = strong1
   // strong RC = 1 (unchanged — weak doesn't count)
   // weak refs tracked separately in side table

   weak var weak2: Session? = strong1
   // strong RC = 1 still

   print(weak1?.id ?? "nil")
   // Output: S001
   print(weak2?.id ?? "nil")
   // Output: S001

   var strong2: Session? = strong1
   // strong RC = 2

   strong1 = nil
   // strong RC = 1 — not freed yet
   print(weak1?.id ?? "nil")   // still alive via strong2
   // Output: S001

   strong2 = nil
   // strong RC = 0 → freed
   // Output: Session(S001) freed — strong RC=0

   // ARC automatically sets all weak refs to nil:
   print(weak1?.id ?? "nil")
   // Output: nil
   print(weak2?.id ?? "nil")
   // Output: nil

 FIXING THE STRONG CYCLE WITH WEAK
 ===================================
   class Author {
       let name: String
       var book: Book?            // strong — Author owns Book
       init(name: String) {
           self.name = name
           print("Author(\(name)) RC=1")
       }
       deinit { print("Author(\(name)) FREED ✓") }
   }

   class Book {
       let title: String
       weak var author: Author?   // weak — Book does NOT own Author
       init(title: String) {
           self.title = title
           print("Book(\(title)) RC=1")
       }
       deinit { print("Book(\(title)) FREED ✓") }
   }

   var auth: Author? = Author(name: "Tolkien")
   var book: Book?   = Book(title: "LOTR")
   // Output: Author(Tolkien) RC=1
   //         Book(LOTR) RC=1

   auth!.book   = book   // book strong RC = 2
   book!.author = auth   // auth strong RC = 1 (weak — no change)

   //
   //  auth (var) ──strong──► Author [RC=1]
   //                         Author.book ──strong──► Book [RC=2]
   //  book (var) ──strong──► Book   [RC=2]
   //                         Book.author ──WEAK──► Author [RC=1]
   //

   auth = nil
   // Author strong RC = 0 → freed immediately
   // Output: Author(Tolkien) FREED ✓
   // Author's book property released → book strong RC = 1
   print(book!.author)    // weak ref auto-set to nil
   // Output: nil

   book = nil
   // book strong RC = 0 → freed
   // Output: Book(LOTR) FREED ✓
   // NO MEMORY LEAK — both freed correctly ✓

 WEAK IN DELEGATE PATTERN
 =========================
   protocol NetworkDelegate: AnyObject {
       func didLoad(data: String)
       func didFail(error: String)
   }

   class NetworkManager {
       weak var delegate: NetworkDelegate?   // weak — key!

       func simulateLoad(success: Bool) {
           if success {
               delegate?.didLoad(data: "Response JSON")
           } else {
               delegate?.didFail(error: "Timeout")
           }
       }
       deinit { print("NetworkManager freed") }
   }

   class ViewController: NetworkDelegate {
       let network = NetworkManager()

       init() {
           network.delegate = self   // would cycle if strong
           print("ViewController created")
       }

       func didLoad(data: String) {
           print("Loaded: \(data)")
       }

       func didFail(error: String) {
           print("Error: \(error)")
       }

       deinit { print("ViewController freed") }
   }

   var vc: ViewController? = ViewController()
   // Output: ViewController created

   vc!.network.simulateLoad(success: true)
   // Output: Loaded: Response JSON

   vc!.network.simulateLoad(success: false)
   // Output: Error: Timeout

   vc = nil
   // ViewController RC = 0 → freed
   // Output: NetworkManager freed   (held by vc.network)
   //         ViewController freed
   // No cycle — delegate was weak ✓


 ================================================================
 PART 8 — UNOWNED REFERENCE COUNTING IN DETAIL
 ================================================================

 WHAT IS AN UNOWNED REFERENCE?
 ==============================
 An unowned reference does not increment the strong
 reference count. Unlike weak, it is NOT optional and
 is NOT zeroed when the object is freed. If you access
 an unowned reference after the object is freed, you
 get an immediate crash.

 UNOWNED vs WEAK COMPARISON
 ============================
   Property           | weak             | unowned
   -------------------|------------------|------------------
   Keyword            | weak             | unowned
   Optional           | Always (var?)    | Never
   Auto-nil on free   | Yes              | No
   Crash on bad access| No (returns nil) | Yes (immediate crash)
   ARC check          | Yes              | Yes (safe), No (unsafe)
   Use when           | Might become nil | Always outlives ref

 UNOWNED REFERENCE — STEP BY STEP
 ==================================
   class Subscription {
       let plan: String
       var invoice: Invoice?      // strong — owns invoice
       init(plan: String) {
           self.plan = plan
           print("Subscription(\(plan)) RC=1")
       }
       deinit { print("Subscription(\(plan)) FREED") }
   }

   class Invoice {
       let amount: Double
       unowned let subscription: Subscription  // unowned
       init(amount: Double, subscription: Subscription) {
           self.amount   = amount
           self.subscription = subscription
           // subscription RC stays 1 — unowned doesn't add
           print("Invoice(\(amount)) RC=1, sub RC unchanged=1")
       }
       deinit { print("Invoice(\(amount)) FREED") }
   }

   var sub: Subscription? = Subscription(plan: "Pro")
   // sub RC = 1
   // Output: Subscription(Pro) RC=1

   sub!.invoice = Invoice(amount: 29.99, subscription: sub!)
   // invoice RC = 1 (held by sub.invoice)
   // sub RC stays 1 — unowned doesn't increment
   // Output: Invoice(29.99) RC=1, sub RC unchanged=1

   //
   //  sub (var) ──strong──► Subscription [RC=1]
   //                        Subscription.invoice ──strong──► Invoice [RC=1]
   //                        Invoice.subscription ──UNOWNED──► Subscription [RC=1]
   //

   sub = nil
   // sub RC = 0 → Subscription freed
   // Subscription releases .invoice → invoice RC = 0 → Invoice freed
   // Output: Subscription(Pro) FREED
   //         Invoice(29.99) FREED
   // Both freed cleanly — no cycle ✓


 ================================================================
 PART 9 — ARC IMPLEMENTATION INTERNALS
 ================================================================

 HOW ARC WORKS INTERNALLY
 =========================
 Each class instance has a hidden header containing:
   - isa pointer     — type metadata pointer
   - Strong RC       — strong reference count
   - Unowned RC      — unowned reference count + 1
   - Weak RC         — weak reference count

 When strong RC hits 0:
   1. deinit is called on the instance
   2. Instance memory is invalidated (not immediately freed)
   3. Unowned RC decremented by 1
   4. If unowned RC also hits 0 → memory actually freed
   5. Weak references zero out (via side table)

 SIMPLIFIED ARC SIMULATION IN SWIFT
 =====================================
   // This simulates what ARC does internally
   // NOT actual ARC code — for educational purposes only

   class ARCSimulator {
       let name: String
       private(set) var strongCount: Int = 0
       private(set) var weakCount:   Int = 0

       init(name: String) {
           self.name = name
           retain()
           print("\(name) created: strong=\(strongCount)")
       }

       func retain() {
           strongCount += 1
           print("\(name) retain → strong=\(strongCount)")
       }

       func release() {
           strongCount -= 1
           print("\(name) release → strong=\(strongCount)")
           if strongCount == 0 {
               print("\(name) deinit called — memory freed")
           }
       }

       func weakRetain() {
           weakCount += 1
           print("\(name) weakRetain → weak=\(weakCount)")
       }

       func weakRelease() {
           weakCount -= 1
           print("\(name) weakRelease → weak=\(weakCount)")
       }
   }

   // Simulating: var a = Obj(), var b = a, a = nil, b = nil
   let obj = ARCSimulator(name: "Object")
   // Output: Object retain → strong=1
   //         Object created: strong=1

   obj.retain()    // var b = a
   // Output: Object retain → strong=2

   obj.weakRetain() // weak var w = a
   // Output: Object weakRetain → weak=1

   obj.release()   // a = nil
   // Output: Object release → strong=1

   obj.release()   // b = nil
   // Output: Object release → strong=0
   //         Object deinit called — memory freed

   obj.weakRelease() // weak ref zeroed
   // Output: Object weakRelease → weak=0

 SIDE TABLE — HOW WEAK REFERENCES WORK
 ========================================
   // When a weak reference is created, Swift may
   // allocate a "side table" alongside the object.
   // The side table holds:
   //   - Pointer back to the object
   //   - Weak reference count
   //
   // When strong RC → 0:
   //   1. Object data is destroyed (deinit)
   //   2. Side table remains alive (weak count > 0)
   //   3. Weak references become nil via side table
   //   4. When weak RC → 0, side table also freed
   //
   // This is why weak references NEVER crash:
   // The side table redirects them to nil safely.

   // Illustration:
   class SideTableDemo {
       let id = "demo"
       deinit { print("SideTableDemo freed") }
   }

   var strong: SideTableDemo? = SideTableDemo()
   weak var weakRef1: SideTableDemo? = strong
   weak var weakRef2: SideTableDemo? = strong

   // Memory layout (conceptual):
   // strong   ──────────────────────────────► [SideTableDemo instance]
   // weakRef1 ──► [Side Table] ──────────────► [SideTableDemo instance]
   // weakRef2 ──► [Side Table] ──────────────► [SideTableDemo instance]

   print(weakRef1 != nil)
   // Output: true

   strong = nil
   // strong RC = 0 → deinit → instance destroyed
   // Output: SideTableDemo freed
   // Side table remains, sets weakRef1, weakRef2 to nil

   print(weakRef1 != nil)
   // Output: false       ← safely nil, no crash
   print(weakRef2 != nil)
   // Output: false

 ARC RETAIN/RELEASE AT COMPILE TIME
 =====================================
   // Swift compiler inserts retain/release calls.
   // You can see this in SIL (Swift Intermediate Language):
   //   swiftc -emit-sil main.swift | grep retain
   //
   // Conceptual expansion of:
   //   var x: MyClass? = MyClass()
   //   var y = x
   //   x = nil
   //   y = nil
   //
   // Compiles to roughly:
   //   %obj = swift_allocObject(...)   // alloc on heap
   //   swift_retain(%obj)              // RC = 1
   //   var x = %obj
   //
   //   swift_retain(%obj)              // RC = 2
   //   var y = %obj
   //
   //   swift_release(%obj)             // RC = 1  (x = nil)
   //
   //   swift_release(%obj)             // RC = 0  (y = nil)
   //   // RC = 0 → swift_deallocObject(%obj)

 ARC THREAD SAFETY
 ==================
   // ARC reference count operations are ATOMIC.
   // This means increment/decrement are thread-safe.
   // Two threads can retain/release the same object safely.
   // However, the OBJECT'S DATA is NOT thread-safe —
   // only the counting is atomic.

   class ThreadSafeCounter {
       private var value = 0
       private let lock = NSLock()

       func increment() {
           lock.lock()
           value += 1
           lock.unlock()
       }

       func get() -> Int {
           lock.lock()
           defer { lock.unlock() }
           return value
       }
   }

   // ARC keeps the instance alive across threads safely,
   // but accessing 'value' needs manual synchronization.
   let counter = ThreadSafeCounter()

   let q = DispatchQueue.global()
   let group = DispatchGroup()

   for _ in 0..<5 {
       group.enter()
       q.async {
           counter.increment()
           group.leave()
       }
   }

   group.notify(queue: .main) {
       print("Count: \(counter.get())")
   }
   // Output: Count: 5

 ARC AND SWIFT OPTIMIZER
 ========================
   // The Swift optimizer can eliminate unnecessary
   // retain/release pairs. For example:
   //
   //   func process(_ obj: MyClass) {
   //       swift_retain(obj)         ← inserted for param
   //       let x = obj.value
   //       swift_release(obj)        ← immediately after use
   //   }
   //
   // The optimizer may detect obj doesn't escape
   // and eliminate the retain/release entirely.
   // Use 'final' on classes to help the optimizer:

   final class OptimizedClass {
       // final means no subclasses — enables devirtualization
       // Compiler knows exact method implementations
       // Allows inlining — fewer retain/release calls
       var data: Int = 0
       func compute() -> Int { data * 2 }
   }

   // Also: @inline(__always) can force inlining:
   final class FastClass {
       var value: Int = 0
       @inline(__always) func doubled() -> Int { value * 2 }
   }


 ================================================================
 PART 10 — COMPLETE ARC SCENARIOS WITH REFERENCE COUNTS
 ================================================================

 SCENARIO 1: SIMPLE STRONG CHAIN
 =================================
   class Link {
       let id: Int
       init(id: Int) {
           self.id = id
           print("Link(\(id)) — RC=1")
       }
       deinit { print("Link(\(id)) — freed") }
   }

   // RC tracking:
   var a: Link? = Link(id: 1)  // RC[1] = 1
   var b: Link? = a             // RC[1] = 2
   var c: Link? = b             // RC[1] = 3
   var d: Link? = Link(id: 2)  // RC[2] = 1

   // Output: Link(1) — RC=1
   //         Link(2) — RC=1

   b = d                        // RC[1] = 2, RC[2] = 2
   c = nil                      // RC[1] = 1
   a = nil                      // RC[1] = 0 → freed
   // Output: Link(1) — freed

   d = nil                      // RC[2] = 1 (b still holds)
   b = nil                      // RC[2] = 0 → freed
   // Output: Link(2) — freed

 SCENARIO 2: STRONG CYCLE (LEAK)
 =================================
   class NodeA {
       var nodeB: NodeB?
       deinit { print("NodeA freed") }
   }
   class NodeB {
       var nodeA: NodeA?
       deinit { print("NodeB freed") }
   }

   var na: NodeA? = NodeA()  // RC[A] = 1
   var nb: NodeB? = NodeB()  // RC[B] = 1

   na!.nodeB = nb             // RC[B] = 2
   nb!.nodeA = na             // RC[A] = 2

   na = nil                   // RC[A] = 1 — not freed
   nb = nil                   // RC[B] = 1 — not freed

   // Both stuck at RC=1 forever — MEMORY LEAK
   // Output: (nothing)

 SCENARIO 3: WEAK BREAKS CYCLE
 ================================
   class NodeC {
       var nodeD: NodeD?
       deinit { print("NodeC freed ✓") }
   }
   class NodeD {
       weak var nodeC: NodeC?  // WEAK
       deinit { print("NodeD freed ✓") }
   }

   var nc: NodeC? = NodeC()  // RC[C] = 1
   var nd: NodeD? = NodeD()  // RC[D] = 1

   nc!.nodeD = nd             // RC[D] = 2
   nd!.nodeC = nc             // RC[C] = 1 (weak — unchanged)

   // RC diagram:
   // nc var ──strong──► NodeC [RC=1]
   //                   NodeC.nodeD ──strong──► NodeD [RC=2]
   // nd var ──strong──► NodeD [RC=2]
   //                   NodeD.nodeC ──WEAK──► NodeC [RC=1]

   nc = nil                   // RC[C] = 0 → freed
   // Output: NodeC freed ✓

   // NodeC freed → releases nodeD → RC[D] = 1
   print(nd!.nodeC)           // auto-nil
   // Output: nil

   nd = nil                   // RC[D] = 0 → freed
   // Output: NodeD freed ✓

 SCENARIO 4: CLOSURE STRONG CYCLE
 ==================================
   class ViewModel {
       var name = "Home"
       var onUpdate: (() -> Void)?

       init() { print("ViewModel created") }

       // PROBLEM: strong capture of self
       func setupBad() {
           onUpdate = {                       // strong capture
               print("Updated: \(self.name)") // self RC +1
           }
       }

       // FIXED: weak capture of self
       func setupGood() {
           onUpdate = { [weak self] in
               guard let self = self else { return }
               print("Updated: \(self.name)")
           }
       }

       deinit { print("ViewModel freed") }
   }

   print("=== BAD ===")
   var vmBad: ViewModel? = ViewModel()
   vmBad!.setupBad()
   // RC[vmBad] = 2 (variable + closure capture)
   vmBad = nil
   // RC[vmBad] = 1 — closure still holds self
   // Output: ViewModel created
   // Output: (no deinit — LEAKED)

   print("=== GOOD ===")
   var vmGood: ViewModel? = ViewModel()
   vmGood!.setupGood()
   // RC[vmGood] = 1 (variable only — weak capture)
   vmGood!.onUpdate?()
   // Output: ViewModel created
   // Output: Updated: Home
   vmGood = nil
   // RC[vmGood] = 0 → freed
   // Output: ViewModel freed ✓

 SCENARIO 5: UNOWNED IN CLOSURE
 ================================
   class UserProfile {
       var username: String
       // unowned safe — lazy property outlived by self
       lazy var greeting: () -> String = { [unowned self] in
           return "Hello, \(self.username)!"
       }
       init(username: String) {
           self.username = username
           print("UserProfile(\(username)) created")
       }
       deinit { print("UserProfile(\(username)) freed") }
   }

   var profile: UserProfile? = UserProfile(username: "Alice")
   // Output: UserProfile(Alice) created

   print(profile!.greeting())
   // Output: Hello, Alice!

   profile = nil
   // Output: UserProfile(Alice) freed ✓
   // unowned did not form a cycle — both freed cleanly

 SCENARIO 6: PARENT-CHILD TREE
 ================================
   class TreeNode {
       let value: Int
       var children: [TreeNode] = []  // strong — owns children
       weak var parent: TreeNode?     // weak — does not own parent

       init(value: Int) {
           self.value = value
           print("Node(\(value)) created")
       }

       func addChild(_ child: TreeNode) {
           child.parent = self
           children.append(child)
       }

       deinit { print("Node(\(value)) freed") }
   }

   var root: TreeNode? = TreeNode(value: 1)
   let n2 = TreeNode(value: 2)
   let n3 = TreeNode(value: 3)
   let n4 = TreeNode(value: 4)
   // Output: Node(1) created
   //         Node(2) created
   //         Node(3) created
   //         Node(4) created

   root!.addChild(n2)
   root!.addChild(n3)
   n2.addChild(n4)

   print(n4.parent?.value ?? -1)
   // Output: 2

   // RC diagram:
   // root var ──strong──► Node(1) [RC=1]
   //                      Node(1).children[0] ──strong──► Node(2) [RC=1]
   //                      Node(1).children[1] ──strong──► Node(3) [RC=1]
   //                      Node(2).children[0] ──strong──► Node(4) [RC=1]
   //                      Node(2).parent ──WEAK──► Node(1) [RC=1]
   //                      Node(3).parent ──WEAK──► Node(1) [RC=1]
   //                      Node(4).parent ──WEAK──► Node(2) [RC=1]

   root = nil
   // root RC = 0 → Node(1) freed
   // Node(1) releases children → Node(2) RC=0, Node(3) RC=0
   // Node(2) releases children → Node(4) RC=0
   // All freed in cascade — no leaks ✓
   // Output (order may vary):
   // Node(1) freed
   // Node(2) freed
   // Node(3) freed
   // Node(4) freed


 ================================================================
 PART 11 — INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 SECTION 1 — BASIC LEVEL
 ================================================================

 Q1. What is the difference between a value type
     and a reference type?
 ----------------------------------------------------
 A: Value type — copied on assignment (struct, enum).
                Changes to copy don't affect original.
    Reference type — shared on assignment (class).
                     Changes through one ref affect all.
    Example:
      struct VS { var x: Int }
      class RS { var x: Int; init(_ x: Int) { self.x = x } }

      var v1 = VS(x: 1)
      var v2 = v1         // copy
      v2.x = 99
      print(v1.x)         // unchanged
      // Output: 1

      var r1 = RS(10)
      var r2 = r1         // shared
      r2.x = 99
      print(r1.x)         // also changed
      // Output: 99


 Q2. What is ARC?
 -----------------
 A: Automatic Reference Counting — Swift's memory
    management system for class instances.
    Tracks how many strong references exist.
    Frees memory when count reaches zero.
    Example:
      class Obj {
          init()  { print("created") }
          deinit  { print("freed") }
      }
      var a: Obj? = Obj()  // RC=1 — Output: created
      var b: Obj? = a      // RC=2
      a = nil              // RC=1
      b = nil              // RC=0 — Output: freed


 Q3. What is a strong reference?
 --------------------------------
 A: Default reference type. Increases RC by 1.
    Keeps instance alive while at least one exists.
    Example:
      class Data {
          deinit { print("Data freed") }
      }
      var x: Data? = Data()  // RC=1
      var y: Data? = x       // RC=2
      x = nil                // RC=1 — NOT freed
      y = nil                // RC=0 — Output: Data freed


 Q4. What is a weak reference?
 ------------------------------
 A: Does NOT increase RC. Always Optional var.
    Set to nil when instance is freed.
    Prevents strong reference cycles.
    Example:
      class Thing {
          deinit { print("Thing freed") }
      }
      var strong: Thing? = Thing()    // RC=1
      weak var weakRef: Thing? = strong
      print(weakRef != nil)           // Output: true
      strong = nil                    // RC=0 → freed
      // Output: Thing freed
      print(weakRef)                  // Output: nil


 Q5. What is an unowned reference?
 -----------------------------------
 A: Does NOT increase RC. Not Optional.
    Does NOT become nil on dealloc.
    Crashes if accessed after dealloc.
    Use when referenced object always outlives the reference.
    Example:
      class Owner { var item: Item2?; deinit { print("Owner freed") } }
      class Item2 {
          unowned let owner: Owner
          init(owner: Owner) { self.owner = owner }
          deinit { print("Item2 freed") }
      }
      var owner: Owner? = Owner()
      owner!.item = Item2(owner: owner!)
      owner = nil
      // Output: Owner freed
      //         Item2 freed


 Q6. What causes a strong reference cycle?
 ------------------------------------------
 A: When two class instances hold strong references
    to each other — both ref counts stay above zero.
    Neither can be freed — causes a memory leak.
    Example:
      class X { var y: Y?; deinit { print("X freed") } }
      class Y { var x: X?; deinit { print("Y freed") } }
      var x: X? = X(); var y: Y? = Y()
      x!.y = y; y!.x = x
      x = nil; y = nil
      // Output: (nothing — both leaked)


 Q7. When is deinit called?
 ---------------------------
 A: Automatically when the last strong reference
    is removed and RC drops to zero.
    Cannot be called manually.
    Example:
      class Resource {
          init()  { print("opened") }
          deinit  { print("closed") }
      }
      do {
          let r = Resource()  // RC=1, Output: opened
      }                       // RC=0, Output: closed


 Q8. What is the difference between weak
     and unowned?
 -------------------------------------------
 A: weak   — Optional, auto-nil, safe after dealloc
    unowned — Non-optional, no auto-nil, crash after dealloc
    Example:
      class Obj2 { deinit { print("freed") } }
      var obj: Obj2? = Obj2()
      // unowned var u:
     weak var w: Obj2? = obj      // Optional — safe
     obj = nil
     // Output: freed
     print(w)                     // auto-nil — no crash
     // Output: nil

     // unowned — non-optional — crashes if accessed after free
     // Use only when lifetime is guaranteed


    Q9. Does ARC work with structs or enums?
    -----------------------------------------
    A: No. ARC only manages class instances on the heap.
    Structs and enums are value types on the stack
    and are managed automatically by the compiler.
    Example:
     struct ValueType { var n: Int }
     var v1 = ValueType(n: 10)
     var v2 = v1                // copy — no ARC
     v2.n = 99
     print(v1.n)
     // Output: 10              // unaffected — no ARC involved


    Q10. What is a memory leak?
    -----------------------------
    A: Memory that is allocated but can never be freed
    because its reference count can never reach zero.
    Common cause: strong reference cycles.
    Example:
     class Leak {
         var other: Leak?
         deinit { print("freed") }
     }
     var a: Leak? = Leak()
     var b: Leak? = Leak()
     a!.other = b              // cycle
     b!.other = a              // cycle
     a = nil; b = nil
     // Output: (nothing — both leaked forever)


    Q11. What keyword makes a reference weak?
    ------------------------------------------
    A: The weak keyword. Must be var and Optional.
    Example:
     class Example2 {
         weak var ref: AnyObject?  // must be var Optional
     }


    Q12. Can a struct have a reference cycle?
    ------------------------------------------
    A: No. Value types are copied — they cannot
    form reference cycles. Cycles only happen
    with reference types (class, closure).
    Example:
     struct Node2 {
         // var next: Node2?  // Error — recursive value type
         // Must use class for linked structures
     }
     // Structs with class properties CAN participate
     // in cycles through the class side, not the struct side.


    Q13. What does === check?
    --------------------------
    A: === checks reference identity — whether two
    variables point to the exact same instance.
    == checks value equality (if Equatable).
    Example:
     class Box2 { var v: Int; init(_ v: Int) { self.v = v } }
     let b1 = Box2(5)
     let b2 = b1          // same instance
     let b3 = Box2(5)     // different instance

     print(b1 === b2)     // same reference
     // Output: true
     print(b1 === b3)     // different reference
     // Output: false


    Q14. Why must weak references be Optional var?
    -----------------------------------------------
    A: Optional — because ARC may set it to nil
              when the referenced object is freed.
    var — because ARC must be able to reassign it to nil.
    let is immutable — ARC cannot set it to nil.
    Example:
     class Demo3 {}
     // weak let x: Demo3? = nil    // Error: weak + let invalid
     weak var x: Demo3? = nil       // OK


    Q15. What is the reference count when you
     create a class instance?
    -----------------------------------------------
    A: 1. The instance starts with a reference count
    of 1 when first created and assigned to a variable.
    Example:
     class Start {
         init()  { print("RC is now 1") }
         deinit  { print("RC reached 0 — freed") }
     }
     var s: Start? = Start()   // RC=1
     // Output: RC is now 1
     s = nil                   // RC=0
     // Output: RC reached 0 — freed


    ================================================================
    SECTION 2 — INTERMEDIATE LEVEL
    ================================================================

    Q16. What is Copy-on-Write and which types use it?
    ---------------------------------------------------
    A: COW delays copying until the moment of mutation.
    Multiple variables share storage until one mutates.
    Used by Array, Dictionary, String, Set.
    Example:
     var arr1 = [1, 2, 3, 4, 5]
     var arr2 = arr1           // no copy yet — shared
     arr2.append(6)            // COPY happens now
     print(arr1.count)
     // Output: 5              // unchanged
     print(arr2.count)
     // Output: 6


    Q17. How does weak prevent a reference cycle?
    ----------------------------------------------
    A: By not incrementing the reference count on
    the referenced object, one side of the cycle
    can reach RC=0 and be freed. The weak reference
    then becomes nil automatically.
    Example:
     class Parent2 {
         var child: Child3?
         deinit { print("Parent2 freed ✓") }
     }
     class Child3 {
         weak var parent: Parent2?  // weak — no RC increase
         deinit { print("Child3 freed ✓") }
     }
     var p: Parent2? = Parent2()
     var c: Child3?  = Child3()
     p!.child  = c              // child RC = 2
     c!.parent = p              // parent RC = 1 (weak)
     p = nil                    // parent RC = 0 → freed
     // Output: Parent2 freed ✓
     // Freed parent releases child → child RC = 1
     c = nil                    // child RC = 0 → freed
     // Output: Child3 freed ✓


    Q18. When should you use unowned vs weak?
    ------------------------------------------
    A: weak   — when the referenced object CAN become nil.
             Access through Optional — safe.
    unowned — when the referenced object will NEVER
             become nil before the reference does.
             Access is non-optional — fast but dangerous.
    Example:
     class Account {
         var card: Card?
         deinit { print("Account freed") }
     }
     class Card {
         // Card cannot exist without Account — use unowned:
         unowned let account: Account
         init(account: Account) { self.account = account }
         deinit { print("Card freed") }
     }
     var acc: Account? = Account()
     acc!.card = Card(account: acc!)
     acc = nil
     // Output: Account freed
     //         Card freed


    Q19. What happens to a weak reference when
     the object it points to is freed?
    -----------------------------------------------
    A: ARC automatically sets it to nil.
    The next access returns nil — no crash.
    Example:
     class Temp {
         deinit { print("Temp freed") }
     }
     var strong: Temp? = Temp()
     weak var weak3: Temp? = strong

     print(weak3 != nil)
     // Output: true

     strong = nil
     // Output: Temp freed

     print(weak3 != nil)   // automatically nil
     // Output: false
     print(weak3)
     // Output: nil


    Q20. How do you fix a closure reference cycle?
    -----------------------------------------------
    A: Use a capture list [weak self] or [unowned self]
    to prevent the closure from strongly capturing self.
    Example:
     class Animator {
         var label = "Fade"
         var action: (() -> Void)?

         func setup() {
             action = { [weak self] in            // fixed
                 guard let self = self else { return }
                 print("Animating: \(self.label)")
             }
         }
         deinit { print("Animator freed") }
     }

     var anim: Animator? = Animator()
     anim!.setup()
     anim!.action?()
     // Output: Animating: Fade
     anim = nil
     // Output: Animator freed ✓


    Q21. What is the difference between inout
     and a reference type for mutation?
    -----------------------------------------------
    A: inout — passes the address of a value type,
           allowing mutation. Value is copied back.
           The caller's value is modified in place.
    Reference type — passed by reference naturally.
                    No special keyword needed.
    Example:
     // inout — value type mutation:
     func addTen(_ x: inout Int) { x += 10 }
     var num = 5
     addTen(&num)
     print(num)
     // Output: 15

     // Reference type — naturally mutated:
     class Counter2 { var value = 0 }
     func addTenRef(_ c: Counter2) { c.value += 10 }
     let cnt = Counter2()
     addTenRef(cnt)
     print(cnt.value)
     // Output: 10


    Q22. Can a struct contain a class property?
    What happens to memory?
    -----------------------------------------------
    A: Yes. The struct itself is a value type (stack).
    The class property is a reference type (heap).
    When you copy the struct, you copy the reference —
    both structs share the same class instance.
    Example:
     class Engine2 {
         var hp: Int = 0
         init(hp: Int) { self.hp = hp }
         deinit { print("Engine2 freed") }
     }
     struct Car2 {
         var model: String
         var engine: Engine2       // class inside struct
     }
     var car1 = Car2(model: "A", engine: Engine2(hp: 200))
     var car2 = car1               // struct is copied
     // but engine reference is SHARED

     car2.engine.hp = 999          // modifies shared instance
     print(car1.engine.hp)
     // Output: 999                // car1 sees the change

     car2.model = "B"              // String is value type — copied
     print(car1.model)
     // Output: A                  // car1 unaffected


    Q23. How does ARC handle class instances
     inside an array?
    -----------------------------------------------
    A: Array holds strong references to class instances.
    The array contributes to the reference count.
    Instance freed only when removed from array AND
    all other strong references are removed.
    Example:
     class Person4 {
         let name: String
         init(name: String) { self.name = name }
         deinit { print("\(name) freed") }
     }
     var arr: [Person4] = []
     var p1: Person4? = Person4(name: "Alice")
     arr.append(p1!)        // RC=2 (var + array)
     p1 = nil               // RC=1 — NOT freed
     print("Array still holds Alice")
     arr.removeAll()        // RC=0
     // Output: Alice freed


    Q24. What is the difference between lazy var
     and a regular stored property in ARC terms?
    -----------------------------------------------
    A: Regular property — initialized when instance is created.
                      Contributes to RC immediately.
    lazy var — initialized on first access.
              Memory allocated only when needed.
              For closures: be careful of capture cycles.
    Example:
     class DataManager {
         var source = "API"

         // lazy — created only on first access:
         lazy var fetcher: () -> String = { [unowned self] in
             return "Fetching from \(self.source)"
         }
         deinit { print("DataManager freed") }
     }
     var dm: DataManager? = DataManager()
     // fetcher NOT yet created
     print(dm!.fetcher())
     // Output: Fetching from API
     dm = nil
     // Output: DataManager freed ✓


    Q25. How does @escaping affect ARC?
    --------------------------------------
    A: @escaping means the closure can outlive the function.
    If it captures self strongly, it keeps self alive.
    This can cause leaks if self also holds the closure.
    Use [weak self] for @escaping closures that could cycle.
    Example:
     class Request {
         var url = "https://api.com"
         var completion: (() -> Void)?

         func startEscaping() {
             // @escaping stores closure — potential cycle:
             completion = { [weak self] in
                 print("Done: \(self?.url ?? "gone")")
             }
             // Simulated async call:
             DispatchQueue.main.async { [weak self] in
                 self?.completion?()
             }
         }
         deinit { print("Request freed") }
     }
     var req: Request? = Request()
     req!.startEscaping()
     req = nil
     // Output: Request freed ✓
     //         (async) Done: gone    ← self was nil by then


    Q26. How many strong references are there
     after this code and what happens?

     var a: MyClass? = MyClass()
     var b = a
     var c = b
     a = nil
     b = nil
     // How many strong refs remain?
    -----------------------------------------
    A: After a=nil, b=nil — 1 strong reference remains (c).
    Instance is NOT freed. Freed when c=nil.
    Example:
     class MyClass2 {
         init()  { print("created") }
         deinit  { print("freed") }
     }
     var a2: MyClass2? = MyClass2()  // RC=1
     // Output: created
     var b2 = a2                      // RC=2
     var c2 = b2                      // RC=3
     a2 = nil                         // RC=2
     b2 = nil                         // RC=1
     print("Still alive — c2 holds it")
     // Output: Still alive — c2 holds it
     c2 = nil                         // RC=0
     // Output: freed


    ================================================================
    SECTION 3 — ADVANCED LEVEL
    ================================================================

    Q27. How do you implement a custom
     Copy-on-Write value type?
    -----------------------------------------
    A: Wrap mutable storage in a class. Use
    isKnownUniquelyReferenced to check if a copy
    is needed before any mutation.
    Example:
     final class Buffer {
         var data: [Int]
         init(_ data: [Int]) { self.data = data }
         init(copying b: Buffer) {
             self.data = b.data
             print("Buffer COPIED")
         }
     }
     struct COWVec {
         private var buf: Buffer
         init(_ data: [Int] = []) { buf = Buffer(data) }

         private mutating func makeUnique() {
             if !isKnownUniquelyReferenced(&buf) {
                 buf = Buffer(copying: buf)
             }
         }
         mutating func append(_ v: Int) {
             makeUnique()
             buf.data.append(v)
         }
         var count: Int { buf.data.count }
         subscript(i: Int) -> Int {
             get { buf.data[i] }
             set { makeUnique(); buf.data[i] = newValue }
         }
     }
     var v1 = COWVec([1, 2, 3])
     var v2 = v1                 // shared — no copy
     print(v1.count)
     // Output: 3
     v2.append(4)                // copy triggered
     // Output: Buffer COPIED
     print(v1.count)
     // Output: 3
     print(v2.count)
     // Output: 4


    Q28. What is the ARC side table and when
     is it created?
    -----------------------------------------
    A: A side table is a separate heap allocation that
    Swift may create alongside a class instance to
    store weak reference bookkeeping data.
    Created lazily when the first weak reference to
    an object is created.
    Contains:
    - Pointer back to the object
    - Weak reference count
    When strong RC → 0: object data destroyed,
    side table stays until weak RC also → 0.
    This ensures weak refs safely become nil.
    Example:
     class HasSideTable {
         deinit { print("Object data destroyed") }
     }
     var obj2: HasSideTable? = HasSideTable()
     // No side table yet

     weak var w1: HasSideTable? = obj2
     // Side table CREATED for obj2 now

     weak var w2: HasSideTable? = obj2
     // Side table reused — weak RC incremented

     obj2 = nil
     // Strong RC = 0 → deinit → object data destroyed
     // Output: Object data destroyed
     // Side table still exists — zeroes w1, w2
     // Then side table freed (weak RC = 0)
     print(w1)   // Output: nil
     print(w2)   // Output: nil


    Q29. How does ARC interact with protocols
     and existential types?
    -----------------------------------------
    A: A protocol existential (any Protocol) uses an
    "existential container" — 3 inline words for
    small values, heap for large ones, or a reference
    for class types. ARC manages class instances
    stored in existentials just like normal refs.
    weak only works with class-constrained protocols.
    Example:
     protocol Drawable2: AnyObject {
         func draw() -> String
     }
     class Circle2: Drawable2 {
         func draw() -> String { "Circle" }
         deinit { print("Circle2 freed") }
     }
     var shape: (any Drawable2)? = Circle2()
     weak var weakShape: (any Drawable2)? = shape
     print(weakShape?.draw() ?? "nil")
     // Output: Circle
     shape = nil
     // Output: Circle2 freed
     print(weakShape?.draw() ?? "nil")
     // Output: nil


    Q30. How do actors manage memory with ARC?
    -------------------------------------------
    A: Actors are reference types — ARC tracks their
    lifetime exactly like classes. The difference is
    actors use a serial executor to protect state.
    You can still create cycles with actors if they
    hold strong references to each other.
    Use weak actor references the same way as classes.
    Example:
     actor Cache {
         private var store: [String: String] = [:]

         func set(_ key: String, value: String) {
             store[key] = value
         }
         func get(_ key: String) -> String? {
             store[key]
         }
         deinit { print("Cache freed") }
     }
     Task {
         var cache: Cache? = Cache()
         await cache!.set("name", value: "Alice")
         let val = await cache!.get("name")
         print(val ?? "nil")
         // Output: Alice
         cache = nil
         // Output: Cache freed ✓
     }


    Q31. What is the retain cycle in a Timer
     and how do you fix it?
    -----------------------------------------
    A: Timer's target: parameter creates a strong reference
    to the target (usually self). If self holds the timer,
    a cycle forms. Fix: use block-based Timer with
    [weak self] or invalidate timer in deinit.
    Example:
     import Foundation

     // PROBLEM:
     class BadTimer2 {
         var timer: Timer?
         func start() {
             timer = Timer.scheduledTimer(
                 timeInterval: 1.0,
                 target: self,          // strong ref to self
                 selector: #selector(tick2),
                 userInfo: nil,
                 repeats: true
             )
         }
         @objc func tick2() { print("tick") }
         deinit { print("BadTimer2 freed") }
     }
     // Cycle: BadTimer2 → timer → BadTimer2 (target)

     // FIXED:
     class GoodTimer2 {
         var timer: Timer?
         func start() {
             timer = Timer.scheduledTimer(
                 withTimeInterval: 1.0,
                 repeats: true
             ) { [weak self] _ in       // no strong capture
                 self?.tick2()
             }
         }
         func tick2() { print("tick") }
         deinit {
             timer?.invalidate()
             print("GoodTimer2 freed ✓")
         }
     }


    Q32. Explain the three-phase initialization
     in Swift classes and its ARC impact.
    -----------------------------------------
    A: Phase 1 — All stored properties initialized
             (subclass first, then superclass).
             No self usage until complete.
    Phase 2 — Customization allowed.
             self is now valid. Methods can be called.
    ARC starts tracking the instance after allocation
    in phase 1. deinit mirrors this in reverse.
    Example:
     class Base2 {
         var x: Int
         init(x: Int) {
             self.x = x
             print("Base2 phase1 done: x=\(x)")
             // Phase 2: customize base
             print("Base2 phase2 done")
         }
         deinit { print("Base2 deinit") }
     }
     class Derived: Base2 {
         var y: Int
         init(x: Int, y: Int) {
             self.y = y               // phase 1 — subclass first
             super.init(x: x)         // phase 1 — then super
             // phase 2 — self fully available:
             print("Derived phase2: x=\(self.x), y=\(self.y)")
         }
         deinit {
             print("Derived deinit")
             // super.deinit called automatically after
         }
     }
     var d: Derived? = Derived(x: 1, y: 2)
     // Output: Base2 phase1 done: x=1
     //         Base2 phase2 done
     //         Derived phase2: x=1, y=2
     d = nil
     // Output: Derived deinit
     //         Base2 deinit


    Q33. How do you detect a reference cycle
     in Xcode?
    -----------------------------------------
    A: Method 1 — Add deinit print statements:
               If deinit is never called → possible leak.

    Method 2 — Xcode Memory Graph Debugger:
               Run app → Debug → Memory Graph (⌃⇧I)
               Look for objects with back references
               forming cycles.

    Method 3 — Instruments → Leaks template:
               Records all allocations.
               Flags objects that were allocated
               but never deallocated.

    Method 4 — Instruments → Allocations:
               Monitor heap growth over time.
               Leak = heap grows without freeing.
    Example:
     class Leaking {
         var other: Leaking?
         init()  { print("Leaking created") }
         deinit  { print("Leaking freed — NEVER CALLED if leak") }
     }
     // In tests: verify deinit is called
     // using addTeardownBlock or XCTestCase tearDown


    Q34. How does isKnownUniquelyReferenced work
     and what are its limitations?
    -----------------------------------------
    A: Returns true only if the object has EXACTLY
    ONE strong reference. Used for COW to decide
    if a copy is needed before mutating.
    Limitations:
    - Only works with pure Swift classes (not @objc)
    - Bridged ObjC classes always return false
    - Must pass as inout (&obj)
    - May not be reliable across threads
    Example:
     final class Holder {
         var data: [Int]
         init(_ data: [Int]) { self.data = data }
     }
     var h1 = Holder([1, 2, 3])
     print(isKnownUniquelyReferenced(&h1))
     // Output: true     — only one strong ref

     var h2 = h1
     print(isKnownUniquelyReferenced(&h1))
     // Output: false    — h2 also holds a strong ref

     h2 = Holder([])                 // h2 now different obj
     print(isKnownUniquelyReferenced(&h1))
     // Output: true     — h1 unique again


    Q35. How do value and reference types behave
     differently in multithreaded code?
    -----------------------------------------
    A: Value types — each thread gets its own copy.
                No shared mutable state → thread-safe.
    Reference types — all threads share the same instance.
                    Not thread-safe without synchronization.
    Example:
     struct SafeCounter { var count = 0 }
     // Each thread gets its own SafeCounter copy — no data race

     class UnsafeCounter {
         var count = 0
         func increment() { count += 1 }  // DATA RACE possible
     }

     // Safe class counter with actor:
     actor SafeClassCounter {
         var count = 0
         func increment() { count += 1 }
         func value() -> Int { count }
     }
     Task {
         let counter = SafeClassCounter()
         await withTaskGroup(of: Void.self) { group in
             for _ in 0..<5 {
                 group.addTask {
                     await counter.increment()
                 }
             }
         }
         print("Count: \(await counter.value())")
     }
     // Output: Count: 5


    ================================================================
    SECTION 4 — EXPERT LEVEL
    ================================================================

    Q36. Explain the full ARC object layout in memory.
    ---------------------------------------------------
    A: Each class instance on the heap has this layout:

    [isa pointer 8 bytes]    — type metadata
    [ref count bits  8 bytes] — inline ref count fields

    The ref count word contains:
    - Strong RC    — bits 0–31   (how many strong refs)
    - Unowned RC   — bits 32–55  (unowned count + 1)
    - isDeiniting  — bit 56      (currently in deinit)
    - hasWeakRefs  — bit 57      (has side table)
    - isSmallInline — bit 62     (no side table)
    - isStrongExtraRef — bit 63

    When side table exists, the ref count word instead
    points to the side table, which contains full counts.
    Example:
     class MemLayout {
         var a: Int = 1
         var b: Double = 2.0
         var c: Bool = true
     }
     // Memory layout (conceptual):
     // [0-7]    isa pointer
     // [8-15]   ref count
     // [16-23]  a (Int — 8 bytes)
     // [24-31]  b (Double — 8 bytes)
     // [32]     c (Bool — 1 byte)
     // [33-39]  padding

     import Swift
     print(MemoryLayout<MemLayout>.size)
     // Output: varies — typically 25+ bytes
     // But class instances are on heap — MemoryLayout
     // gives the size of the reference (pointer) = 8


    Q37. What is the difference between
     unowned(safe) and unowned(unsafe)?
    -----------------------------------------
    A: unowned(safe) — default. Swift runtime checks
                   that the object is still alive.
                   Crashes with a clear error if not.
    unowned(unsafe) — no runtime check. No ARC tracking.
                     Fastest option but undefined
                     behavior if accessed after dealloc.
                     Use only in proven hot paths.
    Example:
     class Anchor {
         var value = 42
         deinit { print("Anchor freed") }
     }

     // unowned(safe) — clear crash with stack trace:
     class SafeRef {
         unowned(safe) var anchor: Anchor
         init(a: Anchor) { anchor = a }
         func read() -> Int { anchor.value }
     }

     // unowned(unsafe) — undefined behavior (no check):
     class UnsafeRef {
         unowned(unsafe) var anchor: Anchor
         init(a: Anchor) { anchor = a }
         func read() -> Int { anchor.value }  // UB if freed
     }

     var anch: Anchor? = Anchor()
     let safe = SafeRef(a: anch!)
     print(safe.read())
     // Output: 42
     anch = nil
     // Output: Anchor freed
     // safe.read() would crash HERE with clear error


    Q38. How does Swift's ownership proposal
     (SE-0390 ~Copyable) affect value types?
    -----------------------------------------
    A: ~Copyable (non-copyable / move-only types) allows
    structs and enums that CANNOT be copied.
    Ownership is transferred (moved), not duplicated.
    This eliminates accidental copies of expensive values
    and models unique ownership like file handles, locks.
    Example (Swift 5.9+):
     struct FileHandle: ~Copyable {
         let path: String
         init(path: String) {
             self.path = path
             print("FileHandle opened: \(path)")
         }
         consuming func close() {
             print("FileHandle closed: \(path)")
             // discard self
         }
         deinit {
             print("FileHandle deinit (auto-close): \(path)")
         }
     }

     var fh = FileHandle(path: "/tmp/data.txt")
     // Output: FileHandle opened: /tmp/data.txt

     // let fh2 = fh   // Error — ~Copyable cannot be copied

     fh.close()        // consuming — fh transferred
     // Output: FileHandle closed: /tmp/data.txt


    Q39. How does Swift ARC compare to
     Rust's ownership system?
    -----------------------------------------
    A: Swift ARC:
    - Reference counting at runtime
    - Shared ownership allowed (multiple strong refs)
    - Cycle prevention is programmer's responsibility
    - Small overhead per reference operation
    - Simpler to use — GC-like feel
    - Works with classes (heap) only

    Rust Ownership:
    - Compile-time ownership rules — zero runtime cost
    - Single owner at a time (move semantics by default)
    - Borrowing: shared (&T) or exclusive (&mut T)
    - No cycles possible (borrow checker prevents them)
    - More complex to learn and use
    - Works with all types

    Example (Swift ARC — runtime tracking):
     class SwiftBox {
         var value: Int
         init(_ v: Int) { value = v }
         deinit { print("SwiftBox freed") }
     }
     var sb1: SwiftBox? = SwiftBox(10)  // RC=1
     var sb2 = sb1                       // RC=2 — shared OK
     sb1 = nil                           // RC=1
     sb2 = nil                           // RC=0 → freed
     // Output: SwiftBox freed
     // Rust equivalent would use Rc<T> or Arc<T>
     // for shared ownership — rare in Rust code


    Q40. Describe the full lifecycle of a Swift
     class instance from allocation to deallocation
     including ARC steps.
    -----------------------------------------
    A: Complete lifecycle:

    Step 1 — Allocation:
     swift_allocObject called.
     OS allocates heap memory.
     isa pointer set to class metadata.
     Inline ref count initialized to 1.

    Step 2 — Initialization:
     init() called on the new instance.
     Properties set in phase 1.
     super.init() called.
     Phase 2 customization.

    Step 3 — Use:
     Each strong assignment → swift_retain → RC++
     Each strong release → swift_release → RC--
     Weak assignments → side table created/used.
     Unowned assignments → unowned RC++

    Step 4 — Deinitiation (RC strong hits 0):
     swift_release sees RC = 0.
     isDeiniting flag set.
     deinit() called on instance.
     super.deinit() called automatically.
     Properties released (ARC releases their refs).

    Step 5 — Deallocation:
     Unowned RC decremented.
     If unowned RC = 0 → swift_deallocObject called.
     Heap memory returned to OS.
     Side table freed if weak RC also 0.

    Example:
     class FullCycle {
         var data: String
         init(data: String) {
             self.data = data
             print("1. Init: allocated + initialized")
         }
         deinit {
             print("4. Deinit: properties released")
         }
     }

     print("Step 1-2: creating")
     var fc: FullCycle? = FullCycle(data: "payload")
     // Output: 1. Init: allocated + initialized

     print("Step 3: using — retaining via ref")
     var fc2 = fc                  // RC = 2
     fc  = nil                     // RC = 1

     print("Step 4-5: releasing last ref")
     fc2 = nil                     // RC = 0 → deinit
     // Output: 4. Deinit: properties released


    ================================================================
    PART 12 — COMPLETE QUICK REFERENCE CHEAT SHEET
    ================================================================

    VALUE TYPES
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Declare struct                     | struct Name { var prop: Type }
    Declare enum                       | enum Name { case a, b }
    Assign (copies data)               | var copy = original
    Mutating method                    | mutating func change() { }
    Immutable (let)                    | let s = MyStruct() — no property change
    No ARC overhead                    | Managed by compiler on stack
    Thread safe                        | Each copy is independent
    No deinit                          | Cannot define deinit
    No reference cycles                | Copying prevents cycles
    Nested value types                 | Deep copy on assignment
    Value type in collection           | Array/Dictionary of struct — COW applies

    REFERENCE TYPES
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Declare class                      | class Name { var prop: Type }
    Assign (shares reference)          | var ref2 = ref1  — same instance
    ARC managed                        | Retain/release auto-inserted by compiler
    Identity check                     | ref1 === ref2
    Has deinit                         | deinit { cleanup }
    Inheritance                        | class Child: Parent { }
    Can create cycles                  | Use weak/unowned to prevent
    Thread safety                      | Manual — NSLock, actor, DispatchQueue
    Class in collection                | Array holds strong refs — count increases
    final class                        | Prevents subclassing — allows optimization

    STRONG REFERENCE COUNT
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Default reference                  | var x: MyClass = instance  (strong)
    RC starts at                       | 1 on creation
    RC incremented by                  | Each new strong assignment
    RC decremented by                  | nil assignment, scope exit, overwrite
    RC reaches 0 → triggers            | deinit + memory freed
    Cycle detection                    | If deinit never called — likely cycle
    Fix cycle                          | weak or unowned on one side

    WEAK REFERENCE COUNT
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Declaration                        | weak var name: Type?
    Increases strong RC?               | No
    Becomes nil on dealloc?            | Yes — automatically by ARC
    Must be Optional?                  | Yes
    Must be var?                       | Yes
    Uses side table?                   | Yes — created on first weak ref
    Common use cases                   | Delegate, parent ref, observer list
    Safe after dealloc?                | Yes — returns nil

    UNOWNED REFERENCE COUNT
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Declaration                        | unowned var/let name: Type
    Increases strong RC?               | No
    Becomes nil on dealloc?            | No — never
    Optional?                          | No
    Crash if accessed after dealloc?   | Yes — immediate crash
    Safe variant                       | unowned(safe) — default
    Unsafe variant                     | unowned(unsafe) — no ARC check
    Common use cases                   | Closure self in lazy, co-dependent objs

    COPY-ON-WRITE
    Task                               | Code / Fact
    -----------------------------------|------------------------------------------
    Built-in COW types                 | Array, Dictionary, String, Set
    Check uniqueness                   | isKnownUniquelyReferenced(&obj)
    Custom COW                         | Wrap in class, check before mutating
    When copy occurs                   | First mutation after sharing

    ARC CYCLE SCENARIOS AND FIXES
    Scenario                           | Fix
    -----------------------------------|------------------------------------------
    Class A ←strong→ Class B           | weak or unowned on one side
    Class holds closure → self         | [weak self] or [unowned self]
    Delegate declared strong           | weak var delegate: Protocol?
    Timer target: self                 | Block-based Timer + [weak self]
    Observer not removed               | removeObserver in deinit
    Parent ↔ child bidirectional       | strong parent→child, weak child→parent
    Collection of class instances      | Use WeakRef wrapper for weak collections

    REFERENCE COUNT CHEAT SHEET
    Operation                          | Effect on RC
    -----------------------------------|------------------------------------------
    var x: Cls = Cls()                 | RC = 1
    var y = x                          | RC = 2
    var z = y                          | RC = 3
    x = nil                            | RC = 2
    y = nil                            | RC = 1
    z = nil                            | RC = 0 → deinit called
    func f(_ p: Cls)                   | RC++ inside func, RC-- on return
    weak var w: Cls? = x               | RC unchanged
    unowned var u: Cls = x             | RC unchanged
    array.append(x)                    | RC++
    array.removeAll()                  | RC-- for each element
    Closure captures self (strong)     | RC++ for duration of closure life
    Closure [weak self]                | RC unchanged
    Closure [unowned self]             | RC unchanged

 */
