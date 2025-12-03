import Foundation

public protocol DaySolver {
    associatedtype ParsedData: Equatable
    associatedtype Result1: Equatable
    associatedtype Result2: Equatable

    init()

    var day: Int { get }
    var testInput: String { get }
    var bundle: Bundle { get }

    /// Expected test result for Part 1 (optional, for validation)
    var expectedTestResult1: Result1? { get }
    /// Expected test result for Part 2 (optional, for validation)
    var expectedTestResult2: Result2? { get }

    func parse(input: String) -> ParsedData?
    func solvePart1(data: ParsedData) -> Result1
    func solvePart2(data: ParsedData) -> Result2
}

// MARK: - Default Implementations
extension DaySolver {
    public var expectedTestResult1: Result1? { nil }
    public var expectedTestResult2: Result2? { nil }
}
