import AoCCommon

public struct Day07: DaySolver {
    public typealias ParsedData = Grid<Character>
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 21
    public let expectedTestResult2: Result2? = 40

    public init() {}

    public let day = 7
    public let testInput = """
        .......S.......
        ...............
        .......^.......
        ...............
        ......^.^......
        ...............
        .....^.^.^.....
        ...............
        ....^.^...^....
        ...............
        ...^.^...^.^...
        ...............
        ..^...^.....^..
        ...............
        .^.^.^.^.^...^.
        ...............
        """

    public func parse(input: String) throws -> Grid<Character> {
        Grid(parsing: input)
    }

    public func solvePart1(data: Grid<Character>) -> Int {
        solve(data: data, countTimelines: false)
    }

    public func solvePart2(data: Grid<Character>) -> Int {
        solve(data: data, countTimelines: true)
    }

    private func solve(data: Grid<Character>, countTimelines: Bool) -> Int {
        guard let start = data.first(where: { $0 == "S" }) else { return 0 }

        var counts = Array(repeating: 0, count: data.cols)
        counts[start.x] = 1
        var visited = Set<Point>()

        for y in (start.y + 1)..<data.rows {
            var nextCounts = Array(repeating: 0, count: data.cols)

            for x in 0..<data.cols where counts[x] > 0 {
                if data[y, x] == "^" {
                    if !countTimelines { visited.insert(Point(x, y)) }
                    if x > 0 { nextCounts[x - 1] += counts[x] }
                    if x < data.cols - 1 { nextCounts[x + 1] += counts[x] }
                } else {
                    nextCounts[x] += counts[x]
                }
            }

            counts = nextCounts
        }

        return countTimelines ? counts.reduce(0, +) : visited.count
    }
}
