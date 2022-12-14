struct Point: Hashable {
    var x: Int = 0
    var y: Int = 0

    static func construct(from: (any StringProtocol)?) -> Point? {
        if from == nil { return nil }
        let parts = from!.split(separator: ",")
        guard parts.count == 2 else { return nil }
        guard let x = Int(parts[0]) else { return nil }
        guard let y = Int(parts[1]) else { return nil }
        return Point(x: x, y: y)
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class Map: CustomStringConvertible {
    var grid = [[Bool]]()
    var width = 0

    func growToFit(point: Point) {
        if point.y >= grid.count {
            let rowsToAdd = 1 + point.y - grid.count
            grid += [[Bool]](repeating: [Bool](repeating: false, count: width), count: rowsToAdd)
        }
        if point.x >= width {
            width = 1 + point.x
            grid = grid.map {
                let columnsToAdd = width - $0.count
                if columnsToAdd <= 0 { return $0 }
                return $0 + [Bool](repeating: false, count: columnsToAdd)
            }
        }
    }

    func fill(_ point: Point) {
        growToFit(point: point)
        grid[point.y][point.x] = true
    }

    func fill(from: Point, to: Point) {
        growToFit(point: from)
        growToFit(point: to)
        for y in min(from.y, to.y) ... max(from.y, to.y) {
            for x in min(from.x, to.x) ... max(from.x, to.x) {
                grid[y][x] = true
            }
        }
    }

    func contains(_ point: Point) -> Bool {
        return point.y >= 0 && point.y < grid.count
    }

    func isEmpty(_ point: Point) -> Bool {
        return contains(point) && (point.x >= width || !grid[point.y][point.x])
    }

    func drip(at point: Point) -> Point {
        var point = point
        while true {
            var nextPoint = point + Point(x: 0, y: 1)
            if !contains(nextPoint) { break }
            if isEmpty(nextPoint) { point = nextPoint; continue }
            nextPoint = nextPoint + Point(x: -1, y: 0)
            if isEmpty(nextPoint) { point = nextPoint; continue }
            nextPoint = nextPoint + Point(x: 2, y: 0)
            if isEmpty(nextPoint) { point = nextPoint; continue }
            break
        }
        fill(point)
        return point
    }

    static func construct() -> Map? {
        let map = Map()
        while true {
            guard let line = readLine() else { break }
            if line.isEmpty { continue }
            let input = line.split(separator: " ")
            if input.count < 3 { return nil }
            var iterator = input.makeIterator()
            guard var firstPoint = Point.construct(from: iterator.next()) else { return nil }
            while let parameter = iterator.next() {
                if parameter == "->" { continue }
                guard let nextPoint = Point.construct(from: parameter) else { return nil }
                map.fill(from: firstPoint, to: nextPoint)
                firstPoint = nextPoint
            }
        }
        return map
    }

    var description: String {
        var output = String()
        for row in grid {
            output.append(String(row.suffix(30).map { $0 ? "#" : "." }))
            output.append("\n")
        }
        return output
    }
}

let elapsed = ContinuousClock().measure {
    guard let map = Map.construct() else { return }
    let newY = map.grid.count
    map.growToFit(point: Point(x: 0, y: newY))
    let dripPoint = Point(x: 500, y: 0)
    var count = 1
    while map.drip(at: dripPoint) != dripPoint {
        count += 1
    }
    print("Count: \(count)")
}

print("Elapsed Total: \(elapsed)")
