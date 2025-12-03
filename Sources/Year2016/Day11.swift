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
            // For each floor, check if any unpaired microchip is with a generator
            for floor in 0...3 {
                let generators = pairs.filter { $0.generator == floor }
                let chips = pairs.filter { $0.microchip == floor }

                // If there are generators on this floor
                if !generators.isEmpty {
                    // Check each chip on this floor
                    for pair in chips {
                        // If the chip's generator is NOT on this floor, it gets fried
                        if pair.generator != floor {
                            return false
                        }
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

    public func parse(input: String) -> State? {
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

                // Moving 2 items
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
                        }
                    }
                }

                // Moving 1 item
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
                    }
                }
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
