import AoCCommon
import Foundation

public struct Day25: DaySolver {
    public typealias ParsedData = (row: Int, col: Int)
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 25
    public let testInput =
        "To continue, please consult the code grid in the manual.  Enter the code at row 4, column 2."
    public let expectedTestResult1: Result1? = 32_451_966
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) throws -> ParsedData {
        let numbers = input.integers
        guard numbers.count >= 2 else { throw ParseError.invalidInput }
        return (row: numbers[0], col: numbers[1])
    }

    public func solvePart1(data: ParsedData) -> Int {
        let d = data.row + data.col - 1
        let index = d * (d - 1) / 2 + data.col
        let base = 252533
        let mod = 33_554_393
        return 20_151_125 * modPow(base, index - 1, mod) % mod
    }

    private func modPow(_ base: Int, _ exp: Int, _ mod: Int) -> Int {
        var result = 1
        var b = base % mod
        var e = exp
        while e > 0 {
            if e & 1 == 1 { result = result * b % mod }
            b = b * b % mod
            e >>= 1
        }
        return result
    }

    public func solvePart2(data: ParsedData) -> Int {
        // Part 2 is automatically completed when all other puzzles are solved
        0
    }
}
