import AoCCommon

public struct Day10: DaySolver {
    public struct Machine: Equatable {
        let target: Int  // bitmask of indicator light goal
        let buttons: [Int]  // each button as bitmask (for part 1)
        let buttonIndices: [[Int]]  // each button's list of indices
        let joltage: [Int]  // target joltage levels
    }

    public typealias ParsedData = [Machine]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 7
    public let expectedTestResult2: Result2? = 33

    public init() {}

    public let day = 10

    public let testInput = """
        [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
        """

    public func parse(input: String) throws -> [Machine] {
        input.lines.map { line in
            let bracketStart = line.firstIndex(of: "[")!
            let bracketEnd = line.firstIndex(of: "]")!
            let pattern = line[line.index(after: bracketStart)..<bracketEnd]
            var target = 0
            for (i, c) in pattern.enumerated() {
                if c == "#" { target |= 1 << i }
            }

            let buttonIndices: [[Int]] = line.matches(of: /\(([^)]+)\)/).compactMap { match in
                let nums = match.1.split(separator: ",").compactMap { Int($0) }
                return nums.isEmpty ? nil : nums
            }

            var buttons = [Int]()
            for indices in buttonIndices {
                var mask = 0
                for n in indices { mask |= 1 << n }
                buttons.append(mask)
            }

            let curlyStart = line.firstIndex(of: "{")!
            let curlyEnd = line.firstIndex(of: "}")!
            let joltageStr = line[line.index(after: curlyStart)..<curlyEnd]
            let joltage = joltageStr.split(separator: ",").map { Int($0)! }

            return Machine(
                target: target, buttons: buttons, buttonIndices: buttonIndices, joltage: joltage)
        }
    }

    public func solvePart1(data: ParsedData) -> Int {
        data.map { minPresses($0) }.sum()
    }

    private func minPresses(_ machine: Machine) -> Int {
        let n = machine.buttons.count
        var best = Int.max

        for mask in 0..<(1 << n) {
            let presses = mask.nonzeroBitCount
            guard presses < best else { continue }

            var state = 0
            for i in 0..<n where mask & (1 << i) != 0 {
                state ^= machine.buttons[i]
            }
            if state == machine.target {
                best = presses
            }
        }

        return best
    }

    public func solvePart2(data: ParsedData) -> Int {
        data.map { minJoltagePresses($0) }.sum()
    }

    /// Solve: minimize sum(x) subject to Ax = b, x >= 0, x integer
    /// Uses branch-and-bound DFS with pruning
    private func minJoltagePresses(_ machine: Machine) -> Int {
        let numCounters = machine.joltage.count
        let numButtons = machine.buttonIndices.count

        // For each button, which counters (< numCounters) it increments
        var cols = [[Int]](repeating: [], count: numButtons)
        for (j, indices) in machine.buttonIndices.enumerated() {
            cols[j] = indices.filter { $0 < numCounters }
        }

        let target = machine.joltage
        var best = Int.max

        func dfs(_ buttonIdx: Int, _ current: [Int], _ totalPresses: Int) {
            if totalPresses >= best { return }

            if buttonIdx == numButtons {
                if current == target { best = totalPresses }
                return
            }

            // Max presses for this button: limited by how much any affected counter can still grow
            var maxPresses: Int
            if cols[buttonIdx].isEmpty {
                maxPresses = 0
            } else {
                maxPresses = cols[buttonIdx].map { target[$0] - current[$0] }.min()!
            }

            for presses in 0...maxPresses {
                if totalPresses + presses >= best { break }
                var next = current
                for c in cols[buttonIdx] {
                    next[c] += presses
                }
                // Prune: no counter can exceed target
                var valid = true
                for c in cols[buttonIdx] {
                    if next[c] > target[c] {
                        valid = false
                        break
                    }
                }
                if valid {
                    dfs(buttonIdx + 1, next, totalPresses + presses)
                }
            }
        }

        dfs(0, [Int](repeating: 0, count: numCounters), 0)
        return best == Int.max ? 0 : best
    }
}
