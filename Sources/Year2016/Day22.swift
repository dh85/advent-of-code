import AoCCommon

public struct Day22: DaySolver {
    public struct Node: Equatable {
        let x: Int
        let y: Int
        let size: Int
        let used: Int
        var avail: Int { size - used }
    }

    public typealias ParsedData = [Node]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 22
    public let testInput = """
        root@ebhq-gridcenter# df -h
        Filesystem              Size  Used  Avail  Use%
        /dev/grid/node-x0-y0     10T    8T     2T   80%
        /dev/grid/node-x0-y1     11T    6T     5T   54%
        /dev/grid/node-x0-y2     32T   28T     4T   87%
        /dev/grid/node-x1-y0      9T    7T     2T   77%
        /dev/grid/node-x1-y1      8T    0T     8T    0%
        /dev/grid/node-x1-y2     11T    7T     4T   63%
        /dev/grid/node-x2-y0     10T    6T     4T   60%
        /dev/grid/node-x2-y1      9T    8T     1T   88%
        /dev/grid/node-x2-y2      9T    6T     3T   66%
        """
    public let expectedTestResult1: Result1? = 7
    public let expectedTestResult2: Result2? = 7

    public func parse(input: String) throws -> [Node] {
        input.lines.compactMap { line -> Node? in
            // /dev/grid/node-x0-y0     10T    8T     2T   80%
            guard line.hasPrefix("/dev/grid/node-") else { return nil }
            let nums = line.integers
            guard nums.count >= 4 else { return nil }
            return Node(x: nums[0], y: nums[1], size: nums[2], used: nums[3])
        }
    }

    public func solvePart1(data: [Node]) -> Int {
        var count = 0
        for a in data where a.used > 0 {
            for b in data where a != b && a.used <= b.avail {
                count += 1
            }
        }
        return count
    }

    public func solvePart2(data: [Node]) -> Int {
        // Find grid dimensions
        let maxX = data.map(\.x).max() ?? 0

        // Goal data starts at (maxX, 0)
        // We need to move it to (0, 0)

        // Find the empty node
        guard let empty = data.first(where: { $0.used == 0 }) else { return 0 }

        // Find "wall" nodes (too large to fit anywhere)
        let normalSize = data.filter { $0.used > 0 && $0.used < 100 }.map(\.size).max() ?? 100
        let walls = data.filter { $0.used > normalSize }

        func isWall(_ x: Int, _ y: Int) -> Bool {
            walls.contains { $0.x == x && $0.y == y }
        }

        // Find the leftmost wall blocking path to goal
        var wallX = maxX + 1
        for wall in walls {
            wallX = min(wallX, wall.x)
        }

        // Steps:
        // 1. Move empty node to (maxX-1, 0) - position to the left of goal
        // 2. Each move of goal left by 1 takes 5 steps:
        //    - Move empty around the goal (4 steps)
        //    - Move goal into empty (1 step)
        // 3. Move goal from (maxX, 0) to (0, 0) = maxX moves

        var emptyToGoalLeft: Int
        if wallX > maxX {
            // No walls blocking, Manhattan distance
            emptyToGoalLeft = abs(empty.x - (maxX - 1)) + abs(empty.y - 0)
        } else {
            // Need to go around the wall
            // Go left of wall, up to row 0, then right to goal
            // Find the gap in the wall (leftmost x where we can pass through entire column)
            var gapX = 0
            for x in stride(from: wallX - 1, through: 0, by: -1) {
                if !walls.contains(where: { $0.x == x }) {
                    gapX = x
                    break
                }
            }
            // Path: empty -> (gapX, empty.y) -> (gapX, 0) -> (maxX-1, 0)
            emptyToGoalLeft = abs(empty.x - gapX) + abs(empty.y - 0) + abs(gapX - (maxX - 1))
        }

        // Move goal from (maxX, 0) to (0, 0): maxX steps, each taking 5 moves except first takes 1
        let moveGoalSteps = 1 + (maxX - 1) * 5

        return emptyToGoalLeft + moveGoalSteps
    }
}
