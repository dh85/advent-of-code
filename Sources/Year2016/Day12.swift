import AoCCommon

public struct Day12: DaySolver {
    // Compact instruction encoding: 4 bytes per instruction
    // Byte 0: opcode (0=cpy, 1=inc, 2=dec, 3=jnz)
    // Byte 1-2: operand1 (value or register marker 0x8000+reg)
    // Byte 3: operand2 (register index or jump offset)
    public struct Program: Equatable {
        var code: [UInt32]

        static let regMarker: Int16 = 0x4000

        static func encode(op: UInt8, val1: Int16, val2: Int8) -> UInt32 {
            UInt32(op) | (UInt32(bitPattern: Int32(val1)) << 8)
                | (UInt32(UInt8(bitPattern: val2)) << 24)
        }

        static func reg(_ c: Character) -> Int8 {
            Int8(c.asciiValue! - Character("a").asciiValue!)
        }
    }

    public typealias ParsedData = Program
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 12
    public let testInput = """
        cpy 41 a
        inc a
        inc a
        dec a
        jnz a 2
        dec a
        """
    public let expectedTestResult1: Result1? = 42
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) -> Program? {
        let code: [UInt32] = input.lines.map { line in
            let parts = line.split(separator: " ")
            let op = parts[0]

            func parseVal(_ s: Substring) -> Int16 {
                if let v = Int16(s) { return v }
                return Program.regMarker + Int16(Program.reg(s.first!))
            }

            switch op {
            case "cpy":
                return Program.encode(
                    op: 0, val1: parseVal(parts[1]), val2: Program.reg(parts[2].first!))
            case "inc":
                return Program.encode(op: 1, val1: 0, val2: Program.reg(parts[1].first!))
            case "dec":
                return Program.encode(op: 2, val1: 0, val2: Program.reg(parts[1].first!))
            case "jnz":
                return Program.encode(op: 3, val1: parseVal(parts[1]), val2: Int8(parts[2])!)
            default:
                fatalError("Unknown instruction: \(op)")
            }
        }
        return Program(code: code)
    }

    private func execute(_ program: Program, initialC: Int = 0) -> Int {
        var regs: (Int, Int, Int, Int) = (0, 0, initialC, 0)
        var ip = 0
        let code = program.code
        let count = code.count

        @inline(__always) func getReg(_ i: Int8) -> Int {
            switch i {
            case 0: return regs.0
            case 1: return regs.1
            case 2: return regs.2
            default: return regs.3
            }
        }

        @inline(__always) func setReg(_ i: Int8, _ v: Int) {
            switch i {
            case 0: regs.0 = v
            case 1: regs.1 = v
            case 2: regs.2 = v
            default: regs.3 = v
            }
        }

        @inline(__always) func getVal(_ v: Int16) -> Int {
            v >= Program.regMarker ? getReg(Int8(v - Program.regMarker)) : Int(v)
        }

        while ip >= 0 && ip < count {
            let instr = code[ip]
            let op = UInt8(instr & 0xFF)
            let val1 = Int16(bitPattern: UInt16((instr >> 8) & 0xFFFF))
            let val2 = Int8(bitPattern: UInt8(instr >> 24))

            switch op {
            case 0:
                setReg(val2, getVal(val1))
                ip += 1  // cpy
            case 1:
                setReg(val2, getReg(val2) + 1)
                ip += 1  // inc
            case 2:
                setReg(val2, getReg(val2) - 1)
                ip += 1  // dec
            default:  // jnz
                ip += getVal(val1) != 0 ? Int(val2) : 1
            }
        }

        return regs.0
    }

    public func solvePart1(data: Program) -> Int {
        execute(data)
    }

    public func solvePart2(data: Program) -> Int {
        execute(data, initialC: 1)
    }
}
