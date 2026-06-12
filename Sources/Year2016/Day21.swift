import AoCCommon

public struct Day21: DaySolver {
    public enum Operation {
        case swapPosition(Int, Int)
        case swapLetter(Character, Character)
        case rotateLeft(Int)
        case rotateRight(Int)
        case rotateBased(Character)
        case reverse(Int, Int)
        case move(Int, Int)
    }

    public typealias ParsedData = [Operation]
    public typealias Result1 = String
    public typealias Result2 = String

    public init() {}

    public let day = 21
    public let testInput = """
        swap position 4 with position 0
        swap letter d with letter b
        reverse positions 0 through 4
        rotate left 1 step
        move position 1 to position 4
        move position 3 to position 0
        rotate based on position of letter b
        rotate based on position of letter d
        """
    public let expectedTestResult1: Result1? = "decab"
    public let expectedTestResult2: Result2? = nil

    public func parse(input: String) throws -> [Operation] {
        input.lines.compactMap { line -> Operation? in
            let words = line.split(separator: " ")
            switch (words[0], words[1]) {
            case ("swap", "position"):
                return .swapPosition(Int(words[2])!, Int(words[5])!)
            case ("swap", "letter"):
                return .swapLetter(Character(String(words[2])), Character(String(words[5])))
            case ("rotate", "left"):
                return .rotateLeft(Int(words[2])!)
            case ("rotate", "right"):
                return .rotateRight(Int(words[2])!)
            case ("rotate", "based"):
                return .rotateBased(Character(String(words[6])))
            case ("reverse", _):
                return .reverse(Int(words[2])!, Int(words[4])!)
            case ("move", _):
                return .move(Int(words[2])!, Int(words[5])!)
            default:
                return nil
            }
        }
    }

    private func apply(_ op: Operation, to password: inout [Character]) {
        let n = password.count
        switch op {
        case .swapPosition(let x, let y):
            password.swapAt(x, y)

        case .swapLetter(let a, let b):
            if let i = password.firstIndex(of: a), let j = password.firstIndex(of: b) {
                password.swapAt(i, j)
            }

        case .rotateLeft(let steps):
            let s = steps % n
            password = Array(password[s...]) + Array(password[..<s])

        case .rotateRight(let steps):
            let s = steps % n
            password = Array(password[(n - s)...]) + Array(password[..<(n - s)])

        case .rotateBased(let letter):
            if let idx = password.firstIndex(of: letter) {
                var rotations = 1 + idx
                if idx >= 4 { rotations += 1 }
                rotations %= n
                password = Array(password[(n - rotations)...]) + Array(password[..<(n - rotations)])
            }

        case .reverse(let x, let y):
            password[x...y].reverse()

        case .move(let x, let y):
            let char = password.remove(at: x)
            password.insert(char, at: y)
        }
    }

    private func reverseApply(_ op: Operation, to password: inout [Character]) {
        let n = password.count
        switch op {
        case .swapPosition, .swapLetter, .reverse:
            // These are self-inverse
            apply(op, to: &password)

        case .rotateLeft(let steps):
            // Reverse of left is right
            apply(.rotateRight(steps), to: &password)

        case .rotateRight(let steps):
            // Reverse of right is left
            apply(.rotateLeft(steps), to: &password)

        case .rotateBased(let letter):
            // Need to find original position that would result in current position
            // For length 8: map from final position to left rotations needed
            // After rotation: newPos = (pos + 1 + pos + (pos >= 4 ? 1 : 0)) % n
            // Brute force: try all positions
            for origPos in 0..<n {
                var testPw = password
                var rotations = 1 + origPos
                if origPos >= 4 { rotations += 1 }
                rotations %= n
                // Undo this rotation (rotate left)
                let s = rotations
                testPw = Array(testPw[s...]) + Array(testPw[..<s])
                if let idx = testPw.firstIndex(of: letter), idx == origPos {
                    password = testPw
                    return
                }
            }

        case .move(let x, let y):
            // Reverse: move from y back to x
            apply(.move(y, x), to: &password)
        }
    }

    public func solvePart1(data: [Operation]) -> String {
        var password: [Character] =
            data.count < 20
            ? Array("abcde")
            : Array("abcdefgh")
        for op in data {
            apply(op, to: &password)
        }
        return String(password)
    }

    public func solvePart2(data: [Operation]) -> String {
        var password: [Character] = Array("fbgdceah")
        for op in data.reversed() {
            reverseApply(op, to: &password)
        }
        return String(password)
    }
}
