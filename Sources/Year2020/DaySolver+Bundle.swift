import AoCCommon
import Foundation

extension DaySolver {
    public var bundle: Bundle { .module }
    public var year: Int { 2020 }
}

public enum Year2020: YearSolutions {
    public static let year = 2020
    public static let solvers: [any DaySolver] = []
}
