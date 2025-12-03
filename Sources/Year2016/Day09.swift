import AoCCommon

public struct Day09: DaySolver {
    public typealias ParsedData = [UInt8]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 9
    public let testInput = "(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"
    public let expectedTestResult1: Result1? = 238
    public let expectedTestResult2: Result2? = 445

    public func parse(input: String) -> [UInt8]? {
        Array(input.filter { !$0.isWhitespace }.utf8)
    }

    public func solvePart1(data: [UInt8]) -> Int {
        decompressedLength(data[...], recursive: false)
    }

    public func solvePart2(data: [UInt8]) -> Int {
        decompressedLength(data[...], recursive: true)
    }

    private func decompressedLength(_ data: ArraySlice<UInt8>, recursive: Bool) -> Int {
        var length = 0
        var i = data.startIndex

        while i < data.endIndex {
            if data[i] == UInt8(ascii: "(") {
                // Parse marker: (NxM)
                var charCount = 0
                var repeatCount = 0
                i += 1

                // Parse first number
                while data[i] != UInt8(ascii: "x") {
                    charCount = charCount * 10 + Int(data[i] - UInt8(ascii: "0"))
                    i += 1
                }
                i += 1  // skip 'x'

                // Parse second number
                while data[i] != UInt8(ascii: ")") {
                    repeatCount = repeatCount * 10 + Int(data[i] - UInt8(ascii: "0"))
                    i += 1
                }
                i += 1  // skip ')'

                let segment = data[i..<(i + charCount)]
                length +=
                    (recursive ? decompressedLength(segment, recursive: true) : charCount)
                    * repeatCount
                i += charCount
            } else {
                length += 1
                i += 1
            }
        }

        return length
    }
}
