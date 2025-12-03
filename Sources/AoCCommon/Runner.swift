import Foundation

public func runDay<S: DaySolver>(_ solver: S) {
    let dayString = String(format: "%02d", solver.day)
    print("--- Day \(dayString) ---")

    print("[Test Input]")
    if let testParsedData = solver.parse(input: solver.testInput) {
        let testResult1 = solver.solvePart1(data: testParsedData)
        let status1 = validationStatus(result: testResult1, expected: solver.expectedTestResult1)
        print("  Part 1: \(testResult1)\(status1)")

        let testResult2 = solver.solvePart2(data: testParsedData)
        let status2 = validationStatus(result: testResult2, expected: solver.expectedTestResult2)
        print("  Part 2: \(testResult2)\(status2)")
    } else {
        print("  Failed to parse test input.")
    }

    print("--------------------")

    print("[Main Input]")
    let fileName = "day-\(dayString)"
    guard let fileInput = readResource(named: fileName, resourceBundler: solver.bundle) else {
        print("====================")
        return
    }

    if let fileParsedData = solver.parse(input: fileInput) {
        let (fileResult1, time1) = measure { solver.solvePart1(data: fileParsedData) }
        print("  Part 1: \(fileResult1) (\(formatDuration(time1)))")

        let (fileResult2, time2) = measure { solver.solvePart2(data: fileParsedData) }
        print("  Part 2: \(fileResult2) (\(formatDuration(time2)))")
    } else {
        print("  Failed to parse main input file.")
    }
    print("====================")
}

private func validationStatus<T: Equatable>(result: T, expected: T?) -> String {
    guard let expected = expected else { return "" }
    return result == expected ? " ✓" : " ✗ (expected \(expected))"
}

private func measure<T>(_ block: () -> T) -> (T, Duration) {
    let clock = ContinuousClock()
    let start = clock.now
    let result = block()
    let elapsed = clock.now - start
    return (result, elapsed)
}

private func formatDuration(_ duration: Duration) -> String {
    let seconds =
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    if seconds >= 1.0 {
        return String(format: "%.2fs", seconds)
    } else if seconds >= 0.001 {
        return String(format: "%.2fms", seconds * 1000)
    } else {
        return String(format: "%.2fµs", seconds * 1_000_000)
    }
}

private func readResource(
    named resourceName: String, resourceBundler: Bundle, extension ext: String = "txt"
) -> String? {
    guard let url = resourceBundler.url(forResource: resourceName, withExtension: ext) else {
        print(
            "Error: Resource file '\(resourceName).\(ext)' not found in Swift Package bundle.")
        return nil
    }
    do {
        return try String(contentsOf: url, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        print("Error reading resource file '\(url.path)': \(error)")
        return nil
    }
}
