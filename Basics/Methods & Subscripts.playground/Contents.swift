import UIKit

/*
 METHODS & SUBSCRIPTS IN SWIFT
 ===========================================================
 INSTANCE METHODS, TYPE METHODS,
 CUSTOM SUBSCRIPTING LOGIC
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — METHODS FUNDAMENTALS
 ================================================================

 WHAT IS A METHOD?
 ==================
 A method is a function that belongs to a specific type
 (class, struct, or enum). Methods have access to the
 instance (or type) they belong to via self.
 They encapsulate behavior alongside the data it operates on.

 METHODS vs FUNCTIONS
 =====================
   Functions  — standalone, no associated type
   Methods    — attached to a type, access self
   Both       — same syntax, same first-class citizen status

 THREE KINDS OF METHODS
 =======================
   1. Instance methods  — called on an instance:  obj.method()
   2. Type methods      — called on the type itself: Type.method()
   3. Mutating methods  — instance methods that modify
                          value type (struct/enum) self

 METHOD ANATOMY
 ===============
   struct MyType {
       var value: Int

       // Instance method — has access to self:
       func describe() -> String {
           return "Value is \(value)"    // implicit self.value
       }

       // Mutating — modifies self:
       mutating func double() {
           value *= 2                    // self.value *= 2
       }

       // Static (type) method:
       static func create(with n: Int) -> MyType {
           return MyType(value: n)
       }
   }

   var mt = MyType(value: 5)
   print(mt.describe())
   // Output: Value is 5
   mt.double()
   print(mt.value)
   // Output: 10
   let mt2 = MyType.create(with: 42)
   print(mt2.describe())
   // Output: Value is 42

 IMPLICIT self
 ==============
   struct Circle {
       var radius: Double

       // Swift injects self — you can omit it:
       func area() -> Double {
           return Double.pi * radius * radius     // self.radius
       }
       func circumference() -> Double {
           return 2 * Double.pi * radius
       }
       func isLargerThan(_ other: Circle) -> Bool {
           return radius > other.radius           // self.radius
       }
   }

   let c1 = Circle(radius: 5)
   let c2 = Circle(radius: 3)
   print(c1.area())
   // Output: 78.53981633974483
   print(c1.circumference())
   // Output: 31.41592653589793
   print(c1.isLargerThan(c2))
   // Output: true

 EXPLICIT self — WHEN REQUIRED
 ================================
   struct Player {
       var name: String
       var score: Int

       // When parameter name shadows property — self required:
       init(name: String, score: Int) {
           self.name  = name     // self. required — shadows param
           self.score = score
       }

       // Optional: self for clarity:
       func greet() -> String {
           return "Hi, I'm \(self.name) with score \(self.score)"
       }
   }

   let p = Player(name: "Alice", score: 100)
   print(p.greet())
   // Output: Hi, I'm Alice with score 100


 ================================================================
 PART 2 — INSTANCE METHODS IN DEPTH
 ================================================================

 INSTANCE METHODS — STRUCTS
 ============================
   struct Rectangle {
       var width:  Double
       var height: Double

       // Read-only instance methods:
       func area()      -> Double { width * height }
       func perimeter() -> Double { 2 * (width + height) }
       func diagonal()  -> Double { (width*width + height*height).squareRoot() }
       func isSquare()  -> Bool   { width == height }

       func scaled(by factor: Double) -> Rectangle {
           return Rectangle(width: width * factor,
                            height: height * factor)
       }

       func fits(inside other: Rectangle) -> Bool {
           return width <= other.width && height <= other.height
       }

       // Mutating instance methods:
       mutating func scale(by factor: Double) {
           width  *= factor
           height *= factor
       }

       mutating func rotate() {
           swap(&width, &height)
       }

       mutating func expand(by amount: Double) {
           width  += amount
           height += amount
       }
   }

   var rect = Rectangle(width: 4, height: 6)
   print(rect.area())
   // Output: 24.0
   print(rect.perimeter())
   // Output: 20.0
   print(rect.diagonal())
   // Output: 7.211102550927978
   print(rect.isSquare())
   // Output: false

   let bigger = rect.scaled(by: 2)
   print(bigger.area())
   // Output: 96.0
   print(rect.area())
   // Output: 24.0   (original unchanged)

   rect.scale(by: 1.5)
   print(rect.width)
   // Output: 6.0
   print(rect.height)
   // Output: 9.0

   rect.rotate()
   print("\(rect.width) x \(rect.height)")
   // Output: 9.0 x 6.0

 INSTANCE METHODS — CLASSES
 ============================
   class BankAccount {
       private(set) var balance:  Double
       private(set) var owner:    String
       private var transactions: [String] = []

       init(owner: String, initialBalance: Double = 0) {
           self.owner   = owner
           self.balance = initialBalance
       }

       // Modifier methods — no mutating needed (reference type):
       func deposit(_ amount: Double) {
           guard amount > 0 else {
               print("Deposit must be positive")
               return
           }
           balance += amount
           transactions.append("+ $\(amount)")
           print("\(owner) deposited $\(amount). Balance: $\(balance)")
       }

       func withdraw(_ amount: Double) -> Bool {
           guard amount > 0 else {
               print("Withdrawal must be positive")
               return false
           }
           guard balance >= amount else {
               print("Insufficient funds. Balance: $\(balance)")
               return false
           }
           balance -= amount
           transactions.append("- $\(amount)")
           print("\(owner) withdrew $\(amount). Balance: $\(balance)")
           return true
       }

       func transfer(_ amount: Double, to other: BankAccount) {
           if withdraw(amount) {
               other.deposit(amount)
           }
       }

       func printStatement() {
           print("=== Statement for \(owner) ===")
           transactions.forEach { print("  \($0)") }
           print("  Balance: $\(balance)")
       }
   }

   let alice = BankAccount(owner: "Alice", initialBalance: 1000)
   let bob   = BankAccount(owner: "Bob",   initialBalance: 500)

   alice.deposit(200)
   // Output: Alice deposited $200.0. Balance: $1200.0
   alice.withdraw(150)
   // Output: Alice withdrew $150.0. Balance: $1050.0
   alice.transfer(300, to: bob)
   // Output: Alice withdrew $300.0. Balance: $750.0
   //         Bob deposited $300.0. Balance: $800.0
   alice.withdraw(1000)
   // Output: Insufficient funds. Balance: $750.0

   alice.printStatement()
   // Output: === Statement for Alice ===
   //           + $200.0
   //           - $150.0
   //           - $300.0
   //           Balance: $750.0

 INSTANCE METHODS — ENUMS
 ==========================
   enum Direction {
       case north, south, east, west

       func opposite() -> Direction {
           switch self {
           case .north: return .south
           case .south: return .north
           case .east:  return .west
           case .west:  return .east
           }
       }

       func rotatedClockwise() -> Direction {
           switch self {
           case .north: return .east
           case .east:  return .south
           case .south: return .west
           case .west:  return .north
           }
       }

       func steps(to other: Direction) -> Int {
           var current = self
           var count   = 0
           while current != other {
               current = current.rotatedClockwise()
               count  += 1
           }
           return count
       }

       mutating func turnRight()      { self = rotatedClockwise() }
       mutating func turnLeft()       { self = rotatedClockwise()
                                              .rotatedClockwise()
                                              .rotatedClockwise() }
       mutating func turnAround()     { self = opposite() }

       var isVertical:   Bool { self == .north || self == .south }
       var isHorizontal: Bool { self == .east  || self == .west  }
   }

   var heading = Direction.north
   print(heading.opposite())
   // Output: south
   print(heading.steps(to: .west))
   // Output: 3
   heading.turnRight()
   print(heading)
   // Output: east
   heading.turnAround()
   print(heading)
   // Output: west

 METHOD CHAINING
 ================
   // Return Self to enable chaining:
   class QueryBuilder {
       private var table:      String = ""
       private var conditions: [String] = []
       private var columns:    [String] = ["*"]
       private var orderBy:    String?
       private var limitVal:   Int?
       private var offsetVal:  Int?

       func from(_ table: String) -> QueryBuilder {
           self.table = table
           return self
       }

       func select(_ columns: String...) -> QueryBuilder {
           self.columns = columns
           return self
       }

       func `where`(_ condition: String) -> QueryBuilder {
           conditions.append(condition)
           return self
       }

       func order(by column: String) -> QueryBuilder {
           orderBy = column
           return self
       }

       func limit(_ n: Int) -> QueryBuilder {
           limitVal = n
           return self
       }

       func offset(_ n: Int) -> QueryBuilder {
           offsetVal = n
           return self
       }

       func build() -> String {
           var sql  = "SELECT \(columns.joined(separator: ", "))"
           sql     += " FROM \(table)"
           if !conditions.isEmpty {
               sql += " WHERE " + conditions.joined(separator: " AND ")
           }
           if let order = orderBy { sql += " ORDER BY \(order)" }
           if let lim   = limitVal  { sql += " LIMIT \(lim)"  }
           if let off   = offsetVal { sql += " OFFSET \(off)" }
           return sql
       }
   }

   let query = QueryBuilder()
       .from("users")
       .select("id", "name", "email")
       .where("active = true")
       .where("age >= 18")
       .order(by: "name")
       .limit(20)
       .offset(40)
       .build()

   print(query)
   // Output: SELECT id, name, email FROM users
   //         WHERE active = true AND age >= 18
   //         ORDER BY name LIMIT 20 OFFSET 40

 METHOD CHAINING WITH VALUE TYPES
 ==================================
   // Return a modified copy — non-mutating chaining:
   struct TextStyle {
       var fontName:  String  = "Helvetica"
       var fontSize:  Double  = 14
       var bold:      Bool    = false
       var italic:    Bool    = false
       var color:     String  = "#000000"
       var underline: Bool    = false

       func withFont(_ name: String)   -> TextStyle {
           var s = self; s.fontName = name;   return s }
       func withSize(_ size: Double)   -> TextStyle {
           var s = self; s.fontSize = size;   return s }
       func withBold(_ b: Bool = true) -> TextStyle {
           var s = self; s.bold = b;          return s }
       func withItalic(_ i: Bool = true) -> TextStyle {
           var s = self; s.italic = i;        return s }
       func withColor(_ c: String)     -> TextStyle {
           var s = self; s.color = c;         return s }
       func withUnderline(_ u: Bool = true) -> TextStyle {
           var s = self; s.underline = u;     return s }

       var description: String {
           var parts = ["\(fontName) \(fontSize)pt"]
           if bold      { parts.append("bold")      }
           if italic    { parts.append("italic")    }
           if underline { parts.append("underline") }
           parts.append(color)
           return parts.joined(separator: ", ")
       }
   }

   let headingStyle = TextStyle()
       .withFont("SF Pro")
       .withSize(24)
       .withBold()
       .withColor("#1A1A1A")

   let bodyStyle = TextStyle()
       .withFont("Georgia")
       .withSize(16)
       .withColor("#333333")

   let emphasisStyle = bodyStyle
       .withItalic()
       .withColor("#007AFF")

   print(headingStyle.description)
   // Output: SF Pro 24.0pt, bold, #1A1A1A
   print(bodyStyle.description)
   // Output: Georgia 16.0pt, #333333
   print(emphasisStyle.description)
   // Output: Georgia 16.0pt, italic, #007AFF

 METHODS WITH CLOSURES
 ======================
   class EventEmitter {
       private var listeners: [String: [(Any) -> Void]] = [:]

       func on(_ event: String,
                handler: @escaping (Any) -> Void) {
           listeners[event, default: []].append(handler)
       }

       func emit(_ event: String, data: Any = ()) {
           listeners[event]?.forEach { $0(data) }
       }

       func off(_ event: String) {
           listeners.removeValue(forKey: event)
       }

       func once(_ event: String,
                  handler: @escaping (Any) -> Void) {
           // Create a wrapper that removes itself after first call:
           var wrapper: ((Any) -> Void)!
           wrapper = { [weak self] data in
               handler(data)
               self?.off(event)
           }
           on(event, handler: wrapper)
       }
   }

   let emitter = EventEmitter()

   emitter.on("login") { data in
       print("[Auth] Login event: \(data)")
   }
   emitter.on("login") { data in
       print("[Log]  Login logged: \(data)")
   }
   emitter.once("startup") { _ in
       print("[Init] App started — one time only")
   }

   emitter.emit("login", data: "alice@example.com")
   // Output: [Auth] Login event: alice@example.com
   //         [Log]  Login logged: alice@example.com

   emitter.emit("startup")
   // Output: [Init] App started — one time only
   emitter.emit("startup")
   // Output: (nothing — handler removed after first call)

   emitter.emit("login", data: "bob@example.com")
   // Output: [Auth] Login event: bob@example.com
   //         [Log]  Login logged: bob@example.com

 METHODS AS VALUES
 ==================
   struct MathOps {
       var base: Int

       func add(_ n: Int)      -> Int { base + n }
       func multiply(_ n: Int) -> Int { base * n }
       func power(_ n: Int)    -> Int {
           (0..<n).reduce(1) { acc, _ in acc * base }
       }
   }

   let ops = MathOps(base: 3)

   // Bound method references:
   let addThree      = ops.add        // (Int) -> Int
   let multiplyThree = ops.multiply   // (Int) -> Int

   print(addThree(7))
   // Output: 10
   print(multiplyThree(7))
   // Output: 21

   // Store in array:
   let operations: [(Int) -> Int] = [ops.add, ops.multiply, ops.power]
   operations.forEach { print($0(4)) }
   // Output: 7      (3 + 4)
   //         12     (3 * 4)
   //         81     (3 ^ 4)

   // Unbound method reference (curried):
   let unboundAdd = MathOps.add
   // Type: (MathOps) -> (Int) -> Int
   let result = unboundAdd(ops)(5)
   print(result)
   // Output: 8

 METHODS WITH DEFER
 ===================
   class ResourceManager {
       var resources: [String] = []

       func loadResource(named name: String) -> Bool {
           print("Opening \(name)")
           resources.append(name)

           defer {
               // Always runs when function exits — success or failure:
               print("Cleanup: closing \(name)")
               resources.removeAll { $0 == name }
           }

           guard name.count > 2 else {
               print("Resource name too short")
               return false   // defer still runs
           }

           print("Processing \(name)")
           return true
       }

       func processWithMultipleDefers() {
           defer { print("Defer 3 — last in, first out") }
           defer { print("Defer 2") }
           defer { print("Defer 1 — first in, last out") }
           print("Processing")
       }
   }

   let rm = ResourceManager()

   let ok = rm.loadResource(named: "config.json")
   print("Success: \(ok)")
   // Output: Opening config.json
   //         Processing config.json
   //         Cleanup: closing config.json
   //         Success: true

   let fail = rm.loadResource(named: "x")
   print("Success: \(fail)")
   // Output: Opening x
   //         Resource name too short
   //         Cleanup: closing x
   //         Success: false

   rm.processWithMultipleDefers()
   // Output: Processing
   //         Defer 1 — first in, last out
   //         Defer 2
   //         Defer 3 — last in, first out


 ================================================================
 PART 3 — TYPE METHODS IN DEPTH
 ================================================================

 WHAT ARE TYPE METHODS?
 =======================
 Type methods are called on the TYPE itself, not
 on an instance. Declared with static (structs/enums)
 or class (classes — allows override in subclasses).

 Inside a type method, self refers to the TYPE itself,
 not an instance.

 STATIC vs class KEYWORD
 =========================
   // static — cannot be overridden:
   // class  — can be overridden in subclasses:

   class Vehicle {
       static  var count     = 0       // static stored property
       class   var typeName: String {  // class computed — overridable
           return "Vehicle"
       }

       static  func resetCount() {     // static — not overridable
           count = 0
       }
       class   func describe() -> String {   // class — overridable
           return "\(typeName) (count: \(count))"
       }
   }

   class Car: Vehicle {
       override class var typeName: String { return "Car" }
       override class func describe() -> String {
           return "🚗 \(super.describe())"
       }
   }

   Vehicle.count = 3
   print(Vehicle.describe())
   // Output: Vehicle (count: 3)
   print(Car.describe())
   // Output: 🚗 Car (count: 3)

   Vehicle.resetCount()
   print(Vehicle.count)
   // Output: 0

 STATIC METHODS — FACTORY PATTERN
 ==================================
   struct Color {
       let red:   Double
       let green: Double
       let blue:  Double
       let alpha: Double

       // Designated init:
       init(red: Double, green: Double,
            blue: Double, alpha: Double = 1.0) {
           self.red   = max(0, min(1, red))
           self.green = max(0, min(1, green))
           self.blue  = max(0, min(1, blue))
           self.alpha = max(0, min(1, alpha))
       }

       // Static factory methods:
       static func rgb(_ r: Int, _ g: Int, _ b: Int,
                        alpha: Double = 1.0) -> Color {
           return Color(red:   Double(r)/255,
                        green: Double(g)/255,
                        blue:  Double(b)/255,
                        alpha: alpha)
       }

       static func hex(_ hexString: String) -> Color? {
           var hex = hexString.trimmingCharacters(
               in: CharacterSet(charactersIn: "#"))
           guard hex.count == 6 else { return nil }
           let r = Int(hex.prefix(2), radix: 16) ?? 0
           let g = Int(hex.dropFirst(2).prefix(2), radix: 16) ?? 0
           let b = Int(hex.dropFirst(4).prefix(2), radix: 16) ?? 0
           return rgb(r, g, b)
       }

       // Predefined colors:
       static let red   = Color(red: 1, green: 0, blue: 0)
       static let green = Color(red: 0, green: 1, blue: 0)
       static let blue  = Color(red: 0, green: 0, blue: 1)
       static let white = Color(red: 1, green: 1, blue: 1)
       static let black = Color(red: 0, green: 0, blue: 0)
       static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)

       // Static utility:
       static func blend(_ c1: Color, _ c2: Color,
                          ratio: Double = 0.5) -> Color {
           let t = max(0, min(1, ratio))
           return Color(
               red:   c1.red   * (1-t) + c2.red   * t,
               green: c1.green * (1-t) + c2.green * t,
               blue:  c1.blue  * (1-t) + c2.blue  * t,
               alpha: c1.alpha * (1-t) + c2.alpha * t
           )
       }

       var description: String {
           String(format: "rgb(%.0f, %.0f, %.0f, %.2f)",
               red*255, green*255, blue*255, alpha)
       }
   }

   let tomato = Color.rgb(255, 99, 71)
   print(tomato.description)
   // Output: rgb(255, 99, 71, 1.00)

   let skyBlue = Color.hex("#87CEEB")!
   print(skyBlue.description)
   // Output: rgb(135, 206, 235, 1.00)

   let mixed = Color.blend(.red, .blue)
   print(mixed.description)
   // Output: rgb(128, 0, 128, 1.00)

   print(Color.hex("ZZZZZZ") ?? "invalid")
   // Output: invalid

 STATIC METHODS — SINGLETON PATTERN
 =====================================
   class AppConfig {
       // Single shared instance:
       static let shared = AppConfig()

       private var settings: [String: Any] = [
           "theme":    "light",
           "fontSize": 14,
           "language": "en",
           "debug":    false
       ]

       private init() {}    // prevent external instantiation

       func get<T>(_ key: String) -> T? {
           return settings[key] as? T
       }

       func set(_ key: String, value: Any) {
           settings[key] = value
           print("Config updated: \(key) = \(value)")
       }

       static func reset() {
           shared.settings = [
               "theme":    "light",
               "fontSize": 14,
               "language": "en",
               "debug":    false
           ]
           print("Config reset to defaults")
       }

       func dump() {
           settings.sorted { $0.key < $1.key }
                   .forEach { print("  \($0.key): \($0.value)") }
       }
   }

   AppConfig.shared.set("theme", value: "dark")
   // Output: Config updated: theme = dark
   AppConfig.shared.set("fontSize", value: 18)
   // Output: Config updated: fontSize = 18

   let theme: String = AppConfig.shared.get("theme") ?? "light"
   print(theme)
   // Output: dark

   AppConfig.reset()
   // Output: Config reset to defaults

   AppConfig.shared.dump()
   // Output:   debug: false
   //           fontSize: 14
   //           language: en
   //           theme: light

 STATIC METHODS — REGISTRY PATTERN
 ====================================
   class PluginRegistry {
       private static var plugins: [String: () -> String] = [:]
       private static var order:   [String]               = []

       static func register(name: String,
                             factory: @escaping () -> String) {
           if plugins[name] == nil { order.append(name) }
           plugins[name] = factory
           print("Registered plugin: \(name)")
       }

       static func unregister(name: String) {
           plugins.removeValue(forKey: name)
           order.removeAll { $0 == name }
           print("Unregistered plugin: \(name)")
       }

       static func run(_ name: String) -> String? {
           return plugins[name]?()
       }

       static func runAll() -> [String: String] {
           var results: [String: String] = [:]
           for name in order {
               results[name] = plugins[name]?()
           }
           return results
       }

       static var registeredNames: [String] { order }
   }

   PluginRegistry.register(name: "auth")    { "Auth plugin v1.0" }
   // Output: Registered plugin: auth
   PluginRegistry.register(name: "cache")   { "Cache plugin v2.1" }
   // Output: Registered plugin: cache
   PluginRegistry.register(name: "logging") { "Logging plugin v3.0" }
   // Output: Registered plugin: logging

   print(PluginRegistry.run("auth") ?? "not found")
   // Output: Auth plugin v1.0

   print(PluginRegistry.runAll())
   // Output: ["auth": "Auth plugin v1.0",
   //          "cache": "Cache plugin v2.1",
   //          "logging": "Logging plugin v3.0"]

   PluginRegistry.unregister(name: "cache")
   // Output: Unregistered plugin: cache
   print(PluginRegistry.registeredNames)
   // Output: ["auth", "logging"]

 TYPE METHOD CALLING TYPE METHOD
 =================================
   struct Statistics {
       // Type methods calling other type methods:
       static func sum(_ values: [Double]) -> Double {
           values.reduce(0, +)
       }

       static func mean(_ values: [Double]) -> Double {
           guard !values.isEmpty else { return 0 }
           return sum(values) / Double(values.count)   // calls sum
       }

       static func variance(_ values: [Double]) -> Double {
           guard values.count > 1 else { return 0 }
           let m = mean(values)                        // calls mean
           return values.map { ($0 - m) * ($0 - m) }
                        .reduce(0, +) / Double(values.count - 1)
       }

       static func standardDeviation(_ values: [Double]) -> Double {
           return variance(values).squareRoot()        // calls variance
       }

       static func summary(_ values: [Double]) -> String {
           guard !values.isEmpty else { return "empty" }
           let mn = values.min()!
           let mx = values.max()!
           let m  = mean(values)
           let sd = standardDeviation(values)
           return String(format:
               "n=%d min=%.2f max=%.2f mean=%.2f σ=%.2f",
               values.count, mn, mx, m, sd)
           // summary calls mean + standardDeviation
       }
   }

   let data = [4.0, 7.0, 13.0, 2.0, 8.0, 11.0, 5.0, 9.0]
   print(Statistics.mean(data))
   // Output: 7.375
   print(Statistics.standardDeviation(data))
   // Output: 3.3380...
   print(Statistics.summary(data))
   // Output: n=8 min=2.00 max=13.00 mean=7.38 σ=3.34

 STATIC vs INSTANCE — CHOOSING THE RIGHT ONE
 =============================================
   struct Validator {
       let rules: [(String) -> Bool]

       // Instance method — uses instance state (rules):
       func validate(_ input: String) -> Bool {
           rules.allSatisfy { $0(input) }
       }

       // Static method — no instance needed, utility:
       static func isEmail(_ s: String) -> Bool {
           s.contains("@") && s.contains(".")
       }

       static func isPhone(_ s: String) -> Bool {
           s.allSatisfy { $0.isNumber || $0 == "-" || $0 == " " }
           && s.filter { $0.isNumber }.count >= 7
       }

       static func isStrongPassword(_ s: String) -> Bool {
           let hasUpper   = s.contains { $0.isUppercase }
           let hasLower   = s.contains { $0.isLowercase }
           let hasDigit   = s.contains { $0.isNumber }
           let hasSpecial = s.contains { "!@#$%^&*".contains($0) }
           return s.count >= 8 && hasUpper && hasLower
                               && hasDigit && hasSpecial
       }

       // Static factory:
       static func emailValidator() -> Validator {
           Validator(rules: [isEmail, { $0.count <= 254 }])
       }

       static func passwordValidator() -> Validator {
           Validator(rules: [isStrongPassword, { $0.count <= 128 }])
       }
   }

   print(Validator.isEmail("alice@example.com"))
   // Output: true
   print(Validator.isEmail("notanemail"))
   // Output: false
   print(Validator.isStrongPassword("Secure1!"))
   // Output: true
   print(Validator.isStrongPassword("weakpass"))
   // Output: false

   let emailV = Validator.emailValidator()
   print(emailV.validate("user@domain.com"))
   // Output: true
   print(emailV.validate("bademail"))
   // Output: false


 ================================================================
 PART 4 — MUTATING METHODS IN DEPTH
 ================================================================

 WHY MUTATING?
 ==============
 Value types (struct, enum) are immutable by default.
 To modify self inside an instance method, you must
 mark it mutating. The compiler then copies the value
 before mutation and writes back the result.

 MUTATING IN STRUCTS
 ====================
   struct Stack<T> {
       private var elements: [T] = []

       // Non-mutating — read only:
       var count:   Int  { elements.count  }
       var isEmpty: Bool { elements.isEmpty }
       var top:     T?   { elements.last   }

       // Mutating — modifies elements:
       mutating func push(_ element: T) {
           elements.append(element)
       }

       mutating func pop() -> T? {
           return elements.isEmpty ? nil : elements.removeLast()
       }

       mutating func removeAll() {
           elements.removeAll()
       }

       mutating func push(contentsOf sequence: [T]) {
           elements.append(contentsOf: sequence)
       }

       // Returns new copy — not mutating:
       func peekAll() -> [T] { elements }
   }

   var stack = Stack<Int>()
   stack.push(1)
   stack.push(2)
   stack.push(3)
   stack.push(contentsOf: [4, 5])

   print(stack.count)
   // Output: 5
   print(stack.top ?? -1)
   // Output: 5
   print(stack.pop() ?? -1)
   // Output: 5
   print(stack.peekAll())
   // Output: [1, 2, 3, 4]

   // let stack2 = Stack<Int>()
   // stack2.push(1)    // Error — push is mutating, stack2 is let

 MUTATING WITH self REPLACEMENT
 ================================
   struct Point {
       var x: Double
       var y: Double

       // Replace self entirely:
       mutating func translate(dx: Double, dy: Double) {
           self = Point(x: x + dx, y: y + dy)
           // equivalent to: x += dx; y += dy
       }

       mutating func reflect(over axis: String) {
           switch axis {
           case "x": self = Point(x:  x, y: -y)
           case "y": self = Point(x: -x, y:  y)
           default:  break
           }
       }

       mutating func normalize() {
           let length = (x*x + y*y).squareRoot()
           guard length > 0 else { return }
           self = Point(x: x/length, y: y/length)
       }

       var length: Double { (x*x + y*y).squareRoot() }
   }

   var pt = Point(x: 3, y: 4)
   print(pt.length)
   // Output: 5.0
   pt.normalize()
   print(pt.x)
   // Output: 0.6
   print(pt.y)
   // Output: 0.8
   pt.reflect(over: "x")
   print("(\(pt.x), \(pt.y))")
   // Output: (0.6, -0.8)

 MUTATING IN PROTOCOLS
 ======================
   protocol Resettable {
       mutating func reset()
   }

   protocol Incrementable {
       mutating func increment()
       mutating func decrement()
   }

   struct Counter: Resettable, Incrementable {
       var value: Int
       let step:  Int

       init(value: Int = 0, step: Int = 1) {
           self.value = value
           self.step  = step
       }

       mutating func increment() { value += step }
       mutating func decrement() { value -= step }
       mutating func reset()     { value = 0     }

       mutating func advance(by n: Int) {
           for _ in 0..<n { increment() }
       }
   }

   var counter = Counter(step: 5)
   counter.increment()
   counter.increment()
   counter.increment()
   print(counter.value)
   // Output: 15
   counter.advance(by: 3)
   print(counter.value)
   // Output: 30
   counter.reset()
   print(counter.value)
   // Output: 0

   // Class conforming to protocol — no mutating needed:
   class ClassCounter: Resettable, Incrementable {
       var value = 0
       func increment() { value += 1 }
       func decrement() { value -= 1 }
       func reset()     { value = 0  }
   }


 ================================================================
 PART 5 — SUBSCRIPTS FUNDAMENTALS
 ================================================================

 WHAT IS A SUBSCRIPT?
 =====================
 Subscripts are shortcuts for accessing elements of
 a collection, list, or sequence. They use bracket
 syntax: instance[index]. You define them with the
 subscript keyword — like a computed property with
 parameters. Subscripts can be read-only or read-write.

 SUBSCRIPT ANATOMY
 ==================
   subscript(parameterName: ParameterType) -> ReturnType {
       get {
           // Return value for given parameter
       }
       set(newValue) {
           // Set value for given parameter
       }
   }

   // Read-only shorthand (omit get/set):
   subscript(index: Int) -> String {
       return items[index]
   }

 BASIC SUBSCRIPT
 ================
   struct IntArray {
       private var storage: [Int]

       init(_ values: [Int]) {
           storage = values
       }

       // Read-write subscript:
       subscript(index: Int) -> Int {
           get {
               precondition(index >= 0 && index < storage.count,
                            "Index out of range")
               return storage[index]
           }
           set {
               precondition(index >= 0 && index < storage.count,
                            "Index out of range")
               storage[index] = newValue
           }
       }

       var count: Int { storage.count }
   }

   var arr = IntArray([10, 20, 30, 40, 50])
   print(arr[0])
   // Output: 10
   print(arr[4])
   // Output: 50
   arr[2] = 99
   print(arr[2])
   // Output: 99

 SUBSCRIPT IN STRUCTS
 =====================
   struct Matrix {
       private var grid: [[Double]]
       let rows:    Int
       let columns: Int

       init(rows: Int, columns: Int, defaultValue: Double = 0) {
           self.rows    = rows
           self.columns = columns
           grid = Array(
               repeating: Array(repeating: defaultValue,
                                 count: columns),
               count: rows
           )
       }

       // Two-parameter subscript:
       subscript(row: Int, col: Int) -> Double {
           get {
               precondition(isValid(row, col), "Index out of range")
               return grid[row][col]
           }
           set {
               precondition(isValid(row, col), "Index out of range")
               grid[row][col] = newValue
           }
       }

       // Row subscript — returns entire row:
       subscript(row row: Int) -> [Double] {
           get {
               precondition(row >= 0 && row < rows)
               return grid[row]
           }
           set {
               precondition(row >= 0 && row < rows)
               precondition(newValue.count == columns)
               grid[row] = newValue
           }
       }

       private func isValid(_ r: Int, _ c: Int) -> Bool {
           return r >= 0 && r < rows && c >= 0 && c < columns
       }

       func description() -> String {
           grid.map { row in
               row.map { String(format: "%6.1f", $0) }
                  .joined(separator: " ")
           }.joined(separator: "\n")
       }
   }

   var m = Matrix(rows: 3, columns: 3)
   m[0, 0] = 1; m[0, 1] = 2; m[0, 2] = 3
   m[1, 0] = 4; m[1, 1] = 5; m[1, 2] = 6
   m[2, 0] = 7; m[2, 1] = 8; m[2, 2] = 9

   print(m[1, 1])
   // Output: 5.0
   print(m[row: 2])
   // Output: [7.0, 8.0, 9.0]
   print(m.description())
   // Output:    1.0    2.0    3.0
   //            4.0    5.0    6.0
   //            7.0    8.0    9.0

 SUBSCRIPT IN CLASSES
 =====================
   class Cache<Key: Hashable, Value> {
       private var storage:   [Key: Value]  = [:]
       private var accessLog: [Key]         = []
       private let capacity:  Int

       init(capacity: Int) {
           self.capacity = capacity
       }

       subscript(key: Key) -> Value? {
           get {
               if let value = storage[key] {
                   accessLog.append(key)
                   return value
               }
               return nil
           }
           set {
               if let value = newValue {
                   if storage[key] == nil && storage.count >= capacity {
                       evictOldest()
                   }
                   storage[key] = value
               } else {
                   storage.removeValue(forKey: key)
               }
           }
       }

       private func evictOldest() {
           // Find least-recently used key not in recent log:
           if let oldest = storage.keys.first {
               storage.removeValue(forKey: oldest)
               print("Evicted: \(oldest)")
           }
       }

       var count: Int    { storage.count }
       var keys:  [Key]  { Array(storage.keys) }
   }

   var cache = Cache<String, Int>(capacity: 3)
   cache["a"] = 1
   cache["b"] = 2
   cache["c"] = 3
   print(cache["b"] ?? -1)
   // Output: 2
   print(cache.count)
   // Output: 3
   cache["a"] = nil
   print(cache.count)
   // Output: 2
   cache["d"] = 4
   cache["e"] = 5
   print(cache.count)
   // Output: 3   (capacity reached, oldest evicted)

 READ-ONLY SUBSCRIPT
 ====================
   struct FibonacciSequence {
       // Read-only — no setter:
       subscript(n: Int) -> Int {
           guard n >= 0 else { return 0 }
           if n <= 1 { return n }
           var a = 0, b = 1
           for _ in 2...n {
               let temp = a + b
               a = b
               b = temp
           }
           return b
       }

       subscript(range: ClosedRange<Int>) -> [Int] {
           range.map { self[$0] }
       }
   }

   let fib = FibonacciSequence()
   print(fib[10])
   // Output: 55
   print(fib[0])
   // Output: 0
   print(fib[1])
   // Output: 1
   print(fib[7])
   // Output: 13
   print(fib[0...10])
   // Output: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]


 ================================================================
 PART 6 — SUBSCRIPTS IN DEPTH
 ================================================================

 SUBSCRIPT OVERLOADING
 ======================
   struct DataGrid {
       private var data: [String: [String: Any]] = [:]

       // Subscript overload 1 — by row and column String:
       subscript(row: String, col: String) -> Any? {
           get { data[row]?[col] }
           set {
               if data[row] == nil { data[row] = [:] }
               data[row]?[col] = newValue
           }
       }

       // Subscript overload 2 — by row Int index (sorted keys):
       subscript(rowIndex: Int) -> [String: Any]? {
           let keys = data.keys.sorted()
           guard rowIndex >= 0 && rowIndex < keys.count else {
               return nil
           }
           return data[keys[rowIndex]]
       }

       // Subscript overload 3 — column lookup across all rows:
       subscript(column col: String) -> [Any] {
           data.keys.sorted().compactMap { data[$0]?[col] }
       }

       var rowCount: Int { data.count }
   }

   var grid = DataGrid()
   grid["alice", "age"]    = 28
   grid["alice", "city"]   = "NYC"
   grid["bob",   "age"]    = 34
   grid["bob",   "city"]   = "LA"
   grid["carol", "age"]    = 25
   grid["carol", "city"]   = "Chicago"

   print(grid["bob", "city"] ?? "nil")
   // Output: LA
   print(grid[0] ?? [:])
   // Output: ["age": 28, "city": "NYC"]   (alice — sorted first)
   print(grid[column: "age"])
   // Output: [28, 34, 25]

 SUBSCRIPT WITH MULTIPLE PARAMETERS
 =====================================
   struct TensorSlice {
       private var data: [[[Double]]]
       let depth:   Int
       let rows:    Int
       let columns: Int

       init(depth: Int, rows: Int, columns: Int) {
           self.depth   = depth
           self.rows    = rows
           self.columns = columns
           data = Array(repeating:
               Array(repeating:
                   Array(repeating: 0, count: columns),
                   count: rows),
               count: depth)
       }

       // Three-index subscript:
       subscript(d: Int, r: Int, c: Int) -> Double {
           get { data[d][r][c] }
           set { data[d][r][c] = newValue }
       }

       // Slice by depth:
       subscript(depth d: Int) -> [[Double]] {
           get { data[d] }
           set { data[d] = newValue }
       }

       // Variadic — fill diagonal:
       static func identity(size: Int) -> TensorSlice {
           var t = TensorSlice(depth: 1, rows: size, columns: size)
           for i in 0..<size { t[0, i, i] = 1.0 }
           return t
       }
   }

   var tensor = TensorSlice(depth: 2, rows: 3, columns: 3)
   tensor[0, 0, 0] = 1.0
   tensor[0, 1, 1] = 2.0
   tensor[0, 2, 2] = 3.0
   tensor[1, 0, 0] = 4.0

   print(tensor[0, 1, 1])
   // Output: 2.0
   print(tensor[depth: 0])
   // Output: [[1.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 3.0]]

   let identity = TensorSlice.identity(size: 3)
   print(identity[depth: 0])
   // Output: [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]

 SUBSCRIPT WITH RANGE
 =====================
   struct CircularBuffer<T> {
       private var buffer: [T?]
       private var head   = 0
       private var tail   = 0
       private var count2 = 0
       let capacity: Int

       init(capacity: Int) {
           self.capacity = capacity
           buffer = Array(repeating: nil, count: capacity)
       }

       mutating func enqueue(_ element: T) {
           buffer[tail] = element
           tail = (tail + 1) % capacity
           if count2 < capacity { count2 += 1 }
           else { head = (head + 1) % capacity }
       }

       // Index from logical position (0 = oldest):
       subscript(index: Int) -> T? {
           guard index >= 0 && index < count2 else { return nil }
           return buffer[(head + index) % capacity]
       }

       // Range subscript:
       subscript(range: Range<Int>) -> [T] {
           return range.compactMap { self[$0] }
       }

       var elements: [T] { self[0..<count2] }
   }

   var cb = CircularBuffer<Int>(capacity: 5)
   for i in 1...7 { cb.enqueue(i) }   // 1,2 overwritten

   print(cb.elements)
   // Output: [3, 4, 5, 6, 7]
   print(cb[0] ?? -1)
   // Output: 3
   print(cb[4] ?? -1)
   // Output: 7
   print(cb[1...3])
   // Output: [4, 5, 6]

 SUBSCRIPT WITH KEYPATH
 =======================
   struct Record {
       var id:       Int
       var name:     String
       var email:    String
       var isActive: Bool

       // Dynamic property access via KeyPath:
       subscript<T>(keyPath path: KeyPath<Record, T>) -> T {
           return self[keyPath: path]
       }

       subscript<T>(writableKeyPath path: WritableKeyPath<Record, T>)
           -> T {
           get { self[keyPath: path] }
           set { self[keyPath: path] = newValue }
       }
   }

   var record = Record(id: 1, name: "Alice",
                        email: "alice@x.com", isActive: true)

   print(record[keyPath: \.name])
   // Output: Alice
   print(record[keyPath: \.isActive])
   // Output: true

   record[writableKeyPath: \.name]  = "Alice Smith"
   record[writableKeyPath: \.email] = "asmith@x.com"
   print(record.name)
   // Output: Alice Smith
   print(record.email)
   // Output: asmith@x.com

 SUBSCRIPT IN ENUMS
 ===================
   enum JSONValue {
       case null
       case bool(Bool)
       case number(Double)
       case string(String)
       case array([JSONValue])
       case object([String: JSONValue])

       // String subscript for object:
       subscript(key: String) -> JSONValue? {
           if case .object(let obj) = self { return obj[key] }
           return nil
       }

       // Int subscript for array:
       subscript(index: Int) -> JSONValue? {
           if case .array(let arr) = self,
              index >= 0 && index < arr.count {
               return arr[index]
           }
           return nil
       }

       // Chained access helper:
       subscript(path: [String]) -> JSONValue? {
           return path.reduce(self as JSONValue?) { val, key in
               val?[key]
           }
       }

       var stringValue: String? {
           if case .string(let s) = self { return s }
           return nil
       }
       var numberValue: Double? {
           if case .number(let n) = self { return n }
           return nil
       }
       var boolValue: Bool? {
           if case .bool(let b) = self { return b }
           return nil
       }
   }

   let json = JSONValue.object([
       "user": .object([
           "id":    .number(42),
           "name":  .string("Alice"),
           "roles": .array([.string("admin"), .string("user")])
       ]),
       "active": .bool(true)
   ])

   print(json["user"]?["name"]?.stringValue ?? "nil")
   // Output: Alice
   print(json["user"]?["roles"]?[0]?.stringValue ?? "nil")
   // Output: admin
   print(json["active"]?.boolValue ?? false)
   // Output: true
   print(json[["user", "id"]]?.numberValue ?? 0)
   // Output: 42.0

 TYPE-LEVEL SUBSCRIPTS (STATIC SUBSCRIPT)
 ==========================================
   struct Registry2 {
       private static var store: [String: Any] = [:]

       // Static subscript — subscript on the type itself:
       static subscript(key: String) -> Any? {
           get { store[key] }
           set { store[key] = newValue }
       }

       static subscript<T>(key: String, as type2: T.Type) -> T? {
           return store[key] as? T
       }
   }

   Registry2["appName"]    = "MyApp"
   Registry2["version"]    = 2
   Registry2["debugMode"]  = true

   print(Registry2["appName"] ?? "nil")
   // Output: MyApp

   let version = Registry2["version", as: Int.self]
   print(version ?? -1)
   // Output: 2

   let debug = Registry2["debugMode", as: Bool.self]
   print(debug ?? false)
   // Output: true

 DYNAMIC MEMBER LOOKUP SUBSCRIPT
 =================================
   @dynamicMemberLookup
   struct DynamicConfig {
       private var values: [String: String] = [:]

       subscript(dynamicMember key: String) -> String {
           get { values[key] ?? "" }
           set { values[key] = newValue }
       }

       subscript(dynamicMember key: String) -> Int {
           get { Int(values[key] ?? "") ?? 0 }
           set { values[key] = "\(newValue)" }
       }
   }

   var config = DynamicConfig()
   config.host    = "localhost"
   config.port    = 8080
   config.timeout = 30

   let host:    String = config.host
   let port:    Int    = config.port
   let timeout: Int    = config.timeout

   print(host)
   // Output: localhost
   print(port)
   // Output: 8080
   print(timeout)
   // Output: 30


 ================================================================
 PART 7 — ADVANCED METHOD PATTERNS
 ================================================================

 METHOD DISPATCH — STATIC vs DYNAMIC
 =====================================
   // Static dispatch — resolved at compile time (faster):
   // - Struct methods
   // - Enum methods
   // - final class methods
   // - Class methods called on concrete type

   // Dynamic dispatch — resolved at runtime via vtable:
   // - Class methods (non-final)
   // - Protocol methods via existential

   class Animal {
       func speak() -> String { "..." }       // dynamic dispatch
       final func breathe() -> String { "inhale/exhale" } // static
   }

   class Dog: Animal {
       override func speak() -> String { "Woof" }
   }

   class Cat: Animal {
       override func speak() -> String { "Meow" }
   }

   let animals: [Animal] = [Dog(), Cat(), Animal()]
   animals.forEach { print($0.speak()) }
   // Output: Woof
   //         Meow
   //         ...

   // Protocol dispatch:
   protocol Speakable {
       func speak() -> String
   }
   // When called via protocol existential — dynamic dispatch
   // When called via generic constraint  — static dispatch

 METHOD REQUIREMENTS IN PROTOCOLS
 ==================================
 protocol Drawable {
     func draw() -> String
     func area() -> Double
     mutating func scale(by factor: Double)
     static func defaultInstance() -> Self
 }

 struct Square: Drawable {
     var side: Double

     func draw() -> String {
         return "■ Square(\(side))"
     }
     func area() -> Double { side * side }
     mutating func scale(by factor: Double) { side *= factor }
     static func defaultInstance() -> Square {
         return Square(side: 1.0)
     }
 }

 struct Triangle2: Drawable {
     var base:   Double
     var height: Double

     func draw() -> String {
         return "▲ Triangle(\(base) x \(height))"
     }
     func area() -> Double { 0.5 * base * height }
     mutating func scale(by factor: Double) {
         base   *= factor
         height *= factor
     }
     static func defaultInstance() -> Triangle2 {
         return Triangle2(base: 1.0, height: 1.0)
     }
 }

 var sq = Square(side: 4)
 print(sq.draw())
 // Output: ■ Square(4.0)
 print(sq.area())
 // Output: 16.0
 sq.scale(by: 2)
 print(sq.draw())
 // Output: ■ Square(8.0)

 let shapes: [any Drawable] = [
     Square(side: 3),
     Triangle2(base: 6, height: 4)
 ]
 shapes.forEach { print("\($0.draw()) area=\($0.area())") }
 // Output: ■ Square(3.0) area=9.0
 //         ▲ Triangle(6.0 x 4.0) area=12.0

METHODS WITH GENERICS
======================
 struct SortedArray<T: Comparable> {
     private var elements: [T] = []

     mutating func insert(_ value: T) {
         let index = elements.firstIndex { $0 >= value }
                     ?? elements.endIndex
         elements.insert(value, at: index)
     }

     mutating func remove(_ value: T) {
         if let idx = elements.firstIndex(of: value) {
             elements.remove(at: idx)
         }
     }

     func contains(_ value: T) -> Bool {
         binarySearch(for: value) != nil
     }

     private func binarySearch(for value: T) -> Int? {
         var low = 0, high = elements.count - 1
         while low <= high {
             let mid = (low + high) / 2
             if      elements[mid] == value { return mid }
             else if elements[mid] <  value { low  = mid + 1 }
             else                           { high = mid - 1 }
         }
         return nil
     }

     func min() -> T?   { elements.first }
     func max() -> T?   { elements.last  }
     var count: Int     { elements.count }
     var all:   [T]     { elements       }

     subscript(index: Int) -> T {
         elements[index]
     }
 }

 var sorted = SortedArray<Int>()
 [5, 2, 8, 1, 9, 3, 7, 4, 6].forEach { sorted.insert($0) }
 print(sorted.all)
 // Output: [1, 2, 3, 4, 5, 6, 7, 8, 9]
 print(sorted.contains(7))
 // Output: true
 print(sorted.contains(10))
 // Output: false
 print(sorted.min() ?? -1)
 // Output: 1
 print(sorted.max() ?? -1)
 // Output: 9
 sorted.remove(5)
 print(sorted.all)
 // Output: [1, 2, 3, 4, 6, 7, 8, 9]

METHODS WITH WHERE CLAUSES
============================
 extension Array {
     // Method available only when Element is Comparable:
     func sortedUnique() -> [Element] where Element: Comparable {
         return Array(Set(self as! [AnyHashable]) as! Set<Element>)
             .sorted()
     }

     // Method available only when Element is numeric:
     func average() -> Double where Element: BinaryInteger {
         guard !isEmpty else { return 0 }
         return Double(reduce(0, +)) / Double(count)
     }

     func average() -> Double where Element: BinaryFloatingPoint {
         guard !isEmpty else { return 0 }
         return Double(reduce(0, +)) / Double(count)
     }

     // Method when Element is Optional:
     func compacted<Wrapped>() -> [Wrapped]
         where Element == Optional<Wrapped> {
         return compactMap { $0 }
     }
 }

 let nums = [3, 1, 4, 1, 5, 9, 2, 6, 5]
 print(nums.average())
 // Output: 4.0

 let optionals: [Int?] = [1, nil, 3, nil, 5]
 print(optionals.compacted())
 // Output: [1, 3, 5]

 let floats = [1.5, 2.5, 3.5, 4.5]
 print(floats.average())
 // Output: 3.0

OPERATOR METHODS
=================
 struct Vector2D {
     var x: Double
     var y: Double

     // Instance method as operator:
     static func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
         return Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
     }
     static func - (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
         return Vector2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
     }
     static func * (lhs: Vector2D, rhs: Double) -> Vector2D {
         return Vector2D(x: lhs.x * rhs, y: lhs.y * rhs)
     }
     static func * (lhs: Double, rhs: Vector2D) -> Vector2D {
         return rhs * lhs
     }

     // Dot product:
     static func • (lhs: Vector2D, rhs: Vector2D) -> Double {
         return lhs.x * rhs.x + lhs.y * rhs.y
     }

     // Compound assignment:
     static func += (lhs: inout Vector2D, rhs: Vector2D) {
         lhs = lhs + rhs
     }

     // Unary minus:
     static prefix func - (v: Vector2D) -> Vector2D {
         return Vector2D(x: -v.x, y: -v.y)
     }

     var magnitude: Double { (x*x + y*y).squareRoot() }
     var normalized: Vector2D {
         let m = magnitude
         return m > 0 ? Vector2D(x: x/m, y: y/m) : self
     }
     var description: String { "(\(x), \(y))" }
 }

 infix operator •: MultiplicationPrecedence

 let v1 = Vector2D(x: 3, y: 4)
 let v2 = Vector2D(x: 1, y: 2)

 print((v1 + v2).description)
 // Output: (4.0, 6.0)
 print((v1 - v2).description)
 // Output: (2.0, 2.0)
 print((v1 * 2).description)
 // Output: (6.0, 8.0)
 print((-v1).description)
 // Output: (-3.0, -4.0)
 print(v1 • v2)
 // Output: 11.0
 print(v1.magnitude)
 // Output: 5.0
 print(v1.normalized.description)
 // Output: (0.6, 0.8)

 var v3 = Vector2D(x: 1, y: 1)
 v3 += v1
 print(v3.description)
 // Output: (4.0, 5.0)


================================================================
PART 8 — ADVANCED SUBSCRIPT PATTERNS
================================================================

SUBSCRIPT WITH GENERIC CONSTRAINTS
=====================================
 struct TypedStorage {
     private var data: [String: Any] = [:]

     // Generic subscript — type-safe access:
     subscript<T>(key: String, as type2: T.Type = T.self) -> T? {
         get { data[key] as? T }
         set { data[key] = newValue }
     }

     // Default-value subscript:
     subscript<T>(key: String, default defaultValue: T) -> T {
         get { data[key] as? T ?? defaultValue }
         set { data[key] = newValue }
     }
 }

 var storage = TypedStorage()
 storage["name",    as: String.self] = "Alice"
 storage["age",     as: Int.self]    = 28
 storage["active",  as: Bool.self]   = true
 storage["score",   as: Double.self] = 98.5

 let name:   String = storage["name",   as: String.self] ?? ""
 let age:    Int    = storage["age",    as: Int.self]    ?? 0
 let active: Bool   = storage["active", as: Bool.self]   ?? false

 print(name)
 // Output: Alice
 print(age)
 // Output: 28
 print(active)
 // Output: true

 let missing = storage["missing", default: "N/A"]
 print(missing)
 // Output: N/A

 let score = storage["score", default: 0.0]
 print(score)
 // Output: 98.5

SUBSCRIPT CHAINING
===================
 struct DeepAccessor {
     private var root: [String: Any]

     init(_ dict: [String: Any]) {
         root = dict
     }

     subscript(path: String...) -> Any? {
         var current: Any? = root
         for key in path {
             guard let dict = current as? [String: Any] else {
                 return nil
             }
             current = dict[key]
         }
         return current
     }

     subscript(path: [String]) -> Any? {
         self[path[0], path.dropFirst().first ?? "",
              path.dropFirst(2).first ?? ""]
     }
 }

 let config2 = DeepAccessor([
     "database": [
         "primary": [
             "host": "db1.example.com",
             "port": 5432
         ],
         "replica": [
             "host": "db2.example.com",
             "port": 5433
         ]
     ],
     "cache": [
         "ttl": 3600,
         "maxSize": 1024
     ]
 ])

 print(config2["database", "primary", "host"] ?? "nil")
 // Output: db1.example.com
 print(config2["database", "replica", "port"] ?? "nil")
 // Output: 5433
 print(config2["cache", "ttl"] ?? "nil")
 // Output: 3600
 print(config2["missing", "key"] ?? "nil")
 // Output: nil

SUBSCRIPT WITH TRANSFORMATION
================================
 struct TransformingCollection<T> {
     private var items: [T]

     init(_ items: [T]) {
         self.items = items
     }

     // Standard index subscript:
     subscript(index: Int) -> T {
         items[index]
     }

     // Transformed subscript — apply a function on access:
     subscript<U>(index: Int, transform f: (T) -> U) -> U {
         return f(items[index])
     }

     // Range subscript returning new collection:
     subscript(range: Range<Int>) -> TransformingCollection<T> {
         return TransformingCollection(Array(items[range]))
     }

     // Conditional subscript — returns nil if predicate fails:
     subscript(index: Int,
               where predicate: (T) -> Bool) -> T? {
         let item = items[index]
         return predicate(item) ? item : nil
     }

     var count: Int { items.count }
     var all:   [T] { items       }
 }

 let tc = TransformingCollection([1, 2, 3, 4, 5, 6, 7, 8])

 print(tc[3])
 // Output: 4
 print(tc[3, transform: { $0 * 10 }])
 // Output: 40
 print(tc[3, transform: { "Item: \($0)" }])
 // Output: Item: 4

 print(tc[2..<5].all)
 // Output: [3, 4, 5]

 print(tc[4, where: { $0 > 3 }] ?? -1)
 // Output: 5
 print(tc[1, where: { $0 > 3 }] ?? -1)
 // Output: -1   (2 does not satisfy > 3)

SUBSCRIPT IN PROTOCOLS
========================
 protocol Container2 {
     associatedtype Element
     var count: Int { get }
     subscript(index: Int) -> Element { get }
 }

 protocol MutableContainer: Container2 {
     subscript(index: Int) -> Element { get set }
 }

 struct BoundedArray<T>: MutableContainer {
     private var items:       [T]
     private let minVal:      T?
     private let maxVal:      T?
     private let comparator:  ((T, T) -> Bool)?

     init(items: [T] = [],
          min: T? = nil,
          max: T? = nil,
          comparator: ((T, T) -> Bool)? = nil) {
         self.items      = items
         self.minVal     = min
         self.maxVal     = max
         self.comparator = comparator
     }

     var count: Int { items.count }

     subscript(index: Int) -> T {
         get {
             precondition(index >= 0 && index < count)
             return items[index]
         }
         set {
             precondition(index >= 0 && index < count)
             items[index] = newValue
         }
     }

     func allItems() -> [T] { items }
 }

 var ba = BoundedArray<String>(
     items: ["alpha", "beta", "gamma", "delta"]
 )
 print(ba[0])
 // Output: alpha
 print(ba[2])
 // Output: gamma
 ba[1] = "BETA"
 print(ba.allItems())
 // Output: ["alpha", "BETA", "gamma", "delta"]

SUBSCRIPT PERFORMANCE — INLINING
==================================
 // Subscripts can be marked @inlinable for
 // cross-module optimization:
 struct FastBuffer<T> {
     var buffer: [T]

     init(_ items: [T]) { buffer = items }

     // @inlinable — compiler may inline at call site:
     @inlinable
     subscript(index: Int) -> T {
         get { buffer[index] }
         set { buffer[index] = newValue }
     }

     // Unsafe — no bounds check (for hot paths):
     subscript(unsafe index: Int) -> T {
         get { buffer.withUnsafeBufferPointer { $0[index] } }
         set { buffer.withUnsafeMutableBufferPointer {
             $0[index] = newValue }
         }
     }
 }

 var fb = FastBuffer([10, 20, 30, 40, 50])
 print(fb[2])
 // Output: 30
 fb[2] = 99
 print(fb[2])
 // Output: 99
 print(fb[unsafe: 0])
 // Output: 10


================================================================
PART 9 — COMBINING METHODS AND SUBSCRIPTS
================================================================

FULL EXAMPLE — SPREADSHEET ENGINE
====================================
 struct Spreadsheet {
     private var cells:   [String: Double] = [:]
     private var labels:  [String: String] = [:]
     private var formulas:[String: String] = [:]

     // Subscript for cell value by address (e.g., "A1"):
     subscript(address: String) -> Double {
         get { cells[address.uppercased()] ?? 0 }
         set {
             let key = address.uppercased()
             cells[key]    = newValue
             formulas[key] = nil    // clear formula on direct set
         }
     }

     // Subscript for range — returns array of values:
     subscript(range addresses: String...) -> [Double] {
         return addresses.map { self[$0] }
     }

     // Subscript for label:
     subscript(label address: String) -> String {
         get { labels[address.uppercased()] ?? "" }
         set { labels[address.uppercased()] = newValue }
     }

     // Instance methods:
     mutating func setFormula(_ address: String,
                               formula: String) {
         let key = address.uppercased()
         formulas[key] = formula
         cells[key]    = evaluate(formula: formula)
         print("  \(key) = \(formula) → \(cells[key]!)")
     }

     func sum(_ addresses: String...) -> Double {
         addresses.reduce(0) { $0 + self[$1] }
     }

     func average(_ addresses: String...) -> Double {
         guard !addresses.isEmpty else { return 0 }
         return addresses.reduce(0) { $0 + self[$1] }
              / Double(addresses.count)
     }

     func max2(_ addresses: String...) -> Double {
         addresses.compactMap { cells[$0.uppercased()] }
                  .max() ?? 0
     }

     private func evaluate(formula: String) -> Double {
         // Simplified: parse SUM(A1,A2,A3) style:
         if formula.hasPrefix("SUM(") {
             let inner = formula.dropFirst(4).dropLast()
             let addrs = inner.split(separator: ",")
                              .map(String.init)
             return addrs.reduce(0) { $0 + self[$1] }
         }
         if formula.hasPrefix("AVG(") {
             let inner = formula.dropFirst(4).dropLast()
             let addrs = inner.split(separator: ",").map(String.init)
             guard !addrs.isEmpty else { return 0 }
             return addrs.reduce(0) { $0 + self[$1] }
                  / Double(addrs.count)
         }
         return Double(formula) ?? 0
     }

     func printSheet(rows: Int, cols: Int) {
         let colLetters = (0..<cols).map {
             String(UnicodeScalar(65 + $0)!)
         }
         // Header:
         let header = "     " + colLetters
             .map { String(format: "%-10s", $0) }
             .joined()
         print(header)
         for r in 1...rows {
             var line = String(format: "%-5d", r)
             for col in colLetters {
                 let addr  = "\(col)\(r)"
                 let val   = cells[addr]
                 let lbl   = labels[addr]
                 let disp  = lbl ?? (val.map { String(format:"%.1f",$0) } ?? "-")
                 line     += String(format: "%-10s", disp)
             }
             print(line)
         }
     }
 }

 var sheet = Spreadsheet()

 // Set labels:
 sheet[label: "A1"] = "Q1 Sales"
 sheet[label: "A2"] = "Q2 Sales"
 sheet[label: "A3"] = "Q3 Sales"
 sheet[label: "A4"] = "Q4 Sales"
 sheet[label: "A5"] = "TOTAL"

 // Set values:
 sheet["B1"] = 12500
 sheet["B2"] = 15800
 sheet["B3"] = 14200
 sheet["B4"] = 18900

 // Set formula:
 print("Setting formula:")
 sheet.setFormula("B5", formula: "SUM(B1,B2,B3,B4)")
 // Output: Setting formula:
 //           B5 = SUM(B1,B2,B3,B4) → 61400.0

 print(sheet["B5"])
 // Output: 61400.0

 print(sheet.average("B1", "B2", "B3", "B4"))
 // Output: 15350.0

 print(sheet.max2("B1", "B2", "B3", "B4"))
 // Output: 18900.0

 sheet.printSheet(rows: 5, cols: 2)
 // Output:      A         B
 //         1    Q1 Sales  12500.0
 //         2    Q2 Sales  15800.0
 //         3    Q3 Sales  14200.0
 //         4    Q4 Sales  18900.0
 //         5    TOTAL     61400.0


================================================================
PART 10 — INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
================================================================

================================================================
SECTION 1 — BASIC LEVEL
================================================================

Q1. What is the difference between
   a method and a function in Swift?
-----------------------------------------
A: Functions are standalone — not tied to any type.
  Methods belong to a type (class, struct, enum)
  and have access to self. Both share the same
  syntax and are first-class citizens.
  Example:
    // Standalone function:
    func double2(_ n: Int) -> Int { n * 2 }

    // Method — belongs to a type:
    struct Doubler {
        var factor: Int
        func apply(_ n: Int) -> Int { n * factor }
    }
    print(double2(5))
    // Output: 10
    let d = Doubler(factor: 3)
    print(d.apply(5))
    // Output: 15


Q2. What does mutating mean for
   a struct method?
-----------------------------------------
A: Structs are value types — immutable by default.
  mutating marks a method that is allowed to
  modify self or its stored properties.
  The compiler treats it as an inout parameter.
  Example:
    struct Wallet {
        var balance: Double = 0
        mutating func add(_ amount: Double) {
            balance += amount
        }
        func total() -> Double { balance }
    }
    var w = Wallet()
    w.add(50)
    w.add(25)
    print(w.total())
    // Output: 75.0
    // let w2 = Wallet()
    // w2.add(10)   // Error — w2 is let, cannot mutate


Q3. What is a type method and how is
   it declared?
-----------------------------------------
A: A type method is called on the type itself,
  not on an instance. Declared with static
  (structs, enums) or class (classes, overridable).
  Inside it, self refers to the type.
  Example:
    struct Temperature {
        var celsius: Double
        static func fromFahrenheit(_ f: Double) -> Temperature {
            return Temperature(celsius: (f - 32) * 5/9)
        }
        static func fromKelvin(_ k: Double) -> Temperature {
            return Temperature(celsius: k - 273.15)
        }
    }
    let boiling = Temperature.fromFahrenheit(212)
    print(boiling.celsius)
    // Output: 100.0
    let absolute = Temperature.fromKelvin(0)
    print(absolute.celsius)
    // Output: -273.15


Q4. What is a subscript in Swift?
-----------------------------------
A: A subscript provides bracket-syntax access to
  elements. Defined with the subscript keyword.
  Can be read-only or read-write. Can take any
  parameter type and number of parameters.
  Example:
    struct Multiplier {
        let factor: Int
        subscript(n: Int) -> Int { n * factor }
    }
    let triple = Multiplier(factor: 3)
    print(triple[5])
    // Output: 15
    print(triple[10])
    // Output: 30


Q5. Can a subscript have a setter?
------------------------------------
A: Yes. A subscript with get and set is read-write.
  The setter receives newValue (or a custom name).
  Example:
    struct SettableGrid {
        private var data = [[0,0,0],[0,0,0],[0,0,0]]
        subscript(row: Int, col: Int) -> Int {
            get { data[row][col] }
            set { data[row][col] = newValue }
        }
    }
    var g = SettableGrid()
    g[1, 1] = 42
    print(g[1, 1])
    // Output: 42
    print(g[0, 0])
    // Output: 0


Q6. What is implicit self in a method?
----------------------------------------
A: Inside a method, you can access the instance's
  properties and methods without writing self.
  Swift injects self automatically. Explicit self
  is required only when a parameter name shadows
  a property name.
  Example:
    struct Box {
        var width: Double
        var height: Double
        // Implicit self.width and self.height:
        func area() -> Double { width * height }
        init(width: Double, height: Double) {
            // Explicit — parameter shadows property:
            self.width  = width
            self.height = height
        }
    }
    let b = Box(width: 3, height: 5)
    print(b.area())
    // Output: 15.0


Q7. Can enums have methods?
-----------------------------
A: Yes. Enums can have instance methods, type methods,
  computed properties, and mutating methods.
  They cannot have stored properties.
  Example:
    enum Coin { case penny, nickel, dime, quarter
        var value: Int {
            switch self {
            case .penny:   return 1
            case .nickel:  return 5
            case .dime:    return 10
            case .quarter: return 25
            }
        }
        static func total(_ coins: [Coin]) -> Int {
            coins.reduce(0) { $0 + $1.value }
        }
    }
    print(Coin.quarter.value)
    // Output: 25
    print(Coin.total([.quarter,.dime,.nickel,.penny]))
    // Output: 41


Q8. What is the difference between
   static and class for type methods?
-----------------------------------------
A: static — cannot be overridden by subclasses.
            Works on structs, enums, and classes.
  class  — can be overridden in subclasses.
            Only valid on classes.
  Example:
    class Shape {
        class  func describe() -> String { "Shape" }
        static func category() -> String { "Geometry" }
    }
    class Circle2: Shape {
        override class func describe() -> String { "Circle" }
        // Cannot override category() — it's static
    }
    print(Shape.describe())
    // Output: Shape
    print(Circle2.describe())
    // Output: Circle
    print(Circle2.category())
    // Output: Geometry


Q9. Can a subscript be read-only?
-----------------------------------
A: Yes. Omit the set block (or just write the
  return expression directly). The compiler treats
  the whole body as the getter.
  Example:
    struct TruthTable {
        // Read-only — just the expression:
        subscript(a: Bool, b: Bool) -> Bool {
            return a && b   // AND gate
        }
    }
    let tt = TruthTable()
    print(tt[true, true])
    // Output: true
    print(tt[true, false])
    // Output: false
    print(tt[false, false])
    // Output: false


Q10. Can you define multiple subscripts
    with different parameter types?
-----------------------------------------
A: Yes — subscript overloading. Swift resolves by
  matching the parameter types at the call site.
  Example:
    struct Lookup {
        private let data = ["a":1,"b":2,"c":3]
        private let arr  = [10, 20, 30]

        subscript(key: String) -> Int? { data[key]  }
        subscript(idx: Int)    -> Int  { arr[idx]   }
    }
    let lk = Lookup()
    print(lk["b"] ?? -1)
    // Output: 2
    print(lk[2])
    // Output: 30


Q11. What does defer do inside a method?
-----------------------------------------
A: defer schedules a block to run when the current
  scope exits — regardless of how it exits
  (return, throw, or falling off end).
  Multiple defers run in reverse declaration order.
  Example:
    func riskyOp(fail: Bool) -> String {
        defer { print("Cleanup always runs") }
        if fail { return "failed early" }
        return "success"
    }
    print(riskyOp(fail: true))
    // Output: Cleanup always runs
    //         failed early
    print(riskyOp(fail: false))
    // Output: Cleanup always runs
    //         success


Q12. Can a class method call an
    instance method?
-----------------------------------------
A: Not directly — a type method has no instance.
  It can create an instance and call a method on it,
  or call other type methods via self (the type).
  Example:
    struct Greeter {
        let name: String
        func greet() -> String { "Hello, \(name)!" }
        static func greetDefault() -> String {
            // Create instance, then call instance method:
            return Greeter(name: "World").greet()
        }
        static func greetAll(_ names: [String]) -> [String] {
            return names.map { Greeter(name: $0).greet() }
        }
    }
    print(Greeter.greetDefault())
    // Output: Hello, World!
    print(Greeter.greetAll(["Alice", "Bob"]))
    // Output: ["Hello, Alice!", "Hello, Bob!"]


Q13. How do you use subscripts with
    optional chaining?
-----------------------------------------
A: Add ? after the instance. If the instance or
  subscript returns nil, the whole chain short-
  circuits to nil. The result is always optional.
  Example:
    struct Config3 {
        private var data: [String: String] =
            ["host":"localhost","port":"8080"]
        subscript(key: String) -> String? { data[key] }
    }
    var config3: Config3? = Config3()
    print(config3?["host"] ?? "nil")
    // Output: localhost
    config3 = nil
    print(config3?["host"] ?? "nil")
    // Output: nil


Q14. What is method chaining and how
    is it achieved in Swift?
-----------------------------------------
A: Method chaining calls multiple methods on a
  single expression. Achieved by returning self
  (or Self) from each method so the next method
  can be called immediately on the result.
  Example:
    class Builder {
        private var parts: [String] = []
        @discardableResult
        func add(_ part: String) -> Builder {
            parts.append(part)
            return self
        }
        func build() -> String {
            parts.joined(separator: ", ")
        }
    }
    let result = Builder()
        .add("one")
        .add("two")
        .add("three")
        .build()
    print(result)
    // Output: one, two, three


Q15. Can you use a subscript on a
    type rather than an instance?
-----------------------------------------
A: Yes — static subscript (Swift 5.1+). Declared
  with the static keyword on the subscript.
  Called directly on the type: Type[key].
  Example:
    struct Env {
        private static var vars: [String:String] =
            ["HOME":"/Users/alice","SHELL":"/bin/zsh"]
        static subscript(key: String) -> String? {
            get { vars[key] }
            set { vars[key] = newValue }
        }
    }
    print(Env["HOME"] ?? "nil")
    // Output: /Users/alice
    Env["EDITOR"] = "vim"
    print(Env["EDITOR"] ?? "nil")
    // Output: vim


================================================================
SECTION 2 — INTERMEDIATE LEVEL
================================================================

Q16. How do methods and subscripts differ
    in protocol requirements?
-----------------------------------------
A: Methods in protocols declare func with optional
  mutating. Subscripts declare subscript with
  get (and optionally set). Both create requirements
  that conforming types must implement.
  Example:
    protocol Indexable {
        subscript(i: Int) -> String { get }
        func item(at index: Int) -> String
    }
    struct Words: Indexable {
        let words = ["apple","banana","cherry"]
        subscript(i: Int) -> String { words[i] }
        func item(at index: Int) -> String { words[index] }
    }
    let w = Words()
    print(w[1])
    // Output: banana
    print(w.item(at: 2))
    // Output: cherry


Q17. How does method dispatch work
    in classes vs structs?
-----------------------------------------
A: Structs — static dispatch. Resolved at compile
            time. Compiler can inline. Fastest.
  Classes  — dynamic dispatch via vtable. Resolved
            at runtime. Allows polymorphism.
  final class — static dispatch (no override).
  Example:
    struct StructOp  { func run() -> String { "struct" } }
    final class FinalOp { func run() -> String { "final class" } }
    class DynOp  {
        func run() -> String { "base class" }
    }
    class DynSub: DynOp {
        override func run() -> String { "subclass" }
    }

    let ops: [DynOp] = [DynOp(), DynSub()]
    ops.forEach { print($0.run()) }
    // Output: base class
    //         subclass
    // (resolved at runtime via vtable)

    print(StructOp().run())
    // Output: struct
    print(FinalOp().run())
    // Output: final class


Q18. How do you override a method
    in a subclass?
-----------------------------------------
A: Mark the base class method with open or leave
  it as a regular func (override-able within module).
  Subclass uses override keyword. super.method()
  calls the parent implementation.
  Example:
    class Logger2 {
        func log(_ msg: String) {
            print("[LOG] \(msg)")
        }
    }
    class TimedLogger: Logger2 {
        override func log(_ msg: String) {
            print("[TIMED \(Date().timeIntervalSince1970)] \(msg)")
            super.log(msg)      // call parent
        }
    }
    class PrefixLogger: Logger2 {
        var prefix: String
        init(prefix: String) { self.prefix = prefix }
        override func log(_ msg: String) {
            super.log("[\(prefix)] \(msg)")
        }
    }
    let pl = PrefixLogger(prefix: "AUTH")
    pl.log("User logged in")
    // Output: [LOG] [AUTH] User logged in


Q19. What is the difference between
    a computed property and a method
    with no parameters?
-----------------------------------------
A: Computed property — accessed like a stored
  property, no (). Communicates "this IS a value."
  Method — called with (). Communicates "this DOES
  something." Use properties for O(1) or cheap
  lookups. Use methods for expensive/side-effect work.
  Example:
    struct Circle3 {
        var radius: Double

        // Computed — just a value derived from radius:
        var diameter:    Double { radius * 2 }
        var area:        Double { Double.pi * radius * radius }

        // Method — implies action / notable computation:
        func scale(to newRadius: Double) -> Circle3 {
            return Circle3(radius: newRadius)
        }
        func intersects(_ other: Circle3,
                         at distance: Double) -> Bool {
            return distance < radius + other.radius
        }
    }
    let c3 = Circle3(radius: 5)
    print(c3.diameter)        // property — no ()
    // Output: 10.0
    print(c3.area)
    // Output: 78.539...
    print(c3.scale(to: 3).radius)
    // Output: 3.0


Q20. How do you prevent a method
    from being overridden?
-----------------------------------------
A: Mark it with final. This applies to individual
  methods or the entire class. Final enables the
  compiler to use static dispatch — faster.
  Example:
    class Authenticator {
        // Can be overridden:
        func validateInput(_ s: String) -> Bool { !s.isEmpty }

        // Cannot be overridden:
        final func hash(_ password: String) -> String {
            // Security-critical — must not be changed:
            return String(password.reversed()) + "_hashed"
        }
    }
    class MockAuth: Authenticator {
        override func validateInput(_ s: String) -> Bool {
            return true   // OK — not final
        }
        // override func hash(...)  // Error — hash is final
    }
    let auth = MockAuth()
    print(auth.validateInput(""))
    // Output: true
    print(auth.hash("secret"))
    // Output: terces_hashed


Q21. How do subscripts work with
    generics?
-----------------------------------------
A: Declare the subscript with type parameters
  or use the enclosing type's generic parameters.
  The subscript can also have its own type parameter
  for the return type (generic subscript).
  Example:
    struct Pair<A, B> {
        var first:  A
        var second: B

        // Subscript using Bool to pick A or B
        // (cannot use generic return here easily —
        // use KeyPath instead):
        subscript<T>(path: KeyPath<Pair<A,B>, T>) -> T {
            return self[keyPath: path]
        }
    }
    let pair = Pair(first: "hello", second: 42)
    print(pair[\.first])
    // Output: hello
    print(pair[\.second])
    // Output: 42


Q22. How do mutating and nonmutating
    interact with properties?
-----------------------------------------
A: A computed property's get is nonmutating.
  Its set is mutating. You can mark a get
  as mutating or a set as nonmutating explicitly.
  nonmutating set means the setter does NOT
  modify self (e.g., writes to an external store).
  Example:
    struct UserDefaults2 {
        var key: String

        var value: String {
            get { UserDefaults.standard.string(forKey: key) ?? "" }
            nonmutating set { UserDefaults.standard
                .set(newValue, forKey: key) }
            // nonmutating set — doesn't change self,
            // writes to external storage
        }
    }
    // (Real usage requires Foundation — concept demo)
    // The struct can be let and still have set called:
    let ud = UserDefaults2(key: "username")
    // ud.value = "Alice"  // allowed on let — nonmutating set


Q23. What is self-assignment safety
    in mutating methods?
-----------------------------------------
A: In Swift, mutating methods can freely assign new
  values to self without risk. The compiler ensures
  the old value is properly discarded and the new
  one is written back to the original storage.
  Example:
    struct Signal {
        var samples: [Double]

        mutating func normalize() {
            guard let max3 = samples.max(), max3 > 0 else { return }
            // Safe to read self.samples while creating new self:
            self = Signal(samples: samples.map { $0 / max3 })
        }

        mutating func append(contentsOf other: Signal) {
            // Safe — ARC/copy semantics handle this:
            samples += other.samples
        }
    }

    var sig = Signal(samples: [2.0, 4.0, 6.0, 8.0])
    sig.normalize()
    print(sig.samples)
    // Output: [0.25, 0.5, 0.75, 1.0]


Q24. How do you implement a subscript
    that supports both String and Int keys?
-----------------------------------------
A: Overload the subscript — one taking String,
  one taking Int. Swift resolves at call site.
  Alternatively, use a generic subscript with
  a protocol constraint.
  Example:
    struct FlexStore {
        private var byString: [String: String] = [:]
        private var byInt:    [Int: String]    = [:]

        subscript(key: String) -> String? {
            get { byString[key] }
            set { byString[key] = newValue }
        }
        subscript(key: Int) -> String? {
            get { byInt[key] }
            set { byInt[key] = newValue }
        }
    }
    var fs = FlexStore()
    fs["name"]  = "Alice"
    fs[42]      = "The answer"
    print(fs["name"] ?? "nil")
    // Output: Alice
    print(fs[42] ?? "nil")
    // Output: The answer


Q25. How do methods support
    default parameter values?
-----------------------------------------
A: Methods support default parameter values
  exactly like functions. A method with defaults
  can be called with fewer arguments.
  Multiple overloads are NOT needed.
  Example:
    struct Paginator {
        var totalItems: Int

        func page(_ number: Int,
                  size: Int = 20,
                  offset: Int = 0) -> (start: Int, end: Int) {
            let start = (number - 1) * size + offset
            let end   = min(start + size, totalItems)
            return (start, end)
        }
    }
    let pg = Paginator(totalItems: 100)
    print(pg.page(1))
    // Output: (start: 0, end: 20)
    print(pg.page(2))
    // Output: (start: 20, end: 40)
    print(pg.page(1, size: 10))
    // Output: (start: 0, end: 10)
    print(pg.page(3, size: 10, offset: 5))
    // Output: (start: 25, end: 35)


================================================================
SECTION 3 — ADVANCED LEVEL
================================================================

Q26. How does Swift implement method
    dispatch for protocol extensions?
-----------------------------------------
A: Protocol extension methods are statically
  dispatched — the extension provides a default
  implementation. If a type also provides the
  same method, which one runs depends on whether
  it's in the protocol requirement or extension.
  Requirement — dynamic dispatch (witness table).
  Extension only — static dispatch.
  Example:
    protocol Describable3 {
        func describe() -> String    // requirement
        func verbose()  -> String    // NOT a requirement
    }
    extension Describable3 {
        func describe() -> String { "default describe" }
        func verbose()  -> String { "default verbose" }
    }
    struct MyType2: Describable3 {
        func describe() -> String { "MyType2 describe" }
        func verbose()  -> String { "MyType2 verbose"  }
    }
    let concrete = MyType2()
    let asProto:   any Describable3 = MyType2()

    print(concrete.describe())
    // Output: MyType2 describe   (static — concrete type)
    print(concrete.verbose())
    // Output: MyType2 verbose    (static)

    print(asProto.describe())
    // Output: MyType2 describe   (dynamic — in requirement)
    print(asProto.verbose())
    // Output: default verbose    (static — NOT in requirement)


Q27. What is the difference between
    mutating func and taking inout?
-----------------------------------------
A: mutating func — method on a value type that can
  modify self. The whole instance may change.
  inout parameter — passes a variable by reference
  into any function or method. Modifies the caller's
  variable. Can appear in any function, not just methods.
  Example:
    struct Vec {
        var x: Double, y: Double

        // mutating — modifies self:
        mutating func add(_ other: Vec) {
            x += other.x; y += other.y
        }
    }

    // inout — modifies caller's variable:
    func normalize2(_ v: inout Vec) {
        let len = (v.x*v.x + v.y*v.y).squareRoot()
        if len > 0 { v.x /= len; v.y /= len }
    }

    var v = Vec(x: 3, y: 4)
    v.add(Vec(x: 1, y: 1))
    print(v.x, v.y)
    // Output: 4.0 5.0

    normalize2(&v)
    print(String(format:"%.4f %.4f", v.x, v.y))
    // Output: 0.6247 0.7809


Q28. How do you write a method that
    accepts a metatype as a parameter?
-----------------------------------------
A: Use T.Type (concrete metatype) or any T.Type
  (existential metatype). Pass with Type.self.
  Common for factory methods and type-based dispatch.
  Example:
    protocol Buildable { init() }

    struct ServiceLocator {
        private var services: [ObjectIdentifier: Any] = [:]

        mutating func register<T: Buildable>(_ type2: T.Type) {
            let key = ObjectIdentifier(type2)
            services[key] = type2.init()
            print("Registered: \(type2)")
        }

        func resolve<T>(_ type2: T.Type) -> T? {
            return services[ObjectIdentifier(type2)] as? T
        }
    }

    struct AuthService:  Buildable { init() {} }
    struct CacheService: Buildable { init() {} }

    var locator = ServiceLocator()
    locator.register(AuthService.self)
    // Output: Registered: AuthService
    locator.register(CacheService.self)
    // Output: Registered: CacheService

    let auth = locator.resolve(AuthService.self)
    print(auth != nil ? "AuthService resolved" : "not found")
    // Output: AuthService resolved


Q29. How do you build a method that
    returns Self for protocol-oriented
    method chaining?
-----------------------------------------
A: Use Self (capital S) as the return type.
  Self refers to the actual conforming type,
  not the protocol. Required for value types
  where a concrete copy must be returned.
  Example:
    protocol Configurable {
        func configured(with key: String,
                         value: Any) -> Self
    }

    struct AppOptions: Configurable {
        private var dict: [String: Any] = [:]

        func configured(with key: String,
                         value: Any) -> AppOptions {
            var copy = self
            copy.dict[key] = value
            return copy
        }

        func value(for key: String) -> Any? { dict[key] }
    }

    let opts = AppOptions()
        .configured(with: "debug",   value: true)
        .configured(with: "version", value: "2.0")
        .configured(with: "timeout", value: 30)

    print(opts.value(for: "debug")   ?? "nil")
    // Output: true
    print(opts.value(for: "version") ?? "nil")
    // Output: 2.0
    print(opts.value(for: "timeout") ?? "nil")
    // Output: 30


Q30. How does method visibility affect
    overriding and dispatch?
-----------------------------------------
A: private/fileprivate — cannot be overridden
  (visibility too restricted for subclass).
  internal — overridable within the module.
  open — overridable from outside the module.
  final — not overridable regardless of visibility.
  Example:
    class Base {
        open     func openMethod()     -> String { "base open" }
        func     internalMethod()      -> String { "base internal" }
        private  func privateMethod()  -> String { "base private" }
        final    func finalMethod()    -> String { "base final" }
    }

    class Sub: Base {
        override func openMethod()    -> String { "sub open" }
        override func internalMethod()-> String { "sub internal" }
        // Cannot override privateMethod — not visible
        // Cannot override finalMethod — marked final
    }

    let s: Base = Sub()
    print(s.openMethod())
    // Output: sub open
    print(s.internalMethod())
    // Output: sub internal
    print(s.finalMethod())
    // Output: base final


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q31. How does Swift implement vtable
    dispatch for class methods?
-----------------------------------------
A: Every Swift class has a vtable — an array of
  function pointers, one per overridable method.
  A method call on a class instance reads the
  vtable slot for that method and calls the pointer.
  Subclasses replace vtable slots for overridden
  methods. Protocol witness tables (PWT) work
  similarly for protocol conformances.
  Example:
    class Base2 {
        func method() -> String { "Base2" }
    }
    class Mid: Base2 {
        override func method() -> String { "Mid" }
    }
    class Leaf: Mid {
        override func method() -> String { "Leaf" }
    }

    // Each object's vtable slot for method() points to
    // the most-derived override:
    let objects: [Base2] = [Base2(), Mid(), Leaf()]
    objects.forEach { print($0.method()) }
    // Output: Base2
    //         Mid
    //         Leaf


Q32. How do you write a thread-safe
    method using property wrappers?
-----------------------------------------
A: Use a concurrent DispatchQueue with barriers
  for writes. Reads are concurrent (fast).
  Writes use .barrier (exclusive access).
  Wrap it in a property wrapper for reuse.
  Example:
    @propertyWrapper
    final class Protected<T> {
        private var value: T
        private let queue = DispatchQueue(
            label: "protected.queue",
            attributes: .concurrent)

        init(wrappedValue: T) { value = wrappedValue }

        var wrappedValue: T {
            get { queue.sync { value } }
            set { queue.async(flags: .barrier) {
                [weak self] in self?.value = newValue }
            }
        }
    }

    class SharedCounter {
        @Protected var count = 0

        func increment() { count += 1 }
        func reset()     { count  = 0 }
    }

    let counter2 = SharedCounter()
    let group    = DispatchGroup()

    for _ in 0..<100 {
        group.enter()
        DispatchQueue.global().async {
            counter2.increment()
            group.leave()
        }
    }
    group.wait()
    print(counter2.count)
    // Output: 100   (thread-safe — no race condition)


Q33. How do methods interact with
    @discardableResult?
-----------------------------------------
A: By default Swift warns if you call a method
  that returns a value and discard the result.
  @discardableResult suppresses that warning.
  Use it when the return value is optional context
  (e.g., builder methods, logging).
  Example:
    struct Pipeline {
        private var steps: [String] = []

        @discardableResult
        mutating func add(step: String) -> Pipeline {
            steps.append(step)
            return self
        }

        func run() {
            steps.forEach { print("Running: \($0)") }
        }
    }

    var p = Pipeline()
    p.add(step: "Fetch")       // no warning — result ignored
    p.add(step: "Parse")
    p.add(step: "Save")
    p.run()
    // Output: Running: Fetch
    //         Running: Parse
    //         Running: Save

    // Also usable as chain:
    var p2 = Pipeline()
    p2.add(step: "Step1").add(step: "Step2").run()
    // Output: Running: Step1
    //         Running: Step2


Q34. How do you implement copy-on-write
    in a method?
-----------------------------------------
A: Check isKnownUniquelyReferenced on the backing
  reference. If not unique, copy before mutating.
  This is how Swift's standard library implements
  Array, Dictionary, and String.
  Example:
    final class Storage<T> {
        var data: [T]
        init(_ data: [T]) { self.data = data }
        init(copying other: Storage<T>) {
            self.data = other.data
        }
    }

    struct COWArray<T> {
        private var storage: Storage<T>

        init(_ data: [T] = []) {
            storage = Storage(data)
        }

        // Copy-on-write before any mutation:
        private mutating func ensureUnique() {
            if !isKnownUniquelyReferenced(&storage) {
                print("  COW: copying storage")
                storage = Storage(copying: storage)
            }
        }

        mutating func append(_ value: T) {
            ensureUnique()
            storage.data.append(value)
        }

        mutating func remove(at index: Int) {
            ensureUnique()
            storage.data.remove(at: index)
        }

        var count: Int     { storage.data.count }
        var all:   [T]     { storage.data       }
        subscript(i: Int) -> T { storage.data[i] }
    }

    var a = COWArray([1, 2, 3])
    var b = a       // shares storage — no copy yet
    print(a.all)
    // Output: [1, 2, 3]
    b.append(4)     // triggers copy
    // Output:   COW: copying storage
    print(a.all)
    // Output: [1, 2, 3]   (a unchanged)
    print(b.all)
    // Output: [1, 2, 3, 4]


Q35. How do you implement a memoized
 method in Swift?
-----------------------------------------
A: Store previously computed results in a cache
(dictionary). On each call, check the cache
first. Only compute if not yet cached.
Use a class (reference type) or mutating method
in a struct to store the cache.
Example:
 final class Memoizer<Input: Hashable, Output> {
     private var cache: [Input: Output] = [:]
     private let compute: (Input) -> Output

     init(_ compute: @escaping (Input) -> Output) {
         self.compute = compute
     }

     func call(_ input: Input) -> Output {
         if let cached = cache[input] {
             return cached
         }
         let result = compute(input)
         cache[input] = result
         return result
     }
 }

 // Memoized fibonacci:
 let fib2 = Memoizer<Int, Int> { n in
     // Note: for recursive memoization use a
     // class-based approach so closure can call self:
     if n <= 1 { return n }
     var a = 0, b = 1
     for _ in 2...n { let t = a + b; a = b; b = t }
     return b
 }

 print(fib2.call(10))
 // Output: 55
 print(fib2.call(20))
 // Output: 6765
 print(fib2.call(10))
 // Output: 55   (from cache — not recomputed)

 // Struct with mutating memoization:
 struct ExpensiveCalc {
     private var cache: [Int: Int] = [:]

     mutating func compute(_ n: Int) -> Int {
         if let cached = cache[n] { return cached }
         print("  Computing for \(n)...")
         let result = (1...n).reduce(1, *)   // n!
         cache[n] = result
         return result
     }
 }

 var calc = ExpensiveCalc()
 print(calc.compute(5))
 // Output:   Computing for 5...
 //           120
 print(calc.compute(5))
 // Output: 120   (cached — no recompute message)
 print(calc.compute(6))
 // Output:   Computing for 6...
 //           720


Q36. How do you implement method
 interception / AOP-style wrappers?
-----------------------------------------
A: Swift has no runtime AOP. Simulate it using
closures, protocols, or wrapper types that
intercept method calls before/after delegation.
Example:
 protocol Service {
     func execute(request: String) -> String
 }

 struct RealService: Service {
     func execute(request: String) -> String {
         return "Result for: \(request)"
     }
 }

 // Logging interceptor:
 struct LoggingService: Service {
     private let inner: Service
     init(_ inner: Service) { self.inner = inner }

     func execute(request: String) -> String {
         print("[LOG] Before: \(request)")
         let result = inner.execute(request: request)
         print("[LOG] After: \(result)")
         return result
     }
 }

 // Timing interceptor:
 struct TimingService: Service {
     private let inner: Service
     init(_ inner: Service) { self.inner = inner }

     func execute(request: String) -> String {
         let start  = Date()
         let result = inner.execute(request: request)
         let ms     = Date().timeIntervalSince(start) * 1000
         print(String(format: "[TIME] %.3fms", ms))
         return result
     }
 }

 // Caching interceptor:
 final class CachingService: Service {
     private let inner: Service
     private var cache: [String: String] = [:]
     init(_ inner: Service) { self.inner = inner }

     func execute(request: String) -> String {
         if let cached = cache[request] {
             print("[CACHE] HIT: \(request)")
             return cached
         }
         print("[CACHE] MISS: \(request)")
         let result = inner.execute(request: request)
         cache[request] = result
         return result
     }
 }

 // Stack interceptors: cache → log → real:
 let service: Service = CachingService(
                          LoggingService(
                            RealService()))

 print(service.execute(request: "query1"))
 // Output: [CACHE] MISS: query1
 //         [LOG] Before: query1
 //         [LOG] After: Result for: query1
 //         Result for: query1

 print(service.execute(request: "query1"))
 // Output: [CACHE] HIT: query1
 //         Result for: query1   (no log — served from cache)


Q37. How do subscripts relate to
 Swift's KeyPath machinery?
-----------------------------------------
A: KeyPaths are strongly typed references to
properties. You can subscript any instance
with a KeyPath using [keyPath:]. WritableKeyPath
allows mutation. ReferenceWritableKeyPath
allows mutation via a class reference.
Example:
 struct Person {
     var name:  String
     var age:   Int
     var email: String
 }

 // Read via KeyPath subscript:
 let alice = Person(name: "Alice", age: 28, email: "a@x.com")
 let nameKP: KeyPath<Person, String> = \.name

 print(alice[keyPath: nameKP])
 // Output: Alice
 print(alice[keyPath: \.age])
 // Output: 28

 // Write via WritableKeyPath:
 var bob = Person(name: "Bob", age: 32, email: "b@x.com")
 let writeName: WritableKeyPath<Person, String> = \.name
 bob[keyPath: writeName] = "Robert"
 print(bob.name)
 // Output: Robert

 // Generic function using KeyPath:
 func extract<T, V>(from items: [T],
                     keyPath: KeyPath<T, V>) -> [V] {
     return items.map { $0[keyPath: keyPath] }
 }

 let people = [alice, bob]
 print(extract(from: people, keyPath: \.name))
 // Output: ["Alice", "Robert"]
 print(extract(from: people, keyPath: \.age))
 // Output: [28, 32]

 // KeyPath composition:
 struct Team {
     var lead: Person
     var name: String
 }
 let team = Team(lead: alice, name: "iOS")
 let leadName = \Team.lead.name   // composed KeyPath
 print(team[keyPath: leadName])
 // Output: Alice


Q38. How do you implement a
 type-safe event system using
 methods and subscripts?
-----------------------------------------
A: Use a generic event bus. Store handlers
keyed by type identity. Subscript provides
ergonomic publish/subscribe syntax.
Example:
 struct EventBus {
     private var handlers:
         [ObjectIdentifier: [(Any) -> Void]] = [:]

     mutating func subscribe<E>(
         to eventType: E.Type,
         handler: @escaping (E) -> Void
     ) {
         let key = ObjectIdentifier(eventType)
         let wrapper: (Any) -> Void = { event in
             if let e = event as? E { handler(e) }
         }
         handlers[key, default: []].append(wrapper)
     }

     func publish<E>(_ event: E) {
         let key = ObjectIdentifier(E.self)
         handlers[key]?.forEach { $0(event) }
     }

     // Subscript syntax for publishing:
     subscript<E>(eventType: E.Type) -> (E) -> Void {
         return { [self] event in
             self.publish(event)
         }
     }
 }

 struct UserLoggedIn  { let username: String }
 struct UserLoggedOut { let username: String; let reason: String }
 struct DataFetched   { let count: Int }

 var bus = EventBus()

 bus.subscribe(to: UserLoggedIn.self) { event in
     print("[Auth] \(event.username) logged in")
 }
 bus.subscribe(to: UserLoggedIn.self) { event in
     print("[Audit] Login recorded: \(event.username)")
 }
 bus.subscribe(to: UserLoggedOut.self) { event in
     print("[Auth] \(event.username) out — \(event.reason)")
 }
 bus.subscribe(to: DataFetched.self) { event in
     print("[Data] Received \(event.count) records")
 }

 bus.publish(UserLoggedIn(username: "alice"))
 // Output: [Auth] alice logged in
 //         [Audit] Login recorded: alice

 bus.publish(DataFetched(count: 42))
 // Output: [Data] Received 42 records

 bus.publish(UserLoggedOut(username: "alice",
                            reason: "timeout"))
 // Output: [Auth] alice out — timeout

 // Subscript publish syntax:
 bus[UserLoggedIn.self](UserLoggedIn(username: "bob"))
 // Output: [Auth] bob logged in
 //         [Audit] Login recorded: bob


Q39. How do methods enable
 phantom types for compile-time
 state enforcement?
-----------------------------------------
A: Phantom types use generic type parameters that
exist only to carry compile-time state. Methods
are defined only on specific phantom-type
configurations — invalid state transitions
become compile errors.
Example:
 // Phantom type markers — uninhabited, never instantiated:
 enum Open    {}
 enum Closed  {}
 enum Locked  {}

 struct Door<State> {
     private let id: String
     private init(id: String) { self.id = id }

     // Only creatable as Closed:
     static func make(id: String) -> Door<Closed> {
         print("Door \(id): created (closed)")
         return Door<Closed>(id: id)
     }
 }

 // Methods only available in correct state:
 extension Door where State == Closed {
     func open() -> Door<Open> {
         print("Door \(id): opened")
         return Door<Open>(id: id)
     }
     func lock() -> Door<Locked> {
         print("Door \(id): locked")
         return Door<Locked>(id: id)
     }
 }

 extension Door where State == Open {
     func close() -> Door<Closed> {
         print("Door \(id): closed")
         return Door<Closed>(id: id)
     }
 }

 extension Door where State == Locked {
     func unlock() -> Door<Closed> {
         print("Door \(id): unlocked")
         return Door<Closed>(id: id)
     }
 }

 let door  = Door.make(id: "front")
 // Output: Door front: created (closed)
 let open  = door.open()
 // Output: Door front: opened
 let shut  = open.close()
 // Output: Door front: closed
 let locked = shut.lock()
 // Output: Door front: locked
 let unlocked = locked.unlock()
 // Output: Door front: unlocked

 // These would be compile errors:
 // door.close()      // Error — Door<Closed> has no close()
 // open.lock()       // Error — Door<Open>   has no lock()
 // locked.open()     // Error — Door<Locked> has no open()


Q40. How do methods and subscripts
 work with result builders?
-----------------------------------------
A: Result builders (@resultBuilder) allow DSL-style
syntax where method calls become building blocks.
Methods on the builder transform the results.
Subscripts on the built product provide ergonomic
access to the resulting data structure.
Example:
 @resultBuilder
 struct HTMLBuilder {
     static func buildBlock(_ parts: String...) -> String {
         parts.joined(separator: "\n")
     }
     static func buildIf(_ part: String?) -> String {
         part ?? ""
     }
     static func buildEither(first: String) -> String {
         first
     }
     static func buildEither(second: String) -> String {
         second
     }
 }

 func div(class cls: String,
           @HTMLBuilder content: () -> String) -> String {
     "<div class=\"\(cls)\">\n\(content())\n</div>"
 }

 func p(_ text: String) -> String { "<p>\(text)</p>" }
 func h1(_ text: String) -> String { "<h1>\(text)</h1>" }
 func span(_ text: String) -> String { "<span>\(text)</span>" }

 struct Page {
     let html: String

     init(title: String,
          showHeader: Bool,
          @HTMLBuilder content: () -> String) {
         let header = showHeader ? h1(title) : ""
         let body   = content()
         html = div(class: "page") {
             header
             body
         }
     }

     // Subscript to extract sections by tag:
     subscript(tag: String) -> [String] {
         let pattern = "<\(tag)>(.*?)</\(tag)>"
         guard let regex = try? NSRegularExpression(
             pattern: pattern) else { return [] }
         let range = NSRange(html.startIndex...,
                              in: html)
         return regex.matches(in: html, range: range)
             .compactMap {
                 Range($0.range(at: 1), in: html)
                     .map { String(html[$0]) }
             }
     }
 }

 let page = Page(title: "Dashboard", showHeader: true) {
     p("Welcome to your dashboard")
     p("You have 3 new messages")
     span("Status: Active")
 }

 print(page.html)
 // Output: <div class="page">
 //         <h1>Dashboard</h1>
 //         <p>Welcome to your dashboard</p>
 //         <p>You have 3 new messages</p>
 //         <span>Status: Active</span>
 //         </div>

 print(page["p"])
 // Output: ["Welcome to your dashboard",
 //          "You have 3 new messages"]


================================================================
PART 11 — COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

INSTANCE METHODS
Task                               | Code
-----------------------------------|------------------------------------------
Declare instance method            | func name(param: Type) -> ReturnType { }
Call instance method               | instance.name(param: value)
Access properties in method        | value  or  self.value
Required self (shadowed param)     | self.name = name
Mutating method (struct/enum)      | mutating func name() { self.x = ... }
Completely replace self            | mutating func f() { self = NewValue() }
Return self for chaining (class)   | func f() -> MyClass { ...; return self }
Return copy for chaining (struct)  | func f() -> MyStruct { var s=self; ...; return s }
Method with default param          | func f(x: Int = 0) { }
Suppress return-value warning      | @discardableResult func f() -> Int { }
Method as value (bound)            | let fn = instance.methodName
Method as value (unbound/curried)  | let fn = MyType.methodName
defer in method                    | defer { /* runs on scope exit */ }

