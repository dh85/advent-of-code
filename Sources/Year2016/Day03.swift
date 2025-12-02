import AoCCommon
import Foundation

public struct Day03: DaySolver {
    public typealias ParsedData = [[Int]]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 3
    public let testInput = """
        5 10 25
        3 4 5
        10 15 20
        """

    public func parse(input: String) -> [[Int]]? {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map(\.integers)
    }

    private func isValidTriangle(_ sides: [Int]) -> Bool {
        let sorted = sides.sorted()
        return sorted[0] + sorted[1] > sorted[2]
    }

    private func trianglesByRows(_ data: [[Int]]) -> [[Int]] {
        data
    }

    private func trianglesByColumns(_ data: [[Int]]) -> [[Int]] {
        stride(from: 0, to: data.count, by: 3).flatMap { i -> [[Int]] in
            guard i + 2 < data.count else { return [] }
            return (0..<3).map { col in
                [data[i][col], data[i + 1][col], data[i + 2][col]]
            }
        }
    }

    public func solvePart1(data: [[Int]]) -> Int {
        trianglesByRows(data).filter(isValidTriangle).count
    }

    public func solvePart2(data: [[Int]]) -> Int {
        trianglesByColumns(data).filter(isValidTriangle).count
    }
}
