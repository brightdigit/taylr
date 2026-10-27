import Foundation
import Testing

@testable import TaylrDescription

@Suite("Header")
internal enum HeaderTests {
  @Suite("file(_:)")
  internal struct FileTests {
    @Test("file keeps its path")
    internal func keepsPath() {
      #expect(FileHeader.file(HeaderTests.path).path == HeaderTests.path)
    }

    @Test("file serializes as its path")
    internal func serializesAsPath() {
      #expect(FileHeader.file(HeaderTests.path).serialization == .file(path: HeaderTests.path))
    }

    @Test("An optional header parameter takes file, nil, or a default")
    internal func optionalParameter() {
      func serialize(_ header: (any Header)? = .file("Scripts/header.mustache"))
        -> HeaderSerialization?
      {
        header?.serialization
      }
      #expect(serialize(.file(HeaderTests.path)) == .file(path: HeaderTests.path))
      #expect(serialize(nil) == nil)
      #expect(serialize() == .file(path: "Scripts/header.mustache"))
    }
  }

  @Suite("serializesEqually(_:_:)")
  internal struct SerializesEquallyTests {
    /// A second header type, to compare across conforming types.
    internal struct TemplateHeader: Header {
      internal let template: String
      internal var serialization: HeaderSerialization { .file(path: template) }
    }

    @Test("Two file headers with the same path serialize equally")
    internal func sameType() {
      let header = FileHeader.file(HeaderTests.path)
      #expect(FileHeader.serializesEqually(header, FileHeader.file(HeaderTests.path)))
      #expect(!FileHeader.serializesEqually(header, FileHeader.file("Scripts/other")))
    }

    @Test("Headers of different types with the same template serialize equally")
    internal func differentTypes() {
      let template = TemplateHeader(template: HeaderTests.path)
      #expect(FileHeader.serializesEqually(FileHeader.file(HeaderTests.path), template))
      #expect(!FileHeader.serializesEqually(FileHeader.file("Scripts/other"), template))
    }

    @Test("Two existential headers compare once the first is opened")
    internal func existentials() {
      let headers: [any Header] = [
        FileHeader.file(HeaderTests.path), TemplateHeader(template: HeaderTests.path),
      ]
      func compare(_ lhs: some Header, _ rhs: any Header) -> Bool {
        lhs.serialization == rhs.serialization
      }
      let same = compare(headers[0], headers[1])
      #expect(same)
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    @Test("file encodes its path under a labeled key")
    internal func encodesLabeled() throws {
      let data = try JSONEncoder().encode(HeaderSerialization.file(path: "a"))
      #expect(String(decoding: data, as: UTF8.self) == #"{"file":{"path":"a"}}"#)
    }

    @Test("file keeps its path through a round trip")
    internal func fileRoundTrips() throws {
      let header = FileHeader.file(HeaderTests.path).serialization
      let data = try JSONEncoder().encode(header)
      #expect(try JSONDecoder().decode(HeaderSerialization.self, from: data) == header)
    }

    @Test("An optional header round-trips both as nil and as a file")
    internal func optionalRoundTrips() throws {
      let headers: [HeaderSerialization?] = [nil, .file(path: HeaderTests.path)]
      let data = try JSONEncoder().encode(headers)
      #expect(try JSONDecoder().decode([HeaderSerialization?].self, from: data) == headers)
    }
  }

  private static let path = "Scripts/our-header.mustache"
}
