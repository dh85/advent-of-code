import AoCCommon

public struct Day04: DaySolver {
    public typealias ParsedData = Grid<Bool>
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 13
    public let expectedTestResult2: Result2? = 43

    public init() {}

    public let day = 4
    public let testInput = """
        ..@@.@@@@.
        @@@.@.@.@@
        @@@@@.@.@@
        @.@@@@..@.
        @@.@@@@.@@
        .@@@@@@@.@
        .@.@.@.@@@
        @.@@@.@@@@
        .@@@@@@@@.
        @.@.@@@.@.
        """

    public func parse(input: String) throws -> Grid<Bool> {
        Grid(parsing: input) { $0 == "@" }
    }

    public func solvePart1(data: Grid<Bool>) -> Int {
        accessible(in: data).count
    }

    public func solvePart2(data: Grid<Bool>) -> Int {
        let rows = data.rows
        let cols = data.cols
        // Use flat UInt8 array for neighbor counts
        var alive = [Bool](repeating: false, count: rows * cols)
        var neighborCount = [UInt8](repeating: 0, count: rows * cols)

        // Initialize
        for y in 0..<rows {
            for x in 0..<cols {
                if data[y, x] {
                    alive[y * cols + x] = true
                }
            }
        }

        // Compute initial neighbor counts
        for y in 0..<rows {
            for x in 0..<cols {
                guard alive[y * cols + x] else { continue }
                let minY = max(0, y - 1)
                let maxY = min(rows - 1, y + 1)
                let minX = max(0, x - 1)
                let maxX = min(cols - 1, x + 1)
                var count: UInt8 = 0
                for ny in minY...maxY {
                    for nx in minX...maxX {
                        if (ny != y || nx != x) && alive[ny * cols + nx] {
                            count += 1
                        }
                    }
                }
                neighborCount[y * cols + x] = count
            }
        }

        var totalRemoved = 0
        var toRemove = [Int]()
        var toCheck = [Int]()

        // Initial pass: find all accessible cells (alive with < 4 neighbors)
        for i in 0..<(rows * cols) {
            if alive[i] && neighborCount[i] < 4 {
                toRemove.append(i)
            }
        }

        while !toRemove.isEmpty {
            totalRemoved += toRemove.count
            toCheck.removeAll(keepingCapacity: true)

            // Remove cells and update neighbor counts
            for idx in toRemove {
                alive[idx] = false
                let y = idx / cols
                let x = idx % cols
                let minY = max(0, y - 1)
                let maxY = min(rows - 1, y + 1)
                let minX = max(0, x - 1)
                let maxX = min(cols - 1, x + 1)
                for ny in minY...maxY {
                    for nx in minX...maxX {
                        if ny == y && nx == x { continue }
                        let nIdx = ny * cols + nx
                        if alive[nIdx] {
                            neighborCount[nIdx] -= 1
                            if neighborCount[nIdx] < 4 {
                                toCheck.append(nIdx)
                            }
                        }
                    }
                }
            }

            // Find newly accessible cells
            toRemove.removeAll(keepingCapacity: true)
            for idx in toCheck {
                if alive[idx] && neighborCount[idx] < 4 {
                    toRemove.append(idx)
                }
            }
            // Deduplicate
            let unique = Set(toRemove)
            toRemove = Array(unique)
        }

        return totalRemoved
    }

    private func accessible(in grid: Grid<Bool>) -> [Point] {
        grid.allPoints.filter { point in
            grid[point]
                && grid.neighbors(of: point, includeDiagonals: true).filter { grid[$0] }.count < 4
        }
    }
}
