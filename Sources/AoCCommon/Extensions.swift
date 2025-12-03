import Foundation

// MARK: - String Extensions

extension String {
    /// Returns all integers found in the string (including negative numbers)
    public var integers: [Int] {
        matches(of: /-?\d+/).compactMap { Int($0.output) }
    }

    /// Returns non-empty lines
    public var lines: [String] {
        components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
}

// MARK: - Sequence Extensions

extension Sequence where Element: AdditiveArithmetic {
    /// Returns the sum of all elements
    public func sum() -> Element {
        reduce(.zero, +)
    }
}

extension Sequence where Element: Numeric {
    /// Returns the product of all elements
    public func product() -> Element {
        reduce(1, *)
    }
}

extension Sequence where Element: Hashable {
    /// Returns a dictionary of element frequencies
    public func frequencies() -> [Element: Int] {
        reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
}

// MARK: - Collection Extensions

extension Collection {
    /// Returns all permutations of the collection (Heap's algorithm)
    public func permutations() -> [[Element]] {
        guard count > 1 else { return [Array(self)] }
        var result: [[Element]] = []
        var array = Array(self)

        func permute(_ n: Int) {
            if n == 1 {
                result.append(array)
                return
            }
            for i in 0..<n {
                permute(n - 1)
                array.swapAt(n % 2 == 0 ? i : 0, n - 1)
            }
        }

        permute(array.count)
        return result
    }

    /// Splits the collection into chunks of the specified size
    public func chunks(of size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { offset in
            Array(dropFirst(offset).prefix(size))
        }
    }
}

// MARK: - Point

public struct Point: Hashable, Sendable, CustomStringConvertible {
    public var x: Int
    public var y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public static let zero = Point(0, 0)
    public static let up = Point(0, -1)
    public static let down = Point(0, 1)
    public static let left = Point(-1, 0)
    public static let right = Point(1, 0)

    public static let cardinalDirections: [Point] = [.up, .right, .down, .left]
    public static let allDirections: [Point] = [
        Point(-1, -1), .up, Point(1, -1),
        .left, .right,
        Point(-1, 1), .down, Point(1, 1),
    ]

    public var description: String { "(\(x), \(y))" }

    public var manhattanDistance: Int { abs(x) + abs(y) }

    public func manhattanDistance(to other: Point) -> Int {
        (self - other).manhattanDistance
    }

    public var neighbors: [Point] { Self.cardinalDirections.map { self + $0 } }
    public var neighborsWithDiagonals: [Point] { Self.allDirections.map { self + $0 } }

    public var rotatedLeft: Point { Point(y, -x) }
    public var rotatedRight: Point { Point(-y, x) }
}

extension Point {
    public static func + (lhs: Point, rhs: Point) -> Point {
        Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static func - (lhs: Point, rhs: Point) -> Point {
        Point(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    public static func * (lhs: Point, rhs: Int) -> Point {
        Point(lhs.x * rhs, lhs.y * rhs)
    }

    public static func += (lhs: inout Point, rhs: Point) { lhs = lhs + rhs }
    public static func -= (lhs: inout Point, rhs: Point) { lhs = lhs - rhs }
}

// MARK: - Grid

public struct Grid<T: Equatable>: Equatable {
    public var data: [[T]]

    public var rows: Int { data.count }
    public var cols: Int { data.first?.count ?? 0 }

    public init(_ data: [[T]]) {
        self.data = data
    }

    public init(rows: Int, cols: Int, initial: T) {
        data = Array(repeating: Array(repeating: initial, count: cols), count: rows)
    }

    public init(parsing string: String, transform: (Character) -> T) {
        data = string.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.map(transform) }
    }

    public subscript(row: Int, col: Int) -> T {
        get { data[row][col] }
        set { data[row][col] = newValue }
    }

    public subscript(point: Point) -> T {
        get { data[point.y][point.x] }
        set { data[point.y][point.x] = newValue }
    }

    public func contains(_ point: Point) -> Bool {
        (0..<cols).contains(point.x) && (0..<rows).contains(point.y)
    }

    public func neighbors(of point: Point, includeDiagonals: Bool = false) -> [Point] {
        (includeDiagonals ? point.neighborsWithDiagonals : point.neighbors)
            .filter { contains($0) }
    }

    public var allPoints: [Point] {
        (0..<rows).flatMap { y in (0..<cols).map { x in Point(x, y) } }
    }

    public func first(where predicate: (T) -> Bool) -> Point? {
        allPoints.first { predicate(self[$0]) }
    }
}

extension Grid where T == Character {
    public init(parsing string: String) {
        self.init(parsing: string) { $0 }
    }
}

// MARK: - Math Utilities

public func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? abs(a) : gcd(b, a % b)
}

public func lcm(_ a: Int, _ b: Int) -> Int {
    a * b / gcd(a, b)
}

extension Sequence where Element == Int {
    public func gcd() -> Int {
        reduce(0, AoCCommon.gcd)
    }

    public func lcm() -> Int {
        reduce(1, AoCCommon.lcm)
    }
}
