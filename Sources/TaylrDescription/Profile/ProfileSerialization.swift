//
//  ProfileSerialization.swift
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

/// How a ``ProfileSource`` is stored and encoded: one case per kind of profile.
public enum ProfileSerialization: Sendable, Codable, Equatable {
  /// A profile named in `~/.taylr/profiles/`.
  case reference(name: String)
  /// A profile spelled out in the manifest.
  case custom(profile: CustomProfile)

  /// The bundle ID prefix the profile resolves to, or `nil` for a ``reference(name:)``, whose
  /// prefix lives in the profile file.
  public var resolvedBundleIDPrefix: String? {
    switch self {
    case .reference:
      nil
    case .custom(let profile):
      profile.resolvedBundleIDPrefix
    }
  }
}