TYPE METHODS
Task                               | Code
-----------------------------------|------------------------------------------
Declare static method (struct)     | static func name() -> T { }
Declare static method (class)      | static func name() -> T { }
Declare overridable type method    | class func name() -> T { }
Override type method               | override class func name() -> T { }
Call type method                   | TypeName.name()
self inside type method            | self refers to the TYPE, not instance
Type method calling type method    | OtherTypeMethod() or self.OtherMethod()
Type method creating instance      | return MyType(value: x)
Singleton pattern                  | static let shared = MyClass()
Factory method                     | static func make(x: Int) -> MyType { }
Prevent override                   | final static func or final class func

MUTATING METHODS
Task                               | Code
-----------------------------------|------------------------------------------
Modify property                    | mutating func f() { self.x = newValue }
Replace self entirely              | mutating func f() { self = NewInstance }
Protocol mutating requirement      | mutating func f() in protocol
Class conforming to protocol       | no mutating needed for class
Let instance — cannot mutate       | let s = MyStruct(); s.mutating()  // Error
Var instance — can mutate          | var s = MyStruct(); s.mutating()  // OK

SUBSCRIPTS
Task                               | Code
-----------------------------------|------------------------------------------
Declare read-write subscript       | subscript(i: Int) -> T { get { } set { } }
Declare read-only subscript        | subscript(i: Int) -> T { return ... }
Two-param subscript                | subscript(r: Int, c: Int) -> T { }
Call subscript                     | instance[i]  or  instance[r, c]
Labeled subscript param            | subscript(row r: Int) -> [T] { }
Call labeled subscript             | instance[row: 2]
Static (type) subscript            | static subscript(key: K) -> V { }
Call static subscript              | TypeName[key]
Subscript with default value       | subscript(k: K, default d: V) -> V { }
Generic subscript                  | subscript<T>(kp: KeyPath<Self,T>) -> T { }
Overloaded subscripts              | Multiple subscript with diff param types
Optional chaining with subscript   | instance?[key]
@dynamicMemberLookup subscript     | subscript(dynamicMember key: String) -> T

