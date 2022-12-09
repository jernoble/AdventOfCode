
let elapsed = ContinuousClock().measure {
    var crates: [[Character]] = Array()
    while true {
        guard let line = readLine() else { break }
        if line.isEmpty { break }

        let stringArray = Array(line)
        if stringArray[1] == "1" { break }

        for (i, j) in stride(from: 1, to: stringArray.count, by: 4).enumerated() {
            if i == crates.count { crates.append(Array()) }
            if stringArray[j] == " " { continue }
            crates[i].insert(stringArray[j], at: 0)
        }
    }

    while true {
        guard let line = readLine() else { break }
        if line.isEmpty { continue }
        let instructions = line.split(separator: " ")
        if let count = Int(instructions[1]), let from = Int(instructions[3]), let to = Int(instructions[5]) {
            for _ in 0 ..< count {
                crates[to - 1].append(crates[from - 1].popLast()!)
            }
        }
    }
    print(String(crates.map { $0.last! }))
}

print("Elapsed: \(elapsed)")
