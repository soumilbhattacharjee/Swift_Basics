import UIKit

/*
 CUSTOM TYPES IN SWIFT
 ===========================================================
 STRUCT (VALUE TYPES) vs CLASS (REFERENCE TYPES)
 IDENTITY OPERATORS, MEMORY, PATTERNS
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — WHAT ARE CUSTOM TYPES?
 ================================================================

 WHAT IS A CUSTOM TYPE?
 =======================
 A custom type is a type you define yourself using
 struct, class, enum, protocol, or typealias.
 It groups related data and behavior into a single
 named unit. Swift is a protocol-oriented language
 that strongly favors structs over classes.

 SWIFT TYPE CATEGORIES
 ======================
   Named Types:
     - struct      — value type  (your custom data model)
     - class       — reference type (identity matters)
     - enum        — value type  (finite set of cases)
     - protocol    — blueprint   (defines requirements)

   Compound Types:
     - tuple       — value type  (unnamed grouping)
     - function    — reference type (closures are ref types)

 STRUCT vs CLASS — MASTER COMPARISON TABLE
 ==========================================
 Feature                   | struct                | class
 --------------------------|------------------------|---------------------------
 Type category             | Value type             | Reference type
 Memory location           | Stack (typically)      | Heap
 Assignment behavior       | Copies data            | Shares reference
 ARC managed               | No                     | Yes
 Inheritance               | No (protocol only)     | Yes (single inheritance)
 deinit                    | No                     | Yes
 Identity check (===)      | Not available          | Available
 Memberwise initializer    | Auto-generated         | Not auto-generated
 Mutability keyword        | mutating               | Not needed
 let immutability          | All props immutable    | Only reference immutable
 Reference cycles          | Impossible             | Possible
 Thread safety             | Yes (by default)       | No (needs care)
 Protocol conformance      | Yes                    | Yes
 Generics support          | Yes                    | Yes
 Type methods/props        | static (non-override)  | static or class (override)
 Default initializer       | Yes (if all have def.) | Yes (if no init defined)
 Required initializer      | N/A                    | required init
 Convenience initializer   | N/A                    | convenience init
 Designated initializer    | init (all inits)       | Designated init


 ================================================================
 PART 2 — STRUCT IN DEPTH
 ================================================================

 WHAT IS A STRUCT?
 ==================
 A struct is a value type that groups related
 properties and methods. It is copied when assigned
 or passed. Mutation requires the mutating keyword.
 The compiler automatically generates a memberwise
 initializer for structs.

 BASIC STRUCT
 =============
   struct Point {
       var x: Double
       var y: Double
   }

   // Memberwise initializer — auto-generated:
   var p1 = Point(x: 3.0, y: 4.0)
   print(p1.x)
   // Output: 3.0
   print(p1.y)
   // Output: 4.0

 STRUCT WITH COMPUTED PROPERTY
 ================================
   struct Circle {
       var radius: Double

       // Stored property:
       var color: String = "red"

       // Computed property:
       var area: Double {
           return Double.pi * radius * radius
       }

       // Computed property with getter and setter:
       var diameter: Double {
           get { return radius * 2 }
           set { radius = newValue / 2 }
       }
   }

   var c = Circle(radius: 5.0)
   print(c.area)
   // Output: 78.53981633974483
   print(c.diameter)
   // Output: 10.0

   c.diameter = 20.0
   print(c.radius)
   // Output: 10.0

 STRUCT WITH METHODS
 ====================
   struct Rectangle {
       var width: Double
       var height: Double

       // Non-mutating — reads only:
       func area() -> Double {
           return width * height
       }

       func perimeter() -> Double {
           return 2 * (width + height)
       }

       // mutating — modifies self:
       mutating func scale(factor: Double) {
           width  *= factor
           height *= factor
       }

       mutating func reset() {
           width  = 0
           height = 0
       }
   }

   var rect = Rectangle(width: 4.0, height: 3.0)
   print(rect.area())
   // Output: 12.0
   print(rect.perimeter())
   // Output: 14.0

   rect.scale(factor: 2.0)
   print(rect.area())
   // Output: 48.0

   rect.reset()
   print(rect.width)
   // Output: 0.0

 STRUCT — COPY BEHAVIOR
 ========================
   struct Temperature {
       var celsius: Double

       var fahrenheit: Double {
           return celsius * 9/5 + 32
       }
   }

   var temp1 = Temperature(celsius: 100.0)
   var temp2 = temp1          // COPY — independent
   temp2.celsius = 0.0

   print(temp1.celsius)       // temp1 unchanged
   // Output: 100.0
   print(temp2.celsius)       // temp2 changed
   // Output: 0.0
   print(temp1.fahrenheit)
   // Output: 212.0
   print(temp2.fahrenheit)
   // Output: 32.0

 STRUCT — let IMMUTABILITY
 ===========================
   // let on a struct → ALL properties immutable:
   let immutablePoint = Point(x: 1.0, y: 2.0)
   // immutablePoint.x = 5.0   // Error: cannot assign to property
   // immutablePoint.y = 9.0   // Error: cannot assign to property

   // var on a struct → properties can change:
   var mutablePoint = Point(x: 1.0, y: 2.0)
   mutablePoint.x = 5.0        // OK
   print(mutablePoint.x)
   // Output: 5.0

 STRUCT WITH CUSTOM INITIALIZER
 ================================
   struct Color {
       var red:   Double
       var green: Double
       var blue:  Double
       var alpha: Double

       // Custom initializer — memberwise still available
       // only if NO custom init defined in the main body.
       // Use extension to keep both:
       init(white: Double, alpha: Double = 1.0) {
           self.red   = white
           self.green = white
           self.blue  = white
           self.alpha = alpha
       }
   }

   // Custom init:
   var gray = Color(white: 0.5)
   print(gray.red)
   // Output: 0.5

   // To keep memberwise AND custom init — use extension:
   struct Size {
       var width:  Double
       var height: Double
   }
   extension Size {
       init(square side: Double) {
           self.width  = side
           self.height = side
       }
   }

   let s1 = Size(width: 4.0, height: 3.0)  // memberwise
   let s2 = Size(square: 5.0)               // custom

   print(s1.width)
   // Output: 4.0
   print(s2.width)
   // Output: 5.0
   print(s2.height)
   // Output: 5.0

 STRUCT WITH STATIC MEMBERS
 ============================
   struct MathConstants {
       static let pi    = 3.14159265358979
       static let e     = 2.71828182845905
       static let sqrt2 = 1.41421356237310

       static func circleArea(radius: Double) -> Double {
           return pi * radius * radius
       }
   }

   print(MathConstants.pi)
   // Output: 3.14159265358979
   print(MathConstants.circleArea(radius: 3.0))
   // Output: 28.274333882308138

 STRUCT CONFORMING TO PROTOCOL
 ================================
   protocol Describable {
       func describe() -> String
   }

   protocol Resizable {
       mutating func resize(by factor: Double)
   }

   struct Square: Describable, Resizable {
       var side: Double

       func describe() -> String {
           return "Square with side \(side), area \(side * side)"
       }

       mutating func resize(by factor: Double) {
           side *= factor
       }
   }

   var sq = Square(side: 4.0)
   print(sq.describe())
   // Output: Square with side 4.0, area 16.0

   sq.resize(by: 2.0)
   print(sq.describe())
   // Output: Square with side 8.0, area 64.0

 STRUCT PASSING TO FUNCTION
 ============================
   struct Vector {
       var dx: Double
       var dy: Double

       var magnitude: Double {
           return (dx * dx + dy * dy).squareRoot()
       }
   }

   // Function receives a COPY — original unchanged:
   func normalize(_ v: Vector) -> Vector {
       let mag = v.magnitude
       return Vector(dx: v.dx / mag, dy: v.dy / mag)
   }

   let original = Vector(dx: 3.0, dy: 4.0)
   let normalized = normalize(original)

   print(original.dx)
   // Output: 3.0
   print(normalized.dx)
   // Output: 0.6
   print(normalized.magnitude)
   // Output: 1.0

 STRUCT WITH PROPERTY OBSERVERS
 ================================
   struct StepCounter {
       var steps: Int = 0 {
           willSet(newSteps) {
               print("About to set steps to \(newSteps)")
           }
           didSet {
               if steps > oldValue {
                   print("Added \(steps - oldValue) steps")
               }
           }
       }
   }

   var counter = StepCounter()
   counter.steps = 100
   // Output: About to set steps to 100
   //         Added 100 steps
   counter.steps = 150
   // Output: About to set steps to 150
   //         Added 50 steps

 NESTED STRUCTS
 ===============
   struct Company {
       struct Address {
           var street: String
           var city: String
           var country: String
       }

       struct Employee {
           var name: String
           var role: String
           var salary: Double
       }

       var name: String
       var headquarters: Address
       var employees: [Employee]

       func headcount() -> Int { employees.count }
   }

   let apple = Company(
       name: "Apple",
       headquarters: Company.Address(
           street: "1 Apple Park Way",
           city: "Cupertino",
           country: "USA"
       ),
       employees: [
           Company.Employee(name: "Tim", role: "CEO", salary: 3_000_000),
           Company.Employee(name: "Craig", role: "SVP", salary: 2_500_000)
       ]
   )

   print(apple.name)
   // Output: Apple
   print(apple.headquarters.city)
   // Output: Cupertino
   print(apple.headcount())
   // Output: 2
   print(apple.employees[0].name)
   // Output: Tim


 ================================================================
 PART 3 — CLASS IN DEPTH
 ================================================================

 WHAT IS A CLASS?
 =================
 A class is a reference type that groups properties
 and methods. Assignment shares a reference to the
 same heap instance. Supports inheritance, deinit,
 and identity comparison (===). ARC manages lifetime.

 BASIC CLASS
 ============
   class Person {
       var name: String
       var age: Int

       init(name: String, age: Int) {
           self.name = name
           self.age  = age
           print("Person(\(name)) initialized")
       }

       func greet() -> String {
           return "Hi, I'm \(name), age \(age)"
       }

       deinit {
           print("Person(\(name)) deinitialized")
       }
   }

   var p: Person? = Person(name: "Alice", age: 30)
   // Output: Person(Alice) initialized
   print(p!.greet())
   // Output: Hi, I'm Alice, age 30
   p = nil
   // Output: Person(Alice) deinitialized

 CLASS — REFERENCE BEHAVIOR
 ============================
   class BankAccount {
       var balance: Double
       let owner: String

       init(owner: String, balance: Double) {
           self.owner   = owner
           self.balance = balance
           print("Account for \(owner) created")
       }
       deinit { print("Account for \(owner) closed") }
   }

   var account1: BankAccount? = BankAccount(owner: "Bob",
                                              balance: 1000.0)
   // Output: Account for Bob created

   var account2 = account1      // SHARED reference
   account2?.balance = 5000.0   // modifies the SAME instance

   print(account1?.balance ?? 0)  // sees the change
   // Output: 5000.0
   print(account2?.balance ?? 0)
   // Output: 5000.0

   account1 = nil               // RC = 1 — NOT freed
   account2 = nil               // RC = 0 — freed
   // Output: Account for Bob closed

 CLASS — let BEHAVIOR (REFERENCE IMMUTABILITY)
 ================================================
   class Config {
       var theme: String = "dark"
       var fontSize: Int = 14
   }

   // let on a class → reference is constant (can't reassign)
   // but properties CAN change:
   let cfg = Config()
   cfg.theme    = "light"       // OK — property mutation allowed
   cfg.fontSize = 16            // OK
   // cfg = Config()            // Error — cannot reassign let

   print(cfg.theme)
   // Output: light
   print(cfg.fontSize)
   // Output: 16

 CLASS INHERITANCE
 ==================
   class Animal {
       var name: String
       var sound: String

       init(name: String, sound: String) {
           self.name  = name
           self.sound = sound
           print("Animal \(name) created")
       }

       func makeSound() -> String {
           return "\(name) says \(sound)"
       }

       func describe() -> String {
           return "Animal: \(name)"
       }

       deinit { print("Animal \(name) freed") }
   }

   class Dog: Animal {
       var breed: String

       init(name: String, breed: String) {
           self.breed = breed
           super.init(name: name, sound: "Woof")
           print("Dog \(name) (\(breed)) created")
       }

       override func describe() -> String {
           return "Dog: \(name), Breed: \(breed)"
       }

       func fetch() -> String {
           return "\(name) fetches the ball!"
       }

       deinit { print("Dog \(name) freed") }
   }

   class GoldenRetriever: Dog {
       var isTherapyDog: Bool

       init(name: String, isTherapyDog: Bool) {
           self.isTherapyDog = isTherapyDog
           super.init(name: name, breed: "Golden Retriever")
       }

       override func describe() -> String {
           let therapy = isTherapyDog ? " (therapy dog)" : ""
           return super.describe() + therapy
       }
   }

   var buddy: GoldenRetriever? = GoldenRetriever(name: "Buddy",
                                                   isTherapyDog: true)
   // Output: Animal Buddy created
   //         Dog Buddy (Golden Retriever) created

   print(buddy!.makeSound())
   // Output: Buddy says Woof
   print(buddy!.describe())
   // Output: Dog: Buddy, Breed: Golden Retriever (therapy dog)
   print(buddy!.fetch())
   // Output: Buddy fetches the ball!

   buddy = nil
   // Output: Dog Buddy freed
   //         Animal Buddy freed

 CLASS — DESIGNATED AND CONVENIENCE INITIALIZERS
 =================================================
   class Vehicle {
       var make:  String
       var model: String
       var year:  Int
       var color: String

       // Designated initializer — must init ALL stored props:
       init(make: String, model: String, year: Int, color: String) {
           self.make  = make
           self.model = model
           self.year  = year
           self.color = color
           print("Vehicle \(year) \(make) \(model) created")
       }

       // Convenience initializer — must call designated init:
       convenience init(make: String, model: String) {
           self.init(make: make, model: model,
                     year: 2024, color: "White")
           print("Convenience init used")
       }

       // Convenience init calling another convenience init:
       convenience init(make: String) {
           self.init(make: make, model: "Unknown")
       }

       deinit { print("Vehicle \(make) freed") }
   }

   var v1: Vehicle? = Vehicle(make: "Toyota", model: "Camry",
                                year: 2023, color: "Blue")
   // Output: Vehicle 2023 Toyota Camry created

   var v2: Vehicle? = Vehicle(make: "Honda", model: "Civic")
   // Output: Vehicle 2024 Honda Civic created
   //         Convenience init used

   v1 = nil
   // Output: Vehicle Toyota freed
   v2 = nil
   // Output: Vehicle Honda freed

 CLASS — REQUIRED INITIALIZER
 ==============================
   class Shape {
       var name: String

       // required — every subclass MUST implement this init:
       required init(name: String) {
           self.name = name
       }

       func area() -> Double { return 0 }
   }

   class Triangle: Shape {
       var base:   Double
       var height: Double

       required init(name: String) {
           self.base   = 0
           self.height = 0
           super.init(name: name)
       }

       init(name: String, base: Double, height: Double) {
           self.base   = base
           self.height = height
           super.init(name: name)
       }

       override func area() -> Double {
           return 0.5 * base * height
       }
   }

   let t = Triangle(name: "MyTriangle", base: 6.0, height: 4.0)
   print(t.area())
   // Output: 12.0

 CLASS — OVERRIDE
 =================
   class Printer {
       func print_doc(_ text: String) {
           print("Printing: \(text)")
       }

       var description: String {
           return "Basic Printer"
       }
   }

   class LaserPrinter: Printer {
       var dpi: Int

       init(dpi: Int) { self.dpi = dpi }

       // Override method:
       override func print_doc(_ text: String) {
           print("Laser printing at \(dpi)dpi: \(text)")
       }

       // Override computed property:
       override var description: String {
           return "Laser Printer \(dpi)dpi"
       }
   }

   let laser = LaserPrinter(dpi: 1200)
   laser.print_doc("Invoice")
   // Output: Laser printing at 1200dpi: Invoice
   print(laser.description)
   // Output: Laser Printer 1200dpi

 CLASS — final
 ==============
   // final prevents subclassing and method overriding:
   final class Singleton {
       static let shared = Singleton()
       private init() { print("Singleton created") }
       func doWork() { print("Working") }
   }

   // class Sub: Singleton { }  // Error — cannot subclass final

   Singleton.shared.doWork()
   // Output: Singleton created
   //         Working

 CLASS — TYPE PROPERTIES AND METHODS
 =====================================
   class Counter {
       static var totalCreated = 0     // static — not overridable
       class var description: String { // class — overridable
           return "Counter"
       }
       var count = 0

       init() {
           Counter.totalCreated += 1
           print("Counter #\(Counter.totalCreated) created")
       }

       func increment() { count += 1 }
       func reset()     { count = 0 }

       static func resetTotal() {
           totalCreated = 0
       }
   }

   class SpecialCounter: Counter {
       override class var description: String {
           return "Special Counter"
       }
   }

   let c1 = Counter()
   // Output: Counter #1 created
   let c2 = Counter()
   // Output: Counter #2 created
   let sc = SpecialCounter()
   // Output: Counter #3 created

   print(Counter.totalCreated)
   // Output: 3
   print(Counter.description)
   // Output: Counter
   print(SpecialCounter.description)
   // Output: Special Counter


 ================================================================
 PART 4 — IDENTITY OPERATORS IN DEPTH
 ================================================================

 WHAT ARE IDENTITY OPERATORS?
 ==============================
 Identity operators check whether two variables
 refer to the exact same class instance in memory.
 They only work with reference types (class).
 They do NOT work with value types (struct, enum).

   ===    "Identical to"    — same instance
   !==    "Not identical to" — different instances

 IDENTITY vs EQUALITY
 =====================
   // Identity (===) — are they the SAME object?
   // Equality (==)  — do they have the SAME VALUE?

   class Point3D {
       var x, y, z: Double
       init(_ x: Double, _ y: Double, _ z: Double) {
           self.x = x; self.y = y; self.z = z
       }
   }

   extension Point3D: Equatable {
       static func == (lhs: Point3D, rhs: Point3D) -> Bool {
           return lhs.x == rhs.x &&
                  lhs.y == rhs.y &&
                  lhs.z == rhs.z
       }
   }

   let pt1 = Point3D(1.0, 2.0, 3.0)
   let pt2 = pt1                       // same instance
   let pt3 = Point3D(1.0, 2.0, 3.0)   // different instance, same values

   // Identity:
   print(pt1 === pt2)    // same reference
   // Output: true
   print(pt1 === pt3)    // different reference
   // Output: false
   print(pt1 !== pt3)
   // Output: true

   // Equality:
   print(pt1 == pt3)     // same values
   // Output: true
   print(pt1 == pt2)
   // Output: true

 IDENTITY OPERATORS — BASIC EXAMPLES
 ======================================
   class Car {
       var model: String
       init(model: String) { self.model = model }
   }

   let tesla = Car(model: "Model S")
   let bmw   = Car(model: "M3")
   let alias = tesla              // same reference

   print(tesla === alias)         // same object
   // Output: true
   print(tesla === bmw)           // different objects
   // Output: false
   print(tesla !== bmw)           // not identical
   // Output: true
   print(tesla !== alias)         // identical — so !== is false
   // Output: false

 IDENTITY OPERATORS WITH OPTIONAL
 ==================================
   class Node {
       var value: Int
       init(_ value: Int) { self.value = value }
   }

   var node1: Node? = Node(1)
   var node2: Node? = node1       // same instance
   var node3: Node? = Node(1)     // different instance

   print(node1 === node2)
   // Output: true
   print(node1 === node3)
   // Output: false
   print(node1 === nil)
   // Output: false
   node1 = nil
   print(node1 === node2)
   // Output: false   (node1 is nil, node2 is not)
   node2 = nil
   print(node1 === node2)
   // Output: true    (both nil === nil is true)

 IDENTITY OPERATORS WITH INHERITANCE
 =====================================
   class Vehicle2 {
       var speed: Int = 0
   }
   class SportsCar: Vehicle2 {
       var turbo: Bool = false
   }

   let sc1 = SportsCar()
   let sc2 = sc1                  // same instance
   let v1: Vehicle2 = sc1         // upcast — same instance

   print(sc1 === sc2)
   // Output: true
   print(sc1 === v1)              // same underlying instance
   // Output: true

   let v2 = Vehicle2()
   print(sc1 === v2)
   // Output: false

 IDENTITY OPERATORS — PRACTICAL USE CASES
 ==========================================
   // Use case 1: Check if delegate is set to self:
   class TableView {
       weak var delegate: AnyObject?
       func isOwnDelegate(_ obj: AnyObject) -> Bool {
           return delegate === obj
       }
   }

   // Use case 2: Avoiding duplicate inserts in a collection:
   class Task {
       let name: String
       init(name: String) { self.name = name }
   }

   class TaskQueue {
       private var tasks: [Task] = []

       func enqueue(_ task: Task) {
           // Only add if not already in queue (by identity):
           guard !tasks.contains(where: { $0 === task }) else {
               print("Task \(task.name) already in queue")
               return
           }
           tasks.append(task)
           print("Task \(task.name) enqueued")
       }

       func dequeue() -> Task? {
           return tasks.isEmpty ? nil : tasks.removeFirst()
       }
   }

   let tq = TaskQueue()
   let t1 = Task(name: "Download")
   let t2 = Task(name: "Upload")

   tq.enqueue(t1)
   // Output: Task Download enqueued
   tq.enqueue(t2)
   // Output: Task Upload enqueued
   tq.enqueue(t1)              // same instance — rejected
   // Output: Task Download already in queue
   tq.enqueue(Task(name: "Download"))  // different instance — allowed
   // Output: Task Download enqueued

   // Use case 3: Checking object in notification handler:
   class EventBus {
       var subscribers: [AnyObject] = []

       func subscribe(_ obj: AnyObject) {
           subscribers.append(obj)
       }

       func unsubscribe(_ obj: AnyObject) {
           subscribers = subscribers.filter { $0 !== obj }
           print("Unsubscribed")
       }
   }

   // Use case 4: Equality fallback for class:
   class UserSession {
       let sessionId: String
       init(id: String) { self.sessionId = id }
   }

   extension UserSession: Equatable {
       static func == (lhs: UserSession, rhs: UserSession) -> Bool {
           // Use identity for Equatable conformance on class:
           return lhs === rhs
           // OR use value-based comparison:
           // return lhs.sessionId == rhs.sessionId
       }
   }

   let session1 = UserSession(id: "abc")
   let session2 = session1
   let session3 = UserSession(id: "abc")

   print(session1 == session2)   // same object
   // Output: true
   print(session1 == session3)   // different objects, same id
   // Output: false               (identity-based Equatable)

 IDENTITY OPERATORS DO NOT WORK WITH VALUE TYPES
 ================================================
   struct StructPoint { var x: Int; var y: Int }

   let sp1 = StructPoint(x: 1, y: 2)
   let sp2 = sp1

   // print(sp1 === sp2)  // Error: binary operator '===' cannot be
                          // applied to two 'StructPoint' operands

   // Value types use == for equality (if Equatable):
   extension StructPoint: Equatable {}
   print(sp1 == sp2)
   // Output: true


 ================================================================
 PART 5 — STRUCT vs CLASS DECISION GUIDE
 ================================================================

 PREFER STRUCT WHEN:
 ====================
   1. Data should be copied, not shared
   2. There is no need for identity
   3. The type is relatively simple
   4. Thread safety is needed
   5. The type doesn't need to be an Objective-C class
   6. Examples: Point, Size, Color, Date, URL,
                Configuration, Request, Response

 PREFER CLASS WHEN:
 ==================
   1. Shared mutable state is required
   2. Identity matters (two instances are distinct
      even if they have the same data)
   3. The type needs to be subclassed
   4. Objective-C interoperability is required
   5. The type manages external resources (files, connections)
   6. Examples: ViewController, NetworkManager,
                DatabaseConnection, FileHandle, Thread

 PRACTICAL DECISION EXAMPLES
 =============================
   // Struct — coordinate is just data:
   struct Coordinate {
       var latitude:  Double
       var longitude: Double
   }

   // Struct — configuration is data, copied to each component:
   struct AppConfig {
       var theme:     String
       var fontSize:  Int
       var language:  String
   }

   // Class — connection manages a resource:
   class DatabaseConnection {
       let url: String
       private var isOpen = false

       init(url: String) {
           self.url = url
           open()
       }

       private func open()  { isOpen = true;  print("DB opened")  }
       private func close() { isOpen = false; print("DB closed")  }

       deinit { close() }
   }

   // Class — view controller has identity and lifecycle:
   class ViewController {
       var title: String
       init(title: String) {
           self.title = title
           print("VC \(title) loaded")
       }
       deinit { print("VC \(title) unloaded") }
   }

   // Test:
   var cfg = AppConfig(theme: "dark", fontSize: 14, language: "en")
   var cfg2 = cfg         // independent copy — intentional
   cfg2.theme = "light"
   print(cfg.theme)       // unchanged
   // Output: dark

   var db: DatabaseConnection? = DatabaseConnection(url: "db://localhost")
   // Output: DB opened
   var db2 = db           // shared — both point to same connection
   db  = nil              // RC=1 — NOT closed
   db2 = nil              // RC=0 — closed
   // Output: DB closed


 ================================================================
 PART 6 — ADVANCED STRUCT AND CLASS PATTERNS
 ================================================================

 STRUCT WITH COPY-ON-WRITE
 ==========================
   final class _ArrayStorage<T> {
       var elements: [T]
       init(_ e: [T]) {
           self.elements = e
           print("Storage created")
       }
       init(copying s: _ArrayStorage<T>) {
           self.elements = s.elements
           print("Storage COPIED")
       }
   }

   struct SmartArray<T> {
       private var storage: _ArrayStorage<T>

       init(_ elements: [T] = []) {
           storage = _ArrayStorage(elements)
       }

       private mutating func ensureUnique() {
           if !isKnownUniquelyReferenced(&storage) {
               storage = _ArrayStorage(copying: storage)
           }
       }

       mutating func append(_ element: T) {
           ensureUnique()
           storage.elements.append(element)
       }

       var count: Int { storage.elements.count }

       subscript(index: Int) -> T {
           get { storage.elements[index] }
           set { ensureUnique(); storage.elements[index] = newValue }
       }
   }

   var sa1 = SmartArray([1, 2, 3])
   // Output: Storage created
   var sa2 = sa1            // no copy — shared storage
   print(sa1.count)
   // Output: 3
   sa2.append(4)            // copy triggered
   // Output: Storage COPIED
   print(sa1.count)
   // Output: 3
   print(sa2.count)
   // Output: 4

 CLASS WITH BUILDER PATTERN
 ============================
   class QueryBuilder {
       private var table:      String = ""
       private var conditions: [String] = []
       private var columns:    [String] = ["*"]
       private var limit:      Int? = nil

       func from(_ table: String) -> QueryBuilder {
           self.table = table
           return self                    // returns self for chaining
       }

       func select(_ columns: String...) -> QueryBuilder {
           self.columns = columns
           return self
       }

       func `where`(_ condition: String) -> QueryBuilder {
           conditions.append(condition)
           return self
       }

       func limit(_ count: Int) -> QueryBuilder {
           self.limit = count
           return self
       }

       func build() -> String {
           var query = "SELECT \(columns.joined(separator: ", "))"
           query += " FROM \(table)"
           if !conditions.isEmpty {
               query += " WHERE \(conditions.joined(separator: " AND "))"
           }
           if let limit = limit {
               query += " LIMIT \(limit)"
           }
           return query
       }
   }

   let query = QueryBuilder()
       .from("users")
       .select("name", "email", "age")
       .where("age > 18")
       .where("active = true")
       .limit(10)
       .build()

   print(query)
   // Output: SELECT name, email, age FROM users
   //         WHERE age > 18 AND active = true LIMIT 10

 STRUCT WITH FLUENT INTERFACE
 ==============================
   struct HTMLBuilder {
       private var html: String = ""

       func h1(_ text: String) -> HTMLBuilder {
           var copy = self               // value type — copy!
           copy.html += "<h1>\(text)</h1>\n"
           return copy
       }

       func p(_ text: String) -> HTMLBuilder {
           var copy = self
           copy.html += "<p>\(text)</p>\n"
           return copy
       }

       func div(class cls: String,
                _ content: HTMLBuilder) -> HTMLBuilder {
           var copy = self
           copy.html += "<div class=\"\(cls)\">\n"
                      + content.html
                      + "</div>\n"
           return copy
       }

       func build() -> String { html }
   }

   let page = HTMLBuilder()
       .h1("Welcome to Swift")
       .p("Swift is a powerful language.")
       .p("It uses structs and classes.")
       .build()

   print(page)
   // Output: <h1>Welcome to Swift</h1>
   //         <p>Swift is a powerful language.</p>
   //         <p>It uses structs and classes.</p>

 CLASS CLUSTER PATTERN (FACTORY)
 =================================
   class Compression {
       // Abstract base — use class cluster:
       func compress(_ data: [UInt8]) -> [UInt8] {
           fatalError("Subclass must implement compress")
       }
       func decompress(_ data: [UInt8]) -> [UInt8] {
           fatalError("Subclass must implement decompress")
       }

       // Factory method:
       static func make(type: String) -> Compression {
           switch type {
           case "gzip": return GzipCompression()
           case "lz4":  return LZ4Compression()
           default:     return NoCompression()
           }
       }
   }

   class GzipCompression: Compression {
       override func compress(_ data: [UInt8]) -> [UInt8] {
           print("Gzip compressing \(data.count) bytes")
           return data   // simplified
       }
       override func decompress(_ data: [UInt8]) -> [UInt8] {
           print("Gzip decompressing \(data.count) bytes")
           return data
       }
   }

   class LZ4Compression: Compression {
       override func compress(_ data: [UInt8]) -> [UInt8] {
           print("LZ4 compressing \(data.count) bytes")
           return data
       }
       override func decompress(_ data: [UInt8]) -> [UInt8] {
           print("LZ4 decompressing \(data.count) bytes")
           return data
       }
   }

   class NoCompression: Compression {
       override func compress(_ data: [UInt8]) -> [UInt8] {
           print("No compression: \(data.count) bytes")
           return data
       }
       override func decompress(_ data: [UInt8]) -> [UInt8] {
           print("No decompression: \(data.count) bytes")
           return data
       }
   }

   let data: [UInt8] = [1, 2, 3, 4, 5]
   let compressors = ["gzip", "lz4", "none"].map {
       Compression.make(type: $0)
   }
   for c in compressors {
       _ = c.compress(data)
   }
   // Output: Gzip compressing 5 bytes
   //         LZ4 compressing 5 bytes
   //         No compression: 5 bytes

 PROTOCOL-ORIENTED STRUCT DESIGN
 ==================================
   protocol Printable2 {
       func prettyPrint()
   }
   protocol Serializable {
       func serialize() -> String
       static func deserialize(from: String) -> Self?
   }
   protocol Validatable {
       var isValid: Bool { get }
       func validate() throws
   }

   enum ValidationError: Error {
       case emptyName
       case invalidAge(Int)
       case invalidEmail(String)
   }

   struct UserRecord: Printable2, Serializable, Validatable {
       var name:  String
       var age:   Int
       var email: String

       // Printable2:
       func prettyPrint() {
           print("User: \(name) | Age: \(age) | Email: \(email)")
       }

       // Serializable:
       func serialize() -> String {
           return "\(name),\(age),\(email)"
       }
       static func deserialize(from s: String) -> UserRecord? {
           let parts = s.split(separator: ",").map(String.init)
           guard parts.count == 3,
                 let age = Int(parts[1]) else { return nil }
           return UserRecord(name: parts[0], age: age, email: parts[2])
       }

       // Validatable:
       var isValid: Bool {
           return !name.isEmpty && age >= 0 && email.contains("@")
       }

       func validate() throws {
           if name.isEmpty { throw ValidationError.emptyName }
           if age < 0 || age > 150 {
               throw ValidationError.invalidAge(age)
           }
           if !email.contains("@") {
               throw ValidationError.invalidEmail(email)
           }
       }
   }

   var user = UserRecord(name: "Alice", age: 28,
                          email: "alice@example.com")
   user.prettyPrint()
   // Output: User: Alice | Age: 28 | Email: alice@example.com

   let serialized = user.serialize()
   print(serialized)
   // Output: Alice,28,alice@example.com

   if let restored = UserRecord.deserialize(from: serialized) {
       restored.prettyPrint()
       // Output: User: Alice | Age: 28 | Email: alice@example.com
   }

   do {
       try user.validate()
       print("User is valid")
       // Output: User is valid
   } catch ValidationError.emptyName {
       print("Name is empty")
   } catch ValidationError.invalidAge(let a) {
       print("Invalid age: \(a)")
   } catch ValidationError.invalidEmail(let e) {
       print("Invalid email: \(e)")
   }


 ================================================================
 PART 7 — EQUATABLE AND HASHABLE FOR CUSTOM TYPES
 ================================================================

 STRUCT — AUTO EQUATABLE AND HASHABLE
 =======================================
   // Structs get Equatable and Hashable for free
   // if ALL stored properties are Equatable/Hashable:
   struct Coordinate: Equatable, Hashable {
       var lat: Double
       var lon: Double
   }

   let c1 = Coordinate(lat: 37.7749, lon: -122.4194)
   let c2 = Coordinate(lat: 37.7749, lon: -122.4194)
   let c3 = Coordinate(lat: 40.7128, lon: -74.0060)

   print(c1 == c2)
   // Output: true
   print(c1 == c3)
   // Output: false

   // Hashable — can use in Set and Dictionary:
   var visited: Set<Coordinate> = [c1, c2, c3]
   print(visited.count)
   // Output: 2   (c1 and c2 are equal — deduplicated)

   var cityNames: [Coordinate: String] = [:]
   cityNames[c1] = "San Francisco"
   cityNames[c3] = "New York"
   print(cityNames[c1] ?? "unknown")
   // Output: San Francisco

 CLASS — CUSTOM EQUATABLE AND COMPARABLE
 =========================================
   class Student: Equatable, Comparable {
       let id:    Int
       var name:  String
       var grade: Double

       init(id: Int, name: String, grade: Double) {
           self.id    = id
           self.name  = name
           self.grade = grade
       }

       // Equatable — by id (identity of data, not reference):
       static func == (lhs: Student, rhs: Student) -> Bool {
           return lhs.id == rhs.id
       }

       // Comparable — by grade descending:
       static func < (lhs: Student, rhs: Student) -> Bool {
           return lhs.grade > rhs.grade  // higher grade = "less" for sorting
       }
   }

   let students = [
       Student(id: 1, name: "Alice", grade: 92.5),
       Student(id: 2, name: "Bob",   grade: 88.0),
       Student(id: 3, name: "Carol", grade: 95.0),
       Student(id: 4, name: "Dave",  grade: 78.5)
   ]

   let sorted = students.sorted()
   for s in sorted {
       print("\(s.name): \(s.grade)")
   }
   // Output: Carol: 95.0
   //         Alice: 92.5
   //         Bob: 88.0
   //         Dave: 78.5

   // Check equality (by id):
   let same = Student(id: 1, name: "Different Name", grade: 0)
   print(students[0] == same)
   // Output: true   (same id)

 STRUCT CUSTOM EQUATABLE OVERRIDE
 ==================================
   struct Product: Equatable {
       var sku:      String
       var name:     String
       var price:    Double
       var stock:    Int

       // Custom == — only compare by SKU:
       static func == (lhs: Product, rhs: Product) -> Bool {
           return lhs.sku == rhs.sku
       }
   }

   let p1 = Product(sku: "A100", name: "Widget",
                     price: 9.99, stock: 50)
   let p2 = Product(sku: "A100", name: "Widget UPDATED",
                     price: 12.99, stock: 30)
   let p3 = Product(sku: "B200", name: "Gadget",
                     price: 19.99, stock: 10)

   print(p1 == p2)   // same SKU → equal
   // Output: true
   print(p1 == p3)   // different SKU → not equal
   // Output: false


 ================================================================
 PART 8 — TYPE CASTING WITH CUSTOM TYPES
 ================================================================

 TYPE CHECKING AND CASTING
 ==========================
   class MediaItem {
       var title: String
       init(title: String) { self.title = title }
   }

   class Movie: MediaItem {
       var director: String
       var duration: Int
       init(title: String, director: String, duration: Int) {
           self.director = director
           self.duration = duration
           super.init(title: title)
       }
   }

   class Song: MediaItem {
       var artist: String
       var bpm: Int
       init(title: String, artist: String, bpm: Int) {
           self.artist = artist
           self.bpm    = bpm
           super.init(title: title)
       }
   }

   class Podcast: MediaItem {
       var host: String
       var episodes: Int
       init(title: String, host: String, episodes: Int) {
           self.host     = host
           self.episodes = episodes
           super.init(title: title)
       }
   }

   let library: [MediaItem] = [
       Movie(title: "Inception", director: "Nolan", duration: 148),
       Song(title: "Bohemian Rhapsody", artist: "Queen", bpm: 72),
       Movie(title: "Interstellar", director: "Nolan", duration: 169),
       Podcast(title: "Swift Talk", host: "Florian", episodes: 300),
       Song(title: "Stairway to Heaven", artist: "Zeppelin", bpm: 82)
   ]

   // is — type check:
   let movieCount = library.filter { $0 is Movie }.count
   print("Movies: \(movieCount)")
   // Output: Movies: 2

   // as? — conditional downcast:
   for item in library {
       if let movie = item as? Movie {
           print("Movie: \(movie.title) (\(movie.duration)min)")
       } else if let song = item as? Song {
           print("Song: \(song.title) by \(song.artist)")
       } else if let podcast = item as? Podcast {
           print("Podcast: \(podcast.title) — \(podcast.episodes) eps")
       }
   }
   // Output: Movie: Inception (148min)
   //         Song: Bohemian Rhapsody by Queen
   //         Movie: Interstellar (169min)
   //         Podcast: Swift Talk — 300 eps
   //         Song: Stairway to Heaven by Zeppelin

   // as! — forced downcast (crash if wrong):
   let firstMovie = library[0] as! Movie
   print(firstMovie.director)
   // Output: Nolan

   // switch with type patterns:
   for item in library {
       switch item {
       case let m as Movie where m.duration > 150:
           print("Long movie: \(m.title) \(m.duration)min")
       case let m as Movie:
           print("Movie: \(m.title)")
       case let s as Song where s.bpm > 80:
           print("Fast song: \(s.title) \(s.bpm)bpm")
       case let s as Song:
           print("Song: \(s.title) \(s.bpm)bpm")
       default:
           print("Other: \(item.title)")
       }
   }
   // Output: Movie: Inception
   //         Song: Bohemian Rhapsody 72bpm
   //         Long movie: Interstellar 169min
   //         Other: Swift Talk
   //         Fast song: Stairway to Heaven 82bpm


 ================================================================
 PART 9 — STRUCT AND CLASS WITH GENERICS
 ================================================================

 GENERIC STRUCT
 ===============
   struct Stack<Element> {
       private var elements: [Element] = []

       mutating func push(_ element: Element) {
           elements.append(element)
           print("Pushed: \(element) | Size: \(elements.count)")
       }

       mutating func pop() -> Element? {
           let element = elements.popLast()
           print("Popped: \(element.map { "\($0)" } ?? "nil") "
               + "| Size: \(elements.count)")
           return element
       }

       func peek() -> Element? { elements.last }

       var isEmpty: Bool { elements.isEmpty }
       var count:   Int  { elements.count }
   }

   var intStack = Stack<Int>()
   intStack.push(10)
   // Output: Pushed: 10 | Size: 1
   intStack.push(20)
   // Output: Pushed: 20 | Size: 2
   intStack.push(30)
   // Output: Pushed: 30 | Size: 3
   print(intStack.peek() ?? -1)
   // Output: 30
   _ = intStack.pop()
   // Output: Popped: 30 | Size: 2
   print(intStack.count)
   // Output: 2

   var strStack = Stack<String>()
   strStack.push("Swift")
   // Output: Pushed: Swift | Size: 1
   strStack.push("Kotlin")
   // Output: Pushed: Kotlin | Size: 2

 GENERIC CLASS
 ==============
   class Cache<Key: Hashable, Value> {
       private var store:     [Key: Value] = [:]
       private var maxSize:   Int
       private var accessLog: [Key] = []   // LRU tracking

       init(maxSize: Int) {
           self.maxSize = maxSize
           print("Cache created (max: \(maxSize))")
       }

       func set(_ key: Key, value: Value) {
           if store[key] == nil && store.count >= maxSize {
               // Evict least recently used:
               if let oldest = accessLog.first {
                   store.removeValue(forKey: oldest)
                   accessLog.removeFirst()
                   print("Evicted: \(oldest)")
               }
           }
           store[key] = value
           accessLog.removeAll { $0 == key }
           accessLog.append(key)
       }

       func get(_ key: Key) -> Value? {
           guard let value = store[key] else { return nil }
           accessLog.removeAll { $0 == key }
           accessLog.append(key)
           return value
       }

       var count: Int { store.count }

       deinit { print("Cache freed") }
   }

   var cache: Cache<String, Int>? = Cache(maxSize: 3)
   // Output: Cache created (max: 3)

   cache!.set("a", value: 1)
   cache!.set("b", value: 2)
   cache!.set("c", value: 3)
   cache!.set("d", value: 4)   // evicts "a" (LRU)
   // Output: Evicted: a

   print(cache!.get("a") ?? -1)  // evicted — not found
   // Output: -1
   print(cache!.get("b") ?? -1)
   // Output: 2
   print(cache!.count)
   // Output: 3

   cache = nil
   // Output: Cache freed

 GENERIC STRUCT WITH CONSTRAINTS
 =================================
   struct SortedArray<T: Comparable> {
       private var elements: [T] = []

       mutating func insert(_ element: T) {
           let index = elements.firstIndex { $0 > element }
                       ?? elements.endIndex
           elements.insert(element, at: index)
       }

       func contains(_ element: T) -> Bool {
           // Binary search (elements are sorted):
           var low = 0, high = elements.count - 1
           while low <= high {
               let mid = (low + high) / 2
               if elements[mid] == element { return true }
               if elements[mid] < element  { low = mid + 1 }
               else                        { high = mid - 1 }
           }
           return false
       }

       var all: [T] { elements }
       var min: T?  { elements.first }
       var max: T?  { elements.last }
   }

   var sorted = SortedArray<Int>()
   [5, 2, 8, 1, 9, 3, 7, 4, 6].forEach { sorted.insert($0) }

   print(sorted.all)
   // Output: [1, 2, 3, 4, 5, 6, 7, 8, 9]
   print(sorted.min ?? -1)
   // Output: 1
   print(sorted.max ?? -1)
   // Output: 9
   print(sorted.contains(5))
   // Output: true
   print(sorted.contains(10))
   // Output: false


 ================================================================
 PART 10 — INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
 ================================================================

 ================================================================
 SECTION 1 — BASIC LEVEL
 ================================================================

 Q1. What is the difference between struct and class?
 -----------------------------------------------------
 A: struct — value type, copied on assignment,
             no inheritance, no deinit, no ARC.
    class   — reference type, shared on assignment,
              supports inheritance, has deinit, ARC managed.
    Example:
      struct SVal { var x: Int }
      class RRef { var x: Int; init(_ x: Int) { self.x = x } }

      var sv1 = SVal(x: 1)
      var sv2 = sv1          // copy
      sv2.x = 99
      print(sv1.x)           // unchanged
      // Output: 1

      var rv1 = RRef(10)
      var rv2 = rv1          // shared
      rv2.x = 99
      print(rv1.x)           // changed
      // Output: 99


 Q2. What are identity operators?
 ----------------------------------
 A: === checks if two variables point to the SAME
    class instance. !== checks if they do NOT.
    Only work with reference types (class).
    Example:
      class Box { var v: Int; init(_ v: Int) { self.v = v } }
      let b1 = Box(5)
      let b2 = b1             // same instance
      let b3 = Box(5)         // different instance

      print(b1 === b2)        // true — same reference
      // Output: true
      print(b1 === b3)        // false — different reference
      // Output: false
      print(b1 !== b3)
      // Output: true


 Q3. Can you use === with structs?
 ----------------------------------
 A: No. === only applies to reference types (class).
    Structs are value types — use == for equality.
    Example:
      struct Pt { var x: Int; var y: Int }
      extension Pt: Equatable {}
      let pt1 = Pt(x: 1, y: 2)
      let pt2 = pt1
      // pt1 === pt2   // Error: operator not applicable
      print(pt1 == pt2)    // use == for value types

Q4. Does let on a struct behave differently
from let on a class?
--------------------------------------------
A: Yes.
let on struct → ALL properties are immutable.
let on class  → reference is constant (cannot
               reassign), but properties CAN change.
Example:
 struct S { var x: Int }
 class C { var x: Int; init(_ x: Int) { self.x = x } }

 let s = S(x: 1)
 // s.x = 99          // Error — all props immutable

 let c = C(10)
 c.x = 99             // OK — properties mutable
 print(c.x)
 // Output: 99
 // c = C(5)          // Error — cannot reassign let


Q5. Does struct support inheritance?
--------------------------------------
A: No. Structs cannot inherit from other structs.
They can conform to protocols.
Only classes support inheritance.
Example:
 // struct Child: Parent { }  // Error — not supported

 protocol Flyable {
     func fly() -> String
 }
 struct Bird: Flyable {       // protocol conformance — OK
     func fly() -> String { return "Bird is flying" }
 }
 print(Bird().fly())
 // Output: Bird is flying


Q6. What is a mutating function in a struct?
---------------------------------------------
A: A method that modifies one or more stored
properties of a struct must be marked mutating.
This is because struct instances on let are
immutable — mutating methods only work on var.
Example:
 struct Counter {
     var count = 0
     mutating func increment() { count += 1 }
     mutating func reset()     { count = 0  }
 }
 var c = Counter()
 c.increment()
 c.increment()
 print(c.count)
 // Output: 2
 c.reset()
 print(c.count)
 // Output: 0

 let frozen = Counter()
 // frozen.increment()   // Error — let struct immutable


Q7. Can a class have a memberwise initializer?
-----------------------------------------------
A: No. Only structs automatically get a memberwise
initializer. Classes require you to write init
manually.
Example:
 struct Point2 { var x: Int; var y: Int }
 let p = Point2(x: 3, y: 4)    // auto memberwise
 print(p.x)
 // Output: 3

 class PointC { var x: Int; var y: Int
     init(x: Int, y: Int) {    // must write manually
         self.x = x; self.y = y
     }
 }
 let pc = PointC(x: 3, y: 4)
 print(pc.x)
 // Output: 3


Q8. What happens to both variables when
you assign a class instance to another?
-------------------------------------------
A: Both variables point to the SAME heap instance.
Changing data through one is visible through both.
Example:
 class Config2 { var debug = false }
 var c1 = Config2()
 var c2 = c1              // same instance
 c2.debug = true
 print(c1.debug)          // sees the change
 // Output: true


Q9. What is deinit and which types support it?
-----------------------------------------------
A: deinit is a method called when a class instance
is about to be freed (RC = 0). Only classes
support it. Structs cannot have deinit.
Example:
 class Resource {
     let id: Int
     init(id: Int) { self.id = id; print("Resource \(id) init") }
     deinit            { print("Resource \(id) deinit") }
 }
 var r: Resource? = Resource(id: 42)
 // Output: Resource 42 init
 r = nil
 // Output: Resource 42 deinit

 // struct NoDeInit { deinit { } }  // Error — not allowed


Q10. When would you choose struct over class?
----------------------------------------------
A: Choose struct when:
- Data should be copied independently
- No inheritance needed
- Thread safety matters
- The type represents simple data
Example:
 struct UserProfile {
     var username: String
     var email:    String
     var score:    Int
 }
 var u1 = UserProfile(username: "alice",
                       email: "alice@x.com", score: 100)
 var u2 = u1              // independent copy — intentional
 u2.username = "bob"
 print(u1.username)       // alice unaffected
 // Output: alice


Q11. What is the difference between
 == and ===?
----------------------------------------------
A: == checks VALUE equality (Equatable protocol).
=== checks REFERENCE identity (same object in memory).
Example:
 class Dog { var name: String
             init(_ n: String) { name = n } }
 extension Dog: Equatable {
     static func == (l: Dog, r: Dog) -> Bool {
         l.name == r.name
     }
 }
 let d1 = Dog("Rex")
 let d2 = d1
 let d3 = Dog("Rex")

 print(d1 == d3)     // same value
 // Output: true
 print(d1 === d3)    // different instance
 // Output: false
 print(d1 === d2)    // same instance
 // Output: true


Q12. Can struct methods modify properties
 without mutating?
----------------------------------------------
A: No. Any method that modifies a stored property
MUST be marked mutating. Without it, you get
a compile error.
Example:
 struct Wallet {
     var balance: Double = 0

     // func deposit(_ amount: Double) {
     //     balance += amount   // Error — needs mutating
     // }

     mutating func deposit(_ amount: Double) {
         balance += amount
     }
 }
 var w = Wallet()
 w.deposit(100)
 print(w.balance)
 // Output: 100.0


Q13. What is the difference between static
 and class for type properties/methods?
----------------------------------------------
A: static — applies to both struct and class.
        Cannot be overridden by subclasses.
class   — only in classes.
         CAN be overridden by subclasses.
Example:
 class Base {
     static var staticProp = "Base static"
     class  var classProp  = "Base class"
 }
 class Sub: Base {
     // override static var staticProp = "..."  // Error
     override class var classProp = "Sub class"  // OK
 }
 print(Base.staticProp)
 // Output: Base static
 print(Base.classProp)
 // Output: Base class
 print(Sub.classProp)
 // Output: Sub class


Q14. Can two struct variables ever be
 identical (===)?
----------------------------------------------
A: No. Structs are value types with no identity.
The === operator is not available for structs.
Each struct variable holds its own independent copy.
Example:
 struct S2 { var n: Int }
 var s1 = S2(n: 1)
 var s2 = s1
 // s1 === s2   // Error: operator not defined for struct
 // Use == instead (with Equatable):
 extension S2: Equatable {}
 print(s1 == s2)
 // Output: true


Q15. What is a convenience initializer?
-----------------------------------------
A: A secondary initializer in a class that calls
the designated (primary) initializer.
Simplifies object creation with default values.
Only available in classes.
Example:
 class Server {
     let host:    String
     let port:    Int
     let secure:  Bool

     init(host: String, port: Int, secure: Bool) {
         self.host   = host
         self.port   = port
         self.secure = secure
     }
     convenience init(host: String) {
         self.init(host: host, port: 443, secure: true)
     }
     convenience init() {
         self.init(host: "localhost")
     }
 }
 let s1 = Server()
 print(s1.host, s1.port, s1.secure)
 // Output: localhost 443 true
 let s2 = Server(host: "api.example.com")
 print(s2.host, s2.port, s2.secure)
 // Output: api.example.com 443 true


================================================================
SECTION 2 — INTERMEDIATE LEVEL
================================================================

Q16. What is Copy-on-Write and does it apply
 to structs by default?
----------------------------------------------
A: COW is an optimization where value types delay
copying until mutation. It applies automatically
to Swift's built-in types (Array, Dictionary, String).
Your custom structs do NOT get COW automatically —
you must implement it manually using a class
as the backing store.
Example:
 var arr1 = [1, 2, 3]
 var arr2 = arr1       // shared storage — no copy yet
 arr2.append(4)        // copy happens NOW
 print(arr1)
 // Output: [1, 2, 3]
 print(arr2)
 // Output: [1, 2, 3, 4]

 // Custom struct — NOT COW by default:
 struct MyData { var values: [Int] }
 var d1 = MyData(values: [1, 2, 3])
 var d2 = d1           // FULL copy of struct immediately


Q17. How does a struct with a class property
 behave during assignment?
----------------------------------------------
A: The struct itself is copied (value type behavior).
But the class property is a reference — both
struct copies share the SAME class instance.
This is called a shallow copy.
Example:
 class Engine3 { var hp: Int; init(_ hp: Int) { self.hp = hp } }
 struct Bike  { var model: String; var engine: Engine3 }

 var b1 = Bike(model: "X", engine: Engine3(200))
 var b2 = b1               // struct copied — engine ref shared

 b2.model      = "Y"       // String is value — b1 unchanged
 b2.engine.hp  = 999       // Engine3 is reference — SHARED

 print(b1.model)           // struct field — independent copy
 // Output: X
 print(b1.engine.hp)       // class ref — shared, sees change
 // Output: 999


Q18. What is a designated initializer?
-----------------------------------------
A: The primary initializer of a class that sets
ALL stored properties. Every class must have at
least one. Subclasses must call super's designated
init in their own designated init.
Example:
 class Product {
     var name:  String
     var price: Double
     var stock: Int

     // Designated — initializes all stored props:
     init(name: String, price: Double, stock: Int) {
         self.name  = name
         self.price = price
         self.stock = stock
         print("Product \(name) created")
     }

     // Convenience — delegates to designated:
     convenience init(name: String, price: Double) {
         self.init(name: name, price: price, stock: 0)
     }
 }
 class DigitalProduct: Product {
     var downloadUrl: String
     // Designated — calls super designated:
     init(name: String, price: Double, url: String) {
         self.downloadUrl = url
         super.init(name: name, price: price, stock: 999)
     }
 }
 let dp = DigitalProduct(name: "App", price: 4.99,
                          url: "https://dl.example.com")
 // Output: Product App created
 print(dp.downloadUrl)
 // Output: https://dl.example.com


Q19. How does polymorphism work with classes?
----------------------------------------------
A: Subclass instances can be used where superclass
type is expected. The correct overridden method
is called at runtime (dynamic dispatch).
Example:
 class Shape2 {
     func area() -> Double { return 0 }
     func describe() { print("Shape: area=\(area())") }
 }
 class Circle3: Shape2 {
     var radius: Double
     init(r: Double) { self.radius = r }
     override func area() -> Double {
         return Double.pi * radius * radius
     }
 }
 class Rect2: Shape2 {
     var w, h: Double
     init(w: Double, h: Double) { self.w=w; self.h=h }
     override func area() -> Double { return w * h }
 }

 let shapes: [Shape2] = [
     Circle3(r: 5), Rect2(w: 4, h: 3), Circle3(r: 2)
 ]
 for s in shapes { s.describe() }
 // Output: Shape: area=78.53981633974483
 //         Shape: area=12.0
 //         Shape: area=12.566370614359172


Q20. What is the difference between
 override and final override?
----------------------------------------------
A: override — subclass provides its own implementation
          of a superclass method/property.
final override — overrides and PREVENTS further
                overriding in sub-subclasses.
Example:
 class A { func greet() { print("Hello from A") } }
 class B: A {
     override func greet() { print("Hello from B") }
 }
 class C: B {
     final override func greet() { print("Hello from C") }
 }
 class D: C {
     // override func greet() { }  // Error — final in C
 }
 let objects: [A] = [A(), B(), C()]
 for o in objects { o.greet() }
 // Output: Hello from A
 //         Hello from B
 //         Hello from C


Q21. How do you make a struct Comparable?
-------------------------------------------
A: Conform to Comparable and implement < operator.
Swift derives >, <=, >= from < automatically.
Example:
 struct Version: Comparable {
     var major: Int
     var minor: Int
     var patch: Int

     static func < (lhs: Version, rhs: Version) -> Bool {
         if lhs.major != rhs.major { return lhs.major < rhs.major }
         if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
         return lhs.patch < rhs.patch
     }
 }
 extension Version: CustomStringConvertible {
     var description: String { "\(major).\(minor).\(patch)" }
 }

 let versions = [
     Version(major: 2, minor: 0, patch: 0),
     Version(major: 1, minor: 9, patch: 3),
     Version(major: 2, minor: 1, patch: 0),
     Version(major: 1, minor: 0, patch: 0)
 ]
 let sorted2 = versions.sorted()
 for v in sorted2 { print(v) }
 // Output: 1.0.0
 //         1.9.3
 //         2.0.0
 //         2.1.0

 print(versions[0] > versions[1])
 // Output: true


Q22. How do you use type casting with
 a class hierarchy?
----------------------------------------------
A: Use is for type checking, as? for safe downcast,
as! for forced downcast (crash if wrong type).
Example:
 class Media    { var title: String; init(_ t: String) { title = t } }
 class Film: Media { var director: String
                    init(_ t: String, _ d: String) {
                        director = d; super.init(t) } }
 class Music: Media { var artist: String
                     init(_ t: String, _ a: String) {
                         artist = a; super.init(t) } }

 let items: [Media] = [
     Film("Inception", "Nolan"),
     Music("Purple Rain", "Prince"),
     Film("Matrix", "Wachowski")
 ]
 for item in items {
     if item is Film {
         print("\(item.title) is a film")
     }
 }
 // Output: Inception is a film
 //         Matrix is a film

 for item in items {
     if let film = item as? Film {
         print("Director: \(film.director)")
     } else if let music = item as? Music {
         print("Artist: \(music.artist)")
     }
 }
 // Output: Director: Nolan
 //         Artist: Prince
 //         Director: Wachowski


Q23. Can a struct conform to a class-only protocol?
-----------------------------------------------------
A: No. A class-only protocol (AnyObject or @objc)
can only be conformed to by classes.
This is how delegates are made weak-reference safe.
Example:
 protocol ClassOnly: AnyObject {
     func doWork()
 }
 class Worker: ClassOnly {    // OK — class
     func doWork() { print("Working") }
 }
 // struct SWorker: ClassOnly { // Error — struct not allowed
 //     func doWork() { }
 // }
 weak var worker: ClassOnly?  // weak allowed — AnyObject
 worker = Worker()
 worker?.doWork()
 // Output: Working


Q24. What happens to the reference count
 when a class instance is passed to
 a function?
----------------------------------------------
A: The parameter is a strong reference — RC increases
by 1 for the duration of the function call.
When the function returns, RC decreases by 1.
Example:
 class Packet {
     let id: Int
     init(id: Int) {
         self.id = id
         print("Packet \(id) created — RC=1")
     }
     deinit { print("Packet \(id) freed — RC=0") }
 }

 func process(_ pkt: Packet) {
     // pkt is a strong ref — RC=2 inside here
     print("Processing packet \(pkt.id) — RC=2")
 }   // pkt released — RC back to 1

 var p2: Packet? = Packet(id: 99)
 // Output: Packet 99 created — RC=1
 process(p2!)
 // Output: Processing packet 99 — RC=2
 p2 = nil
 // Output: Packet 99 freed — RC=0


Q25. What is the difference between
 value semantics and reference semantics?
----------------------------------------------
A: Value semantics — each variable has its own
independent copy. Changes are isolated.
(Struct, enum, Int, String, Array)
Reference semantics — variables share one instance.
Changes affect all references.
(Class, closure, actor)
Example:
 // Value semantics:
 var a = [1, 2, 3]
 var b = a           // copy
 b.append(4)
 print(a)            // unchanged
 // Output: [1, 2, 3]

 // Reference semantics:
 class Bag { var items = [1, 2, 3] }
 var bag1 = Bag()
 var bag2 = bag1     // shared
 bag2.items.append(4)
 print(bag1.items)   // changed
 // Output: [1, 2, 3, 4]


Q26. How do you implement Equatable on a class?
-------------------------------------------------
A: Conform to Equatable and implement ==.
You choose what "equal" means — often by value,
sometimes by identity (===).
Example:
 class Invoice: Equatable {
     let invoiceId: String
     var amount:    Double

     init(id: String, amount: Double) {
         self.invoiceId = id
         self.amount    = amount
     }

     // Equal if same invoiceId:
     static func == (lhs: Invoice, rhs: Invoice) -> Bool {
         return lhs.invoiceId == rhs.invoiceId
     }
 }
 let inv1 = Invoice(id: "INV-001", amount: 500)
 let inv2 = Invoice(id: "INV-001", amount: 999)  // same id
 let inv3 = Invoice(id: "INV-002", amount: 500)

 print(inv1 == inv2)   // same id — equal
 // Output: true
 print(inv1 == inv3)   // different id
 // Output: false
 print(inv1 === inv2)  // different objects
 // Output: false


================================================================
SECTION 3 — ADVANCED LEVEL
================================================================

Q27. What is the difference between
 static dispatch and dynamic dispatch?
----------------------------------------------
A: Static dispatch — compiler knows exact method to
call at compile time. Faster. Used for structs,
final classes, and non-overridable methods.
Dynamic dispatch — method resolved at runtime via
vtable. Slower. Used for open/non-final class methods.
Example:
 // Static dispatch — struct method:
 struct FastCalc {
     func square(_ n: Int) -> Int { n * n }  // static
 }
 let fc = FastCalc()
 print(fc.square(7))
 // Output: 49

 // Dynamic dispatch — class method (vtable lookup):
 class SlowCalc {
     func square(_ n: Int) -> Int { n * n }
 }
 class SpecialCalc: SlowCalc {
     override func square(_ n: Int) -> Int { n * n + 1 }
 }
 var calc: SlowCalc = SpecialCalc()
 print(calc.square(7))  // resolved at runtime
 // Output: 50

 // Force static on class with final:
 final class OptCalc {
     func square(_ n: Int) -> Int { n * n }  // now static
 }


Q28. How do you implement a value-type
 linked list using indirect enum?
----------------------------------------------
A: Use indirect enum — allows a case to reference
the enum itself. Each node is a value type but
the recursive reference is boxed on the heap.
Example:
 indirect enum LinkedList2<T> {
     case empty
     case node(value: T, next: LinkedList2<T>)

     func prepend(_ value: T) -> LinkedList2<T> {
         return .node(value: value, next: self)
     }

     var count: Int {
         switch self {
         case .empty:           return 0
         case .node(_, let n): return 1 + n.count
         }
     }

     func toArray() -> [T] {
         switch self {
         case .empty:              return []
         case .node(let v, let n): return [v] + n.toArray()
         }
     }
 }

 let list2 = LinkedList2<Int>.empty
     .prepend(3)
     .prepend(2)
     .prepend(1)

 print(list2.toArray())
 // Output: [1, 2, 3]
 print(list2.count)
 // Output: 3


Q29. What is protocol-oriented programming
 and how does it relate to structs?
----------------------------------------------
A: Protocol-oriented programming (POP) uses protocols
and protocol extensions to share behavior
without class inheritance. Structs are the
preferred building block in POP because:
- They cannot inherit (cleaner design)
- They are thread-safe
- They have value semantics
- Protocol extensions add shared implementation
Example:
 protocol Geometric {
     var area:      Double { get }
     var perimeter: Double { get }
 }
 extension Geometric {
     // Shared default implementation:
     func describe() {
         print(String(format:
             "Area: %.2f, Perimeter: %.2f",
             area, perimeter))
     }
     var isLarge: Bool { area > 100 }
 }

 struct Circle4: Geometric {
     var radius: Double
     var area:      Double { Double.pi * radius * radius }
     var perimeter: Double { 2 * Double.pi * radius }
 }
 struct Rect3: Geometric {
     var width, height: Double
     var area:      Double { width * height }
     var perimeter: Double { 2 * (width + height) }
 }

 let shapes2: [any Geometric] = [
     Circle4(radius: 6),
     Rect3(width: 12, height: 9)
 ]
 for s in shapes2 {
     s.describe()
     print("Large: \(s.isLarge)")
 }
 // Output: Area: 113.10, Perimeter: 37.70
 //         Large: true
 //         Area: 108.00, Perimeter: 42.00
 //         Large: true


Q30. How do you make a class thread-safe
 using actor?
----------------------------------------------
A: Replace class with actor. The actor serializes
access to its mutable state automatically.
All mutations and reads are protected by the
actor's executor.
Example:
 actor SafeInventory {
     private var stock: [String: Int] = [:]

     func add(product: String, quantity: Int) {
         stock[product, default: 0] += quantity
         print("Added \(quantity) of \(product)")
     }

     func remove(product: String, quantity: Int) -> Bool {
         guard let current = stock[product],
               current >= quantity else {
             print("Insufficient stock for \(product)")
             return false
         }
         stock[product] = current - quantity
         return true
     }

     func quantity(for product: String) -> Int {
         return stock[product] ?? 0
     }
 }

 Task {
     let inv = SafeInventory()
     await inv.add(product: "Widget", quantity: 100)
     // Output: Added 100 of Widget
     let ok = await inv.remove(product: "Widget", quantity: 30)
     print("Removed: \(ok)")
     // Output: Removed: true
     let qty = await inv.quantity(for: "Widget")
     print("Stock: \(qty)")
     // Output: Stock: 70
 }


Q31. What is the difference between
 final class and struct for performance?
----------------------------------------------
A: final class:
- Heap allocated — ARC overhead
- Static dispatch (no vtable) — fast method calls
- Shared — no copying cost
- One allocation per creation

struct:
- Stack allocated — no ARC overhead
- Static dispatch — fast method calls
- Copied on assignment — potential copy cost
- Each copy is independent

Use struct for small, frequently copied data.
Use final class for large objects that are
shared and rarely copied.
Example:
 struct TinyPoint { var x, y: Double }      // stack — no ARC
 final class BigGraph {                      // heap — ARC
     var nodes: [TinyPoint]                  // array of structs
     var edges: [(Int, Int)]
     init() { nodes = []; edges = [] }
     func addNode(_ p: TinyPoint) { nodes.append(p) }
 }

 var graph: BigGraph? = BigGraph()
 graph!.addNode(TinyPoint(x: 1, y: 2))
 graph!.addNode(TinyPoint(x: 3, y: 4))
 print(graph!.nodes.count)
 // Output: 2
 graph = nil   // ARC frees BigGraph


Q32. How does type(of:) work with
 structs and classes?
----------------------------------------------
A: type(of:) returns the dynamic (runtime) type
of any value. For classes it returns the actual
subclass type even through a superclass variable.
For structs it always returns the struct type.
Example:
 class Base3  { var name = "Base"  }
 class Child3: Base3 { override var name: String { "Child" } }
 struct Plain { var n = 0 }

 let b3: Base3 = Child3()         // polymorphic
 print(type(of: b3))
 // Output: Child3                  (dynamic type)
 print(type(of: b3) == Base3.self)
 // Output: false
 print(type(of: b3) == Child3.self)
 // Output: true

 let plain = Plain()
 print(type(of: plain))
 // Output: Plain

 // Use for factory patterns:
 func describe2(_ obj: AnyObject) {
     print("Type: \(type(of: obj))")
 }
 describe2(Child3())
 // Output: Type: Child3


Q33. How does Self work in structs and classes?
------------------------------------------------
A: Self refers to the conforming type at compile time.
In a struct, Self is always the exact struct type.
In a class, Self can be a subclass type at runtime.
Example:
 protocol Cloneable {
     func clone() -> Self
 }
 struct Blueprint: Cloneable {
     var version: Int
     func clone() -> Blueprint {    // Self = Blueprint
         return Blueprint(version: version)
     }
 }
 var b4 = Blueprint(version: 1)
 var b5 = b4.clone()
 b5.version = 2
 print(b4.version)
 // Output: 1
 print(b5.version)
 // Output: 2

 class Template: Cloneable {
     var name: String
     required init(name: String) { self.name = name }
     func clone() -> Self {         // Self = actual subclass
         return type(of: self).init(name: name)
     }
 }
 class SpecialTemplate: Template {}
 let t1 = SpecialTemplate(name: "Alpha")
 let t2 = t1.clone()
 print(type(of: t2))
 // Output: SpecialTemplate         (Self resolved correctly)


Q34. How do you implement the Observer
 pattern with structs and weak references?
----------------------------------------------
A: Observers should be classes (for weak refs).
The observable subject can be a struct or class.
Use a weak wrapper to avoid retain cycles in
the observer list.
Example:
 protocol EventObserver: AnyObject {
     func onEvent(_ event: String)
 }

 struct WeakObserver {
     weak var ref: EventObserver?
 }

 class EventEmitter {
     private var observers: [WeakObserver] = []

     func subscribe(_ obs: EventObserver) {
         observers.append(WeakObserver(ref: obs))
     }

     func emit(_ event: String) {
         observers = observers.filter { $0.ref != nil }
         observers.forEach { $0.ref?.onEvent(event) }
     }
 }

 class Logger2: EventObserver {
     let tag: String
     init(tag: String) { self.tag = tag }
     func onEvent(_ event: String) {
         print("[\(tag)] Event: \(event)")
     }
     deinit { print("Logger2 \(tag) freed") }
 }

 let emitter = EventEmitter()
 var logA: Logger2? = Logger2(tag: "A")
 var logB: Logger2? = Logger2(tag: "B")

 emitter.subscribe(logA!)
 emitter.subscribe(logB!)
 emitter.emit("login")
 // Output: [A] Event: login
 //         [B] Event: login

 logA = nil
 // Output: Logger2 A freed

 emitter.emit("logout")   // logA auto-removed (weak = nil)
 // Output: [B] Event: logout


Q35. How does Sendable relate to
 struct and class in concurrency?
----------------------------------------------
A: Sendable marks types safe to transfer between
concurrent contexts (actors, tasks).
Structs with Sendable properties are automatically
Sendable (compiler verifies).
Classes must be explicitly Sendable and proven
safe (e.g., immutable or internally synchronized).
Example:
 // Struct — auto Sendable if all props are Sendable:
 struct SafeMessage: Sendable {
     let from:    String
     let content: String
     let timestamp: Double
 }

 // Class must be carefully marked:
 final class ImmutableConfig: Sendable {
     let apiKey:  String
     let baseURL: String
     init(key: String, url: String) {
         apiKey  = key
         baseURL = url
     }
 }

 // Mutable class — NOT safely Sendable:
 // class MutableState: Sendable {  // Warning/Error
 //     var count = 0               // mutable — unsafe
 // }

 actor MessageBus {
     func send(_ msg: SafeMessage) {
         print("From \(msg.from): \(msg.content)")
     }
 }

 Task {
     let bus = MessageBus()
     let msg = SafeMessage(from: "Alice",
                            content: "Hello",
                            timestamp: 1000.0)
     await bus.send(msg)
     // Output: From Alice: Hello
 }


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q36. Explain the memory layout difference
 between struct and class instances.
----------------------------------------------
A: Struct — stored inline on the stack (usually).
        No header. No heap allocation.
        Size = sum of stored properties + padding.

Class — stored on the heap.
       Header contains:
         [0-7]  isa pointer (type metadata)
         [8-15] reference count
       Then stored properties follow.
       Variable on stack holds 8-byte pointer to heap.

Example:
 struct SLayout {
     var a: Int    // 8 bytes
     var b: Double // 8 bytes
     var c: Bool   // 1 byte
 }
 // Stack: [a:8][b:8][c:1][pad:7] = 24 bytes inline

 class CLayout {
     var a: Int    = 0   // stored on heap
     var b: Double = 0.0
     var c: Bool   = false
 }
 // Stack variable: 8-byte pointer to heap object
 // Heap object: [isa:8][RC:8][a:8][b:8][c:1][pad:7]

 print(MemoryLayout<SLayout>.size)
 // Output: 17    (compiler may show actual bytes)
 print(MemoryLayout<SLayout>.stride)
 // Output: 24    (aligned size)
 print(MemoryLayout<CLayout>.size)
 // Output: 8     (size of the pointer)


Q37. How does Swift resolve method calls
 for protocol conformance on struct vs class?
----------------------------------------------
A: Struct conformance — protocol witness table (PWT).
Swift looks up the method via the PWT at compile
or link time. Generally static (fast).

Class conformance — virtual dispatch table (vtable)
for class methods; PWT for protocol requirements.
Dynamic resolution at runtime (slower).

Generics with constraints use static dispatch —
the compiler specializes the code for the exact type.
Example:
 protocol Greetable { func greet() -> String }

 struct StructGreeter: Greetable {
     func greet() -> String { "Hello from struct" }
     // Resolved via PWT — potentially inlined
 }
 class ClassGreeter: Greetable {
     func greet() -> String { "Hello from class" }
     // Resolved via vtable — dynamic dispatch
 }

 // Generic — statically dispatched (monomorphized):
 func printGreeting<T: Greetable>(_ g: T) {
     print(g.greet())
 }
 printGreeting(StructGreeter())
 // Output: Hello from struct    (static — fast)
 printGreeting(ClassGreeter())
 // Output: Hello from class     (still static in generic)

 // Existential — dynamic dispatch:
 func printGreeting2(_ g: any Greetable) {
     print(g.greet())            // PWT lookup at runtime
 }
 printGreeting2(StructGreeter())
 // Output: Hello from struct
 printGreeting2(ClassGreeter())
 // Output: Hello from class


Q38. What is an existential container and
 how does it affect struct performance?
----------------------------------------------
A: When a struct is stored as a protocol type
(any Protocol), Swift wraps it in an
"existential container":
- 3 pointer-sized words (24 bytes) as inline buffer
 for small values (fits without heap allocation)
- If struct is larger, extra heap allocation needed
- 1 word for value witness table (VWT)
- 1 word for protocol witness table (PWT)
This adds overhead vs generics (which are monomorphized).
Example:
 protocol Area2 { var area: Double { get } }

 struct SmallRect: Area2 {
     var w, h: Double                // 16 bytes — fits inline
     var area: Double { w * h }
 }

 struct LargePolygon: Area2 {
     var pts: [(Double,Double,Double)] // large — heap needed
     var area: Double { Double(pts.count) * 0.5 }
 }

 // Existential — boxing overhead for LargePolygon:
 var shapes3: [any Area2] = [
     SmallRect(w: 3, h: 4),          // inline (fits in buffer)
     LargePolygon(pts: [(1,2,3),(4,5,6),(7,8,9)])  // heap
 ]
 for s in shapes3 { print(s.area) }
 // Output: 12.0
 //         1.5

 // Generic — no boxing, monomorphized:
 func totalArea<T: Area2>(_ shapes: [T]) -> Double {
     shapes.reduce(0) { $0 + $1.area }
 }
 let rects = [SmallRect(w:1,h:2), SmallRect(w:3,h:4)]
 print(totalArea(rects))
 // Output: 14.0        (no existential boxing)


Q39. How do you implement a type-erased
 wrapper for a generic struct?
----------------------------------------------
A: Type erasure wraps a concrete generic type behind
a non-generic interface. Useful when you need
to store heterogeneous values conforming to a
protocol with associated types (like Combine's
AnyPublisher).
Example:
 protocol Transformer {
     associatedtype Input
     associatedtype Output
     func transform(_ input: Input) -> Output
 }

 // Type-erased wrapper:
 struct AnyTransformer<I, O> {
     private let _transform: (I) -> O

     init<T: Transformer>(_ t: T)
         where T.Input == I, T.Output == O {
         _transform = t.transform
     }

     func transform(_ input: I) -> O {
         return _transform(input)
     }
 }

 struct Doubler: Transformer {
     func transform(_ input: Int) -> Int { input * 2 }
 }

 struct Stringify: Transformer {
     func transform(_ input: Int) -> String {
         return "Value: \(input)"
     }
 }

 // Heterogeneous storage now possible:
 let doublerErased = AnyTransformer(Doubler())
 let stringifyErased = AnyTransformer(Stringify())

 print(doublerErased.transform(21))
 // Output: 42
 print(stringifyErased.transform(99))
 // Output: Value: 99

 // Can store in array:
 let intTransformers: [AnyTransformer<Int, Int>] = [
     AnyTransformer(Doubler()),
     AnyTransformer(Doubler())
 ]
 print(intTransformers.map { $0.transform(5) })
 // Output: [10, 10]


Q40. How do you implement a class with
 value semantics (copy-on-write class)?
----------------------------------------------
A: Wrap all mutable state in a private inner class.
Use isKnownUniquelyReferenced to copy only when
the storage is shared. This gives the class
value semantics (copies on mutation).
Example:
 private class _PersonData {
     var name:  String
     var age:   Int
     var email: String
     init(name: String, age: Int, email: String) {
         self.name  = name
         self.age   = age
         self.email = email
     }
     init(copying d: _PersonData) {
         name  = d.name
         age   = d.age
         email = d.email
         print("_PersonData COPIED")
     }
 }

 struct PersonValue {
     private var data: _PersonData

     init(name: String, age: Int, email: String) {
         data = _PersonData(name: name, age: age, email: email)
     }

     private mutating func ensureUnique() {
         if !isKnownUniquelyReferenced(&data) {
             data = _PersonData(copying: data)
         }
     }

     var name: String {
         get { data.name }
         set { ensureUnique(); data.name = newValue }
     }
     var age: Int {
         get { data.age }
         set { ensureUnique(); data.age = newValue }
     }
     var email: String {
         get { data.email }
         set { ensureUnique(); data.email = newValue }
     }
 }

 var pv1 = PersonValue(name: "Alice", age: 28,
                        email: "alice@x.com")
 var pv2 = pv1          // shared storage — no copy
 print(pv1.name)
 // Output: Alice
 pv2.name = "Bob"       // mutation — copy triggered
 // Output: _PersonData COPIED
 print(pv1.name)        // unchanged
 // Output: Alice
 print(pv2.name)
 // Output: Bob


================================================================
PART 11 — COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

STRUCT — VALUE TYPE
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Define                             | struct Name { var prop: Type }
Assignment                         | Copies data — independent
ARC overhead                       | None — stack allocated
Mutation in method                 | mutating func change() { }
let struct                         | ALL properties immutable
var struct                         | Properties can mutate
Inheritance                        | Not supported — use protocols
Auto memberwise init               | Yes — if no custom init in body
Custom init + memberwise           | Put custom init in extension
Static member                      | static var/func — not overridable
Type property shared across all    | static var count = 0
deinit                             | Not available
Protocol conformance               | Yes
Thread safety                      | Yes — each copy independent
When to use                        | Simple data, models, configs, thread safety

CLASS — REFERENCE TYPE
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Define                             | class Name { var prop: Type }
Assignment                         | Shares reference — same instance
ARC overhead                       | Yes — retain/release on heap
let class                          | Reference constant — props still mutable
Inheritance                        | Single inheritance supported
Memberwise init                    | NOT auto-generated — write manually
Designated init                    | Primary init — initializes all props
Convenience init                   | Delegates to designated init
Required init                      | required init — must be in all subclasses
Override method                    | override func method()
Prevent override                   | final func method() or final class
Static member (not overridable)    | static var/func
Type member (overridable)          | class var/func
deinit                             | Available — cleanup on dealloc
Thread safety                      | Not by default — use actor or locks
When to use                        | Shared state, identity, inheritance, resources

IDENTITY OPERATORS
Task                               | Code / Fact
-----------------------------------|------------------------------------------
Same instance check                | ref1 === ref2  → Bool
Different instance check           | ref1 !== ref2  → Bool
Works with                         | Class instances only
Does NOT work with                 | Struct, enum, tuple, Int, String
vs equality                        | === is identity; == is value equality
nil === nil                        | true
Optional identity                  | var? === var?  works correctly
Common use case                    | Delegate check, deduplication, cache lookup

STRUCT vs CLASS DECISION
Scenario                           | Use
-----------------------------------|------------------------------------------
Simple data model                  | struct
Independent copies needed          | struct
Thread safety required             | struct (or actor)
No inheritance needed              | struct
Shared mutable state               | class
Identity matters                   | class
Lifecycle management (deinit)      | class
Objective-C interop                | class
External resource management       | class
Polymorphism via inheritance       | class
Polymorphism via protocol          | struct preferred

INITIALIZER TYPES
Type                               | Where           | Note
-----------------------------------|-----------------|----------------------------
Memberwise                         | struct only     | Auto-generated
Designated                         | class           | Primary — inits all props
Convenience                        | class           | Delegates to designated
Required                           | class           | Subclasses must implement
Default                            | struct & class  | Only if all props have defaults
Failable (init?)                   | struct & class  | Returns nil on failure
Throwing (init throws)             | struct & class  | Throws on failure

METHODS AND PROPERTIES
Task                               | Struct                | Class
-----------------------------------|------------------------|------------------
Instance method                    | func f()              | func f()
Mutating method                    | mutating func f()     | func f() (not needed)
Static method                      | static func f()       | static func f()
Overridable type method            | N/A                   | class func f()
Stored property                    | var/let prop          | var/let prop
Computed property                  | var prop: T { get }   | var prop: T { get }
Lazy property                      | lazy var prop         | lazy var prop
Property observer                  | willSet / didSet      | willSet / didSet
Type property                      | static var            | static var / class var

EQUATABLE AND COMPARABLE
Task                               | Struct                | Class
-----------------------------------|------------------------|------------------
Auto Equatable                     | Yes (all props Equatable) | No — manual only
Auto Hashable                      | Yes (all props Hashable)  | No — manual only
Auto Comparable                    | No — implement <      | No — implement <
Custom ==                          | static func ==        | static func ==
Identity Equatable                 | N/A (no ===)          | return lhs === rhs

CASTING AND TYPE CHECKING
Task                               | Code
-----------------------------------|------------------------------------------
Check type                         | obj is SomeClass
Safe downcast                      | obj as? SubClass
Forced downcast                    | obj as! SubClass  (crash if wrong)
Upcast                             | subObj as SuperClass
Get dynamic type                   | type(of: obj)
Pattern match in switch            | case let x as SubClass:
Pattern + condition                | case let x as SubClass where x.prop > 0:

GENERICS WITH CUSTOM TYPES
Task                               | Code
-----------------------------------|------------------------------------------
Generic struct                     | struct Box<T> { var value: T }
Generic class                      | class Cache<K: Hashable, V> { }
Generic with constraint            | struct SortedArray<T: Comparable>
Generic function                   | func swap<T>(_ a: inout T, _ b: inout T)
Associated type protocol           | protocol Container { associatedtype Element }
Type erasure                       | struct AnyContainer<T> wrapping protocol

 */
