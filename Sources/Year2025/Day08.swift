import AoCCommon

public struct Day08: DaySolver {
    public struct Point3D: Hashable {
        let x, y, z: Int

        @inline(__always)
        func distanceSquared(to other: Point3D) -> Int {
            let dx = x - other.x
            let dy = y - other.y
            let dz = z - other.z
            return dx * dx + dy * dy + dz * dz
        }
    }

    public typealias ParsedData = [Point3D]
    public typealias Result1 = Int
    public typealias Result2 = Int

    public let expectedTestResult1: Result1? = 40
    public let expectedTestResult2: Result2? = 25272

    public init() {}
    public let day = 8
    public let testInput = """
        162,817,812
        57,618,57
        906,360,560
        592,479,940
        352,342,300
        466,668,158
        542,29,236
        431,825,988
        739,650,466
        52,470,668
        216,146,977
        819,987,18
        117,168,530
        805,96,715
        346,949,466
        970,615,88
        941,993,340
        862,61,35
        984,92,344
        425,690,689
        """

    public func parse(input: String) throws -> [Point3D] {
        input.lines.map { Point3D(x: $0.integers[0], y: $0.integers[1], z: $0.integers[2]) }
    }

    public func solvePart1(data: [Point3D]) -> Int {
        let edges = sortedEdges(data)
        var parent = Array(0..<data.count)
        var size = Array(repeating: 1, count: data.count)

        let edgeCount = data.count == 20 ? 10 : 1000
        for k in 0..<min(edgeCount, edges.count) {
            let e = edges[k]
            merge(e.i, e.j, &parent, &size)
        }

        var sizes: [Int: Int] = [:]
        for i in 0..<data.count { sizes[find(i, &parent), default: 0] += 1 }
        return sizes.values.sorted(by: >).prefix(3).product()
    }

    public func solvePart2(data: [Point3D]) -> Int {
        let edges = sortedEdges(data)
        var parent = Array(0..<data.count)
        var size = Array(repeating: 1, count: data.count)
        var components = data.count

        for e in edges {
            let pi = find(e.i, &parent)
            let pj = find(e.j, &parent)
            guard pi != pj else { continue }
            if size[pi] < size[pj] {
                parent[pi] = pj
                size[pj] += size[pi]
            } else {
                parent[pj] = pi
                size[pi] += size[pj]
            }
            components -= 1
            if components == 1 { return data[e.i].x * data[e.j].x }
        }
        return 0
    }

    private struct Edge: Comparable {
        let dist: Int
        let i: Int
        let j: Int

        @inline(__always)
        static func < (lhs: Edge, rhs: Edge) -> Bool { lhs.dist < rhs.dist }
    }

    @inline(__always)
    private func find(_ x: Int, _ parent: inout [Int]) -> Int {
        var x = x
        while parent[x] != x {
            parent[x] = parent[parent[x]]  // path halving
            x = parent[x]
        }
        return x
    }

    @inline(__always)
    private func merge(_ a: Int, _ b: Int, _ parent: inout [Int], _ size: inout [Int]) {
        let pa = find(a, &parent)
        let pb = find(b, &parent)
        guard pa != pb else { return }
        if size[pa] < size[pb] {
            parent[pa] = pb
            size[pb] += size[pa]
        } else {
            parent[pb] = pa
            size[pa] += size[pb]
        }
    }

    private func sortedEdges(_ data: [Point3D]) -> [Edge] {
        let n = data.count
        var edges = [Edge]()
        edges.reserveCapacity(n * (n - 1) / 2)
        for i in 0..<n {
            for j in (i + 1)..<n {
                edges.append(Edge(dist: data[i].distanceSquared(to: data[j]), i: i, j: j))
            }
        }
        edges.sort()
        return edges
    }
}
