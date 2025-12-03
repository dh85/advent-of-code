import AoCCommon

public struct Day01: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 1
    public let testInput = "()())"
    public let expectedTestResult1: Result1? = -1
    public let expectedTestResult2: Result2? = 5

    public func parse(input: String) -> String? { input }

    private func floorChange(_ char: Character) -> Int {
        char == "(" ? 1 : -1
    }

    public func solvePart1(data: String) -> Int {
        data.reduce(0) { $0 + floorChange($1) }
    }

    public func solvePart2(data: String) -> Int {
        var floor = 0
        for (index, char) in data.enumerated() {
            floor += floorChange(char)
            if floor == -1 { return index + 1 }
        }
        return 0
    }
}
