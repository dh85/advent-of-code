import AoCCommon

public struct Day03: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 3
    public let testInput = "^v^v^v^v^v"
    public let expectedTestResult1: Result1? = 2
    public let expectedTestResult2: Result2? = 11

    public func parse(input: String) -> String? { input }

    private func move(_ pos: inout [Int], _ char: Character) {
        switch char {
        case "^": pos[1] += 1
        case "v": pos[1] -= 1
        case ">": pos[0] += 1
        case "<": pos[0] -= 1
        default: break
        }
    }

    public func solvePart1(data: String) -> Int {
        var visited = Set<[Int]>()
        var pos = [0, 0]
        visited.insert(pos)

        for char in data {
            move(&pos, char)
            visited.insert(pos)
        }

        return visited.count
    }

    public func solvePart2(data: String) -> Int {
        var visited = Set<[Int]>()
        var positions = [[0, 0], [0, 0]]
        visited.insert(positions[0])

        for (index, char) in data.enumerated() {
            move(&positions[index % 2], char)
            visited.insert(positions[index % 2])
        }

        return visited.count
    }
}
