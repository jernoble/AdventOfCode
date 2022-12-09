
let elapsed = ContinuousClock().measure {
    var score = 0
    while true {
        guard let line = readLine() else { break }
        let assignments = line.split(separator: ",")
        if assignments.count != 2 { break }

        let a: [Int] = assignments[0].split(separator: "-").map { Int($0) ?? 0 }
        let b: [Int] = assignments[1].split(separator: "-").map { Int($0) ?? 0 }
        if a.count != 2 || b.count != 2 { break }

        if a[0] <= b[1], a[1] >= b[0] { score += 1 }
        else if b[0] <= a[1], b[1] >= a[0] { score += 1 }
    }

    print("Score: \(score)")
}

print("Elapsed: \(elapsed)")
