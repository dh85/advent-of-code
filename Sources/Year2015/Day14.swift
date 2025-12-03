import AoCCommon

public struct Day14: DaySolver {
    public struct Reindeer: Equatable {
        let name: String
        let speed: Int
        let flyTime: Int
        let restTime: Int
    }

    public typealias ParsedData = [Reindeer]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 14
    public let testInput = """
        Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
        Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
        """
    public let expectedTestResult1: Result1? = 2660
    public let expectedTestResult2: Result2? = 1564

    private let raceDuration = 2503

    public func parse(input: String) -> [Reindeer]? {
        input.lines.map { line in
            let p = line.split(separator: " ")
            let nums = line.integers
            return Reindeer(
                name: String(p[0]),
                speed: nums[0],
                flyTime: nums[1],
                restTime: nums[2]
            )
        }
    }

    private func distance(_ reindeer: Reindeer, after seconds: Int) -> Int {
        let cycle = reindeer.flyTime + reindeer.restTime
        let flyingTime =
            (seconds / cycle) * reindeer.flyTime + min(seconds % cycle, reindeer.flyTime)
        return flyingTime * reindeer.speed
    }

    public func solvePart1(data: [Reindeer]) -> Int {
        data.map { distance($0, after: raceDuration) }.max()!
    }

    public func solvePart2(data: [Reindeer]) -> Int {
        var points = [String: Int]()

        for second in 1...raceDuration {
            let distances = data.map { ($0, distance($0, after: second)) }
            let maxDist = distances.map(\.1).max()!

            distances.filter { $0.1 == maxDist }.forEach {
                points[$0.0.name, default: 0] += 1
            }
        }

        return points.values.max()!
    }
}
