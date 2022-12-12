var crt = [[Bool]](repeating: [Bool](repeating: false, count: 40), count: 6)

let elapsed = ContinuousClock().measure {
    var values = [1]
    while true {
        guard let line = readLine() else { break }
        let instruction = line.split(separator: " ")
        if instruction[0] == "noop" {
            values.append(values.last!)
            continue
        }
        guard let value = Int(instruction[1]) else { break }
        values.append(values.last!)
        values.append(values.last! + value)
    }
    for (index, value) in values.enumerated() {
        let row = index / 40 % 6
        let column = index % 40
        crt[row][column] = abs(column - value) <= 1 ? true : false
    }
    for row in crt {
        print(row.map { $0 ? "#" : "." }.joined())
    }
}

print("Elapsed Total: \(elapsed)")
