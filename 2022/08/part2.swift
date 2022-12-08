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

    var maxScore = 0
    for i in 1 ..< rows.count - 1 {
        for j in 1 ..< columns.count - 1 {
            let value = rows[i][j]
            let left = Array(rows[i][0 ..< j].reversed())
            let right = Array(rows[i][j + 1 ..< rows.count])
            let up = Array(columns[j][0 ..< i].reversed())
            let down = Array(columns[j][i + 1 ..< columns.count])
            func visibility(_ direction: [Int], _ value: Int) -> Int {
                return 1 + (direction.firstIndex(where: { $0 >= value }) ?? direction.count - 1)
            }
            let localScore = visibility(left, value) * visibility(right, value) * visibility(up, value) * visibility(down, value)
            if localScore > maxScore { maxScore = localScore }
        }
    }

    print("Score: \(maxScore)")
}

print("Elapsed: \(elapsed)")
