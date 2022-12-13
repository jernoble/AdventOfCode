enum ComparisonResult: Int {
    case orderedAscending
    case orderedSame
    case orderedDescending
}

class PacketValue: Comparable, CustomStringConvertible {
    var value: Int?
    var children: [PacketValue]?

    init(children: [PacketValue]) {
        self.children = children
    }

    init(value: Int) {
        self.value = value
    }

    var description: String {
        if value != nil { return String(value!) }
        if children != nil { return children!.description }
        return "nil"
    }

    static func compare(_ lhs: Int, _ rhs: Int) -> ComparisonResult {
        if lhs < rhs { return ComparisonResult.orderedAscending }
        if lhs == rhs { return ComparisonResult.orderedSame }
        return ComparisonResult.orderedDescending
    }

    static func compare(_ lhs: [PacketValue], _ rhs: [PacketValue]) -> ComparisonResult {
        var lhs = lhs
        var rhs = rhs
        while !lhs.isEmpty && !rhs.isEmpty {
            let leftValue = lhs.removeFirst()
            let rightValue = rhs.removeFirst()
            let result = compare(leftValue, rightValue)
            if result != ComparisonResult.orderedSame { return result }
        }
        if lhs.isEmpty && rhs.isEmpty { return ComparisonResult.orderedSame }
        return rhs.isEmpty ? ComparisonResult.orderedDescending : ComparisonResult.orderedAscending
    }

    static func compare(_ lhs: PacketValue, _ rhs: PacketValue) -> ComparisonResult {
        var lhs = lhs
        var rhs = rhs
        if lhs.value != nil && rhs.value != nil { return compare(lhs.value!, rhs.value!) }
        if lhs.children == nil && rhs.children == nil { return ComparisonResult.orderedSame }
        if lhs.value != nil && rhs.children != nil { lhs = PacketValue(children: [PacketValue(value: lhs.value!)]) }
        if lhs.children != nil && rhs.value != nil { rhs = PacketValue(children: [PacketValue(value: rhs.value!)]) }
        return compare(lhs.children!, rhs.children!)
    }

    static func == (lhs: PacketValue, rhs: PacketValue) -> Bool {
        return compare(lhs, rhs) == ComparisonResult.orderedSame
    }

    static func < (lhs: PacketValue, rhs: PacketValue) -> Bool {
        return compare(lhs, rhs) == ComparisonResult.orderedAscending
    }

    static func construct() -> PacketValue? {
        guard let line = readLine() else { return nil }
        var valueStack = [PacketValue]()
        var firstValue: PacketValue?
        var iterator = line.makeIterator()

        while var char = iterator.next() {
            inner: repeat {
                if char == "[" {
                    let newValue = PacketValue(children: [PacketValue]())
                    if firstValue == nil { firstValue = newValue }
                    if !valueStack.isEmpty { valueStack.last!.children!.append(newValue) }
                    valueStack.append(newValue)
                } else if char == "]" {
                    _ = valueStack.popLast()
                } else if char == "," {
                    // no-op
                } else if char.isNumber {
                    var digitString = String(char)
                    while let innerChar = iterator.next() {
                        if innerChar.isNumber {
                            digitString.append(char)
                        } else { char = innerChar; break }
                    }
                    valueStack.last!.children!.append(PacketValue(value: Int(digitString) ?? 0))
                    continue inner
                }
            } while false
        }
        return firstValue
    }
}

let elapsed = ContinuousClock().measure {
    var index = 1
    var score = 0
    while true {
        guard let first = PacketValue.construct() else { return }
        guard let second = PacketValue.construct() else { return }

        if first < second { score += index }

        let newline = readLine()
        if newline == nil { break }

        index += 1
    }
    print("Score: \(score)")
}

print("Elapsed Total: \(elapsed)")
