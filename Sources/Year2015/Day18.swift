import AoCCommon

public struct Day18: DaySolver {
    public struct LightGrid: Equatable {
        let cells: [Bool]
        let size: Int
    }

    public typealias ParsedData = LightGrid
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 18
    public let testInput = """
        .#.#.#
        ...##.
        #....#
        ..#...
        #.#..#
        ####..
        """
    public let expectedTestResult1: Result1? = 4
    public let expectedTestResult2: Result2? = 17

    public func parse(input: String) -> LightGrid? {
        let lines = input.split(separator: "\n")
        let size = lines.count
        let cells = lines.flatMap { $0.map { $0 == "#" } }
        return LightGrid(cells: cells, size: size)
    }

    public func solvePart1(data: LightGrid) -> Int {
        simulate(data.cells, size: data.size, steps: data.size == 6 ? 4 : 100, stuckCorners: false)
    }

    public func solvePart2(data: LightGrid) -> Int {
        simulate(data.cells, size: data.size, steps: data.size == 6 ? 5 : 100, stuckCorners: true)
    }

    private func simulate(_ initial: [Bool], size: Int, steps: Int, stuckCorners: Bool) -> Int {
        var current = initial
        var next = current

        if stuckCorners {
            fixCorners(&current, size: size)
        }

        for _ in 0..<steps {
            step(from: current, to: &next, size: size)
            if stuckCorners {
                fixCorners(&next, size: size)
            }
            swap(&current, &next)
        }

        return current.count { $0 }
    }

    private func step(from grid: [Bool], to next: inout [Bool], size: Int) {
        for y in 0..<size {
            for x in 0..<size {
                var count = 0
                let minY = max(0, y - 1)
                let maxY = min(size - 1, y + 1)
                let minX = max(0, x - 1)
                let maxX = min(size - 1, x + 1)

                for ny in minY...maxY {
                    for nx in minX...maxX {
                        if ny == y && nx == x { continue }
                        if grid[ny * size + nx] { count += 1 }
                    }
                }

                let idx = y * size + x
                next[idx] = grid[idx] ? (count == 2 || count == 3) : count == 3
            }
        }
    }

    private func fixCorners(_ grid: inout [Bool], size: Int) {
        let last = size - 1
        grid[0] = true
        grid[last] = true
        grid[last * size] = true
        grid[last * size + last] = true
    }
}
