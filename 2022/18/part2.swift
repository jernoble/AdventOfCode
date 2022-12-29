struct Point: Hashable, Comparable, CustomStringConvertible {
    var x: Int = 0
    var y: Int = 0
    var z: Int = 0

    static func construct(from: (any StringProtocol)?) -> Point? {
        if from == nil { return nil }
        let parts = from!.split(separator: ",")
        guard parts.count == 3 else { return nil }
        guard let x = Int(parts[0]) else { return nil }
        guard let y = Int(parts[1]) else { return nil }
        guard let z = Int(parts[2]) else { return nil }
        return Point(x: x, y: y, z: z)
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return (lhs.y < rhs.y) || (lhs.y == rhs.y && lhs.x < rhs.x) || (lhs.y == rhs.y && lhs.x == rhs.x && lhs.z < rhs.z)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }

    var description: String {
        return "(\(x),\(y),\(z))"
    }
}

let elapsed = ContinuousClock().measure {
    var points = [Point]()
    let elapsedParsing = ContinuousClock().measure {
        while let point = Point.construct(from: readLine()) {
            points.append(point)
        }
    }
    print("Elapsed parsing: \(elapsedParsing)")

    let maxX = points.map { $0.x }.max() ?? 0
    let maxY = points.map { $0.y }.max() ?? 0
    let maxZ = points.map { $0.z }.max() ?? 0

    let aisle = [Int](repeating: 0, count: maxX + 1)
    let layer = [[Int]](repeating: aisle, count: maxY + 1)
    var grid = [[[Int]]](repeating: layer, count: maxZ + 1)

    for p in points {
        grid[p.z][p.y][p.x] = 6
    }

    var visited = Set<Point>()
    var edges = Set<Point>()
    var outside = Set<Point>()

    func adjacentPoints(to p: Point) -> Set<Point> {
        var a = Set<Point>()
        if p.z - 1 >= -1 { a.insert(Point(x: p.x, y: p.y, z: p.z - 1)) }
        if p.z + 1 <= maxZ + 1 { a.insert(Point(x: p.x, y: p.y, z: p.z + 1)) }
        if p.y - 1 >= -1 { a.insert(Point(x: p.x, y: p.y - 1, z: p.z)) }
        if p.y + 1 <= maxY + 1 { a.insert(Point(x: p.x, y: p.y + 1, z: p.z)) }
        if p.x - 1 >= -1 { a.insert(Point(x: p.x - 1, y: p.y, z: p.z)) }
        if p.x + 1 <= maxX + 1 { a.insert(Point(x: p.x + 1, y: p.y, z: p.z)) }
        return a
    }

    visited.insert(Point(x: -1, y: -1, z: -1))
    while true {
        var newPoints = Set<Point>()
        for p in visited {
            newPoints.formUnion(adjacentPoints(to: p))
        }
        newPoints.subtract(visited)

        for p in newPoints {
            guard p.z >= 0, p.z <= maxZ,
                  p.y >= 0, p.y <= maxY,
                  p.x >= 0, p.x <= maxX else { continue }
            if grid[p.z][p.y][p.x] > 0 { edges.insert(p) }
        }
        newPoints.subtract(edges)
        if newPoints.isEmpty { break }

        outside.formUnion(newPoints)
        visited.formUnion(newPoints)
    }

    for p in edges {
        let a = adjacentPoints(to: p).intersection(outside)
        grid[p.z][p.y][p.x] = a.count
    }

    var total = 0
    for p in edges { total += grid[p.z][p.y][p.x] }
    print("Total: \(total)")
}

print("Elapsed Total: \(elapsed)")
