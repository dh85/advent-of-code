import AoCCommon

public struct Day09: DaySolver {
    public typealias ParsedData = [Point]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 50
    public let expectedTestResult2: Result2? = 24

    public init() {}

    public let day = 9

    public let testInput = """
        7,1
        11,1
        11,7
        9,7
        9,5
        2,5
        2,3
        7,3
        """

    public func parse(input: String) throws -> [Point] {
        input.lines.map {
            let i = $0.firstIndex(of: ",")!
            return Point(Int($0[$0.startIndex..<i])!, Int($0[$0.index(after: i)...])!)
        }
    }

    public func solvePart1(data: ParsedData) -> Int {
        var maxArea = 0
        for i in 0..<data.count {
            for j in (i + 1)..<data.count {
                let area = (abs(data[i].x - data[j].x) + 1) * (abs(data[i].y - data[j].y) + 1)
                if area > maxArea { maxArea = area }
            }
        }
        return maxArea
    }

    public func solvePart2(data: ParsedData) -> Int {
        // Build boundary segments
        var hSegs: [(y: Int, x1: Int, x2: Int)] = []
        var vSegs: [(x: Int, y1: Int, y2: Int)] = []
        for i in 0..<data.count {
            let a = data[i]
            let b = data[(i + 1) % data.count]
            if a.y == b.y {
                hSegs.append((y: a.y, x1: min(a.x, b.x), x2: max(a.x, b.x)))
            } else {
                vSegs.append((x: a.x, y1: min(a.y, b.y), y2: max(a.y, b.y)))
            }
        }

        // Sort vertical segments by x for efficient ray casting
        let sortedV = vSegs.sorted { $0.x < $1.x }

        // Point-in-polygon using ray casting (ray goes in +x direction)
        // Point is inside if it's on the boundary OR has odd crossings
        func isInside(_ p: Point) -> Bool {
            // On horizontal segment?
            for seg in hSegs {
                if p.y == seg.y && p.x >= seg.x1 && p.x <= seg.x2 { return true }
            }
            // On vertical segment?
            for seg in vSegs {
                if p.x == seg.x && p.y >= seg.y1 && p.y <= seg.y2 { return true }
            }
            // Ray cast
            var crossings = 0
            for seg in sortedV {
                guard seg.x > p.x else { continue }
                if p.y > seg.y1 && p.y <= seg.y2 { crossings += 1 }
            }
            return crossings % 2 == 1
        }

        // Check if rectangle [x1,y1]-[x2,y2] is fully inside the polygon
        // All 4 corners must be inside, and no boundary segment may cross through the interior
        func rectInside(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) -> Bool {
            // All corners inside
            if !isInside(Point(x1, y1)) || !isInside(Point(x2, y2))
                || !isInside(Point(x1, y2)) || !isInside(Point(x2, y1))
            {
                return false
            }

            // No vertical segment strictly inside x-range that overlaps y-range
            for seg in vSegs {
                if seg.x > x1 && seg.x < x2 && seg.y1 < y2 && seg.y2 > y1 {
                    return false
                }
            }
            // No horizontal segment strictly inside y-range that overlaps x-range
            for seg in hSegs {
                if seg.y > y1 && seg.y < y2 && seg.x1 < x2 && seg.x2 > x1 {
                    return false
                }
            }
            return true
        }

        var maxArea = 0
        for i in 0..<data.count {
            for j in (i + 1)..<data.count {
                let x1 = min(data[i].x, data[j].x)
                let x2 = max(data[i].x, data[j].x)
                let y1 = min(data[i].y, data[j].y)
                let y2 = max(data[i].y, data[j].y)
                let area = (x2 - x1 + 1) * (y2 - y1 + 1)
                guard area > maxArea else { continue }
                if rectInside(x1, y1, x2, y2) {
                    maxArea = area
                }
            }
        }
        return maxArea
    }
}
