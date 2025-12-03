import AoCCommon
import Foundation

public struct Day03: DaySolver {
    public typealias ParsedData = [[Int]]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 3
    public let testInput = """
        987654321111111
        811111111111119
        234234234234278
        818181911112111
        """

    public let expectedTestResult1: Int? = 357
    public let expectedTestResult2: Int? = 3_121_910_778_619

    public func parse(input: String) -> [[Int]]? {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.compactMap(\.wholeNumberValue) }
    }

    private func maxJoltage(_ bank: [Int], selecting count: Int) -> Int {
        var result = 0
        var startIndex = 0

        for remaining in stride(from: count, through: 1, by: -1) {
            // Find the largest digit in the valid range [startIndex, bank.count - remaining]
            let searchRange = startIndex...(bank.count - remaining)
            let bestIndex = searchRange.max(by: { bank[$0] < bank[$1] })!

            result = result * 10 + bank[bestIndex]
            startIndex = bestIndex + 1
        }

        return result
    }

    public func solvePart1(data: [[Int]]) -> Int {
        data.map { maxJoltage($0, selecting: 2) }.sum()
    }

    public func solvePart2(data: [[Int]]) -> Int {
        data.map { maxJoltage($0, selecting: 12) }.sum()
    }
}
