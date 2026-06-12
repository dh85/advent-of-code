import AoCCommon

public struct Day05: DaySolver {
    public struct Range: Equatable {
        let start: Int
        let end: Int

        var size: Int { end - start + 1 }

        func contains(_ value: Int) -> Bool {
            value >= start && value <= end
        }

        func overlaps(_ other: Range) -> Bool {
            start <= other.end + 1 && other.start <= end + 1
        }

        func merged(with other: Range) -> Range {
            Range(start: min(start, other.start), end: max(end, other.end))
        }
    }

    public struct Database: Equatable {
        let ranges: [Range]
        let ids: [Int]
    }

    public typealias ParsedData = Database
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 3
    public let expectedTestResult2: Result2? = 14

    public init() {}

    public let day = 5
    public let testInput = """
        3-5
        10-14
        16-20
        12-18

        1
        5
        8
        11
        17
        32
        """

    public func parse(input: String) throws -> Database {
        let parts = input.components(separatedBy: "\n\n")
        guard parts.count == 2 else { throw ParseError.invalidInput }

        let ranges = parts[0].split(separator: "\n").map {
            let nums = $0.split(separator: "-").map { Int($0)! }
            return Range(start: nums[0], end: nums[1])
        }

        let ids = parts[1].split(separator: "\n").compactMap { Int($0) }

        return Database(ranges: ranges, ids: ids)
    }

    public func solvePart1(data: Database) -> Int {
        data.ids.filter { id in
            data.ranges.contains { $0.contains(id) }
        }.count
    }

    public func solvePart2(data: Database) -> Int {
        mergeRanges(data.ranges).map(\.size).sum()
    }

    private func mergeRanges(_ ranges: [Range]) -> [Range] {
        let sorted = ranges.sorted { $0.start < $1.start }
        var merged: [Range] = []

        for range in sorted {
            if let last = merged.last, last.overlaps(range) {
                merged[merged.count - 1] = last.merged(with: range)
            } else {
                merged.append(range)
            }
        }

        return merged
    }
}
