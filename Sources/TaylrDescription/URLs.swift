//
//  URLs.swift
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

/// The links App Store Connect requires for an app.
///
/// Give each link in full with ``init(privacy:support:marketing:)``, or give your website and
/// the path of each page with ``base(_:privacy:support:marketing:)``.
public struct URLs: Sendable, Codable, Equatable {
  /// The privacy policy URL. Required by App Store Connect.
  public var privacy: String

  /// The support page URL. Required by App Store Connect.
  public var support: String

  /// The marketing page URL. Optional; `nil` by default.
  public var marketing: String?

  /// Creates URLs from links given in full.
  ///
  /// - Parameters:
  ///   - privacy: The privacy policy URL.
  ///   - support: The support page URL.
  ///   - marketing: The marketing page URL, or `nil` for none.
  public init(privacy: String, support: String, marketing: String? = nil) {
    self.privacy = privacy
    self.support = support
    self.marketing = marketing
  }

  /// Creates URLs from your website and the path of each page.
  ///
  /// Each path is joined to `url` with exactly one slash, whether or not `url` ends in `/` or
  /// the path starts with `/`. A path of `/` (or an empty path) resolves to `url` itself without a
  /// trailing slash, so the default marketing page of `https://acme.example` is
  /// `https://acme.example`.
  ///
  /// - Parameters:
  ///   - url: The website, such as `https://acme.example`.
  ///   - privacy: The path of the privacy policy. Defaults to `/privacy`.
  ///   - support: The path of the support page. Defaults to `/support`.
  ///   - marketing: The path of the marketing page. Defaults to `/`.
  /// - Returns: The three URLs as absolute strings.
  public static func base(
    _ url: String,
    privacy: String = "/privacy",
    support: String = "/support",
    marketing: String = "/"
  ) -> URLs {
    URLs(
      privacy: join(url, privacy),
      support: join(url, support),
      marketing: join(url, marketing)
    )
  }

  private static func join(_ base: String, _ path: String) -> String {
    var head = Substring(base)
    while head.last == "/" {
      head = head.dropLast()
    }
    let tail = path.drop { $0 == "/" }
    return tail.isEmpty ? String(head) : "\(head)/\(tail)"
  }
}
