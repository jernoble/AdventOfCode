struct Point: Hashable {
    var x: Int = 0
    var y: Int = 0

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

class Node: CustomStringConvertible {
    var elevation: Character
    var score: Int = 0

    init(elevation: Character) {
        self.elevation = elevation
    }

    public var description: String { return "Node \(elevation): \(score)" }
}

struct Map {
    var grid = [[Node]]()
    var start: Point?
    var end: Point?

    static func construct() -> Map? {
        var rowIndex = 0
        var grid = [[Node]]()
        var start: Point?
        var end: Point?
        while true {
            guard let line = readLine() else { break }
            var row = [Node]()
            for (columnIndex, char) in line.enumerated() {
                var char = char
                if char == "S" { char = "a"; start = Point(x: columnIndex, y: rowIndex) }
                if char == "E" { char = "z"; end = Point(x: columnIndex, y: rowIndex) }
                row.append(Node(elevation: char))
            }

            rowIndex += 1
            grid.append(row)
        }
        return Map(grid: grid, start: start, end: end)
    }

    func elevation(at: Point) -> Character {
        return grid[at.y][at.x].elevation
    }

    func elevationChange(from: Point, to: Point) -> Int {
        return Int(elevation(at: to).utf8.first!) - Int(elevation(at: from).utf8.first!)
    }

    func adjacentPoints(to: Point) -> Set<Point> {
        var adjacentPoints = Set<Point>()

        let southPoint = to + Point(x: 0, y: 1)
        if southPoint.y < grid.count && elevationChange(from: to, to: southPoint) <= 1 { adjacentPoints.insert(southPoint) }

        let northPoint = to + Point(x: 0, y: -1)
        if northPoint.y >= 0 && elevationChange(from: to, to: northPoint) <= 1 { adjacentPoints.insert(northPoint) }

        let eastPoint = to + Point(x: 1, y: 0)
        if eastPoint.x < grid[0].count && elevationChange(from: to, to: eastPoint) <= 1 { adjacentPoints.insert(eastPoint) }

        let westPoint = to + Point(x: -1, y: 0)
        if westPoint.x >= 0 && elevationChange(from: to, to: westPoint) <= 1 { adjacentPoints.insert(westPoint) }

        return adjacentPoints
    }

    func setScore(at: Point, to: Int) {
        grid[at.y][at.x].score = to
    }
}

let elapsed = ContinuousClock().measure {
    guard let map = Map.construct() else { return }
    guard map.start != nil, map.end != nil else { return }
    var visited = Set<Point>()
    visited.insert(map.start!)
    print("Start: \(map.start!), end: \(map.end!)")
    var round = 1
    while true {
        var newPoints = Set<Point>()
        for point in visited {
            newPoints.formUnion(map.adjacentPoints(to: point))
        }
        newPoints.subtract(visited)
        newPoints.forEach { map.setScore(at: $0, to: round) }
        visited.formUnion(newPoints)
        if newPoints.contains(map.end!) { break }
        round += 1
    }
    let score = round
    print("Score: \(score)")
}

print("Elapsed Total: \(elapsed)")
