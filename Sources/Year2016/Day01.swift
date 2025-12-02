import AoCCommon
import Foundation

public struct Day01: DaySolver {
    public enum Turn: Character {
        case left = "L"
        case right = "R"
    }

    public struct Instruction: Equatable {
        public let turn: Turn
        public let blocks: Int
    }

    public typealias ParsedData = [Instruction]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 1
    public let testInput = """
        R8, R4, R4, R8
        """

    public func parse(input: String) -> [Instruction]? {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = cleaned.components(separatedBy: ", ")
        let blocks = cleaned.integers

        guard parts.count == blocks.count else { return nil }

        return zip(parts, blocks).compactMap { part, blockCount in
            guard let firstChar = part.first,
                let turn = Turn(rawValue: firstChar)
            else {
                return nil
            }
            return Instruction(turn: turn, blocks: blockCount)
        }
    }

    private enum Direction: Int, CaseIterable {
        case north = 0
        case east = 1
        case south = 2
        case west = 3

        func turn(_ turn: Turn) -> Direction {
            let offset = turn == .left ? -1 : 1
            let newValue = (rawValue + offset + 4) % 4
            return Direction(rawValue: newValue)!
        }

        var delta: (x: Int, y: Int) {
            switch self {
            case .north: return (0, 1)
            case .east: return (1, 0)
            case .south: return (0, -1)
            case .west: return (-1, 0)
            }
        }
    }

    private struct Position: Hashable {
        let x: Int
        let y: Int

        var manhattanDistance: Int {
            abs(x) + abs(y)
        }

        func move(by delta: (x: Int, y: Int)) -> Position {
            Position(x: x + delta.x, y: y + delta.y)
        }
    }

    public func solvePart1(data: [Instruction]) -> Int {
        var position = Position(x: 0, y: 0)
        var direction = Direction.north

        for instruction in data {
            direction = direction.turn(instruction.turn)
            let delta = direction.delta
            position = Position(
                x: position.x + delta.x * instruction.blocks,
                y: position.y + delta.y * instruction.blocks
            )
        }

        return position.manhattanDistance
    }

    public func solvePart2(data: [Instruction]) -> Int {
        var position = Position(x: 0, y: 0)
        var direction = Direction.north
        var visited: Set<Position> = [position]

        for instruction in data {
            direction = direction.turn(instruction.turn)
            let delta = direction.delta

            for _ in 0..<instruction.blocks {
                position = position.move(by: delta)
                if visited.contains(position) {
                    return position.manhattanDistance
                }
                visited.insert(position)
            }
        }

        return 0
    }
}
