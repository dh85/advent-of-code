import AoCCommon

public struct Day05: DaySolver {
    public typealias ParsedData = [String]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 5
    public let testInput = """
        ugknbfddgicrmopn
        aaa
        jchzalrnumimnmhp
        haegwjzuvuyypxyu
        dvszwmarrgswjxmb
        """
    public let expectedTestResult1: Result1? = 2
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) -> [String]? {
        input.lines
    }

    private func isNice1(_ string: String) -> Bool {
        let vowels = string.filter { "aeiou".contains($0) }.count >= 3
        let doubles = zip(string, string.dropFirst()).contains { $0 == $1 }
        let forbidden = ["ab", "cd", "pq", "xy"].allSatisfy { !string.contains($0) }
        return vowels && doubles && forbidden
    }

    private func isNice2(_ string: String) -> Bool {
        let chars = Array(string)
        let hasPair = (0..<chars.count - 1).contains { i in
            string.dropFirst(i + 2).contains(String(chars[i...i + 1]))
        }
        let hasRepeat = zip(chars, chars.dropFirst(2)).contains { $0 == $1 }
        return hasPair && hasRepeat
    }

    public func solvePart1(data: [String]) -> Int {
        data.filter(isNice1).count
    }

    public func solvePart2(data: [String]) -> Int {
        data.filter(isNice2).count
    }
}
