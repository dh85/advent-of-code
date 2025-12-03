import AoCCommon

public struct Day24: DaySolver {
    public typealias ParsedData = [Int]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 24
    public let testInput = """
        1
        2
        3
        4
        5
        7
        8
        9
        10
        11
        """
    public let expectedTestResult1: Result1? = 99
    public let expectedTestResult2: Result2? = 44

    public func parse(input: String) -> [Int]? {
        input.split(separator: "\n").compactMap { Int($0) }
    }

    public func solvePart1(data: [Int]) -> Int {
        solve(data, groups: 3)
    }

    public func solvePart2(data: [Int]) -> Int {
        solve(data, groups: 4)
    }

    private func solve(_ data: [Int], groups: Int) -> Int {
        let target = data.sum() / groups

        for size in 1...data.count {
            if let qe = findMinQE(data, target: target, size: size) {
                return qe
            }
        }

        return 0
    }

    private func findMinQE(_ packages: [Int], target: Int, size: Int) -> Int? {
        var minQE: Int?

        func search(_ index: Int, _ count: Int, _ sum: Int, _ qe: Int) {
            if count == size {
                if sum == target { minQE = min(minQE ?? Int.max, qe) }
                return
            }

            if sum >= target || index >= packages.count { return }
            if let min = minQE, qe >= min { return }

            for i in index..<packages.count {
                search(i + 1, count + 1, sum + packages[i], qe * packages[i])
            }
        }

        search(0, 0, 0, 1)
        return minQE
    }

}
