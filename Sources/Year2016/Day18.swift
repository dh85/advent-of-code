import AoCCommon

public struct Day18: DaySolver {
    public struct TrapRow: Equatable {
        let bits: [UInt64]
        let width: Int
    }

    public typealias ParsedData = TrapRow
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 18
    public let testInput = ".^^.^.^^^^"
    public let expectedTestResult1: Result1? = 38
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> TrapRow {
        let chars = Array(input.trimmingCharacters(in: .whitespacesAndNewlines))
        let width = chars.count
        let words = (width + 63) / 64
        var row = [UInt64](repeating: 0, count: words)
        for (i, c) in chars.enumerated() {
            if c == "^" {
                row[i / 64] |= 1 << (i % 64)
            }
        }
        return TrapRow(bits: row, width: width)
    }

    @inline(__always)
    private func countTraps(_ row: [UInt64], width: Int) -> Int {
        let words = row.count
        var traps = 0
        for i in 0..<(words - 1) {
            traps += row[i].nonzeroBitCount
        }
        let remainder = width % 64
        if remainder == 0 {
            traps += row[words - 1].nonzeroBitCount
        } else {
            traps += (row[words - 1] & ((1 << remainder) - 1)).nonzeroBitCount
        }
        return traps
    }

    private func solve(_ initial: TrapRow, rows: Int) -> Int {
        let width = initial.width
        let words = initial.bits.count
        var current = initial.bits
        var next = [UInt64](repeating: 0, count: words)
        var safeCount = width - countTraps(current, width: width)

        let mask: UInt64 = width % 64 == 0 ? ~0 : (1 << (width % 64)) - 1

        for _ in 1..<rows {
            for w in 0..<words {
                // Left neighbor of position i is position i-1
                // Shift whole row LEFT by 1: bit i gets value of bit i-1
                var left: UInt64 = current[w] << 1
                if w > 0 { left |= current[w - 1] >> 63 }

                // Right neighbor of position i is position i+1
                // Shift whole row RIGHT by 1: bit i gets value of bit i+1
                var right: UInt64 = current[w] >> 1
                if w < words - 1 { right |= current[w + 1] << 63 }

                next[w] = left ^ right
            }
            next[words - 1] &= mask

            safeCount += width - countTraps(next, width: width)
            swap(&current, &next)
        }

        return safeCount
    }

    public func solvePart1(data: TrapRow) -> Int {
        let rows = data.width == 10 ? 10 : 40
        return solve(data, rows: rows)
    }

    public func solvePart2(data: TrapRow) -> Int {
        solve(data, rows: 400000)
    }
}
