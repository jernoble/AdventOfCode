import Algorithms

struct Size: Hashable, CustomStringConvertible {
    var width: Int = 0
    var height: Int = 0

    static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }

    var description: String {
        return "(\(width)x\(height))"
    }
}

extension Array {
    func anyOf(_ lambda: (Self.Element) -> Bool) -> Bool {
        if isEmpty { return false }
        return !allSatisfy { !lambda($0) }
    }
}

struct Point: Hashable, Comparable, CustomStringConvertible {
    var x: Int = 0
    var y: Int = 0

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func + (lhs: Point, rhs: Size) -> Point {
        return Point(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return (lhs.y < rhs.y) || (lhs.y == rhs.y && lhs.x < rhs.x)
    }

    static func += (lhs: inout Point, rhs: Size) {
        lhs.x += rhs.width
        lhs.y += rhs.height
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    var description: String {
        return "(\(x),\(y))"
    }
}

struct Rect: Hashable, CustomStringConvertible {
    var origin = Point()
    var size = Size()

    var top: Int { return origin.y + size.height }
    var left: Int { return origin.x }
    var bottom: Int { return origin.y }
    var right: Int { return origin.x + size.width }

    func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }

    static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }

    func intersects(with other: Rect) -> Bool {
        return bottom <= other.top && top >= other.bottom && left <= other.right && right >= other.left
    }

    var description: String {
        return "({\(origin) \(size)})"
    }
}

// Assumes array parameters are sorted
func fastArraysIntersect<C: Comparable>(_ one: [C], _ two: [C]) -> Bool {
    var i1 = one.makeIterator()
    var i2 = two.makeIterator()
    var element1 = i1.next()
    var element2 = i2.next()
    while element1 != nil && element2 != nil {
        if element1! == element2! { return true }
        if element1! < element2! { element1 = i1.next(); continue }
        element2 = i2.next()
    }
    return false
}

struct Shape: Comparable, CustomStringConvertible {
    init(with points: [Point]) {
        _points = points.sorted()

        let xs = _points.map { $0.x }
        let ys = _points.map { $0.y }
        let top = (ys.max() ?? 0) + 1
        let left = xs.min() ?? 0
        let bottom = ys.min() ?? 0
        let right = (xs.max() ?? 0) + 1
        _bounds = Rect(origin: Point(x: left, y: bottom), size: Size(width: right - left, height: top - bottom))
    }

    mutating func setOrigin(to point: Point) { _bounds.origin = point }
    mutating func move(by size: Size) { _bounds.origin += size }

    var points: [Point] { return _points.map { $0 + Size(width: _bounds.origin.x, height: _bounds.origin.y) }}

    private var _points: [Point]
    private var _bounds: Rect

    var bounds: Rect { return _bounds }

    func intersects(with other: Shape) -> Bool {
        if !_bounds.intersects(with: other._bounds) { return false }
        return fastArraysIntersect(points, other.points)
    }

    static func < (lhs: Shape, rhs: Shape) -> Bool {
        return lhs._bounds.bottom < rhs._bounds.bottom
    }

    var description: String {
        return bounds.description
    }
}

let shapes = [
    Shape(with: [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 2, y: 0), Point(x: 3, y: 0)]),
    Shape(with: [Point(x: 1, y: 0), Point(x: 0, y: 1), Point(x: 1, y: 1), Point(x: 2, y: 1), Point(x: 1, y: 2)]),
    Shape(with: [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 2, y: 0), Point(x: 2, y: 1), Point(x: 2, y: 2)]),
    Shape(with: [Point(x: 0, y: 0), Point(x: 0, y: 1), Point(x: 0, y: 2), Point(x: 0, y: 3)]),
    Shape(with: [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 0, y: 1), Point(x: 1, y: 1)]),
]

func print(stack: [Shape], incomingShape: Shape) {
    let maxY = max(stack.map { $0.bounds.top }.max() ?? 0, incomingShape.bounds.top)
    let blankRow = [Character](["|", ".", ".", ".", ".", ".", ".", ".", "|"])
    var output = [[Character]](repeating: blankRow, count: maxY + 1)
    output[0] = ["+", "-", "-", "-", "-", "-", "-", "-", "+"]

    for shape in stack {
        for point in shape.points { output[point.y + 1][point.x + 1] = "#" }
    }

    for point in incomingShape.points { output[point.y + 1][point.x + 1] = "@" }
    print(String(output.reversed().joined(separator: ["\n"])))
}

struct Stack {
    var shapes = [Shape]()

    typealias Index = Array<Shape>.Index
    typealias Element = Array<Shape>.Element

    mutating func reserveCapacity(_ value: Int) {
        shapes.reserveCapacity(value)
    }

    func intersects(with shape: Shape) -> Bool {
        for otherShape in shapes.reversed() {
            if otherShape.bounds.top < shape.bounds.bottom { return false }
            if otherShape.intersects(with: shape) { return true }
        }
        return false
    }

    func lastIndex(where predicate: (Self.Element) -> Bool) -> Self.Index? {
        return shapes.lastIndex(where: predicate)
    }

    func last(where predicate: (Self.Element) -> Bool) -> Self.Element? {
        guard let index = lastIndex(where: predicate) else { return nil }
        return shapes[index]
    }

    var count: Int { return shapes.count }

    mutating func append(_ shape: Shape) {
        var insertionPoint: Self.Index?
        let range = 0 ..< shapes.count
        for index in range.reversed() {
            if shapes[index].bounds.top < shape.bounds.top { break }
            insertionPoint = index
        }

        if insertionPoint != nil { shapes.insert(shape, at: insertionPoint!) }
        else { shapes.append(shape) }
    }
}

let elapsed = ContinuousClock().measure {
    let left = Size(width: -1, height: 0)
    let right = Size(width: 1, height: 0)
    let up = Size(width: 0, height: 1)
    let down = Size(width: 0, height: -1)

    guard let line = readLine() else { return }
    let windValues = line.map { switch $0 {
    case ">": return [right, left]
    case "<": return [left, right]
    default: return [Size(), Size()]
    } }

    var stack = Stack()
    var highestPoint = 0
    stack.reserveCapacity(2022)

    var windGenerator = windValues.cycled().makeIterator()

    for shape in shapes.cycled() {
        var shape = shape
        shape.setOrigin(to: Point(x: 2, y: highestPoint + 3))
        repeat {
            let wind = windGenerator.next()!
            // print(stack: stack.shapes, incomingShape: shape)
            shape.move(by: wind[0])

            if shape.bounds.left < 0 || shape.bounds.right > 7 || stack.intersects(with: shape) {
                shape.move(by: wind[1])
            }

            shape.move(by: down)
            if shape.bounds.bottom < 0 || stack.intersects(with: shape) {
                shape.move(by: up)
                break
            }
        } while true

        stack.append(shape)

        highestPoint = max(highestPoint, shape.bounds.top)
        if stack.count >= 2022 { break }
    }
    // print(stack: stack.shapes, incomingShape: Shape(with: [Point]()))

    print("Highest Point: \(highestPoint)")
}

print("Elapsed Total: \(elapsed)")
