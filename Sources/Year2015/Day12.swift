import AoCCommon
import Foundation

public struct Day12: DaySolver {
    public struct JSON: Equatable {
        let value: Any
        public static func == (lhs: JSON, rhs: JSON) -> Bool { true }
    }

    public typealias ParsedData = JSON
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 12
    public let testInput = "[1,2,3]"
    public let expectedTestResult1: Result1? = 6
    public let expectedTestResult2: Result2? = 6

    public func parse(input: String) -> JSON? {
        guard let obj = try? JSONSerialization.jsonObject(with: Data(input.utf8)) else {
            return nil
        }
        return JSON(value: obj)
    }

    private func sumNumbers(_ obj: Any, ignoreRed: Bool = false) -> Int {
        switch obj {
        case let num as Int:
            return num
        case let array as [Any]:
            return array.reduce(0) { $0 + sumNumbers($1, ignoreRed: ignoreRed) }
        case let dict as [String: Any]:
            if ignoreRed && dict.values.contains(where: { $0 as? String == "red" }) {
                return 0
            }
            return dict.values.reduce(0) { $0 + sumNumbers($1, ignoreRed: ignoreRed) }
        default:
            return 0
        }
    }

    public func solvePart1(data: JSON) -> Int {
        sumNumbers(data.value)
    }

    public func solvePart2(data: JSON) -> Int {
        sumNumbers(data.value, ignoreRed: true)
    }
}
