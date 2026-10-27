//
//  License.swift
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

/// The license a project or package is released under.
///
/// taylr writes the license text when it creates the project and picks the file header that
/// suits the license.
public enum License: String, CaseIterable, Sendable, Codable, Equatable {
  /// All rights reserved. The default for apps.
  case proprietary
  /// The MIT License. The default for packages.
  case mit
  /// The Apache License 2.0.
  case apache2
  /// The BSD 2-Clause License.
  case bsd2
  /// The BSD 3-Clause License.
  case bsd3
  /// The Boost Software License 1.0.
  case boost
  /// The Mozilla Public License 2.0.
  case mpl2
  /// The Eclipse Public License 2.0.
  case epl2
  /// The GNU General Public License, version 2.
  case gpl2
  /// The GNU General Public License, version 3.
  case gpl3
  /// The GNU Lesser General Public License, version 2.1.
  case lgpl21
  /// The GNU Affero General Public License, version 3.
  case agpl3
  /// The CC0 1.0 Universal public domain dedication.
  case cc0
  /// The Unlicense.
  case unlicense

  /// The license's SPDX identifier, such as `Apache-2.0`.
  public var spdxIdentifier: String {
    switch self {
    case .proprietary: "LicenseRef-Proprietary"
    case .mit: "MIT"
    case .apache2: "Apache-2.0"
    case .bsd2: "BSD-2-Clause"
    case .bsd3: "BSD-3-Clause"
    case .boost: "BSL-1.0"
    case .mpl2: "MPL-2.0"
    case .epl2: "EPL-2.0"
    case .gpl2: "GPL-2.0"
    case .gpl3: "GPL-3.0"
    case .lgpl21: "LGPL-2.1"
    case .agpl3: "AGPL-3.0"
    case .cc0: "CC0-1.0"
    case .unlicense: "Unlicense"
    }
  }

  /// The name of the license file at the project root: `LICENSE`, `COPYING` for GPL 3 and
  /// `UNLICENSE` for the Unlicense.
  public var fileName: String {
    switch self {
    case .gpl3: "COPYING"
    case .unlicense: "UNLICENSE"
    default: "LICENSE"
    }
  }

  /// Whether file headers carry a copyright line. `false` for CC0 and the Unlicense.
  public var includesCopyrightLine: Bool {
    switch self {
    case .cc0, .unlicense: false
    default: true
    }
  }

  /// Whether the license asks for a short notice in each source file: Apache, GPL, LGPL,
  /// AGPL, MPL and EPL.
  public var requiresPerFileNotice: Bool {
    switch self {
    case .apache2, .gpl2, .gpl3, .lgpl21, .agpl3, .mpl2, .epl2: true
    default: false
    }
  }
}
