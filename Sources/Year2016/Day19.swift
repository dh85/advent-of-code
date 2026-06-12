import AoCCommon

public struct Day19: DaySolver {
    public typealias ParsedData = Int
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 19
    public let testInput = "5"
    public let expectedTestResult1: Result1? = 3
    public let expectedTestResult2: Result2? = 2

    public func parse(input: String) throws -> Int {
        guard let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ParseError.invalidInput
        }
        return value
    }

    // Josephus problem with k=2: winner = 2*L + 1 where n = 2^m + L
    // Equivalently: rotate the binary representation left by 1
    public func solvePart1(data: Int) -> Int {
        // Find highest power of 2 <= n
        let highBit = 1 << (Int.bitWidth - 1 - data.leadingZeroBitCount)
        // L = n - highBit, answer = 2*L + 1
        return 2 * (data - highBit) + 1
    }

    // Part 2: Steal from elf directly across (n/2 positions away)
    // Formula based on powers of 3
    public func solvePart2(data: Int) -> Int {
        // Find highest power of 3 <= n
        var p = 1
        while p * 3 <= data {
            p *= 3
        }

        // If n == p (exact power of 3), winner is n
        if data == p {
            return data
        }

        // If n <= 2*p, winner is n - p
        if data <= 2 * p {
            return data - p
        }

        // Otherwise, winner is 2*n - 3*p
        return 2 * data - 3 * p
    }
}
