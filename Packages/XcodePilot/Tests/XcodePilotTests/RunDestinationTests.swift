import Testing

@testable import XcodePilot

@Suite("RunDestination")
internal enum RunDestinationTests {
  @Suite("firstMatch(in:)")
  internal struct MatchTests {
    private static let destinations = [
      Destination(platform: "macOS", arch: "arm64", name: "My Mac"),
      Destination(
        platform: "iOS Simulator",
        arch: "x86_64",
        name: "iPhone 17",
        operatingSystem: "26.0"
      ),
      Destination(
        platform: "iOS Simulator",
        arch: "arm64",
        name: "iPhone 17 Pro",
        operatingSystem: "27.0"
      ),
    ]

    @Test("The architecture decides the match within a platform")
    internal func matchesArch() {
      let runDestination = RunDestination(arch: "arm64", platform: "iOS Simulator")
      #expect(runDestination.firstMatch(in: Self.destinations)?.name == "iPhone 17 Pro")
    }

    @Test("The OS version decides the match when no architecture is given")
    internal func matchesOperatingSystem() {
      let runDestination = RunDestination(platform: "iOS Simulator", operatingSystem: "26.0")
      #expect(runDestination.firstMatch(in: Self.destinations)?.name == "iPhone 17")
    }

    @Test("The name decides the match when nothing else is given")
    internal func matchesName() {
      let runDestination = RunDestination(platform: "macOS", name: "My Mac")
      #expect(runDestination.firstMatch(in: Self.destinations)?.arch == "arm64")
    }

    @Test("A destination on another platform never matches")
    internal func rejectsOtherPlatform() {
      let runDestination = RunDestination(arch: "arm64", platform: "visionOS Simulator")
      #expect(runDestination.firstMatch(in: Self.destinations) == nil)
    }
  }
}
