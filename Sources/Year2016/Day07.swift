import AoCCommon
import Foundation

public struct Day07: DaySolver {
    public struct IPv7: Equatable {
        let supernets: [String]  // Outside brackets
        let hypernets: [String]  // Inside brackets

        var supportsTLS: Bool {
            supernets.contains { $0.containsABBA } && !hypernets.contains { $0.containsABBA }
        }

        var supportsSSL: Bool {
            supernets.flatMap(\.abas).contains { aba in
                hypernets.contains { $0.contains(aba.bab) }
            }
        }
    }

    public typealias ParsedData = [IPv7]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 2
    public let expectedTestResult2: Result2? = 0

    public init() {}

    public let day = 7
    public let testInput = """
        abba[mnop]qrst
        abcd[bddb]xyyx
        aaaa[qwer]tyui
        ioxxoj[asdfgh]zxcvbn
        """

    public func parse(input: String) throws -> [IPv7] {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { line in
                var supernets: [String] = []
                var hypernets: [String] = []
                var current = ""

                for char in line {
                    switch char {
                    case "[":
                        supernets.append(current)
                        current = ""
                    case "]":
                        hypernets.append(current)
                        current = ""
                    default:
                        current.append(char)
                    }
                }
                if !current.isEmpty {
                    supernets.append(current)
                }

                return IPv7(supernets: supernets, hypernets: hypernets)
            }
    }

    public func solvePart1(data: [IPv7]) -> Int {
        data.count { $0.supportsTLS }
    }

    public func solvePart2(data: [IPv7]) -> Int {
        data.count { $0.supportsSSL }
    }
}

private struct ABA {
    let a: Character
    let b: Character

    var bab: String { String([b, a, b]) }
}

extension String {
    fileprivate var containsABBA: Bool {
        let chars = Array(self)
        guard chars.count >= 4 else { return false }
        for i in 0...(chars.count - 4) {
            if chars[i] == chars[i + 3] && chars[i + 1] == chars[i + 2] && chars[i] != chars[i + 1]
            {
                return true
            }
        }
        return false
    }

    fileprivate var abas: [ABA] {
        let chars = Array(self)
        guard chars.count >= 3 else { return [] }
        var result: [ABA] = []
        for i in 0...(chars.count - 3) {
            if chars[i] == chars[i + 2] && chars[i] != chars[i + 1] {
                result.append(ABA(a: chars[i], b: chars[i + 1]))
            }
        }
        return result
    }
}
