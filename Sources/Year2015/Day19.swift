import AoCCommon

public struct Day19: DaySolver {
    public struct Replacement: Equatable {
        let from: String
        let to: String
    }

    public struct Input: Equatable {
        let replacements: [Replacement]
        let molecule: String
    }

    public typealias ParsedData = Input
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 19
    public let testInput = """
        H => HO
        H => OH
        O => HH

        HOH
        """
    public let expectedTestResult1: Result1? = 4
    public let expectedTestResult2: Result2? = 2

    public func parse(input: String) -> Input? {
        let parts = input.components(separatedBy: "\n\n")
        guard parts.count == 2 else { return nil }

        let replacements = parts[0].split(separator: "\n").map { line in
            let components = line.split(separator: " ")
            return Replacement(from: String(components[0]), to: String(components[2]))
        }

        return Input(
            replacements: replacements,
            molecule: parts[1].trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public func solvePart1(data: Input) -> Int {
        Set(
            data.replacements.flatMap { replacement in
                allReplacements(in: data.molecule, from: replacement.from, to: replacement.to)
            }
        ).count
    }

    private func allReplacements(in molecule: String, from: String, to: String) -> [String] {
        var results: [String] = []
        var index = molecule.startIndex
        while let range = molecule.range(of: from, range: index..<molecule.endIndex) {
            results.append(molecule.replacingCharacters(in: range, with: to))
            index = molecule.index(after: range.lowerBound)
        }
        return results
    }

    public func solvePart2(data: Input) -> Int {
        let m = data.molecule
        let elements = m.filter { $0.isUppercase }.count
        let rn = count(m, "Rn")
        let ar = count(m, "Ar")
        let y = count(m, "Y")
        return elements - rn - ar - 2 * y - 1
    }

    private func count(_ string: String, _ substring: String) -> Int {
        string.components(separatedBy: substring).count - 1
    }
}
