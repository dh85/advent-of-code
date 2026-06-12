import AoCCommon

public struct Day18: DaySolver {
    public struct LightGrid: Equatable {
        let cells: [UInt8]
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

    public func parse(input: String) throws -> LightGrid {
        let lines = input.split(separator: "\n")
        let size = lines.count
        let cells = lines.flatMap { $0.map { UInt8($0 == "#" ? 1 : 0) } }
        return LightGrid(cells: cells, size: size)
    }

    public func solvePart1(data: LightGrid) -> Int {
        simulate(data.cells, size: data.size, steps: data.size == 6 ? 4 : 100, stuckCorners: false)
    }

    public func solvePart2(data: LightGrid) -> Int {
        simulate(data.cells, size: data.size, steps: data.size == 6 ? 5 : 100, stuckCorners: true)
    }

    private func simulate(_ initial: [UInt8], size: Int, steps: Int, stuckCorners: Bool) -> Int {
        var current = initial
        var next = [UInt8](repeating: 0, count: size * size)

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

        return current.reduce(0) { $0 + Int($1) }
    }

    private func step(from grid: [UInt8], to next: inout [UInt8], size: Int) {
        for y in 0..<size {
            let minY = max(0, y - 1)
            let maxY = min(size - 1, y + 1)
            for x in 0..<size {
                let minX = max(0, x - 1)
                let maxX = min(size - 1, x + 1)

                var count: UInt8 = 0
                for ny in minY...maxY {
                    let rowOff = ny * size
                    for nx in minX...maxX {
                        count &+= grid[rowOff + nx]
                    }
                }
                // Subtract self
                let idx = y * size + x
                count &-= grid[idx]
                // alive if count==3, or count==2 and currently alive
                next[idx] = (count == 3 || (count == 2 && grid[idx] == 1)) ? 1 : 0
            }
        }
    }

    private func fixCorners(_ grid: inout [UInt8], size: Int) {
        let last = size - 1
        grid[0] = 1
        grid[last] = 1
        grid[last * size] = 1
        grid[last * size + last] = 1
    }
}
