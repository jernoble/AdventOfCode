struct Point: Comparable, Hashable, CustomStringConvertible {
    var x: Int = 0
    var y: Int = 0
    init(x: Int, y: Int) { self.x = x; self.y = y }
    var description: String { return "(\(x), \(y))" }

    static func < (lhs: Point, rhs: Point) -> Bool {
        return lhs.x < rhs.y || (lhs.x == rhs.x && lhs.y < rhs.y)
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func - (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    mutating func move(up: Int) { y += up }
    mutating func move(left: Int) { x -= left }
    mutating func move(down: Int) { y -= down }
    mutating func move(right: Int) { x += right }
    mutating func move(toward: Point) -> Bool {
        let diff = toward - self
        if abs(diff.x) <= 1, abs(diff.y) <= 1 { return false }
        x += 1 * diff.x.signum()
        y += 1 * diff.y.signum()
        return true
    }
}

let elapsed = ContinuousClock().measure {
    var visited = Set<Point>()
    var rope = [Point](repeating: Point(x: 0, y: 0), count: 10)
    visited.insert(Point(x: rope.last!.x, y: rope.last!.y))
    loop: while true {
        guard let line = readLine() else { break }
        if line.isEmpty { continue }
        let instructions = line.split(separator: " ")
        if instructions.count != 2 { break }
        guard var distance = Int(instructions[1]) else { break }

        while distance != 0 {
            switch instructions[0] {
            case "U": rope[0].move(up: 1)
            case "L": rope[0].move(left: 1)
            case "D": rope[0].move(down: 1)
            case "R": rope[0].move(right: 1)
            default: break loop
            }

            for i in 1 ..< rope.count {
                rope[i].move(toward: rope[i - 1])
            }
            visited.insert(Point(x: rope.last!.x, y: rope.last!.y))
            distance -= 1
        }
    }
    print("Visited: \(visited.count)")
}

print("Elapsed Total: \(elapsed)")
