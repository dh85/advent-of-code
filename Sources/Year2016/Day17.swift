import AoCCommon
import Crypto
import Foundation

public struct Day17: DaySolver {
    public typealias ParsedData = String
    public typealias Result1 = String
    public typealias Result2 = Int

    public init() {}

    public let day = 17
    public let testInput = "ihgpwlah"
    public let expectedTestResult1: Result1? = "DDRRRD"
    public let expectedTestResult2: Result2? = 370

    public func parse(input: String) throws -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Check if a hex char means door is open (b-f)
    @inline(__always)
    private func isOpen(_ char: UInt8) -> Bool {
        char >= UInt8(ascii: "b") && char <= UInt8(ascii: "f")
    }

    // Get open doors from MD5 hash of passcode+path
    // Returns (up, down, left, right) as booleans
    private func openDoors(_ input: String) -> (Bool, Bool, Bool, Bool) {
        let digest = Insecure.MD5.hash(data: Data(input.utf8))
        let bytes = Array(digest)
        // First 4 hex chars = first 2 bytes, high/low nibbles
        let up = isOpen(
            (bytes[0] >> 4) + (bytes[0] >> 4 >= 10 ? UInt8(ascii: "a") - 10 : UInt8(ascii: "0")))
        let down = isOpen(
            (bytes[0] & 0xF) + ((bytes[0] & 0xF) >= 10 ? UInt8(ascii: "a") - 10 : UInt8(ascii: "0"))
        )
        let left = isOpen(
            (bytes[1] >> 4) + ((bytes[1] >> 4) >= 10 ? UInt8(ascii: "a") - 10 : UInt8(ascii: "0")))
        let right = isOpen(
            (bytes[1] & 0xF) + ((bytes[1] & 0xF) >= 10 ? UInt8(ascii: "a") - 10 : UInt8(ascii: "0"))
        )
        return (up, down, left, right)
    }

    // BFS to find shortest path to (3,3) from (0,0)
    public func solvePart1(data: String) -> String {
        // State: (x, y, path)
        var queue: [(Int, Int, String)] = [(0, 0, "")]

        while !queue.isEmpty {
            let (x, y, path) = queue.removeFirst()

            // Reached the vault
            if x == 3 && y == 3 {
                return path
            }

            let (up, down, left, right) = openDoors(data + path)

            // Try each direction
            if up && y > 0 {
                queue.append((x, y - 1, path + "U"))
            }
            if down && y < 3 {
                queue.append((x, y + 1, path + "D"))
            }
            if left && x > 0 {
                queue.append((x - 1, y, path + "L"))
            }
            if right && x < 3 {
                queue.append((x + 1, y, path + "R"))
            }
        }

        return ""  // No path found
    }

    // Find the longest path to the vault
    public func solvePart2(data: String) -> Int {
        var maxLength = 0
        var stack: [(Int, Int, String)] = [(0, 0, "")]

        while !stack.isEmpty {
            let (x, y, path) = stack.removeLast()

            // Reached the vault - record length but don't continue
            if x == 3 && y == 3 {
                maxLength = max(maxLength, path.count)
                continue
            }

            let (up, down, left, right) = openDoors(data + path)

            if up && y > 0 {
                stack.append((x, y - 1, path + "U"))
            }
            if down && y < 3 {
                stack.append((x, y + 1, path + "D"))
            }
            if left && x > 0 {
                stack.append((x - 1, y, path + "L"))
            }
            if right && x < 3 {
                stack.append((x + 1, y, path + "R"))
            }
        }

        return maxLength
    }
}
