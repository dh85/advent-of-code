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

    public func parse(input: String) throws -> Program {
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
            // Detect addition pattern: inc X / dec Y / jnz Y -2
            if ip + 2 < count {
                let i0 = code[ip]
                let i1 = code[ip + 1]
                let i2 = code[ip + 2]

                if UInt8(i0 & 0xFF) == 1 && UInt8(i1 & 0xFF) == 2 && UInt8(i2 & 0xFF) == 3 {
                    let regX = Int8(bitPattern: UInt8(i0 >> 24))
                    let regY = Int8(bitPattern: UInt8(i1 >> 24))
                    let jnzVal = Int16(bitPattern: UInt16((i2 >> 8) & 0xFFFF))
                    let jnzOff = Int8(bitPattern: UInt8(i2 >> 24))

                    if jnzOff == -2 && jnzVal == Program.regMarker + Int16(regY) {
                        setReg(regX, getReg(regX) + getReg(regY))
                        setReg(regY, 0)
                        ip += 3
                        continue
                    }
                }
            }

            // Detect multiply pattern: inc X / dec Y / jnz Y -2 / dec Z / jnz Z -5
            if ip + 4 < count {
                let i0 = code[ip]
                let i1 = code[ip + 1]
                let i2 = code[ip + 2]
                let i3 = code[ip + 3]
                let i4 = code[ip + 4]

                let op0 = UInt8(i0 & 0xFF)
                let op1 = UInt8(i1 & 0xFF)
                let op2 = UInt8(i2 & 0xFF)
                let op3 = UInt8(i3 & 0xFF)
                let op4 = UInt8(i4 & 0xFF)

                if op0 == 1 && op1 == 2 && op2 == 3 && op3 == 2 && op4 == 3 {
                    let regX = Int8(bitPattern: UInt8(i0 >> 24))
                    let regY = Int8(bitPattern: UInt8(i1 >> 24))
                    let jnz2val = Int16(bitPattern: UInt16((i2 >> 8) & 0xFFFF))
                    let jnz2off = Int8(bitPattern: UInt8(i2 >> 24))
                    let regZ = Int8(bitPattern: UInt8(i3 >> 24))
                    let jnz4val = Int16(bitPattern: UInt16((i4 >> 8) & 0xFFFF))
                    let jnz4off = Int8(bitPattern: UInt8(i4 >> 24))

                    if jnz2off == -2 && jnz4off == -5
                        && jnz2val == Program.regMarker + Int16(regY)
                        && jnz4val == Program.regMarker + Int16(regZ)
                    {
                        setReg(regX, getReg(regX) + getReg(regY) * getReg(regZ))
                        setReg(regY, 0)
                        setReg(regZ, 0)
                        ip += 5
                        continue
                    }
                }
            }

            let instr = code[ip]
            let op = UInt8(instr & 0xFF)
            let val1 = Int16(bitPattern: UInt16((instr >> 8) & 0xFFFF))
            let val2 = Int8(bitPattern: UInt8(instr >> 24))

            switch op {
            case 0:
                setReg(val2, getVal(val1))
                ip += 1
            case 1:
                setReg(val2, getReg(val2) + 1)
                ip += 1
            case 2:
                setReg(val2, getReg(val2) - 1)
                ip += 1
            default:
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
