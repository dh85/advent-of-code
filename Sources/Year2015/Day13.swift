import AoCCommon

public struct Day13: DaySolver {
    public struct Seating: Equatable {
        let happiness: [String: [String: Int]]
        let people: Set<String>
    }

    public typealias ParsedData = Seating
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 13
    public let testInput = """
        Alice would gain 54 happiness units by sitting next to Bob.
        Alice would lose 79 happiness units by sitting next to Carol.
        Alice would lose 2 happiness units by sitting next to David.
        Bob would gain 83 happiness units by sitting next to Alice.
        Bob would lose 7 happiness units by sitting next to Carol.
        Bob would lose 63 happiness units by sitting next to David.
        Carol would lose 62 happiness units by sitting next to Alice.
        Carol would gain 60 happiness units by sitting next to Bob.
        Carol would gain 55 happiness units by sitting next to David.
        David would gain 46 happiness units by sitting next to Alice.
        David would lose 7 happiness units by sitting next to Bob.
        David would gain 41 happiness units by sitting next to Carol.
        """
    public let expectedTestResult1: Result1? = 330
    public let expectedTestResult2: Result2? = 286

    public func parse(input: String) -> Seating? {
        var happiness: [String: [String: Int]] = [:]
        var people: Set<String> = []

        for line in input.lines {
            let parts = line.split(separator: " ")
            let (person, neighbor) = (String(parts[0]), String(parts[10].dropLast()))
            let value = Int(parts[3])! * (parts[2] == "gain" ? 1 : -1)

            people.insert(person)
            happiness[person, default: [:]][neighbor] = value
        }

        return Seating(happiness: happiness, people: people)
    }

    private func calculateHappiness(_ arrangement: [Int], _ matrix: [[Int]]) -> Int {
        let n = arrangement.count
        var total = 0
        for i in 0..<n {
            let person = arrangement[i]
            let left = arrangement[(i - 1 + n) % n]
            let right = arrangement[(i + 1) % n]
            total += matrix[person][left] + matrix[person][right]
        }
        return total
    }

    private func optimalHappiness(_ seating: Seating) -> Int {
        // Convert to index-based for faster lookup
        let people = Array(seating.people)
        let n = people.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
        for (i, p1) in people.enumerated() {
            for (j, p2) in people.enumerated() {
                matrix[i][j] = seating.happiness[p1]?[p2] ?? 0
            }
        }

        // Fix first person to reduce permutations (circular table)
        let others = Array(1..<n)
        return others.permutations().map { perm in
            calculateHappiness([0] + perm, matrix)
        }.max()!
    }

    public func solvePart1(data: Seating) -> Int {
        optimalHappiness(data)
    }

    public func solvePart2(data: Seating) -> Int {
        var happiness = data.happiness
        var people = data.people
        people.insert("Me")

        for person in data.people {
            happiness["Me", default: [:]][person] = 0
            happiness[person]!["Me"] = 0
        }

        return optimalHappiness(Seating(happiness: happiness, people: people))
    }
}
