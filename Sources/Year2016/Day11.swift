import AoCCommon

public struct Day11: DaySolver {
    public struct State: Hashable {
        var elevator: Int
        var pairs: [Pair]  // Sorted for canonical form

        struct Pair: Hashable, Comparable {
            var generator: Int  // Floor 0-3
            var microchip: Int  // Floor 0-3

            static func < (lhs: Pair, rhs: Pair) -> Bool {
                (lhs.generator, lhs.microchip) < (rhs.generator, rhs.microchip)
            }
        }

        var isGoal: Bool {
            pairs.allSatisfy { $0.generator == 3 && $0.microchip == 3 }
        }

        func isValid() -> Bool {
            for floor in 0...3 {
                var hasGenerator = false
                for pair in pairs {
                    if pair.generator == floor {
                        hasGenerator = true
                        break
                    }
                }
                if !hasGenerator { continue }
                for pair in pairs {
                    if pair.microchip == floor && pair.generator != floor {
                        return false
                    }
                }
            }
            return true
        }

        func canonical() -> State {
            State(elevator: elevator, pairs: pairs.sorted())
        }
    }

    public typealias ParsedData = State
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 11
    public let testInput = """
        The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
        The second floor contains a hydrogen generator.
        The third floor contains a lithium generator.
        The fourth floor contains nothing relevant.
        """
    public let expectedTestResult1: Result1? = 11
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> State {
        var elements: [String: (generator: Int, microchip: Int)] = [:]

        for (floor, line) in input.lines.enumerated() {
            // Find generators
            let genPattern = /(\w+) generator/
            for match in line.matches(of: genPattern) {
                let element = String(match.1)
                elements[element, default: (0, 0)].generator = floor
            }

            // Find microchips
            let chipPattern = /(\w+)-compatible microchip/
            for match in line.matches(of: chipPattern) {
                let element = String(match.1)
                elements[element, default: (0, 0)].microchip = floor
            }
        }

        let pairs = elements.values.map {
            State.Pair(generator: $0.generator, microchip: $0.microchip)
        }
        return State(elevator: 0, pairs: pairs.sorted())
    }

    private func solve(_ initial: State) -> Int {
        var queue: [(State, Int)] = [(initial.canonical(), 0)]
        var visited: Set<State> = [initial.canonical()]
        var index = 0

        while index < queue.count {
            let (state, steps) = queue[index]
            index += 1

            if state.isGoal { return steps }

            // Generate all possible moves
            let currentFloor = state.elevator
            let directions = currentFloor == 0 ? [1] : (currentFloor == 3 ? [-1] : [-1, 1])

            // Collect all items on current floor
            var items: [(pairIndex: Int, isGenerator: Bool)] = []
            for (i, pair) in state.pairs.enumerated() {
                if pair.generator == currentFloor {
                    items.append((i, true))
                }
                if pair.microchip == currentFloor {
                    items.append((i, false))
                }
            }

            // Try moving 1 or 2 items
            for dir in directions {
                let newFloor = currentFloor + dir
                var foundTwo = false

                // Moving 2 items (prefer when going up)
                for i in 0..<items.count {
                    for j in (i + 1)..<items.count {
                        var newState = state
                        newState.elevator = newFloor

                        let item1 = items[i]
                        let item2 = items[j]

                        if item1.isGenerator {
                            newState.pairs[item1.pairIndex].generator = newFloor
                        } else {
                            newState.pairs[item1.pairIndex].microchip = newFloor
                        }

                        if item2.isGenerator {
                            newState.pairs[item2.pairIndex].generator = newFloor
                        } else {
                            newState.pairs[item2.pairIndex].microchip = newFloor
                        }

                        let canonical = newState.canonical()
                        if canonical.isValid() && !visited.contains(canonical) {
                            visited.insert(canonical)
                            queue.append((canonical, steps + 1))
                            if dir == 1 { foundTwo = true }
                        }
                    }
                }

                // Moving 1 item — skip going up with 1 if we already moved 2 up
                if dir == 1 && foundTwo { continue }
                var foundOne = false
                for item in items {
                    var newState = state
                    newState.elevator = newFloor

                    if item.isGenerator {
                        newState.pairs[item.pairIndex].generator = newFloor
                    } else {
                        newState.pairs[item.pairIndex].microchip = newFloor
                    }

                    let canonical = newState.canonical()
                    if canonical.isValid() && !visited.contains(canonical) {
                        visited.insert(canonical)
                        queue.append((canonical, steps + 1))
                        if dir == -1 { foundOne = true }
                    }
                }

                // Skip moving 2 items down if we already moved 1 down
                // (already processed 2 above, so this prunes future states conceptually)
                _ = foundOne
            }
        }

        return -1
    }

    public func solvePart1(data: State) -> Int {
        solve(data)
    }

    public func solvePart2(data: State) -> Int {
        // Add elerium and dilithium pairs on floor 0
        var extended = data
        extended.pairs.append(State.Pair(generator: 0, microchip: 0))
        extended.pairs.append(State.Pair(generator: 0, microchip: 0))
        return solve(extended.canonical())
    }
}
