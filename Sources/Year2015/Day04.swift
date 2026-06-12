import AoCCommon
import Crypto
import Foundation

/// Recommended running this in release mode
/// `swift run -c release`
public struct Day04: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 4
    public let testInput = "abcdef"
    public let expectedTestResult1: Result1? = 609043
    public let expectedTestResult2: Result2? = 6_742_839

    public func parse(input: String) throws -> String { input }

    private func findHash(key: String, zeros: Int) -> Int {
        let keyData = Array(key.utf8)
        let numCores = 8
        let batchSize = 50_000
        let fullBytes = zeros / 2
        let checkHalfByte = zeros % 2 == 1

        var round = 0
        while true {
            let roundStart = round * batchSize * numCores + 1
            nonisolated(unsafe) var localResults = [Int](repeating: Int.max, count: numCores)

            DispatchQueue.concurrentPerform(iterations: numCores) { core in
                let start = roundStart + core * batchSize
                let end = start + batchSize

                // Pre-allocate buffer: key bytes + max 7 digits for numbers up to ~10M
                var buffer = [UInt8](repeating: 0, count: keyData.count + 8)
                buffer.replaceSubrange(0..<keyData.count, with: keyData)

                for num in start..<end {
                    // Write number digits directly into buffer
                    let len = writeNumber(num, into: &buffer, at: keyData.count)
                    let totalLen = keyData.count + len

                    // Compute MD5 and check leading zeros without allocation
                    let digest = buffer.withUnsafeBufferPointer { ptr in
                        Insecure.MD5.hash(
                            data: UnsafeRawBufferPointer(
                                start: ptr.baseAddress, count: totalLen))
                    }
                    let valid = digest.withUnsafeBytes { bytes -> Bool in
                        let ptr = bytes.bindMemory(to: UInt8.self)
                        for i in 0..<fullBytes {
                            if ptr[i] != 0 { return false }
                        }
                        if checkHalfByte && ptr[fullBytes] >= 16 { return false }
                        return true
                    }

                    if valid {
                        localResults[core] = num
                        return
                    }
                }
            }

            let best = localResults.min()!
            if best != Int.max { return best }
            round += 1
        }
    }

    /// Writes the decimal digits of `num` into `buffer` starting at `offset`.
    /// Returns the number of digits written.
    @inline(__always)
    private func writeNumber(_ num: Int, into buffer: inout [UInt8], at offset: Int) -> Int {
        var n = num
        var count = 0
        var temp: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (
            0, 0, 0, 0, 0, 0, 0, 0
        )
        withUnsafeMutableBytes(of: &temp) { digits in
            while n > 0 {
                digits[count] = UInt8(n % 10) + 0x30
                n /= 10
                count += 1
            }
            for i in 0..<count {
                buffer[offset + i] = digits[count - 1 - i]
            }
        }
        return count
    }

    public func solvePart1(data: String) -> Int {
        findHash(key: data, zeros: 5)
    }

    public func solvePart2(data: String) -> Int {
        findHash(key: data, zeros: 6)
    }
}
