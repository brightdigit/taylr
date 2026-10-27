//
//  PackageGraph.swift
//  taylr
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

/// Reads a client, a server and `others` into one graph of packages keyed by name.
internal struct PackageGraph {
  private enum Role {
    case client
    case server
    case other
  }

  internal let appName: String
  internal let client: Package
  internal let server: Package?
  internal let others: [Package]
  private var declarations: [String: Package] = [:]

  private var rootNames: [String] {
    var roots = [key(client)]
    if let server { roots.append(key(server)) }
    roots.append(contentsOf: others.map { key($0) })
    return roots
  }

  internal init(appName: String, client: Package, server: Package?, others: [Package]) {
    self.appName = appName
    self.client = client
    self.server = server
    self.others = others
  }

  /// The package's name in the graph. Only
  /// ``Package/server(name:platforms:dependencies:framework:)`` leaves a name out, so a missing
  /// name is the server's: `<App>Server`.
  private func key(_ package: Package) -> String {
    package.name ?? "\(appName)Server"
  }

  internal mutating func resolve() throws(Packages.GraphError) -> [Package] {
    try collect(client, role: .client)
    if let server { try collect(server, role: .server) }
    for other in others { try collect(other, role: .other) }
    try checkCycles()
    try checkClientDoesNotUseServer()
    try checkOthers()
    return orderedPackages()
  }

  // MARK: Reading

  private mutating func collect(_ declared: Package, role: Role) throws(Packages.GraphError) {
    var package = declared
    let name = key(package)
    package.name = name
    if package.framework != nil { try checkServerSlot(package, role: role) }
    if let existing = declarations[name] {
      if existing.isNameOnly {
        if !package.isNameOnly { declarations[name] = package }
      } else if !package.isNameOnly && existing != package {
        throw .duplicateNameDifferentSettings(name: name)
      }
    } else {
      declarations[name] = package
    }
    for dependency in package.localDependencyPackages {
      try collect(dependency, role: .other)
    }
  }

  private func checkServerSlot(_ package: Package, role: Role) throws(Packages.GraphError) {
    switch role {
    case .server:
      return
    case .client:
      throw .serverOutsideServerSlot(name: key(package))
    case .other:
      guard let server else { throw .serverOutsideServerSlot(name: key(package)) }
      if key(package) != key(server) {
        throw .multipleServers(names: [key(server), key(package)])
      }
    }
  }

  private func localNames(of name: String) -> [String] {
    declarations[name]?.localDependencyPackages.map { key($0) } ?? []
  }

  // MARK: Checks

  private func checkCycles() throws(Packages.GraphError) {
    var done: Set<String> = []
    for root in rootNames {
      var stack: [String] = []
      try visit(root, stack: &stack, done: &done)
    }
  }

  private func visit(
    _ name: String, stack: inout [String], done: inout Set<String>
  ) throws(Packages.GraphError) {
    if let index = stack.firstIndex(of: name) {
      throw .cycle(path: Array(stack[index...]) + [name])
    }
    if done.contains(name) {
      return
    }
    stack.append(name)
    for next in localNames(of: name) {
      try visit(next, stack: &stack, done: &done)
    }
    stack.removeLast()
    done.insert(name)
  }

  private func checkClientDoesNotUseServer() throws(Packages.GraphError) {
    guard let server else {
      return
    }
    let serverName = key(server)
    var parents: [String: String] = [:]
    var queue = [key(client)]
    var seen: Set<String> = [key(client)]
    var index = 0
    while index < queue.count {
      let name = queue[index]
      index += 1
      for next in localNames(of: name) where seen.insert(next).inserted {
        parents[next] = name
        if next == serverName {
          var path = [next]
          while let parent = parents[path[0]] { path.insert(parent, at: 0) }
          throw .clientDependsOnServer(path: path)
        }
        queue.append(next)
      }
    }
  }

  private func checkOthers() throws(Packages.GraphError) {
    for other in others {
      let name = key(other)
      let isUsed =
        name == key(client) || name == server.map { key($0) }
        || declarations.contains { declaredName, package in
          declaredName != name && package.localDependencyPackages.contains { key($0) == name }
        }
      if isUsed { throw .unusedOthersEntry(name: name) }
    }
  }

  // MARK: Ordering

  /// Breadth-first from the client, then from the server, then from each `others` entry.
  private func orderedPackages() -> [Package] {
    var result: [Package] = []
    var seen: Set<String> = []
    for root in rootNames where seen.insert(root).inserted {
      var queue = [root]
      var index = 0
      while index < queue.count {
        let name = queue[index]
        index += 1
        if let package = declarations[name] { result.append(package) }
        for next in localNames(of: name) where seen.insert(next).inserted {
          queue.append(next)
        }
      }
    }
    return result
  }
}

extension Package {
  /// The packages this one lists as ``DependencySerialization/local(package:)``.
  fileprivate var localDependencyPackages: [Package] {
    dependencies.compactMap { dependency in
      guard case .local(let package) = dependency else {
        return nil
      }
      return package
    }
  }

  /// A package that is only a name: every other setting is at its default.
  fileprivate var isNameOnly: Bool {
    name.map { self == Package(name: $0) } ?? false
  }
}
