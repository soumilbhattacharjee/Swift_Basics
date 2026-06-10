import UIKit

/*
 // ============================================================
 // SWIFT NOTES: ERROR HANDLING
 // Error Protocol | do-catch | try? | try! | defer
 // ============================================================


 // ============================================================
 // 1. THE ERROR PROTOCOL
 // ============================================================

 // --- WHAT IS IT? ---
 // `Error` is a protocol in Swift that marks a type as
 // representable as an error value. Any type (enum, struct,
 // class) can conform to it. Enums are the most common choice
 // because they model a finite, well-defined set of failure modes.

 // --- BASIC ENUM ERROR ---
 enum NetworkError: Error {
     case notConnected
     case timeout
     case badStatusCode(Int)
     case decodingFailed(String)
 }

 // --- STRUCT ERROR (less common but valid) ---
 struct ValidationError: Error {
     let field: String
     let message: String
 }

 // --- LOCALIZED ERROR ---
 // Conform to LocalizedError to provide human-readable descriptions.
 // Useful for displaying errors in UI.

 enum AuthError: Error, LocalizedError {
     case invalidCredentials
     case accountLocked(until: Date)
     case tokenExpired

     var errorDescription: String? {
         switch self {
         case .invalidCredentials:
             return "The username or password is incorrect."
         case .accountLocked(let date):
             return "Account locked until \(date)."
         case .tokenExpired:
             return "Your session has expired. Please log in again."
         }
     }

     var recoverySuggestion: String? {
         switch self {
         case .invalidCredentials:
             return "Check your credentials and try again."
         case .accountLocked:
             return "Wait until the lock expires or contact support."
         case .tokenExpired:
             return "Navigate to the login screen."
         }
     }
 }

 // Accessing localized description
 let err = AuthError.invalidCredentials
 print(err.localizedDescription)   // "The username or password is incorrect."


 // --- CUSTOM ERROR WITH UNDERLYING CAUSE ---
 // Wrap lower-level errors inside domain-specific ones.
 // Mirrors NSError's `userInfo` pattern but in pure Swift.

 enum DataStoreError: Error {
     case readFailed(underlying: Error)
     case writeFailed(underlying: Error)
     case notFound(key: String)
 }


 // --- THROWING FUNCTIONS ---
 // Mark a function with `throws` to indicate it can throw.
 // Mark with `rethrows` if it only throws when a passed-in
 // closure throws (e.g., map, forEach).

 func fetchUser(id: Int) throws -> String {
     guard id > 0 else {
         throw ValidationError(field: "id", message: "ID must be positive")
     }
     guard id < 1000 else {
         throw NetworkError.badStatusCode(404)
     }
     return "User_\(id)"
 }

 // rethrows example — only throws if the closure throws
 func process(_ items: [Int], using transform: (Int) throws -> Int) rethrows -> [Int] {
     return try items.map(transform)
 }


 // ============================================================
 // ERROR PROTOCOL — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What types can conform to the Error protocol?
 A: Any type — enum, struct, or class. Enums are preferred
    because they cleanly represent a finite set of cases,
    each potentially carrying associated values (context data).

 Q2 (Basic): What is the difference between `Error` and
    `LocalizedError`?
 A: `Error` is the base requirement. `LocalizedError` is a
    refinement that adds optional computed properties:
    `errorDescription`, `failureReason`, `recoverySuggestion`,
    and `helpAnchor`. These provide human-readable strings
    suitable for UI display via `localizedDescription`.

 Q3 (Medium): What does `rethrows` mean and when should
    you use it instead of `throws`?
 A: `rethrows` means a function only propagates errors thrown
    by a closure argument — it doesn't throw on its own.
    This matters because it lets callers skip try/catch when
    they pass a non-throwing closure:

    try process([1,2,3]) { $0 * 2 }  // closure doesn't throw
    process([1,2,3]) { $0 * 2 }      // no try needed!

    If the function were marked `throws`, callers would always
    need `try` regardless of the closure they pass.

 Q4 (Medium): Can you throw values that aren't errors?
    For example, can you throw an Int?
 A: No. Swift requires thrown values to conform to the `Error`
    protocol. Unlike some other languages, you can't throw
    arbitrary values. (Note: Swift 6 introduces typed throws
    — see Hard questions.)

 Q5 (Hard): What are typed throws in Swift 6 and why do
    they matter?
 A: Typed throws (`throws(ErrorType)`) allow a function to
    declare the exact error type it throws, rather than the
    untyped `any Error` existential used in Swift 5.
    Benefits:
    (a) Callers know exactly what errors to handle — exhaustive
        catch becomes possible.
    (b) No existential boxing overhead for the error type —
        better performance in tight loops.
    (c) Generic functions can propagate error types precisely.

    func parse(_ input: String) throws(ParseError) -> Int { ... }

    In Swift 5, `throws` is sugar for `throws(any Error)`.
    Typed throws brings Swift's error system closer to
    Result<T, E>'s precision without the verbosity.

 Q6 (Hard): How does Swift's error handling compare to
    exceptions in Java/C++? Is it truly zero-cost?
 A: Swift's error handling is NOT exception-based. There are
    no stack-unwinding exceptions. Instead, throwing functions
    return errors through a hidden out-parameter in the ABI
    (similar to a Result type under the hood). This means:
    - No stack unwinding overhead on the error path.
    - No dynamic exception tables needed.
    - The happy path (no error) has near-zero overhead.
    - The error path does have some overhead (setting the
      error output, branching) but far less than C++ exceptions.
    This is why Swift docs say "error handling in Swift does
    not involve unwinding the call stack."
 */


 // ============================================================
 // 2. DO-CATCH
 // ============================================================

 // --- BASIC STRUCTURE ---
 // `do` wraps code that can throw.
 // `catch` handles specific errors or acts as a fallback.

 do {
     let user = try fetchUser(id: 5)
     print("Got user: \(user)")
 } catch {
     // `error` is implicitly available here
     print("Something went wrong: \(error)")
 }


 // --- PATTERN MATCHING IN CATCH ---
 // Catch specific cases, with or without associated values.

 func loadProfile(userID: Int) {
     do {
         let user = try fetchUser(id: userID)
         print("Loaded: \(user)")

     } catch let validationErr as ValidationError {
         // Catch and cast to specific error type
         print("Validation failed on '\(validationErr.field)': \(validationErr.message)")

     } catch NetworkError.notConnected {
         print("No internet connection.")

     } catch NetworkError.badStatusCode(let code) where code == 404 {
         // where clause for fine-grained matching
         print("Resource not found (404).")

     } catch NetworkError.badStatusCode(let code) {
         print("Server error with status: \(code)")

     } catch {
         // Catch-all — always place last
         print("Unexpected error: \(error.localizedDescription)")
     }
 }

 loadProfile(userID: -1)   // Validation failed
 loadProfile(userID: 999)  // Success
 loadProfile(userID: 5000) // 404 not found


 // --- MULTICATCH (Swift 5.3+) ---
 // Catch multiple patterns in one clause.

 func handleNetworkError() {
     do {
         let _ = try fetchUser(id: -1)
     } catch NetworkError.notConnected, NetworkError.timeout {
         print("Connectivity issue — retry later.")
     } catch {
         print("Other error: \(error)")
     }
 }


 // --- RE-THROWING ERRORS ---
 // You can catch, augment, then re-throw for layered error handling.

 enum ServiceError: Error {
     case userFetchFailed(underlying: Error)
 }

 func getProfile(id: Int) throws -> String {
     do {
         return try fetchUser(id: id)
     } catch {
         // Wrap the underlying error with domain context
         throw ServiceError.userFetchFailed(underlying: error)
     }
 }


 // --- ERROR HANDLING IN ASYNC CONTEXT ---
 // `try` works seamlessly with `async throws`.

 func fetchRemoteUser(id: Int) async throws -> String {
     // Simulated async throwing function
     try await Task.sleep(nanoseconds: 100_000_000)
     return try fetchUser(id: id)
 }

 // Usage in an async context:
 // do {
 //     let user = try await fetchRemoteUser(id: 5)
 // } catch { ... }


 // ============================================================
 // DO-CATCH — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): Do you need to catch every possible error type
    in a do-catch block?
 A: No. You need at least one catch clause, but it doesn't have
    to be exhaustive. A catch-all `catch { }` at the end covers
    anything not matched by specific clauses. Swift's error
    handling is NOT exhaustive by default (unlike Result<T,E>).

 Q2 (Basic): Where is the implicit `error` variable available?
 A: Inside a catch clause that doesn't bind an explicit variable.
    The compiler automatically provides `let error` in the
    catch body, typed as `any Error`.

 Q3 (Medium): What happens if a function marked `throws` never
    actually throws — is there a performance cost?
 A: On the happy path, the overhead is minimal. The compiler
    emits code to check an error register (or hidden parameter)
    on return, but no stack unwinding infrastructure is set up.
    So yes, calling a `throws` function costs slightly more than
    a non-throwing call, but far less than exception-based
    languages. Use non-throwing functions where you're certain
    no failure is possible.

 Q4 (Medium): Can you use `try` outside of a do-catch block?
 A: Yes — inside a function marked `throws`, you can use `try`
    without a do-catch and the error propagates up to the caller.
    Also `try?` and `try!` can be used anywhere (see next sections).

 Q5 (Hard): What is the difference between catching as a specific
    type with `catch let e as SomeError` vs pattern-matching
    `catch SomeError.someCase`?
 A: `catch let e as SomeError` downcasts the thrown error to
    SomeError and binds the whole value — you get access to all
    cases of SomeError in `e`. This is useful when you handle
    ALL cases of a custom error type together.
    `catch SomeError.someCase` only matches that specific case
    with no binding of the whole error — cleaner for targeting
    one specific failure mode. They differ in scope and binding.

 Q6 (Hard): Can `catch` clauses be exhaustive in Swift, and
    is there a way to get exhaustive error matching?
 A: In standard Swift, catch is NOT exhaustive — you always
    need a catch-all for the compiler to be satisfied.
    To get exhaustive matching, use `Result<T, E>` with a
    `switch` statement on the `.failure` case, or Swift 6 typed
    throws — where the compiler CAN verify all cases of a
    concrete error type are handled, similar to switch on enums.
    This is a significant ergonomic improvement in Swift 6.
 */


 // ============================================================
 // 3. TRY? — OPTIONAL ERROR HANDLING
 // ============================================================

 // --- WHAT IT DOES ---
 // Converts a throwing expression into an Optional.
 // Returns nil if an error is thrown, discarding the error.
 // Returns Optional(value) on success.

 let user1 = try? fetchUser(id: 5)    // Optional("User_5")
 let user2 = try? fetchUser(id: -1)   // nil (error discarded)

 print(user1 ?? "No user")   // User_5
 print(user2 ?? "No user")   // No user


 // --- COMBINING WITH IF LET / GUARD LET ---
 if let user = try? fetchUser(id: 10) {
     print("Found: \(user)")
 } else {
     print("Could not load user (no error detail)")
 }

 func loadUser(id: Int) -> String {
     guard let user = try? fetchUser(id: id) else {
         return "default_user"
     }
     return user
 }


 // --- COMBINING WITH MAP / FLATMAP ---
 // try? plays nicely with functional chaining.

 let userLength = (try? fetchUser(id: 5))?.count   // Optional(6)
 print(userLength ?? 0)


 // --- WHEN TO USE try? ---
 // Use when:
 // (a) Failure is expected and acceptable (cache miss, optional file load)
 // (b) You only care about success/failure, not the reason
 // (c) You have a sensible default to fall back on
 // Avoid when the error carries useful diagnostic info you need.


 // --- NESTED OPTIONALS GOTCHA ---
 // If the return type is already Optional, try? creates Optional<Optional<T>>
 // Swift auto-flattens this — but be aware of it.

 func maybeFind(id: Int) throws -> String? {
     guard id > 0 else { throw NetworkError.notConnected }
     return id == 1 ? "Found" : nil
 }

 let result: String?? = try? maybeFind(id: 1)
 // result is Optional(Optional("Found"))
 // Swift 5+ flattens: let flat = try? maybeFind(id: 1) -> String?
 let flat = try? maybeFind(id: 1)   // "Found" — flattened
 let flat2 = try? maybeFind(id: 99) // nil — not found
 let flat3 = try? maybeFind(id: -1) // nil — threw error


 // ============================================================
 // TRY? — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What is the return type of `try? someThrowingFunc()`
    where someThrowingFunc returns String?
 A: Optional<String> — the value is wrapped in an Optional.
    Success returns Optional("value"), failure returns nil.

 Q2 (Basic): What happens to the error when try? is used?
 A: It is completely discarded. You get no information about
    why the call failed. This is the key trade-off vs do-catch.

 Q3 (Medium): When is try? appropriate vs do-catch?
 A: try? is appropriate when you have a meaningful fallback
    and don't need to distinguish between error types —
    e.g., loading a cached image, checking a keychain value,
    parsing optional config. do-catch is better when the
    error type matters for recovery logic or logging.

 Q4 (Medium): Does try? always return Optional<T> even if
    the function already returns Optional<T>?
 A: In Swift 5+, it DOES flatten — `try? f()` where f returns
    `T?` gives you `T?`, not `T??`. This was a source of bugs
    in Swift 4 and was fixed with SE-0230.

 Q5 (Hard): Can using try? cause silent failures in production?
    How do you guard against it?
 A: Yes — this is the biggest risk. try? swallows errors with
    no trace, making bugs invisible. Mitigations:
    (a) Wrap try? calls in logging helpers:
        func attempting<T>(_ operation: () throws -> T) -> T? {
            do { return try operation() }
            catch { Logger.log(error); return nil }
        }
    (b) Prefer Result<T,E> where you want optional semantics
        BUT need to inspect failure later.
    (c) Use assertions/preconditions in debug builds when nil
        from try? is genuinely unexpected.

 Q6 (Hard): How does try? interact with async throws functions?
 A: It works the same way — `try? await asyncThrowingFunc()`
    returns Optional<T>. The await still suspends the task;
    any thrown error is converted to nil. Important: even
    CancellationError is swallowed, which can mask task
    cancellation silently. In async contexts, be especially
    careful with try? swallowing CancellationError — you
    generally want cancellation to propagate, not be silenced.
 */


 // ============================================================
 // 4. TRY! — FORCED ERROR HANDLING
 // ============================================================

 // --- WHAT IT DOES ---
 // Asserts at runtime that no error will be thrown.
 // If an error IS thrown, the app crashes with a fatal error.
 // Returns an unwrapped (non-Optional) value on success.

 // ONLY use when you have absolute certainty the call won't fail.

 // Safe example: regex from a hardcoded literal (won't fail)
 import Foundation
 let regex = try! NSRegularExpression(pattern: "^[a-z]+$")
 // Pattern is a compile-time constant — guaranteed valid.

 // Another legitimate use: loading a guaranteed bundled resource
 // let data = try! Data(contentsOf: Bundle.main.url(forResource: "seed", withExtension: "json")!)


 // --- WHAT A CRASH LOOKS LIKE ---
 // Uncommenting this will crash at runtime:
 // let badUser = try! fetchUser(id: -1)
 // Fatal error: 'try!' expression unexpectedly raised an error:
 // ValidationError(field: "id", message: "ID must be positive")


 // --- try! vs FORCE UNWRAP ---
 // Philosophically identical — both say "I guarantee this works,
 // crash if I'm wrong." The same discipline applies:
 // document WHY it cannot fail, and prefer safer alternatives
 // in code paths that depend on runtime conditions.

 // ANTI-PATTERN — don't do this:
 // let userData = try! fetchUser(id: userInputID)  // userInputID is runtime data!


 // ============================================================
 // TRY! — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): What happens when try! encounters a thrown error?
 A: The app crashes immediately with a fatal error. No catch
    clause can intercept it — it's an unrecoverable runtime failure.

 Q2 (Basic): When is try! genuinely acceptable?
 A: When the throwing function operates on compile-time constants
    or guaranteed-valid static data — e.g., compiling a known-good
    regex, decoding a hardcoded JSON string, or loading a resource
    that ships with the app bundle and will always be present.

 Q3 (Medium): How is try! different from try? in terms of
    the result type?
 A: try? returns Optional<T> — nil on failure.
    try! returns T (non-optional) — crashes on failure.
    They are both ways to avoid do-catch, but with opposite
    safety trade-offs.

 Q4 (Medium): Is try! ever appropriate in unit tests?
 A: Yes — in test setup (setUp, tearDownWithError) or test
    helper functions where failure means the test itself is
    broken, not the code under test. A crash is acceptable
    because it surfaces misconfigured test infrastructure
    loudly. In test assertions themselves, prefer XCTAssertNoThrow
    for clearer failure messages.

 Q5 (Hard): Can you make try! safe in debug builds while
    using a fallback in release builds?
 A: Not directly — try! always crashes in both configurations.
    A common pattern to achieve "crash in debug, fallback in
    release" is:

    func forceTry<T>(_ operation: () throws -> T,
                     fallback: T,
                     file: StaticString = #file,
                     line: UInt = #line) -> T {
        do {
            return try operation()
        } catch {
            assertionFailure("Unexpected error: \(error)", file: file, line: line)
            return fallback
        }
    }

    assertionFailure crashes in Debug, does nothing in Release —
    giving you loud failures during development with graceful
    degradation in production.

 Q6 (Hard): From an ABI perspective, does try! have any
    overhead compared to a non-throwing call?
 A: Yes, a small amount. The compiler must still check the
    error output (hidden error parameter or register) after
    the call and trap (call the fatal error path) if it's set.
    This is a branch + potential crash — slightly more than a
    plain non-throwing call. In very performance-critical loops,
    prefer non-throwing functions over try! if possible.
    In practice the difference is negligible for most code.
 */


 // ============================================================
 // 5. DEFER — CLEANUP
 // ============================================================

 // --- WHAT IT DOES ---
 // `defer` schedules a block of code to run when the current
 // scope exits — regardless of HOW it exits (return, throw,
 // break, or fall-through to end of scope). This guarantees
 // cleanup always happens.

 func readFile(named name: String) throws -> String {
     print("Opening file: \(name)")
     // defer is registered here, but runs at scope exit
     defer {
         print("Closing file: \(name)")   // ALWAYS runs
     }

     guard name != "missing.txt" else {
         throw NetworkError.notConnected   // defer still runs
     }

     return "Contents of \(name)"
 }

 // Success path — defer still runs
 let contents = try? readFile(named: "data.txt")
 // Prints: Opening file: data.txt
 //         Closing file: data.txt

 // Error path — defer still runs
 let _ = try? readFile(named: "missing.txt")
 // Prints: Opening file: missing.txt
 //         Closing file: missing.txt


 // --- MULTIPLE DEFERS — LIFO ORDER ---
 // Multiple defers in the same scope execute in REVERSE order
 // (Last In, First Out — like a stack). Think: cleanup should
 // mirror setup in reverse.

 func multiDefer() {
     defer { print("Third defer — runs FIRST") }
     defer { print("Second defer — runs SECOND") }
     defer { print("First defer — runs THIRD") }
     print("Body executing")
 }

 multiDefer()
 // Body executing
 // First defer — runs THIRD      <- reversed
 // Second defer — runs SECOND
 // Third defer — runs FIRST


 // --- REAL-WORLD CLEANUP PATTERNS ---

 // 1. Lock / unlock
 import Foundation

 let lock = NSLock()

 func criticalSection() {
     lock.lock()
     defer { lock.unlock() }   // guaranteed unlock even if early return

     // ... do thread-sensitive work ...
     // No risk of forgetting unlock if an early return is added later
 }


 // 2. Showing / hiding loading indicator
 func loadData(completion: () -> Void) {
     // showLoadingSpinner()
     defer { /* hideLoadingSpinner() */ }

     completion()
     // Spinner hidden even if completion returns early
 }


 // 3. Database transaction rollback
 enum DBError: Error { case queryFailed }

 func runTransaction(shouldFail: Bool) throws {
     print("BEGIN TRANSACTION")
     var committed = false

     defer {
         if !committed {
             print("ROLLBACK")   // runs if commit never reached
         }
     }

     if shouldFail { throw DBError.queryFailed }

     print("COMMIT")
     committed = true
 }

 try? runTransaction(shouldFail: false)
 // BEGIN TRANSACTION → COMMIT  (no rollback, committed = true)

 try? runTransaction(shouldFail: true)
 // BEGIN TRANSACTION → ROLLBACK  (committed stays false)


 // 4. Temporary state restoration
 func withTemporaryValue(_ newValue: Int, on object: inout Int, action: () -> Void) {
     let original = object
     object = newValue
     defer { object = original }   // always restore
     action()
 }


 // --- DEFER AND RETURN VALUES ---
 // defer runs AFTER the return value is captured, but BEFORE
 // the function actually returns. It cannot change the return value.

 func deferWithReturn() -> String {
     defer { print("defer ran") }
     return "result"   // "result" is captured first, then defer runs
 }

 let val = deferWithReturn()
 // Prints: defer ran
 // val = "result"


 // --- DEFER GOTCHA: VARIABLE CAPTURE ---
 // defer captures variables by REFERENCE (for value types, it
 // captures the variable binding — so it sees the final value).

 func deferCaptureExample() {
     var x = 0
     defer { print("x in defer: \(x)") }   // captures binding
     x = 42
     print("x before exit: \(x)")
 }

 deferCaptureExample()
 // x before exit: 42
 // x in defer: 42   <- sees final value, NOT the value at defer registration


 // ============================================================
 // DEFER — INTERVIEW QUESTIONS
 // ============================================================

 /*
 Q1 (Basic): When does a defer block execute?
 A: When the enclosing scope exits — regardless of how.
    Whether the scope exits via return, throw, break, continue,
    or naturally reaching the end, defer always runs.

 Q2 (Basic): Can defer be used outside of a do-catch or
    throwing function?
 A: Yes. defer works in any scope: functions, loops, if blocks,
    closures. It's not specific to error handling — it's a
    general scope-exit guarantee.

 Q3 (Medium): What is the execution order when multiple
    defer statements are in the same scope?
 A: LIFO — Last In, First Out. The last defer registered
    executes first. This mirrors the natural "undo" order
    of setup operations: if you open A then B, you close B
    then A.

 Q4 (Medium): Can a defer block throw an error?
 A: No — defer blocks cannot throw. If you need cleanup that
    might fail, you must handle errors internally within
    the defer block (e.g., with try? or do-catch inside defer).
    A defer block with unhandled `try` won't compile.

    defer {
        try? cleanup()   // OK — error is swallowed
        // try cleanup() // ERROR — won't compile
    }

 Q5 (Hard): What value does defer see if a variable is
    modified after the defer is registered?
 A: The final value at the time of scope exit. defer captures
    the variable BINDING, not the value at registration time.
    So if x is 0 when defer is registered but 42 when the
    scope exits, defer sees 42. This is a frequent interview
    gotcha. To capture the VALUE at registration time, copy
    it into a local constant inside the defer closure:

    var x = 0
    let capturedX = x
    defer { print(capturedX) }   // always prints 0
    x = 42

 Q6 (Hard): How does defer interact with inout parameters?
    Is the deferred code guaranteed to run before the
    inout write-back?
 A: Yes — defer runs before the function returns, which means
    it runs BEFORE inout write-back occurs. So modifications
    to the inout parameter inside defer ARE reflected in
    the caller's variable. This matters in complex mutation
    scenarios — defer can be used to finalize inout state
    as a form of post-condition enforcement:

    func normalize(_ value: inout Double) {
        defer {
            if value < 0 { value = 0 }   // enforced at exit
        }
        value -= 10.0   // might go negative
    }

 Q7 (Hard): Can defer be used inside a closure, and does
    it respect the closure's scope exit?
 A: Yes. defer inside a closure runs when the closure's own
    scope exits — not the outer function's scope. This is
    important when closures outlive their enclosing function
    (e.g., async callbacks, escaping closures). Each scope
    boundary is independent for defer purposes.

    let operation = {
        defer { print("Closure done") }
        print("Closure body")
    }
    operation()
    // Closure body
    // Closure done
 */


 // ============================================================
 // PUTTING IT ALL TOGETHER — REAL-WORLD EXAMPLE
 // ============================================================

 enum FileError: Error, LocalizedError {
     case notFound(String)
     case permissionDenied
     case corrupted(reason: String)

     var errorDescription: String? {
         switch self {
         case .notFound(let name): return "File '\(name)' not found."
         case .permissionDenied:  return "Permission denied."
         case .corrupted(let r):  return "File corrupted: \(r)"
         }
     }
 }

 class FileProcessor {
     private var isOpen = false

     func open(file: String) throws {
         guard file != "missing.txt" else { throw FileError.notFound(file) }
         guard file != "locked.txt"  else { throw FileError.permissionDenied }
         isOpen = true
         print("Opened: \(file)")
     }

     func close() {
         isOpen = false
         print("File closed")
     }

     func process(file: String) -> String {
         do {
             try open(file: file)
             defer { close() }          // guaranteed close

             // ... process file contents ...
             return "Processed \(file)"

         } catch let fileErr as FileError {
             return fileErr.localizedDescription ?? "File error"

         } catch {
             return "Unknown error: \(error)"
         }
     }
 }

 let processor = FileProcessor()

 print(processor.process(file: "data.txt"))
 // Opened: data.txt → File closed → "Processed data.txt"

 print(processor.process(file: "missing.txt"))
 // "File 'missing.txt' not found." (defer doesn't run — open() failed before defer registered)

 // Note: defer only runs for the scope it's registered in.
 // If open() throws, we never reach the defer line — this is correct behavior.
 // The file was never opened, so there's nothing to close.


 // ============================================================
 // END OF NOTES
 // ============================================================

 
 // ============================================================
 // SWIFT ERROR HANDLING — 100+ INTERVIEW QUESTIONS
 // Error Protocol | do-catch | try? | try! | defer
 // ============================================================
 // FORMAT: Q = Question | A = Answer | Difficulty tagged
 // Levels: [BASIC] | [MEDIUM] | [HARD] | [EXPERT]
 // ============================================================


 // ============================================================
 // SECTION 1: THE ERROR PROTOCOL (Q1–Q25)
 // ============================================================

 /*
 ─────────────────────────────────────────────
 Q1 [BASIC]
 What is the Error protocol in Swift?
 ─────────────────────────────────────────────
 A: `Error` is a marker protocol in Swift that any type can
    conform to in order to be thrown and caught. It has no
    required methods or properties — conforming to it simply
    signals "this type represents an error value."
    Enums are the most idiomatic choice because they model
    a finite, named set of failure modes.


 ─────────────────────────────────────────────
 Q2 [BASIC]
 Why are enums preferred for defining error types?
 ─────────────────────────────────────────────
 A: Enums naturally represent a closed, exhaustive set of
    cases. Each case can carry associated values (context data),
    they're lightweight (value types), and switch statements
    on them are exhaustive — the compiler ensures you handle
    every case. This makes error handling predictable and
    self-documenting.


 ─────────────────────────────────────────────
 Q3 [BASIC]
 Can a struct or class conform to Error?
 ─────────────────────────────────────────────
 A: Yes. Any Swift type — enum, struct, or class — can conform
    to Error. Structs are useful when errors carry mutable or
    complex state. Classes are useful for error hierarchies
    (subclassing). Enums remain the most common and idiomatic.

    struct NetworkError: Error {
        let statusCode: Int
        let message: String
    }


 ─────────────────────────────────────────────
 Q4 [BASIC]
 What is LocalizedError and how does it differ from Error?
 ─────────────────────────────────────────────
 A: `LocalizedError` refines `Error` by adding optional
    computed properties:
    - errorDescription: String?
    - failureReason: String?
    - recoverySuggestion: String?
    - helpAnchor: String?

    These are surfaced through `localizedDescription`.
    If you don't implement them, you fall back to a generic
    system message. Use LocalizedError when errors need
    to be presented to users.


 ─────────────────────────────────────────────
 Q5 [BASIC]
 What keyword marks a function as capable of throwing errors?
 ─────────────────────────────────────────────
 A: `throws` — placed between the parameter list and
    the return type.

    func load(id: Int) throws -> String { ... }

    Callers must use `try` when calling it.


 ─────────────────────────────────────────────
 Q6 [BASIC]
 What keyword is used to throw an error from a function?
 ─────────────────────────────────────────────
 A: `throw` — followed by an Error-conforming value.

    throw NetworkError.timeout
    throw ValidationError(field: "email", message: "Invalid format")


 ─────────────────────────────────────────────
 Q7 [BASIC]
 Can a function marked throws also return a value?
 ─────────────────────────────────────────────
 A: Yes. A throws function can either return a value on
    success OR throw an error on failure — but not both
    simultaneously. The return type is the success type only.

    func parse(_ input: String) throws -> Int { ... }


 ─────────────────────────────────────────────
 Q8 [BASIC]
 What is the difference between throw and return in a
 throwing function?
 ─────────────────────────────────────────────
 A: `return` exits normally with a value.
    `throw` exits abnormally with an error.
    A throws function uses one or the other — never both
    for the same execution path.


 ─────────────────────────────────────────────
 Q9 [BASIC]
 Does conforming to Error require implementing any methods?
 ─────────────────────────────────────────────
 A: No. `Error` is an empty protocol — it has no required
    methods or properties. It serves purely as a marker
    to make a type throwable.


 ─────────────────────────────────────────────
 Q10 [BASIC]
 Can you throw nil in Swift?
 ─────────────────────────────────────────────
 A: No. You can only throw values that conform to the Error
    protocol. nil is not an Error-conforming value.
    Use Optional return types or failable initializers
    to signal absence of a value rather than failure.


 ─────────────────────────────────────────────
 Q11 [MEDIUM]
 What is the difference between throws and rethrows?
 ─────────────────────────────────────────────
 A: `throws` means the function itself can throw.
    `rethrows` means the function only throws if a closure
    argument it receives throws — it never throws on its own.

    Key benefit: callers passing a non-throwing closure
    don't need `try`:

    func transform(_ arr: [Int], using fn: (Int) throws -> Int)
        rethrows -> [Int] {
        return try arr.map(fn)
    }

    transform([1,2,3]) { $0 * 2 }       // no try needed
    try transform([1,2,3]) { try parse($0) } // try needed


 ─────────────────────────────────────────────
 Q12 [MEDIUM]
 Can you have associated values in error enum cases?
 ─────────────────────────────────────────────
 A: Yes — this is one of the key reasons enums are ideal
    for errors. Associated values carry contextual data:

    enum ParseError: Error {
        case invalidFormat(line: Int, column: Int)
        case unexpectedToken(found: String, expected: String)
        case overflow(value: Double, max: Double)
    }

    throw ParseError.invalidFormat(line: 3, column: 12)


 ─────────────────────────────────────────────
 Q13 [MEDIUM]
 What is CustomNSError and when would you use it?
 ─────────────────────────────────────────────
 A: `CustomNSError` bridges Swift errors to NSError for
    Objective-C interop. It requires:
    - static var errorDomain: String
    - var errorCode: Int
    - var errorUserInfo: [String: Any]

    Use it when your Swift error needs to be passed to
    Obj-C APIs, logged via NSError, or integrated with
    frameworks that use NSError-based APIs.


 ─────────────────────────────────────────────
 Q14 [MEDIUM]
 How do you wrap a low-level error inside a domain-specific
 higher-level error?
 ─────────────────────────────────────────────
 A: Use an associated value to capture the underlying error:

    enum ServiceError: Error {
        case fetchFailed(underlying: Error)
        case saveFailed(underlying: Error)
    }

    do {
        try coreDataSave()
    } catch {
        throw ServiceError.saveFailed(underlying: error)
    }

    This preserves the root cause while adding domain context.


 ─────────────────────────────────────────────
 Q15 [MEDIUM]
 Can throwing functions be used as first-class values
 (stored in variables, passed as arguments)?
 ─────────────────────────────────────────────
 A: Yes. The type includes `throws` in its signature:

    var operation: (Int) throws -> String
    operation = fetchUser   // fetchUser is (Int) throws -> String

    let handlers: [(String) throws -> Void] = [step1, step2]


 ─────────────────────────────────────────────
 Q16 [MEDIUM]
 What happens to NSException vs Swift Error — are they
 the same?
 ─────────────────────────────────────────────
 A: No — they are completely different mechanisms.
    NSException (Objective-C) involves stack unwinding
    and is NOT caught by Swift's do-catch. Swift Error
    uses hidden return parameters, no unwinding.
    NSException crossing Swift code causes undefined behavior
    or crashes. Never rely on catching NSException in Swift.


 ─────────────────────────────────────────────
 Q17 [MEDIUM]
 Can you make an existing type you don't own (e.g., String)
 conform to Error?
 ─────────────────────────────────────────────
 A: Yes via extension, but it's strongly discouraged.
    It works technically:

    extension String: Error {}
    throw "Something went wrong"  // compiles

    But it pollutes the String namespace globally and
    causes confusion. Define a proper custom Error type instead.
    In Swift 5.7+ this may also trigger retroactive
    conformance warnings.


 ─────────────────────────────────────────────
 Q18 [MEDIUM]
 How does Swift represent a throwing function's error
 at the ABI level?
 ─────────────────────────────────────────────
 A: Swift passes a hidden extra parameter — effectively an
    output pointer to an error value. On success it's nil;
    on failure it holds the thrown error. No exception tables
    or stack unwinding needed. This makes the happy path
    essentially free and the error path only slightly more
    expensive than a normal return.


 ─────────────────────────────────────────────
 Q19 [HARD]
 What are typed throws (Swift 6) and how do they change
 error handling ergonomics?
 ─────────────────────────────────────────────
 A: Typed throws allow declaring the exact error type:

    func parse(_ s: String) throws(ParseError) -> Int { ... }

    Benefits:
    1. Exhaustive catch — compiler verifies all ParseError
       cases are handled (no catch-all required).
    2. No existential boxing — avoids `any Error` overhead,
       enabling compiler optimizations.
    3. Generic error propagation:
       func map<T, E>(_ fn: () throws(E) -> T) throws(E) -> T

    `throws` alone is sugar for `throws(any Error)` in Swift 6.


 ─────────────────────────────────────────────
 Q20 [HARD]
 What is the Result type and how does it relate to
 Swift's throw/catch mechanism?
 ─────────────────────────────────────────────
 A: Result<Success, Failure: Error> is an enum:
    case success(Success) | case failure(Failure)

    It's an ALTERNATIVE to throws — useful when:
    - Errors need to be passed asynchronously (callbacks)
    - You want to store success/failure in a variable
    - You want exhaustive typed error handling (Result<T, MyError>)

    Converting between them:
    // throws -> Result
    let result = Result { try fetchUser(id: 5) }

    // Result -> throws
    let user = try result.get()


 ─────────────────────────────────────────────
 Q21 [HARD]
 What is error type erasure and when is it necessary?
 ─────────────────────────────────────────────
 A: Type erasure converts a concrete Error type to `any Error`
    (the existential). It's necessary when:
    - Combining errors from multiple subsystems
    - Storing heterogeneous errors in arrays
    - Returning from functions that don't know the specific type

    func combineErrors(_ errors: [any Error]) -> String {
        errors.map { $0.localizedDescription }.joined(separator: "\n")
    }

    The cost: you lose compile-time exhaustiveness.
    Solution: use typed throws or Result<T, E> to preserve type.


 ─────────────────────────────────────────────
 Q22 [HARD]
 How does Error conform to Sendable and why does
 it matter in Swift concurrency?
 ─────────────────────────────────────────────
 A: In Swift 5.7+, `Error` has a retroactive conformance
    to `Sendable`, meaning thrown errors can be safely passed
    across actor/task boundaries. This matters because:
    - Tasks can throw errors back to their parent
    - Actors can propagate errors across isolation boundaries
    If you define a custom Error type with non-Sendable
    properties (like a class reference), you may get
    warnings in strict concurrency mode. Make error types
    structs or enums with Sendable-conforming associated values.


 ─────────────────────────────────────────────
 Q23 [HARD]
 What is the difference between an Error and a precondition/
 assertion failure?
 ─────────────────────────────────────────────
 A: Error: recoverable, expected failure condition —
    invalid user input, network timeout, missing file.
    Can be caught and handled.

    preconditionFailure / assertionFailure / fatalError:
    programmer error — violated invariant, impossible state.
    These are NOT catchable. They terminate the process.

    Rule of thumb:
    - If it could happen in production with valid usage → Error
    - If it represents "this should never happen" → precondition


 ─────────────────────────────────────────────
 Q24 [EXPERT]
 How would you design a hierarchical error type system
 for a large-scale app (network, persistence, validation
 layers)?
 ─────────────────────────────────────────────
 A: Layer errors by domain, with wrapping at boundaries:

    // Domain-level errors
    enum NetworkError: Error { case timeout, unauthorized, notFound }
    enum PersistenceError: Error { case writeFailure, readFailure }
    enum ValidationError: Error { case invalidInput(field: String) }

    // App-level aggregate
    enum AppError: Error {
        case network(NetworkError)
        case persistence(PersistenceError)
        case validation(ValidationError)
        case unknown(underlying: Error)
    }

    // Repository layer wraps domain errors
    func loadUser(id: Int) throws -> User {
        do { return try network.fetch(id) }
        catch let e as NetworkError { throw AppError.network(e) }
        catch { throw AppError.unknown(underlying: error) }
    }

    Benefits: UI only imports AppError; domain layers stay decoupled;
    typed throws (Swift 6) can make each layer exhaustive.


 ─────────────────────────────────────────────
 Q25 [EXPERT]
 How do you handle errors in property getters and setters?
 ─────────────────────────────────────────────
 A: Stored properties and non-subscript getters CANNOT throw.
    Subscript getters CAN be marked throws:

    struct SafeArray<T> {
        private var storage: [T]
        enum AccessError: Error { case outOfBounds(Int) }

        subscript(index: Int) throws -> T {
            get throws {
                guard storage.indices.contains(index) else {
                    throw AccessError.outOfBounds(index)
                }
                return storage[index]
            }
        }
    }

    let val = try safeArray[5]

    For regular properties that depend on fallible state,
    use throwing methods or lazy initialization with Result.
 */


 // ============================================================
 // SECTION 2: DO-CATCH (Q26–Q50)
 // ============================================================

 /*
 ─────────────────────────────────────────────
 Q26 [BASIC]
 What is the purpose of a do-catch block?
 ─────────────────────────────────────────────
 A: `do` marks a scope where errors can be thrown.
    `catch` clauses intercept and handle those errors.
    Together they prevent errors from propagating further
    up the call stack.


 ─────────────────────────────────────────────
 Q27 [BASIC]
 What is the implicit variable available in a catch clause?
 ─────────────────────────────────────────────
 A: `error` — automatically bound to the thrown value,
    typed as `any Error`. Available in any catch clause
    that doesn't explicitly bind its own variable.

    do { try riskyOperation() }
    catch { print(error.localizedDescription) }


 ─────────────────────────────────────────────
 Q28 [BASIC]
 Does every do block require a catch clause?
 ─────────────────────────────────────────────
 A: Yes — a `do` block that calls throwing functions must
    have at least one catch clause. However, if no throwing
    calls exist inside `do`, no catch is required
    (though the compiler may warn about unnecessary do).


 ─────────────────────────────────────────────
 Q29 [BASIC]
 Can you have multiple catch clauses for one do block?
 ─────────────────────────────────────────────
 A: Yes — as many as you need, each matching different
    error types or cases. They're evaluated top-to-bottom;
    the first matching clause wins.

    do { try operation() }
    catch SpecificError.caseA { ... }
    catch SpecificError.caseB { ... }
    catch { ... }   // catch-all — must be last


 ─────────────────────────────────────────────
 Q30 [BASIC]
 What happens if no catch clause matches the thrown error?
 ─────────────────────────────────────────────
 A: The error propagates up to the enclosing scope.
    If no scope catches it and it reaches the top level,
    the app crashes. This is why a catch-all `catch { }`
    at the end is good practice when you can't enumerate
    all possible errors.


 ─────────────────────────────────────────────
 Q31 [BASIC]
 Can you use try inside a function without a do-catch?
 ─────────────────────────────────────────────
 A: Yes — if the function itself is marked `throws`.
    The error simply propagates upward to the caller.
    You only need do-catch if you want to HANDLE the error
    at that level rather than propagate it.


 ─────────────────────────────────────────────
 Q32 [BASIC]
 Is Swift's error handling exhaustive like switch statements?
 ─────────────────────────────────────────────
 A: No — unlike switch on an enum (which must cover all cases),
    catch clauses don't need to cover every possible error.
    You always need a catch-all to satisfy the compiler,
    but that single wildcard clause covers everything else.


 ─────────────────────────────────────────────
 Q33 [BASIC]
 Can you catch errors from multiple throwing calls
 in one do block?
 ─────────────────────────────────────────────
 A: Yes. One do block can contain multiple try calls and one
    set of catch clauses handles all of them:

    do {
        let user = try fetchUser(id: 5)
        let profile = try loadProfile(for: user)
        try saveToCache(profile)
    } catch NetworkError.timeout {
        print("Network timed out")
    } catch {
        print("Other error: \(error)")
    }


 ─────────────────────────────────────────────
 Q34 [BASIC]
 What is catch pattern matching with where clauses?
 ─────────────────────────────────────────────
 A: A `where` clause adds a condition to a catch pattern:

    catch NetworkError.badStatusCode(let code) where code >= 500 {
        print("Server error: \(code)")
    }
    catch NetworkError.badStatusCode(let code) {
        print("Client error: \(code)")
    }


 ─────────────────────────────────────────────
 Q35 [BASIC]
 Can you throw inside a catch clause?
 ─────────────────────────────────────────────
 A: Yes — re-throwing (potentially with transformation)
    is common:

    do { try operation() }
    catch let original {
        Logger.log(original)
        throw AppError.wrapped(original)   // re-throw as different type
    }


 ─────────────────────────────────────────────
 Q36 [MEDIUM]
 What is multicatch syntax (Swift 5.3+)?
 ─────────────────────────────────────────────
 A: Multiple patterns in a single catch clause, separated by commas:

    catch NetworkError.timeout, NetworkError.notConnected {
        showRetryAlert()
    }

    This avoids duplicating the same handler for similar cases.
    Note: you cannot bind associated values in multicatch clauses.


 ─────────────────────────────────────────────
 Q37 [MEDIUM]
 What is the difference between catching as a type vs
 catching a specific case?
 ─────────────────────────────────────────────
 A: `catch let e as NetworkError` — downcasts, binds the WHOLE
    error value of that type. Access any case via switch on e.

    `catch NetworkError.timeout` — matches only that specific
    case. No binding of the full error value.

    Use the first when handling all cases of an error type
    together; the second for targeting one specific failure.


 ─────────────────────────────────────────────
 Q38 [MEDIUM]
 How do you propagate errors through a chain of functions
 without handling them at every level?
 ─────────────────────────────────────────────
 A: Mark each intermediate function `throws` and use `try`
    without do-catch. Only the outermost caller handles it:

    func step1() throws { try step2() }
    func step2() throws { try step3() }
    func step3() throws { throw SomeError.failure }

    // Only top level catches:
    do { try step1() } catch { print(error) }


 ─────────────────────────────────────────────
 Q39 [MEDIUM]
 Can you use guard with try inside a throws function?
 ─────────────────────────────────────────────
 A: Yes — guard + try works cleanly:

    func process(id: Int) throws -> String {
        guard let user = try? fetchUser(id: id) else {
            throw ProcessingError.userNotFound(id)
        }
        return user
    }

    Or with do-catch inside guard:
    guard (try? riskyOp()) != nil else { throw MyError.failed }


 ─────────────────────────────────────────────
 Q40 [MEDIUM]
 Can you use try in a closure? What constraints apply?
 ─────────────────────────────────────────────
 A: Yes, but the closure must itself be marked `throws`
    (or be passed to a `rethrows` function):

    let doubled = try [1, 2, 3].map { num -> Int in
        guard num > 0 else { throw MathError.negative }
        return num * 2
    }

    Non-escaping rethrows functions (like map, filter, forEach)
    handle this automatically. Escaping closures that throw
    must be typed as `() throws -> T`.


 ─────────────────────────────────────────────
 Q41 [MEDIUM]
 What is the execution order inside a do block after
 a throw occurs?
 ─────────────────────────────────────────────
 A: Execution stops at the throw point immediately.
    No subsequent statements in the do block run.
    Control jumps directly to the matching catch clause.
    (Exception: `defer` blocks in the scope run before exit.)

    do {
        try failingOperation()  // throws here
        print("This never runs")
    } catch {
        print("Caught: \(error)")
    }


 ─────────────────────────────────────────────
 Q42 [MEDIUM]
 How does do-catch interact with defer inside the same scope?
 ─────────────────────────────────────────────
 A: defer always runs at scope exit — regardless of whether
    the scope exits via return, throw, or normal completion.
    Even when a throw causes the do block to exit, any defer
    blocks registered before the throw point will execute
    before control reaches the catch clause.


 ─────────────────────────────────────────────
 Q43 [MEDIUM]
 Can a catch clause itself throw?
 ─────────────────────────────────────────────
 A: Yes — a catch clause can throw, but only if the enclosing
    function is marked `throws`. The thrown error propagates
    up to the caller:

    func handle() throws {
        do { try operation() }
        catch let e as LowLevelError {
            throw HighLevelError.wrapped(e)   // re-throw upward
        }
    }


 ─────────────────────────────────────────────
 Q44 [MEDIUM]
 Can you use try inside an if condition directly?
 ─────────────────────────────────────────────
 A: Not directly. `try` in a condition must be wrapped:

    if let result = try? fetchUser(id: 5) { ... }  // valid

    // This is NOT valid:
    // if try fetchUser(id: 5) == "Admin" { ... }  // compile error

    For conditional logic with throws, use do-catch or try?


 ─────────────────────────────────────────────
 Q45 [HARD]
 How do you test throwing functions in XCTest?
 ─────────────────────────────────────────────
 A: Several approaches:

    // Assert no error is thrown:
    XCTAssertNoThrow(try fetchUser(id: 5))

    // Assert a specific error is thrown:
    XCTAssertThrowsError(try fetchUser(id: -1)) { error in
        XCTAssertEqual(error as? ValidationError,
                       ValidationError(field: "id", message: "..."))
    }

    // Test in async context:
    func testAsync() async throws {
        let user = try await fetchRemoteUser(id: 5)
        XCTAssertFalse(user.isEmpty)
    }


 ─────────────────────────────────────────────
 Q46 [HARD]
 What are the performance implications of using do-catch
 in a hot path (e.g., parsing 100,000 records)?
 ─────────────────────────────────────────────
 A: Swift error handling has near-zero overhead on the
    HAPPY PATH (no error thrown) — just a hidden register
    check on return. The ERROR PATH is more expensive:
    heap allocation for the error object, branch misprediction.

    In hot loops where most calls succeed:
    - do-catch is fine — success path is cheap.
    In hot loops where errors are frequent (e.g., validation):
    - Prefer Result<T,E> to avoid heap-allocated errors.
    - Or use Optional returns (nil = failure) for max speed.
    - Typed throws (Swift 6) can reduce error boxing overhead.


 ─────────────────────────────────────────────
 Q47 [HARD]
 How do you implement retry logic with do-catch?
 ─────────────────────────────────────────────
 A:
    func withRetry<T>(attempts: Int,
                      operation: () throws -> T) throws -> T {
        var lastError: Error?
        for attempt in 1...attempts {
            do {
                return try operation()
            } catch {
                lastError = error
                print("Attempt \(attempt) failed: \(error)")
                if attempt < attempts {
                    Thread.sleep(forTimeInterval: Double(attempt) * 0.5)
                }
            }
        }
        throw lastError!
    }

    // Usage:
    let result = try withRetry(attempts: 3) {
        try fetchUser(id: 5)
    }


 ─────────────────────────────────────────────
 Q48 [HARD]
 Can you catch errors inside a SwiftUI View body?
 ─────────────────────────────────────────────
 A: No — View body is a computed property returning `some View`
    and cannot be marked `throws`. You handle errors in:
    - .task { do { try await load() } catch { handleError(error) } }
    - .onAppear with a Task { }
    - ViewModel/ObservableObject methods that update @State
    - .alert modifier bound to an error state property

    Pattern:
    @State private var errorMessage: String?

    .task {
        do { data = try await fetch() }
        catch { errorMessage = error.localizedDescription }
    }
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") { errorMessage = nil }
    } message: { Text(errorMessage ?? "") }


 ─────────────────────────────────────────────
 Q49 [EXPERT]
 How do you implement structured error handling across
 multiple concurrent tasks?
 ─────────────────────────────────────────────
 A: Use TaskGroup or async let — errors from child tasks
    propagate to the parent automatically:

    func fetchAll(ids: [Int]) async throws -> [String] {
        try await withThrowingTaskGroup(of: String.self) { group in
            for id in ids {
                group.addTask { try await fetchRemoteUser(id: id) }
            }

            var results: [String] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    // First child task error cancels the group and rethrows.

    For collecting ALL errors (not just the first):
    var errors: [Error] = []
    for id in ids {
        group.addTask { ... }
    }
    for try await result in group.map({ ... }) { ... }


 ─────────────────────────────────────────────
 Q50 [EXPERT]
 What is the "error tunnel" anti-pattern and how do you
 avoid it?
 ─────────────────────────────────────────────
 A: The error tunnel is when every function in a chain is
    marked `throws` just to pass errors through, adding
    noise without adding handling logic:

    // Anti-pattern — no value added at each level
    func a() throws { try b() }
    func b() throws { try c() }
    func c() throws { try d() }

    Each `throws` is justified only if the function can
    meaningfully intercept, transform, or supplement the error.

    Solutions:
    1. Flatten the chain — handle at the appropriate layer only.
    2. Use Result<T,E> at async boundaries to carry errors
       without requiring throws through the whole chain.
    3. In Swift 6, typed throws makes tunneling explicit and
       type-safe, so at least it documents the error type.
 */


 // ============================================================
 // SECTION 3: TRY? (Q51–Q68)
 // ============================================================

 /*
 ─────────────────────────────────────────────
 Q51 [BASIC]
 What does try? do to a throwing expression?
 ─────────────────────────────────────────────
 A: Converts the result into an Optional. Returns Optional(value)
    on success, nil on failure. The error is discarded silently.


 ─────────────────────────────────────────────
 Q52 [BASIC]
 What is the return type of `try? someFunc()` where
 someFunc() returns Int?
 ─────────────────────────────────────────────
 A: Optional<Int> — i.e., Int?.
    Success → Optional(intValue)
    Failure → nil


 ─────────────────────────────────────────────
 Q53 [BASIC]
 When should you prefer try? over do-catch?
 ─────────────────────────────────────────────
 A: When failure is acceptable and expected, you have a
    meaningful fallback, and you don't need to know WHY
    it failed:
    - Optional cache lookup
    - Parsing optional config values
    - Non-critical feature setup that can gracefully degrade


 ─────────────────────────────────────────────
 Q54 [BASIC]
 How do you use try? with if let?
 ─────────────────────────────────────────────
 A:
    if let user = try? fetchUser(id: id) {
        display(user)
    } else {
        showPlaceholder()
    }


 ─────────────────────────────────────────────
 Q55 [BASIC]
 How do you use try? with guard let?
 ─────────────────────────────────────────────
 A:
    func loadUser(id: Int) -> String {
        guard let user = try? fetchUser(id: id) else {
            return "Guest"
        }
        return user
    }


 ─────────────────────────────────────────────
 Q56 [BASIC]
 Can you chain optional methods on a try? result?
 ─────────────────────────────────────────────
 A: Yes — using optional chaining:

    let length = (try? fetchUser(id: 5))?.count
    // Optional(Int) or nil


 ─────────────────────────────────────────────
 Q57 [BASIC]
 Can try? be used with async functions?
 ─────────────────────────────────────────────
 A: Yes:

    let user = try? await fetchRemoteUser(id: 5)
    // Optional<String>

    The await still suspends; errors are converted to nil.


 ─────────────────────────────────────────────
 Q58 [MEDIUM]
 What is the double Optional problem with try? and how
 does Swift handle it?
 ─────────────────────────────────────────────
 A: If the throwing function returns T?, then try? wrapping
    it would naively produce T?? (Optional<Optional<T>>).
    Swift 5+ (SE-0230) automatically flattens this to T?:

    func find(id: Int) throws -> String? { ... }
    let result = try? find(id: 1)   // String? not String??

    This was a bug in Swift 4 — functions returning Optional
    combined with try? produced Double Optionals unexpectedly.


 ─────────────────────────────────────────────
 Q59 [MEDIUM]
 How does try? compare to using Result?
 ─────────────────────────────────────────────
 A: try? → Optional<T>: loses error info entirely.
    Result<T, E>: preserves both success value AND error type.

    Use try? when you truly don't need the error.
    Use Result when you might need to inspect or log failure:

    let result: Result<String, Error> = Result { try fetchUser(id: 5) }
    switch result {
    case .success(let u): print(u)
    case .failure(let e): log(e)      // error preserved
    }


 ─────────────────────────────────────────────
 Q60 [MEDIUM]
 Can try? cause memory leaks?
 ─────────────────────────────────────────────
 A: Not directly, but silently failing operations can mask
    resource leaks. If a function that acquires a resource
    fails partway through, try? hides the failure — you may
    not release resources properly if cleanup depends on
    knowing what failed. Always pair try? with resources
    that have guaranteed cleanup (defer, RAII patterns).


 ─────────────────────────────────────────────
 Q61 [MEDIUM]
 How do you use try? with nil coalescing for defaults?
 ─────────────────────────────────────────────
 A:
    let config = try? loadConfig() ?? defaultConfig()
    // Note: ?? has lower precedence, parentheses help clarity:
    let config = (try? loadConfig()) ?? defaultConfig()


 ─────────────────────────────────────────────
 Q62 [MEDIUM]
 What is the difference between these two:
    let a = try? optionalReturning()
    let b: String? = try? optionalReturning()
 Where optionalReturning() -> String? throws
 ─────────────────────────────────────────────
 A: Both produce String? due to Swift's SE-0230 flattening.
    They are equivalent — the explicit type annotation on `b`
    doesn't change the flattening behavior. This is often a
    gotcha question; the answer is: no difference in Swift 5+.


 ─────────────────────────────────────────────
 Q63 [HARD]
 How does try? interact with CancellationError in
 Swift concurrency?
 ─────────────────────────────────────────────
 A: This is a critical gotcha. try? swallows ALL errors —
    including CancellationError. Since cancellation is a
    cooperative mechanism in Swift concurrency, silencing it
    means your task may continue running after cancellation:

    // DANGEROUS — cancellation silently swallowed:
    let result = try? await fetchRemoteUser(id: 5)

    // SAFER — check for cancellation explicitly:
    do {
        let result = try await fetchRemoteUser(id: 5)
    } catch is CancellationError {
        return   // respect cancellation
    } catch {
        // handle other errors
    }

    Or use Task.checkCancellation() before and after operations.


 ─────────────────────────────────────────────
 Q64 [HARD]
 Can you write a logging wrapper that uses try? semantics
 but preserves error information?
 ─────────────────────────────────────────────
 A: Yes — a common production pattern:

    func silently<T>(_ operation: () throws -> T,
                     file: String = #file,
                     line: Int = #line) -> T? {
        do {
            return try operation()
        } catch {
            // Log in debug builds, silent in release
            #if DEBUG
            print("[Warning] Silenced error at \(file):\(line) — \(error)")
            #endif
            return nil
        }
    }

    let user = silently { try fetchUser(id: id) }


 ─────────────────────────────────────────────
 Q65 [HARD]
 How does try? affect the retain count of objects
 involved in the throwing call?
 ─────────────────────────────────────────────
 A: On the success path — no difference to normal returns.
    On the error path — any partially constructed objects
    inside the throwing function are released normally
    (ARC handles it). The thrown error itself is heap-allocated
    temporarily then released since try? discards it.
    No special retain issues exist, but be aware that large
    error objects with strong references to other objects
    will be allocated then immediately released — potentially
    affecting heap pressure in tight error-prone loops.


 ─────────────────────────────────────────────
 Q66 [HARD]
 Is try? evaluated lazily?
 ─────────────────────────────────────────────
 A: No. `try? expression` eagerly evaluates the expression.
    It's not lazy like Optional chaining on a nil object
    (which short-circuits). The function is called; if it
    throws, the error is discarded and nil returned. If you
    need lazy evaluation, wrap in a closure:

    let lazyResult: () -> String? = { try? fetchUser(id: 5) }
    // Evaluated only when lazyResult() is called


 ─────────────────────────────────────────────
 Q67 [EXPERT]
 How would you implement a try? equivalent that
 returns Result instead of Optional?
 ─────────────────────────────────────────────
 A:
    // Using Result's throwing initializer:
    let result = Result { try fetchUser(id: 5) }
    // Result<String, Error>

    // Generic helper for cleaner syntax:
    func catching<T>(_ operation: () throws -> T) -> Result<T, Error> {
        return Result(catching: operation)
    }

    let r = catching { try fetchUser(id: 5) }
    switch r {
    case .success(let u): print(u)
    case .failure(let e): print(e)
    }


 ─────────────────────────────────────────────
 Q68 [EXPERT]
 How does try? behave when used inside a property
 observer (willSet/didSet)?
 ─────────────────────────────────────────────
 A: Property observers (willSet/didSet) cannot throw.
    However, you CAN use try? inside them since try? never
    propagates an error — it returns Optional silently:

    var userID: Int = 0 {
        didSet {
            let _ = try? validateAndSave(userID)   // valid
            // try validateAndSave(userID)          // ERROR — can't throw here
        }
    }
 */


 // ============================================================
 // SECTION 4: TRY! (Q69–Q82)
 // ============================================================

 /*
 ─────────────────────────────────────────────
 Q69 [BASIC]
 What does try! do?
 ─────────────────────────────────────────────
 A: Asserts at runtime that no error will be thrown.
    Returns an unwrapped non-Optional value on success.
    Crashes with a fatal error if the expression throws.


 ─────────────────────────────────────────────
 Q70 [BASIC]
 What is the return type of `try! someFunc()` where
 someFunc() returns String?
 ─────────────────────────────────────────────
 A: String — not Optional. The ! removes the Optional wrapper.
    This is analogous to force-unwrapping an Optional.


 ─────────────────────────────────────────────
 Q71 [BASIC]
 What error message appears when try! crashes?
 ─────────────────────────────────────────────
 A: A fatal error like:
    "Fatal error: 'try!' expression unexpectedly raised an error:
    [ErrorType]: [description]"
    This terminates the process — no recovery is possible.


 ─────────────────────────────────────────────
 Q72 [BASIC]
 Name two legitimate use cases for try!
 ─────────────────────────────────────────────
 A: 1. Compiling a hardcoded regex pattern known to be valid:
       let regex = try! NSRegularExpression(pattern: "^\\d{4}$")

    2. Decoding a JSON file bundled with the app that
       is guaranteed to be well-formed:
       let data = try! JSONDecoder().decode(Config.self, from: bundledData)


 ─────────────────────────────────────────────
 Q73 [BASIC]
 How is try! analogous to force-unwrap (!)?
 ─────────────────────────────────────────────
 A: Both say "I guarantee this will succeed — crash if wrong."
    Force-unwrap crashes on nil Optional.
    try! crashes on a thrown error.
    The same caution applies: use only when invariant is
    provable, not just assumed.


 ─────────────────────────────────────────────
 Q74 [MEDIUM]
 Can try! be used with async functions?
 ─────────────────────────────────────────────
 A: Yes:
    let user = try! await fetchRemoteUser(id: 5)
    But this is almost always a bad idea for async operations
    because network/IO failures are a real possibility —
    not programmer-contract violations. Avoid try! with async.


 ─────────────────────────────────────────────
 Q75 [MEDIUM]
 How do you detect improper try! usage in a codebase?
 ─────────────────────────────────────────────
 A: Several approaches:
    1. SwiftLint rule `force_try` — flags all try! usage
       as a warning or error.
    2. Code review policy requiring justification comments
       above any try! usage.
    3. Compiler flag `-warn-unhandled-errors` (Swift 6 mode)
       provides tighter checking.


 ─────────────────────────────────────────────
 Q76 [MEDIUM]
 Is it safe to use try! in unit tests?
 ─────────────────────────────────────────────
 A: Yes — in test setup/helpers where a crash means the
    test infrastructure is misconfigured (not the production
    code). For actual test assertions, prefer:
    XCTAssertNoThrow(try operation())
    — which gives a cleaner failure message rather than crashing.


 ─────────────────────────────────────────────
 Q77 [MEDIUM]
 What is the difference between try! and force-unwrap
 after try??
 ─────────────────────────────────────────────
 A: Functionally identical in behavior — both crash on failure.
    Stylistically different:
    `try! f()`    — clear intent: f() must not throw.
    `(try? f())!` — needlessly roundabout: converts to Optional
                    then force-unwraps. Avoid this pattern;
                    prefer try! directly for clarity.


 ─────────────────────────────────────────────
 Q78 [HARD]
 How do you make try! safe in debug builds while
 falling back gracefully in release builds?
 ─────────────────────────────────────────────
 A: Replace try! with a custom helper using assertionFailure
    (crashes Debug, no-ops Release):

    func forceTry<T>(_ fn: () throws -> T,
                     fallback: @autoclosure () -> T,
                     file: StaticString = #file,
                     line: UInt = #line) -> T {
        do { return try fn() }
        catch {
            assertionFailure("Unexpected error: \(error)",
                             file: file, line: line)
            return fallback()
        }
    }

    let regex = forceTry({ try NSRegularExpression(pattern: "...") },
                          fallback: NSRegularExpression())


 ─────────────────────────────────────────────
 Q79 [HARD]
 Does try! have overhead compared to a non-throwing call?
 ─────────────────────────────────────────────
 A: Yes, marginally. The compiler emits a branch to check
    the hidden error return value and trap if set. In practice
    this is negligible. In extremely performance-critical code
    (hot inner loops), prefer non-throwing APIs or refactor
    to remove throws from the call site entirely.


 ─────────────────────────────────────────────
 Q80 [HARD]
 Can try! be used in a lazy property initializer?
 ─────────────────────────────────────────────
 A: Yes — lazy properties can use try! since the lazy
    closure isn't marked throws:

    class DataManager {
        lazy var config: Config = try! loadConfig()
    }

    This crashes on first access if loadConfig throws.
    A safer pattern: load in init and handle gracefully there,
    or use a Result<Config, Error> stored property.


 ─────────────────────────────────────────────
 Q81 [HARD]
 What happens to objects created before a try! crash?
 ─────────────────────────────────────────────
 A: ARC does NOT guarantee deallocation on a fatalError crash.
    The process terminates abruptly — deinit may not be called,
    file handles may not be flushed, database connections not
    closed. This is why try! is inappropriate for operations
    with real-world side effects (file writes, DB transactions,
    network requests).


 ─────────────────────────────────────────────
 Q82 [EXPERT]
 Can try! be used inside a property wrapper?
 ─────────────────────────────────────────────
 A: Yes — the wrappedValue getter/setter can't throw,
    but you can use try! inside them:

    @propertyWrapper
    struct JSONDecoded<T: Codable> {
        var wrappedValue: T

        init(jsonString: String) {
            let data = jsonString.data(using: .utf8)!
            self.wrappedValue = try! JSONDecoder()
                .decode(T.self, from: data)
        }
    }

    This is acceptable if jsonString is a compile-time
    constant. At runtime with user input, it's dangerous.
 */


 // ============================================================
 // SECTION 5: DEFER (Q83–Q110)
 // ============================================================

 /*
 ─────────────────────────────────────────────
 Q83 [BASIC]
 What is the purpose of defer in Swift?
 ─────────────────────────────────────────────
 A: `defer` schedules a block to execute when the current
    scope exits — regardless of how (return, throw, break,
    or natural end). It guarantees cleanup always happens.


 ─────────────────────────────────────────────
 Q84 [BASIC]
 In what order do multiple defer blocks execute?
 ─────────────────────────────────────────────
 A: LIFO (Last In, First Out) — the last defer registered
    runs first. This mirrors the natural undo order:
    open A → open B → close B → close A.


 ─────────────────────────────────────────────
 Q85 [BASIC]
 Can defer be used outside of error handling contexts?
 ─────────────────────────────────────────────
 A: Yes. defer works in any scope regardless of whether
    errors are involved. It's commonly used for:
    - Lock/unlock pairs
    - Start/stop spinners
    - Begin/commit transactions
    - Incrementing/decrementing counters


 ─────────────────────────────────────────────
 Q86 [BASIC]
 Does defer run if a function returns early with return?
 ─────────────────────────────────────────────
 A: Yes — defer runs on ANY scope exit including early return.
    This is the whole point: you write cleanup once and it
    runs no matter how the scope exits.


 ─────────────────────────────────────────────
 Q87 [BASIC]
 Can defer change the return value of a function?
 ─────────────────────────────────────────────
 A: No. The return value is captured BEFORE defer runs.
    defer executes after the value is captured but before
    the function actually returns. It cannot modify
    what gets returned.

    func getValue() -> Int {
        defer { print("deferred") }
        return 42   // 42 captured first, then defer runs
    }


 ─────────────────────────────────────────────
 Q88 [BASIC]
 Can you have a return statement inside a defer block?
 ─────────────────────────────────────────────
 A: No — defer blocks cannot contain control flow that
    would exit the block's enclosing scope: no return,
    no break, no throw. Only code that stays within the
    defer block itself is allowed.


 ─────────────────────────────────────────────
 Q89 [BASIC]
 Is defer only available in functions?
 ─────────────────────────────────────────────
 A: No — defer works in any scope: functions, closures,
    for loops, while loops, if blocks. It defers to the
    exit of the NEAREST enclosing scope, not necessarily
    the function.


 ─────────────────────────────────────────────
 Q90 [MEDIUM]
 What value does defer see for a variable modified
 after defer is registered?
 ─────────────────────────────────────────────
 A: The FINAL value at scope exit — not the value at
    registration time. defer captures the binding, not
    a snapshot.

    var x = 0
    defer { print(x) }   // will print 42, not 0
    x = 42


 ─────────────────────────────────────────────
 Q91 [MEDIUM]
 How do you capture the value at defer registration time,
 not the final value?
 ─────────────────────────────────────────────
 A: Copy into a local constant inside the defer block:

    var x = 0
    let snapshot = x
    defer { print(snapshot) }   // always prints 0
    x = 42


 ─────────────────────────────────────────────
 Q92 [MEDIUM]
 Can defer throw errors?
 ─────────────────────────────────────────────
 A: No — defer blocks cannot propagate thrown errors.
    You must handle errors internally using try? or
    do-catch inside the defer block:

    defer {
        try? cleanup()          // silent failure — OK
        do {
            try riskyCleanup()
        } catch {
            log(error)         // handle internally
        }
    }


 ─────────────────────────────────────────────
 Q93 [MEDIUM]
 Does defer run inside a guard statement?
 ─────────────────────────────────────────────
 A: defer registered before a guard runs when the FUNCTION
    scope exits. defer registered inside a guard's else block
    — which is not allowed because guard's else must exit.
    Typically: register defer after guard validations pass,
    to ensure cleanup happens after resources are acquired.


 ─────────────────────────────────────────────
 Q94 [MEDIUM]
 What is the relationship between defer and RAII
 (Resource Acquisition Is Initialization)?
 ─────────────────────────────────────────────
 A: defer achieves RAII-like patterns in Swift.
    RAII (C++) ties resource lifetime to object lifetime —
    destructors auto-release. defer achieves scope-bound
    cleanup without requiring a wrapper object:

    // C++ RAII: destructor releases lock
    // Swift defer equivalent:
    lock.lock()
    defer { lock.unlock() }


 ─────────────────────────────────────────────
 Q95 [MEDIUM]
 Does defer execute in a loop on each iteration?
 ─────────────────────────────────────────────
 A: Yes — if defer is inside a loop body, it registers and
    executes on each loop iteration's scope exit:

    for i in 0..<3 {
        defer { print("end of iteration \(i)") }
        print("start of iteration \(i)")
    }
    // start 0 → end 0 → start 1 → end 1 → start 2 → end 2


 ─────────────────────────────────────────────
 Q96 [MEDIUM]
 Can you use defer inside a switch case?
 ─────────────────────────────────────────────
 A: Yes — defer inside a case runs when that case's scope exits:

    switch state {
    case .loading:
        defer { spinner.stop() }
        spinner.start()
        load()
    default:
        break
    }


 ─────────────────────────────────────────────
 Q97 [HARD]
 How does defer interact with inout parameters?
 ─────────────────────────────────────────────
 A: defer executes before inout write-back. Changes made
    to an inout parameter inside defer ARE reflected in
    the caller's variable:

    func normalize(_ value: inout Double) {
        defer {
            if value < 0 { value = 0 }   // written back to caller
        }
        value -= 10.0   // may go negative — defer corrects it
    }

    var v = 5.0
    normalize(&v)
    print(v)   // 0.0 — defer correction written back


 ─────────────────────────────────────────────
 Q98 [HARD]
 How does defer behave with escaping closures?
 ─────────────────────────────────────────────
 A: defer respects the SCOPE it's in — not when the closure
    executes. If you register a defer and then create an
    escaping closure, the defer runs when the CURRENT scope
    exits — the closure may run later, after defer has
    already executed.

    func setup(completion: @escaping () -> Void) {
        defer { print("setup scope exited") }
        DispatchQueue.main.async {
            completion()   // runs AFTER defer
        }
    }
    // "setup scope exited" prints before completion runs


 ─────────────────────────────────────────────

  
 
*/*/
