import AoCCommon

public struct Day10: DaySolver {
    public struct Rule: Equatable {
        let lowToBot: Bool
        let lowId: Int
        let highToBot: Bool
        let highId: Int
    }

    public struct Value: Equatable {
        let chip: Int
        let bot: Int
    }

    public struct Input: Equatable {
        let values: [Value]
        let rules: [Int: Rule]
    }

    public typealias ParsedData = Input
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 10
    public let testInput = """
        value 5 goes to bot 2
        bot 2 gives low to bot 1 and high to bot 0
        value 3 goes to bot 1
        bot 1 gives low to output 1 and high to bot 0
        bot 0 gives low to output 2 and high to output 0
        value 2 goes to bot 2
        """
    public let expectedTestResult1: Result1? = 2
    public let expectedTestResult2: Result2? = 30

    public func parse(input: String) -> Input? {
        var values: [Value] = []
        var rules: [Int: Rule] = [:]

        for line in input.lines {
            let nums = line.integers
            if line.hasPrefix("value") {
                values.append(Value(chip: nums[0], bot: nums[1]))
            } else {
                rules[nums[0]] = Rule(
                    lowToBot: line.contains("low to bot"),
                    lowId: nums[1],
                    highToBot: line.contains("high to bot"),
                    highId: nums[2]
                )
            }
        }
        return Input(values: values, rules: rules)
    }

    private func simulate(_ input: Input, targetLow: Int, targetHigh: Int) -> (
        bot: Int, outputs: [Int]
    ) {
        var bots = [[Int]](repeating: [], count: 256)
        var outputs = [Int](repeating: 0, count: 32)
        var comparingBot = -1

        for v in input.values {
            bots[v.bot].append(v.chip)
        }

        var queue = (0..<256).filter { bots[$0].count == 2 }

        while let bot = queue.popLast() {
            let chips = bots[bot]
            guard chips.count == 2 else { continue }

            let (low, high) = chips[0] < chips[1] ? (chips[0], chips[1]) : (chips[1], chips[0])

            if low == targetLow && high == targetHigh {
                comparingBot = bot
            }

            guard let rule = input.rules[bot] else { continue }
            bots[bot] = []

            if rule.lowToBot {
                bots[rule.lowId].append(low)
                if bots[rule.lowId].count == 2 { queue.append(rule.lowId) }
            } else {
                outputs[rule.lowId] = low
            }

            if rule.highToBot {
                bots[rule.highId].append(high)
                if bots[rule.highId].count == 2 { queue.append(rule.highId) }
            } else {
                outputs[rule.highId] = high
            }
        }

        return (comparingBot, outputs)
    }

    public func solvePart1(data: Input) -> Int {
        let isTest = data.values.count < 10
        let (targetLow, targetHigh) = isTest ? (2, 5) : (17, 61)
        return simulate(data, targetLow: targetLow, targetHigh: targetHigh).bot
    }

    public func solvePart2(data: Input) -> Int {
        let outputs = simulate(data, targetLow: 17, targetHigh: 61).outputs
        return outputs[0] * outputs[1] * outputs[2]
    }
}
