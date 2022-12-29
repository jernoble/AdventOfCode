import Algorithms

struct Size: Hashable, CustomStringConvertible {
    var width: Int = 0
    var height: Int = 0
    private var _isEmpty: Bool = true

    init() {}
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        _isEmpty = width == 0 || height == 0
    }

    static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }

    var isEmpty: Bool { return _isEmpty }

    func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }

    var description: String {
        return _isEmpty ? "(nil)" : "(\(width)x\(height))"
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

    static func - (lhs: Point, rhs: Point) -> Size {
        return Size(width: lhs.x + rhs.x, height: lhs.y + rhs.y)
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

var comparisons = 0

struct Rect: Hashable, CustomStringConvertible {
    var origin = Point()
    var size = Size()
    private var _top = 0
    private var _right = 0

    init() {}

    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
        _top = origin.y + size.height
        _right = origin.x + size.width
    }

    init(x: Int, y: Int, width: Int, height: Int) {
        origin = Point(x: x, y: y)
        size = Size(width: width, height: height)
        _top = origin.y + size.height
        _right = origin.x + size.width
    }

    var top: Int { return _top }
    var left: Int { return origin.x }
    var bottom: Int { return origin.y }
    var right: Int { return _right }

    var isEmpty: Bool { return size.isEmpty }

    func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }

    static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }

    mutating func setOrigin(to point: Point) {
        origin = point
        _top = origin.y + size.height
        _right = origin.x + size.width
    }

    mutating func move(by distance: Size) {
        origin += distance
        _top += distance.height
        _right += distance.width
    }

    func intersects(with other: Rect) -> Bool {
        if isEmpty || other.isEmpty { return false }
        comparisons += 1
        return bottom < other.top && top > other.bottom && left < other.right && right > other.left
    }

    func intersects(with other: [Rect]) -> Bool {
        return other.anyOf { $0.intersects(with: self) }
    }

    var description: String {
        return "({\(origin) \(size)})"
    }
}

struct Shape: Comparable, CustomStringConvertible {
    init(with rect1: Rect) {
        self.rect1 = rect1
        _bounds = rect1
    }

    init(with rect1: Rect, and rect2: Rect) {
        self.rect1 = rect1
        self.rect2 = rect2
        let top = max(rect1.top, rect2.top)
        let left = min(rect1.left, rect2.left)
        let bottom = min(rect1.bottom, rect2.bottom)
        let right = max(rect1.right, rect2.right)
        _bounds = Rect(origin: Point(x: left, y: bottom), size: Size(width: right - left, height: top - bottom))
    }

    mutating func setOrigin(to point: Point) {
        let distance = _bounds.origin - point
        _bounds.setOrigin(to: point)
        rect1.move(by: distance)
        rect2.move(by: distance)
    }

    mutating func move(by distance: Size) {
        _bounds.move(by: distance)
        rect1.move(by: distance)
        rect2.move(by: distance)
    }

    var rect1 = Rect()
    var rect2 = Rect()
    private var _bounds: Rect

    var bounds: Rect { return _bounds }

    func intersects(with other: Shape) -> Bool {
        if !_bounds.intersects(with: other._bounds) { return false }
        if rect2.isEmpty && other.rect2.isEmpty { return true }
        return rect1.intersects(with: other.rect1) ||
            rect1.intersects(with: other.rect2) ||
            rect2.intersects(with: other.rect1) ||
            rect2.intersects(with: other.rect2)
    }

    static func < (lhs: Shape, rhs: Shape) -> Bool {
        return lhs._bounds.bottom < rhs._bounds.bottom
    }

    static func == (lhs: Shape, rhs: Shape) -> Bool {
        return lhs.rect1 == rhs.rect1 && lhs.rect2 == rhs.rect2
    }

    var description: String {
        return bounds.description
    }
}

