import Foundation

enum GeneratorError: LocalizedError {
  case invalidAppName(String, reason: String)
  case pathValidationFailed(String, reason: String)
  case fileWriteFailed(path: String, underlyingError: Error)
  case directoryCreationFailed(path: String, underlyingError: Error)

  var errorDescription: String? {
    switch self {
    case .invalidAppName(let name, let reason):
      return """
        Invalid app name '\(name)': \(reason)
        App names must start with a letter or underscore and contain only letters, numbers, and underscores.
        """
    case .pathValidationFailed(let path, let reason):
      return """
        Path validation failed for '\(path)': \(reason)
        """
    case .fileWriteFailed(let path, let error):
      return "Failed to write file at '\(path)': \(error.localizedDescription)"
    case .directoryCreationFailed(let path, let error):
      return "Failed to create directory at '\(path)': \(error.localizedDescription)"
    }
  }
}
