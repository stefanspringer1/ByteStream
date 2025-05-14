import Testing
@testable import ByteStream
import Foundation

let testFile = URL(fileURLWithPath: "/Users/stefan/Projekte/GPX/ditr.xml")

func time(functionName: String = #function, _ f: () throws -> ()) rethrows -> TimeInterval {
    let startPoint = Date()
    try f()
    return Date().timeIntervalSince(startPoint)
}

@Test func testReadFileAsStream() throws {
    var count = 0
    let duration = try time {
        var byteStream = try FileByteStream(url: testFile)
        while let byte = try byteStream.get() {
            //                print(String(UnicodeScalar(Int(byte))!), terminator: "")
            count += 1
        }
    }
    print("\(count) bytes read in \(duration) s")
}

@Test func testTextAsStream() throws {
    var count = 0
    let duration = try time {
        let text = try String(contentsOf: testFile, encoding: .utf8)
        var byteStream = try TextByteStream(text: text)
        while let byte = try byteStream.get() {
            //                print(String(UnicodeScalar(Int(byte))!), terminator: "")
            count += 1
        }
    }
    print("\(count) bytes read in \(duration) s")
}

@Test func testDataAsStream() throws {
    var count = 0
    let duration = try time {
        let data = try Data(contentsOf: testFile)
        var byteStream = try DataByteStream(data: data)
        while let byte = try byteStream.get() {
            //                print(String(UnicodeScalar(Int(byte))!), terminator: "")
            count += 1
        }
    }
    print("\(count) bytes read in \(duration) s")
}

@Test func testCompare() throws {
    try testReadFileAsStream()
    try testTextAsStream()
    try testDataAsStream()
}
