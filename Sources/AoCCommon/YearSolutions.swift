public protocol YearSolutions {
    static var year: Int { get }
    static var solvers: [any DaySolver] { get }
}
