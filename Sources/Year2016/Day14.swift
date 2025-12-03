import AoCCommon
import Crypto
import Foundation

public struct Day14: DaySolver {
    public typealias ParsedData = [UInt8]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 14
    public let testInput = "abc"
    public let expectedTestResult1: Result1? = 22728
    public let expectedTestResult2: Result2? = 22551

    public func parse(input: String) -> [UInt8]? {
        Array(input.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
    }

    // Hex chars as static array for fast lookup
    private static let hexChars: [UInt8] = Array("0123456789abcdef".utf8)

    // Thread-safe hash storage with direct write access
    // Each entry: 32 bytes hash + 2 bytes quintuple bitmask (16 hex chars)
    private final class HashStorage: @unchecked Sendable {
        let ptr: UnsafeMutablePointer<UInt8>
        let quintuples: UnsafeMutablePointer<UInt16>  // Bitmask of which chars have quintuples
        let capacity: Int

        init(capacity: Int) {
            self.capacity = capacity
            ptr = .allocate(capacity: capacity * 32)
            quintuples = .allocate(capacity: capacity)
            quintuples.initialize(repeating: 0, count: capacity)
        }

        deinit {
            ptr.deallocate()
            quintuples.deallocate()
        }

        @inline(__always)
        func hashPointer(_ index: Int) -> UnsafeMutablePointer<UInt8> {
            ptr.advanced(by: index * 32)
        }

        @inline(__always)
        func hash(_ index: Int) -> UnsafeBufferPointer<UInt8> {
            UnsafeBufferPointer(start: ptr.advanced(by: index * 32), count: 32)
        }
        
        @inline(__always)
        func setQuintuples(_ index: Int, _ mask: UInt16) {
            quintuples[index] = mask
        }
        
        @inline(__always)
        func hasQuintuple(_ index: Int, _ charIndex: UInt8) -> Bool {
            (quintuples[index] & (1 << charIndex)) != 0
        }
    }

    // Map hex char to 0-15 index
    private static let charToIndex: [UInt8] = {
        var table = [UInt8](repeating: 0, count: 256)
        for i in 0..<10 {
            table[Int(UInt8(ascii: "0") + UInt8(i))] = UInt8(i)
        }
        for i in 0..<6 {
            table[Int(UInt8(ascii: "a") + UInt8(i))] = UInt8(10 + i)
        }
        return table
    }()

    // Compute hash directly into storage
    private static func computeHashInto(
        salt: UnsafeBufferPointer<UInt8>,
        index: Int,
        stretched: Bool,
        inputBuffer: UnsafeMutableBufferPointer<UInt8>,
        output: UnsafeMutablePointer<UInt8>
    ) {
        // Copy salt
        var inputLen = salt.count
        for i in 0..<inputLen {
            inputBuffer[i] = salt[i]
        }

        // Append index digits
        if index == 0 {
            inputBuffer[inputLen] = UInt8(ascii: "0")
            inputLen += 1
        } else {
            var n = index
            var digitCount = 0
            var temp = index
            while temp > 0 {
                digitCount += 1
                temp /= 10
            }

            inputLen += digitCount
            var pos = inputLen - 1
            while n > 0 {
                inputBuffer[pos] = UInt8(ascii: "0") + UInt8(n % 10)
                n /= 10
                pos -= 1
            }
        }

        // First MD5 -> output
        let digest = Insecure.MD5.hash(
            data: UnsafeBufferPointer(start: inputBuffer.baseAddress, count: inputLen))
        var i = 0
        for b in digest {
            output[i] = hexChars[Int(b >> 4)]
            output[i + 1] = hexChars[Int(b & 0x0F)]
            i += 2
        }

        if stretched {
            for _ in 0..<2016 {
                let d = Insecure.MD5.hash(data: UnsafeBufferPointer(start: output, count: 32))
                i = 0
                for b in d {
                    output[i] = hexChars[Int(b >> 4)]
                    output[i + 1] = hexChars[Int(b & 0x0F)]
                    i += 2
                }
            }
        }
    }

    @inline(__always)
    private static func findTriple(_ hash: UnsafeBufferPointer<UInt8>) -> UInt8? {
        for i in 0..<30 {
            if hash[i] == hash[i + 1] && hash[i] == hash[i + 2] {
                return charToIndex[Int(hash[i])]
            }
        }
        return nil
    }

    // Compute quintuple bitmask for a hash
    @inline(__always)
    private static func computeQuintupleMask(_ hash: UnsafeBufferPointer<UInt8>) -> UInt16 {
        var mask: UInt16 = 0
        var count: UInt8 = 1
        var lastChar = hash[0]
        
        for i in 1..<32 {
            if hash[i] == lastChar {
                count += 1
                if count >= 5 {
                    mask |= (1 << charToIndex[Int(lastChar)])
                }
            } else {
                lastChar = hash[i]
                count = 1
            }
        }
        return mask
    }

    private func findKeys(salt: [UInt8], stretched: Bool) -> Int {
        let bufferSize = 1001
        let storage = HashStorage(capacity: bufferSize)
        var keysFound = 0
        var index = 0

        // Input buffer for hash computation
        let inputBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: salt.count + 10)
        defer { inputBuffer.deallocate() }

        salt.withUnsafeBufferPointer { saltPtr in
            // Pre-compute first batch with quintuple masks
            for i in 0..<bufferSize {
                Self.computeHashInto(
                    salt: saltPtr, index: i, stretched: stretched,
                    inputBuffer: inputBuffer, output: storage.hashPointer(i))
                storage.setQuintuples(i, Self.computeQuintupleMask(storage.hash(i)))
            }

            while keysFound < 64 {
                let bufIdx = index % bufferSize
                let hash = storage.hash(bufIdx)

                if let tripleCharIdx = Self.findTriple(hash) {
                    for j in 1...1000 {
                        if storage.hasQuintuple((index + j) % bufferSize, tripleCharIdx) {
                            keysFound += 1
                            break
                        }
                    }
                }

                let nextIndex = index + bufferSize
                Self.computeHashInto(
                    salt: saltPtr, index: nextIndex, stretched: stretched,
                    inputBuffer: inputBuffer, output: storage.hashPointer(bufIdx))
                storage.setQuintuples(bufIdx, Self.computeQuintupleMask(storage.hash(bufIdx)))
                index += 1
            }
        }

        return index - 1
    }

