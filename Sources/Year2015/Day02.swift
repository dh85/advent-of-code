import AoCCommon

public struct Day02: DaySolver {
    public struct Box: Equatable {
        let dims: [Int]

        init(_ dims: [Int]) { self.dims = dims.sorted() }

        var wrappingPaper: Int {
            let sides = [dims[0] * dims[1], dims[1] * dims[2], dims[0] * dims[2]]
            return 2 * sides.sum() + sides[0]
        }

        var ribbon: Int {
            2 * (dims[0] + dims[1]) + dims.product()
        }
    }

    public typealias ParsedData = [Box]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 2
    public let testInput = """
        2x3x4
        1x1x10
        """
    public let expectedTestResult1: Result1? = 101
    public let expectedTestResult2: Result2? = 48

    public func parse(input: String) -> [Box]? {
        input.lines
            .map { Box($0.split(separator: "x").compactMap { Int($0) }) }
    }

    public func solvePart1(data: [Box]) -> Int {
        data.map(\.wrappingPaper).sum()
    }

    public func solvePart2(data: [Box]) -> Int {
        data.map(\.ribbon).sum()
    }
}
