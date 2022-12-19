struct Point: Hashable, Comparable, CustomStringConvertible {
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

    static func < (lhs: Self, rhs: Self) -> Bool {
        return (lhs.y < rhs.y) || (lhs.y == rhs.y && lhs.x < rhs.x)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    func distance(to: Point) -> Int {
        return abs(x - to.x) + abs(y - to.y)
    }

    var description: String {
        return "(\(x),\(y))"
    }
}

extension ClosedRange {
    func unionWith(_ range: ClosedRange<Bound>) -> ClosedRange<Bound> {
        let lowerBound = Swift.min(lowerBound, range.lowerBound)
        let upperBound = Swift.max(upperBound, range.upperBound)
        return lowerBound ... upperBound
    }
}

struct DisjointRange {
    var ranges = [ClosedRange<Int>]()

    func overlaps(_ range: ClosedRange<Int>) -> Bool {
        return !ranges.allSatisfy { !$0.overlaps(range) }
    }

    mutating func unionWith(_ range: ClosedRange<Int>) {
        let overlappingRanges = ranges.filter { $0.overlaps(range) }
        if overlappingRanges.isEmpty {
            ranges.append(range)
            return
        }

        var range = range
        ranges.removeAll(where: { overlappingRanges.contains($0) })
        overlappingRanges.forEach { range = range.unionWith($0) }
        ranges.append(range)
    }

    var count: Int {
        return ranges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound + 1) }
    }
}

struct Beacon: Comparable {
    var point = Point(x: 0, y: 0)

    static func == (lhs: Beacon, rhs: Beacon) -> Bool { return lhs.point == rhs.point }
    static func < (lhs: Beacon, rhs: Beacon) -> Bool { return lhs.point < rhs.point }
}

class Sensor {
    var point = Point(x: 0, y: 0)
    var closestBeacon: Beacon
    var beaconDistance: Int

    init(point: Point, closestBeacon: Beacon) {
        self.point = point
        self.closestBeacon = closestBeacon
        beaconDistance = point.distance(to: closestBeacon.point)
    }

    static func construct() -> Sensor? {
        guard var line = readLine() else { return nil }
        guard line.hasPrefix("Sensor at ") else { return nil }
        line.removeFirst(10)

        var parts = line.split(separator: ":")
        guard parts.count == 2 else { return nil }
        var sensorLocationParts = parts[0].split(separator: ",")
        guard sensorLocationParts.count == 2 &&
            sensorLocationParts[0].hasPrefix("x=") &&
            sensorLocationParts[1].hasPrefix(" y=") else { return nil }
        sensorLocationParts[0].removeFirst(2)
        sensorLocationParts[1].removeFirst(3)
        guard let sensorX = Int(sensorLocationParts[0]),
              let sensorY = Int(sensorLocationParts[1]) else { return nil }
        let sensorPoint = Point(x: sensorX, y: sensorY)

        guard parts[1].hasPrefix(" closest beacon is at ") else { return nil }
        parts[1].removeFirst(22)
        var beaconLocationParts = parts[1].split(separator: ",")
        guard beaconLocationParts.count == 2 &&
            beaconLocationParts[0].hasPrefix("x=") &&
            beaconLocationParts[1].hasPrefix(" y=") else { return nil }
        beaconLocationParts[0].removeFirst(2)
        beaconLocationParts[1].removeFirst(3)
        guard let beaconX = Int(beaconLocationParts[0]),
              let beaconY = Int(beaconLocationParts[1]) else { return nil }
        let beaconPoint = Point(x: beaconX, y: beaconY)

        return Sensor(point: sensorPoint, closestBeacon: Beacon(point: beaconPoint))
    }

    static func == (lhs: Sensor, rhs: Sensor) -> Bool { return lhs.point == rhs.point }
    static func < (lhs: Sensor, rhs: Sensor) -> Bool { return lhs.point < rhs.point }
}

let elapsed = ContinuousClock().measure {
    var sensors = [Sensor]()
    let elapsedParsing = ContinuousClock().measure {
        while let sensor = Sensor.construct() {
            sensors.append(sensor)
        }
    }
    print("Elapsed parsing: \(elapsedParsing)")

    let detectionRow = 2_000_000

    var ranges = DisjointRange()
    for sensor in sensors {
        let verticalDistance = abs(sensor.point.y - detectionRow)
        guard sensor.beaconDistance > verticalDistance else { continue }

        let xDistance = sensor.beaconDistance - verticalDistance
        let newRange = (sensor.point.x - xDistance) ... (sensor.point.x + xDistance)

        ranges.unionWith(newRange)
    }

    let beaconsInDetectionRow = Set(sensors.map { $0.closestBeacon.point }.filter { $0.y == detectionRow })

    print("Count: \(ranges.count - beaconsInDetectionRow.count)")
}

print("Elapsed Total: \(elapsed)")
