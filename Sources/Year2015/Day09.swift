import AoCCommon

public struct Day09: DaySolver {
    public struct Graph: Equatable {
        let distances: [String: [String: Int]]
        let cities: Set<String>
    }

    public typealias ParsedData = Graph
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 9
    public let testInput = """
        London to Dublin = 464
        London to Belfast = 518
        Dublin to Belfast = 141
        """
    public let expectedTestResult1: Result1? = 605
    public let expectedTestResult2: Result2? = 982

    public func parse(input: String) -> Graph? {
        var distances: [String: [String: Int]] = [:]
        var cities: Set<String> = []

        for line in input.lines {
            let parts = line.split(separator: " ")
            let (from, to, dist) = (String(parts[0]), String(parts[2]), Int(parts[4])!)

            cities.formUnion([from, to])
            distances[from, default: [:]][to] = dist
            distances[to, default: [:]][from] = dist
        }

        return Graph(distances: distances, cities: cities)
    }

    private func routeDistance(_ route: [Int], _ matrix: [[Int]]) -> Int {
        var total = 0
        for i in 0..<(route.count - 1) {
            total += matrix[route[i]][route[i + 1]]
        }
        return total
    }

    public func solvePart1(data: Graph) -> Int {
        let cities = Array(data.cities)
        let n = cities.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
        for (i, c1) in cities.enumerated() {
            for (j, c2) in cities.enumerated() {
                matrix[i][j] = data.distances[c1]?[c2] ?? 0
            }
        }
        return Array(0..<n).permutations().map { routeDistance($0, matrix) }.min()!
    }

    public func solvePart2(data: Graph) -> Int {
        let cities = Array(data.cities)
        let n = cities.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
        for (i, c1) in cities.enumerated() {
            for (j, c2) in cities.enumerated() {
                matrix[i][j] = data.distances[c1]?[c2] ?? 0
            }
        }
        return Array(0..<n).permutations().map { routeDistance($0, matrix) }.max()!
    }
}
