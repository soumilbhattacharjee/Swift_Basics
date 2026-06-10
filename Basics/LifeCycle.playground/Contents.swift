import UIKit

/*
 
 =======================================================================
   SWIFT — APP LIFECYCLE & VIEW LIFECYCLE
   UIKit + SwiftUI | Complete Study Notes + 100 Interview Q&A
 =======================================================================

 TABLE OF CONTENTS
 -----------------
 PART 1: UIKIT APP LIFECYCLE
   A. App States
   B. AppDelegate Methods
   C. SceneDelegate & Multi-Window Support
   D. Scene Life Cycle States
   E. AppDelegate vs SceneDelegate Responsibilities
   F. Background Execution
   G. State Restoration

 PART 2: UIKIT VIEW LIFECYCLE
   A. UIViewController Lifecycle — Full Flow
   B. Each Method — Detailed Explanation + Code
   C. UIView vs UIViewController Lifecycle
   D. Container View Controllers
   E. Modal Presentation Lifecycle
   F. Navigation Stack Lifecycle
   G. Rotation & Size Changes

 PART 3: SWIFTUI APP LIFECYCLE
   A. @main & App Protocol
   B. Scene Types
   C. ScenePhase
   D. Environment-Driven Lifecycle
   E. onAppear / onDisappear

 PART 4: SWIFTUI VIEW LIFECYCLE
   A. View Protocol & Body
   B. View Identity (Structural vs Explicit)
   C. State & Lifecycle
   D. onAppear / onDisappear vs UIKit equivalents
   E. task() modifier
   F. View Updates & Rendering Pipeline
   G. Lifetime of @State, @StateObject, @ObservedObject

 PART 5: UIKIT vs SWIFTUI COMPARISON

 PART 6: 100 INTERVIEW Q&A
   - Basic      (Q1–Q30)
   - Intermediate (Q31–Q70)
   - Hard/Advanced (Q71–Q100)

 =======================================================================
 PART 1: UIKIT APP LIFECYCLE
 =======================================================================

 -----------------------------------------------------------------------
 A. APP STATES (iOS Application States)
 -----------------------------------------------------------------------
 An iOS app can be in one of FIVE states at any time:

 1. NOT RUNNING
    - App has not been launched, OR
    - Was terminated by the system or user.
    - No code is executing.

 2. INACTIVE
    - App is in the FOREGROUND but NOT receiving events.
    - Transition state — brief.
    - Examples: incoming phone call, showing app switcher,
      Control Center/Notification Center pulled down.

 3. ACTIVE
    - App is in the FOREGROUND and receiving events.
    - Normal operational state. UI is fully interactive.

 4. BACKGROUND
    - App is NOT in the foreground but code is still executing.
    - Happens briefly when moving to background.
    - Extended background time requires specific capabilities
      (audio, location, fetch, push notifications, etc.).

 5. SUSPENDED
    - App is in the background but NO code is executing.
    - App remains in memory (fast re-launch possible).
    - System may terminate suspended apps under memory pressure
      WITHOUT notifying the app.

 STATE TRANSITION DIAGRAM:
   Not Running ──launch──► Inactive ──► Active
                                 ▲         │
                                 │         ▼
                            Background ◄── Inactive
                                 │
                                 ▼
                            Suspended
                                 │
                                 ▼
                            Not Running (system terminates)

 -----------------------------------------------------------------------
 B. APPDELEGATE METHODS
 -----------------------------------------------------------------------
 AppDelegate is the entry point for pre-iOS 13 apps.
 In iOS 13+, scene-based lifecycle is preferred,
 but AppDelegate still handles app-level events.

 // AppDelegate.swift
 @main  // iOS 13 uses this OR Info.plist entry
 class AppDelegate: UIResponder, UIApplicationDelegate {

     // ── LAUNCH ──────────────────────────────────────────────────────

     func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
         // Called when app finishes launching.
         // Set up app-wide state, third-party SDKs, root VC.
         // launchOptions: why the app was launched (push, URL, etc.)
         return true
     }

     // ── FOREGROUND / BACKGROUND ──────────────────────────────────────

     func applicationWillResignActive(_ application: UIApplication) {
         // About to leave ACTIVE state.
         // Pause timers, animations, ongoing tasks.
         // App becomes INACTIVE next.
     }

     func applicationDidEnterBackground(_ application: UIApplication) {
         // Now in BACKGROUND state.
         // Save data, release shared resources.
         // About 5 seconds to complete (request more time if needed).
         // App may be suspended after this.
     }

     func applicationWillEnterForeground(_ application: UIApplication) {
         // About to enter FOREGROUND (before becoming active).
         // Undo background changes, refresh UI.
     }

     func applicationDidBecomeActive(_ application: UIApplication) {
         // App is now ACTIVE and receiving events.
         // Restart paused tasks, refresh UI.
     }

     // ── TERMINATION ──────────────────────────────────────────────────

     func applicationWillTerminate(_ application: UIApplication) {
         // Called when app is about to terminate.
         // NOTE: NOT called if app is suspended when terminated.
         // Save data here as a fallback.
         // ~5 seconds to complete.
     }

     // ── MEMORY ───────────────────────────────────────────────────────

     func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
         // System is low on memory.
         // Free up as much memory as possible here.
     }

     // ── BACKGROUND FETCH ─────────────────────────────────────────────

     func application(
         _ application: UIApplication,
         performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
     ) {
         // Called for background app refresh.
         // Fetch new data, update UI off-screen.
         // Call completionHandler ASAP (< 30 seconds).
         completionHandler(.newData)
     }

     // ── PUSH NOTIFICATIONS ───────────────────────────────────────────

     func application(
         _ application: UIApplication,
         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
     ) {
         // Successfully registered for remote notifications.
     }

     func application(
         _ application: UIApplication,
         didFailToRegisterForRemoteNotificationsWithError error: Error
     ) {
         // Registration for remote notifications failed.
     }

     // ── URL HANDLING ─────────────────────────────────────────────────

     func application(
         _ application: UIApplication,
         open url: URL,
         options: [UIApplication.OpenURLOptionsKey: Any] = [:]
     ) -> Bool {
         // Handle deep links / custom URL schemes.
         return true
     }

     // ── SCENE CONFIGURATION (iOS 13+) ───────────────────────────────

     func application(
         _ application: UIApplication,
         configurationForConnecting connectingSceneSession: UISceneSession,
         options: UIScene.ConnectionOptions
     ) -> UISceneConfiguration {
         // Return configuration for new scene.
         return UISceneConfiguration(name: "Default Configuration",
                                     sessionRole: connectingSceneSession.role)
     }

     func application(
         _ application: UIApplication,
         didDiscardSceneSessions sceneSessions: Set<UISceneSession>
     ) {
         // Called when user discards a scene (e.g., swipes away
         // from app switcher on iPad). Clean up scene-specific data.
     }
 }

 -----------------------------------------------------------------------
 C. SCENEDELEGATE & MULTI-WINDOW (iOS 13+)
 -----------------------------------------------------------------------
 Starting iOS 13, Apple introduced the SCENE-BASED lifecycle.
 Each "scene" represents a UI instance (window) of the app.
 On iPhone: typically one scene.
 On iPad: multiple scenes (multi-window support).

 WHY SCENEDELEGATE:
 - Separates UI lifecycle from app lifecycle
 - Supports multiple windows (iPad multitasking)
 - Better state restoration per scene
 - Each scene has its own session and state

 // SceneDelegate.swift
 class SceneDelegate: UIResponder, UIWindowSceneDelegate {

     var window: UIWindow?

     // ── SCENE CONNECTED (first creation) ─────────────────────────────

     func scene(
         _ scene: UIScene,
         willConnectTo session: UISceneSession,
         options connectionOptions: UIScene.ConnectionOptions
     ) {
         // Scene is being created and connected.
         // Set up root view controller and window.
         guard let windowScene = scene as? UIWindowScene else { return }
         let window = UIWindow(windowScene: windowScene)
         window.rootViewController = ViewController()
         self.window = window
         window.makeKeyAndVisible()

         // Handle URL if app was opened via URL
         if let url = connectionOptions.urlContexts.first?.url {
             handleDeepLink(url)
         }
     }

     // ── SCENE DISCONNECTED ───────────────────────────────────────────

     func sceneDidDisconnect(_ scene: UIScene) {
         // Scene was disconnected from app (NOT necessarily discarded).
         // Could be reconnected later.
         // Release resources tied to this scene.
     }

     // ── SCENE BECAME ACTIVE ──────────────────────────────────────────

     func sceneDidBecomeActive(_ scene: UIScene) {
         // Scene moved to ACTIVE state.
         // Restart paused tasks, refresh data.
     }

     // ── SCENE WILL RESIGN ACTIVE ─────────────────────────────────────

     func sceneWillResignActive(_ scene: UIScene) {
         // Scene about to become INACTIVE.
         // Pause tasks, save in-progress work.
     }

     // ── SCENE WILL ENTER FOREGROUND ──────────────────────────────────

     func sceneWillEnterForeground(_ scene: UIScene) {
         // Scene about to enter FOREGROUND.
         // Undo background preparation, refresh UI.
     }

     // ── SCENE DID ENTER BACKGROUND ───────────────────────────────────

     func sceneDidEnterBackground(_ scene: UIScene) {
         // Scene is now in BACKGROUND.
         // Save data, release shared resources.
         // Reduce memory footprint.
         (UIApplication.shared.delegate as? AppDelegate)?
             .saveContext()
     }

     // ── STATE RESTORATION ────────────────────────────────────────────

     func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
         // Return activity representing current scene state.
         // Used to restore scene on next launch.
         return scene.userActivity
     }

     func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
         // Restore scene to previously saved state.
     }

     // ── URL HANDLING ─────────────────────────────────────────────────

     func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
         guard let url = URLContexts.first?.url else { return }
         handleDeepLink(url)
     }
 }

 -----------------------------------------------------------------------
 D. SCENE LIFECYCLE STATES
 -----------------------------------------------------------------------

 Scene states mirror app states but are per-scene:

   UNATTACHED → FOREGROUND INACTIVE → FOREGROUND ACTIVE
                          ↑                    ↓
                  BACKGROUND SUSPENDED ← FOREGROUND INACTIVE

 Method call sequence for app launch:
   1. application(_:didFinishLaunchingWithOptions:)  [AppDelegate]
   2. application(_:configurationForConnecting:)     [AppDelegate]
   3. scene(_:willConnectTo:options:)                [SceneDelegate]
   4. sceneWillEnterForeground(_:)                   [SceneDelegate]
   5. sceneDidBecomeActive(_:)                       [SceneDelegate]

 Method call sequence for backgrounding:
   1. sceneWillResignActive(_:)
   2. sceneDidEnterBackground(_:)

 Method call sequence for foregrounding:
   1. sceneWillEnterForeground(_:)
   2. sceneDidBecomeActive(_:)

 -----------------------------------------------------------------------
 E. APPDELEGATE vs SCENEDELEGATE RESPONSIBILITIES
 -----------------------------------------------------------------------

 AppDelegate handles:
   ✓ One-time app setup (SDKs, services)
   ✓ Push notification registration/handling
   ✓ App-level URL handling (before scenes)
   ✓ CloudKit and background refresh configuration
   ✓ Scene session creation/destruction
   ✓ Shared global state

 SceneDelegate handles:
   ✓ Window/root VC creation per scene
   ✓ Scene-level foreground/background transitions
   ✓ Scene-specific state restoration
   ✓ Scene-specific URL/deep link handling
   ✓ UI state saving/restoring per window

 -----------------------------------------------------------------------
 F. BACKGROUND EXECUTION
 -----------------------------------------------------------------------

 iOS gives about 5-10 seconds in background by default.
 For more time, use Background Tasks framework.

 1. BACKGROUND TASK (short extension):
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func applicationDidEnterBackground(_ application: UIApplication) {
        backgroundTask = application.beginBackgroundTask {
            // Called when time is about to expire
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        DispatchQueue.global().async {
            // Do work here
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }

 2. BGAPPREFRESHTASK (iOS 13+):
    import BackgroundTasks

    // Register in AppDelegate:
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.app.refresh",
        using: nil
    ) { task in
        self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }

    // Schedule:
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.app.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

 -----------------------------------------------------------------------
 G. STATE RESTORATION
 -----------------------------------------------------------------------

 iOS 13+: Use NSUserActivity-based restoration per scene.

 // Save state:
 func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
     let activity = NSUserActivity(activityType: "com.app.state")
     activity.userInfo = ["currentScreen": "profile", "userId": "123"]
     return activity
 }

 // Restore state:
 func scene(
     _ scene: UIScene,
     restoreInteractionStateWith activity: NSUserActivity
 ) {
     if let screen = activity.userInfo?["currentScreen"] as? String {
         navigateTo(screen)
     }
 }

 =======================================================================
 PART 2: UIKIT VIEW LIFECYCLE
 =======================================================================

 -----------------------------------------------------------------------
 A. UIVIEWCONTROLLER LIFECYCLE — FULL FLOW
 -----------------------------------------------------------------------

 COMPLETE SEQUENCE (first appearance):

   init(coder:) / init(nibName:bundle:)
          ↓
   loadView()
          ↓
   viewDidLoad()
          ↓
   viewWillAppear(_:)
          ↓
   viewWillLayoutSubviews()
          ↓
   viewDidLayoutSubviews()
          ↓
   viewDidAppear(_:)
          ↓
   [User interaction / screen is visible]
          ↓
   viewWillDisappear(_:)
          ↓
   viewWillLayoutSubviews()  [may occur]
          ↓
   viewDidLayoutSubviews()   [may occur]
          ↓
   viewDidDisappear(_:)
          ↓
   deinit  [when VC is deallocated]

 LAYOUT CALLS also happen on:
   - Rotation
   - Trait collection change
   - Manual call to setNeedsLayout() → layoutIfNeeded()

 -----------------------------------------------------------------------
 B. EACH METHOD — DETAILED EXPLANATION + CODE
 -----------------------------------------------------------------------

 --- 1. init(coder:) / init(nibName:bundle:) ---

   Called when the VC is instantiated from a storyboard,
   nib, or programmatically.
   Do NOT access self.view here — it hasn't been loaded.

   // Storyboard:
   required init?(coder: NSCoder) {
       // Decode and initialize non-view properties
       self.viewModel = MyViewModel()
       super.init(coder: coder)
   }

   // Programmatic:
   init(viewModel: MyViewModel) {
       self.viewModel = viewModel
       super.init(nibName: nil, bundle: nil)
   }

 --- 2. loadView() ---

   Called to create or load the view hierarchy.
   Default: loads from storyboard/nib, or creates a UIView.
   OVERRIDE ONLY for fully programmatic views.
   Do NOT call super when overriding.

   override func loadView() {
       // Create root view manually
       let rootView = UIView()
       rootView.backgroundColor = .white
       self.view = rootView   // MUST set self.view
   }

   IMPORTANT: Accessing self.view before loadView completes
   triggers loadView automatically. This is fine — it's by design.

 --- 3. viewDidLoad() ---

   Called ONCE after the view hierarchy is loaded into memory.
   Most common place for one-time setup.
   View exists, but NOT yet in the window hierarchy.
   Subviews have their initial sizes (not final sizes yet).

   override func viewDidLoad() {
       super.viewDidLoad()
       // ✓ Add subviews
       // ✓ Set up constraints
       // ✓ Configure UI elements
       // ✓ Register table view cells
       // ✓ Set up gesture recognizers
       // ✓ Bind view model
       // ✗ Do NOT assume final view sizes
       // ✗ Do NOT start animations

       view.addSubview(tableView)
       setupConstraints()
       viewModel.delegate = self
       tableView.register(MyCell.self,
                          forCellReuseIdentifier: "MyCell")
   }

 --- 4. viewWillAppear(_ animated: Bool) ---

   Called every time the view is about to be added to
   the screen (not just first time).
   View has its size from the window, but layout may not
   be finalized yet.

   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       // ✓ Show/hide navigation bar
       // ✓ Refresh data that may have changed
       // ✓ Register for notifications
       // ✓ Start background tasks for this screen

       navigationController?.setNavigationBarHidden(false,
                                                    animated: animated)
       NotificationCenter.default.addObserver(
           self,
           selector: #selector(handleDataChange),
           name: .dataDidChange,
           object: nil
       )
       refreshUI()
   }

 --- 5. viewWillLayoutSubviews() ---

   Called before the VC's view lays out its subviews.
   Called EVERY TIME layout occurs (rotation, size change, etc.).
   Bounds may not be final at the START of this call.

   override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
       // Prepare for layout — adjust before auto layout runs
   }

 --- 6. viewDidLayoutSubviews() ---

   Called AFTER the VC's view finishes laying out subviews.
   Final bounds are available here.
   Use for anything that depends on exact view dimensions
   (e.g., circular corner radius, gradient layers).

   override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
       // ✓ Set cornerRadius based on actual size
       // ✓ Update CALayer frames
       // ✓ Adjust gradient layer frames
       profileImageView.layer.cornerRadius =
           profileImageView.bounds.height / 2
       gradientLayer.frame = headerView.bounds
   }

 --- 7. viewDidAppear(_ animated: Bool) ---

   Called AFTER the view is fully visible on screen.
   Animation is complete.

   override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       // ✓ Start animations
       // ✓ Begin expensive operations (video, audio)
       // ✓ Track analytics / screen impressions
       // ✓ Show alerts or prompts
       // ✓ Start camera/microphone session

       analyticsService.trackScreen("Home")
       startAnimation()
       cameraSession.startRunning()
   }

 --- 8. viewWillDisappear(_ animated: Bool) ---

   Called when the view is about to be removed from screen.
   (Push navigation, modal dismissal, tab switch, etc.)

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       // ✓ Save user input
       // ✓ Cancel ongoing operations
       // ✓ Hide keyboard
       // ✓ Deregister time-sensitive observers

       view.endEditing(true)
       saveCurrentState()
   }

 --- 9. viewDidDisappear(_ animated: Bool) ---

   Called AFTER the view has been removed from screen.

   override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
       // ✓ Stop resource-intensive processes
       // ✓ Invalidate timers
       // ✓ Deregister notifications (if not in viewWillDisappear)
       // ✓ Stop camera/audio sessions

       timer?.invalidate()
       timer = nil
       cameraSession.stopRunning()
       NotificationCenter.default.removeObserver(self)
   }

 --- 10. deinit ---

   Called when the VC's reference count drops to zero.
   Final cleanup opportunity.

   deinit {
       // ✓ Remove any remaining KVO observers
       // ✓ Invalidate final resources
       // ✓ Debug prints in development
       NotificationCenter.default.removeObserver(self)
       print("ViewController deallocated")
   }

 --- 11. traitCollectionDidChange(_ previousTraitCollection:) ---

   Called when the VC's traits change (dark/light mode,
   accessibility, dynamic type size, rotation).

   override func traitCollectionDidChange(
       _ previousTraitCollection: UITraitCollection?
   ) {
       super.traitCollectionDidChange(previousTraitCollection)
       if traitCollection.hasDifferentColorAppearance(
           comparedTo: previousTraitCollection
       ) {
           updateColorsForCurrentAppearance()
       }
   }

 -----------------------------------------------------------------------
 C. UIVIEW LIFECYCLE (vs UIViewController)
 -----------------------------------------------------------------------

 UIView itself has these lifecycle-relevant methods:

   willMove(toSuperview:)
   didMoveToSuperview()
   willMove(toWindow:)
   didMoveToWindow()
   layoutSubviews()          ← equivalent of viewDidLayoutSubviews
   draw(_:)                  ← custom drawing
   removeFromSuperview()
   didMoveToSuperview()

 // Custom UIView example:
 class MyCustomView: UIView {

     override func didMoveToSuperview() {
         super.didMoveToSuperview()
         // View was added to a parent
         setupIfNeeded()
     }

     override func layoutSubviews() {
         super.layoutSubviews()
         // Final bounds available — update layer frames here
         gradientLayer.frame = bounds
         layer.cornerRadius = bounds.height / 2
     }

     override func draw(_ rect: CGRect) {
         // Custom drawing with Core Graphics
         let context = UIGraphicsGetCurrentContext()
         context?.setFillColor(UIColor.blue.cgColor)
         context?.fill(rect)
     }
 }

 KEY DIFFERENCE:
   UIViewController: viewDidLayoutSubviews  ← after auto layout
   UIView:           layoutSubviews         ← same concept, view level

 -----------------------------------------------------------------------
 D. CONTAINER VIEW CONTROLLERS
 -----------------------------------------------------------------------

 UINavigationController:
   push:  destination.viewWillAppear → source.viewWillDisappear
          → source.viewDidDisappear → destination.viewDidAppear

   pop:   destination.viewWillAppear → source.viewWillDisappear
          → source.viewDidDisappear → destination.viewDidAppear
          → source.deinit (if no other reference)

 UITabBarController:
   tab switch: newVC.viewWillAppear → oldVC.viewWillDisappear
               → oldVC.viewDidDisappear → newVC.viewDidAppear
   NOTE: VCs are NOT deallocated on tab switch — they stay loaded.

 Parent-Child Container:
   addChild(childVC)
   view.addSubview(childVC.view)
   childVC.didMove(toParent: self)

   childVC.willMove(toParent: nil)
   childVC.view.removeFromSuperview()
   childVC.removeFromParent()

 -----------------------------------------------------------------------
 E. MODAL PRESENTATION LIFECYCLE
 -----------------------------------------------------------------------

 Present: presenting.viewWillDisappear (NOT called for .pageSheet!)
          presented.viewWillAppear
          presented.viewDidAppear
          presenting.viewDidDisappear (depends on presentation style)

 Dismiss: presented.viewWillDisappear
          presenting.viewWillAppear
          presenting.viewDidAppear
          presented.viewDidDisappear
          presented.deinit

 NOTE ON .pageSheet / .formSheet (iOS 13+):
   These do NOT call viewWillDisappear on the presenting VC
   because the presenting VC is still partially visible.
   Use UIAdaptivePresentationControllerDelegate to know when
   modal is dismissed.

   class HomeVC: UIViewController,
                 UIAdaptivePresentationControllerDelegate {

       func presentModal() {
           let modal = DetailVC()
           modal.presentationController?.delegate = self
           present(modal, animated: true)
       }

       func presentationControllerDidDismiss(
           _ presentationController: UIPresentationController
       ) {
           // Called when modal is dismissed (swipe or programmatic)
           refreshData()
       }
   }

 -----------------------------------------------------------------------
 F. ROTATION & SIZE CHANGES
 -----------------------------------------------------------------------

 Rotation triggers:
   viewWillTransition(to:with:)
   viewWillLayoutSubviews()
   viewDidLayoutSubviews()

   override func viewWillTransition(
       to size: CGSize,
       with coordinator: UIViewControllerTransitionCoordinator
   ) {
       super.viewWillTransition(to: size, with: coordinator)
       coordinator.animate(alongsideTransition: { _ in
           // Animations during rotation
           self.updateLayoutForSize(size)
       }, completion: { _ in
           // After rotation completes
           self.finalizeLayout()
       })
   }

 =======================================================================
 PART 3: SWIFTUI APP LIFECYCLE
 =======================================================================

 -----------------------------------------------------------------------
 A. @main & App PROTOCOL
 -----------------------------------------------------------------------

 SwiftUI apps use the App protocol and @main attribute.
 Replaces UIApplicationMain / AppDelegate as the entry point.

 @main
 struct MyApp: App {

     // AppDelegate bridging (if needed for push notifications etc.):
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }

 NOTES:
   - @main designates this as the entry point
   - body returns one or more Scene descriptions
   - SwiftUI creates and manages the actual window/scene

 -----------------------------------------------------------------------
 B. SCENE TYPES (SwiftUI)
 -----------------------------------------------------------------------

 WindowGroup:
   - Standard multi-window scene (iPhone + iPad)
   - Multiple instances possible on iPad/Mac
   - Each window gets its own ContentView instance

   WindowGroup {
       ContentView()
           .environment(\.managedObjectContext, context)
   }

 DocumentGroup:
   - For document-based apps
   - Handles file open/save UI automatically
   DocumentGroup(newDocument: MyDocument()) { file in
       DocumentEditor(document: file.$document)
   }

 Settings (macOS):
   Settings {
       SettingsView()
   }

 -----------------------------------------------------------------------
 C. SCENEPHASE
 -----------------------------------------------------------------------

 ScenePhase is the SwiftUI equivalent of UIApplication states.
 Observed via @Environment(\.scenePhase).

 THREE PHASES:
   .active      → User is interacting with the scene
   .inactive    → Scene visible but not receiving input
                  (notification center pulled down, etc.)
   .background  → Scene not visible

 USAGE IN App:
   @main
   struct MyApp: App {
       @Environment(\.scenePhase) private var scenePhase

       var body: some Scene {
           WindowGroup {
               ContentView()
           }
           .onChange(of: scenePhase) { newPhase in
               switch newPhase {
               case .active:
                   print("App is active")
               case .inactive:
                   print("App is inactive")
               case .background:
                   saveData()
                   print("App is in background")
               @unknown default:
                   break
               }
           }
       }
   }

 USAGE IN View:
   struct ContentView: View {
       @Environment(\.scenePhase) private var scenePhase

       var body: some View {
           Text("Hello")
               .onChange(of: scenePhase) { phase in
                   if phase == .background {
                       saveUserProgress()
                   }
               }
       }
   }

 NOTE: When observed at the App level, .background fires when
 ALL scenes are in background. At View level, it fires for
 the specific scene containing that view.

 -----------------------------------------------------------------------
 D. ENVIRONMENT-DRIVEN LIFECYCLE
 -----------------------------------------------------------------------

 SwiftUI uses the environment to propagate lifecycle and system info:

   @Environment(\.scenePhase) var scenePhase
   @Environment(\.colorScheme) var colorScheme
   @Environment(\.dismiss) var dismiss
   @Environment(\.openURL) var openURL
   @Environment(\.managedObjectContext) var context

 AppDelegate bridging:
   // Still needed for: push notifications, background fetch,
   // third-party SDK setup, URL handling

   class AppDelegate: NSObject, UIApplicationDelegate {
       func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [...]?
       ) -> Bool {
           configureFirebase()
           configurePushNotifications()
           return true
       }
   }

   @main
   struct MyApp: App {
       @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
       var body: some Scene {
           WindowGroup { ContentView() }
       }
   }

 -----------------------------------------------------------------------
 E. ONAPPEAR / ONDISAPPEAR AT APP LEVEL
 -----------------------------------------------------------------------

   @main
   struct MyApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .onAppear { setupAnalytics() }
           }
       }
   }

 =======================================================================
 PART 4: SWIFTUI VIEW LIFECYCLE
 =======================================================================

 -----------------------------------------------------------------------
 A. VIEW PROTOCOL & BODY
 -----------------------------------------------------------------------

 Every SwiftUI view is a VALUE TYPE (struct) conforming to View.
 The body property describes the view's content and layout.

   struct MyView: View {
       var body: some View {
           Text("Hello")
       }
   }

 KEY INSIGHT: SwiftUI views are DESCRIPTIONS of UI, not the UI itself.
 The framework decides WHEN and HOW to render them.
 Unlike UIKit, you don't control rendering — you declare state.

 RENDERING PIPELINE:
   State changes → body re-evaluated → Diff with previous description
   → Only actual UI changes are applied to the rendering layer

 -----------------------------------------------------------------------
 B. VIEW IDENTITY
 -----------------------------------------------------------------------

 SwiftUI needs to track views across re-renders to:
   - Animate correctly
   - Preserve state
   - Know when to create/destroy views

 TWO TYPES OF IDENTITY:

 1. STRUCTURAL IDENTITY:
    SwiftUI infers identity from the view's TYPE and POSITION
    in the view hierarchy. Two views of the same type in the
    same position are treated as the same view.

    // Both Text views get different identity by position:
    VStack {
        Text("First")   // structural identity: VStack.0.Text
        Text("Second")  // structural identity: VStack.1.Text
    }

 2. EXPLICIT IDENTITY (id modifier):
    You explicitly assign a stable identity using .id(_:).
    Forces SwiftUI to treat a view as new when the id changes.

    // Force re-creation when userId changes:
    ProfileView(userId: userId)
        .id(userId)   // New id = new view = onAppear fires again

 -----------------------------------------------------------------------
 C. STATE & LIFECYCLE
 -----------------------------------------------------------------------

 @State:
   - Owned by the view
   - Initialized once when view is first created
   - Preserved across body re-evaluations (re-renders)
   - DESTROYED when the view is removed from hierarchy

   struct CounterView: View {
       @State private var count = 0

       var body: some View {
           Button("Count: \(count)") { count += 1 }
       }
   }

 @StateObject:
   - Owns a reference type (ObservableObject)
   - Created ONCE when the view is first created
   - Preserved as long as the view remains in hierarchy
   - Use when THIS view OWNS the object

   struct ProfileView: View {
       @StateObject private var viewModel = ProfileViewModel()
       var body: some View {
           Text(viewModel.username)
       }
   }

 @ObservedObject:
   - References an ObservableObject owned ELSEWHERE
   - Can be re-created if the parent re-renders and
     passes a new instance
   - Use when another view/owner created the object

   struct ProfileView: View {
       @ObservedObject var viewModel: ProfileViewModel // passed in
       var body: some View {
           Text(viewModel.username)
       }
   }

 LIFETIME DIFFERENCE (@State vs @StateObject):
   @State:        Scoped to the view's lifetime in the hierarchy
   @StateObject:  Same — preserved while view is in hierarchy
   @ObservedObject: No lifetime guarantee — tied to whoever owns it

 -----------------------------------------------------------------------
 D. ONAPPEAR / ONDISAPPEAR vs UIKIT EQUIVALENTS
 -----------------------------------------------------------------------

 UIKit                       SwiftUI
 ─────────────────────────── ─────────────────────────
 viewDidLoad()               .onAppear { }  (first time*)
 viewWillAppear()            .onAppear { }
 viewDidAppear()             .onAppear { }  (after animation*)
 viewWillDisappear()         .onDisappear { }
 viewDidDisappear()          .onDisappear { }  (after animation*)
 deinit                      No direct equivalent

 * SwiftUI does NOT distinguish between willAppear and didAppear.
   onAppear fires AFTER the view has appeared.

 onAppear FIRES when:
   - View is first inserted into the hierarchy
   - View re-appears after navigation (e.g., back from detail)
   - Tab switches back to a view
   - Sheet/full screen cover is dismissed revealing parent

 onDisappear FIRES when:
   - View is removed from hierarchy
   - Navigation pushes away from a view
   - Tab switches away
   - Sheet covers the view

   struct ContentView: View {
       @State private var items: [Item] = []

       var body: some View {
           List(items) { item in ItemRow(item: item) }
               .onAppear {
                   // Fires every time view appears
                   loadItems()
               }
               .onDisappear {
                   // Fires every time view disappears
                   cancelNetworkRequests()
               }
       }
   }

 IMPORTANT: onAppear fires EVERY appearance (not just first).
 For first-only setup, use @State flag:

   struct ContentView: View {
       @State private var hasAppeared = false

       var body: some View {
           Text("Hello")
               .onAppear {
                   guard !hasAppeared else { return }
                   hasAppeared = true
                   performFirstTimeSetup()
               }
       }
   }

 -----------------------------------------------------------------------
 E. task() MODIFIER
 -----------------------------------------------------------------------

 Introduced iOS 15. The async/await aware version of onAppear.

 DIFFERENCES FROM onAppear:
   - Can run async code directly
   - Automatically CANCELS the task when view disappears
   - No need for manual Task {} wrapper

   struct ContentView: View {
       @State private var data: [String] = []

       var body: some View {
           List(data, id: \.self) { Text($0) }
               .task {
                   // Runs on appear, cancelled on disappear
                   data = await fetchData()
               }
       }
   }

   // With id: Re-runs task when id changes
   .task(id: selectedCategory) {
       data = await fetchData(for: selectedCategory)
   }

 COMPARISON:
   .onAppear { Task { await fetch() } }  ← Task NOT auto-cancelled
   .task { await fetch() }               ← Task IS auto-cancelled ✓

 -----------------------------------------------------------------------
 F. VIEW UPDATES & RENDERING PIPELINE
 -----------------------------------------------------------------------

 WHEN DOES body GET CALLED?
   1. @State or @Binding property changes
   2. @StateObject / @ObservedObject publishes a change
   3. @EnvironmentObject publishes a change
   4. Environment values change (dark mode, accessibility, etc.)
   5. Parent view's body is called and passes new props

 HOW SWIFTUI AVOIDS UNNECESSARY REDRAWS:
   - Value types: compare old and new values
   - If identical → skip re-render of subtree
   - Use Equatable to help SwiftUI compare view props:

   struct ItemRow: View, Equatable {
       let item: Item

       static func == (lhs: ItemRow, rhs: ItemRow) -> Bool {
           lhs.item.id == rhs.item.id
       }

       var body: some View { Text(item.name) }
   }

   // Wrap with EquatableView for SwiftUI to use ==:
   EquatableView(content: ItemRow(item: item))

 -----------------------------------------------------------------------
 G. LIFETIME OF @State, @StateObject, @ObservedObject
 -----------------------------------------------------------------------

 SCENARIO: NavigationStack push/pop

   struct ParentView: View {
       @State private var showDetail = false

       var body: some View {
           NavigationStack {
               Button("Push") {
                   showDetail = true
               }
               .navigationDestination(isPresented: $showDetail) {
                   DetailView()  // @State inside DetailView created
                                 // on push, destroyed on pop
               }
           }
       }
   }

   struct DetailView: View {
       @State private var localCount = 0        // Created on push
       @StateObject private var vm = DetailVM() // Created on push

       var body: some View {
           Text("\(localCount)")
       }
       // When popped: localCount and vm are DESTROYED
       // Next push: fresh localCount = 0, fresh DetailVM()
   }

 SCENARIO: TabView

   struct ContentView: View {
       var body: some View {
           TabView {
               Tab1View()   // @State PRESERVED when switching tabs
               Tab2View()   // because tab views keep all tabs alive
           }
       }
   }

   // Unlike navigation, tab views don't destroy/recreate views
   // on tab switch. @State is preserved.

 =======================================================================
 PART 5: UIKIT vs SWIFTUI COMPARISON
 =======================================================================

 CONCEPT              UIKIT                     SWIFTUI
 ─────────────────────────────────────────────────────────────────────
 Entry point          AppDelegate @UIMain       @main App protocol
 Scene lifecycle      SceneDelegate             onChange(scenePhase)
 App states           UIApplicationDelegate     ScenePhase enum
 View creation        loadView(), viewDidLoad() View.init, body
 Appears              viewWillAppear            onAppear
 Fully visible        viewDidAppear             onAppear (no distinction)
 Disappears           viewWillDisappear         onDisappear
 Layout               viewDidLayoutSubviews     GeometryReader, layout()
 Deallocation         deinit                    No direct equivalent
 Async work           viewDidAppear + Task      .task {}
 State               @IBOutlet + model          @State, @StateObject
 Notification center  addObserver               .onReceive
 Dark mode            traitCollectionDidChange  automatic + colorScheme
 Rotation             viewWillTransition        automatic + GeometryReader
 Memory warning       applicationDidReceive     No direct equivalent
 Background           applicationDidEnter...    .onChange(scenePhase == .background)

 WHEN TO USE WHICH:
   UIKit:
     ✓ Complex custom animations
     ✓ UICollectionView / UITableView with complex cells
     ✓ Precise layout control needed
     ✓ Large existing codebase
     ✓ Camera / ARKit / complex media
     ✓ Targeting iOS < 14

   SwiftUI:
     ✓ New projects (iOS 16+)
     ✓ Rapid prototyping
     ✓ Simple to moderately complex layouts
     ✓ Widget / WatchOS / macOS / tvOS unified codebase
     ✓ Declarative data-driven UI

 =======================================================================
 PART 6: 100 INTERVIEW Q&A
 =======================================================================

 ────────────────────────────────────────────────────────────────────
 SECTION 1: BASIC QUESTIONS (Q1–Q30)
 ────────────────────────────────────────────────────────────────────

 Q1. What are the five app states in iOS?
 A:  1. Not Running  — app not launched or was terminated
     2. Inactive     — in foreground but not receiving events
     3. Active       — in foreground, receiving events (normal)
     4. Background   — not visible, may execute code briefly
     5. Suspended    — in background, no code executing

 ---

 Q2. What is the purpose of AppDelegate?
 A:  AppDelegate is the app-level event handler. It handles:
     app launch, push notification setup, URL opening, memory
     warnings, background task configuration, and
     scene session lifecycle (iOS 13+).

 ---

 Q3. What is SceneDelegate and when was it introduced?
 A:  Introduced in iOS 13, SceneDelegate manages the lifecycle
     of a single UI instance (scene/window). It handles:
     scene creation, foreground/background transitions,
     state restoration, and deep link handling per scene.

 ---

 Q4. What is the order of lifecycle methods when an app launches?
 A:  1. application(_:didFinishLaunchingWithOptions:)
     2. application(_:configurationForConnecting:...)
     3. scene(_:willConnectTo:options:)
     4. sceneWillEnterForeground(_:)
     5. sceneDidBecomeActive(_:)

 ---

 Q5. What does viewDidLoad() guarantee?
 A:  The view hierarchy has been loaded into memory. Subviews
     exist and can be configured. However, the view has not
     yet appeared on screen and final layout hasn't happened.
     It is called ONCE per VC lifecycle.

 ---

 Q6. What is the difference between viewWillAppear and viewDidAppear?
 A:  viewWillAppear: called just before view is added to screen.
     Transition animation hasn't started yet.
     viewDidAppear: called after view is fully visible and
     animation has completed.

 ---

 Q7. What is the difference between viewWillDisappear and viewDidDisappear?
 A:  viewWillDisappear: called before the view starts leaving.
     Good for saving state, hiding keyboard.
     viewDidDisappear: called after the view is fully gone.
     Good for stopping resource-intensive tasks.

 ---

 Q8. What should you do in viewDidLayoutSubviews?
 A:  Use it for anything that requires EXACT view dimensions:
     - Setting cornerRadius based on view size
     - Updating CALayer frames (gradients, borders)
     - Adjusting scroll view insets based on actual size
     Call super.viewDidLayoutSubviews() first.

 ---

 Q9. What is the purpose of loadView()?
 A:  It creates the root view for the VC. The default
     implementation loads from storyboard/nib. Override
     (without calling super) to create the root view
     programmatically:
     override func loadView() { self.view = MyCustomView() }

 ---

 Q10. What is ScenePhase in SwiftUI?
 A:  ScenePhase is an enum representing the app's current
     lifecycle state: .active, .inactive, .background.
     Observed via @Environment(\.scenePhase).

 ---

 Q11. How do you respond to app lifecycle events in SwiftUI?
 A:  Use .onChange(of: scenePhase) modifier on the Scene or
     on individual views in the body. You can also use
     @UIApplicationDelegateAdaptor to bridge to AppDelegate.

 ---

 Q12. What does onAppear do in SwiftUI?
 A:  The onAppear modifier executes a closure when the view
     appears on screen. It fires EVERY TIME the view becomes
     visible (not just first time).

 ---

 Q13. What is the UIKit equivalent of onAppear?
 A:  viewWillAppear / viewDidAppear. SwiftUI's onAppear
     is closest to viewDidAppear (fires after view is visible),
     though it doesn't strictly distinguish will vs did.

 ---

 Q14. What is the .task modifier in SwiftUI?
 A:  .task runs an async operation when a view appears and
     automatically cancels it when the view disappears.
     It's the async-aware version of .onAppear.

 ---

 Q15. What happens to @State when a SwiftUI view is popped off a NavigationStack?
 A:  The @State is destroyed. When the view is pushed again,
     @State starts fresh with its initial value.

 ---

 Q16. What is the difference between @StateObject and @ObservedObject?
 A:  @StateObject: The view OWNS the object. It's created once
     and preserved for the view's lifetime.
     @ObservedObject: The object is owned EXTERNALLY. The view
     just observes it. No guarantee of stability.

 ---

 Q17. When does deinit get called in UIKit?
 A:  When the last strong reference to a VC is released.
     For pushed VCs: when popped AND no other reference holds it.
     For presented VCs: when dismissed AND no strong reference.

 ---

 Q18. What is the difference between the app lifecycle in iOS 12 vs iOS 13+?
 A:  iOS 12: All lifecycle events go through AppDelegate.
     iOS 13+: App-level events → AppDelegate.
              Scene/UI lifecycle → SceneDelegate.
     This separation supports multi-window on iPad.

 ---

 Q19. How do you prevent multiple onAppear calls in SwiftUI?
 A:  Use a @State flag:
     @State private var hasLoaded = false
     .onAppear {
         guard !hasLoaded else { return }
         hasLoaded = true
         // one-time setup
     }

 ---

 Q20. What is @main in Swift?
 A:  @main designates a type as the program's entry point.
     The Swift compiler looks for a static main() method.
     For SwiftUI apps, App conformance provides this method.

 ---

 Q21. What is the purpose of applicationWillTerminate?
 A:  Called when the app is about to terminate. Used for
     final data save. IMPORTANT: This is NOT called if the
     app is suspended when the system kills it. Don't rely
     on it as the only save point.

 ---

 Q22. What is a retain cycle in the context of UIViewController lifecycle?
 A:  When a VC holds a strong reference to a closure (e.g.,
     completion handler) that captures self strongly, creating
     a cycle: VC → closure → VC. This prevents deinit from
     being called and leaks memory. Fix: [weak self] in closure.

 ---

 Q23. What is the role of makeKeyAndVisible() in UIKit?
 A:  It makes the window the key window (primary recipient of
     keyboard events) and visible on screen. Called in
     SceneDelegate's scene(_:willConnectTo:) to show the UI.

 ---

 Q24. What is the difference between a scene's disconnect and discard?
 A:  Disconnect: Scene is removed from the screen but may
                 be reconnected later (e.g., background).
     Discard: User permanently closes the window (swipe away
              in iPad multitasking). Application(_:didDiscardSceneSessions:)
              is called to clean up associated data.

 ---

 Q25. Can viewDidLoad be called more than once?
 A:  No. viewDidLoad is called exactly ONCE per VC instance
     when the view is loaded into memory. If the VC is
     deallocated and re-created, a new instance's viewDidLoad
     is called, but that's a different instance.

 ---

 Q26. What happens when an iOS app receives a phone call?
 A:  The app transitions to INACTIVE state.
     applicationWillResignActive (AppDelegate) or
     sceneWillResignActive (SceneDelegate) is called.
     If the user accepts: app goes to BACKGROUND.
     If the user declines: app returns to ACTIVE.

 ---

 Q27. What is the difference between .onAppear and .task for network calls?
 A:  .onAppear requires manual Task {} and manual cancellation.
     .task automatically wraps in a Task and cancels it when
     the view disappears. Prefer .task for async work.

 ---

 Q28. What does applicationDidReceiveMemoryWarning do?
 A:  Called when the system is low on memory. You should
     free cached data, images, or other non-essential memory.
     Also propagated to all VCs via didReceiveMemoryWarning().

 ---

 Q29. In SwiftUI, when does onDisappear fire during navigation?
 A:  When you push a new view, onDisappear fires on the
     source view. When you pop back, onAppear fires on the
     source view and onDisappear fires on the popped view.

 ---

 Q30. What is the recommended place to set up Auto Layout constraints in UIKit?
 A:  In viewDidLoad() for static constraints.
     In viewDidLayoutSubviews() for layout that depends
     on the view's actual size. NOT in viewWillAppear
     (called repeatedly).

 ────────────────────────────────────────────────────────────────────
 SECTION 2: INTERMEDIATE QUESTIONS (Q31–Q70)
 ────────────────────────────────────────────────────────────────────

 Q31. Why doesn't viewWillDisappear get called when presenting
      a .pageSheet in iOS 13+?
 A:  Because the presenting VC is STILL VISIBLE under the sheet.
     UIKit only calls viewWillDisappear when the VC fully leaves
     the screen. For .pageSheet/.formSheet, use
     UIAdaptivePresentationControllerDelegate to detect dismissal.

 ---

 Q32. What happens to UIViewController lifecycle on a tab switch?
 A:  The outgoing VC gets viewWillDisappear + viewDidDisappear.
     The incoming VC gets viewWillAppear + viewDidAppear.
     IMPORTANT: UITabBarController keeps all VCs loaded —
     they are NOT deallocated on tab switch.

 ---

 Q33. How does the parent-child VC container lifecycle work?
 A:  When adding:
       addChild(childVC)
       view.addSubview(childVC.view)
       childVC.didMove(toParent: self)
     When removing:
       childVC.willMove(toParent: nil)
       childVC.view.removeFromSuperview()
       childVC.removeFromParent()
     Skipping these steps prevents proper lifecycle forwarding.

 ---

 Q34. What is the difference between viewWillLayoutSubviews
      and viewDidLayoutSubviews?
 A:  viewWillLayoutSubviews: Called BEFORE auto layout runs.
     Bounds MAY change after this call. Use to prepare for layout.
     viewDidLayoutSubviews: Called AFTER auto layout runs.
     Final bounds are set. Use for size-dependent configuration.
     Both can be called MANY TIMES (not just on first load).

 ---

 Q35. How does SwiftUI identify views when a list changes?
 A:  SwiftUI uses the id(_:) modifier or ForEach's id parameter
     to stably identify list items. When items reorder/add/remove,
     SwiftUI matches by id to correctly animate and preserve state.
     ForEach(items, id: \.id) { ... }

 ---

 Q36. What is structural identity in SwiftUI and why does it matter?
 A:  Structural identity is SwiftUI's default way to identify
     views: by TYPE + POSITION in the hierarchy. Two views of
     the same type in the same branch are considered the same.
     This means SwiftUI preserves state across re-renders if
     the view's position doesn't change.

 ---

 Q37. What happens when you use an if/else in SwiftUI for identity?
 A:  if/else creates TWO different branches, giving each view
     different structural identities.
     if condition { MyView() } else { MyView() }
     The two MyView() are DIFFERENT views to SwiftUI.
     Transitions/animations happen because identity changes.

 ---

 Q38. How do you bridge UIKit lifecycle events into SwiftUI?
 A:  Use @UIApplicationDelegateAdaptor:
     @main struct App: App {
         @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
     }
     AppDelegate handles UIKit lifecycle callbacks while
     SwiftUI's App manages the scene graph.

 ---

 Q39. What is the order of layout calls when the screen rotates in UIKit?
 A:  1. viewWillTransition(to:with:)
     2. (in coordinator animation block): viewWillLayoutSubviews
     3. viewDidLayoutSubviews
     4. (in coordinator completion): final layout adjustments

 ---

 Q40. Why is viewDidLoad not the right place to make views circular?
 A:  In viewDidLoad, view bounds are provisional (often 0 or
     default storyboard size). Final bounds are only guaranteed
     in viewDidLayoutSubviews. So cornerRadius = height/2 should
     go in viewDidLayoutSubviews.

 ---

 Q41. How does background task execution time work in iOS?
 A:  Default: ~5 seconds to execute in background.
     beginBackgroundTask(expirationHandler:): extends to ~30 seconds.
     Background modes (Info.plist): unlimited for audio, location.
     BGAppRefreshTask (iOS 13+): scheduled, system-managed.
     Silent push: 30 seconds.

 ---

 Q42. What is the ScenePhase difference between App level and View level?
 A:  App level: .background fires when ALL scenes are in background.
     View level: .background fires when THIS VIEW'S SCENE is
     in background. An iPad app with two scenes can have one .active and one
    .background simultaneously. App-level scenePhase reflects the "worst"(most background)
    state across all scenes.

---

Q43. What is the difference between UIWindowScene and UIScene?
A:  UIScene is the abstract base class representing any scene.
 UIWindowScene is a concrete subclass specifically for
 window-based UI (which is what iPhone/iPad apps use).
 Other platforms/future scene types may use other UIScene
 subclasses (e.g., CPTemplateApplicationScene for CarPlay).

---

Q44. How does NotificationCenter observer registration
  relate to the view lifecycle?
A:  Best practice:
   Register   in viewWillAppear or viewDidLoad
   Deregister in viewDidDisappear or deinit
 Registering in viewDidLoad + deregistering in deinit
 is safest for observers needed throughout VC lifetime.
 Registering in viewWillAppear + deregistering in
 viewDidDisappear is best for observers only needed
 while visible. Always balance register/deregister to
 avoid duplicate notifications or memory leaks.

---

Q45. Can SwiftUI onAppear fire before the view is visible?
A:  It can fire slightly before the view's animation
 completes, but it fires after the view is inserted into
 the hierarchy. For work that must wait until fully visible
 (e.g., starting a video), using DispatchQueue.main.async
 inside onAppear delays one run loop tick to ensure
 the rendering pass has completed.

---

Q46. What is UIAdaptivePresentationControllerDelegate and
  when do you need it?
A:  A delegate protocol on UIPresentationController that
 notifies you about interactive dismissal events.
 Needed when:
 - Presenting with .pageSheet or .formSheet (iOS 13+)
 - The user can swipe down to dismiss
 - You need to know when dismissal occurs (to refresh data)

 Key methods:
 presentationControllerDidDismiss(_:) — user dismissed
 presentationControllerShouldDismiss(_:) — return false
                                           to prevent swipe dismiss
 presentationControllerDidAttemptToDismiss(_:) — fired
                                           when prevented

---

Q47. How does @EnvironmentObject interact with view lifecycle?
A:  @EnvironmentObject is injected via the environment.
 The object persists as long as the parent that injected
 it persists. Views observing it re-render when the
 object publishes changes. If a view is removed from the
 hierarchy and re-inserted, it gets the same object back
 from the environment (same instance, not a copy).

 struct ParentView: View {
     @StateObject private var store = AppStore()
     var body: some View {
         ChildView()
             .environmentObject(store)
     }
 }
 struct ChildView: View {
     @EnvironmentObject var store: AppStore
     // store survives navigation, tab switches etc.
 }

---

Q48. What is traitCollectionDidChange and what triggers it?
A:  Called on UIViewController/UIView when the iOS trait
 collection changes. Common triggers:
 - Dark/Light mode switch
 - Dynamic Type size change
 - Device rotation (compact/regular size class change)
 - Split screen multitasking entry/exit
 - Display zoom changes
 Use it to update non-adaptive UI that doesn't auto-respond
 to trait changes (e.g., custom CALayer colors).

---

Q49. In SwiftUI, how do you handle the equivalent of
  applicationDidReceiveMemoryWarning?
A:  SwiftUI has no direct equivalent. Options:
 1. Bridge via AppDelegate:
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        NotificationCenter.default.post(name: .memoryWarning, object: nil)
    }
 2. Observe UIApplication.didReceiveMemoryWarningNotification:
    .onReceive(NotificationCenter.default.publisher(
        for: UIApplication.didReceiveMemoryWarningNotification
    )) { _ in
        clearImageCache()
    }

---

Q50. How do you perform a one-time setup in SwiftUI
  equivalent to viewDidLoad?
A:  Three approaches:
 1. @State flag (most common):
    @State private var didLoad = false
    .onAppear { guard !didLoad else { return }
                didLoad = true; setup() }

 2. Task with id (fires once per view lifetime):
    .task { await setupAsync() }

 3. init of ViewModel (@StateObject):
    @StateObject private var vm = MyViewModel()
    // MyViewModel.init() is the "viewDidLoad" equivalent

---

Q51. What is the role of willMove(toParent:) and
  didMove(toParent:) in UIKit?
A:  These are lifecycle callbacks for child VCs in custom
 container view controllers.
 willMove(toParent: parent) — called before the VC is
   added/removed from parent. parent is nil when removing.
 didMove(toParent: parent) — called after the VC is
   added/removed from parent.
 You MUST call these manually when building custom
 containers. They also trigger viewWillAppear/viewDidAppear
 chains through the hierarchy.

---

Q52. Why does addChild() need to be called before
  adding the child view?
A:  addChild(_:) establishes the parent-child VC relationship
 BEFORE the view is added. This ensures:
 - Lifecycle method forwarding is set up
 - viewWillAppear etc. are properly called
 - The child VC knows its parent context
 Adding the view first, then calling addChild, can result
 in missed lifecycle calls.

---

Q53. What is the Coordinator pattern and how does it
  relate to VC lifecycle?
A:  Coordinator is an architectural pattern where a separate
 object manages navigation between VCs, rather than VCs
 talking to each other. The coordinator:
 - Creates and presents/pushes VCs
 - Holds strong references to child coordinators
 - VCs hold a weak delegate reference back to coordinator
 This decouples navigation from view lifecycle and
 prevents retain cycles (weak delegate).

---

Q54. How does UIViewController lifecycle interact with
  UINavigationController during a back swipe gesture?
A:  During interactive pop (swipe back gesture):
 - viewWillAppear fires on the destination VC immediately
 - viewWillDisappear fires on the source VC immediately
 If user cancels (swipes back partially then releases):
 - viewWillAppear fires on source VC (coming back)
 - viewWillDisappear fires on destination VC
 Both viewWillAppear and viewWillDisappear may be called
 multiple times before viewDidAppear/viewDidDisappear.

---

Q55. What is the App Protocol's scene(body) evaluation timing?
A:  The App body is evaluated once on launch to set up scenes.
 Unlike View body (re-evaluated on state changes), App body
 changes only the DESCRIPTION of scenes. The system creates
 actual scenes according to the configuration. The body
 isn't re-evaluated frequently — it's more of a declaration.

---

Q56. How does lazy loading of views affect lifecycle in UIKit?
A:  A VC's view is not loaded until first accessed
 (self.view, or view.addSubview, etc.).
 Benefits: saves memory for VCs not yet shown.
 Pitfall: accessing self.view in init() or before needed
 triggers premature loading and may cause incorrect sizing.
 In UITabBarController: all tab VCs are instantiated but
 their views are loaded lazily (when first shown).

---

Q57. What is the difference between present(_:animated:) and
  show(_:sender:) in UIKit?
A:  present(_:animated:): Always presents modally.
                       Explicit presentation style.
 show(_:sender:):       Context-aware presentation.
                       In NavigationController: pushes.
                       Otherwise: presents modally.
                       Adapts to the current containment.
 For consistent navigation-based flow: use show().
 For deliberate modal presentation: use present().

---

Q58. How does SwiftUI decide when to destroy vs preserve a view?
A:  SwiftUI destroys a view's state when:
 - The view's identity changes (structural or explicit .id)
 - The view is removed from the hierarchy
 - Navigation pops the view (NavigationStack)
 - A conditional (if/else) switches branches
 SwiftUI preserves state when:
 - The view stays in its position (tab views)
 - The view's identity is stable
 - The container keeps it alive (List, TabView)

---

Q59. What is the purpose of the .id() modifier in SwiftUI?
A:  .id(_:) assigns explicit identity to a view.
 When the id value changes, SwiftUI:
 1. Destroys the old view (onDisappear fires)
 2. Creates a new view (onAppear fires)
 3. All @State resets to initial values
 Use cases:
 - Force a form to reset: form.id(UUID())
 - Re-fetch data on parameter change: view.id(userId)
 - Force re-animation: view.id(animationTrigger)

---

Q60. What happens to ongoing network requests when an app
  enters background in UIKit?
A:  URLSession with default/ephemeral configuration:
 - Requests in flight continue briefly
 - New requests may not start
 URLSession with background configuration:
 - Requests continue even when suspended
 - System manages them outside the app process
 - Completion delivered on relaunch via:
   application(_:handleEventsForBackgroundURLSession:...)
 Best practice: use background URLSession for large
 downloads/uploads.

---

Q61. What is significant location change monitoring and
  how does it relate to app lifecycle?
A:  CLLocationManager.startMonitoringSignificantLocationChanges()
 can wake a SUSPENDED or NOT RUNNING app in the background
 when a significant location change occurs.
 The app launches with UIApplication.LaunchOptionsKey.location
 in launchOptions. You must handle this in
 application(_:didFinishLaunchingWithOptions:).

---

Q62. How do you test lifecycle methods in XCTest for UIKit?
A:  Load the VC's view explicitly:
 let vc = MyViewController()
 _ = vc.view          // triggers loadView + viewDidLoad
 vc.viewWillAppear(false)
 vc.viewDidAppear(false)
 // Test UI state
 vc.viewWillDisappear(false)
 vc.viewDidDisappear(false)
 For full integration: use UIWindow and embed the VC.

---

Q63. What is the Responder Chain and how does it interact
  with the VC lifecycle?
A:  The responder chain is UIKit's event-handling mechanism.
 UIView → UIViewController → UIWindow → UIApplication
 → AppDelegate
 VCs participate as responders. When a VC is added to
 the window hierarchy (viewDidAppear), it becomes part
 of the active responder chain. When removed
 (viewDidDisappear), it exits the chain. This is why
 keyboard shortcuts (UIKeyCommand) added to a VC only
 work when that VC is on screen.

---

Q64. How does weak self in closures relate to VC lifecycle?
A:  [weak self] prevents the closure from keeping a VC alive
 past its natural lifecycle. Without it:
 - Network closure retains VC → VC outlives its parent
 - VC never deinits → memory leak
 With [weak self]:
 - VC can be deallocated normally
 - Closure checks if self still exists before executing
 - guard let self = self else { return } pattern used
 ALWAYS use [weak self] in escaping closures that
 reference view controllers.

---

Q65. What is the difference between UIViewController
  viewIsAppearing and viewWillAppear (iOS 17+)?
A:  viewIsAppearing(_:) was added in iOS 17 (backdeployed
 to iOS 13). Called BETWEEN viewWillAppear and
 viewDidAppear. At this point:
 - The view IS in the hierarchy
 - Trait collection IS updated
 - Initial layout HAS occurred
 - But animation is NOT yet complete
 Use for: updating UI that depends on final layout/traits
 but before the animation starts. More reliable than
 viewWillAppear for size-dependent setup.
 viewWillAppear → viewIsAppearing → viewDidAppear

---

Q66. How does @StateObject initialization timing differ
  from @State initialization timing?
A:  @State initial value expression is evaluated every time
 the parent's body runs, but SwiftUI only USES the value
 once (first initialization). Subsequent parent re-renders
 do NOT reset @State.
 @StateObject's initializer is called every time the
 parent's body runs — BUT SwiftUI only creates the object
 ONCE and discards subsequent initializations.
 Implication: avoid expensive init in @StateObject unless
 necessary, since init() may be called but its result
 discarded on subsequent parent renders.

---

Q67. What is the withAnimation lifecycle and how does it
  interact with onAppear?
A:  withAnimation wraps state changes in an animation context.
 If you trigger state changes inside onAppear:
 .onAppear {
     withAnimation(.easeIn(duration: 0.3)) {
         isVisible = true
     }
 }
 The animation starts after the view has appeared.
 For appear animations, prefer .transition() + animation
 modifiers, which integrate with SwiftUI's lifecycle-aware
 animation system.

---

Q68. What is the consequence of calling super in lifecycle
  methods incorrectly in UIKit?
A:  Always call super for:
 viewDidLoad, viewWillAppear, viewDidAppear,
 viewWillDisappear, viewDidDisappear,
 viewWillLayoutSubviews, viewDidLayoutSubviews,
 traitCollectionDidChange, viewWillTransition,
 didReceiveMemoryWarning
 NOT calling super can result in:
 - Navigation bar animations breaking
 - Trait forwarding failing to children
 - System-managed UI not updating
 - Input accessory views misbehaving
 - Silent hard-to-debug bugs

---

Q69. What happens to @Published properties in an
  @StateObject when the view disappears?
A:  The @StateObject (and its @Published properties) persist
 as long as the VIEW remains in the hierarchy. They are
 NOT reset on disappear/reappear. They are only destroyed
 when the view is removed from the hierarchy entirely
 (navigation pop, conditional removal, etc.).
 This is a key difference from UIKit where you might
 recreate data on viewWillAppear.

---

Q70. How do you share data between two SwiftUI scenes
  (windows) on iPad?
A:  Options:
 1. @AppStorage (UserDefaults): lightweight, auto-syncs
 2. NSUbiquitousKeyValueStore: iCloud synced
 3. Core Data with NSPersistentContainer: shared store
 4. Custom singleton store (careful with thread safety)
 5. File-based sharing (shared App Group container)
 Since each scene has its own view hierarchy and @State,
 shared mutable state MUST go in an external store.
 DO NOT rely on @StateObject for cross-scene data —
 each scene gets its own instance.

────────────────────────────────────────────────────────────────────
SECTION 3: HARD / ADVANCED QUESTIONS (Q71–Q100)
────────────────────────────────────────────────────────────────────

Q71. Why can viewWillAppear and viewWillDisappear both
  be called multiple times before their "Did" counterparts
  during an interactive navigation gesture?
A:  During an interactive (swipe) pop gesture, UIKit calls
 viewWillAppear on the destination and viewWillDisappear
 on the source as soon as the gesture begins. If the user
 cancels the gesture mid-way, UIKit reverses these:
 viewWillDisappear fires on the destination,
 viewWillAppear fires on the source.
 This means WILL methods are not guaranteed to be
 followed by their DID counterparts. Any logic in
 viewWillAppear that should only run once (e.g.,
 analytics) must guard against this. The DID methods
 are only called after the transition fully commits.

---

Q72. Explain how the rendering loop works in SwiftUI and
  how it relates to view lifecycle.
A:  SwiftUI uses a two-phase rendering loop:

 PHASE 1 — ATTRIBUTE GRAPH (layout pass):
   - SwiftUI traverses the view tree
   - Computes sizes via proposal/response sizing protocol
   - Each view receives a proposed size, returns actual size
   - Parent arranges children based on their sizes

 PHASE 2 — RENDER PASS:
   - Resolved attributes are converted to Metal draw calls
   - CALayer-level updates are submitted to the render server
   - Off the main thread in many cases (iOS 15+)

 LIFECYCLE INTEGRATION:
 - body is called during Phase 1 when state changes
 - onAppear/onDisappear fire after Phase 2 confirms
   view insertion/removal from the render tree
 - Modifiers (.opacity, .offset) are resolved in Phase 1
   and don't require body re-evaluation

---

Q73. What is the risk of calling UIApplication.shared inside
  an App extension, and how does lifecycle differ?
A:  App extensions (widgets, share extensions, notification
 content extensions) do NOT run as a UIApplication process.
 Calling UIApplication.shared in an extension crashes
 or returns nil. Extensions have their own lifecycle:
 - No AppDelegate or SceneDelegate
 - Launched on demand by the system
 - Have strict memory limits (~120MB for widgets)
 - NSExtensionContext manages the extension lifecycle
 - Terminated by the system when not needed
 Share data between app and extensions via App Groups
 (shared UserDefaults/Core Data container).

---

Q74. How does the scene-based lifecycle interact with
  UIWindowSceneDelegate when the app is launched
  via a push notification?
A:  Launch sequence with push notification:
 1. application(_:didFinishLaunchingWithOptions:)
    launchOptions contains .remoteNotification key
 2. application(_:configurationForConnecting:...)
 3. scene(_:willConnectTo:options:)
    connectionOptions.notificationResponse contains
    the UNNotificationResponse
 4. sceneWillEnterForeground
 5. sceneDidBecomeActive
 You should handle the notification in step 3 by
 inspecting connectionOptions. If the app was
 ALREADY running (background → foreground via push),
 use userNotificationCenter(_:didReceive:withCompletionHandler:)
 instead (UNUserNotificationCenterDelegate).

---

Q75. How can you implement a custom UIViewController
  transition and what lifecycle methods fire during it?
A:  Implement UIViewControllerAnimatedTransitioning:

 class SlideTransition: NSObject,
     UIViewControllerAnimatedTransitioning {

     func transitionDuration(...) -> TimeInterval { 0.3 }

     func animateTransition(using context: UIViewControllerContextTransitioning) {
         let toVC = context.viewController(forKey: .to)!
         let fromVC = context.viewController(forKey: .from)!
         // Add toVC.view to containerView
         // Animate
         // Call context.completeTransition(true) when done
     }
 }

 LIFECYCLE DURING CUSTOM TRANSITION:
 1. fromVC.viewWillDisappear (before animation)
 2. toVC.viewWillAppear (before animation)
 3. [animation runs]
 4. toVC.viewDidAppear (after completeTransition)
 5. fromVC.viewDidDisappear (after completeTransition)
 The transition context controls timing of DID calls.

---

Q76. Explain how @State storage actually works under the hood
  in SwiftUI's attribute graph.
A:  @State is NOT stored inside the View struct (which is
 a temporary value type created fresh each render pass).
 Instead:
 1. On first render, SwiftUI allocates HEAP storage for
    @State in its internal "attribute graph" (a persistent
    graph of nodes representing the UI tree).
 2. The View struct gets a reference token (StateStorage<T>)
    that points to this heap node.
 3. On subsequent body calls, the same heap node is used.
 4. When state changes, SwiftUI marks the relevant graph
    node as dirty and schedules a re-evaluation of
    dependent body calls.
 5. When the view is removed from the tree, the graph node
    is deallocated, destroying the @State value.
 This is why @State survives body re-evaluations but NOT
 view identity changes.

---

Q77. What is the "purple thread checker" warning and
  how does it relate to view lifecycle?
A:  Xcode's Main Thread Checker detects when UIKit/AppKit
 UI updates occur on background threads. Related to
 lifecycle because:
 - Network callbacks arrive on background threads
 - Updating UI properties (labels, tableView.reloadData)
   from these callbacks triggers the warning/crash
 FIX:
 DispatchQueue.main.async { self.tableView.reloadData() }
 // or
 await MainActor.run { tableView.reloadData() }
 In SwiftUI: @MainActor on the view model ensures
 @Published updates are dispatched to main thread:
 @MainActor class ViewModel: ObservableObject { ... }

---

Q78. How does UIHostingController bridge UIKit and SwiftUI
  lifecycles?
A:  UIHostingController<Content: View> is a UIViewController
 subclass that hosts a SwiftUI view hierarchy.
 LIFECYCLE INTEGRATION:
 - viewDidLoad: SwiftUI view tree is created
 - viewWillAppear → SwiftUI onAppear fires
 - viewDidDisappear → SwiftUI onDisappear fires
 - view.intrinsicContentSize: returns SwiftUI's ideal size
 - Trait changes forwarded to SwiftUI environment
 CAVEATS:
 - SwiftUI layout system runs inside UIKit layout pass
 - Size changes require invalidateIntrinsicContentSize()
 - Embedding in UIScrollView needs explicit sizing
 - @Environment values set on UIHostingController.rootView
   propagate down the SwiftUI tree

---

Q79. What is the difference between .onReceive and
  .onChange in terms of lifecycle timing?
A:  .onReceive(publisher):
 - Subscribes to a Combine publisher
 - Fires whenever the publisher emits a value
 - Works with ANY Combine publisher
 - NOT guaranteed to be synchronous with body evaluation
 - Great for NotificationCenter, Timer.publish, etc.

 .onChange(of: value):
 - Fires when a specific value changes
 - Called AFTER the body has been evaluated with new value
 - Synchronous with the render cycle
 - Only works with Equatable values

 KEY DIFFERENCE:
 .onChange fires during/after body evaluation.
 .onReceive fires independently of the render cycle.
 For driving state changes: prefer .onChange.
 For external events: prefer .onReceive.

---

Q80. What are the memory implications of UIViewController
  being retained by the navigation stack?
A:  UINavigationController maintains a strong reference
 to all VCs in its viewControllers array. This means:
 - ALL pushed VCs stay in memory (not suspended)
 - Their views may be purged under memory pressure
   (didReceiveMemoryWarning can set view to nil in iOS < 6,
    but NOT in modern iOS — views are kept)
 - VCs are only deallocated when POPPED from the stack
 IMPLICATION: In a deep navigation stack, all VCs consume
 memory. Design VCs to be lightweight, lazy-load data,
 and release caches in didReceiveMemoryWarning.

---

Q81. How does Swift concurrency (async/await) interact
  with UIViewController lifecycle?
A:  async functions in UIKit VCs run on MainActor by default
 (since UIViewController is @MainActor).
 LIFECYCLE PITFALLS:
 1. A task started in viewDidAppear may complete AFTER
    viewDidDisappear. Always check if VC is still shown:
    guard isViewLoaded && view.window != nil else { return }

 2. Structured tasks (Task {}) in a VC are NOT automatically
    cancelled when the VC disappears. Store and cancel them:
    private var loadTask: Task<Void, Never>?
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadTask?.cancel()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTask = Task { await loadData() }
    }

 In SwiftUI: use .task{} which handles this automatically.

---

Q82. What is the UIScene.ActivationState and how does it
  differ from UIApplication.State?
A:  UIScene.ActivationState values:
 .foregroundActive    — scene is front and interactive
 .foregroundInactive  — scene is front but not interactive
 .background          — scene is not front
 .unattached          — scene is not connected to the app yet

 UIApplication.State values:
 .active     — equivalent, but app-wide
 .inactive
 .background

 KEY DIFFERENCE:
 UIScene.ActivationState is PER SCENE.
 UIApplication.State is GLOBAL for the whole app.
 On iPad with multiple windows, scene states can differ
 (one scene .foregroundActive, another .background).
 UIApplication.State reflects the "most active" scene.

---

Q83. How does SwiftUI handle lifecycle for views inside
  a LazyVStack or LazyHStack?
A:  Views inside Lazy containers follow ON-DEMAND lifecycle:
 - onAppear fires when the view SCROLLS into the visible area
 - onDisappear fires when the view SCROLLS out of visible area
 This means:
 - onAppear/onDisappear can fire MANY TIMES (not just once)
 - Do NOT start permanent setup in onAppear of lazy views
 - Prefer @StateObject for data that should outlive
   scroll position changes
 - .task {} is safe (auto-cancelled on disappear, restarted on appear)
 CONTRAST: VStack loads ALL child views upfront →
 onAppear fires once, onDisappear fires once (on removal).

---

Q84. What is the significance of the window.makeKeyAndVisible()
  call timing in SceneDelegate?
A:  makeKeyAndVisible() does three things:
 1. Makes the window the KEY window (receives keyboard/remote events)
 2. Makes the window VISIBLE (addSubview to screen layer)
 3. Triggers the root VC's view lifecycle:
    loadView → viewDidLoad → viewWillAppear → viewDidAppear

 TIMING MATTERS:
 - Call AFTER setting window.rootViewController
 - Any setup needed before viewDidLoad must happen BEFORE this call
 - Calling makeKeyAndVisible() before rootViewController is set
   causes a blank white screen (UIViewController with empty view)
 - In iOS 15+, if you delay this call, the launch screen
   persists longer (intentionally or unintentionally).

---

Q85. How do you implement proper lifecycle management for
  a video player (AVPlayer) across the VC lifecycle?
A:  class VideoViewController: UIViewController {
     private var player: AVPlayer?
     private var playerLayer: AVPlayerLayer?
     private var timeObserver: Any?

     override func viewDidLoad() {
         super.viewDidLoad()
         // Create player — heavyweight resource
         player = AVPlayer(url: videoURL)
     }

     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         // Layer frame must match final view bounds
         playerLayer?.frame = view.bounds
     }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         // Start playback when visible
         player?.play()
         // Add periodic time observer
         timeObserver = player?.addPeriodicTimeObserver(...)
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         // Pause when leaving — good UX + saves resources
         player?.pause()
     }

     override func viewDidDisappear(_ animated: Bool) {
         super.viewDidDisappear(animated)
         // Remove time observer — must remove to avoid retain cycle
         if let observer = timeObserver {
             player?.removeTimeObserver(observer)
             timeObserver = nil
         }
     }

     deinit {
         // Final cleanup
         player?.pause()
         player = nil
     }
 }

---

Q86. What happens to SwiftUI views when the app receives
  a memory warning?
A:  SwiftUI does NOT automatically discard views on memory
 warning (unlike UIKit which could nil out a VC's view
 in older iOS versions). Options:
 1. Observe the warning notification and clear caches:
    .onReceive(NotificationCenter.default.publisher(
        for: UIApplication.didReceiveMemoryWarningNotification
    )) { _ in
        imageCache.removeAll()
    }
 2. Use @StateObject ViewModels that can flush cached data
 3. Avoid storing large datasets in @State directly
 4. Prefer loading data on demand (Lazy containers)
 The system may kill the app entirely under severe pressure.

---

Q87. Explain the full lifecycle of a SwiftUI sheet from
  presentation to dismissal.
A:  PRESENTATION:
 1. .sheet(isPresented: $show) evaluated
 2. show changes to true
 3. Body of presenting view re-evaluated
 4. SwiftUI creates new view identity for sheet content
 5. Sheet content's @State initialized fresh
 6. Sheet content's onAppear fires
 7. (Presenting view's onDisappear does NOT fire — it's
    still visible behind the sheet)

 DISMISSAL:
 8. User swipes down OR isPresented set to false
 9. Sheet content's onDisappear fires
 10. Sheet content's @State / @StateObject destroyed
 11. isPresented becomes false
 12. Presenting view's .onChange(of: isPresented) fires
     if you're observing it

 IMPORTANT: To refresh presenting view after dismissal,
 use onDismiss parameter:
 .sheet(isPresented: $show, onDismiss: { refresh() }) {
     SheetContent()
 }

---

Q88. How does the iOS app lifecycle handle Handoff and
  Universal Links?
A:  HANDOFF:
 // Continue activity from another Apple device
 // AppDelegate:
 func application(
     _ application: UIApplication,
     continue userActivity: NSUserActivity,
     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
 ) -> Bool {
     // Restore app state to match activity
     return true
 }
 // SceneDelegate:
 func scene(_ scene: UIScene,
            continue userActivity: NSUserActivity) {
     // Scene-level activity continuation
 }

 UNIVERSAL LINKS:
 // Handled via same URL opening pathway:
 func scene(_ scene: UIScene,
            openURLContexts URLContexts: Set<UIOpenURLContext>) { }
 // AND for cold launch:
 // connectionOptions.userActivities in scene(_:willConnectTo:)

 SWIFTUI:
 .onOpenURL { url in handleDeepLink(url) }
 .onContinueUserActivity(NSUserActivityTypes.browse) { activity in
     // Handle Handoff
 }

---

Q89. What is the role of UIApplicationSceneManifest
  in Info.plist and how does it affect lifecycle?
A:  UIApplicationSceneManifest configures scene support:

 Key structure in Info.plist:
 UIApplicationSceneManifest
   ├── UIApplicationSupportsMultipleScenes: Bool
   │     true  = iPad multi-window enabled
   │     false = single scene mode
   └── UISceneConfigurations
         └── UIWindowSceneSessionRoleApplication
               ├── UISceneConfigurationName: "Default Configuration"
               ├── UISceneDelegateClassName: "$(PRODUCT_MODULE_NAME).SceneDelegate"
               └── UISceneStoryboardFile: "Main"

 WITHOUT this key: App uses iOS 12 AppDelegate-only lifecycle.
 WITH this key:    SceneDelegate lifecycle is used.
 UIApplicationSupportsMultipleScenes = false limits to
 one scene but still uses SceneDelegate for that scene.

---

Q90. How does SwiftUI's navigationDestination lifecycle
  differ from UINavigationController push lifecycle?
A:  NavigationStack with navigationDestination:

 SWIFTUI:
 .navigationDestination(isPresented: $isDetailShown) {
     DetailView()
 }
 - DetailView is created when isDetailShown = true
 - DetailView @State initialized on creation
 - onAppear fires after navigation animation
 - When popped: onDisappear fires, @State destroyed
 - LAZY: DetailView is NOT created until presented

 UIKIT PUSH:
 - VC instantiated when push() is called
 - viewDidLoad fires immediately (before animation starts)
 - viewDidAppear fires after animation completes
 - EAGER: VC is fully created and loaded before animation

 KEY DIFFERENCES:
 1. SwiftUI is lazy; UIKit is eager on instantiation
 2. SwiftUI doesn't distinguish will/did appear timings
 3. SwiftUI state reset on pop is automatic
 4. UIKit gives more fine-grained lifecycle control

---

Q91. What are the threading guarantees for lifecycle
  methods in UIKit?
A:  ALL UIKit lifecycle methods are called on the MAIN THREAD.
 This is guaranteed by UIKit's design.
 NEVER call these from background threads:
 - viewDidLoad, viewWillAppear, etc.
 - loadView
 - traitCollectionDidChange
 - viewWillTransition
 SwiftUI @MainActor annotation on View means body,
 onAppear, and onDisappear also run on the main thread.
 Swift 6 enforces this at compile time.
 If you dispatch lifecycle work to background:
 DispatchQueue.global().async {
     // Heavy computation
     DispatchQueue.main.async {
         self.tableView.reloadData() // Back to main
     }
 }

---

Q92. How does state restoration work in SwiftUI apps
  and how does it differ from UIKit's approach?
A:  SWIFTUI (iOS 14+): @SceneStorage
 @SceneStorage("selectedTab") private var selectedTab = 0
 - Automatically saved to/restored from scene session
 - Keyed by string identifier
 - Only lightweight, serializable values (Int, String, URL, Data)
 - Automatically restored when scene reconnects

 UIKIT:
 - Requires UIStateRestoring conformance
 - encodeRestorableState(with:) — save
 - decodeRestorableState(with:) — restore
 - UIApplication.registerForStateRestoration()
 - UIViewController.restorationIdentifier must be set
 - Complex but powerful: can restore navigation stacks,
   modal presentations, scroll positions, etc.

 SWIFTUI + UIKIT HYBRID:
 Use @SceneStorage for simple SwiftUI state.
 Use UIHostingController + UIKit state restoration
 for complex multi-VC restoration.

---

Q93. What is the NSUserActivity lifecycle and how does
  it enable Spotlight search and Siri integration?
A:  NSUserActivity represents a user's current action.
 LIFECYCLE:
 1. Create and configure:
    let activity = NSUserActivity(activityType: "com.app.viewItem")
    activity.title = "View Item"
    activity.userInfo = ["itemId": "123"]
    activity.isEligibleForSearch = true       // Spotlight
    activity.isEligibleForHandoff = true      // Handoff
    activity.isEligibleForPrediction = true   // Siri Shortcuts
    self.userActivity = activity              // Assign to VC

 2. Update as user navigates:
    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.addUserInfoEntries(from: ["itemId": currentItemId])
    }

 3. Resign when VC disappears:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.userActivity?.invalidate()
    }

 SWIFTUI:
 .userActivity("com.app.viewItem") { activity in
     activity.title = "View Item"
 }
 .onContinueUserActivity("com.app.viewItem") { activity in
     // Handle continuation
 }

---

Q94. Explain the view lifecycle implications of using
  GeometryReader in SwiftUI.
A:  GeometryReader participates in the layout lifecycle:
 1. Parent PROPOSES a size to GeometryReader
 2. GeometryReader takes ALL available space (greedy)
 3. GeometryReader provides GeometryProxy to child
 4. Child uses proxy.size to configure itself
 5. Child returns its size to GeometryReader
 6. GeometryReader reports size back to parent

 LIFECYCLE GOTCHA:
 GeometryReader causes the child to re-render whenever
 the available size changes (rotation, split view, etc.)
 because the proxy changes.

 PERFORMANCE CONCERN:
 Using GeometryReader high in the view tree means large
 subtrees re-render on every size change.
 PREFER:
 - .frame(maxWidth: .infinity) for expansion
 - Layout protocol (iOS 16+) for custom layouts
 - .background(GeometryReader {...}) to read size
   without affecting layout of main content

---

Q95. How do multiple concurrent scenes affect AppDelegate
  lifecycle methods?
A:  With multiple scenes (iPad multi-window):
 - AppDelegate fires ONCE: didFinishLaunchingWithOptions
 - Each scene gets its OWN SceneDelegate instance
 - sceneDidBecomeActive/sceneWillResignActive fire
   PER SCENE, independently
 - applicationDidBecomeActive (AppDelegate) only fires
   when the APP moves from background to foreground
   (not on scene-to-scene focus changes)
 - applicationDidEnterBackground fires when ALL scenes
   are backgrounded

 SUBTLE BUG: Registering for UIApplication.didBecomeActiveNotification
 expecting it to fire on tab/window switches will fail.
 Use UIScene.willActivateNotification instead:
 NotificationCenter.default.addObserver(
     forName: UIScene.willActivateNotification, ...)

---

Q96. What is the ObservableObject publication cycle and
  how does it interact with SwiftUI's render lifecycle?
A:  When an @Published property changes:
 1. The set accessor fires
 2. objectWillChange.send() is called (automatically for @Published)
 3. SwiftUI receives the "will change" signal
 4. SwiftUI schedules a render pass for the next run loop tick
 5. body is evaluated with the NEW value
 6. Diff is computed against previous render
 7. Only changed portions of the UI are updated

 IMPORTANT — TIMING:
 "Will change" fires BEFORE the value changes.
 SwiftUI captures the new value AFTER the set completes.
 If you publish MULTIPLE changes in one synchronous block,
 SwiftUI coalesces them into ONE render pass.

 COALESCING EXAMPLE:
 viewModel.name = "Alice"    // schedules render
 viewModel.age = 30          // schedules render (same pass)
 // Result: ONE body call, not two

 MANUAL PUBLISH:
 objectWillChange.send()  // use before manually changing non-@Published props

---

Q97. What are the lifecycle differences between
  UIViewController and NSViewController (macOS)?
A:  While both follow a similar pattern, key differences:
 UIViewController (iOS):
   loadView → viewDidLoad → viewWillAppear → viewDidAppear
   viewWillDisappear → viewDidDisappear

 NSViewController (macOS):
   loadView → viewDidLoad → viewWillAppear → viewDidAppear
   viewWillDisappear → viewDidDisappear
   + viewWillLayout / viewDidLayout (similar to iOS)
   + updateViewConstraints (layout pass hook)

 KEY DIFFERENCES:
 - NSViewController.view is NOT nil by default (has default NSView)
 - viewDidAppear fires differently: macOS windows don't
   "push/pop" — they show/hide. viewDidAppear fires on
   window visibility change.
 - No concept of "background" state (macOS apps always running)
 - NSWindowDelegate handles window-level lifecycle
 - Multiple windows are the norm (not the exception) on macOS

---

Q98. How do you properly implement a "skeleton loading screen"
  pattern with SwiftUI lifecycle?
A:  Skeleton screen should:
 1. Show on FIRST appear only (or while loading)
 2. Animate while data loads
 3. Transition smoothly when data arrives

 struct ContentView: View {
     @StateObject private var vm = ContentViewModel()

     var body: some View {
         Group {
             if vm.isLoading {
                 SkeletonView()
                     .transition(.opacity)
             } else {
                 DataView(data: vm.data)
                     .transition(.opacity)
             }
         }
         .animation(.easeInOut(duration: 0.3), value: vm.isLoading)
         .task {
             // Fires on appear, cancelled on disappear
             await vm.loadData()
         }
     }
 }

 @MainActor
 class ContentViewModel: ObservableObject {
     @Published var isLoading = true
     @Published var data: [Item] = []

     func loadData() async {
         isLoading = true
         data = await fetchFromServer()
         isLoading = false
     }
 }

 LIFECYCLE NOTE: Using .task ensures if the user navigates
 away mid-load, the task cancels. On return, onAppear fires
 again, .task re-runs, and fresh data is fetched.

---

Q99. What is the correct way to handle deep linking in a
  SwiftUI app across both cold launch and warm launch?
A:  COLD LAUNCH (app not running):
 App is launched via URL/universal link.
 1. @main App.body evaluated
 2. WindowGroup sets up ContentView
 3. scene(_:willConnectTo:options:) fires (if bridged)
 4. ContentView .onOpenURL fires
 5. Navigate to deep link destination

 WARM LAUNCH (app running in background):
 1. App is foregrounded
 2. scene(_:openURLContexts:) fires (SceneDelegate)
 3. ContentView .onOpenURL fires

 SWIFTUI HANDLER:
 @main
 struct MyApp: App {
     @StateObject private var router = Router()

     var body: some Scene {
         WindowGroup {
             RootView()
                 .environmentObject(router)
                 .onOpenURL { url in
                     // Fires for BOTH cold and warm launch
                     router.handle(url: url)
                 }
         }
     }
 }

 class Router: ObservableObject {
     @Published var destination: Destination?
     func handle(url: URL) {
         destination = parseDestination(from: url)
     }
 }

 NOTE: .onOpenURL is the unified handler — it fires
 regardless of whether the app was launched cold or warm.
 No need to separately handle AppDelegate/SceneDelegate
 URL methods for SwiftUI apps.

---

Q100. What is the full lifecycle sequence for an iPad app
   moving from single-window to Split View multitasking,
   and how should you handle it?
A:  SEQUENCE when user enters Split View:

 1. UIWindowScene size changes
 2. Scene's coordinateSpace and geometry update
 3. UIWindowSceneDelegate windowScene(_:
       didUpdate:interfaceOrientation:traitCollection:) fires
 4. VC receives viewWillTransition(to:with:)
 5. Trait collection updates: horizontal size class may
    change from .regular to .compact
 6. traitCollectionDidChange fires on all VCs in hierarchy
 7. viewWillLayoutSubviews + viewDidLayoutSubviews fire
 8. ScenePhase does NOT change (still .active)

 SWIFTUI HANDLING:
 struct ContentView: View {
     @Environment(\.horizontalSizeClass) var hSizeClass

     var body: some View {
         if hSizeClass == .compact {
             CompactLayout()
         } else {
             RegularLayout()
         }
     }
 }
 // SwiftUI automatically re-evaluates body when
 // sizeClass changes — no manual lifecycle handling needed

 UIKIT HANDLING:
 override func traitCollectionDidChange(
     _ previous: UITraitCollection?
 ) {
     super.traitCollectionDidChange(previous)
     if traitCollection.horizontalSizeClass != previous?.horizontalSizeClass {
         updateLayoutForSizeClass()
     }
 }

 IMPORTANT CONSIDERATIONS:
 - Don't assume .regular = full screen on iPad
 - Column-based layouts (UISplitViewController) should
   adapt automatically if configured with primaryColumnWidth
 - Use UIContentContainer protocol for custom containers
   to properly forward size changes to children
 - NavigationSplitView (SwiftUI) handles this automatically

=======================================================================
END OF NOTES
=======================================================================
QUICK REFERENCE CHEAT SHEET
=======================================================================

UIKIT APP LIFECYCLE ORDER:
Launch:       didFinishLaunchingWithOptions
             → willConnectTo (Scene)
             → sceneWillEnterForeground
             → sceneDidBecomeActive

Background:   sceneWillResignActive
             → sceneDidEnterBackground

Foreground:   sceneWillEnterForeground
             → sceneDidBecomeActive

Terminate:    applicationWillTerminate (not always called)

UIKIT VIEW LIFECYCLE ORDER:
init → loadView → viewDidLoad → viewWillAppear
→ viewIsAppearing (iOS 13+) → viewWillLayoutSubviews
→ viewDidLayoutSubviews → viewDidAppear → [visible]
→ viewWillDisappear → viewWillLayoutSubviews
→ viewDidLayoutSubviews → viewDidDisappear → deinit

SWIFTUI LIFECYCLE:
App:  body (once) → onChange(scenePhase)
View: body → onAppear → [renders] → onDisappear

KEY RULES TO REMEMBER:
✓ viewDidLoad   = ONE TIME, view loaded (no final size)
✓ viewDidLayoutSubviews = EVERY layout, final size available
✓ viewWillAppear = EVERY appearance
✓ deinit = call ONLY if no retain cycle
✓ onAppear = EVERY appearance (not just first)
✓ .task = onAppear + async + auto-cancel
✓ @StateObject = owned by view, created once
✓ @ObservedObject = owned externally, can be replaced
✓ ScenePhase.background ≠ app terminated
✓ applicationWillTerminate NOT called if app is suspended
=======================================================================

 */
