import AoCCommon

public struct Day16: DaySolver {
    public typealias ParsedData = [UInt8]
    public typealias Result1 = String
    public typealias Result2 = String

    public init() {}

    public let day = 16
    public let testInput = "10000"
    public let expectedTestResult1: Result1? = "01100"
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> [UInt8] {
        input.trimmingCharacters(in: .whitespacesAndNewlines).map {
            $0 == "1" ? UInt8(1) : UInt8(0)
        }
    }

    private func solve(_ initial: [UInt8], diskSize: Int) -> String {
        var data = [UInt8](repeating: 0, count: diskSize)

        for (i, b) in initial.enumerated() {
            data[i] = b
        }

        var len = initial.count
        while len < diskSize {
            let newLen = min(len * 2 + 1, diskSize)
            // Middle separator
            if len < diskSize {
                data[len] = 0
            }
            // Append reversed and flipped
            var writePos = len + 1
            var readPos = len - 1
            while writePos < newLen {
                data[writePos] = data[readPos] ^ 1
                writePos += 1
                readPos -= 1
            }
            len = newLen
        }

        // Checksum in-place using XOR: same = 1, different = 0
        // data[i] ^ data[i+1] gives 0 when same, 1 when different
        // We want 1 when same, so: 1 - (data[i] ^ data[i+1]) = data[i] ^ data[i+1] ^ 1
        while len % 2 == 0 {
            var write = 0
            var read = 0
            while read < len {
                data[write] = data[read] ^ data[read + 1] ^ 1
                write += 1
                read += 2
            }
            len = write
        }

        var result = ""
        result.reserveCapacity(len)
        for i in 0..<len {
            result.append(data[i] == 1 ? "1" : "0")
        }
        return result
    }

    public func solvePart1(data: [UInt8]) -> String {
        let diskSize = data.count == 5 ? 20 : 272
        return solve(data, diskSize: diskSize)
    }

    public func solvePart2(data: [UInt8]) -> String {
        solve(data, diskSize: 35_651_584)
    }
}
