import AoCCommon
import Foundation

public struct Day02: DaySolver {
    public typealias ParsedData = [(start: Int, end: Int)]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 1_227_775_554
    public let expectedTestResult2: Result2? = 4_174_379_265

    public init() {}

    public let day = 2
    public let testInput = """
        11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
        """

    public func parse(input: String) throws -> ParsedData {
        let line = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let rangeStrings = line.components(separatedBy: ",").filter { !$0.isEmpty }

        return rangeStrings.compactMap { rangeStr in
            let parts = rangeStr.components(separatedBy: "-")
            guard parts.count == 2,
                let start = Int(parts[0]),
                let end = Int(parts[1])
            else {
                return nil
            }
            return (start: start, end: end)
        }
    }

    /// Returns the number of decimal digits in n (n > 0)
    @inline(__always)
    private func digitCount(_ n: Int) -> Int {
        if n < 10 { return 1 }
        if n < 100 { return 2 }
        if n < 1000 { return 3 }
        if n < 10000 { return 4 }
        if n < 100000 { return 5 }
        if n < 1_000_000 { return 6 }
        if n < 10_000_000 { return 7 }
        if n < 100_000_000 { return 8 }
        if n < 1_000_000_000 { return 9 }
        if n < 10_000_000_000 { return 10 }
        return 11
    }

    /// Returns 10^n
    @inline(__always)
    private func pow10(_ n: Int) -> Int {
        switch n {
        case 0: return 1
        case 1: return 10
        case 2: return 100
        case 3: return 1000
        case 4: return 10000
        case 5: return 100000
        case 6: return 1_000_000
        case 7: return 10_000_000
        case 8: return 100_000_000
        case 9: return 1_000_000_000
        case 10: return 10_000_000_000
        default: return 1
        }
    }

    /// Check if number has a repeating pattern of length `patLen`
    /// e.g. 123123 with patLen=3: pattern=123, check 123*1001 == 123123
    @inline(__always)
    private func isRepeating(_ n: Int, digits: Int, patLen: Int) -> Bool {
        guard digits % patLen == 0 else { return false }
        let reps = digits / patLen
        let pattern = n / pow10(digits - patLen)
        guard pattern >= pow10(patLen - 1) else { return false }  // no leading zero

        // Build repunit: 1 + 10^patLen + 10^(2*patLen) + ...
        var repunit = 0
        let base = pow10(patLen)
        for _ in 0..<reps {
            repunit = repunit * base + 1
        }
        return pattern * repunit == n
    }

    private func hasRepeatedPattern(_ number: Int, exactlyTwice: Bool) -> Bool {
        guard number >= 10 else { return false }
        let digits = digitCount(number)

        for patLen in 1...(digits / 2) {
            guard digits % patLen == 0 else { continue }
            let reps = digits / patLen
            if exactlyTwice && reps != 2 { continue }
            if isRepeating(number, digits: digits, patLen: patLen) {
                return true
            }
        }
        return false
    }

    public func solvePart1(data: ParsedData) -> Int {
        var total = 0
        for range in data {
            for n in range.start...range.end {
                if hasRepeatedPattern(n, exactlyTwice: true) {
                    total += n
                }
            }
        }
        return total
    }

    public func solvePart2(data: ParsedData) -> Int {
        var total = 0
        for range in data {
            for n in range.start...range.end {
                if hasRepeatedPattern(n, exactlyTwice: false) {
                    total += n
                }
            }
        }
        return total
    }
}
