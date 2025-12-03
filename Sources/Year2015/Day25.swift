import AoCCommon
import Foundation

public struct Day25: DaySolver {
    public struct Position: Equatable {
        let row: Int
        let col: Int
    }

    public typealias ParsedData = Position
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 25
    public let testInput =
        "To continue, please consult the code grid in the manual.  Enter the code at row 4, column 2."
    public let expectedTestResult1: Result1? = 32_451_966
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) -> Position? {
        let numbers = input.integers
        guard numbers.count >= 2 else { return nil }
        return Position(row: numbers[0], col: numbers[1])
    }

    public func solvePart1(data: Position) -> Int {
        let d = data.row + data.col - 1
        let index = d * (d - 1) / 2 + data.col
        var code = 20_151_125

        for _ in 1..<index {
            code = (code * 252533) % 33_554_393
        }

        return code
    }

    public func solvePart2(data: Position) -> Int {
        // Part 2 is automatically completed when all other puzzles are solved
        0
    }
}
