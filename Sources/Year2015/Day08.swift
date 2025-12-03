import AoCCommon

public struct Day08: DaySolver {
    public typealias ParsedData = [String]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 8
    public let testInput = """
        ""
        "abc"
        "aaa\\"aaa"
        "\\x27"
        """
    public let expectedTestResult1: Result1? = 12
    public let expectedTestResult2: Result2? = 19

    public func parse(input: String) -> [String]? {
        input.lines
    }

    private func memoryLength(_ s: String) -> Int {
        var count = 0
        var i = s.index(after: s.startIndex)

        while i < s.index(before: s.endIndex) {
            if s[i] == "\\" {
                i = s.index(after: i)
                i = s[i] == "x" ? s.index(i, offsetBy: 3) : s.index(after: i)
            } else {
                i = s.index(after: i)
            }
            count += 1
        }

        return count
    }

    private func encodedLength(_ s: String) -> Int {
        2 + s.reduce(0) { $0 + ($1 == "\"" || $1 == "\\" ? 2 : 1) }
    }

    public func solvePart1(data: [String]) -> Int {
        data.map { $0.count - memoryLength($0) }.reduce(0, +)
    }

    public func solvePart2(data: [String]) -> Int {
        data.map { encodedLength($0) - $0.count }.reduce(0, +)
    }
}
