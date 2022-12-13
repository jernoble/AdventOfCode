func readNonEmptyLine() -> String? {
    while true {
        guard let line = readLine() else { return nil }
        if line.isEmpty { continue }
        return line
    }
}

func readAndSplitLine(separator: String, startingWith: String) -> [Substring]? {
    guard let line = readNonEmptyLine() else { return nil }
    let arguments = line.split(separator: separator)
    if arguments.count != 2 || !arguments[0].hasSuffix(startingWith) { return nil }
    return Array(arguments)
}

class Monkey {
    static var monkeys = [Monkey]()
    static var metaDivisor = 1

    static func construct() -> Monkey? {
        guard let titleArguments = readAndSplitLine(separator: " ", startingWith: "Monkey") else { return nil }
        guard let index = Int(titleArguments[1].split(separator: ":")[0]) else { return nil }

        guard let startingItemsArguments = readAndSplitLine(separator: ": ", startingWith: "Starting items") else { return nil }
        let startingItems = startingItemsArguments[1].split(separator: ", ").map { Int($0) ?? 0 }

        guard let operationArguments = readAndSplitLine(separator: ": ", startingWith: "Operation") else { return nil }
        let operationParts = operationArguments[1].split(separator: " ")
        if operationParts.count != 5
            || operationParts[0] != "new"
            || operationParts[1] != "="
            || operationParts[2] != "old" { return nil }
        var op: (_: Int, _: Int) -> Int
        switch operationParts[3] {
        case "*": op = { $0 * $1 }
        case "+": op = { $0 + $1 }
        case "-": op = { $0 - $1 }
        default: return nil
        }
        var operation: (_: Int) -> Int
        if operationParts[4] == "old" {
            operation = { op($0, $0) }
        } else if let rhs = Int(operationParts[4]) {
            operation = { op($0, rhs) }
        } else { return nil }

        guard let testArguments = readAndSplitLine(separator: ": ", startingWith: "Test") else { return nil }
        let testParts = testArguments[1].split(separator: " ")
        guard testParts[0] == "divisible" else { return nil }
        guard let divisor = Int(testParts[2]) else { return nil }

        guard let trueArguments = readAndSplitLine(separator: ": ", startingWith: "If true") else { return nil }
        guard let trueValue = Int(trueArguments[1].split(separator: " ").last!) else { return nil }
        guard let falseArguments = readAndSplitLine(separator: ": ", startingWith: "If false") else { return nil }
        guard let falseValue = Int(falseArguments[1].split(separator: " ").last!) else { return nil }

        let action: (Bool) -> Int = { $0 ? trueValue : falseValue }

        let monkey = Monkey(index: index, startingItems: startingItems, operation: operation, multiplier: 1, divisor: divisor, action: action)
        monkeys.append(monkey)
        return monkey
    }

    var index: Int
    var items: [Int]
    var operation: (_: Int) -> Int
    var action: (_: Bool) -> Int
    var inspectionCount: Int = 0
    var multiplier: Int = 1
    var divisor: Int = 1

    init(index: Int, startingItems: [Int], operation: @escaping (_ input: Int) -> Int, multiplier: Int, divisor: Int, action: @escaping (_ input: Bool) -> Int) {
        self.index = index
        items = startingItems
        self.operation = operation
        self.multiplier = multiplier
        self.divisor = divisor
        self.action = action
    }

    func test(_ item: Int) -> Bool {
        return item % divisor == 0
    }

    func turn() {
        for item in items {
            var value = operation(item)
            value %= Monkey.metaDivisor
            inspect(item: value)
        }
        items = [Int]()
    }

    func inspect(item: Int) {
        inspectionCount += 1
        let destinationMonkey = action(test(item))
        if Monkey.monkeys.count <= destinationMonkey { return }
        Monkey.monkeys[destinationMonkey].items.append(item)
    }

    public var description: String { return "Monkey \(index): \(items)" }
}

let elapsed = ContinuousClock().measure {
    while true {
        guard Monkey.construct() != nil else { break }
    }
    Monkey.metaDivisor = Monkey.monkeys.reduce(1) { $0 * $1.divisor }
    for _ in 0 ..< 10000 {
        for monkey in Monkey.monkeys { monkey.turn() }
    }
    Monkey.monkeys.forEach { print("Monkey \($0.index) inspected items \($0.inspectionCount) times") }
    let total = Monkey.monkeys.map { $0.inspectionCount }.sorted(by:>)[0 ..< 2].reduce(1) { $0 * $1 }
    print("Total: \(total)")
}

print("Elapsed Total: \(elapsed)")
