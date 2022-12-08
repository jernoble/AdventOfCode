let elapsed = ContinuousClock().measure {
    var rows = [[Int]]()
    var columns = [[Int]]()
    while true {
        guard let line = readLine() else { break }
        let input = Array(line)
        let row = input.map { $0.wholeNumberValue ?? 0 }
        rows.append(row)
    }
    for (i, _) in rows[0].enumerated() {
        columns.append(rows.map { $0[i] })
    }

    var score = 2 * (rows.count - 1) + 2 * (columns.count - 1)
    for i in 1 ..< rows.count - 1 {
        for j in 1 ..< columns.count - 1 {
            if rows[i][0 ..< j].allSatisfy({ $0 < rows[i][j] }) { score += 1; continue }
            if rows[i][j + 1 ..< rows.count].allSatisfy({ $0 < rows[i][j] }) { score += 1; continue }
            if columns[j][0 ..< i].allSatisfy({ $0 < columns[j][i] }) { score += 1; continue }
            if columns[j][i + 1 ..< columns.count].allSatisfy({ $0 < columns[j][i] }) { score += 1; continue }
        }
    }

    print("Score: \(score)")
}

print("Elapsed: \(elapsed)")