METHOD DISPATCH RULES
Context                            | Dispatch Type
-----------------------------------|------------------------------------------
Struct method                      | Static (compile-time)
Enum method                        | Static (compile-time)
final class method                 | Static (compile-time)
Class method (non-final)           | Dynamic via vtable (runtime)
Protocol method — requirement      | Dynamic via witness table (runtime)
Protocol extension — no requirement| Static (compile-time)
Generic <T: Protocol>              | Static (monomorphized at compile time)
Existential any Protocol           | Dynamic via witness table

COMMON METHOD PATTERNS
Pattern                            | Technique
-----------------------------------|------------------------------------------
Factory                            | static func create(...) -> Self
Singleton                          | static let shared = MyClass()
Builder (class)                    | func set(...) -> Self { ...; return self }
Builder (struct)                   | func with(...) -> Self { var c=self; ...; return c }
Command                            | enum with associated values + execute()
State machine                      | mutating func transition(to:)
Memoization                        | cache dict + mutating method check
Copy-on-write                      | isKnownUniquelyReferenced + copy
Decorator/Interceptor              | Wrap type conforming to same protocol
AOP-style logging                  | Wrapper type delegating to inner
Phantom type state enforcement     | Extension where State == Marker

COMMON SUBSCRIPT PATTERNS
Pattern                            | Technique
-----------------------------------|------------------------------------------
Safe index                         | guard index < count else { return nil }
Default value                      | subscript(k: K, default d: V) -> V
Range access                       | subscript(r: Range<Int>) -> [T]
Nested/chained access              | subscript(path: String...) -> Any?
Type-safe generic access           | subscript<T>(k: K, as: T.Type) -> T?
Enum JSON value access             | subscript(key: String) -> JSONValue?
Static registry access             | static subscript(key: String) -> Any?
Dynamic member lookup              | @dynamicMemberLookup + subscript(dynamicMember:)
KeyPath subscript                  | subscript<T>(kp: KeyPath<Self,T>) -> T
Transformation on access           | subscript(i: Int, transform f: (T)->U) -> U

