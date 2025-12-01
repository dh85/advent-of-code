import Foundation

func runDay<S: DaySolver>(solver: S, resourceBundler: Bundle) {
    let dayString = String(format: "%02d", solver.day)
    print("--- Day \(dayString) ---")

    // --- Test Input Execution ---
    print("[Test Input]")
    if let testParsedData = solver.parse(input: solver.testInput) {
        let testResult1 = solver.solvePart1(data: testParsedData)
        print("  Part 1: \(testResult1)")  // Relies on CustomStringConvertible

        let testResult2 = solver.solvePart2(data: testParsedData)
        print("  Part 2: \(testResult2)")
    } else {
        print("  Failed to parse test input.")
    }

    print("--------------------")

    // --- Main Input Execution ---
    print("[Main Input]")
    let fileName = "day-\(dayString)"  // Assumes input files are named like "day-01.txt"
    guard let fileInput = readResource(named: fileName, resourceBundler: resourceBundler) else {
        // Error message already printed by readResource
        print("====================")
        return
    }

    if let fileParsedData = solver.parse(input: fileInput) {
        let fileResult1 = solver.solvePart1(data: fileParsedData)
        print("  Part 1: \(fileResult1)")

        let fileResult2 = solver.solvePart2(data: fileParsedData)
        print("  Part 2: \(fileResult2)")
    } else {
        print(" Failed to parse main input file: \(fileInput).txt")
    }
    print("====================")
}

private func readResource(
    named resourceName: String, resourceBundler: Bundle, extension ext: String = "txt"
) -> String? {
    #if SWIFT_PACKAGE  // Check if building as an SPM package with resources
        guard let url = resourceBundler.url(forResource: resourceName, withExtension: ext) else {
            print(
                "Error: Resource file '\(resourceName).\(ext)' not found in Swift Package bundle.")
            return nil
        }
        do {
            // Trim whitespace/newlines from start/end which can sometimes cause parsing issues
            return try String(contentsOf: url, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error reading resource file '\(url.path)': \(error)")
            return nil
        }
    #else
        // Fallback for non-SPM environments (e.g., Xcode project without resource bundle setup)
        // This might require adjusting the path based on your project structure.
        // A common alternative is to place input files in the same directory as the executable
        // or a known relative path.
        print(
            "Info: Not running as Swift Package. Attempting to read '\(resourceName).\(ext)' from current directory."
        )
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let filePath = "\(currentPath)/\(resourceName).\(ext)"

        if !fileManager.fileExists(atPath: filePath) {
            print("Error: Input file not found at: \(filePath)")
            return nil
        }

        do {
            return try String(contentsOfFile: filePath, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error reading file '\(filePath)': \(error)")
            return nil
        }
    #endif
}
