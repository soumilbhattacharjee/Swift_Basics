import UIKit

/*
   OOP & Protocol-Oriented Programming
 ========================================================

 --------------------------------------------------------
 SECTION 1: INHERITANCE
 Subclassing, Overriding, final keyword
 --------------------------------------------------------

 CONCEPT OVERVIEW:
 -----------------
 - Inheritance allows a class (subclass) to acquire
   properties and methods from another class (superclass).
 - Only CLASSES support inheritance. Structs and enums do NOT.
 - Use 'override' to replace a superclass method/property.
 - Use 'super' to call the superclass implementation.
 - Use 'final' to prevent further subclassing or overriding.

 CODE EXAMPLE — Basic Subclassing:
 -----------------------------------
 class Vehicle {
     var speed: Int

     init(speed: Int) {
         self.speed = speed
     }

     func describe() -> String {
         return "Vehicle going \(speed) km/h"
     }
 }

 class Car: Vehicle {
     var brand: String

     init(brand: String, speed: Int) {
         self.brand = brand
         super.init(speed: speed)  // must call super.init
     }

     override func describe() -> String {
         return "\(brand) going \(speed) km/h"
     }
 }

 final class SportsCar: Car {
     override func describe() -> String {
         return "Sports: \(brand) at \(speed) km/h"
     }
 }

 // SportsCar cannot be subclassed — 'final' prevents it
 let car = SportsCar(brand: "Ferrari", speed: 300)
 print(car.describe())
 // Output: Sports: Ferrari at 300 km/h

 CODE EXAMPLE — final on a method:
 -----------------------------------
 class Device {
     final func serialNumber() -> String {
         return "SN-001"
     }
 }

 class Phone: Device {
     // ERROR if you try to override serialNumber()
     // override func serialNumber() -> String { ... } // COMPILE ERROR
 }

 RULES TO REMEMBER:
 ------------------
 - 'override' is required — Swift enforces it, no silent overrides.
 - 'super.init(...)' must be called before accessing 'self'
   in a subclass designated initializer.
 - 'final' on a class = no subclassing allowed.
 - 'final' on a method/property = no overriding allowed.
 - 'final' also enables direct dispatch (faster than vtable).

 --------------------------------------------------------
 INTERVIEW QUESTIONS — INHERITANCE
 --------------------------------------------------------

 BASIC:
 ------
 Q1: Can structs inherit from other structs in Swift?
 A: No. Inheritance is only supported by classes. Structs
    and enums use protocols to share behavior instead.

 Q2: What is the purpose of the 'override' keyword?
 A: It explicitly marks that a method or property is
    replacing a superclass implementation. Swift requires
    it — if you omit it, you get a compile error.

 Q3: What does 'final' do in Swift?
 A: Applied to a class, it prevents subclassing.
    Applied to a method or property, it prevents overriding.
    It also enables direct dispatch, improving performance.

 Q4: What is the difference between overriding and overloading?
 A: Overriding: replacing a superclass method in a subclass
    (same name, same signature, 'override' required).
    Overloading: defining multiple methods with the same name
    but different parameter types/labels in the same type.

 Q5: When must you call super.init()?
 A: In a designated initializer of a subclass, before
    accessing any inherited property or 'self'. Swift's
    two-phase initialization enforces this.

 INTERMEDIATE:
 -------------
 Q6: What is the difference between class and static methods
     in the context of inheritance?
 A: 'static func' cannot be overridden by subclasses.
    'class func' can be overridden. Both are type-level methods.

    class Animal {
        class func sound() -> String { return "..." }
        static func kingdom() -> String { return "Animalia" }
    }
    class Dog: Animal {
        override class func sound() -> String { return "Woof" }
        // override static func kingdom() — COMPILE ERROR
    }

 Q7: What is "two-phase initialization" in Swift?
 A: Phase 1: Every stored property is assigned an initial value
    from bottom up (subclass -> superclass).
    Phase 2: Each class can customize properties top down
    (superclass -> subclass) before the instance is ready.
    This prevents accessing uninitialized memory.

 Q8: Can you prevent only a specific method from being
     overridden while keeping the class open for subclassing?
 A: Yes. Apply 'final' to that specific method, not the class.

    class Base {
        final func locked() { }  // can't override
        func open() { }          // can override
    }

 HARD:
 -----
 Q9: What is vtable dispatch and how does 'final' affect it?
 A: In Swift, class methods use a virtual dispatch table (vtable)
    at runtime to determine which method implementation to call.
    This adds a small runtime overhead. When a method or class
    is marked 'final', the compiler uses direct dispatch instead,
    resolving the call at compile time — faster and allows inlining.

 Q10: What happens if a subclass doesn't call super.init()
      in its designated initializer?
 A: It's a compile-time error in Swift. Swift enforces that
    all stored properties are initialized. If the superclass
    has stored properties, they must be initialized via
    super.init() before the subclass uses them.

 Q11: How does Swift's class inheritance model differ from
      Objective-C in terms of dispatch?
 A: Objective-C uses message passing (objc_msgSend) for ALL
    method calls — always dynamic. Swift uses three dispatch
    types: static (final/structs), vtable (class methods),
    and dynamic (with @objc/@dynamic). Swift is faster by
    default due to static and vtable dispatch.

 Q12: What is the diamond problem and how does Swift handle it?
 A: The diamond problem occurs when two superclasses share a
    common base and a subclass inherits from both, causing
    ambiguity. Swift avoids this by NOT allowing multiple
    class inheritance. However, a type CAN conform to multiple
    protocols, and protocol extensions handle default
    implementations. If two protocols provide the same default,
    the conforming type must provide its own implementation.

 ========================================================

 --------------------------------------------------------
 SECTION 2: INITIALIZATION
 Designated, Convenience, Failable, Deinitialization
 --------------------------------------------------------

 CONCEPT OVERVIEW:
 -----------------
 - Designated init: primary init, must fully initialize all
   stored properties. Every class needs at least one.
 - Convenience init: secondary init that calls designated
   init via self.init(...). Keyword 'convenience' required.
 - Failable init (init?): returns Optional — nil on failure.
 - Required init: subclasses MUST implement it (init with
   'required' keyword).
 - deinit: called when ARC deallocates a class instance.

 CODE EXAMPLE — All Init Types:
 --------------------------------
 class BankAccount {
     var owner: String
     var balance: Double

     // Designated
     init(owner: String, balance: Double) {
         self.owner = owner
         self.balance = balance
     }

     // Convenience — calls designated
     convenience init(owner: String) {
         self.init(owner: owner, balance: 0.0)
     }

     // Failable — returns nil if invalid
     init?(owner: String, initialDeposit: Double) {
         guard initialDeposit >= 0 else { return nil }
         self.owner = owner
         self.balance = initialDeposit
     }

     deinit {
         print("Account for \(owner) deallocated")
     }
 }

 let acc1 = BankAccount(owner: "Alice", balance: 1000)
 let acc2 = BankAccount(owner: "Bob")            // balance = 0
 let acc3 = BankAccount(owner: "Eve", initialDeposit: -100) // nil
 let acc4 = BankAccount(owner: "Dan", initialDeposit: 500)  // Optional

 print(acc3 as Any)   // nil
 print(acc4?.balance ?? 0)  // 500.0

 CODE EXAMPLE — Required Init:
 -------------------------------
 class Shape {
     var color: String
     required init(color: String) {
         self.color = color
     }
 }

 class Circle: Shape {
     var radius: Double
     required init(color: String) {
         self.radius = 1.0
         super.init(color: color)
     }
 }

 CODE EXAMPLE — Struct Init (memberwise):
 -----------------------------------------
 struct Point {
     var x: Double
     var y: Double
     // Automatically gets: init(x:y:) for free
 }
 let p = Point(x: 3.0, y: 4.0)

 RULES TO REMEMBER:
 ------------------
 - Convenience inits must call self.init(...) — delegation to
   designated init is mandatory.
 - Designated inits in subclasses must call super.init(...).
 - init? returns Optional<Type>. Use guard/if to check.
 - deinit has NO parameters and NO parentheses.
 - deinit is only available on CLASS types (not structs/enums).
 - Structs get a free memberwise initializer.

 --------------------------------------------------------
 INTERVIEW QUESTIONS — INITIALIZATION
 --------------------------------------------------------

 BASIC:
 ------
 Q1: What is the difference between designated and
     convenience initializers?
 A: Designated: fully initializes all stored properties,
    calls super.init if in a subclass. Primary initializer.
    Convenience: secondary, must call self.init(...) to
    delegate to a designated init. Marked with 'convenience'.

 Q2: What is a failable initializer?
 A: An initializer marked with 'init?' that can return nil
    if the input is invalid. Returns an Optional type.

 Q3: What is 'deinit' and when is it called?
 A: deinit is a deinitializer — it runs just before a class
    instance is freed by ARC (when the last strong reference
    is released). Used for cleanup (closing files, removing
    observers, etc.). Only classes have deinit.

 Q4: Can structs have a deinit?
 A: No. deinit is only for class types. Structs are value
    types and don't use ARC.

 Q5: What is 'required init'?
 A: A required init must be implemented by all subclasses.
    If a subclass has a designated init, it must also
    include the required init (marked with 'required', not
    'override').

 INTERMEDIATE:
 -------------
 Q6: Can a convenience initializer call another convenience
     initializer?
 A: Yes — as long as the chain eventually reaches a
    designated initializer. Direct delegation chain:
    convenience -> convenience -> ... -> designated init.

 Q7: What is init inheritance in Swift?
 A: Subclasses do NOT automatically inherit superclass inits
    by default. However, if a subclass provides NO designated
    inits, it inherits all superclass designated inits.
    If it implements all superclass designated inits, it
    also inherits all superclass convenience inits.

 Q8: How do you handle initialization failure in init??
 A: Use 'guard' or 'if' to validate input. Return nil early
    if validation fails. The caller receives Optional and
    must unwrap or use optional binding.

 Q9: What is the difference between init? and init!?
 A: init? returns an Optional (safe). The caller must
    handle nil explicitly.
    init! returns an implicitly unwrapped Optional. It
    will crash at runtime if nil is accessed. Use rarely.

 HARD:
 -----
 Q10: Explain Swift's two-phase initialization in depth.
 A: Phase 1 (bottom-up):
    - Subclass designated init assigns all OWN stored props.
    - It calls super.init(...).
    - Superclass does the same up the chain.
    - At end of Phase 1, all stored properties have values.
    Phase 2 (top-down):
    - Each class in the chain gets a chance to customize
      properties further before the object is available.
    - After Phase 2, self is fully usable.
    This prevents accessing uninitialized memory.

 Q11: Why can't you access 'self' before calling super.init()?
 A: Until super.init() completes Phase 1, inherited stored
    properties are uninitialized. Accessing self would mean
    using potentially garbage memory. Swift enforces the
    call to super.init() first as a compile-time safety rule.

 Q12: Can you have a failable designated init and a non-failable
      convenience init?
 A: No. A non-failable initializer cannot delegate to a
    failable one (init?) because the non-failable guarantees
    a valid instance. You CAN delegate from init? to a
    non-failable init.

 Q13: What happens to deinit if you use 'unowned' references
      in a closure inside the class?
 A: Using 'unowned self' in a closure prevents a retain cycle
    but does NOT prevent deinit from being called — in fact,
    it ensures deinit is called normally when the instance
    has no more strong references. If you used 'strong self'
    inside a stored closure property, it would form a retain
    cycle and deinit would never be called.

 ========================================================

 --------------------------------------------------------
 SECTION 3: PROTOCOLS
 Definition, Extensions, @objc Optional, Inheritance
 --------------------------------------------------------

 CONCEPT OVERVIEW:
 -----------------
 - A protocol defines a blueprint of methods, properties,
   and requirements that conforming types must implement.
 - ANY type can conform: class, struct, enum, even extensions.
 - Protocol extensions provide default implementations.
 - Protocol-Oriented Programming (POP) is Swift's preferred
   design paradigm over OOP inheritance.

 CODE EXAMPLE — Protocol Definition & Conformance:
 ---------------------------------------------------
 protocol Flyable {
     var maxAltitude: Double { get }
     func fly()
 }

 struct Airplane: Flyable {
     var maxAltitude: Double = 40000
     func fly() { print("Airplane flying at \(maxAltitude) ft") }
 }

 struct Bird: Flyable {
     var maxAltitude: Double = 1000
     func fly() { print("Bird flying at \(maxAltitude) ft") }
 }

 let flyingThings: [Flyable] = [Airplane(), Bird()]
 flyingThings.forEach { $0.fly() }

 CODE EXAMPLE — Protocol Extension (Default Implementation):
 ------------------------------------------------------------
 protocol Greetable {
     var name: String { get }
     func greet() -> String
 }

 extension Greetable {
     func greet() -> String {
         return "Hello, I'm \(name)!"
     }
 }

 struct User: Greetable {
     var name: String
     // greet() not implemented — uses default from extension
 }

 struct Robot: Greetable {
     var name: String
     func greet() -> String {
         return "BEEP. Designation: \(name)."
     }
 }

 print(User(name: "Alice").greet())  // Hello, I'm Alice!
 print(Robot(name: "R2D2").greet())  // BEEP. Designation: R2D2.

 CODE EXAMPLE — @objc Optional Protocol Methods:
 ------------------------------------------------
 import Foundation

 @objc protocol UIDelegate {
     func didTapButton()
     @objc optional func didSwipe()
     @objc optional func didPinch()
 }

 class MyViewController: NSObject, UIDelegate {
     func didTapButton() { print("Button tapped") }
     // didSwipe and didPinch are optional — no compile error
 }

 // Calling optional method safely:
 let delegate: UIDelegate = MyViewController()
 delegate.didTapButton()
 delegate.didSwipe?()  // nil-checked call, safe

 CODE EXAMPLE — Protocol Inheritance:
 --------------------------------------
 protocol Animal {
     var name: String { get }
 }

 protocol Pet: Animal {
     var owner: String { get }
 }

 protocol ServiceAnimal: Pet {
     var certification: String { get }
 }

 struct GuideDog: ServiceAnimal {
     var name: String
     var owner: String
     var certification: String
 }

 let dog = GuideDog(name: "Max", owner: "John", certification: "ADA-2024")

 RULES TO REMEMBER:
 ------------------
 - Protocols define REQUIREMENTS — they don't store values.
 - Protocol extensions ADD behavior — the POP way.
 - Multiple protocol conformance is allowed.
 - @objc optional methods require NSObject / Obj-C compatibility.
   Prefer protocol extension defaults in pure Swift.
 - 'Self' in a protocol refers to the conforming type.
 - Protocols can have initializer requirements (init()).
 - 'AnyObject' constrains a protocol to class types only.

 --------------------------------------------------------
 INTERVIEW QUESTIONS — PROTOCOLS
 --------------------------------------------------------

 BASIC:
 ------
 Q1: What is a protocol in Swift?
 A: A protocol defines a contract — a set of methods,
    properties, and other requirements that conforming
    types must implement. Classes, structs, and enums
    can all conform to protocols.

 Q2: What is a protocol extension?
 A: An extension on a protocol that provides default
    implementations for its requirements. Conforming
    types can use the default or override it.

 Q3: What is the difference between a delegate pattern
     and a protocol in Swift?
 A: A protocol IS the mechanism. The delegate pattern
    is a design pattern that USES protocols: one type
    declares a delegate property typed as a protocol,
    and another type conforms to that protocol to
    receive callbacks.

 Q4: Why use '@objc optional' for protocol methods?
 A: To allow methods to be optionally implemented.
    Only possible with Objective-C compatible protocols
    (class types, @objc attribute). In pure Swift,
    use protocol extensions with default implementations
    as a safer alternative.

 Q5: What does 'AnyObject' constraint mean on a protocol?
 A: It restricts the protocol to class types only.
    Example: protocol MyProtocol: AnyObject { }
    Used for weak delegate references (structs can't
    be weak, so the protocol must be AnyObject).

 INTERMEDIATE:
 -------------
 Q6: Can a protocol conform to another protocol?
 A: Yes. Protocol inheritance works like class inheritance.
    A conforming type must satisfy requirements of the
    protocol AND all protocols it inherits.

 Q7: What is the difference between protocol conformance
     in the type declaration vs. in an extension?
 A: Both work for conformance. Extension-based conformance
    is preferred for organization — keeps each protocol's
    implementation grouped. Declared conformance in the
    type definition is also valid but can get cluttered.

 Q8: What is a protocol with 'Self' requirement?
 A: Using 'Self' inside a protocol means the conforming
    type itself. Common in Equatable:
    protocol Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool
    }
    This makes the protocol "non-existential" — you can't
    use it as a type directly (must use 'any Equatable').

 Q9: Can you add stored properties in a protocol extension?
 A: No. Protocol extensions can only add computed properties
    and method implementations — not stored properties.
    Stored properties must be in the conforming type.

 Q10: What is a 'marker protocol'?
 A: A protocol with no requirements — used only to mark
    that a type has some capability.
    Example: Sendable, Codable-like markers.
    protocol Cacheable { }  // no methods needed

 HARD:
 -----
 Q11: What is a protocol witness table (PWT)?
 A: When a type conforms to a protocol, Swift generates a
    Protocol Witness Table — a data structure mapping each
    protocol requirement to the conforming type's actual
    implementation. At runtime, when you call a protocol
    method via an existential (any MyProtocol), Swift
    uses the PWT to find the right implementation.
    This is why existentials have a slight performance cost.

 Q12: What is the 'Existential Container' in Swift?
 A: When you use a protocol as a type (any MyProtocol),
    Swift wraps the value in an existential container:
    - 3 words for inline value storage (or a pointer
      to heap-allocated value if too large)
    - 1 word for a pointer to the value witness table
      (how to copy/destroy the value)
    - 1 word for a pointer to the protocol witness table
    This 5-word container adds overhead vs. generic types.

 Q13: What is the difference between using a generic
      type constraint vs. an existential?
 A: Generic: func process<T: Drawable>(_ item: T)
    - Type resolved at compile time (static dispatch)
    - Compiler can specialize the function per type
    - More performant
    Existential: func process(_ item: any Drawable)
    - Type resolved at runtime (dynamic dispatch)
    - Uses existential container
    - More flexible (heterogeneous collections)
    Rule of thumb: use generics for performance,
    existentials for flexibility.

 Q14: How do you resolve a conflict when two protocol
      extensions provide the same default method?
 A: The conforming type MUST provide its own implementation.
    Swift cannot choose between two equal-priority defaults.
    The compiler will give an error asking you to resolve it.

 Q15: What is 'conditional conformance' in Swift?
 A: A type conforms to a protocol only under certain conditions.
    Example:
    extension Array: Equatable where Element: Equatable { }
    Array<Int> is Equatable, but Array<UIView> is not,
    because UIView doesn't conform to Equatable.

 Q16: What are primary associated types (Swift 5.7+)?
 A: Primary associated types allow you to constrain protocols
    like generics:
    protocol Collection<Element> { ... }
    func process(_ c: some Collection<Int>) { ... }
    This replaces verbose 'where' clauses in many cases.

 ========================================================

 --------------------------------------------------------
 SECTION 4: GENERICS
 Functions, Types, Constraints, associatedtype, some, any
 --------------------------------------------------------

 CONCEPT OVERVIEW:
 -----------------
 - Generics let you write flexible, reusable code that works
   with any type, subject to constraints you define.
 - Generic code avoids duplication while staying type-safe.
 - 'T' is just a convention — any name works (Element, Key, Value).

 CODE EXAMPLE — Generic Function:
 ----------------------------------
 func swapValues<T>(_ a: inout T, _ b: inout T) {
     let temp = a; a = b; b = temp
 }

 var x = 10, y = 20
 swapValues(&x, &y)
 print(x, y)  // 20 10

 var s1 = "Hello", s2 = "World"
 swapValues(&s1, &s2)
 print(s1, s2)  // World Hello

 CODE EXAMPLE — Generic Type:
 ------------------------------
 struct Stack<Element> {
     private var items: [Element] = []

     mutating func push(_ item: Element) {
         items.append(item)
     }

     mutating func pop() -> Element? {
         return items.popLast()
     }

     var top: Element? { return items.last }
     var isEmpty: Bool { return items.isEmpty }
     var count: Int { return items.count }
 }

 var intStack = Stack<Int>()
 intStack.push(1)
 intStack.push(2)
 intStack.push(3)
 print(intStack.pop()!)  // 3
 print(intStack.top!)    // 2

 CODE EXAMPLE — Type Constraints:
 ----------------------------------
 // T must conform to Comparable
 func findMax<T: Comparable>(_ array: [T]) -> T? {
     return array.max()
 }

 print(findMax([3, 1, 4, 1, 5, 9])!)         // 9
 print(findMax(["banana", "apple", "cherry"])!)  // cherry

 // Multiple constraints with 'where'
 func process<T>(_ items: [T]) where T: Comparable, T: Hashable {
     let unique = Set(items).sorted()
     print(unique)
 }
 process([3, 1, 4, 1, 5, 9, 2, 6, 5])
 // [1, 2, 3, 4, 5, 6, 9]

 CODE EXAMPLE — associatedtype:
 --------------------------------
 protocol Container {
     associatedtype Item
     var count: Int { get }
     mutating func add(_ item: Item)
     func get(at index: Int) -> Item
 }

 struct Box<T>: Container {
     typealias Item = T  // Swift often infers this
     private var storage: [T] = []

     var count: Int { storage.count }

     mutating func add(_ item: T) {
         storage.append(item)
     }

     func get(at index: Int) -> T {
         return storage[index]
     }
 }

 var box = Box<String>()
 box.add("Swift")
 box.add("Generics")
 print(box.get(at: 0))  // Swift

 CODE EXAMPLE — some (Opaque Return Type):
 -------------------------------------------
 protocol Shape {
     func area() -> Double
 }

 struct Circle: Shape {
     var radius: Double
     func area() -> Double { return Double.pi * radius * radius }
 }

 // 'some Shape' — returns ONE specific type, hidden from caller
 // Caller gets a Shape but compiler knows exact type
 func makeCircle() -> some Shape {
     return Circle(radius: 5)
 }

 let shape = makeCircle()
 print(shape.area())  // 78.53...

 CODE EXAMPLE — any (Existential Type):
 ----------------------------------------
 // 'any Shape' — can hold ANY conforming type at runtime
 func printAreas(shapes: [any Shape]) {
     shapes.forEach { print($0.area()) }
 }

 struct Square: Shape {
     var side: Double
     func area() -> Double { return side * side }
 }

 printAreas(shapes: [Circle(radius: 3), Square(side: 4)])
 // 28.27...
 // 16.0

 some vs any — COMPARISON TABLE:
 ---------------------------------
 Feature             | some (Opaque)      | any (Existential)
 --------------------|--------------------|-------------------
 Type known at       | Compile time       | Runtime
 Dispatch type       | Static (fast)      | Dynamic (overhead)
 Can hold multiple   | No (one type)      | Yes
 Use in collections  | No                 | Yes
 Use as return type  | Yes                | Yes (Swift 5.7+)
 SwiftUI body        | Yes (default)      | Rarely
 Performance         | Better             | Slight overhead

 RULES TO REMEMBER:
 ------------------
 - Generic functions are resolved per-call at compile time.
 - 'where' clauses add multiple constraints cleanly.
 - 'associatedtype' = protocol's version of generics.
 - 'some' enforces one concrete type (compiler knows it).
 - 'any' allows heterogeneous values (runtime flexibility).
 - You CANNOT use protocols with Self/associatedtype
   directly as types — use 'some' or 'any' (Swift 5.7+).

 --------------------------------------------------------
 INTERVIEW QUESTIONS — GENERICS
 --------------------------------------------------------

 BASIC:
 ------
 Q1: What are generics in Swift?
 A: Generics allow you to write flexible, reusable functions
    and types that work with any type, while maintaining
    type safety. The concrete type is resolved at compile time.

 Q2: What is a type constraint in generics?
 A: A restriction on a generic type parameter requiring it
    to conform to a protocol or inherit from a class.
    Example: func sort<T: Comparable>(_ items: [T]) -> [T]

 Q3: What is 'associatedtype' in a protocol?
 A: A placeholder type used inside a protocol, like a
    generic parameter but scoped to the protocol.
    The conforming type specifies the concrete type.

 Q4: What is the difference between 'some' and 'any'?
 A: 'some' = opaque type: the compiler knows the exact
    concrete type, just hides it from the caller.
    Static dispatch, faster, used in return positions.
    'any' = existential type: the concrete type is erased
    at compile time, resolved at runtime. More flexible,
    slight performance overhead.

 INTERMEDIATE:
 -------------
 Q5: When would you use generics over 'Any' type?
 A: Always prefer generics over 'Any'.
    'Any' loses type information — you have to cast at
    runtime (as?, as!) which can crash.
    Generics are type-safe and performant — the compiler
    enforces types at compile time with no runtime cost.

 Q6: What is a 'where' clause in generics?
 A: It adds constraints to generic parameters:
    func equal<T>(_ a: T, _ b: T) -> Bool
        where T: Equatable, T: Hashable { ... }
    Also used in extensions:
    extension Array where Element: Numeric {
        var sum: Element { reduce(0, +) }
    }

 Q7: Can you have a generic protocol? How?
 A: Protocols use 'associatedtype' instead of <T>:
    protocol Storage {
        associatedtype Item
        func save(_ item: Item)
    }
    You can't write 'protocol Storage<T>' in Swift.

 Q8: What is type erasure and when is it needed?
 A: When a protocol has associatedtype, you can't use
    it directly as a concrete type. Type erasure wraps
    it in a concrete type that hides the associated type.
    Classic example: AnyPublisher in Combine, AnyView in
    SwiftUI. You create a wrapper like 'AnyContainer<T>'
    that stores the protocol conformer in a closure or
    base class, hiding the associated type.

 HARD:
 -----
 Q9: What is 'specialization' in generics and how does
     Swift use it?
 A: When you call a generic function with a specific type,
    the Swift compiler can generate a specialized version
    of that function optimized for that exact type.
    This is called 'whole module optimization' and means
    generics in Swift can be as fast as non-generic code
    when the optimizer has enough information.

 Q10: Explain the difference between opaque types ('some')
      and generic return types in function signatures.
 A: Generic parameter T is caller-driven:
      func make<T: Shape>() -> T { ... }
      The CALLER chooses T. The function must return T.
    Opaque 'some' is implementation-driven:
      func make() -> some Shape { return Circle(radius:1) }
      The IMPLEMENTATION chooses the type. The caller only
      knows it's some Shape. Enables better optimization.

 Q11: Why can't you use a protocol with associatedtype
      as a plain existential before Swift 5.7?
 A: Because the compiler couldn't guarantee type safety —
    different conformers have different associated types,
    so you couldn't form a homogeneous existential.
    Swift 5.7 introduced 'any Protocol' syntax to allow
    it explicitly (with boxing/existential container),
    acknowledging the runtime overhead.

 Q12: What is a 'generic where clause' on an extension?
 A: It constrains when the extension applies:
    extension Stack where Element: Equatable {
        func contains(_ item: Element) -> Bool {
            return items.contains(item)
        }
    }
    'contains' only exists on Stack<Int>, Stack<String>,
    etc. — not Stack<UIView> (which isn't Equatable).

 Q13: What are 'variadic generics' (Swift 5.9+)?
 A: Also called parameter packs. They allow a generic
    function to accept a variable number of type parameters.
    func zip<each T>(_ values: repeat each T) -> (repeat each T)
    Used heavily in Swift macros and tuple operations.
    Eliminates the need for separate overloads for different
    tuple arities.

 ========================================================

 --------------------------------------------------------
 SECTION 5: EXTENSIONS
 Adding Functionality, Protocol Conformance
 --------------------------------------------------------

 CONCEPT OVERVIEW:
 -----------------
 - Extensions add new functionality to an EXISTING type —
   class, struct, enum, or protocol — without subclassing.
 - You CAN'T override existing functionality in extensions.
 - You CANNOT add stored properties in extensions.
 - You CAN add: computed properties, methods, initializers,
   subscripts, nested types, and protocol conformances.

 CODE EXAMPLE — Extending Built-In Types:
 -----------------------------------------
 extension String {
     var isPalindrome: Bool {
         let cleaned = lowercased().filter { $0.isLetter }
         return cleaned == String(cleaned.reversed())
     }

     func truncated(to length: Int, trail: String = "...") -> String {
         guard count > length else { return self }
         return String(prefix(length)) + trail
     }

     var wordCount: Int {
         components(separatedBy: .whitespaces)
             .filter { !$0.isEmpty }.count
     }
 }

 print("racecar".isPalindrome)  // true
 print("hello".isPalindrome)    // false
 print("Hello, Swift World!".truncated(to: 10))  // Hello, Swi...
 print("Swift is awesome".wordCount)  // 3

 CODE EXAMPLE — Extending with Constraints:
 --------------------------------------------
 extension Array where Element: Numeric {
     var sum: Element { reduce(0, +) }
     var product: Element { reduce(1, *) }
 }

 print([1, 2, 3, 4, 5].sum)      // 15
 print([1, 2, 3, 4, 5].product)  // 120

 extension Collection where Element: Comparable {
     func isSorted() -> Bool {
         zip(self, dropFirst()).allSatisfy { $0 <= $1 }
     }
 }

 print([1, 2, 3, 4].isSorted())  // true
 print([1, 3, 2, 4].isSorted())  // false

 CODE EXAMPLE — Protocol Conformance via Extension:
 ---------------------------------------------------
 struct Point {
     var x: Double
     var y: Double
 }

 // Retroactive conformance — adding conformance you don't own
 extension Point: CustomStringConvertible {
     var description: String { "Point(\(x), \(y))" }
 }

 extension Point: Equatable {
     static func == (lhs: Point, rhs: Point) -> Bool {
         return lhs.x == rhs.x && lhs.y == rhs.y
     }
 }

 extension Point: Comparable {
     static func < (lhs: Point, rhs: Point) -> Bool {
         return lhs.x < rhs.x
     }
 }

 let p1 = Point(x: 1, y: 2)
 let p2 = Point(x: 1, y: 2)
 let p3 = Point(x: 3, y: 4)

 print(p1)           // Point(1.0, 2.0)
 print(p1 == p2)     // true
 print(p1 < p3)      // true

 let points = [p3, p1, p2]
 print(points.sorted())  // [Point(1.0, 2.0), Point(1.0, 2.0), Point(3.0, 4.0)]

 CODE EXAMPLE — Adding Convenience Init via Extension:
 ------------------------------------------------------
 extension CGPoint {
     init(value: Double) {
         self.init(x: value, y: value)  // call existing init
     }
 }

 // Note: For classes, you can only add CONVENIENCE inits
 // in extensions, not designated inits.
 // For structs, you can add any init in an extension.

 RULES TO REMEMBER:
 ------------------
 - Extensions can't add stored properties.
 - Extensions can't override existing methods.
 - Use one extension per protocol conformance (organization).
 - Extensions apply to ALL instances of the type globally.
 - 'retroactive modeling' = conforming types you don't own
   (e.g., extending String to conform to your protocol).
 - Conditional extensions ('where') are powerful for
   adding targeted functionality.

 --------------------------------------------------------
 INTERVIEW QUESTIONS — EXTENSIONS
 --------------------------------------------------------

 BASIC:
 ------
 Q1: What can you add with an extension in Swift?
 A: Computed properties, instance and type methods,
    new initializers (convenience for classes, any for
    structs), subscripts, nested types, and protocol
    conformances. You cannot add stored properties.

 Q2: Can you override a method in an extension?
 A: No. Extensions cannot override existing functionality.
    Override requires subclassing (class inheritance).

 Q3: What is retroactive conformance?
 A: Adding protocol conformance to a type defined in
    another module (e.g., extending String or Int to
    conform to your own protocol).

 Q4: Why add protocol conformance in an extension rather
     than in the type definition?
 A: Organization and readability. Keeps each protocol's
    implementation in its own block. Standard practice
    in Swift style guides.

 INTERMEDIATE:
 -------------
 Q5: Can you add a designated initializer to a class
     in an extension?
 A: No. Extensions can only add CONVENIENCE initializers
    to classes. Designated initializers must be in the
    class definition. For structs, any init can go in
    an extension.

 Q6: What is a conditional extension?
 A: An extension that applies only when a type parameter
    meets a condition:
    extension Array where Element: Equatable {
        func removeDuplicates() -> [Element] {
            var seen: [Element] = []
            return filter { seen.contains($0)
                ? false : { seen.append($0); return true }() }
        }
    }

 Q7: Can two extensions on the same type define the same
     method name?
 A: If the signatures differ (overloading), yes.
    If the signatures are identical, it's a compile error.
    If one is in a conditional extension with a more
    specific constraint, it takes precedence.

 Q8: Can you add a 'static' or 'class' method in an extension?
 A: Yes. Both 'static func' and 'class func' can be added
    in extensions.

 HARD:
 -----
 Q9: What is the 'retroactive conformance' warning in
     Swift 5.7+ and how do you resolve it?
 A: If you conform a type from Module A to a protocol
    from Module B in Module C (a third module), Swift 5.7+
    warns it may cause conflicts if both A and B add the
    same conformance. Resolve with '@retroactive':
    extension ExternalType: @retroactive ExternalProtocol { }
    This marks the conformance as intentionally retroactive.

 Q10: How do protocol extensions differ from class
      inheritance for sharing behavior?
 A: Protocol extensions work on structs, enums, and classes.
    Class inheritance is class-only. Protocol extensions
    provide horizontal behavior sharing (multiple protocols),
    while inheritance is vertical (single superclass chain).
    Protocol extensions = composition over inheritance.

 Q11: What is the 'Static Dispatch' vs 'Dynamic Dispatch'
      difference in extensions?
 A: Methods added in a protocol extension (NOT declared
    in the protocol itself) use STATIC dispatch — they
    are resolved at compile time based on the variable's
    declared type, not the actual runtime type.
    Methods declared in the protocol AND implemented in
    an extension use DYNAMIC dispatch via PWT.
    This is a subtle but critical performance/behavior
    difference — can cause surprising results:

    protocol Greetable {
        func greet()  // declared in protocol
    }
    extension Greetable {
        func greet() { print("Hello from extension") }
        func farewell() { print("Bye from extension") } // NOT declared in protocol
    }
    struct User: Greetable {
        func greet() { print("Hello from User") }
        func farewell() { print("Bye from User") }
    }

    let u: Greetable = User()
    u.greet()    // "Hello from User" — dynamic, PWT used
    u.farewell() // "Bye from extension" — STATIC, type is Greetable
                 // The User's farewell is IGNORED!

    This is one of the hardest Swift gotchas.

 Q12: Can you make an extension on a generic type with
      additional conformance?
 A: Yes. Extension on generic type with where clause:
    extension Stack: Equatable where Element: Equatable {
        static func == (lhs: Stack<Element>, rhs: Stack<Element>) -> Bool {
            return lhs.items == rhs.items
        }
    }

 ========================================================

 --------------------------------------------------------
 MASTER INTERVIEW Q&A — COMBINED HARD QUESTIONS
 --------------------------------------------------------

 Q1: What is the difference between OOP and POP in Swift?
 A: OOP: shares behavior via class inheritance (vertical,
    single superclass chain, reference types).
    POP: shares behavior via protocol conformance and
    protocol extensions (horizontal, multiple protocols,
    works with value types). Swift prefers POP because
    it works with structs/enums, avoids fragile base class
    problem, and encourages composition over inheritance.

 Q2: How would you decide between using a class vs a struct
     in a Swift application?
 A: Use struct when:
    - Data should be copied (value semantics)
    - No need for inheritance
    - Thread safety by default (value types are safer)
    - Lightweight models (User, Point, Order)
    Use class when:
    - Need identity (reference semantics)
    - Need inheritance
    - Need deinit (resource cleanup)
    - Shared mutable state is intentional
    Apple's guideline: default to struct, use class when needed.

 Q3: Explain the fragile base class problem. Does Swift solve it?
 A: When a superclass changes (adding/removing methods), it
    can break subclasses in unexpected ways — even if the
    subclass didn't use those methods. It's fragile because
    subclasses are tightly coupled to superclass internals.
    Swift partially addresses it by:
    - Requiring 'override' (no accidental overrides)
    - Using 'final' to lock down classes/methods
    - Encouraging POP (protocols don't have this problem)
    - 'open' vs 'public' distinction in modules

 Q4: How do generics, protocols, and extensions work
     together in Swift?
 A: They form Swift's POP architecture:
    - Protocols define requirements (the contract)
    - Generic functions/types work with any conforming type
    - Extensions provide default implementations
    Example: Equatable (protocol) + generic func
    contains<T: Equatable>(...) + extension Array where
    Element: Equatable = powerful, reusable, type-safe code.

 Q5: What is the 'some' keyword in SwiftUI's 'body' property?
 A: 'var body: some View' uses an opaque return type.
    The exact View type returned is hidden from the caller
    (SwiftUI framework) but known to the compiler. This
    enables the compiler to optimize the view hierarchy
    without requiring complex generic type signatures that
    would be unreadable. Without 'some', you'd need to
    write the full nested generic type like
    'VStack<TupleView<(Text, Button<Text>)>>' etc.

 Q6: How does method dispatch work in Swift broadly?
 A: Three types:
    1. Static dispatch: structs, final class methods,
       non-overriding class methods. Fastest — resolved
       at compile time, can be inlined.
    2. Table dispatch (vtable): class methods. A virtual
       table of function pointers is consulted at runtime.
    3. Message dispatch: @objc/@dynamic methods.
       Uses Objective-C runtime (objc_msgSend). Slowest
       but allows runtime manipulation (swizzling, KVO).

 Q7: What are the SOLID principles and how does Swift
     support them?
 A: S - Single Responsibility: One type = one job.
      Structs/classes focused on one concern.
    O - Open/Closed: Open for extension, closed for modification.
      Protocol extensions extend without changing originals.
    L - Liskov Substitution: Subtypes replace supertypes.
      Protocol conformance ensures this.
    I - Interface Segregation: Small, focused protocols.
      Swift protocols are naturally lean.
    D - Dependency Inversion: Depend on protocols, not concretes.
      Protocol types as parameters/properties.

 ========================================================

 SUMMARY CHEAT SHEET
 ===================

 INHERITANCE:
 - 'override' = required to override
 - 'final' = prevents override/subclass
 - 'super.init()' = must call in subclass designated init
 - 'static func' can't be overridden, 'class func' can

 INITIALIZATION:
 - Designated = fully inits all properties
 - Convenience = delegates to designated via self.init()
 - Failable = init?(), returns nil on failure
 - Required = must be in all subclasses
 - deinit = class only, no params, called by ARC

 PROTOCOLS:
 - Blueprint for methods/properties
 - Extensions = default implementations (POP core)
 - @objc optional = Obj-C only, prefer extensions in Swift
 - Protocol inheritance = stack requirements
 - AnyObject = class-only protocol
 - PWT = Protocol Witness Table (runtime dispatch)

 GENERICS:
 - <T> = placeholder type
 - T: Protocol = type constraint
 - where = multiple constraints
 - associatedtype = protocol's generic placeholder
 - some = opaque, compile-time, static dispatch (fast)
 - any = existential, runtime, dynamic dispatch (flexible)

 EXTENSIONS:
 - Add: computed props, methods, inits, subscripts, conformance
 - Cannot: add stored props, override methods
 - Conditional: 'where Element: Protocol'
 - Static vs dynamic dispatch in protocol extensions = GOTCHA
 - One extension per protocol = best practice

 ========================================================
 
 // ============================================================
 // SWIFT NOTES: OOP & PROTOCOL-ORIENTED PROGRAMMING
 // ============================================================


 // ============================================================
 // 1. INHERITANCE
 // ============================================================

 // --- SUBCLASSING ---
 // A class can inherit properties and methods from another class.
 // Swift supports single inheritance only (one superclass).

 class Animal {
     var name: String
     var sound: String

     init(name: String, sound: String) {
         self.name = name
         self.sound = sound
     }

     func makeSound() {
         print("\(name) says \(sound)")
     }
 }

 class Dog: Animal {
     var breed: String

     init(name: String, breed: String) {
         self.breed = breed
         super.init(name: name, sound: "Woof")
     }
 }

 let dog = Dog(name: "Rex", breed: "Labrador")
 dog.makeSound() // Rex says Woof


 // --- OVERRIDING ---
 // Use `override` keyword to provide a new implementation of
 // an inherited method, property, or subscript.

 class Cat: Animal {
     init(name: String) {
         super.init(name: name, sound: "Meow")
     }

     override func makeSound() {
         print("\(name) softly says \(sound)...")
     }
 }

 let cat = Cat(name: "Whiskers")
 cat.makeSound() // Whiskers softly says Meow...

 // Calling super inside override
 class PoliceDog: Dog {
     override func makeSound() {
         super.makeSound()      // calls Dog -> Animal's makeSound
         print("(Police Dog barks loudly!)")
     }
 }


 // --- FINAL KEYWORD ---
 // `final` prevents a class, method, or property from being subclassed
 // or overridden. Compiler optimizes final classes (static dispatch).

 final class Singleton {
     static let shared = Singleton()
     private init() {}
 }

 // final on a method inside a non-final class
 class Vehicle {
     func start() { print("Vehicle starting") }
     final func stop() { print("Vehicle stopping") }  // cannot override
 }

 class Car: Vehicle {
     override func start() { print("Car starting") }
     // override func stop() {}  // ERROR: Cannot override a final member
 }


 // ============================================================
 // INHERITANCE — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What is the difference between `override` and `overload` in Swift?
 A: `override` replaces an inherited method from a superclass.
    `overload` defines multiple methods with the same name but
    different parameter types/counts.

 Q2 (Basic): Can structs inherit from other structs in Swift?
 A: No. Inheritance is only supported by classes.
    Structs and enums use protocols for shared behavior.

 Q3 (Medium): What does `super.init()` do and when must you call it?
 A: It calls the superclass initializer. In a designated initializer,
    you must call super.init() after setting all stored properties
    of the current class but before using any inherited properties.

 Q4 (Medium): What is the difference between `final class` and
    marking individual methods as `final`?
 A: `final class` prevents any subclassing of that class entirely.
    `final` on a method prevents only that method from being
    overridden while still allowing the class to be subclassed.

 Q5 (Hard): How does `final` affect Swift's dispatch mechanism
    and why does it matter for performance?
 A: By default, class methods use dynamic dispatch (vtable lookup
    at runtime), which has a small overhead. Marking a method or
    class `final` enables static dispatch — the compiler resolves
    the call at compile time, similar to struct methods. This can
    result in inlining and significant performance gains in
    tight loops or frequently called code paths. Swift's optimizer
    can also devirtualize calls it detects won't be overridden,
    but `final` makes this guarantee explicit.

 Q6 (Hard): Can you override a property stored in a superclass
    as a computed property in a subclass?
 A: Yes. A subclass can override a stored property with a computed
    property, but you cannot remove a setter that was provided.
    You can ADD a setter/observer but not REMOVE one.

    class Base {
        var value: Int = 0
    }
    class Sub: Base {
        override var value: Int {
            get { return super.value * 2 }
            set { super.value = newValue }
        }
    }
 */


 // ============================================================
 // 2. INITIALIZATION
 // ============================================================

 // --- DESIGNATED INITIALIZER ---
 // Primary initializer. Must fully initialize all stored properties.
 // Every class must have at least one designated initializer.

 class Person {
     var name: String
     var age: Int

     // Designated
     init(name: String, age: Int) {
         self.name = name
         self.age = age
     }
 }


 // --- CONVENIENCE INITIALIZER ---
 // Secondary initializer. Must call a designated initializer
 // from the same class (horizontal delegation).

 class Employee: Person {
     var department: String

     // Designated
     init(name: String, age: Int, department: String) {
         self.department = department
         super.init(name: name, age: age)
     }

     // Convenience — delegates to designated
     convenience init(name: String) {
         self.init(name: name, age: 0, department: "Unassigned")
     }
 }

 let emp1 = Employee(name: "Alice", age: 30, department: "Engineering")
 let emp2 = Employee(name: "Bob")   // uses convenience init


 // --- FAILABLE INITIALIZER ---
 // Returns nil if initialization fails. Declared with `init?`.

 class Temperature {
     var celsius: Double

     init?(celsius: Double) {
         guard celsius >= -273.15 else { return nil }  // below absolute zero
         self.celsius = celsius
     }
 }

 if let temp = Temperature(celsius: 25.0) {
     print("Valid temp: \(temp.celsius)°C")
 }

 if Temperature(celsius: -300) == nil {
     print("Invalid temperature — below absolute zero")
 }

 // Force-unwrap failable: init! (crashes if nil — use sparingly)
 class Config {
     var value: Int
     init!(value: Int) {
         guard value > 0 else { return nil }
         self.value = value
     }
 }


 // --- DEINITIALIZATION ---
 // Called automatically before instance is deallocated.
 // Only classes have deinit. Only one per class, no parameters.

 class FileManager {
     var filename: String

     init(filename: String) {
         self.filename = filename
         print("Opened file: \(filename)")
     }

     deinit {
         print("Closed file: \(filename)")
         // cleanup: close file handles, remove observers, etc.
     }
 }

 // deinit is triggered when reference count drops to zero
 var fm: FileManager? = FileManager(filename: "data.txt")
 fm = nil   // Prints: "Closed file: data.txt"


 // ============================================================
 // INITIALIZATION — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What is the difference between designated and
    convenience initializers?
 A: Designated initializers fully initialize all properties and
    call a superclass designated init. Convenience initializers
    are helpers that must ultimately call a designated init on
    the same class. Think: designated = vertical chain (super),
    convenience = horizontal delegation (self).

 Q2 (Basic): When would you use a failable initializer?
 A: When initialization depends on external input that might be
    invalid — like parsing a URL, decoding JSON, loading a file,
    or enforcing value constraints.

 Q3 (Medium): What are the two phases of Swift's two-phase
    initialization for classes?
 A: Phase 1: Every stored property is assigned an initial value
    working upward through the class hierarchy.
    Phase 2: Each class gets a chance to customize its stored
    properties before the object is made available.
    This prevents you from using `self` before all properties
    are initialized.

 Q4 (Medium): Can a struct have a failable initializer?
 A: Yes. Both structs and classes support `init?` and `init!`.

 Q5 (Hard): What is the initializer inheritance rule in Swift
    for classes, and when does a subclass NOT inherit
    superclass initializers?
 A: A subclass does NOT automatically inherit superclass
    initializers unless:
    (a) It defines no designated initializers of its own, OR
    (b) It overrides ALL of the superclass's designated
        initializers (in which case it also inherits all
        convenience initializers).
    If the subclass adds new stored properties without defaults,
    it must provide its own designated init.

 Q6 (Hard): Why can't you call `self.someMethod()` before
    calling `super.init()` in a designated initializer?
 A: Swift's two-phase init safety check #1 requires that all
    stored properties of the current class are assigned BEFORE
    delegating up. This prevents accessing memory that hasn't
    been fully initialized. Using `self` before super.init()
    means the full object isn't ready — it could crash or
    return garbage data from uninitialized memory.
 */


 // ============================================================
 // 3. PROTOCOLS
 // ============================================================

 // --- DEFINITION ---
 // A protocol defines a blueprint of methods, properties,
 // and requirements for conforming types.

 protocol Drawable {
     var color: String { get }
     func draw()
 }

 struct Circle: Drawable {
     var color: String
     func draw() { print("Drawing a \(color) circle") }
 }

 struct Square: Drawable {
     var color: String
     func draw() { print("Drawing a \(color) square") }
 }


 // --- PROTOCOL EXTENSIONS ---
 // Add default implementations to protocol methods.
 // This is the foundation of Protocol-Oriented Programming.

 protocol Greetable {
     var name: String { get }
     func greet()
 }

 extension Greetable {
     func greet() {
         print("Hello, I am \(name)!")   // default implementation
     }
 }

 struct Robot: Greetable {
     var name: String
     // No need to implement greet() — uses default
 }

 struct CustomBot: Greetable {
     var name: String
     func greet() {
         print("BEEP BOOP. I am \(name).")   // custom override
     }
 }

 Robot(name: "R2D2").greet()       // Hello, I am R2D2!
 CustomBot(name: "HAL").greet()    // BEEP BOOP. I am HAL.


 // --- OPTIONAL METHODS VIA @objc ---
 // Pure Swift protocols don't support optional methods.
 // You must use @objc protocol + optional keyword.
 // The conforming type must be a class (or @objc type).

 @objc protocol DataSource {
     func numberOfItems() -> Int
     @objc optional func titleForItem(at index: Int) -> String
 }

 class MyDataSource: NSObject, DataSource {
     func numberOfItems() -> Int { return 5 }
     // titleForItem is optional — no compiler error for not implementing
 }

 // Calling optional method safely
 let source = MyDataSource()
 let title = source.titleForItem?(at: 0) ?? "Untitled"


 // --- PROTOCOL INHERITANCE ---
 // Protocols can inherit from one or more other protocols.

 protocol Shape {
     var area: Double { get }
 }

 protocol ColoredShape: Shape {
     var color: String { get }
 }

 // Conforming type must satisfy BOTH Shape and ColoredShape
 struct ColoredCircle: ColoredShape {
     var radius: Double
     var color: String
     var area: Double { return Double.pi * radius * radius }
 }


 // ============================================================
 // PROTOCOLS — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What is protocol-oriented programming (POP)
    and how does it differ from OOP?
 A: POP favors composing behavior via protocols and protocol
    extensions over class hierarchies. Structs and enums can
    participate fully. It avoids the fragility of deep
    inheritance chains and enables value-type polymorphism.

 Q2 (Basic): Can a struct conform to a protocol? Can it conform
    to multiple protocols?
 A: Yes to both. Structs can conform to any number of protocols,
    which is how Swift compensates for not having multiple
    inheritance.

 Q3 (Medium): What is the difference between a protocol
    with a default implementation and an abstract method?
 A: A protocol with a default implementation allows conforming
    types to skip implementing that method (they get the default).
    An abstract method (in OOP languages) forces subclasses to
    implement it. In Swift, all protocol requirements are
    effectively "abstract" — but protocol extensions can make
    them optionally overridable.

 Q4 (Medium): What is the difference between `Self` and `self`
    in a protocol context?
 A: `self` refers to the current instance.
    `Self` (capital S) refers to the concrete conforming type
    at the call site. Used in protocols to constrain return types
    or parameters to be the same type as the conformer.

    protocol Copyable {
        func copy() -> Self
    }

 Q5 (Hard): What is the difference between a protocol used as
    a type vs a protocol with `some` or `any`?
 A: Using a protocol directly as a type (e.g., `var x: Drawable`)
    creates an existential type — it uses dynamic dispatch and
    loses type information (no associated types allowed).
    `some Drawable` is an opaque type — the compiler knows the
    concrete type, enables static dispatch, works with
    associated types.
    `any Drawable` (Swift 5.7+) is the explicit existential
    syntax, replacing the bare protocol-as-type usage.

 Q6 (Hard): Why can't you use a protocol with an `associatedtype`
    as an existential type directly?
 A: Because the associated type creates a type-level dependency
    that can't be resolved without knowing the concrete type.
    The compiler can't build a runtime box (existential) for
    something that's type-parameterized. Solution: use generics,
    `some`, or type erasure (e.g., `AnyCollection`).
 */


 // ============================================================
 // 4. GENERICS
 // ============================================================

 // --- GENERIC FUNCTIONS ---
 // Write flexible, reusable functions that work with any type.

 func swapValues<T>(_ a: inout T, _ b: inout T) {
     let temp = a
     a = b
     b = temp
 }

 var x = 10, y = 20
 swapValues(&x, &y)
 print(x, y)  // 20 10

 var s1 = "Hello", s2 = "World"
 swapValues(&s1, &s2)
 print(s1, s2)  // World Hello


 // --- GENERIC TYPES ---
 // Structs, classes, enums can be generic.

 struct Stack<Element> {
     private var items: [Element] = []

     mutating func push(_ item: Element) {
         items.append(item)
     }

     mutating func pop() -> Element? {
         return items.popLast()
     }

     var top: Element? { return items.last }
     var isEmpty: Bool { return items.isEmpty }
 }

 var intStack = Stack<Int>()
 intStack.push(1)
 intStack.push(2)
 print(intStack.pop()!)  // 2


 // --- TYPE CONSTRAINTS ---
 // Restrict generic types to those that conform to a protocol.

 func findMax<T: Comparable>(_ array: [T]) -> T? {
     guard !array.isEmpty else { return nil }
     return array.max()
 }

 print(findMax([3, 1, 4, 1, 5, 9])!)  // 9
 print(findMax(["apple", "zebra", "mango"])!)  // zebra


 // --- ASSOCIATED TYPE ---
 // Placeholder type in a protocol, defined by the conformer.

 protocol Container {
     associatedtype Item
     var count: Int { get }
     mutating func add(_ item: Item)
     func item(at index: Int) -> Item
 }

 struct Bag<T>: Container {
     private var storage: [T] = []
     var count: Int { return storage.count }

     mutating func add(_ item: T) {
         storage.append(item)
     }

     func item(at index: Int) -> T {
         return storage[index]
     }
 }


 // --- SOME (OPAQUE TYPE) ---
 // Returns "some concrete type that conforms to X" without
 // exposing which type. Used heavily in SwiftUI.

 protocol Shape2 {
     func describe() -> String
 }

 struct Triangle: Shape2 {
     func describe() -> String { return "I am a triangle" }
 }

 func makeShape() -> some Shape2 {
     return Triangle()   // compiler knows the return is Triangle
 }

 let shape = makeShape()
 print(shape.describe())


 // --- ANY (EXISTENTIAL TYPE) ---
 // `any Protocol` is an explicit existential — can hold any
 // conforming type at runtime, but loses static type info.
 // Introduced formally in Swift 5.7.

 func printShape(_ shape: any Shape2) {
     print(shape.describe())
 }

 // Contrast:
 // some Shape2 — one fixed concrete type, statically known
 // any Shape2  — any conforming type, resolved at runtime


 // ============================================================
 // GENERICS — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What problem do generics solve?
 A: They eliminate code duplication by allowing you to write
    one function or type that works with any type, while
    still being type-safe (unlike using `Any`).

 Q2 (Basic): What is a type constraint in generics?
 A: A restriction added to a generic type parameter requiring
    it to conform to a protocol or inherit from a class.
    E.g., `<T: Comparable>` means T must implement Comparable.

 Q3 (Medium): What is the difference between `some` and `any`?
 A: `some Protocol` is an opaque return type — the concrete type
    is fixed and known at compile time (static dispatch, faster).
    `any Protocol` is an explicit existential — the concrete type
    varies at runtime (dynamic dispatch, slightly slower, but
    more flexible). Use `some` when you can for performance.

 Q4 (Medium): Can two functions with the same name differ only
    in their generic constraint?
 A: No — Swift doesn't overload solely on constraints. The
    compiler resolves overloads at compile time based on
    parameter labels and types, not constraint differences.

 Q5 (Hard): What is type erasure and when do you need it?
 A: Type erasure hides a generic concrete type behind a
    protocol-conforming wrapper. You need it when you want
    to store heterogeneous collections of types that share
    a protocol with associated types (which can't be used
    as existentials directly).

    // Example: AnyPublisher in Combine erases the concrete
    // Publisher type so you can return it from functions
    // without exposing the full type chain.

    struct AnyContainer<T>: Container {
        private let _count: () -> Int
        private let _add: (T) -> Void
        private let _item: (Int) -> T

        init<C: Container>(_ container: C) where C.Item == T {
            var c = container
            _count = { c.count }
            _add = { c.add($0) }
            _item = { c.item(at: $0) }
        }
        var count: Int { _count() }
        mutating func add(_ item: T) { _add(item) }
        func item(at index: Int) -> T { _item(index) }
    }

 Q6 (Hard): What is the "primary associated type" feature
    (Swift 5.7+) and how does it interact with `some`/`any`?
 A: Swift 5.7 introduced primary associated types, letting you
    parameterize existentials like generics:
    `any Collection<String>` or `some Collection<Int>`.
    This allows existential types to carry type info and makes
    protocols with associated types usable as existentials in
    more scenarios without full type erasure.
 */


 // ============================================================
 // 5. EXTENSIONS
 // ============================================================

 // --- ADDING FUNCTIONALITY ---
 // Extend types you own OR don't own (Int, String, Array, etc.)

 extension String {
     func trimmed() -> String {
         return self.trimmingCharacters(in: .whitespaces)
     }

     var isPalindrome: Bool {
         let cleaned = self.lowercased().filter { $0.isLetter }
         return cleaned == String(cleaned.reversed())
     }
 }

 print("  Hello  ".trimmed())          // "Hello"
 print("racecar".isPalindrome)         // true
 print("Swift".isPalindrome)           // false


 // Extension on Int
 extension Int {
     func times(_ action: () -> Void) {
         for _ in 0..<self { action() }
     }
 }

 3.times { print("Swift is awesome") }  // prints 3 times


 // --- PROTOCOL CONFORMANCE VIA EXTENSION ---
 // Retroactively add protocol conformance to existing types.

 protocol Describable {
     func describe() -> String
 }

 // Making Int conform to our custom protocol
 extension Int: Describable {
     func describe() -> String {
         return "I am the integer \(self)"
     }
 }

 print(42.describe())   // I am the integer 42


 // Complex example: Equatable conformance added retroactively
 struct Point {
     var x: Double
     var y: Double
 }

 extension Point: Equatable {
     static func == (lhs: Point, rhs: Point) -> Bool {
         return lhs.x == rhs.x && lhs.y == rhs.y
     }
 }

 let p1 = Point(x: 1, y: 2)
 let p2 = Point(x: 1, y: 2)
 print(p1 == p2)  // true


 // --- EXTENSIONS WITH CONSTRAINTS ---
 // Conditionally add methods only when type parameters meet conditions.

 extension Array where Element: Numeric {
     func sum() -> Element {
         return reduce(0, +)
     }
 }

 print([1, 2, 3, 4, 5].sum())    // 15
 print([1.5, 2.5, 3.0].sum())    // 7.0
 // ["a", "b"].sum()             // ERROR — String not Numeric


 // Extensions can't store new stored properties, but CAN
 // add computed properties:
 extension Double {
     var km: Double { return self * 1_000.0 }
     var m: Double  { return self }
     var cm: Double { return self / 100.0 }
 }

 let marathon = 42.2.km
 print("Marathon is \(marathon) meters")


 // ============================================================
 // EXTENSIONS — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What can extensions NOT do in Swift?
 A: Extensions cannot:
    - Add stored instance properties
    - Add stored type properties (static stored vars — computed OK)
    - Override existing methods (only classes via subclass)
    - Add designated initializers to classes
      (can add convenience inits)
    - Add deinit

 Q2 (Basic): Can you add protocol conformance to a type you
    don't own (e.g., String, Int)?
 A: Yes — this is called retroactive conformance. It's a
    powerful feature but must be used carefully to avoid
    conflicts when the same conformance is added in multiple
    modules.

 Q3 (Medium): What is the difference between extending a type
    directly and using a conditional extension?
 A: A direct extension applies to all instances of the type.
    A conditional extension (`where Element: Comparable`) only
    applies when the generic parameter meets the constraint.
    This avoids polluting types where the functionality
    doesn't make sense.

 Q4 (Medium): Can extensions add initializers to structs?
    What rule applies?
 A: Yes, with an important nuance: if you add a custom
    initializer via an extension (not inline in the struct),
    the compiler-synthesized memberwise initializer is still
    preserved. If you put the custom init inline in the struct
    body, the memberwise init is suppressed.

 Q5 (Hard): Why can't extensions add stored properties, and
    how do you work around this limitation?
 A: Stored properties require memory layout to be defined at
    type creation time. Extensions are retroactive and applied
    after the type is defined, so the compiler can't adjust
    the memory layout. Workarounds:
    (a) Use computed properties (no memory overhead).
    (b) Use associated objects via Objective-C runtime
        (objc_getAssociatedObject) for classes only.
    (c) Use a wrapper struct/class that holds the extra state.

 Q6 (Hard): What is "protocol witness table" and how do
    extensions affect method dispatch?
 A: A protocol witness table (PWT) is a Swift runtime structure
    that maps protocol requirements to their concrete
    implementations for a given type. When a type declares
    conformance and implements a protocol method in its main
    body, that method goes into the PWT and participates in
    dynamic dispatch through the protocol. HOWEVER, if a
    method is added via a protocol extension (default
    implementation) and the conforming type also defines it
    — but NOT in its protocol conformance declaration — the
    call goes to static dispatch based on the static type.
    This leads to surprising behavior:

    protocol Greeter { func hello() }
    extension Greeter {
        func hello() { print("Protocol default") }
        func bye()   { print("Extension only") }     // NOT in PWT
    }
    struct Foo: Greeter {
        func hello() { print("Foo hello") }           // IN PWT
        func bye()   { print("Foo bye") }             // NOT in PWT
    }
    let f: Greeter = Foo()
    f.hello()  // "Foo hello"   — dynamic, through PWT
    f.bye()    // "Extension only" — static, based on Greeter type!

    This is one of the most common Swift gotchas in interviews.
 */


 // ============================================================
 // END OF NOTES
 // ============================================================


 */