SUBSCRIPT vs METHOD vs COMPUTED PROPERTY
Feature                            | Subscript | Method    | Computed Property
-----------------------------------|-----------|-----------|-------------------
Called with ()                     | No        | Yes       | No
Uses bracket syntax []             | Yes       | No        | No
Takes parameters                   | Yes       | Yes       | No
Can be overloaded                  | Yes       | Yes       | No
Can be static                      | Yes       | Yes       | Yes
Can be mutating                    | Yes       | Yes       | Yes (set)
Can be read-only                   | Yes       | Yes       | Yes (get only)
Can be in protocol                 | Yes       | Yes       | Yes
Communicates "element access"      | Yes       | No        | Sometimes

METHODS ON STANDARD SWIFT TYPES
Type          | Key Method Patterns
--------------|------------------------------------------------------------
Array         | append, insert, remove, sort, map, filter, reduce
Dictionary    | updateValue, removeValue, mapValues, filter
String        | hasPrefix, contains, split, components, replacingOccurrences
Set           | insert, remove, union, intersection, isSubset
Optional      | map, flatMap, compactMap (via chain)
Result        | map, flatMap, mapError, get()
DispatchQueue | sync, async, asyncAfter

SELF AND SELF IN METHODS
Context                            | What self Refers To
-----------------------------------|------------------------------------------
Instance method                    | The current instance
Type method (static/class)         | The metatype (the Type itself)
Protocol extension                 | The conforming instance
Protocol static extension          | The conforming type
Class init                         | The new instance being initialized
Closure capturing self             | The instance (reference — capture carefully)

 */
