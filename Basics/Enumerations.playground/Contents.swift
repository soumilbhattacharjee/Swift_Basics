import UIKit

/*
 ENUMERATIONS IN SWIFT
 ===========================================================
 RAW VALUES, ASSOCIATED VALUES,
 RECURSIVE ENUMS / INDIRECT
 ALL LEVELS: BASIC → INTERMEDIATE → ADVANCED → EXPERT
 COMPLETE GUIDE + INTERVIEW Q&A WITH OUTPUTS
 ===========================================================


 ================================================================
 PART 1 — ENUMERATIONS FUNDAMENTALS
 ================================================================

 WHAT IS AN ENUMERATION?
 ========================
 An enumeration (enum) is a value type that defines
 a finite set of named cases. Each case represents
 a distinct, meaningful value. Enums in Swift are
 more powerful than in most languages — they can
 have methods, computed properties, associated values,
 raw values, and even be recursive.

 ENUM MEMORY MODEL
 ==================
   - Enum is a VALUE TYPE (like struct)
   - Copied on assignment — no reference counting
   - Stored on the stack (unless boxed in a class)
   - Size = largest associated value + tag byte(s)
   - No inheritance (but can conform to protocols)
   - Cannot define stored instance properties
   - CAN define computed properties and methods

 SWIFT ENUM vs C ENUM
 =====================
   C enum      — integer constants. No methods.
                 No associated data. Weak type safety.
   Swift enum  — first-class type. Methods allowed.
                 Associated values. Pattern matching.
                 Protocols, generics, recursive cases.

 BASIC ENUM DECLARATION
 =======================
   enum Direction {
       case north
       case south
       case east
       case west
   }

   // Or compact form:
   enum Season { case spring, summer, autumn, winter }

   var heading = Direction.north
   print(heading)
   // Output: north

   heading = .east          // type inferred — short dot syntax
   print(heading)
   // Output: east

 USING ENUMS
 ============
   enum Planet {
       case mercury, venus, earth, mars
       case jupiter, saturn, uranus, neptune
   }

   let home = Planet.earth
   print(home)
   // Output: earth

   // Switch over enum — must be exhaustive:
   func describe(planet: Planet) -> String {
       switch planet {
       case .mercury: return "Closest to the Sun"
       case .venus:   return "Hottest planet"
       case .earth:   return "Our home"
       case .mars:    return "The Red Planet"
       case .jupiter: return "Largest planet"
       case .saturn:  return "Has rings"
       case .uranus:  return "Rotates sideways"
       case .neptune: return "Farthest from the Sun"
       }
   }
   print(describe(planet: .earth))
   // Output: Our home
   print(describe(planet: .saturn))
   // Output: Has rings

 ENUM WITH METHODS
 ==================
   enum CompassPoint {
       case north, south, east, west

       func opposite() -> CompassPoint {
           switch self {
           case .north: return .south
           case .south: return .north
           case .east:  return .west
           case .west:  return .east
           }
       }

       func isVertical() -> Bool {
           return self == .north || self == .south
       }

       var description: String {
           switch self {
           case .north: return "North ↑"
           case .south: return "South ↓"
           case .east:  return "East →"
           case .west:  return "West ←"
           }
       }
   }

   let dir = CompassPoint.north
   print(dir.description)
   // Output: North ↑
   print(dir.opposite().description)
   // Output: South ↓
   print(dir.isVertical())
   // Output: true
   print(CompassPoint.east.opposite().description)
   // Output: West ←

 ENUM WITH STATIC MEMBERS
 =========================
   enum Weekday {
       case monday, tuesday, wednesday, thursday
       case friday, saturday, sunday

       static let weekdays: [Weekday] = [
           .monday, .tuesday, .wednesday, .thursday, .friday
       ]
       static let weekend: [Weekday] = [.saturday, .sunday]

       var isWeekend: Bool {
           return self == .saturday || self == .sunday
       }

       static func from(dayNumber: Int) -> Weekday? {
           let all: [Weekday] = [
               .monday, .tuesday, .wednesday,
               .thursday, .friday, .saturday, .sunday
           ]
           guard dayNumber >= 1 && dayNumber <= 7 else { return nil }
           return all[dayNumber - 1]
       }
   }

   print(Weekday.friday.isWeekend)
   // Output: false
   print(Weekday.saturday.isWeekend)
   // Output: true
   print(Weekday.weekdays.count)
   // Output: 5
   print(Weekday.from(dayNumber: 3) ?? "invalid")
   // Output: wednesday
   print(Weekday.from(dayNumber: 9) ?? "invalid")
   // Output: invalid

 ENUM WITH MUTATING METHOD
 ==========================
   enum TrafficLight {
       case red, yellow, green

       mutating func next() {
           switch self {
           case .red:    self = .green
           case .green:  self = .yellow
           case .yellow: self = .red
           }
       }

       var canGo: Bool {
           self == .green
       }
   }

   var light = TrafficLight.red
   print(light)
   // Output: red
   light.next()
   print(light)
   // Output: green
   print(light.canGo)
   // Output: true
   light.next()
   print(light)
   // Output: yellow
   light.next()
   print(light)
   // Output: red

 ENUM PATTERN MATCHING WITH if case
 ====================================
   enum Status {
       case active, inactive, suspended(reason: String)
   }

   let account = Status.suspended(reason: "Non-payment")

   // if case — pattern match a single case:
   if case .suspended(let reason) = account {
       print("Account suspended: \(reason)")
   }
   // Output: Account suspended: Non-payment

   if case .active = account {
       print("Account is active")
   } else {
       print("Account is NOT active")
   }
   // Output: Account is NOT active

   // guard case — early exit pattern:
   func processAccount(_ s: Status) {
       guard case .active = s else {
           print("Cannot process — not active")
           return
       }
       print("Processing active account")
   }
   processAccount(.active)
   // Output: Processing active account
   processAccount(.suspended(reason: "Fraud"))
   // Output: Cannot process — not active

 ENUM IN COLLECTIONS
 ====================
   enum Permission {
       case read, write, execute, admin
   }

   let userPermissions: Set<Permission> = [.read, .write]

   // Check membership:
   if userPermissions.contains(.read) {
       print("Can read")
   }
   // Output: Can read

   if !userPermissions.contains(.admin) {
       print("Not an admin")
   }
   // Output: Not an admin

   // Array of enums:
   let allDirections: [Direction] = [.north, .south, .east, .west]
   let vertical = allDirections.filter {
       $0 == .north || $0 == .south
   }
   print(vertical)
   // Output: [north, south]


 ================================================================
 PART 2 — RAW VALUES IN DEPTH
 ================================================================

 WHAT ARE RAW VALUES?
 =====================
 Raw values give each enum case a pre-defined backing
 value of a specific type. The raw value type must be:
   - String
   - Character
   - Any integer type (Int, UInt8, etc.)
   - Any floating-point type (Double, Float)

 Each case has a unique raw value. Raw values are
 constants — not the same as associated values.

 RAW VALUE SYNTAX
 =================
   enum RawValueEnum: RawValueType {
       case caseA = rawValue1
       case caseB = rawValue2
   }

 INT RAW VALUES
 ===============
   enum Month: Int {
       case january   = 1
       case february  = 2
       case march     = 3
       case april     = 4
       case may       = 5
       case june      = 6
       case july      = 7
       case august    = 8
       case september = 9
       case october   = 10
       case november  = 11
       case december  = 12
   }

   // Access raw value:
   print(Month.march.rawValue)
   // Output: 3
   print(Month.december.rawValue)
   // Output: 12

   // Initialize from raw value — returns Optional:
   let m = Month(rawValue: 6)
   print(m ?? "invalid")
   // Output: june

   let invalid = Month(rawValue: 13)
   print(invalid ?? "invalid month")
   // Output: invalid month

 INT RAW VALUES — AUTO INCREMENT
 =================================
   // When you set the first value, rest auto-increment:
   enum HTTPStatus: Int {
       case ok          = 200
       case created     = 201
       case noContent   = 204
       case badRequest  = 400
       case unauthorized = 401
       case forbidden   = 403
       case notFound    = 404
       case serverError = 500
   }

   print(HTTPStatus.ok.rawValue)
   // Output: 200
   print(HTTPStatus.notFound.rawValue)
   // Output: 404

   if let status = HTTPStatus(rawValue: 401) {
       print("Status: \(status)")
   }
   // Output: Status: unauthorized

   // Auto-increment from first value:
   enum Level: Int {
       case beginner = 1    // 1
       case intermediate    // 2 — auto
       case advanced        // 3 — auto
       case expert          // 4 — auto
   }
   print(Level.intermediate.rawValue)
   // Output: 2
   print(Level.expert.rawValue)
   // Output: 4

   // Default starts at 0:
   enum Priority: Int {
       case low        // 0
       case medium     // 1
       case high       // 2
       case critical   // 3
   }
   print(Priority.high.rawValue)
   // Output: 2
   print(Priority.low.rawValue)
   // Output: 0

 STRING RAW VALUES
 ==================
   enum Currency: String {
       case usd = "USD"
       case eur = "EUR"
       case gbp = "GBP"
       case jpy = "JPY"
       case cad = "CAD"
       case aud = "AUD"
   }

   print(Currency.usd.rawValue)
   // Output: USD
   print(Currency.gbp.rawValue)
   // Output: GBP

   if let c = Currency(rawValue: "EUR") {
       print("Found currency: \(c)")
   }
   // Output: Found currency: eur

   if Currency(rawValue: "XYZ") == nil {
       print("Unknown currency code")
   }
   // Output: Unknown currency code

 STRING RAW VALUES — AUTO NAME
 ==============================
   // When no value is given for String raw type,
   // Swift uses the case name as the raw value:
   enum Color: String {
       case red             // rawValue = "red"
       case green           // rawValue = "green"
       case blue            // rawValue = "blue"
       case darkBlue = "dark_blue"   // explicit override
   }

   print(Color.red.rawValue)
   // Output: red
   print(Color.green.rawValue)
   // Output: green
   print(Color.darkBlue.rawValue)
   // Output: dark_blue

   // Common use: JSON key mapping:
   enum UserField: String {
       case firstName = "first_name"
       case lastName  = "last_name"
       case emailAddr = "email"
       case phoneNum  = "phone"
   }

   print(UserField.firstName.rawValue)
   // Output: first_name
   print(UserField.emailAddr.rawValue)
   // Output: email

 CHARACTER RAW VALUES
 =====================
   enum Grade: Character {
       case excellent = "A"
       case good      = "B"
       case average   = "C"
       case poor      = "D"
       case failing   = "F"
   }

   print(Grade.excellent.rawValue)
   // Output: A

   if let g = Grade(rawValue: "B") {
       print("Grade: \(g)")
   }
   // Output: Grade: good

   let score = 88
   let grade: Grade = score >= 90 ? .excellent :
                      score >= 80 ? .good :
                      score >= 70 ? .average :
                      score >= 60 ? .poor : .failing
   print(grade.rawValue)
   // Output: B

 DOUBLE RAW VALUES
 ==================
   enum Multiplier: Double {
       case tenth    = 0.1
       case quarter  = 0.25
       case half     = 0.5
       case full     = 1.0
       case double2  = 2.0
       case triple   = 3.0
   }

   func apply(amount: Double,
               multiplier: Multiplier) -> Double {
       return amount * multiplier.rawValue
   }

   print(apply(amount: 100, multiplier: .half))
   // Output: 50.0
   print(apply(amount: 100, multiplier: .double2))
   // Output: 200.0
   print(apply(amount: 75,  multiplier: .quarter))
   // Output: 18.75

 RAW VALUES + CaseIterable
 ==========================
   // CaseIterable gives you allCases array:
   enum Suit: String, CaseIterable {
       case hearts   = "♥"
       case diamonds = "♦"
       case clubs    = "♣"
       case spades   = "♠"
   }

   print(Suit.allCases.count)
   // Output: 4
   print(Suit.allCases.map { $0.rawValue })
   // Output: ["♥", "♦", "♣", "♠"]

   for suit in Suit.allCases {
       print("\(suit): \(suit.rawValue)")
   }
   // Output: hearts: ♥
   //         diamonds: ♦
   //         clubs: ♣
   //         spades: ♠

 RAW VALUES + Codable
 =====================
   import Foundation

   enum LogLevel: String, Codable, CaseIterable {
       case debug   = "DEBUG"
       case info    = "INFO"
       case warning = "WARNING"
       case error   = "ERROR"
       case critical = "CRITICAL"
   }

   struct LogEntry: Codable {
       let level:   LogLevel
       let message: String
   }

   let entry = LogEntry(level: .warning, message: "Low memory")
   let encoder = JSONEncoder()
   encoder.outputFormatting = .prettyPrinted

   if let data = try? encoder.encode(entry),
      let json = String(data: data, encoding: .utf8) {
       print(json)
   }
   // Output: {
   //   "level" : "WARNING",
   //   "message" : "Low memory"
   // }

   let jsonStr = """
   {"level":"ERROR","message":"Disk full"}
   """
   let decoder = JSONDecoder()
   if let decoded = try? decoder.decode(LogEntry.self,
                                         from: jsonStr.data(using: .utf8)!) {
       print(decoded.level)
       // Output: error
       print(decoded.message)
       // Output: Disk full
   }

 RAW VALUES WITH COMPUTED PROPERTIES
 =====================================
   enum Rank: Int, CaseIterable {
       case ace   = 1
       case two   = 2
       case three = 3
       case four  = 4
       case five  = 5
       case six   = 6
       case seven = 7
       case eight = 8
       case nine  = 9
       case ten   = 10
       case jack  = 11
       case queen = 12
       case king  = 13

       var displayName: String {
           switch self {
           case .ace:   return "Ace"
           case .jack:  return "Jack"
           case .queen: return "Queen"
           case .king:  return "King"
           default:     return "\(rawValue)"
           }
       }

       var blackjackValue: Int {
           switch self {
           case .ace:   return 11    // simplified
           case .jack, .queen, .king: return 10
           default:     return rawValue
           }
       }

       static var faceCards: [Rank] {
           [.jack, .queen, .king]
       }
   }

   print(Rank.queen.displayName)
   // Output: Queen
   print(Rank.queen.rawValue)
   // Output: 12
   print(Rank.queen.blackjackValue)
   // Output: 10
   print(Rank.seven.displayName)
   // Output: 7
   print(Rank.faceCards.map { $0.displayName })
   // Output: ["Jack", "Queen", "King"]


 ================================================================
 PART 3 — ASSOCIATED VALUES IN DEPTH
 ================================================================

 WHAT ARE ASSOCIATED VALUES?
 =============================
 Associated values let each enum case carry additional
 custom data of any type. Different cases can have
 different types and numbers of associated values.
 Unlike raw values (which are constants), associated
 values are set each time you create a case instance.

 ASSOCIATED VALUE SYNTAX
 =========================
   enum EnumName {
       case caseName(Type1)
       case caseName2(Type1, Type2)
       case caseName3(label1: Type1, label2: Type2)
   }

 BASIC ASSOCIATED VALUES
 ========================
   enum Barcode {
       case upc(Int, Int, Int, Int)
       case qr(String)
   }

   var productCode = Barcode.upc(8, 85909, 51226, 3)

   switch productCode {
   case .upc(let numSys, let mfr, let prod, let check):
       print("UPC: \(numSys)-\(mfr)-\(prod)-\(check)")
   case .qr(let code):
       print("QR: \(code)")
   }
   // Output: UPC: 8-85909-51226-3

   productCode = .qr("ABCDEFGHIJK12345")
   switch productCode {
   case .upc(let n, let m, let p, let c):
       print("UPC: \(n)-\(m)-\(p)-\(c)")
   case .qr(let code):
       print("QR: \(code)")
   }
   // Output: QR: ABCDEFGHIJK12345

 ASSOCIATED VALUES — LABELED
 =============================
   enum Shape {
       case circle(radius: Double)
       case rectangle(width: Double, height: Double)
       case triangle(base: Double, height: Double)
       case point
   }

   func area(of shape: Shape) -> Double {
       switch shape {
       case .circle(let radius):
           return Double.pi * radius * radius
       case .rectangle(let width, let height):
           return width * height
       case .triangle(let base, let height):
           return 0.5 * base * height
       case .point:
           return 0
       }
   }

   let c = Shape.circle(radius: 5)
   let r = Shape.rectangle(width: 4, height: 6)
   let t = Shape.triangle(base: 3, height: 8)
   let p = Shape.point

   print(area(of: c))
   // Output: 78.53981633974483
   print(area(of: r))
   // Output: 24.0
   print(area(of: t))
   // Output: 12.0
   print(area(of: p))
   // Output: 0.0

 ASSOCIATED VALUES — RESULT-LIKE PATTERN
 =========================================
   enum NetworkResult {
       case success(data: Data, statusCode: Int)
       case failure(error: Error, statusCode: Int?)
       case loading(progress: Double)
       case cancelled
   }

   func handle(result: NetworkResult) {
       switch result {
       case .success(let data, let code):
           print("Success [\(code)]: \(data.count) bytes")
       case .failure(let error, let code):
           let codeStr = code.map { "\($0)" } ?? "none"
           print("Failure [\(codeStr)]: \(error.localizedDescription)")
       case .loading(let progress):
           print("Loading: \(Int(progress * 100))%")
       case .cancelled:
           print("Request cancelled")
       }
   }

   handle(result: .success(data: Data(repeating: 0, count: 1024),
                             statusCode: 200))
   // Output: Success [200]: 1024 bytes

   handle(result: .loading(progress: 0.65))
   // Output: Loading: 65%

   handle(result: .failure(
       error: NSError(domain: "NetError", code: 404, userInfo: nil),
       statusCode: 404
   ))
   // Output: Failure [404]: The operation couldn't be completed. ...

   handle(result: .cancelled)
   // Output: Request cancelled

 ASSOCIATED VALUES — EXTRACTING WITH if case
 =============================================
   enum Event {
       case tap(x: Int, y: Int)
       case swipe(direction: String, velocity: Double)
       case pinch(scale: Double)
       case keyPress(key: Character)
   }

   let events: [Event] = [
       .tap(x: 100, y: 200),
       .swipe(direction: "left", velocity: 450.0),
       .tap(x: 50, y: 75),
       .pinch(scale: 1.5),
       .keyPress(key: "a"),
       .swipe(direction: "up", velocity: 300.0)
   ]

   // if case — extract single matching case:
   for event in events {
       if case .tap(let x, let y) = event {
           print("Tap at (\(x), \(y))")
       }
   }
   // Output: Tap at (100, 200)
   //         Tap at (50, 75)

   // Filter swipes:
   let swipes = events.filter {
       if case .swipe = $0 { return true }
       return false
   }
   print("Swipe count: \(swipes.count)")
   // Output: Swipe count: 2

   // Extract specific associated value:
   for event in events {
       if case .swipe(let dir, let vel) = event, vel > 400 {
           print("Fast swipe: \(dir) at \(vel) px/s")
       }
   }
   // Output: Fast swipe: left at 450.0 px/s

 ASSOCIATED VALUES — COMPLEX TYPES
 ====================================
   struct User {
       let id: Int
       let name: String
       let email: String
   }

   struct APIError {
       let code: Int
       let message: String
   }

   enum UserOperation {
       case create(User)
       case update(id: Int, changes: [String: String])
       case delete(id: Int, permanent: Bool)
       case fetch(id: Int, completion: (User?) -> Void)
       case fetchAll(page: Int, perPage: Int)
       case batchDelete(ids: [Int])
   }

   func processOperation(_ op: UserOperation) {
       switch op {
       case .create(let user):
           print("Creating user: \(user.name) (\(user.email))")

       case .update(let id, let changes):
           print("Updating user \(id): \(changes)")

       case .delete(let id, let permanent):
           let type2 = permanent ? "permanently" : "soft"
           print("Deleting user \(id) \(type2)")

       case .fetch(let id, _):
           print("Fetching user \(id)")

       case .fetchAll(let page, let perPage):
           print("Fetching page \(page) (\(perPage) per page)")

       case .batchDelete(let ids):
           print("Batch deleting \(ids.count) users: \(ids)")
       }
   }

   let u = User(id: 1, name: "Alice", email: "alice@x.com")
   processOperation(.create(u))
   // Output: Creating user: Alice (alice@x.com)

   processOperation(.update(id: 1, changes: ["name": "Alice Smith"]))
   // Output: Updating user 1: ["name": "Alice Smith"]

   processOperation(.delete(id: 5, permanent: true))
   // Output: Deleting user 5 permanently

   processOperation(.fetchAll(page: 2, perPage: 20))
   // Output: Fetching page 2 (20 per page)

   processOperation(.batchDelete(ids: [3, 7, 12, 45]))
   // Output: Batch deleting 4 users: [3, 7, 12, 45]

 ASSOCIATED VALUES — switch BINDING STYLES
 ===========================================
   enum Notification2 {
       case message(from: String, text: String, unread: Bool)
       case alert(title: String, severity: Int)
       case badge(count: Int)
   }

   let n = Notification2.message(from: "Bob",
                                   text: "Hey!",
                                   unread: true)

   // Bind all individually:
   switch n {
   case .message(let from, let text, let unread):
       print("From: \(from), Text: \(text), Unread: \(unread)")
   default: break
   }
   // Output: From: Bob, Text: Hey!, Unread: true

   // Bind all with single let:
   switch n {
   case let .message(from, text, unread):
       print("From: \(from), Text: \(text), Unread: \(unread)")
   default: break
   }
   // Output: From: Bob, Text: Hey!, Unread: true

   // Bind some, ignore others with _:
   switch n {
   case .message(let from, _, let unread) where unread:
       print("Unread message from \(from)")
   default:
       print("No unread messages")
   }
   // Output: Unread message from Bob

 ASSOCIATED VALUES + EQUATABLE
 ================================
   // Enum with associated values is NOT automatically Equatable.
   // You must implement == manually or synthesize with Equatable:

   enum Token: Equatable {
       case identifier(String)
       case number(Int)
       case string(String)
       case keyword(String)
       case operator2(Character)
       case eof
   }
   // Swift auto-synthesizes Equatable since all
   // associated value types are Equatable.

   let t1 = Token.identifier("foo")
   let t2 = Token.identifier("foo")
   let t3 = Token.identifier("bar")
   let t4 = Token.number(42)

   print(t1 == t2)
   // Output: true
   print(t1 == t3)
   // Output: false
   print(t1 == t4)
   // Output: false

   // Using in collections:
   let tokens: [Token] = [
       .identifier("x"),
       .operator2("+"),
       .number(5),
       .eof
   ]
   print(tokens.contains(.eof))
   // Output: true

 ASSOCIATED VALUES — REAL-WORLD STATE MACHINE
 =============================================
   enum AuthState {
       case idle
       case authenticating(username: String)
       case authenticated(token: String, expiresIn: Int)
       case refreshing(oldToken: String)
       case failed(error: String, retryCount: Int)
       case loggedOut
   }

   class AuthManager {
       private var state: AuthState = .idle {
           didSet { onStateChanged(state) }
       }

       func onStateChanged(_ state: AuthState) {
           switch state {
           case .idle:
               print("Auth: idle")
           case .authenticating(let user):
               print("Auth: authenticating \(user)...")
           case .authenticated(let token, let expires):
               print("Auth: ✓ token=\(token.prefix(8))... expires=\(expires)s")
           case .refreshing(let old):
               print("Auth: refreshing (old=\(old.prefix(8))...)")
           case .failed(let err, let retry):
               print("Auth: ✗ \(err) (retry #\(retry))")
           case .loggedOut:
               print("Auth: logged out")
           }
       }

       func login(username: String, password: String) {
           state = .authenticating(username: username)
           // Simulate result:
           if password == "secret" {
               state = .authenticated(token: "tok_abc123xyz789",
                                       expiresIn: 3600)
           } else {
               state = .failed(error: "Wrong password", retryCount: 1)
           }
       }

       func logout() { state = .loggedOut }
   }

   let auth = AuthManager()
   // Output: Auth: idle   (didSet fires on init if default triggers)

   auth.login(username: "alice", password: "secret")
   // Output: Auth: authenticating alice...
   //         Auth: ✓ token=tok_abc1... expires=3600s

   auth.login(username: "bob", password: "wrong")
   // Output: Auth: authenticating bob...
   //         Auth: ✗ Wrong password (retry #1)

   auth.logout()
   // Output: Auth: logged out


 ================================================================
 PART 4 — RECURSIVE ENUMS AND INDIRECT IN DEPTH
 ================================================================

 WHAT IS A RECURSIVE ENUM?
 ==========================
 A recursive enum is an enum that has one or more
 cases that use the enum itself as an associated value.
 Because enums are value types, a direct recursive
 definition would create an infinitely sized type.
 The indirect keyword solves this by introducing
 an indirect (heap-allocated pointer) layer.

 WHY indirect IS NEEDED
 ========================
   // Without indirect — ERROR:
   // enum Tree {
   //     case leaf(Int)
   //     case node(Tree, Tree)     // Error — recursive value type
   // }

   // With indirect — OK (heap allocated):
   indirect enum Tree {
       case leaf(Int)
       case node(Tree, Tree)         // pointer to heap — finite size
   }

 TWO WAYS TO USE indirect
 =========================
   // Option 1: Mark entire enum as indirect:
   indirect enum LinkedList<T> {
       case empty
       case node(value: T, next: LinkedList<T>)
   }

   // Option 2: Mark only specific cases as indirect:
   enum BinaryTree<T> {
       case empty
       case leaf(T)
       indirect case node(left: BinaryTree<T>,
                           value: T,
                           right: BinaryTree<T>)
   }

 BASIC RECURSIVE ENUM — LINKED LIST
 =====================================
   indirect enum List<T> {
       case empty
       case cons(head: T, tail: List<T>)

       // Build from array:
       static func from(_ array: [T]) -> List<T> {
           var result = List<T>.empty
           for element in array.reversed() {
               result = .cons(head: element, tail: result)
           }
           return result
       }

       // Convert to array:
       func toArray() -> [T] {
           switch self {
           case .empty:
               return []
           case .cons(let head, let tail):
               return [head] + tail.toArray()
           }
       }

       // Count elements:
       var count: Int {
           switch self {
           case .empty:               return 0
           case .cons(_, let tail):   return 1 + tail.count
           }
       }

       // First element:
       var head: T? {
           if case .cons(let h, _) = self { return h }
           return nil
       }
   }

   let list = List<Int>.from([1, 2, 3, 4, 5])
   print(list.toArray())
   // Output: [1, 2, 3, 4, 5]
   print(list.count)
   // Output: 5
   print(list.head ?? -1)
   // Output: 1

   let emptyList = List<String>.empty
   print(emptyList.toArray())
   // Output: []
   print(emptyList.count)
   // Output: 0

 RECURSIVE ENUM — BINARY TREE
 ==============================
   indirect enum BST<T: Comparable> {
       case empty
       case node(left: BST<T>, value: T, right: BST<T>)

       // Insert — maintains BST property:
       func inserting(_ newValue: T) -> BST<T> {
           switch self {
           case .empty:
               return .node(left: .empty,
                             value: newValue,
                             right: .empty)
           case .node(let left, let value, let right):
               if newValue < value {
                   return .node(left: left.inserting(newValue),
                                 value: value,
                                 right: right)
               } else if newValue > value {
                   return .node(left: left,
                                 value: value,
                                 right: right.inserting(newValue))
               } else {
                   return self    // duplicate — no change
               }
           }
       }

       // In-order traversal (sorted):
       func inOrder() -> [T] {
           switch self {
           case .empty:
               return []
           case .node(let left, let value, let right):
               return left.inOrder() + [value] + right.inOrder()
           }
       }

       // Search:
       func contains(_ target: T) -> Bool {
           switch self {
           case .empty:
               return false
           case .node(let left, let value, let right):
               if target == value { return true }
               if target < value  { return left.contains(target) }
               return right.contains(target)
           }
       }

       // Height of tree:
       var height: Int {
           switch self {
           case .empty: return 0
           case .node(let left, _, let right):
               return 1 + max(left.height, right.height)
           }
       }

       // Count nodes:
       var count: Int {
           switch self {
           case .empty: return 0
           case .node(let left, _, let right):
               return 1 + left.count + right.count
           }
       }
   }

   var tree = BST<Int>.empty
   let values = [5, 3, 8, 1, 4, 7, 9, 2, 6]
   for v in values {
       tree = tree.inserting(v)
   }

   print(tree.inOrder())
   // Output: [1, 2, 3, 4, 5, 6, 7, 8, 9]
   print(tree.contains(4))
   // Output: true
   print(tree.contains(10))
   // Output: false
   print(tree.height)
   // Output: 4
   print(tree.count)
   // Output: 9

 RECURSIVE ENUM — ARITHMETIC EXPRESSION
 =========================================
   indirect enum Expression {
       case number(Double)
       case variable(String)
       case addition(Expression, Expression)
       case subtraction(Expression, Expression)
       case multiplication(Expression, Expression)
       case division(Expression, Expression)
       case negation(Expression)
       case power(base: Expression, exponent: Expression)
   }

   func evaluate(_ expr: Expression,
                  variables: [String: Double] = [:]) -> Double {
       switch expr {
       case .number(let n):
           return n

       case .variable(let name):
           return variables[name] ?? 0

       case .addition(let a, let b):
           return evaluate(a, variables: variables)
                + evaluate(b, variables: variables)

       case .subtraction(let a, let b):
           return evaluate(a, variables: variables)
                - evaluate(b, variables: variables)

       case .multiplication(let a, let b):
           return evaluate(a, variables: variables)
                * evaluate(b, variables: variables)

       case .division(let a, let b):
           let divisor = evaluate(b, variables: variables)
           guard divisor != 0 else { return .nan }
           return evaluate(a, variables: variables) / divisor

       case .negation(let e):
           return -evaluate(e, variables: variables)

       case .power(let base, let exp):
           return pow(evaluate(base, variables: variables),
                      evaluate(exp, variables: variables))
       }
   }

   func describe(_ expr: Expression) -> String {
       switch expr {
       case .number(let n):
           return n.truncatingRemainder(dividingBy: 1) == 0
               ? String(Int(n)) : "\(n)"
       case .variable(let v): return v
       case .addition(let a, let b):
           return "(\(describe(a)) + \(describe(b)))"
       case .subtraction(let a, let b):
           return "(\(describe(a)) - \(describe(b)))"
       case .multiplication(let a, let b):
           return "(\(describe(a)) * \(describe(b)))"
       case .division(let a, let b):
           return "(\(describe(a)) / \(describe(b)))"
       case .negation(let e):
           return "-\(describe(e))"
       case .power(let b, let e):
           return "(\(describe(b)) ^ \(describe(e)))"
       }
   }

   // Build: (x^2 + 3*x - 5) / 2
   let x   = Expression.variable("x")
   let two = Expression.number(2)
   let thr = Expression.number(3)
   let fiv = Expression.number(5)

   let expr = Expression.division(
       Expression.subtraction(
           Expression.addition(
               Expression.power(base: x, exponent: two),
               Expression.multiplication(thr, x)
           ),
           fiv
       ),
       two
   )

   print(describe(expr))
   // Output: (((x ^ 2) + (3 * x)) - 5) / 2)

   let result = evaluate(expr, variables: ["x": 4.0])
   print(result)
   // Output: 8.5   (16 + 12 - 5) / 2 = 23/2 = 11.5
   // Note: (4^2 + 3*4 - 5)/2 = (16+12-5)/2 = 23/2 = 11.5
   print(evaluate(expr, variables: ["x": 0.0]))
   // Output: -2.5   (0 + 0 - 5) / 2

 RECURSIVE ENUM — JSON REPRESENTATION
 ========================================
   indirect enum JSON {
       case null
       case bool(Bool)
       case number(Double)
       case string(String)
       case array([JSON])
       case object([String: JSON])
   }

   extension JSON: CustomStringConvertible {
       var description: String {
           return stringify(indent: 0)
       }

       private func stringify(indent: Int) -> String {
           let pad  = String(repeating: "  ", count: indent)
           let pad2 = String(repeating: "  ", count: indent + 1)

           switch self {
           case .null:         return "null"
           case .bool(let b):  return b ? "true" : "false"
           case .number(let n):
               return n.truncatingRemainder(dividingBy: 1) == 0
                   ? String(Int(n)) : "\(n)"
           case .string(let s): return "\"\(s)\""
           case .array(let arr):
               if arr.isEmpty { return "[]" }
               let items = arr.map {
                   "\(pad2)\($0.stringify(indent: indent + 1))"
               }.joined(separator: ",\n")
               return "[\n\(items)\n\(pad)]"
           case .object(let obj):
               if obj.isEmpty { return "{}" }
               let pairs = obj.sorted { $0.key < $1.key }
                   .map { k, v in
                       "\(pad2)\"\(k)\": \(v.stringify(indent: indent + 1))"
                   }.joined(separator: ",\n")
               return "{\n\(pairs)\n\(pad)}"
           }
       }
   }

   extension JSON {
       subscript(key: String) -> JSON? {
           if case .object(let obj) = self { return obj[key] }
           return nil
       }
       subscript(index: Int) -> JSON? {
           if case .array(let arr) = self,
              index < arr.count { return arr[index] }
           return nil
       }
   }

   let json = JSON.object([
       "name":    .string("Alice"),
       "age":     .number(28),
       "active":  .bool(true),
       "scores":  .array([.number(95), .number(87), .number(92)]),
       "address": .object([
           "city":    .string("San Francisco"),
           "country": .string("USA")
       ]),
       "metadata": .null
   ])

   print(json)
   // Output:
   // {
   //   "active": true,
   //   "address": {
   //     "city": "San Francisco",
   //     "country": "USA"
   //   },
   //   "age": 28,
   //   "metadata": null,
   //   "name": "Alice",
   //   "scores": [
   //     95,
   //     87,
   //     92
   //   ]
   // }

   // Subscript access:
   print(json["name"] ?? .null)
   // Output: "Alice"
   print(json["scores"]?[1] ?? .null)
   // Output: 87
   print(json["address"]?["city"] ?? .null)
   // Output: "San Francisco"

 RECURSIVE ENUM — FILE SYSTEM
 ==============================
   indirect enum FileSystem {
       case file(name: String, size: Int)
       case directory(name: String, contents: [FileSystem])
       case symlink(name: String, target: String)

       var name: String {
           switch self {
           case .file(let n, _):       return n
           case .directory(let n, _):  return n
           case .symlink(let n, _):    return n
           }
       }

       var totalSize: Int {
           switch self {
           case .file(_, let size):    return size
           case .symlink:              return 0
           case .directory(_, let contents):
               return contents.reduce(0) { $0 + $1.totalSize }
           }
       }

       var fileCount: Int {
           switch self {
           case .file:                  return 1
           case .symlink:               return 0
           case .directory(_, let c):
               return c.reduce(0) { $0 + $1.fileCount }
           }
       }

       func listing(indent: Int = 0) {
           let pad = String(repeating: "  ", count: indent)
           switch self {
           case .file(let n, let s):
               print("\(pad)📄 \(n) (\(s) bytes)")
           case .symlink(let n, let t):
               print("\(pad)🔗 \(n) → \(t)")
           case .directory(let n, let contents):
               print("\(pad)📁 \(n)/")
               contents.forEach { $0.listing(indent: indent + 1) }
           }
       }

       func find(name target: String) -> [String] {
           switch self {
           case .file(let n, _) where n == target:
               return [n]
           case .symlink(let n, _) where n == target:
               return [n]
           case .directory(let n, let contents):
               let sub = contents.flatMap { $0.find(name: target) }
               return sub.map { "\(n)/\($0)" }
           default:
               return []
           }
       }
   }

   let root = FileSystem.directory(name: "root", contents: [
       .directory(name: "src", contents: [
           .file(name: "main.swift",   size: 2048),
           .file(name: "models.swift", size: 4096),
           .directory(name: "utils", contents: [
               .file(name: "helpers.swift", size: 1024),
               .symlink(name: "config", target: "../config.json")
           ])
       ]),
       .directory(name: "tests", contents: [
           .file(name: "tests.swift", size: 3072)
       ]),
       .file(name: "README.md",    size: 512),
       .file(name: "config.json",  size: 256)
   ])

   root.listing()
   // Output:
   // 📁 root/
   //   📁 src/
   //     📄 main.swift (2048 bytes)
   //     📄 models.swift (4096 bytes)
   //     📁 utils/
   //       📄 helpers.swift (1024 bytes)
   //       🔗 config → ../config.json
   //   📁 tests/
   //     📄 tests.swift (3072 bytes)
   //   📄 README.md (512 bytes)
   //   📄 config.json (256 bytes)

   print("Total size: \(root.totalSize) bytes")
   // Output: Total size: 11008 bytes
   print("File count: \(root.fileCount)")
   // Output: File count: 6
   print(root.find(name: "helpers.swift"))
   // Output: ["root/src/utils/helpers.swift"]


 ================================================================
 PART 5 — ADVANCED ENUM PATTERNS
 ================================================================

 ENUM CONFORMING TO PROTOCOLS
 ==============================
   protocol Iconable {
       var icon: String { get }
   }

   protocol Colorable {
       var color: String { get }
   }

   enum FileType: String, Iconable, Colorable, CaseIterable {
       case swift  = "swift"
       case python = "py"
       case javascript = "js"
       case markdown = "md"
       case json   = "json"
       case image  = "img"
       case video  = "mp4"

       var icon: String {
           switch self {
           case .swift:      return "🦅"
           case .python:     return "🐍"
           case .javascript: return "🟨"
           case .markdown:   return "📝"
           case .json:       return "📋"
           case .image:      return "🖼"
           case .video:      return "🎬"
           }
       }

       var color: String {
           switch self {
           case .swift:      return "#F05138"
           case .python:     return "#3776AB"
           case .javascript: return "#F7DF1E"
           case .markdown:   return "#083FA1"
           case .json:       return "#000000"
           case .image:      return "#8B5CF6"
           case .video:      return "#EF4444"
           }
       }

       var isCode: Bool {
           [.swift, .python, .javascript].contains(self)
       }

       static func from(extension ext: String) -> FileType? {
           FileType.allCases.first { $0.rawValue == ext }
       }
   }

   let ft = FileType.swift
   print("\(ft.icon) \(ft.rawValue) — \(ft.color)")
   // Output: 🦅 swift — #F05138

   let codeTypes = FileType.allCases.filter { $0.isCode }
   print(codeTypes.map { "\($0.icon)\($0.rawValue)" })
   // Output: ["🦅swift", "🐍py", "🟨js"]

   print(FileType.from(extension: "json")?.icon ?? "?")
   // Output: 📋

 GENERIC ENUM
 =============
   enum Either<L, R> {
       case left(L)
       case right(R)

       var isLeft:  Bool { if case .left  = self { return true }; return false }
       var isRight: Bool { if case .right = self { return true }; return false }

       var leftValue:  L? { if case .left(let v)  = self { return v }; return nil }
       var rightValue: R? { if case .right(let v) = self { return v }; return nil }

       func mapLeft<T>(_ f: (L) -> T) -> Either<T, R> {
           switch self {
           case .left(let v):  return .left(f(v))
           case .right(let v): return .right(v)
           }
       }

       func mapRight<T>(_ f: (R) -> T) -> Either<L, T> {
           switch self {
           case .left(let v):  return .left(v)
           case .right(let v): return .right(f(v))
           }
       }

       func fold<T>(onLeft:  (L) -> T,
                    onRight: (R) -> T) -> T {
           switch self {
           case .left(let v):  return onLeft(v)
           case .right(let v): return onRight(v)
           }
       }
   }

   let success: Either<String, Int> = .right(42)
   let failure: Either<String, Int> = .left("Something went wrong")

   print(success.fold(
       onLeft:  { "Error: \($0)" },
       onRight: { "Value: \($0)" }
   ))
   // Output: Value: 42

   print(failure.fold(
       onLeft:  { "Error: \($0)" },
       onRight: { "Value: \($0)" }
   ))
   // Output: Error: Something went wrong

   let doubled4 = success.mapRight { $0 * 2 }
   print(doubled4.rightValue ?? -1)
   // Output: 84

 ENUM AS NAMESPACE
 ==================
   // Enums with no cases work as namespaces:
   enum AppConstants {
       enum Network {
           static let baseURL    = "https://api.example.com"
           static let timeout    = 30.0
           static let maxRetries = 3
       }

       enum UI {
           static let cornerRadius = 8.0
           static let animDuration = 0.3
           static let primaryColor = "#007AFF"
       }

       enum Cache {
           static let maxSize   = 50 * 1024 * 1024  // 50MB
           static let ttl       = 3600              // 1 hour
           static let directory = "app_cache"
       }
   }

   print(AppConstants.Network.baseURL)
   // Output: https://api.example.com
   print(AppConstants.UI.cornerRadius)
   // Output: 8.0
   print(AppConstants.Cache.maxSize)
   // Output: 52428800

 PATTERN MATCHING IN switch WITH where
 ========================================
   enum Temperature2 {
       case celsius(Double)
       case fahrenheit(Double)
       case kelvin(Double)

       var inCelsius: Double {
           switch self {
           case .celsius(let c):    return c
           case .fahrenheit(let f): return (f - 32) * 5/9
           case .kelvin(let k):     return k - 273.15
           }
       }
   }

   func classify(_ temp: Temperature2) -> String {
       let c = temp.inCelsius
       switch temp {
       case .celsius(let v)    where v < 0:     return "Freezing (\(v)°C)"
       case .celsius(let v)    where v < 15:    return "Cold (\(v)°C)"
       case .celsius(let v)    where v < 25:    return "Comfortable (\(v)°C)"
       case .celsius(let v)    where v < 35:    return "Warm (\(v)°C)"
       case .celsius(let v):                    return "Hot (\(v)°C)"
       case .fahrenheit(let v) where c < 0:
           return "Freezing (\(v)°F = \(String(format:"%.1f", c))°C)"
       case .fahrenheit(let v):
           return "Fahrenheit: \(v)°F = \(String(format:"%.1f", c))°C"
       case .kelvin(let v):
           return "Kelvin: \(v)K = \(String(format:"%.2f", c))°C"
       }
   }

   print(classify(.celsius(-5)))
   // Output: Freezing (-5.0°C)
   print(classify(.celsius(22)))
   // Output: Comfortable (22.0°C)
   print(classify(.fahrenheit(32)))
   // Output: Freezing (32.0°F = 0.0°C)
   print(classify(.kelvin(373.15)))
   // Output: Kelvin: 373.15K = 100.00°C

 ENUM WITH COMPUTED INIT LOGIC
 ================================
   enum MimeType: String {
       case jpeg    = "image/jpeg"
       case png     = "image/png"
       case gif     = "image/gif"
       case webp    = "image/webp"
       case mp4     = "video/mp4"
       case mp3     = "audio/mpeg"
       case pdf     = "application/pdf"
       case json2   = "application/json"
       case plain   = "text/plain"
       case html    = "text/html"

       init?(fileExtension: String) {
           switch fileExtension.lowercased() {
           case "jpg", "jpeg": self = .jpeg
           case "png":         self = .png
           case "gif":         self = .gif
           case "webp":        self = .webp
           case "mp4":         self = .mp4
           case "mp3":         self = .mp3
           case "pdf":         self = .pdf
           case "json":        self = .json2
           case "txt":         self = .plain
           case "html", "htm": self = .html
           default:            return nil
           }
       }

       var category: String {
           if rawValue.starts(with: "image") { return "image" }
           if rawValue.starts(with: "video") { return "video" }
           if rawValue.
     if rawValue.starts(with: "audio")       { return "audio" }
     if rawValue.starts(with: "application") { return "application" }
     return "text"
}

var isMedia: Bool {
 category == "image" || category == "video" || category == "audio"
}
}

print(MimeType(fileExtension: "jpg")?.rawValue ?? "unknown")
// Output: image/jpeg
print(MimeType(fileExtension: "JPG")?.rawValue ?? "unknown")
// Output: image/jpeg
print(MimeType(fileExtension: "mp3")?.category ?? "unknown")
// Output: audio
print(MimeType(fileExtension: "xyz") ?? "unknown")
// Output: unknown
print(MimeType.pdf.isMedia)
// Output: false
print(MimeType.mp4.isMedia)
// Output: true

NESTED ENUMS
=============
enum HTTP {
enum Method: String {
 case get    = "GET"
 case post   = "POST"
 case put    = "PUT"
 case patch  = "PATCH"
 case delete = "DELETE"

 var hasBody: Bool {
     switch self {
     case .post, .put, .patch: return true
     default:                  return false
     }
 }
}

enum Status: Int {
 case ok             = 200
 case created        = 201
 case noContent      = 204
 case badRequest     = 400
 case unauthorized   = 401
 case forbidden      = 403
 case notFound       = 404
 case serverError    = 500

 var isSuccess:     Bool { rawValue >= 200 && rawValue < 300 }
 var isClientError: Bool { rawValue >= 400 && rawValue < 500 }
 var isServerError: Bool { rawValue >= 500 }

 var message: String {
     switch self {
     case .ok:           return "OK"
     case .created:      return "Created"
     case .noContent:    return "No Content"
     case .badRequest:   return "Bad Request"
     case .unauthorized: return "Unauthorized"
     case .forbidden:    return "Forbidden"
     case .notFound:     return "Not Found"
     case .serverError:  return "Internal Server Error"
     }
 }
}

enum ContentType: String {
 case json = "application/json"
 case xml  = "application/xml"
 case form = "application/x-www-form-urlencoded"
 case multipart = "multipart/form-data"
 case text = "text/plain"
}

struct Request {
 let method:      HTTP.Method
 let url:         String
 let contentType: HTTP.ContentType
 let body:        String?

 func describe() -> String {
     var desc = "\(method.rawValue) \(url)"
     if method.hasBody, let body = body {
         desc += " | body: \(body.prefix(20))..."
     }
     return desc
 }
}
}

let req = HTTP.Request(
method: .post,
url: "https://api.example.com/users",
contentType: .json,
body: "{\"name\":\"Alice\",\"email\":\"alice@example.com\"}"
)
print(req.describe())
// Output: POST https://api.example.com/users |
//         body: {"name":"Alice","email...

let status = HTTP.Status.notFound
print("\(status.rawValue) \(status.message)")
// Output: 404 Not Found
print(status.isClientError)
// Output: true
print(HTTP.Method.get.hasBody)
// Output: false
print(HTTP.Method.post.hasBody)
// Output: true

COMBINING RAW + ASSOCIATED VALUES PATTERNS
============================================
// Swift doesn't allow raw values AND associated values
// on the same enum — but you can simulate it:
enum AppError: Error {
case network(code: Int, message: String)
case database(table: String, operation: String)
case validation(field: String, rule: String)
case authentication(reason: String)
case unknown

// Simulated "raw" error code via computed property:
var errorCode: Int {
 switch self {
 case .network:        return 1000
 case .database:       return 2000
 case .validation:     return 3000
 case .authentication: return 4000
 case .unknown:        return 9999
 }
}

var isRecoverable: Bool {
 switch self {
 case .network, .authentication: return true
 default:                        return false
 }
}
}

extension AppError: CustomStringConvertible {
var description: String {
 switch self {
 case .network(let code, let msg):
     return "[NET-\(errorCode)] HTTP \(code): \(msg)"
 case .database(let table, let op):
     return "[DB-\(errorCode)] Failed to \(op) in \(table)"
 case .validation(let field, let rule):
     return "[VAL-\(errorCode)] \(field) failed rule: \(rule)"
 case .authentication(let reason):
     return "[AUTH-\(errorCode)] \(reason)"
 case .unknown:
     return "[ERR-\(errorCode)] Unknown error"
 }
}
}

let errors: [AppError] = [
.network(code: 503, message: "Service Unavailable"),
.database(table: "users", operation: "INSERT"),
.validation(field: "email", rule: "must contain @"),
.authentication(reason: "Token expired"),
.unknown
]
for err in errors {
print("\(err) | recoverable: \(err.isRecoverable)")
}
// Output: [NET-1000] HTTP 503: Service Unavailable | recoverable: true
//         [DB-2000] Failed to INSERT in users | recoverable: false
//         [VAL-3000] email failed rule: must contain @ | recoverable: false
//         [AUTH-4000] Token expired | recoverable: true
//         [ERR-9999] Unknown error | recoverable: false


================================================================
PART 6 — ENUMS WITH PROTOCOLS
================================================================

ENUM CONFORMING TO Equatable AND Hashable
==========================================
enum Coordinate2: Equatable, Hashable {
case geographic(lat: Double, lon: Double)
case cartesian(x: Double, y: Double)
case polar(r: Double, theta: Double)
}

let home = Coordinate2.geographic(lat: 37.7749, lon: -122.4194)
let work = Coordinate2.geographic(lat: 37.7749, lon: -122.4194)
let office = Coordinate2.cartesian(x: 100, y: 200)

print(home == work)
// Output: true
print(home == office)
// Output: false

// Use in Set (requires Hashable):
var visited: Set<Coordinate2> = [home, work, office]
print(visited.count)
// Output: 2   (home and work are equal — deduplicated)

// Use as Dictionary key:
var labels: [Coordinate2: String] = [:]
labels[home]   = "Home"
labels[office] = "Office"
print(labels[work] ?? "unknown")   // home == work
// Output: Home

ENUM CONFORMING TO Comparable
================================
enum Severity: Int, Comparable, CaseIterable {
case info     = 0
case debug    = 1
case warning  = 2
case error    = 3
case critical = 4

static func < (lhs: Severity, rhs: Severity) -> Bool {
 lhs.rawValue < rhs.rawValue
}

var label: String { rawValue >= 2 ? "⚠️  \(self)" : "ℹ️  \(self)" }
}

let levels: [Severity] = [.error, .info, .critical, .warning, .debug]
print(levels.sorted())
// Output: [info, debug, warning, error, critical]
print(levels.max() ?? .info)
// Output: critical
print(levels.min() ?? .info)
// Output: info
print(Severity.error > Severity.warning)
// Output: true

// Filter by severity threshold:
let threshold = Severity.warning
let important = levels.filter { $0 >= threshold }
print(important)
// Output: [error, critical, warning]

ENUM CONFORMING TO CustomStringConvertible
===========================================
enum CardSuit: String, CustomStringConvertible,
        CaseIterable, Comparable {
case clubs    = "C"
case diamonds = "D"
case hearts   = "H"
case spades   = "S"

static func < (lhs: CardSuit, rhs: CardSuit) -> Bool {
 let order: [CardSuit] = [.clubs, .diamonds, .hearts, .spades]
 return order.firstIndex(of: lhs)! <
        order.firstIndex(of: rhs)!
}

var description: String {
 switch self {
 case .clubs:    return "♣ Clubs"
 case .diamonds: return "♦ Diamonds"
 case .hearts:   return "♥ Hearts"
 case .spades:   return "♠ Spades"
 }
}

var symbol: Character {
 switch self {
 case .clubs:    return "♣"
 case .diamonds: return "♦"
 case .hearts:   return "♥"
 case .spades:   return "♠"
 }
}

var isRed: Bool { self == .hearts || self == .diamonds }
}

for suit in CardSuit.allCases.sorted() {
print("\(suit) | red: \(suit.isRed)")
}
// Output: ♣ Clubs | red: false
//         ♦ Diamonds | red: true
//         ♥ Hearts | red: true
//         ♠ Spades | red: false

ENUM CONFORMING TO Codable
============================
enum PaymentMethod: String, Codable, CaseIterable {
case creditCard  = "credit_card"
case debitCard   = "debit_card"
case paypal      = "paypal"
case applePay    = "apple_pay"
case googlePay   = "google_pay"
case bankTransfer = "bank_transfer"
case crypto      = "crypto"
}

struct Payment: Codable {
let id:     String
let amount: Double
let method: PaymentMethod
let status: String
}

let payment = Payment(id: "pay_001",
                amount: 49.99,
                method: .applePay,
                status: "completed")

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

if let data = try? encoder.encode(payment),
let json = String(data: data, encoding: .utf8) {
print(json)
}
// Output:
// {
//   "id" : "pay_001",
//   "amount" : 49.99,
//   "method" : "apple_pay",
//   "status" : "completed"
// }

let jsonStr = """
{"id":"pay_002","amount":99.0,"method":"crypto","status":"pending"}
"""
let decoder = JSONDecoder()
if let decoded = try? decoder.decode(
Payment.self,
from: jsonStr.data(using: .utf8)!
) {
print(decoded.method)
// Output: crypto
print(decoded.amount)
// Output: 99.0
}

ENUM CONFORMING TO Error
==========================
enum DatabaseError: Error, CustomStringConvertible {
case connectionFailed(host: String, port: Int)
case queryFailed(sql: String, reason: String)
case recordNotFound(table: String, id: Int)
case duplicateKey(table: String, key: String)
case transactionFailed(step: String)
case timeout(seconds: Double)

var description: String {
 switch self {
 case .connectionFailed(let host, let port):
     return "Cannot connect to \(host):\(port)"
 case .queryFailed(let sql, let reason):
     return "Query failed '\(sql.prefix(20))...': \(reason)"
 case .recordNotFound(let table, let id):
     return "Record \(id) not found in \(table)"
 case .duplicateKey(let table, let key):
     return "Duplicate key '\(key)' in \(table)"
 case .transactionFailed(let step):
     return "Transaction failed at step: \(step)"
 case .timeout(let sec):
     return "Operation timed out after \(sec)s"
 }
}

var isRetryable: Bool {
 switch self {
 case .connectionFailed, .timeout: return true
 default:                          return false
 }
}
}

func fetchRecord(id: Int,
          from table: String) throws -> String {
if id <= 0 {
 throw DatabaseError.recordNotFound(table: table, id: id)
}
if id > 1000 {
 throw DatabaseError.timeout(seconds: 30.0)
}
return "Record \(id) from \(table)"
}

do {
let rec = try fetchRecord(id: 42, from: "users")
print(rec)
} catch {
print("Error: \(error)")
}
// Output: Record 42 from users

do {
let rec = try fetchRecord(id: -1, from: "users")
print(rec)
} catch let err as DatabaseError {
print(err)
print("Retryable: \(err.isRetryable)")
}
// Output: Record -1 not found in users
//         Retryable: false

do {
let rec = try fetchRecord(id: 9999, from: "orders")
print(rec)
} catch let err as DatabaseError {
print(err)
print("Retryable: \(err.isRetryable)")
}
// Output: Operation timed out after 30.0s
//         Retryable: true


================================================================
PART 7 — ADVANCED RECURSIVE ENUM PATTERNS
================================================================

RECURSIVE ENUM — ROSE TREE (N-ARY TREE)
=========================================
indirect enum RoseTree<T> {
case leaf(T)
case branch(T, [RoseTree<T>])

var value: T {
 switch self {
 case .leaf(let v):      return v
 case .branch(let v, _): return v
 }
}

var children: [RoseTree<T>] {
 if case .branch(_, let c) = self { return c }
 return []
}

var isLeaf: Bool {
 if case .leaf = self { return true }
 return false
}

var depth: Int {
 switch self {
 case .leaf:              return 0
 case .branch(_, let c):
     return 1 + (c.map { $0.depth }.max() ?? 0)
 }
}

func map<U>(_ f: (T) -> U) -> RoseTree<U> {
 switch self {
 case .leaf(let v):
     return .leaf(f(v))
 case .branch(let v, let children):
     return .branch(f(v), children.map { $0.map(f) })
 }
}

func flatten() -> [T] {
 switch self {
 case .leaf(let v):
     return [v]
 case .branch(let v, let children):
     return [v] + children.flatMap { $0.flatten() }
 }
}

func filter(_ predicate: (T) -> Bool) -> RoseTree<T>? {
 switch self {
 case .leaf(let v):
     return predicate(v) ? .leaf(v) : nil
 case .branch(let v, let children):
     let kept = children.compactMap { $0.filter(predicate) }
     if !predicate(v) && kept.isEmpty { return nil }
     return .branch(v, kept)
 }
}
}

// Build an organization chart:
let org = RoseTree.branch("CEO", [
.branch("CTO", [
 .branch("Engineering Manager", [
     .leaf("iOS Developer"),
     .leaf("Android Developer"),
     .leaf("Backend Engineer")
 ]),
 .leaf("DevOps Engineer")
]),
.branch("CFO", [
 .leaf("Accountant"),
 .leaf("Finance Analyst")
]),
.branch("CMO", [
 .leaf("Marketing Manager"),
 .leaf("Content Writer")
])
])

print(org.flatten())
// Output: ["CEO", "CTO", "Engineering Manager",
//          "iOS Developer", "Android Developer",
//          "Backend Engineer", "DevOps Engineer",
//          "CFO", "Accountant", "Finance Analyst",
//          "CMO", "Marketing Manager", "Content Writer"]

print(org.depth)
// Output: 3

// Map to uppercase:
let upper = org.map { $0.uppercased() }
print(upper.value)
// Output: CEO

// Filter only leaves containing "Developer":
if let devs = org.filter({ $0.contains("Developer") ||
                      $0.contains("Engineer") }) {
print(devs.flatten())
}
// Output: ["iOS Developer", "Android Developer",
//          "Backend Engineer", "DevOps Engineer"]

RECURSIVE ENUM — DECISION TREE
=================================
indirect enum DecisionTree<Question, Answer> {
case answer(Answer)
case question(
 Question,
 yes: DecisionTree<Question, Answer>,
 no:  DecisionTree<Question, Answer>
)

func evaluate(answering: (Question) -> Bool) -> Answer {
 switch self {
 case .answer(let a):
     return a
 case .question(let q, let yes, let no):
     return (answering(q) ? yes : no)
         .evaluate(answering: answering)
 }
}

var depth: Int {
 switch self {
 case .answer: return 0
 case .question(_, let yes, let no):
     return 1 + max(yes.depth, no.depth)
 }
}
}

// Build a simple loan approval decision tree:
let loanTree = DecisionTree<String, String>.question(
"Credit score >= 700?",
yes: .question(
 "Annual income >= 50,000?",
 yes: .question(
     "Existing debt < 30% income?",
     yes: .answer("APPROVED — Standard Rate"),
     no:  .answer("APPROVED — Higher Rate")
 ),
 no: .answer("CONDITIONALLY APPROVED — Co-signer required")
),
no: .question(
 "Credit score >= 600?",
 yes: .answer("REVIEW REQUIRED — Manual assessment"),
 no:  .answer("DECLINED — Credit score too low")
)
)

print("Tree depth: \(loanTree.depth)")
// Output: Tree depth: 3

// Applicant 1: good credit, good income, low debt:
let a1 = loanTree.evaluate { question in
switch question {
case "Credit score >= 700?":      return true
case "Annual income >= 50,000?":  return true
case "Existing debt < 30% income?": return true
default:                          return false
}
}
print("Applicant 1: \(a1)")
// Output: Applicant 1: APPROVED — Standard Rate

// Applicant 2: poor credit:
let a2 = loanTree.evaluate { question in
switch question {
case "Credit score >= 700?":  return false
case "Credit score >= 600?":  return false
default:                      return false
}
}
print("Applicant 2: \(a2)")
// Output: Applicant 2: DECLINED — Credit score too low

RECURSIVE ENUM — PARSER COMBINATOR
=====================================
indirect enum Parser<T> {
case literal(String, T)
case sequence(Parser<T>, Parser<T>,
           (T, T) -> T)
case choice(Parser<T>, Parser<T>)
case transform(Parser<T>, (T) -> T)

func parse(_ input: String) -> (T, String)? {
 switch self {

 case .literal(let expected, let result3):
     guard input.hasPrefix(expected) else { return nil }
     let remaining = String(input.dropFirst(expected.count))
     return (result3, remaining)

 case .sequence(let p1, let p2, let combine):
     guard let (r1, rest1) = p1.parse(input),
           let (r2, rest2) = p2.parse(rest1) else {
         return nil
     }
     return (combine(r1, r2), rest2)

 case .choice(let p1, let p2):
     return p1.parse(input) ?? p2.parse(input)

 case .transform(let p, let f):
     guard let (r, rest) = p.parse(input) else {
         return nil
     }
     return (f(r), rest)
 }
}
}

// Build parsers for simple expressions:
let parseHello = Parser<String>.literal("hello", "HELLO")
let parseWorld = Parser<String>.literal("world", "WORLD")
let parseSpace = Parser<String>.literal(" ", " ")

let parseGreeting = Parser<String>.sequence(
.sequence(parseHello, parseSpace) { a, b in a + b },
parseWorld
) { a, b in a + b }

if let (result, remaining) = parseGreeting.parse("hello world!") {
print("Parsed: \(result)")
// Output: Parsed: HELLO WORLD
print("Remaining: '\(remaining)'")
// Output: Remaining: '!'
}

if parseGreeting.parse("goodbye world") == nil {
print("Parse failed for 'goodbye world'")
}
// Output: Parse failed for 'goodbye world'


================================================================
PART 8 — COMBINING ALL ENUM FEATURES
================================================================

FULL EXAMPLE: COMMAND PATTERN WITH ALL ENUM FEATURES
=====================================================
// Raw values for command codes:
// Associated values for command data:
// Recursive for composite commands:

indirect enum Command: CustomStringConvertible {
// Simple commands with raw-value-style codes:
case move(dx: Int, dy: Int)
case resize(width: Int, height: Int)
case setColor(r: UInt8, g: UInt8, b: UInt8)
case setOpacity(Double)
case setLabel(String)
case hide
case show

// Composite — recursive:
case sequence([Command])
case conditional(test: String, then: Command, else: Command)
case repeat2(times: Int, command: Command)

// Computed "code" — simulates raw value:
var code: String {
 switch self {
 case .move:        return "MOVE"
 case .resize:      return "RESIZE"
 case .setColor:    return "COLOR"
 case .setOpacity:  return "OPACITY"
 case .setLabel:    return "LABEL"
 case .hide:        return "HIDE"
 case .show:        return "SHOW"
 case .sequence:    return "SEQ"
 case .conditional: return "IF"
 case .repeat2:     return "REPEAT"
 }
}

var description: String {
 switch self {
 case .move(let dx, let dy):
     return "move(\(dx),\(dy))"
 case .resize(let w, let h):
     return "resize(\(w)x\(h))"
 case .setColor(let r, let g, let b):
     return "color(#\(String(format:"%02X%02X%02X",r,g,b)))"
 case .setOpacity(let a):
     return "opacity(\(a))"
 case .setLabel(let l):
     return "label('\(l)')"
 case .hide:          return "hide"
 case .show:          return "show"
 case .sequence(let cmds):
     return "seq[\(cmds.map { $0.description }.joined(separator: ","))]"
 case .conditional(let test, let t, let e):
     return "if(\(test)){\(t)} else{\(e)}"
 case .repeat2(let n, let cmd):
     return "repeat(\(n),\(cmd))"
 }
}

func execute(on target: inout WidgetState) {
 switch self {
 case .move(let dx, let dy):
     target.x += dx
     target.y += dy
 case .resize(let w, let h):
     target.width = w
     target.height = h
 case .setColor(let r, let g, let b):
     target.color = String(format: "#%02X%02X%02X", r, g, b)
 case .setOpacity(let a):
     target.opacity = max(0, min(1, a))
 case .setLabel(let l):
     target.label = l
 case .hide:
     target.visible = false
 case .show:
     target.visible = true
 case .sequence(let cmds):
     cmds.forEach { $0.execute(on: &target) }
 case .conditional(let test, let thenCmd, let elseCmd):
     let result3 = target.evaluate(condition: test)
     (result3 ? thenCmd : elseCmd).execute(on: &target)
 case .repeat2(let n, let cmd):
     for _ in 0..<n { cmd.execute(on: &target) }
 }
}
}

struct WidgetState: CustomStringConvertible {
var x:       Int    = 0
var y:       Int    = 0
var width:   Int    = 100
var height:  Int    = 50
var color:   String = "#000000"
var opacity: Double = 1.0
var label:   String = ""
var visible: Bool   = true

func evaluate(condition: String) -> Bool {
 switch condition {
 case "visible": return visible
 case "hidden":  return !visible
 default:        return false
 }
}

var description: String {
 "Widget(\(label)) @ (\(x),\(y)) \(width)x\(height) "
+ "\(color) opacity=\(opacity) visible=\(visible)"
}
}

var widget = WidgetState()

let setup = Command.sequence([
.setLabel("Button"),
.setColor(r: 0, g: 122, b: 255),
.resize(width: 200, height: 44),
.move(dx: 50, dy: 100)
])

setup.execute(on: &widget)
print(widget)
// Output: Widget(Button) @ (50,100) 200x44
//         #007AFF opacity=1.0 visible=true

let animate = Command.sequence([
.repeat2(times: 3, command: .move(dx: 10, dy: 0)),
.setOpacity(0.5),
.conditional(
 test: "visible",
 then: .setLabel("Active"),
 else: .setLabel("Hidden")
)
])

animate.execute(on: &widget)
print(widget)
// Output: Widget(Active) @ (80,100) 200x44
//         #007AFF opacity=0.5 visible=true

print(setup.description)
// Output: seq[label('Button'),color(#007AFF),
//             resize(200x44),move(50,100)]


================================================================
PART 9 — INTERVIEW QUESTIONS AND ANSWERS WITH OUTPUT
================================================================

================================================================
SECTION 1 — BASIC LEVEL
================================================================

Q1. What is an enum in Swift?
--------------------------------
A: An enum is a value type that defines a finite set
of named cases. It is copied on assignment and
can have methods, computed properties, raw values,
and associated values.
Example:
enum Direction { case north, south, east, west }
var d = Direction.north
print(d)
// Output: north
d = .east
print(d)
// Output: east


Q2. What is a raw value in an enum?
-------------------------------------
A: A raw value is a pre-set constant value for each
case. The raw type must be declared after the
enum name. All cases must have unique raw values.
Example:
enum Planet2: Int {
case mercury = 1, venus, earth, mars
}
print(Planet2.earth.rawValue)
// Output: 3
print(Planet2(rawValue: 2) ?? "none")
// Output: venus


Q3. What type does rawValue initializer return?
------------------------------------------------
A: An Optional of the enum type — T? — because
not every raw value has a matching case.
Example:
enum Direction2: String {
case north, south, east, west
}
let valid   = Direction2(rawValue: "north")
let invalid = Direction2(rawValue: "up")
print(valid ?? "nil")
// Output: north
print(invalid ?? "nil")
// Output: nil


Q4. What are associated values?
---------------------------------
A: Associated values let each case carry custom
data of any type. Different cases can hold
different types and numbers of values.
Unlike raw values, they are set per instance.
Example:
enum Coin {
case penny(year: Int)
case nickel(mint: String)
case dollar(amount: Double)
}
let c = Coin.penny(year: 1995)
if case .penny(let year) = c {
print("Penny from \(year)")
}
// Output: Penny from 1995


Q5. What is the difference between
raw values and associated values?
-----------------------------------------
A: Raw values — compile-time constants, same type
      for all cases, one value per case,
      enables rawValue initializer.
Associated values — set at runtime when creating
      an instance, can differ per case,
      can hold any type/count of values.
Example:
// Raw values — fixed at compile time:
enum Size: Int { case small=1, medium=2, large=3 }
print(Size.medium.rawValue)
// Output: 2

// Associated values — set at creation:
enum Measure {
case weight(Double, unit: String)
case distance(Double, unit: String)
}
let w = Measure.weight(72.5, unit: "kg")
if case .weight(let val, let unit) = w {
print("\(val) \(unit)")
}
// Output: 72.5 kg


Q6. What is CaseIterable?
---------------------------
A: A protocol that gives enums an allCases property
containing all cases in declaration order.
Works automatically if no associated values exist.
Example:
enum Season2: String, CaseIterable {
case spring, summer, autumn, winter
}
print(Season2.allCases.count)
// Output: 4
Season2.allCases.forEach { print($0.rawValue) }
// Output: spring
//         summer
//         autumn
//         winter


Q7. What is a mutating method in an enum?
-------------------------------------------
A: A method that modifies self. Since enums are
value types, any method that changes the
enum value must be marked mutating.
Example:
enum Switch { case on, off
mutating func toggle() {
    self = self == .on ? .off : .on
}
}
var s = Switch.off
s.toggle()
print(s)
// Output: on
s.toggle()
print(s)
// Output: off


Q8. What is an indirect enum?
--------------------------------
A: An enum where one or more cases reference the
enum type itself (recursive). The indirect
keyword allocates the case on the heap to
avoid an infinitely sized value type.
Example:
indirect enum Countdown {
case zero
case tick(Int, next: Countdown)
}
let c2 = Countdown.tick(3,
       next: .tick(2,
           next: .tick(1,
               next: .zero)))

var current = c2
while case .tick(let n, let next) = current {
print(n)
current = next
}
print("Done")
// Output: 3
//         2
//         1
//         Done


Q9. Can an enum have stored properties?
-----------------------------------------
A: No. Enums cannot have stored instance properties.
They CAN have computed properties and static
stored properties.
Example:
enum Planet3: Int {
case mercury=1, venus, earth

// static stored — OK:
static let habitable = Planet3.earth

// computed — OK:
var distanceFromSun: String {
    switch self {
    case .mercury: return "57.9M km"
    case .venus:   return "108.2M km"
    case .earth:   return "149.6M km"
    }
}

// var name = ""  // Error — stored not allowed
}
print(Planet3.earth.distanceFromSun)
// Output: 149.6M km
print(Planet3.habitable)
// Output: earth


Q10. How do you switch over an enum
with associated values?
-----------------------------------------
A: Use switch with pattern binding (let or var)
to extract associated values.
Example:
enum Animal {
case dog(name: String, breed: String)
case cat(name: String, indoor: Bool)
case fish(species: String)
}
let pet = Animal.dog(name: "Rex", breed: "Labrador")
switch pet {
case .dog(let name, let breed):
print("Dog: \(name) (\(breed))")
case .cat(let name, let indoor):
print("Cat: \(name) indoor=\(indoor)")
case .fish(let species):
print("Fish: \(species)")
}
// Output: Dog: Rex (Labrador)


Q11. Can Swift enums conform to protocols?
-------------------------------------------
A: Yes. Enums can conform to any protocol including
Equatable, Hashable, Comparable, Codable, Error,
and custom protocols.
Example:
protocol Describable2 {
var label: String { get }
}
enum Fruit: String, Describable2, CaseIterable {
case apple, banana, cherry
var label: String { "Fruit: \(rawValue)" }
}
Fruit.allCases.forEach { print($0.label) }
// Output: Fruit: apple
//         Fruit: banana
//         Fruit: cherry


Q12. What is the default raw value type
behavior for Int enums?
-----------------------------------------
A: First case defaults to 0, each subsequent case
increments by 1. You can override any case —
the next auto-increments from there.
Example:
enum Flag: Int {
case a      // 0
case b      // 1
case c = 10 // 10 explicit
case d      // 11 auto
case e      // 12 auto
}
print(Flag.a.rawValue)
// Output: 0
print(Flag.c.rawValue)
// Output: 10
print(Flag.e.rawValue)
// Output: 12


Q13. Can you use if case with enums?
--------------------------------------
A: Yes. if case is a pattern-match shortcut for
checking and binding a single enum case without
a full switch statement.
Example:
enum Light { case on(brightness: Int), off }
let bulb = Light.on(brightness: 75)
if case .on(let level) = bulb {
print("Light on at \(level)%")
}
// Output: Light on at 75%
if case .off = bulb {
print("Light is off")
} else {
print("Light is not off")
}
// Output: Light is not off


Q14. Can you add a custom initializer
to an enum?
-----------------------------------------
A: Yes. Enums can have custom (often failable) inits.
Commonly used to create cases from external data
with custom logic.
Example:
enum Vowel: Character {
case a="a", e="e", i="i", o="o", u="u"
init?(_ c: Character) {
    self.init(rawValue: Character(c.lowercased()))
}
}
print(Vowel("A") ?? "not a vowel")
// Output: a
print(Vowel("b") ?? "not a vowel")
// Output: not a vowel


Q15. What is the difference between
switch self and if case?
-----------------------------------------
A: switch self — exhaustive, must cover all cases
        or use default. Best for all-case logic.
if case     — non-exhaustive, for checking one case.
        Simpler for single-case matching.
Example:
enum Mode { case light, dark, system }
var m = Mode.dark

// switch — must cover all:
switch m {
case .light:  print("Light mode")
case .dark:   print("Dark mode")
case .system: print("System mode")
}
// Output: Dark mode

// if case — single check:
if case .dark = m { print("It's dark!") }
// Output: It's dark!


================================================================
SECTION 2 — INTERMEDIATE LEVEL
================================================================

Q16. Can an enum have both raw values
AND associated values?
-----------------------------------------
A: No — not in the same enum. Swift does not allow
mixing raw values and associated values.
Workaround: Use computed properties to simulate
a "code" alongside associated values.
Example:
// enum Mixed: Int {
//   case a = 1
//   case b(String) = 2   // ERROR
// }

// Workaround — computed code:
enum Command2 {
case open(filename: String)
case close
case write(data: String, sync: Bool)

var code: Int {
    switch self {
    case .open:  return 1
    case .close: return 2
    case .write: return 3
    }
}
}
let cmd = Command2.open(filename: "log.txt")
print(cmd.code)
// Output: 1


Q17. How do you implement Equatable for
an enum with associated values?
-----------------------------------------
A: If all associated value types are Equatable,
Swift auto-synthesizes Equatable conformance.
Otherwise, implement == manually.
Example:
enum Point3: Equatable {
case origin
case coordinate(x: Double, y: Double)
case named(String, x: Double, y: Double)
}
// Auto-synthesized since Double and String are Equatable:
print(Point3.origin == .origin)
// Output: true
print(Point3.coordinate(x:1,y:2) == .coordinate(x:1,y:2))
// Output: true
print(Point3.coordinate(x:1,y:2) == .coordinate(x:1,y:3))
// Output: false


Q18. How do indirect and associated values
work together in memory?
-----------------------------------------
A: Without indirect — the enum size is computed at
compile time as: largest associated value + tag.
A recursive enum has infinite size → ERROR.
With indirect — that case is stored as a heap
pointer (8 bytes). Size is now finite and fixed.
Example:
// Shows size impact:
enum Flat {
case a(Int)      // 8 bytes
case b(Double)   // 8 bytes
}
indirect enum Recursive {
case leaf(Int)
case node(Recursive, Recursive)  // 8 bytes (pointer)
}
print(MemoryLayout<Flat>.size)
// Output: 9   (8 payload + 1 tag byte)
print(MemoryLayout<Recursive>.size)
// Output: 8   (pointer size)


Q19. How do enums work with Swift's
Result type?
-----------------------------------------
A: Result<T, E: Error> is a built-in generic enum:
case success(T)
case failure(E)
It is the standard way to return success/failure
from throwing-style APIs without using try/catch.
Example:
enum ParseError2: Error { case invalid(String) }

func parseInt(_ s: String) -> Result<Int, ParseError2> {
guard let n = Int(s) else {
    return .failure(.invalid(s))
}
return .success(n)
}

let r1 = parseInt("42")
let r2 = parseInt("abc")

switch r1 {
case .success(let n): print("Parsed: \(n)")
case .failure(let e): print("Error: \(e)")
}
// Output: Parsed: 42

if case .failure(let e) = r2 {
print("Failed: \(e)")
}
// Output: Failed: invalid("abc")

// map and flatMap on Result:
let doubled5 = r1.map { $0 * 2 }
print(try? doubled5.get() ?? 0)
// Output: Optional(84)


Q20. How do you iterate over all cases
of an enum with associated values?
-----------------------------------------
A: CaseIterable is NOT auto-synthesized for enums
with associated values — you must implement it
manually by providing allCases yourself.
Example:
enum Priority2: CaseIterable {
case low, medium, high, critical

// CaseIterable auto — no assoc values:
// allCases provided automatically
}
print(Priority2.allCases)
// Output: [low, medium, high, critical]

// With associated values — manual:
enum Icon: CaseIterable {
case star, heart, bookmark
// case custom(String)  ← cannot be in allCases
static var allCases: [Icon] = [.star, .heart, .bookmark]
}
print(Icon.allCases.count)
// Output: 3


Q21. What is the difference between
indirect case and indirect enum?
-----------------------------------------
A: indirect enum  — every case in the enum is
           treated as indirect (heap pointer).
indirect case  — only that specific case is indirect.
           Other cases remain value-typed.
Use case-level indirect for better performance
when only some cases are recursive.
Example:
// All cases indirect:
indirect enum TreeA<T> {
case leaf(T)
case node(TreeA<T>, TreeA<T>)
}

// Only recursive case is indirect:
enum TreeB<T> {
case leaf(T)
indirect case node(TreeB<T>, TreeB<T>)
}
// leaf is NOT heap-allocated in TreeB — more efficient

let t = TreeB.node(.leaf(1), .leaf(2))
if case .node(let l, let r) = t,
case .leaf(let lv) = l,
case .leaf(let rv) = r {
print("Node: \(lv) and \(rv)")
}
// Output: Node: 1 and 2


Q22. How do you pattern-match an enum
in a for loop?
-----------------------------------------
A: Use for case let pattern — filters and binds
matching elements in one expression.
Example:
enum Message {
case text(String)
case image(url: String, size: Int)
case video(url: String, duration: Double)
case deleted
}
let chat: [Message] = [
.text("Hello"),
.image(url: "img1.jpg", size: 2048),
.text("How are you?"),
.video(url: "vid.mp4", duration: 12.5),
.deleted,
.text("Goodbye")
]

for case .text(let msg) in chat {
print("Text: \(msg)")
}
// Output: Text: Hello
//         Text: How are you?
//         Text: Goodbye

for case .image(let url, let size) in chat {
print("Image: \(url) (\(size) bytes)")
}
// Output: Image: img1.jpg (2048 bytes)


Q23. How does enum with associated values
help model a state machine?
-----------------------------------------
A: Each case represents a distinct state.
Associated values carry state-specific data.
Transitions are just assignments. The compiler
enforces exhaustive handling of all states.
Example:
enum DownloadState {
case idle
case queued(priority: Int)
case downloading(progress: Double, bytesReceived: Int)
case paused(progress: Double)
case completed(fileURL: String, totalBytes: Int)
case failed(error: String, retryCount: Int)
}

var state2 = DownloadState.idle
state2 = .queued(priority: 1)
state2 = .downloading(progress: 0.45, bytesReceived: 46080)
state2 = .completed(fileURL: "/tmp/file.zip",
                 totalBytes: 102400)

switch state2 {
case .completed(let url, let size):
print("Done: \(url) (\(size) bytes)")
default:
print("Not completed")
}
// Output: Done: /tmp/file.zip (102400 bytes)


Q24. Can an enum case have a default
associated value?
-----------------------------------------
A: Not directly. But you can use a static factory
method or failable initializer to provide defaults.
Example:
enum Config2 {
case server(host: String, port: Int, secure: Bool)

static var defaultServer: Config2 {
    return .server(host: "localhost",
                    port: 8080,
                    secure: false)
}
static func production(host: String) -> Config2 {
    return .server(host: host, port: 443, secure: true)
}
}
let dev  = Config2.defaultServer
let prod = Config2.production(host: "api.example.com")

if case .server(let h, let p, _) = dev {
print("Dev: \(h):\(p)")
}
// Output: Dev: localhost:8080

if case .server(let h, let p, let s) = prod {
print("Prod: \(h):\(p) secure=\(s)")
}
// Output: Prod: api.example.com:443 secure=true


Q25. How do you use enums as
type-safe error codes?
-----------------------------------------
A: Conform to Error protocol. Use associated values
for context. This is Swift's standard error model.
Example:
enum FileError: Error, CustomStringConvertible {
case notFound(path: String)
case permissionDenied(path: String, user: String)
case tooLarge(size: Int, limit: Int)
case corrupted(path: String)

var description: String {
    switch self {
    case .notFound(let p):
        return "File not found: \(p)"
    case .permissionDenied(let p, let u):
        return "\(u) cannot access \(p)"
    case .tooLarge(let s, let l):
        return "File \(s)B exceeds limit \(l)B"
    case .corrupted(let p):
        return "File corrupted: \(p)"
    }
}
}
func readFile(at path: String) throws -> String {
if path.isEmpty { throw FileError.notFound(path: path) }
return "file contents"
}
do {
let _ = try readFile(at: "")
} catch let e as FileError {
print(e)
}
// Output: File not found:


================================================================
SECTION 3 — ADVANCED LEVEL
================================================================

Q26. How does Swift synthesize Equatable
and Hashable for enums?
-----------------------------------------
A: Swift auto-synthesizes Equatable and Hashable for
enums when ALL associated value types conform to
those protocols. Raw value enums get them for free.
Enums with no associated values always get them.
Example:
// No assoc values — auto Equatable/Hashable:
enum Coin2 { case penny, nickel, dime, quarter }

// With Equatable assoc values — auto-synthesized:
enum Result2: Equatable, Hashable {
case value(Int)
case error(String)
}

let r1 = Result2.value(42)
let r2 = Result2.value(42)
let r3 = Result2.error("fail")

print(r1 == r2)
// Output: true
print(r1 == r3)
// Output: false

// Hashable — use in Set/Dict:
let unique: Set<Result2> = [r1, r2, r3]
print(unique.count)
// Output: 2   (r1 and r2 are equal)


Q27. How do you pattern-match multiple
associated values with where clauses?
-----------------------------------------
A: Use where in a switch case to add conditions
beyond just matching the case shape.
Example:
enum Transaction {
case deposit(amount: Double, account: String)
case withdrawal(amount: Double, account: String)
case transfer(from: String, to: String, amount: Double)
}

let txns: [Transaction] = [
.deposit(amount: 1000, account: "A001"),
.withdrawal(amount: 50,   account: "A002"),
.withdrawal(amount: 5000, account: "A001"),
.transfer(from: "A001", to: "A002", amount: 200),
.deposit(amount: 10, account: "A003")
]

for txn in txns {
switch txn {
case .withdrawal(let amt, let acc) where amt > 1000:
    print("⚠️  Large withdrawal: \(amt) from \(acc)")
case .deposit(let amt, _) where amt >= 500:
    print("💰 Large deposit: \(amt)")
case .transfer(let from, let to, let amt) where amt > 100:
    print("💸 Transfer \(amt): \(from) → \(to)")
default:
    break
}
}
// Output: 💰 Large deposit: 1000.0
//         ⚠️  Large withdrawal: 5000.0 from A001
//         💸 Transfer 200.0: A001 → A002


Q28. How do you walk a recursive enum
without stack overflow?
-----------------------------------------
A: For deeply recursive structures, use an
iterative approach with an explicit stack (array)
instead of Swift function recursion which is
limited by the call stack (~512KB on iOS).
Example:
indirect enum Tree2<T> {
case leaf(T)
case node(Tree2<T>, Tree2<T>)
}

// Recursive — may overflow for deep trees:
func sumRecursive(_ tree: Tree2<Int>) -> Int {
switch tree {
case .leaf(let v): return v
case .node(let l, let r):
    return sumRecursive(l) + sumRecursive(r)
}
}

// Iterative — explicit stack — no overflow:
func sumIterative(_ root: Tree2<Int>) -> Int {
var stack: [Tree2<Int>] = [root]
var total = 0
while !stack.isEmpty {
    let current = stack.removeLast()
    switch current {
    case .leaf(let v):
        total += v
    case .node(let l, let r):
        stack.append(l)
        stack.append(r)
    }
}
return total
}

let t3 = Tree2.node(
.node(.leaf(1), .leaf(2)),
.node(.leaf(3), .node(.leaf(4), .leaf(5)))
)
print(sumRecursive(t3))
// Output: 15
print(sumIterative(t3))
// Output: 15


Q29. How do you implement a type-safe
builder using enums?
-----------------------------------------
A: Use an enum to represent each possible configuration
option. Collect an array of options and process them.
This avoids stringly-typed APIs and provides
compile-time safety.
Example:
enum ButtonOption {
case title(String)
case color(String)
case size(width: Double, height: Double)
case cornerRadius(Double)
case enabled(Bool)
case action(() -> Void)
}

struct Button3 {
var title:        String = "Button"
var color:        String = "#007AFF"
var width:        Double = 100
var height:       Double = 44
var cornerRadius: Double = 8
var enabled:      Bool   = true
var action:       (() -> Void)?

init(_ options: [ButtonOption]) {
    for option in options {
        switch option {
        case .title(let t):          title = t
        case .color(let c):          color = c
        case .size(let w, let h):    width = w; height = h
        case .cornerRadius(let r):   cornerRadius = r
        case .enabled(let e):        enabled = e
        case .action(let a):         action = a
    }
}
}

func describe() -> String {
"\(title) \(width)x\(height) \(color)"
+ " r=\(cornerRadius) enabled=\(enabled)"
}

func tap() {
guard enabled else {
 print("\(title) is disabled")
 return
}
action?()
}
}

let btn = Button3([
.title("Submit"),
.color("#34C759"),
.size(width: 200, height: 50),
.cornerRadius(12),
.action { print("Submit tapped!") }
])
print(btn.describe())
// Output: Submit 200.0x50.0 #34C759 r=12.0 enabled=true

btn.tap()
// Output: Submit tapped!

let disabledBtn = Button3([
.title("Cancel"),
.enabled(false)
])
disabledBtn.tap()
// Output: Cancel is disabled


Q30. How do enum cases behave as
first-class functions?
-----------------------------------------
A: Enum cases with associated values act as
functions. You can pass them like closures —
they have a matching function type.
Example:
enum Wrapper<T> {
case some(T)
case none
}

// .some acts as (T) -> Wrapper<T>:
let wrapped = [1, 2, 3].map(Wrapper.some)
for w in wrapped {
if case .some(let v) = w { print(v) }
}
// Output: 1
//         2
//         3

// Real-world — Optional.some is the same pattern:
let strings = ["1", "two", "3"]
let nums2   = strings.compactMap(Int.init)
print(nums2)
// Output: [1, 3]

enum Event2 { case click(Int), hover(Int) }
let ids    = [1, 2, 3]
let clicks = ids.map(Event2.click)   // case as function
for e in clicks {
if case .click(let id) = e { print("Click \(id)") }
}
// Output: Click 1
//         Click 2
//         Click 3


Q31. How do you implement Codable for an
enum with associated values?
-----------------------------------------
A: Swift does NOT auto-synthesize Codable for enums
with associated values (prior to SE-0295 workarounds).
You implement encode and init(from:) manually using
a keyed container and a discriminator key.
Example:
enum Shape2: Codable {
case circle(radius: Double)
case rectangle(width: Double, height: Double)
case point

private enum CodingKeys: String, CodingKey {
case type, radius, width, height
}

init(from decoder: Decoder) throws {
let c = try decoder.container(
 keyedBy: CodingKeys.self)
let type3 = try c.decode(String.self, forKey: .type)
switch type3 {
case "circle":
 let r = try c.decode(Double.self, forKey: .radius)
 self = .circle(radius: r)
case "rectangle":
 let w = try c.decode(Double.self, forKey: .width)
 let h = try c.decode(Double.self, forKey: .height)
 self = .rectangle(width: w, height: h)
default:
 self = .point
}
}

func encode(to encoder: Encoder) throws {
var c = encoder.container(keyedBy: CodingKeys.self)
switch self {
case .circle(let r):
 try c.encode("circle", forKey: .type)
 try c.encode(r, forKey: .radius)
case .rectangle(let w, let h):
 try c.encode("rectangle", forKey: .type)
 try c.encode(w, forKey: .width)
 try c.encode(h, forKey: .height)
case .point:
 try c.encode("point", forKey: .type)
}
}
}

let shapes: [Shape2] = [
.circle(radius: 5),
.rectangle(width: 10, height: 4),
.point
]

let encoder2 = JSONEncoder()
encoder2.outputFormatting = .prettyPrinted

if let data = try? encoder2.encode(shapes),
let json = String(data: data, encoding: .utf8) {
print(json)
}
// Output:
// [
//   {
//     "type" : "circle",
//     "radius" : 5
//   },
//   {
//     "type" : "rectangle",
//     "width" : 10,
//     "height" : 4
//   },
//   {
//     "type" : "point"
//   }
// ]

let jsonStr2 = """
[{"type":"circle","radius":3},{"type":"point"}]
"""
if let data2 = jsonStr2.data(using: .utf8),
let decoded = try? JSONDecoder().decode(
[Shape2].self, from: data2) {
print(decoded.count)
// Output: 2
if case .circle(let r) = decoded[0] {
print("Circle radius: \(r)")
// Output: Circle radius: 3.0
}
}


Q32. How does Swift determine the memory
layout of an enum?
-----------------------------------------
A: Swift uses a tagged union layout:
- Tag byte(s) — identifies the active case
- Payload area — sized to the largest case payload
- Total size aligned to largest alignment requirement
For enums with exactly 2 optional-like cases, Swift
uses a niche optimization (no extra tag byte).
Example:
enum NoPayload    { case a, b, c }
enum SmallPayload { case a(Int8); case b }
enum LargePayload { case a(Int); case b(Double) }

print(MemoryLayout<NoPayload>.size)
// Output: 1      (just a tag byte — 3 cases fit in 1 byte)

print(MemoryLayout<SmallPayload>.size)
// Output: 2      (1 byte payload + 1 byte tag)

print(MemoryLayout<LargePayload>.size)
// Output: 9      (8 byte payload + 1 byte tag)

// Optional<Bool> uses niche — no extra byte:
print(MemoryLayout<Bool>.size)
// Output: 1
print(MemoryLayout<Bool?>.size)
// Output: 1      (nil stored as 2, which Bool never uses)

// Optional<Int> needs extra byte:
print(MemoryLayout<Int>.size)
// Output: 8
print(MemoryLayout<Int?>.size)
// Output: 9


================================================================
SECTION 4 — EXPERT LEVEL
================================================================

Q33. How does Swift implement enum
dispatch for protocol methods?
-----------------------------------------
A: Enum protocol conformance uses the Protocol
Witness Table (PWT). Method calls on protocol
type (existential) go through the PWT — dynamic
dispatch. Method calls on concrete enum type
are statically dispatched (inlined by compiler).
Generic constraints also give static dispatch.
Example:
protocol Toggleable2 {
mutating func toggle2()
var isOn: Bool { get }
}

enum LightSwitch: Toggleable2 {
case on, off
mutating func toggle2() {
self = self == .on ? .off : .on
}
var isOn: Bool { self == .on }
}

// Generic — static dispatch (monomorphized):
func flipTwice<T: Toggleable2>(_ item: inout T) {
item.toggle2()
item.toggle2()
}

var sw = LightSwitch.off
flipTwice(&sw)
print(sw.isOn)
// Output: false   (flipped twice — back to original)

// Existential — dynamic dispatch via PWT:
var item: any Toggleable2 = LightSwitch.off
item.toggle2()
print(item.isOn)
// Output: true


Q34. What is the niche optimization in
Swift enums and how does it work?
-----------------------------------------
A: Swift uses "niche" values to avoid extra tag bytes.
A niche is a bit pattern that a type never uses.
Example: Bool uses 0 (false) and 1 (true).
Bit patterns 2-255 are "niches."
Optional<Bool> uses niche 2 to represent .none —
so it takes 0 extra bytes versus Bool.
Class pointers have alignment niches (low bits).
Example:
enum OneBit { case a, b }

// Optional wrapping uses niche:
print(MemoryLayout<OneBit>.size)
// Output: 1
print(MemoryLayout<OneBit?>.size)
// Output: 1   (niche used — no extra byte)

print(MemoryLayout<OneBit??>.size)
// Output: 1   (two optional levels — still fits!)

print(MemoryLayout<OneBit???>.size)
// Output: 2   (ran out of niches — needs extra byte)

// Class pointer niche (low 3 bits are always 0
// due to alignment — used for optional tag):
class Obj {}
print(MemoryLayout<Obj?>.size)
// Output: 8   (same as non-optional pointer)


Q35. How do you build a type-safe
heterogeneous collection using enums?
-----------------------------------------
A: Wrap multiple types in an enum. The enum acts as
a type-erased container while preserving type info
in each case. Pattern match to recover the type.
Example:
enum AnyValue {
case int(Int)
case double(Double)
case string(String)
case bool(Bool)
case array([AnyValue])
case dict([String: AnyValue])
case null

var description2: String {
switch self {
case .int(let v):    return "\(v)"
case .double(let v): return "\(v)"
case .string(let v): return "\"\(v)\""
case .bool(let v):   return v ? "true" : "false"
case .null:          return "null"
case .array(let v):
 return "[\(v.map { $0.description2 }.joined(separator: ", "))]"
case .dict(let v):
 let pairs = v.sorted { $0.key < $1.key }
     .map { "\"\($0.key)\": \($0.value.description2)" }
 return "{\(pairs.joined(separator: ", "))}"
}
}

var asInt:    Int?    { if case .int(let v)    = self { return v }; return nil }
var asDouble: Double? { if case .double(let v) = self { return v }; return nil }
var asString: String? { if case .string(let v) = self { return v }; return nil }
var asBool:   Bool?   { if case .bool(let v)   = self { return v }; return nil }
}

let config: [String: AnyValue] = [
"host":     .string("api.example.com"),
"port":     .int(443),
"secure":   .bool(true),
"timeout":  .double(30.0),
"tags":     .array([.string("prod"), .string("v2")]),
"retries":  .null
]

for (key, value) in config.sorted(by: { $0.key < $1.key }) {
print("\(key): \(value.description2)")
}
// Output: host: "api.example.com"
//         port: 443
//         retries: null
//         secure: true
//         tags: ["prod", "v2"]
//         timeout: 30.0

print(config["port"]?.asInt ?? -1)
// Output: 443
print(config["secure"]?.asBool ?? false)
// Output: true


Q36. How do you implement a fold/catamorphism
over a recursive enum?
-----------------------------------------
A: A fold (catamorphism) replaces each constructor
of the enum with a function. It reduces the entire
recursive structure to a single value without
explicit pattern matching at the call site.
Example:
indirect enum Expr2 {
case num(Double)
case add(Expr2, Expr2)
case mul(Expr2, Expr2)
case neg(Expr2)
}

// Fold — replace each constructor with a function:
func fold<T>(
_ expr: Expr2,
num: (Double) -> T,
add: (T, T) -> T,
mul: (T, T) -> T,
neg: (T) -> T
) -> T {
switch expr {
case .num(let n):    return num(n)
case .add(let a, let b):
return add(fold(a, num:num, add:add, mul:mul, neg:neg),
        fold(b, num:num, add:add, mul:mul, neg:neg))
case .mul(let a, let b):
return mul(fold(a, num:num, add:add, mul:mul, neg:neg),
        fold(b, num:num, add:add, mul:mul, neg:neg))
case .neg(let e):
return neg(fold(e, num:num, add:add, mul:mul, neg:neg))
}
}

let expr3 = Expr2.add(
.mul(.num(3), .num(4)),
.neg(.num(2))
)
// Expression: (3 * 4) + (-2) = 10

// Evaluate using fold:
let value3 = fold(expr3,
num: { $0 },
add: { $0 + $1 },
mul: { $0 * $1 },
neg: { -$0 }
)
print(value3)
// Output: 10.0

// Pretty-print using fold:
let pretty = fold(expr3,
num: { n in n.truncatingRemainder(dividingBy:1)==0
     ? String(Int(n)) : "\(n)" },
add: { "(\($0) + \($1))" },
mul: { "(\($0) * \($1))" },
neg: { "-\($0)" }
)
print(pretty)
// Output: ((3 * 4) + -2)

// Count nodes using fold:
let nodeCount = fold(expr3,
num: { _ in 1 },
add: { $0 + $1 + 1 },
mul: { $0 + $1 + 1 },
neg: { $0 + 1 }
)
print(nodeCount)
// Output: 5


Q37. How do you make a recursive enum
Codable with arbitrary depth?
-----------------------------------------
A: Implement Codable manually. Use the recursive
nature of the enum to recursively encode/decode.
Each indirect case encodes itself with nested
containers.
Example:
indirect enum NestedList<T: Codable>: Codable {
case empty
case cons(T, NestedList<T>)

private enum CodingKeys: String, CodingKey {
case type, head, tail
}

init(from decoder: Decoder) throws {
let c = try decoder.container(
 keyedBy: CodingKeys.self)
let type4 = try c.decode(String.self, forKey: .type)
if type4 == "empty" {
 self = .empty
} else {
 let head = try c.decode(T.self, forKey: .head)
 let tail = try c.decode(
     NestedList<T>.self, forKey: .tail)
 self = .cons(head, tail)
}
}

func encode(to encoder: Encoder) throws {
var c = encoder.container(keyedBy: CodingKeys.self)
switch self {
case .empty:
 try c.encode("empty", forKey: .type)
case .cons(let head, let tail):
 try c.encode("cons",  forKey: .type)
 try c.encode(head,    forKey: .head)
 try c.encode(tail,    forKey: .tail)
}
}

func toArray() -> [T] {
switch self {
case .empty:           return []
case .cons(let h, let t): return [h] + t.toArray()
}
}
}

let list3: NestedList<Int> = .cons(1, .cons(2, .cons(3, .empty)))
print(list3.toArray())
// Output: [1, 2, 3]

let enc = JSONEncoder()
if let data3 = try? enc.encode(list3),
let jsonStr3 = String(data: data3, encoding: .utf8) {
print(jsonStr3)
// Output: {"type":"cons","head":1,
//          "tail":{"type":"cons","head":2,
//            "tail":{"type":"cons","head":3,
//              "tail":{"type":"empty"}}}}
}

let jsonData = """
{"type":"cons","head":10,
"tail":{"type":"cons","head":20,
"tail":{"type":"empty"}}}
""".data(using: .utf8)!

if let decoded2 = try? JSONDecoder().decode(
NestedList<Int>.self, from: jsonData) {
print(decoded2.toArray())
// Output: [10, 20]
}


Q38. How do you implement mutual recursion
with indirect enums?
-----------------------------------------
A: Two enums (or an enum and a struct) that
reference each other. Each must use indirect
to break the infinite size cycle.
Example:
// Mutually recursive — Expr references Stmt,
// Stmt references Expr:

indirect enum Stmt {
case expression(Expr3)
case block([Stmt])
case ifStmt(condition: Expr3,
     then: Stmt,
     else: Stmt?)
case whileStmt(condition: Expr3, body: Stmt)
case print2(Expr3)
}

indirect enum Expr3 {
case literal(Int)
case variable3(String)
case binary(Expr3, String, Expr3)
case call(name: String, args: [Expr3])
}

// Interpreter:
func evalExpr(_ e: Expr3,
   env: [String: Int]) -> Int {
switch e {
case .literal(let n):      return n
case .variable3(let v):    return env[v] ?? 0
case .binary(let l, let op, let r):
let lv = evalExpr(l, env: env)
let rv = evalExpr(r, env: env)
switch op {
case "+": return lv + rv
case "-": return lv - rv
case "*": return lv * rv
case "<": return lv < rv ? 1 : 0
default:  return 0
}
case .call:     return 0   // simplified
}
}

func execStmt(_ s: Stmt,
   env: inout [String: Int]) {
switch s {
case .expression(let e):
_ = evalExpr(e, env: env)
case .block(let stmts):
stmts.forEach { execStmt($0, env: &env) }
case .ifStmt(let cond, let thenS, let elseS):
if evalExpr(cond, env: env) != 0 {
 execStmt(thenS, env: &env)
} else if let elseS = elseS {
 execStmt(elseS, env: &env)
}
case .whileStmt(let cond, let body):
while evalExpr(cond, env: env) != 0 {
 execStmt(body, env: &env)
}
case .print2(let e):
print(evalExpr(e, env: env))
}
}

// Program: x = 1; while x < 4 { print(x); x = x + 1 }
var env2: [String: Int] = ["x": 1]

let program = Stmt.block([
.whileStmt(
condition: .binary(.variable3("x"), "<", .literal(4)),
body: .block([
 .print2(.variable3("x")),
 .expression(.binary(
     .variable3("x"), "+", .literal(1)))
])
)
])

execStmt(program, env: &env2)
// Output: 1
//         2
//         3


Q39. How does Swift handle enum exhaustiveness
checking and when can you opt out?
-----------------------------------------
A: The compiler requires switch to cover ALL cases.
To opt out: use @unknown default — still warns
if new cases are added to the enum (future-proof).
Use plain default to silently ignore new cases.
Example:
enum APIVersion: Int, CaseIterable {
case v1 = 1
case v2 = 2
case v3 = 3
}

func handleVersion(_ v: APIVersion) {
switch v {
case .v1: print("Version 1 — deprecated")
case .v2: print("Version 2 — stable")
case .v3: print("Version 3 — latest")
}   // exhaustive — no default needed
}
handleVersion(.v2)
// Output: Version 2 — stable

// @unknown default — warns if new cases added
// to the enum later (great for library enums):
func handleVersion2(_ v: APIVersion) {
switch v {
case .v1: print("v1")
case .v2: print("v2")
@unknown default:
print("Future version — update handler!")
}
}
handleVersion2(.v3)
// Output: Future version — update handler!
// (also generates a compiler warning because
//  .v3 is a known case not explicitly handled)

// Exhaustiveness across multiple enums:
enum OS   { case ios, macos, watchos, tvos }
enum Arch { case arm64, x86_64 }

func describe3(os: OS, arch: Arch) -> String {
switch (os, arch) {
case (.ios,    .arm64):  return "iPhone/iPad"
case (.macos,  .arm64):  return "Apple Silicon Mac"
case (.macos,  .x86_64): return "Intel Mac"
case (.watchos,.arm64):  return "Apple Watch"
case (.tvos,   .arm64):  return "Apple TV"
default:                 return "Other config"
}
}
print(describe3(os: .macos, arch: .arm64))
// Output: Apple Silicon Mac


Q40. How do you use enums with Swift Macros
to eliminate boilerplate?
-----------------------------------------
A: Swift 5.9 macros can auto-generate code for enums.
Common use: @CasePathable (Swift Composable Architecture),
custom @EnumCodable, or attached macros that generate
computed properties for each case. Below shows the
manual equivalent of what a macro would generate.
Example (manual macro-equivalent pattern):
// What a @Prism or @CasePath macro would generate:
enum AppAction {
case login(username: String, password: String)
case logout
case updateProfile(name: String, avatar: String?)
case fetchData(page: Int)

// Generated: type-safe case extractors
var asLogin: (username: String, password: String)? {
if case .login(let u, let p) = self {
 return (u, p)
}
return nil
}
var isLogout: Bool {
if case .logout = self { return true }
return false
}
var asUpdateProfile: (name: String, avatar: String?)? {
if case .updateProfile(let n, let a) = self {
 return (n, a)
}
return nil
}
var asFetchData: Int? {
if case .fetchData(let p) = self { return p }
return nil
}

// Generated: case name string
var caseName: String {
switch self {
case .login:         return "login"
case .logout:        return "logout"
case .updateProfile: return "updateProfile"
case .fetchData:     return "fetchData"
}
}
}

let actions: [AppAction] = [
.login(username: "alice", password: "secret"),
.fetchData(page: 2),
.logout,
.updateProfile(name: "Alice Smith", avatar: nil)
]

// Use generated extractors:
for action in actions {
if let login = action.asLogin {
print("Login: \(login.username)")
} else if action.isLogout {
print("Logout")
} else if let page = action.asFetchData {
print("Fetch page \(page)")
} else if let profile = action.asUpdateProfile {
print("Update: \(profile.name)")
}
}
// Output: Login: alice
//         Fetch page 2
//         Logout
//         Update: Alice Smith

print(actions.map { $0.caseName })
// Output: ["login", "fetchData", "logout", "updateProfile"]


================================================================
PART 10 — COMPLETE QUICK REFERENCE CHEAT SHEET
================================================================

ENUM BASICS
Task                               | Code
-----------------------------------|------------------------------------------
Declare enum                       | enum Name { case a, b, c }
Assign                             | var x = Name.a
Short dot syntax                   | x = .b  (when type inferred)
Switch over enum                   | switch x { case .a: ... }
Method in enum                     | func f() -> T { switch self { ... } }
Mutating method                    | mutating func f() { self = .b }
Static property                    | static let default = Name.a
Computed property                  | var label: String { switch self {...} }
CaseIterable                       | enum Name: CaseIterable { }
All cases                          | Name.allCases
Count cases                        | Name.allCases.count

RAW VALUES
Task                               | Code
-----------------------------------|------------------------------------------
Declare raw type                   | enum Name: Int { case a = 1 }
Access raw value                   | Name.a.rawValue
Init from raw value                | Name(rawValue: 1)  → Name?
Auto Int increment                 | case a = 1; case b  // b = 2
Auto String name                   | enum N: String { case hello }
                   | // N.hello.rawValue == "hello"
Character raw value                | enum G: Character { case a = "A" }
Double raw value                   | enum M: Double { case half = 0.5 }
Raw + CaseIterable                 | enum N: String, CaseIterable { }
Raw + Codable                      | enum N: String, Codable { }

ASSOCIATED VALUES
Task                               | Code
-----------------------------------|------------------------------------------
Declare associated value           | case result(Int, String)
Labeled associated value           | case point(x: Double, y: Double)
Extract in switch                  | case .result(let n, let s):
Bind all with single let           | case let .point(x, y):
Ignore with _                      | case .point(let x, _):
Guard match                        | guard case .active = state else { }
if case match                      | if case .loading(let p) = state { }
for case in collection             | for case .text(let s) in items { }
Pattern with where                 | case .value(let n) where n > 0:
As first-class function            | [1,2,3].map(Wrapper.some)

INDIRECT / RECURSIVE ENUM
Task                               | Code
-----------------------------------|------------------------------------------
Entire enum indirect               | indirect enum Tree<T> { ... }
Single case indirect               | indirect case node(Tree, Tree)
Recursive leaf + node              | case leaf(T); indirect case node(T,T)
Walk recursively                   | func f() -> T { switch self { ... } }
Walk iteratively (no overflow)     | var stack = [self]; while !stack.isEmpty
Build from array                   | static func from(_ a: [T]) -> List<T>
Depth of tree                      | var depth: Int { ... max(l,r) + 1 }
Map over recursive enum            | func map(_ f: (T)->U) -> Tree<U>
Flatten to array                   | func flatten() -> [T]
Filter recursive                   | func filter(_ p: (T)->Bool) -> Tree<T>?
Fold / catamorphism                | func fold(leaf:, node:) -> T

PROTOCOL CONFORMANCES
Task                               | Requirement
-----------------------------------|------------------------------------------
Equatable (no assoc values)        | Auto-synthesized
Equatable (assoc values)           | Auto if all assoc types Equatable
Hashable (no assoc values)         | Auto-synthesized
Hashable (assoc values)            | Auto if all assoc types Hashable
Comparable                         | Implement < manually
Codable (raw value)                | Auto-synthesized
Codable (assoc values)             | Manual encode/decode required
CaseIterable (no assoc values)     | Auto-synthesized
CaseIterable (assoc values)        | Manual allCases required
Error                              | Just conform — add context via assoc vals
CustomStringConvertible            | var description: String { ... }

PATTERN MATCHING
Task                               | Code
-----------------------------------|------------------------------------------
switch — all cases                 | switch e { case .a: ... case .b: ... }
switch — with default              | default: ...
switch — exhaustive warning bypass | @unknown default: ...
if case — single case              | if case .a(let v) = expr { }
guard case — early exit            | guard case .a(let v) = e else { return }
for case — filter collection       | for case .a(let v) in array { }
where clause                       | case .a(let v) where v > 0:
Tuple pattern matching             | switch (os, arch) { case (.ios, .arm64): }
Optional pattern                   | if case .some(let v) = optional { }
Nested pattern                     | case .node(.leaf(let v), _):

COMMON ENUM PATTERNS
Pattern                            | Use Case
-----------------------------------|------------------------------------------
State machine                      | Each case = a state, assoc vals = data
Result type                        | .success(T) / .failure(Error)
Command pattern                    | Each case = an action with parameters
Namespace                          | enum Constants { static let x = ... }
Type-safe options / builder        | Array of enum options passed to init
Error type                         | Conform to Error, assoc vals for context
Recursive data structure           | indirect enum for trees, lists, graphs
Heterogeneous collection           | enum wrapping multiple types
JSON/config representation         | indirect enum with recursive cases
Parser / AST                       | Recursive enum for expression trees

ENUM vs STRUCT vs CLASS
Feature                            | Enum    | Struct  | Class
-----------------------------------|---------|---------|--------
Value type                         | Yes     | Yes     | No
Stored instance properties         | No      | Yes     | Yes
Computed properties                | Yes     | Yes     | Yes
Methods                            | Yes     | Yes     | Yes
Mutating methods                   | Yes     | Yes     | N/A
Inheritance                        | No      | No      | Yes
Protocol conformance               | Yes     | Yes     | Yes
Finite named cases                 | Yes     | No      | No
Associated values                  | Yes     | No      | No
Raw values                         | Yes     | No      | No
Recursive (indirect)               | Yes     | No      | N/A
CaseIterable                       | Yes     | No      | No
Pattern matching (switch)          | Full    | Limited | Limited
deinit                             | No      | No      | Yes

SWIFT BUILT-IN ENUMS
Enum                               | Cases
-----------------------------------|------------------------------------------
Optional<T>                        | .some(T), .none
Result<T, E: Error>                | .success(T), .failure(E)
Never                              | (no cases — uninhabited type)
Bool                               | (not enum — but acts like one)
ComparisonResult                   | .orderedAscending, .orderedSame,
                   | .orderedDescending

QUICK DECISION — WHICH ENUM FEATURE?
Scenario                           | Use
-----------------------------------|------------------------------------------
Finite set, no data                | plain enum
Serialize / deserialize (JSON/DB)  | enum: String or Int + Codable
Carry different data per case      | associated values
Walk the enum systematically       | CaseIterable
Represent a tree / list / AST      | indirect enum
Model error types                  | enum: Error with assoc values
Type-safe flags / options          | enum (instead of Int bitmask)
Replace stringly-typed APIs        | enum with raw String values
Configuration options              | enum array passed to builder init
Replace class hierarchy            | protocol + enum (protocol-oriented)

 */
