import AoCCommon
import Foundation

public struct Day04: DaySolver {
    public struct Room: Equatable {
        let name: String
        let sectorID: Int
        let checksum: String

        var isReal: Bool {
            computedChecksum == checksum
        }

        private var computedChecksum: String {
            let frequency = name.filter(\.isLetter)
                .reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }

            return String(
                frequency.sorted { ($1.value, $0.key) < ($0.value, $1.key) }
                    .prefix(5)
                    .map(\.key)
            )
        }

        var decryptedName: String {
            name.map { char in
                guard char != "-" else { return " " }
                let base = Int(Character("a").asciiValue!)
                let shifted = (Int(char.asciiValue!) - base + sectorID) % 26
                return String(UnicodeScalar(base + shifted)!)
            }.joined()
        }
    }

    public typealias ParsedData = [Room]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 4
    public let testInput = """
        aaaaa-bbb-z-y-x-123[abxyz]
        a-b-c-d-e-f-g-h-987[abcde]
        not-a-real-room-404[oarel]
        totally-real-room-200[decoy]
        """

    public func parse(input: String) -> [Room]? {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .compactMap(parseRoom)
    }

    private func parseRoom(_ line: String) -> Room? {
        guard let bracketStart = line.firstIndex(of: "["),
            let bracketEnd = line.firstIndex(of: "]"),
            let lastDash = line[..<bracketStart].lastIndex(of: "-"),
            let sectorID = Int(line[line.index(after: lastDash)..<bracketStart])
        else { return nil }

        return Room(
            name: String(line[..<lastDash]),
            sectorID: sectorID,
            checksum: String(line[line.index(after: bracketStart)..<bracketEnd])
        )
    }

    public func solvePart1(data: [Room]) -> Int {
        data.filter(\.isReal).map(\.sectorID).sum()
    }

    public func solvePart2(data: [Room]) -> Int {
        data.filter(\.isReal)
            .first { $0.decryptedName.contains("northpole") }?
            .sectorID ?? 0
    }
}
