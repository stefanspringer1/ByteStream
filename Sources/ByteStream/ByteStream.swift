import Foundation

protocol ByteStream {
    mutating func get() throws -> UInt8?
}

struct FileByteStreamError: LocalizedError {

    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
    
    public var errorDescription: String? {
        return description
    }
}

struct FileByteStream: ByteStream {
    
    private let path: String
    private var fileHandle: FileHandle?
    private var readFromFile: Int = 0
    private var fileSize: Int
    private var chunkSize: Int
    
    private var buffer: Data? = nil
    private var readFromBuffer: Int = 0
    
    init(url: URL, withChunckSize chunkSize: Int? = nil) throws {
        try self.init(path: url.path())
    }
    
    init(path: String, withChunckSize chunkSize: Int? = nil) throws {
        
        self.path = path
        self.chunkSize = chunkSize ?? 1024
        
        let attr = try FileManager.default.attributesOfItem(atPath: path)
        fileSize = Int(attr[FileAttributeKey.size] as! UInt64)
        
        fileHandle = FileHandle(forReadingAtPath: path)
        if fileHandle == nil {
            throw FileByteStreamError("Could not open file [\(path)]")
        }
    }
    
    private mutating func close() {
        do { try fileHandle?.close() } catch {}
        fileHandle = nil
        buffer = nil
    }
    
    mutating func get() throws -> UInt8? {
        
        if let buffer, readFromBuffer < buffer.count {
            defer { readFromBuffer += 1 }
            return buffer[readFromBuffer]
        }
        
        guard let openFileHandle = fileHandle else { return nil }
        
        if readFromFile >= fileSize {
            close()
            return nil
        }
        
        let chunkSize = min(fileSize - readFromFile, self.chunkSize)
        buffer = openFileHandle.readData(ofLength: chunkSize)
        readFromFile += chunkSize
        readFromBuffer = 0
        
        if buffer == nil || buffer!.count != chunkSize {
            close()
            throw FileByteStreamError("Could not read from [\(path)]")
        }
        
        return try get()
    }
}

struct DataByteStream: ByteStream {
    
    private let data: Data
    private var index = 0
    
    init(data: Data) throws {
        self.data = data
    }
    
    mutating func get() throws -> UInt8? {
        guard index < data.count else { return nil }
        let byte = data[index]
        index += 1
        return byte
    }
}

struct TextByteStreamError: LocalizedError {

    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
    
    public var errorDescription: String? {
        return description
    }
}

struct TextByteStream: ByteStream {
    
    private let data: Data
    private var index = 0
    
    init(text: String) throws {
        let data = text.data(using: .utf8)
        if let data {
            self.data = data
        } else {
            throw TextByteStreamError("Could not read text as data")
        }
    }
    
    mutating func get() throws -> UInt8? {
        guard index < data.count else { return nil }
        let byte = data[index]
        index += 1
        return byte
    }
}
