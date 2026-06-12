import AoCCommon

public struct Day23: DaySolver {
    // Instruction: (opcode, arg1, arg2)
    // opcode: 0=cpy, 1=inc, 2=dec, 3=jnz, 4=tgl
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
    public typealias Result2 = Int

    public init() {}

    public let day = 23
    public let testInput = """
        cpy 2 a
        tgl a
        tgl a
        tgl a
        cpy 1 a
        dec a
        dec a
        """
    public let expectedTestResult1: Result1? = 3
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
            case "tgl":
                return Instruction(op: 4, arg1: .value(0), arg2: parseArg(parts[1]))
            default:
                fatalError("Unknown instruction: \(parts[0])")
            }
        }
    }

    private func execute(_ program: [Instruction], initialA: Int) -> Int {
        var code = program
        var regs = [initialA, 0, 0, 0]
        var ip = 0

        func getVal(_ arg: Arg) -> Int {
            switch arg {
            case .value(let v): return v
            case .register(let r): return regs[r]
            }
        }

        func getReg(_ arg: Arg) -> Int? {
            if case .register(let r) = arg { return r }
            return nil
        }

        // Detect multiplication pattern:
        // cpy b c    (or any regs)
        // inc a
        // dec c
        // jnz c -2
        // dec d
        // jnz d -5
        // This computes: a += b * d, c = 0, d = 0
        func tryOptimizeMul() -> Bool {
            guard ip + 5 < code.count else { return false }

            let i0 = code[ip]  // cpy X c
            let i1 = code[ip + 1]  // inc a
            let i2 = code[ip + 2]  // dec c
            let i3 = code[ip + 3]  // jnz c -2
            let i4 = code[ip + 4]  // dec d
            let i5 = code[ip + 5]  // jnz d -5

            guard i0.op == 0,  // cpy
                i1.op == 1,  // inc
                i2.op == 2,  // dec
                i3.op == 3,  // jnz
                i4.op == 2,  // dec
                i5.op == 3  // jnz
            else { return false }

            guard let srcReg = getReg(i0.arg1) ?? (i0.arg1 == .value(getVal(i0.arg1)) ? nil : nil),
                let innerReg = getReg(i0.arg2),
                let targetReg = getReg(i1.arg2),
                let decInner = getReg(i2.arg2), decInner == innerReg,
                getReg(i3.arg1) == innerReg, i3.arg2 == .value(-2),
                let outerReg = getReg(i4.arg2),
                getReg(i5.arg1) == outerReg, i5.arg2 == .value(-5)
            else {
                // Also try with immediate value in cpy
                guard case .value(_) = i0.arg1,
                    let innerReg = getReg(i0.arg2),
                    let targetReg = getReg(i1.arg2),
                    let decInner = getReg(i2.arg2), decInner == innerReg,
                    getReg(i3.arg1) == innerReg, i3.arg2 == .value(-2),
                    let outerReg = getReg(i4.arg2),
                    getReg(i5.arg1) == outerReg, i5.arg2 == .value(-5)
                else { return false }

                // a += value * d
                let value = getVal(i0.arg1)
                regs[targetReg] += value * regs[outerReg]
                regs[innerReg] = 0
                regs[outerReg] = 0
                ip += 6
                return true
            }

            // a += b * d, c = 0, d = 0
            regs[targetReg] += regs[srcReg] * regs[outerReg]
            regs[innerReg] = 0
            regs[outerReg] = 0
            ip += 6
            return true
        }

        while ip >= 0 && ip < code.count {
            // Try multiplication optimization first
            if tryOptimizeMul() {
                continue
            }

            let instr = code[ip]

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
            case 4:  // tgl
                let targetIp = ip + getVal(instr.arg2)
                if targetIp >= 0 && targetIp < code.count {
                    let targetOp = code[targetIp].op
                    // For one-argument (inc, dec, tgl): inc <-> dec/tgl
                    // For two-argument (cpy, jnz): jnz <-> cpy
                    switch targetOp {
                    case 1: code[targetIp].op = 2  // inc -> dec
                    case 2, 4: code[targetIp].op = 1  // dec, tgl -> inc
                    case 0: code[targetIp].op = 3  // cpy -> jnz
                    case 3: code[targetIp].op = 0  // jnz -> cpy
                    default: break
                    }
                }
                ip += 1
            default:
                ip += 1
            }
        }

        return regs[0]
    }

    public func solvePart1(data: [Instruction]) -> Int {
        execute(data, initialA: 7)
    }

    public func solvePart2(data: [Instruction]) -> Int {
        execute(data, initialA: 12)
    }
}
