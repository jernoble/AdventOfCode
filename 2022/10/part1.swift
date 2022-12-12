let elapsed = ContinuousClock().measure {
    var values = [1, 1]
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
    let total = stride(from: 20, to: values.count, by: 40).reduce(0) {
        print("\($1) * \(values[$1]) = \($1 * values[$1])")
        return $0 + $1 * values[$1]
    }
    print("Total: \(total)")
}

print("Elapsed Total: \(elapsed)")
