import AoCCommon
import Foundation

public struct Day06: DaySolver {
    public enum Action: Equatable {
        case turnOn, turnOff, toggle
    }

    public struct Instruction: Equatable {
        let action: Action
        let x1, y1, x2, y2: Int
    }

    public typealias ParsedData = [Instruction]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 6
    public let testInput = """
        turn on 0,0 through 999,999
        toggle 0,0 through 999,0
        turn off 499,499 through 500,500
        """
    public let expectedTestResult1: Result1? = 998996
    public let expectedTestResult2: Result2? = 1_001_996

    public func parse(input: String) -> [Instruction]? {
        input.lines.compactMap { line -> Instruction? in
            let pattern = /(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/
            guard let match = line.firstMatch(of: pattern) else { return nil }
            let action: Action =
                switch match.1 {
                case "turn on": .turnOn
                case "turn off": .turnOff
                default: .toggle
                }
            return Instruction(
                action: action,
                x1: Int(match.2)!, y1: Int(match.3)!,
                x2: Int(match.4)!, y2: Int(match.5)!
            )
        }
    }

    public func solvePart1(data: [Instruction]) -> Int {
        var grid = [Bool](repeating: false, count: 1_000_000)
        for inst in data {
            for y in inst.y1...inst.y2 {
                let rowStart = y * 1000
                for x in inst.x1...inst.x2 {
                    let idx = rowStart + x
                    switch inst.action {
                    case .turnOn: grid[idx] = true
                    case .turnOff: grid[idx] = false
                    case .toggle: grid[idx].toggle()
                    }
                }
            }
        }
        return grid.count { $0 }
    }

    public func solvePart2(data: [Instruction]) -> Int {
        var grid = [Int](repeating: 0, count: 1_000_000)
        for inst in data {
            for y in inst.y1...inst.y2 {
                let rowStart = y * 1000
                for x in inst.x1...inst.x2 {
                    let idx = rowStart + x
                    switch inst.action {
                    case .turnOn: grid[idx] += 1
                    case .turnOff: grid[idx] = max(0, grid[idx] - 1)
                    case .toggle: grid[idx] += 2
                    }
                }
            }
        }
        return grid.sum()
    }
}
