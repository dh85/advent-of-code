import AoCCommon

public struct Day07: DaySolver {
    public enum Gate: Equatable {
        case value(UInt16)
        case wire(String)
        case and(String, String)
        case or(String, String)
        case lshift(String, Int)
        case rshift(String, Int)
        case not(String)
    }

    public typealias ParsedData = [String: Gate]
    public typealias Result1 = UInt16
    public typealias Result2 = UInt16

    public init() {}

    public let day = 7
    public let testInput = """
        123 -> x
        456 -> y
        x AND y -> d
        x OR y -> e
        x LSHIFT 2 -> f
        y RSHIFT 2 -> g
        NOT x -> h
        NOT y -> i
        """
    public let expectedTestResult1: Result1? = 0
    public let expectedTestResult2: Result2? = 0

    public func parse(input: String) -> [String: Gate]? {
        var circuit: [String: Gate] = [:]

        for line in input.lines {
            let parts = line.components(separatedBy: " -> ")
            let tokens = parts[0].components(separatedBy: " ")

            let gate: Gate
            if tokens.count == 1 {
                gate = UInt16(tokens[0]) != nil ? .value(UInt16(tokens[0])!) : .wire(tokens[0])
            } else if tokens[0] == "NOT" {
                gate = .not(tokens[1])
            } else if tokens[1] == "AND" {
                gate = .and(tokens[0], tokens[2])
            } else if tokens[1] == "OR" {
                gate = .or(tokens[0], tokens[2])
            } else if tokens[1] == "LSHIFT" {
                gate = .lshift(tokens[0], Int(tokens[2])!)
            } else {
                gate = .rshift(tokens[0], Int(tokens[2])!)
            }

            circuit[parts[1]] = gate
        }

        return circuit
    }

    private func resolve(_ wire: String, _ circuit: [String: Gate], _ cache: inout [String: UInt16])
        -> UInt16
    {
        if let cached = cache[wire] { return cached }
        if let value = UInt16(wire) { return value }
        guard let gate = circuit[wire] else { return 0 }

        let result =
            switch gate {
            case .value(let v): v
            case .wire(let w): resolve(w, circuit, &cache)
            case .and(let a, let b): resolve(a, circuit, &cache) & resolve(b, circuit, &cache)
            case .or(let a, let b): resolve(a, circuit, &cache) | resolve(b, circuit, &cache)
            case .lshift(let w, let n): resolve(w, circuit, &cache) << n
            case .rshift(let w, let n): resolve(w, circuit, &cache) >> n
            case .not(let w): ~resolve(w, circuit, &cache)
            }

        cache[wire] = result
        return result
    }

    private func solveFor(_ wire: String, _ circuit: [String: Gate]) -> UInt16 {
        var cache: [String: UInt16] = [:]
        return resolve(wire, circuit, &cache)
    }

    public func solvePart1(data: [String: Gate]) -> UInt16 {
        solveFor("a", data)
    }

    public func solvePart2(data: [String: Gate]) -> UInt16 {
        var circuit = data
        circuit["b"] = .value(solveFor("a", data))
        return solveFor("a", circuit)
    }
}
