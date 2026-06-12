import AoCCommon

public struct Day24: DaySolver {
    public struct Maze {
        let grid: [[Character]]
        let locations: [(row: Int, col: Int)]  // indexed by location number
        let width: Int
        let height: Int
    }

    public typealias ParsedData = Maze
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 24
    public let testInput = """
        ###########
        #0.1.....2#
        #.#######.#
        #4.......3#
        ###########
        """
    public let expectedTestResult1: Result1? = 14
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> Maze {
        let grid = input.lines.map { Array($0) }
        var locationDict: [Int: (row: Int, col: Int)] = [:]

        for (row, line) in grid.enumerated() {
            for (col, char) in line.enumerated() {
                if let digit = char.wholeNumberValue {
                    locationDict[digit] = (row, col)
                }
            }
        }

        // Convert to array indexed by location number
        let maxLoc = locationDict.keys.max() ?? 0
        var locations: [(row: Int, col: Int)] = []
        for i in 0...maxLoc {
            locations.append(locationDict[i]!)
        }

        return Maze(
            grid: grid,
            locations: locations,
            width: grid[0].count,
            height: grid.count
        )
    }

    // BFS to find shortest path between two points
    private func shortestPath(from: (Int, Int), to: (Int, Int), in maze: Maze) -> Int {
        if from == to { return 0 }

        var visited = Set<Int>()
        var queue: [(row: Int, col: Int, dist: Int)] = [(from.0, from.1, 0)]
        visited.insert(from.0 * maze.width + from.1)

        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1

            for (dr, dc) in directions {
                let nr = current.row + dr
                let nc = current.col + dc
                let key = nr * maze.width + nc

                if nr >= 0 && nr < maze.height && nc >= 0 && nc < maze.width
                    && maze.grid[nr][nc] != "#" && !visited.contains(key)
                {

                    if (nr, nc) == to {
                        return current.dist + 1
                    }

                    visited.insert(key)
                    queue.append((nr, nc, current.dist + 1))
                }
            }
        }

        return Int.max
    }

    // Compute all pairwise distances between numbered locations
    private func computeDistances(_ maze: Maze) -> [[Int]] {
        let n = maze.locations.count
        var distances = Array(repeating: Array(repeating: 0, count: n), count: n)

        for i in 0..<n {
            for j in (i + 1)..<n {
                let dist = shortestPath(from: maze.locations[i], to: maze.locations[j], in: maze)
                distances[i][j] = dist
                distances[j][i] = dist
            }
        }

        return distances
    }

    // Generate all permutations of an array
    private func permutations<T>(_ arr: [T]) -> [[T]] {
        if arr.count <= 1 { return [arr] }

        var result: [[T]] = []
        for i in arr.indices {
            var remaining = arr
            let elem = remaining.remove(at: i)
            for var perm in permutations(remaining) {
                perm.insert(elem, at: 0)
                result.append(perm)
            }
        }
        return result
    }

    public func solvePart1(data: Maze) -> Int {
        let distances = computeDistances(data)
        let n = data.locations.count

        // We need to visit all locations 1..<n starting from 0
        let toVisit = Array(1..<n)
        var minDist = Int.max

        for perm in permutations(toVisit) {
            var dist = distances[0][perm[0]]
            for i in 0..<(perm.count - 1) {
                dist += distances[perm[i]][perm[i + 1]]
            }
            minDist = min(minDist, dist)
        }

        return minDist
    }

    public func solvePart2(data: Maze) -> Int {
        let distances = computeDistances(data)
        let n = data.locations.count

        // Same as Part 1, but must return to 0
        let toVisit = Array(1..<n)
        var minDist = Int.max

        for perm in permutations(toVisit) {
            var dist = distances[0][perm[0]]
            for i in 0..<(perm.count - 1) {
                dist += distances[perm[i]][perm[i + 1]]
            }
            // Return to start
            dist += distances[perm.last!][0]
            minDist = min(minDist, dist)
        }

        return minDist
    }
}
