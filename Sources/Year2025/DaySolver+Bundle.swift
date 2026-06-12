import AoCCommon
import Foundation

extension DaySolver {
    public var bundle: Bundle { .module }
    public var year: Int { 2025 }
}

public enum Year2025: YearSolutions {
    public static let year = 2025
    public static let solvers: [any DaySolver] = [
        Day01(), Day02(), Day03(), Day04(), Day05(),
        Day06(), Day07(), Day08(), Day09(), Day10(),
    ]
}
