import Configuration
import Foundation
import Hummingbird

public enum {{TEMPLATE_APP_NAME}}Server {
  public static func main() async throws {
    let config = ConfigReader(provider: EnvironmentVariablesProvider())
    let port = config.int(forKey: "port", default: {{TEMPLATE_SERVER_PORT}})

    let app = Application(
      router: buildRouter(),
      configuration: .init(address: .hostname("127.0.0.1", port: port))
    )
    try await app.runService()
  }

  private static func buildRouter() -> Router<BasicRequestContext> {
    let router = Router()
    router.get("/status") { _, _ in "OK" }
    return router
  }
}
