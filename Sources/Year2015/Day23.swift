import AoCCommon

public struct Day23: DaySolver {
    public enum Instruction: Equatable {
        case hlf(String)
        case tpl(String)
        case inc(String)
        case jmp(Int)
        case jie(String, Int)
        case jio(String, Int)
    }

    public typealias ParsedData = [Instruction]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 23
    public let testInput = """
        inc a
        jio a, +2
        tpl a
        inc a
        """
    public let expectedTestResult1: Result1? = 0
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) -> [Instruction]? {
        input.split(separator: "\n").map { line in
            let parts = line.replacingOccurrences(of: ",", with: "").split(separator: " ")
            switch parts[0] {
            case "hlf": return .hlf(String(parts[1]))
            case "tpl": return .tpl(String(parts[1]))
            case "inc": return .inc(String(parts[1]))
            case "jmp": return .jmp(Int(parts[1])!)
            case "jie": return .jie(String(parts[1]), Int(parts[2])!)
            case "jio": return .jio(String(parts[1]), Int(parts[2])!)
            default: fatalError()
            }
        }
    }

    public func solvePart1(data: [Instruction]) -> Int {
        execute(data, a: 0, b: 0).b
    }

    private func execute(_ program: [Instruction], a: Int, b: Int) -> (a: Int, b: Int) {
        var regs = ["a": a, "b": b]
        var ip = 0

        while program.indices.contains(ip) {
            switch program[ip] {
            case .hlf(let r):
                regs[r]! /= 2
                ip += 1
            case .tpl(let r):
                regs[r]! *= 3
                ip += 1
            case .inc(let r):
                regs[r]! += 1
                ip += 1
            case .jmp(let offset): ip += offset
            case .jie(let r, let offset): ip += regs[r]! % 2 == 0 ? offset : 1
            case .jio(let r, let offset): ip += regs[r]! == 1 ? offset : 1
            }
        }

        return (regs["a"]!, regs["b"]!)
    }

    public func solvePart2(data: [Instruction]) -> Int {
        execute(data, a: 1, b: 0).b
    }
}
