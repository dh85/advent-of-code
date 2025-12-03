import AoCCommon

public struct Day16: DaySolver {
    public struct Sue: Equatable {
        let number: Int
        let properties: [String: Int]
    }

    public typealias ParsedData = [Sue]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 16
    public let testInput = """
        Sue 1: cars: 9, akitas: 3, goldfish: 0
        Sue 2: akitas: 9, children: 3, samoyeds: 9
        """
    public let expectedTestResult1: Result1? = 0
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) -> [Sue]? {
        input.lines.map { line in
            let nums = line.integers
            let parts = line.replacingOccurrences(of: ",", with: "").replacingOccurrences(
                of: ":", with: ""
            ).split(separator: " ")
            var properties: [String: Int] = [:]

            for i in stride(from: 2, to: parts.count, by: 2) {
                properties[String(parts[i])] = Int(parts[i + 1])!
            }

            return Sue(number: nums[0], properties: properties)
        }
    }

    private let target: [String: Int] = [
        "children": 3,
        "cats": 7,
        "samoyeds": 2,
        "pomeranians": 3,
        "akitas": 0,
        "vizslas": 0,
        "goldfish": 5,
        "trees": 3,
        "cars": 2,
        "perfumes": 1,
    ]

    public func solvePart1(data: [Sue]) -> Int {
        data.first { sue in
            sue.properties.allSatisfy { (key, value) in
                target[key] == value
            }
        }?.number ?? 0
    }

    public func solvePart2(data: [Sue]) -> Int {
        data.first { sue in
            sue.properties.allSatisfy { (key, value) in
                guard let targetValue = target[key] else { return true }
                switch key {
                case "cats", "trees": return value > targetValue
                case "pomeranians", "goldfish": return value < targetValue
                default: return value == targetValue
                }
            }
        }?.number ?? 0
    }
}
