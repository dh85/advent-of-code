import AoCCommon

public struct Day11: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = String
    public typealias Result2 = String

    public init() {}

    public let day = 11
    public let testInput = "abcdefgh"
    public let expectedTestResult1: Result1? = "abcdffaa"
    public let expectedTestResult2: Result2? = "abcdffbb"

    public func parse(input: String) -> String? { input }

    private let badChars: Set<UInt8> = [UInt8(ascii: "i"), UInt8(ascii: "o"), UInt8(ascii: "l")]
    private let charA = UInt8(ascii: "a")
    private let charZ = UInt8(ascii: "z")

    private func increment(_ chars: inout [UInt8]) {
        var i = chars.count - 1
        while i >= 0 {
            if chars[i] == charZ {
                chars[i] = charA
                i -= 1
            } else {
                chars[i] += 1
                // Skip bad characters immediately
                if badChars.contains(chars[i]) {
                    chars[i] += 1
                    // Reset all following chars to 'a'
                    for j in (i + 1)..<chars.count {
                        chars[j] = charA
                    }
                }
                break
            }
        }
    }

    private func isValid(_ chars: [UInt8]) -> Bool {
        // Check for bad characters
        for c in chars {
            if badChars.contains(c) { return false }
        }

        // Check for straight of 3
        var hasStraight = false
        for i in 0..<(chars.count - 2) {
            if chars[i] + 1 == chars[i + 1] && chars[i + 1] + 1 == chars[i + 2] {
                hasStraight = true
                break
            }
        }
        if !hasStraight { return false }

        // Check for two different pairs
        var pairCount = 0
        var lastPairChar: UInt8 = 0
        var i = 0
        while i < chars.count - 1 {
            if chars[i] == chars[i + 1] && chars[i] != lastPairChar {
                pairCount += 1
                lastPairChar = chars[i]
                i += 2
                if pairCount >= 2 { return true }
            } else {
                i += 1
            }
        }

        return false
    }

    private func nextValid(after password: String) -> String {
        var chars = password.map { $0.asciiValue! }
        increment(&chars)
        while !isValid(chars) {
            increment(&chars)
        }
        return String(chars.map { Character(UnicodeScalar($0)) })
    }

    public func solvePart1(data: String) -> String {
        nextValid(after: data)
    }

    public func solvePart2(data: String) -> String {
        nextValid(after: solvePart1(data: data))
    }
}
