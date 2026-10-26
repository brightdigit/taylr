enum PilotError: Error {
  case invalidWorkspaceDocument
  case cannotFindScheme(String)
}
