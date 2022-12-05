
let elapsed = ContinuousClock().measure {
    var crates: [[Character]] = Array()
    while true {
        if let line = readLine() {
            if line.isEmpty { break }

            let stringArray = Array(line)
            if stringArray[1] == "1" { break }

            for (i, j) in stride(from: 1, to: stringArray.count, by: 4).enumerated() {
                if i == crates.count { crates.append(Array()) }
                if stringArray[j] == " " { continue }
                crates[i].insert(stringArray[j], at: 0)
            }
        } else { break }
    }

    while true {
        if let line = readLine() {
            if line.isEmpty { continue }
            let instructions = line.split(separator: " ")
            if let count = Int(instructions[1]), let from = Int(instructions[3]), let to = Int(instructions[5]) {
                let movePoint = crates[from - 1].count - count

                crates[to - 1].append(contentsOf: crates[from - 1][movePoint...])
                crates[from - 1].removeSubrange(movePoint...)
            }
        } else { break }
    }
    print(String(crates.map { $0.last! }))
}

print("Elapsed: \(elapsed)")
