import AoCCommon
import Crypto
import Foundation
import Synchronization

public struct Day05: DaySolver, Sendable {
    public typealias ParsedData = [UInt8]
    public typealias Result1 = String
    public typealias Result2 = String

    public let expectedTestResult1: Result1? = "18f47a30"
    public let expectedTestResult2: Result2? = "05ace8e3"

    public init() {}

    public let day = 5
    public let testInput = "abc"

    private static let hexChars: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
    ]

    public func parse(input: String) throws -> [UInt8] {
        Array(input.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
    }

    private static let numThreads = ProcessInfo.processInfo.activeProcessorCount
    private static let batchSize = 500_000

    private static func findMatchesInRange(data: [UInt8], start: Int, end: Int) -> [(
        index: Int, b2: Int, b3: Int
    )] {
        var matches: [(index: Int, b2: Int, b3: Int)] = []
        let baseLen = data.count
        var input = data + [UInt8](repeating: 0, count: 10)

        input.withUnsafeMutableBufferPointer { buf in
            for index in start..<end {
                // Fast integer to ASCII conversion - no reversing needed
                var temp = index
                var len = baseLen

                if temp >= 100_000_000 {
                    buf[len] = UInt8(temp / 100_000_000) + 0x30
                    temp %= 100_000_000
                    len += 1
                }
                if temp >= 10_000_000 || len > baseLen {
                    buf[len] = UInt8(temp / 10_000_000) + 0x30
                    temp %= 10_000_000
                    len += 1
                }
                if temp >= 1_000_000 || len > baseLen {
                    buf[len] = UInt8(temp / 1_000_000) + 0x30
                    temp %= 1_000_000
                    len += 1
                }
                if temp >= 100_000 || len > baseLen {
                    buf[len] = UInt8(temp / 100_000) + 0x30
                    temp %= 100_000
                    len += 1
                }
                if temp >= 10_000 || len > baseLen {
                    buf[len] = UInt8(temp / 10_000) + 0x30
                    temp %= 10_000
                    len += 1
                }
                if temp >= 1_000 || len > baseLen {
                    buf[len] = UInt8(temp / 1_000) + 0x30
                    temp %= 1_000
                    len += 1
                }
                if temp >= 100 || len > baseLen {
                    buf[len] = UInt8(temp / 100) + 0x30
                    temp %= 100
                    len += 1
                }
                if temp >= 10 || len > baseLen {
                    buf[len] = UInt8(temp / 10) + 0x30
                    temp %= 10
                    len += 1
                }
                buf[len] = UInt8(temp) + 0x30
                len += 1

                var hasher = Insecure.MD5()
                hasher.update(
                    bufferPointer: UnsafeRawBufferPointer(start: buf.baseAddress, count: len))
                let hash = hasher.finalize()
                var iter = hash.makeIterator()
                let b0 = iter.next()!
                let b1 = iter.next()!
                let b2 = iter.next()!
                let b3 = iter.next()!

                if b0 == 0 && b1 == 0 && b2 < 16 {
                    matches.append((index, Int(b2), Int(b3)))
                }
            }
        }
        return matches
    }

    private static func processBatch(data: [UInt8], batchStart: Int) -> [(
        index: Int, b2: Int, b3: Int
    )] {
        let numThreads = Self.numThreads
        let rangeSize = batchSize / numThreads
        let batchEnd = batchStart + batchSize
        let results = Mutex<[[(index: Int, b2: Int, b3: Int)]]>(
            Array(repeating: [], count: numThreads))

        DispatchQueue.concurrentPerform(iterations: numThreads) { threadIdx in
            let start = batchStart + threadIdx * rangeSize
            let end = threadIdx == numThreads - 1 ? batchEnd : start + rangeSize
            let matches = findMatchesInRange(data: data, start: start, end: end)
            results.withLock { $0[threadIdx] = matches }
        }

        return results.withLock { $0.flatMap { $0 }.sorted { $0.index < $1.index } }
    }

    public func solvePart1(data: [UInt8]) -> String {
        var password = ""
        var searchIndex = 0

        while password.count < 8 {
            let matches = Self.processBatch(data: data, batchStart: searchIndex)
            for match in matches {
                if password.count < 8 {
                    password.append(Self.hexChars[match.b2 & 0x0F])
                }
            }
            searchIndex += Self.batchSize
        }

        return password
    }

    public func solvePart2(data: [UInt8]) -> String {
        var password: [Character?] = Array(repeating: nil, count: 8)
        var filled = 0
        var searchIndex = 0

        while filled < 8 {
            let matches = Self.processBatch(data: data, batchStart: searchIndex)
            for match in matches {
                let position = match.b2 & 0x0F
                if position < 8 && password[position] == nil {
                    password[position] = Self.hexChars[match.b3 >> 4]
                    filled += 1
                }
            }
            searchIndex += Self.batchSize
        }

        return String(password.compactMap { $0 })
    }
}
