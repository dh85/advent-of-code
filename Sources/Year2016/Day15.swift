import AoCCommon
import Foundation

public struct Day15: DaySolver {
    public typealias ParsedData = [(positions: Int, start: Int)]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 15
    public let testInput = """
        Disc #1 has 5 positions; at time=0, it is at position 4.
        Disc #2 has 2 positions; at time=0, it is at position 1.
        """
    public let expectedTestResult1: Result1? = 5
    public let expectedTestResult2: Result2? = nil  // Part 2 adds a disc, test doesn't apply

    public func parse(input: String) throws -> ParsedData {
        // "Disc #1 has 5 positions; at time=0, it is at position 4."
        input.lines.compactMap { line -> (positions: Int, start: Int)? in
            let numbers = line.integers
            guard numbers.count >= 4 else { return nil }
            return (positions: numbers[1], start: numbers[3])
        }
    }

    // Find first time t where all discs align at position 0
    // For disc i (1-indexed): (start_i + t + i) % positions_i == 0
    private func findAlignmentTime(discs: ParsedData) -> Int {
        var t = 0
        var step = 1

        for (index, disc) in discs.enumerated() {
            let discNum = index + 1
            while (disc.start + t + discNum) % disc.positions != 0 {
                t += step
            }
            step = lcm(step, disc.positions)
        }

        return t
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    private func lcm(_ a: Int, _ b: Int) -> Int {
        a / gcd(a, b) * b
    }

    public func solvePart1(data: ParsedData) -> Int {
        findAlignmentTime(discs: data)
    }

    public func solvePart2(data: ParsedData) -> Int {
        var discs = data
        discs.append((positions: 11, start: 0))
        return findAlignmentTime(discs: discs)
    }
}
