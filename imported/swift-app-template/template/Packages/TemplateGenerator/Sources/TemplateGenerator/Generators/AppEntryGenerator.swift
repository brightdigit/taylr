enum AppEntryGenerator {
  static func generate(appName: String) -> String {
    """
    #if canImport(SwiftUI)
      import SwiftUI
      import \(appName)Kit

      public protocol \(appName)App: App {
        var model: AppModel { get }
      }

      extension \(appName)App {
        public var body: some Scene {
          WindowGroup {
            ContentView()
              .environment(model)
          }
        }
      }
    #endif
    """
  }
}
