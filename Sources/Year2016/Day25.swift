import AoCCommon

public struct Day25: DaySolver {
    // Instruction: (opcode, arg1, arg2)
    // opcode: 0=cpy, 1=inc, 2=dec, 3=jnz, 4=out
    // args: Either .value(Int) or .register(Int) where register is 0-3 for a-d

    public enum Arg: Equatable {
        case value(Int)
        case register(Int)
    }

    public struct Instruction: Equatable {
        var op: Int
        var arg1: Arg
        var arg2: Arg
    }

    public typealias ParsedData = [Instruction]
    public typealias Result1 = Int
    public typealias Result2 = String

    public init() {}

    public let day = 25
    public let testInput = ""
    public let expectedTestResult1: Result1? = nil
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> [Instruction] {
        input.lines.map { line in
            let parts = line.split(separator: " ")

            func parseArg(_ s: Substring) -> Arg {
                if let v = Int(s) { return .value(v) }
                return .register(Int(s.first!.asciiValue! - Character("a").asciiValue!))
            }

            switch parts[0] {
            case "cpy":
                return Instruction(op: 0, arg1: parseArg(parts[1]), arg2: parseArg(parts[2]))
            case "inc":
                return Instruction(op: 1, arg1: .value(0), arg2: parseArg(parts[1]))
            case "dec":
                return Instruction(op: 2, arg1: .value(0), arg2: parseArg(parts[1]))
            case "jnz":
                return Instruction(op: 3, arg1: parseArg(parts[1]), arg2: parseArg(parts[2]))
            case "out":
                return Instruction(op: 4, arg1: parseArg(parts[1]), arg2: .value(0))
            default:
                fatalError("Unknown instruction: \(parts[0])")
            }
        }
    }

    // Returns true if the program outputs a valid clock signal (0,1,0,1,...)
    // We detect this by checking if we reach the same state twice
    private func producesClockSignal(_ program: [Instruction], initialA: Int) -> Bool {
        var regs = [initialA, 0, 0, 0]
        var ip = 0
        var outputCount = 0
        var expectedOutput = 0
        var seenStates = Set<[Int]>()

        func getVal(_ arg: Arg) -> Int {
            switch arg {
            case .value(let v): return v
            case .register(let r): return regs[r]
            }
        }

        // Limit iterations to detect infinite loops
        var iterations = 0
        let maxIterations = 1_000_000

        while ip >= 0 && ip < program.count && iterations < maxIterations {
            iterations += 1
            let instr = program[ip]

            switch instr.op {
            case 0:  // cpy
                if case .register(let r) = instr.arg2 {
                    regs[r] = getVal(instr.arg1)
                }
                ip += 1
            case 1:  // inc
                if case .register(let r) = instr.arg2 {
                    regs[r] += 1
                }
                ip += 1
            case 2:  // dec
                if case .register(let r) = instr.arg2 {
                    regs[r] -= 1
                }
                ip += 1
            case 3:  // jnz
                let condition = getVal(instr.arg1)
                let offset = getVal(instr.arg2)
                ip += condition != 0 ? offset : 1
            case 4:  // out
                let output = getVal(instr.arg1)
                if output != expectedOutput {
                    return false  // Not alternating correctly
                }
                expectedOutput = 1 - expectedOutput  // Toggle expected
                outputCount += 1

                // After an output, check if we've seen this state before
                // State = (ip+1, regs) - if we loop back with same state, it's infinite
                let state = [ip + 1, regs[0], regs[1], regs[2], regs[3]]
                if seenStates.contains(state) && outputCount >= 10 {
                    // We're in a cycle that produces correct output
                    return true
                }
                seenStates.insert(state)
                ip += 1
            default:
                ip += 1
            }
        }

        return false
    }

    public func solvePart1(data: [Instruction]) -> Int {
        // Analyze the code: it computes d = a + (c * b) where c and b are constants
        // Then outputs the binary digits of d in a loop
        // For clock signal 0,1,0,1... we need d to have alternating bits: ...10101010

        // Find the constants from the program (first cpy instructions to b and c)
        // cpy a d, cpy C c, cpy B b, then nested loops compute d = a + C*B
        var c: Int? = nil
        var b: Int? = nil
        for instr in data {
            if instr.op == 0 {  // cpy
                if case .value(let v) = instr.arg1 {
                    if case .register(let r) = instr.arg2 {
                        if r == 2 && c == nil { c = v }  // c register (first one)
                        if r == 1 && b == nil { b = v }  // b register (first one)
                    }
                }
            }
            if c != nil && b != nil { break }
        }

        guard let cVal = c, let bVal = b else { return -1 }
        let offset = cVal * bVal  // The constant added to a

        // We need a + offset to have pattern ...10101010 in binary
        // Pattern 10101010... (LSB first outputting 0,1,0,1...) means LSB is 0
        // So we need numbers like 2, 10, 42, 170, 682, 2730, 10922, ...
        // These are 0b10, 0b1010, 0b101010, etc.

        // Find smallest a > 0 such that a + offset has alternating bits starting with 0
        // Generate alternating bit numbers and find smallest > offset
        var pattern = 2  // 0b10
        while pattern <= offset {
            pattern = (pattern << 2) | 2  // 0b1010, 0b101010, etc.
        }

        // pattern is now the smallest alternating-bit number > offset
        // But we might need to check a few to find one where a > 0
        while true {
            let a = pattern - offset
            if a > 0 {
                return a
            }
            pattern = (pattern << 2) | 2
        }
    }

    public func solvePart2(data: [Instruction]) -> String {
        // Day 25 Part 2 is traditionally just "click the button" after completing all stars
        "🎄"
    }
}
