import UIKit

// MARK: - Basic Types

// Int: whole-number integer type, signed by default.
let age: Int = 28

// UInt: whole-number integer type that can only store non-negative values.
let steps: UInt = 12000

/// If you’re storing money, IDs, or values where exact digits matter, Double is usually the wrong tool.
/// Use Decimal for financial calculations or integers for exact counts.

// Double: 64-bit floating-point number, used for precise decimal values, about 15–17 decimal digits of precision
let price: Double = 19.99

// Float: 32-bit floating-point number, used when less precision is acceptable, about 6–7 decimal digits of precision
let progress: Float = 0.75

// Bool: logical type that stores true or false.
let isActive: Bool = true

// String: collection of characters used for text.
let name: String = "Taylor"

// Character: a single Unicode character.
let grade: Character = "A"

print("Int:", age)
print("UInt:", steps)
print("Double:", price)
print("Double: \(String(format: "%.2f", price))") // Till 2nd decimal number
print("Float:", progress)
print("Bool:", isActive)
print("String:", name)
print("Character:", grade)


/*
 let vs var in Swift
 ===================

 Feature               | let                          | var
 ----------------------|------------------------------|------------------------------
 Meaning               | Constant                     | Variable
 Value changeable?     | No                           | Yes
 Declared with         | let name = value             | var name = value
 Thread safety         | Safer (immutable)            | Less safe if shared
 Performance           | Slightly better              | Slightly less optimized
 Use case              | Values that won't change     | Values that need to change
 Compiler enforcement  | Error if you try to reassign | No restriction on reassignment
 Best practice         | Preferred by Swift (default) | Use only when mutation is needed


 Quick Examples
 ==============

 Scenario                        | Use
 --------------------------------|-------------------------------
 User's name that won't change   | let userName = "Alice"
 Counter that increments         | var count = 0
 API response stored once        | let response = fetchData()
 Score in a game                 | var score = 100
 Fixed tax rate                  | let taxRate = 0.08
 Shopping cart total             | var cartTotal = 0.0


 Best Practice
 =============
 Use let by default.
 Switch to var only when you know the value must change.
 Swift will warn you if a var is never mutated — suggesting you use let instead.
 
 */


// Tuple: groups multiple values into one compound value.
let httpStatus: (code: Int, message: String) = (200, "OK")
print("Tuple:", httpStatus.code, httpStatus.message)

// Optional: a value that may be present or nil.
var middleName: String? = "Rose"
print("Optional value:", middleName ?? "nil")

middleName = nil
print("Optional after nil:", middleName ?? "nil")

if let unwrappedMiddleName = middleName {
    print("Unwrapped:", unwrappedMiddleName)
} else {
    print("middleName is nil")
}

// Array: ordered collection of values of the same type.
let numbers: [Int] = [1, 2, 3, 4, 5]
print("Array:", numbers)

// Set: unordered collection of unique values.
let uniqueTags: Set<String> = ["swift", "ios", "swift"]
print("Set:", uniqueTags.sorted())

// Dictionary: collection of key-value pairs.
let scores: [String: Int] = ["Math": 95, "Science": 89]
print("Dictionary Math score:", scores["Math"] ?? 0)

// Range: defines a sequence of values between bounds.
let halfOpenRange = 1..<5
let closedRange = 1...5
print("Half-open range:", Array(halfOpenRange))
print("Closed range:", Array(closedRange))

// Any: can hold a value of any type.
let mixedValues: [Any] = [42, "Hello", true, 3.14]
print("Any array:", mixedValues)

// MARK: - Type Alias

// Typealias: gives an existing type a new name.
typealias UserID = Int
let currentUserID: UserID = 101
print("Typealias UserID:", currentUserID)

// MARK: - Custom Types

// Struct: a value type used to model data.
struct Person {
    let firstName: String
    let lastName: String

    // Computed property: derives a value from stored properties.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    // Method: behavior attached to the struct.
    func introduce() -> String {
        "Hi, I'm \(fullName)."
    }
}

let person = Person(firstName: "John", lastName: "Appleseed")
print(person.introduce())

// Class: a reference type used for shared mutable state or inheritance.
class Vehicle {
    let brand: String

    init(brand: String) {
        self.brand = brand
    }

    func description() -> String {
        "Vehicle brand: \(brand)"
    }
}

// Inheritance: Car is a subclass of Vehicle.
class Car: Vehicle {
    let model: String

    init(brand: String, model: String) {
        self.model = model
        super.init(brand: brand)
    }

    override func description() -> String {
        "Car: \(brand) \(model)"
    }
}

let car = Car(brand: "Toyota", model: "Camry")
print(car.description())

// Enum: defines a type with a fixed set of related cases.
enum Direction: String {
    case north = "North"
    case south = "South"
    case east = "East"
    case west = "West"
}

let direction = Direction.east
print("Enum raw value:", direction.rawValue)

// Enum with associated values: cases can store additional data.
enum APIResponse {
    case success(data: String)
    case failure(errorCode: Int)
}

let apiResponse = APIResponse.success(data: "User loaded")

switch apiResponse {
case .success(let data):
    print("API success:", data)
case .failure(let errorCode):
    print("API failure:", errorCode)
}

// Protocol: defines a blueprint of methods and properties.
protocol Describable {
    func summary() -> String
}

// Conformance: Book adopts the Describable protocol.
struct Book: Describable {
    let title: String
    let author: String

    func summary() -> String {
        "\(title) by \(author)"
    }
}

let book = Book(title: "Swift Essentials", author: "A. Developer")
print(book.summary())

// Extension: adds new functionality to an existing type.
extension String {
    var trimmedAndUppercased: String {
        trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
}

let rawText = "  hello swift  "
print("Extension result:", rawText.trimmedAndUppercased)

// Error: a type used to represent failures that can be thrown.
enum LoginError: Error {
    case invalidCredentials
}

// Throws: function can signal failure by throwing an error.
func login(username: String, password: String) throws -> String {
    if username == "admin" && password == "1234" {
        return "Login successful"
    }
    throw LoginError.invalidCredentials
}

do {
    let loginMessage = try login(username: "admin", password: "1234")
    print(loginMessage)
} catch {
    print("Login failed:", error)
}

// Generic: a type or function that works with any data type.
struct Box<T> {
    let value: T
}

let intBox = Box(value: 99)
let stringBox = Box(value: "Swift")
print("Generic Box Int:", intBox.value)
print("Generic Box String:", stringBox.value)
