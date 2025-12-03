import AoCCommon

public struct Day13: DaySolver {
    public typealias ParsedData = Int
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 13
    public let testInput = "10"
    public let expectedTestResult1: Result1? = 11
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) -> Int? {
        Int(input.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func isOpen(x: Int, y: Int, favoriteNumber: Int) -> Bool {
        guard x >= 0 && y >= 0 else { return false }
        let value = x * x + 3 * x + 2 * x * y + y + y * y + favoriteNumber
        return value.nonzeroBitCount % 2 == 0
    }

    private func bfs(favoriteNumber: Int, target: (Int, Int)?) -> Int {
        var queue: [(x: Int, y: Int, steps: Int)] = [(1, 1, 0)]
        var visited: Set<Int> = [1 << 16 | 1]  // Encode (x,y) as single Int
        var head = 0
        var reachableIn50 = 0

        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]

        while head < queue.count {
            let (x, y, steps) = queue[head]
            head += 1

            // Part 2: count locations reachable in at most 50 steps
            if steps <= 50 {
                reachableIn50 += 1
            }

            // Part 1: found target
            if let t = target, x == t.0 && y == t.1 {
                return steps
            }

            // Stop exploring beyond 50 for Part 2 (no target)
            if target == nil && steps >= 50 {
                continue
            }

            for (dx, dy) in directions {
                let nx = x + dx
                let ny = y + dy
                guard nx >= 0 && ny >= 0 else { continue }

                let key = nx << 16 | ny
                guard !visited.contains(key) else { continue }
                guard isOpen(x: nx, y: ny, favoriteNumber: favoriteNumber) else { continue }

                visited.insert(key)
                queue.append((nx, ny, steps + 1))
            }
        }

        // Part 2: return count of reachable locations
        return reachableIn50
    }

    public func solvePart1(data: Int) -> Int {
        // Test uses target (7,4), main input uses (31,39)
        let target = data == 10 ? (7, 4) : (31, 39)
        return bfs(favoriteNumber: data, target: target)
    }

    public func solvePart2(data: Int) -> Int {
        bfs(favoriteNumber: data, target: nil)
    }
}
