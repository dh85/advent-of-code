import AoCCommon
import Foundation

public struct Day02: DaySolver {
    public typealias ParsedData = [[Character]]
    public typealias Result1 = String
    public typealias Result2 = String

    public init() {}

    public let day = 2
    public let testInput = """
        ULL
        RRDDD
        LURDL
        UUUUD
        """

    public func parse(input: String) -> [[Character]]? {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { Array($0) }
    }

    private struct Keypad {
        let buttons: [[String]]
        let startRow: Int
        let startCol: Int

        static let standard = Keypad(
            buttons: [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
            ],
            startRow: 1,
            startCol: 1
        )

        static let diamond = Keypad(
            buttons: [
                ["", "", "1", "", ""],
                ["", "2", "3", "4", ""],
                ["5", "6", "7", "8", "9"],
                ["", "A", "B", "C", ""],
                ["", "", "D", "", ""],
            ],
            startRow: 2,
            startCol: 0
        )

        func isValid(row: Int, col: Int) -> Bool {
            row >= 0 && row < buttons.count
                && col >= 0 && col < buttons[row].count
                && !buttons[row][col].isEmpty
        }

        func button(at row: Int, col: Int) -> Character {
            Character(buttons[row][col])
        }
    }

    private struct Position {
        var row: Int
        var col: Int

        mutating func move(_ direction: Character, keypad: Keypad) {
            let (newRow, newCol): (Int, Int)

            switch direction {
            case "U": (newRow, newCol) = (row - 1, col)
            case "D": (newRow, newCol) = (row + 1, col)
            case "L": (newRow, newCol) = (row, col - 1)
            case "R": (newRow, newCol) = (row, col + 1)
            default: return
            }

            if keypad.isValid(row: newRow, col: newCol) {
                row = newRow
                col = newCol
            }
        }
    }

    private func solve(data: [[Character]], keypad: Keypad) -> String {
        var position = Position(row: keypad.startRow, col: keypad.startCol)

        return data.map { line in
            line.forEach { position.move($0, keypad: keypad) }
            return keypad.button(at: position.row, col: position.col)
        }.map(String.init).joined()
    }

    public func solvePart1(data: [[Character]]) -> String {
        solve(data: data, keypad: .standard)
    }

    public func solvePart2(data: [[Character]]) -> String {
        solve(data: data, keypad: .diamond)
    }
}
