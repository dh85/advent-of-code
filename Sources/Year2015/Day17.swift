import AoCCommon

public struct Day17: DaySolver {
    public typealias ParsedData = [Int]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 17
    public let testInput = """
        20
        15
        10
        5
        5
        """
    public let expectedTestResult1: Result1? = 4
    public let expectedTestResult2: Result2? = 3

    public func parse(input: String) -> [Int]? {
        input.lines.compactMap { Int($0) }
    }

    private func validCombinations(_ data: [Int]) -> (count: Int, minContainers: Int, minCount: Int)
    {
        let target = data.count == 5 ? 25 : 150
        var totalCount = 0
        var minContainers = Int.max
        var minCount = 0
        let n = data.count
        let total = 1 << n

        for mask in 0..<total {
            var sum = 0
            for i in 0..<n where mask & (1 << i) != 0 {
                sum += data[i]
                if sum > target { break }
            }
            if sum == target {
                totalCount += 1
                let containers = mask.nonzeroBitCount
                if containers < minContainers {
                    minContainers = containers
                    minCount = 1
                } else if containers == minContainers {
                    minCount += 1
                }
            }
        }

        return (totalCount, minContainers, minCount)
    }

    public func solvePart1(data: [Int]) -> Int {
        validCombinations(data).count
    }

    public func solvePart2(data: [Int]) -> Int {
        validCombinations(data).minCount
    }
}
