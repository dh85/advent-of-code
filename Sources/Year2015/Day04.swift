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

    public func parse(input: String) -> String? { input }

    private func hasLeadingZeros(_ hash: [UInt8], count: Int) -> Bool {
        for i in 0..<count / 2 where hash[i] != 0 { return false }
        return count % 2 == 0 || hash[count / 2] < 16
    }

    private func findHash(key: String, zeros: Int) -> Int {
        let keyData = Array(key.utf8)
        let numCores = 8
        let batchSize = 10000
        nonisolated(unsafe) var result = Int.max
        let lock = NSLock()
        let fullBytes = zeros / 2
        let checkHalfByte = zeros % 2 == 1

        DispatchQueue.concurrentPerform(iterations: numCores) { core in
            var batch = 0
            while true {
                lock.lock()
                let shouldStop = result != Int.max
                lock.unlock()
                if shouldStop { return }

                let start = batch * batchSize * numCores + core * batchSize + 1
                let end = start + batchSize

                for num in start..<end {
                    var input = Data(keyData)
                    input.append(contentsOf: String(num).utf8)
                    let hash = Array(Insecure.MD5.hash(data: input))

                    // Inline check for leading zeros
                    var valid = true
                    for i in 0..<fullBytes where hash[i] != 0 {
                        valid = false
                        break
                    }
                    if valid && checkHalfByte && hash[fullBytes] >= 16 { valid = false }

                    if valid {
                        lock.lock()
                        if num < result { result = num }
                        lock.unlock()
                        return
                    }
                }
                batch += 1
            }
        }

        return result
    }

    public func solvePart1(data: String) -> Int {
        findHash(key: data, zeros: 5)
    }

    public func solvePart2(data: String) -> Int {
        findHash(key: data, zeros: 6)
    }
}
