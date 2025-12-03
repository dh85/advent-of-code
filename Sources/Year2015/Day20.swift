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

    public func parse(input: String) -> Int? {
        Int(input.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public func solvePart1(data: Int) -> Int {
        simulate(target: data, presentsPerElf: 10, maxVisits: nil)
    }

    public func solvePart2(data: Int) -> Int {
        simulate(target: data, presentsPerElf: 11, maxVisits: 50)
    }

    private func simulate(target: Int, presentsPerElf: Int, maxVisits: Int?) -> Int {
        let limit = target / presentsPerElf
        var houses = [Int](repeating: 0, count: limit)

        for elf in 1..<limit {
            let maxHouse = maxVisits.map { min(limit, elf * ($0 + 1)) } ?? limit
            for house in stride(from: elf, to: maxHouse, by: elf) {
                houses[house] += elf * presentsPerElf
            }
        }

        return houses.firstIndex { $0 >= target } ?? 0
    }
}
