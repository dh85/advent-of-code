import AoCCommon

public struct Day20: DaySolver {
    public typealias ParsedData = [(start: UInt64, end: UInt64)]
    public typealias Result1 = UInt64
    public typealias Result2 = Int

    public init() {}

    public let day = 20
    public let testInput = """
        5-8
        0-2
        4-7
        """
    public let expectedTestResult1: Result1? = 3
    public let expectedTestResult2: Result2? = 2

    public func parse(input: String) throws -> ParsedData {
        input.lines.compactMap { line -> (start: UInt64, end: UInt64)? in
            let parts = line.split(separator: "-")
            guard parts.count == 2,
                let start = UInt64(parts[0]),
                let end = UInt64(parts[1])
            else { return nil }
            return (start: start, end: end)
        }
    }

    private func mergedRanges(_ ranges: ParsedData) -> [(start: UInt64, end: UInt64)] {
        let sorted = ranges.sorted { $0.start < $1.start }
        var merged = [sorted[0]]
        for range in sorted.dropFirst() {
            if range.start <= merged[merged.count - 1].end + 1 {
                merged[merged.count - 1].end = max(merged[merged.count - 1].end, range.end)
            } else {
                merged.append(range)
            }
        }
        return merged
    }

    public func solvePart1(data: ParsedData) -> UInt64 {
        let merged = mergedRanges(data)
        return merged[0].start > 0 ? 0 : merged[0].end + 1
    }

    public func solvePart2(data: ParsedData) -> Int {
        let merged = mergedRanges(data)
        let maxIP: UInt64 = data.count < 10 ? 9 : 4_294_967_295

        var allowed = Int(merged[0].start)
        for i in 0..<(merged.count - 1) {
            allowed += Int(merged[i + 1].start - merged[i].end - 1)
        }
        allowed += Int(maxIP - merged.last!.end)
        return allowed
    }
}
