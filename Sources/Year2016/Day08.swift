import AoCCommon

public struct Day08: DaySolver {
    public enum Instruction: Equatable {
        case rect(width: Int, height: Int)
        case rotateRow(y: Int, by: Int)
        case rotateColumn(x: Int, by: Int)
    }

    public typealias ParsedData = [Instruction]
    public typealias Result1 = Int
    public typealias Result2 = String

    public init() {}

    public let day = 8
    public let testInput = """
        rect 3x2
        rotate column x=1 by 1
        rotate row y=0 by 4
        rotate column x=1 by 1
        """
    public let expectedTestResult1: Result1? = 6
    public let expectedTestResult2: Result2? = nil  // Test input doesn't form letters

    // 5x6 OCR font - each letter encoded as a 30-bit integer (5 cols × 6 rows, row-major)
    private static let letterPatterns: [UInt32: Character] = [
        0b01100_10010_10010_11110_10010_10010: "A",
        0b11100_10010_11100_10010_10010_11100: "B",
        0b01100_10010_10000_10000_10010_01100: "C",
        0b11110_10000_11100_10000_10000_11110: "E",
        0b11110_10000_11100_10000_10000_10000: "F",
        0b01100_10010_10000_10110_10010_01110: "G",
        0b10010_10010_11110_10010_10010_10010: "H",
        0b00110_00010_00010_00010_10010_01100: "J",
        0b10010_10100_11000_10100_10100_10010: "K",
        0b10000_10000_10000_10000_10000_11110: "L",
        0b01100_10010_10010_10010_10010_01100: "O",
        0b11100_10010_10010_11100_10000_10000: "P",
        0b11100_10010_10010_11100_10100_10010: "R",
        0b01110_10000_10000_01100_00010_11100: "S",
        0b10010_10010_10010_10010_10010_01100: "U",
        0b10001_10001_01010_00100_00100_00100: "Y",
        0b11110_00010_00100_01000_10000_11110: "Z",
    ]

    public func parse(input: String) -> [Instruction]? {
        input.lines.compactMap { line -> Instruction? in
            let nums = line.integers
            if line.hasPrefix("rect") {
                return .rect(width: nums[0], height: nums[1])
            } else if line.contains("row") {
                return .rotateRow(y: nums[0], by: nums[1])
            } else if line.contains("column") {
                return .rotateColumn(x: nums[0], by: nums[1])
            }
            return nil
        }
    }

    private func simulate(_ data: [Instruction], width: Int = 50, height: Int = 6) -> [[Bool]] {
        var screen = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)

        for instruction in data {
            switch instruction {
            case .rect(let w, let h):
                for y in 0..<h {
                    for x in 0..<w {
                        screen[y][x] = true
                    }
                }

            case .rotateRow(let y, let by):
                let row = screen[y]
                for x in 0..<width {
                    screen[y][(x + by) % width] = row[x]
                }

            case .rotateColumn(let x, let by):
                let column = (0..<height).map { screen[$0][x] }
                for y in 0..<height {
                    screen[(y + by) % height][x] = column[y]
                }
            }
        }

        return screen
    }

    private func decodeScreen(_ screen: [[Bool]]) -> String {
        let charWidth = 5
        let numChars = screen[0].count / charWidth

        return (0..<numChars).map { charIndex in
            let startX = charIndex * charWidth
            var bits: UInt32 = 0

            for y in 0..<6 {
                for x in 0..<charWidth {
                    bits = (bits << 1) | (screen[y][startX + x] ? 1 : 0)
                }
            }

            return Self.letterPatterns[bits] ?? "?"
        }.map(String.init).joined()
    }

    public func solvePart1(data: [Instruction]) -> Int {
        simulate(data).flatMap { $0 }.count { $0 }
    }

    public func solvePart2(data: [Instruction]) -> String {
        decodeScreen(simulate(data))
    }
}
