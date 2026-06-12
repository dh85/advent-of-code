import AoCCommon

public struct Day20: DaySolver {
    public typealias ParsedData = Int
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 20
    public let testInput = "150"
    public let expectedTestResult1: Result1? = 8
    public let expectedTestResult2: Result2? = 8

    public func parse(input: String) throws -> Int {
        guard let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ParseError.invalidInput
        }
        return value
    }

    public func solvePart1(data: Int) -> Int {
        // Upper bound: house n gets at least n*10 presents (from elf n itself)
        // A tighter bound: sigma(n) >= n, and we need sigma(n)*10 >= target
        // Use target/10 but we know the answer is much lower in practice
        let limit = data / 10
        var houses = [Int](repeating: 0, count: limit)

        for elf in 1..<limit {
            var house = elf
            while house < limit {
                houses[house] += elf
                house += elf
            }
            if houses[elf] * 10 >= data { return elf }
        }

        return houses.firstIndex { $0 * 10 >= data } ?? 0
    }

    public func solvePart2(data: Int) -> Int {
        let limit = data / 11
        var houses = [Int](repeating: 0, count: limit)

        for elf in 1..<limit {
            let maxHouse = min(limit, elf * 51)
            var house = elf
            while house < maxHouse {
                houses[house] += elf
                house += elf
            }
            if houses[elf] * 11 >= data { return elf }
        }

        return houses.firstIndex { $0 * 11 >= data } ?? 0
    }
}