let shapes = [
    Shape(with: Rect(x: 0, y: 0, width: 4, height: 1)),
    Shape(with: Rect(x: 0, y: 1, width: 3, height: 1), and: Rect(x: 1, y: 0, width: 1, height: 3)),
    Shape(with: Rect(x: 0, y: 0, width: 3, height: 1), and: Rect(x: 2, y: 1, width: 1, height: 2)),
    Shape(with: Rect(x: 0, y: 0, width: 1, height: 4)),
    Shape(with: Rect(x: 0, y: 0, width: 2, height: 2)),
]

func print(stack: [Shape], incomingShape: Shape) {
    let maxY = max(stack.map { $0.bounds.top }.max() ?? 0, incomingShape.bounds.top)
    let blankRow = [Character](["|", ".", ".", ".", ".", ".", ".", ".", "|"])
    var output = [[Character]](repeating: blankRow, count: maxY + 1)
    output[0] = ["+", "-", "-", "-", "-", "-", "-", "-", "+"]

    func printRect(rect: Rect, character: Character) {
        for x in rect.origin.x ..< rect.origin.x + rect.size.width {
            for y in rect.origin.y ..< rect.origin.y + rect.size.height {
                output[y + 1][x + 1] = character
            }
        }
    }

    for shape in stack {
        printRect(rect: shape.rect1, character: "#")
        printRect(rect: shape.rect2, character: "#")
    }

    printRect(rect: incomingShape.rect1, character: "@")
    printRect(rect: incomingShape.rect2, character: "@")

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
        shapes.append(shape)
        let range = 1 ..< shapes.count
        for index in range.reversed() {
            if shapes[index].bounds.top >= shapes[index - 1].bounds.top { break }
            shapes.swapAt(index - 1, index)
        }
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
    var count = 0
    var highestPoint = 0
    let cycleCount = 1_000_000_000_000
    stack.reserveCapacity(100_000)

    var windGenerator = windValues.cycled().makeIterator()

    for shape in shapes.cycled() {
        var shape = shape
        shape.setOrigin(to: Point(x: 2, y: highestPoint + 3))
        repeat {
            // print(stack: stack.shapes, incomingShape: shape)
            let wind = windGenerator.next()!
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

        count += 1
        if stack.count == 100_000 {
            // check for cycles.
            repeat {
                let leftAndSizeStack = stack.shapes.map { Rect(origin: Point(x: $0.bounds.left, y: 0), size: $0.bounds.size) }
                let searchSequence = leftAndSizeStack[500 ..< 550]
                let ranges = leftAndSizeStack.ranges(of: searchSequence)
                if ranges.count < 3 { break }
                let firstDistance = leftAndSizeStack.distance(from: ranges[0].first!, to: ranges[1].first!)
                let secondDistance = leftAndSizeStack.distance(from: ranges[1].first!, to: ranges[2].first!)
                if firstDistance != secondDistance { break }
                let cycleDistance = firstDistance
                let cycleHeight = stack.shapes[ranges[1].first!].bounds.top - stack.shapes[ranges[0].first!].bounds.top

                let cyclesRemaining = (cycleCount - count) / cycleDistance

                print("Found cycle! distance:\(cycleDistance), height:\(cycleHeight), count:\(count), cycles remaining:\(cyclesRemaining)")

                count += cyclesRemaining * cycleDistance
                highestPoint += cyclesRemaining * cycleHeight
                let cycleOffset = Size(width: 0, height: cyclesRemaining * cycleHeight)

                for index in stack.shapes.indices {
                    stack.shapes[index].move(by: cycleOffset)
                }

                print("After cycle, count:\(count), highest")

            } while false

            stack.shapes.removeFirst(50000)
        }

        if count >= cycleCount { break }
    }
    // print(stack: stack.shapes, incomingShape: Shape(with: Rect()))

    // stack.shapes.forEach { print("\($0.rect1) \($0.rect2)") }

    print("Highest Point: \(highestPoint)")
    print("Comparisons: \(comparisons)")
}

print("Elapsed Total: \(elapsed)")
