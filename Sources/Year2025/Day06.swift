import AoCCommon
import BigInt

public struct Day06: DaySolver {
    struct Problem: Equatable {
        let numbers: [Int]
        let operation: Character

        func solve() -> BigInt {
            let bigNums = numbers.map { BigInt($0) }
            return operation == "+" ? bigNums.reduce(0, +) : bigNums.reduce(1, *)
        }
    }

    public typealias ParsedData = String
    public typealias Result1 = String
    public typealias Result2 = String

    public let expectedTestResult1: Result1? = "4277556"
    public let expectedTestResult2: Result2? = "3263827"

    public init() {}

    public let day = 6
    public let testInput = """
        123 328  51 64 
         45 64  387 23 
          6 98  215 314
        *   +   *   +  
        """

    public func parse(input: String) throws -> String { input }

    public func solvePart1(data: String) -> String {
        String(parsePart1(data).map { $0.solve() }.reduce(0, +))
    }

    public func solvePart2(data: String) -> String {
        String(parsePart2(data).map { $0.solve() }.reduce(0, +))
    }

    private func parsePart1(_ input: String) -> [Problem] {
        let lines = input.split(separator: "\n").map { String($0) }
        guard lines.count > 1 else { return [] }

        let numberRows = lines.dropLast().map { $0.split(separator: " ").map { String($0) } }
        let operations = lines.last!.split(separator: " ").map { String($0) }

        return operations.enumerated().compactMap { i, op in
            guard op == "+" || op == "*" else { return nil }
            let numbers = numberRows.compactMap { Int($0[safe: i] ?? "") }
            guard !numbers.isEmpty else { return nil }
            return Problem(numbers: numbers, operation: Character(op))
        }
    }

    private func parsePart2(_ input: String) -> [Problem] {
        let lines = input.split(separator: "\n").map { String($0) }
        guard lines.count > 1 else { return [] }

        let numberRows = Array(lines.dropLast())
        let opRow = String(lines.last!)
        let maxWidth = lines.map { $0.count }.max() ?? 0

        var problems: [Problem] = []
        var col = maxWidth - 1

        while col >= 0 {
            defer { col -= 1 }
            guard col < opRow.count else { continue }
            let opChar = opRow[opRow.index(opRow.startIndex, offsetBy: col)]
            guard opChar == "+" || opChar == "*" else { continue }

            var numbers: [Int] = []
            for c in col..<maxWidth {
                if c > col {
                    let nextOp =
                        c < opRow.count ? opRow[opRow.index(opRow.startIndex, offsetBy: c)] : " "
                    if nextOp == "+" || nextOp == "*" { break }
                }

                let digits = numberRows.compactMap { row -> Int? in
                    guard c < row.count else { return nil }
                    let char = row[row.index(row.startIndex, offsetBy: c)]
                    return char.isNumber ? Int(String(char)) : nil
                }
                if !digits.isEmpty {
                    numbers.append(digits.reduce(0) { $0 * 10 + $1 })
                }
            }

            if !numbers.isEmpty {
                problems.append(Problem(numbers: numbers.reversed(), operation: opChar))
            }
        }

        return problems
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