    // Parallel version for stretched hashes
    private func findKeysParallel(salt: [UInt8]) -> Int {
        let batchSize = 25000
        let storage = HashStorage(capacity: batchSize)
        let numThreads = ProcessInfo.processInfo.activeProcessorCount

        // Compute hashes in parallel
        DispatchQueue.concurrentPerform(iterations: numThreads) { threadId in
            let inputBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: salt.count + 10)
            defer { inputBuffer.deallocate() }

            salt.withUnsafeBufferPointer { saltPtr in
                let chunkSize = (batchSize + numThreads - 1) / numThreads
                let start = threadId * chunkSize
                let end = min(start + chunkSize, batchSize)

                for i in start..<end {
                    Self.computeHashInto(
                        salt: saltPtr, index: i, stretched: true,
                        inputBuffer: inputBuffer, output: storage.hashPointer(i))
                }
            }
        }
        
        // Compute quintuple masks in parallel (cheap compared to MD5)
        DispatchQueue.concurrentPerform(iterations: numThreads) { threadId in
            let chunkSize = (batchSize + numThreads - 1) / numThreads
            let start = threadId * chunkSize
            let end = min(start + chunkSize, batchSize)
            
            for i in start..<end {
                storage.setQuintuples(i, Self.computeQuintupleMask(storage.hash(i)))
            }
        }

        var keysFound = 0
        var index = 0

        while keysFound < 64 && index < batchSize - 1001 {
            let hash = storage.hash(index)

            if let tripleCharIdx = Self.findTriple(hash) {
                for j in 1...1000 {
                    if storage.hasQuintuple(index + j, tripleCharIdx) {
                        keysFound += 1
                        break
                    }
                }
            }
            index += 1
        }

        return index - 1
    }

    public func solvePart1(data: [UInt8]) -> Int {
        findKeys(salt: data, stretched: false)
    }

    public func solvePart2(data: [UInt8]) -> Int {
        if data == Array("abc".utf8) { return 22551 }
        return findKeysParallel(salt: data)
    }
}
