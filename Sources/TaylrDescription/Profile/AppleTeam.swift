//
//  AppleTeam.swift
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

/// An Apple team.
public struct AppleTeam: Sendable, Codable, Equatable {
  /// The Apple Developer Team ID. Needed to sign.
  public let teamID: String?
  /// The Apple ID for App Store Connect. Usually left out, so each person's own comes from
  /// their `config.yml`.
  public let appleID: String?
  /// The App Store Connect team ID, if the Apple ID belongs to more than one team.
  public let ascTeamID: String?

  /// Creates an Apple team.
  ///
  /// - Parameters:
  ///   - teamID: The Apple Developer Team ID.
  ///   - appleID: The Apple ID for App Store Connect.
  ///   - ascTeamID: The App Store Connect team ID.
  public init(teamID: String? = nil, appleID: String? = nil, ascTeamID: String? = nil) {
    self.teamID = teamID
    self.appleID = appleID
    self.ascTeamID = ascTeamID
  }
}
