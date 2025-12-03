import AoCCommon

public struct Day10: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 10
    public let testInput = "1"
    public let expectedTestResult1: Result1? = 82350
    public let expectedTestResult2: Result2? = 1_166_642

    public func parse(input: String) -> String? { input }

    private func lookAndSay(_ digits: [UInt8]) -> [UInt8] {
        var result = [UInt8]()
        result.reserveCapacity(digits.count * 2)
        var i = 0

        while i < digits.count {
            let digit = digits[i]
            var count: UInt8 = 1
            while i + Int(count) < digits.count && digits[i + Int(count)] == digit {
                count += 1
            }
            result.append(count)
            result.append(digit)
            i += Int(count)
        }

        return result
    }

    private func apply(_ data: String, times: Int) -> Int {
        var digits = data.compactMap { UInt8(String($0)) }
        for _ in 0..<times {
            digits = lookAndSay(digits)
        }
        return digits.count
    }

    public func solvePart1(data: String) -> Int {
        apply(data, times: 40)
    }

    public func solvePart2(data: String) -> Int {
        apply(data, times: 50)
    }
}
