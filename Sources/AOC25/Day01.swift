struct Day01: DaySolver {
    struct Instruction: Equatable {
        let direction: Character
        let distance: Int
    }

    typealias ParsedData = [Instruction]
    typealias Result1 = Int
    typealias Result2 = Int

    let day = 1
    let testInput = """
        L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82
        """

    func parse(input: String) -> [Instruction]? {
        input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { Instruction(direction: $0.first!, distance: Int(String($0.dropFirst()))!) }
    }

    private func move(_ position: Int, direction: Character, steps: Int) -> Int {
        direction == "L"
            ? (position - steps + 100) % 100
            : (position + steps) % 100
    }

    func solvePart1(data: [Instruction]) -> Int {
        var position = 50
        var zeroCount = 0

        for instruction in data {
            position = move(
                position, direction: instruction.direction, steps: instruction.distance % 100)
            if position == 0 { zeroCount += 1 }
        }

        return zeroCount
    }

    func solvePart2(data: [Instruction]) -> Int {
        var position = 50
        var zeroCount = 0

        for instruction in data {
            for _ in 0..<instruction.distance {
                position = move(position, direction: instruction.direction, steps: 1)
                if position == 0 { zeroCount += 1 }
            }
        }

        return zeroCount
    }
}
