let elapsed = ContinuousClock().measure {
    var rows = [[Int]]()
    var columns = [[Int]]()
    let elapsedParse = ContinuousClock().measure {
        while true {
            guard let line = readLine() else { break }
            let input = Array(line)
            let row = input.map { $0.wholeNumberValue ?? 0 }
            rows.append(row)
        }
        for (i, _) in rows[0].enumerated() {
            columns.append(rows.map { $0[i] })
        }
    }
    print("Elapsed Parsing: \(elapsedParse)")

    let elapsedCalculate = ContinuousClock().measure {
        var score = 2 * (rows.count - 1) + 2 * (columns.count - 1)
        var visibleTrees = [[Int]](repeating: [Int](repeating: 0, count: columns.count - 2), count: rows.count - 2)
        var max = 0
        func test(_ i: Int, _ j: Int) {
            let value = rows[i + 1][j + 1]
            if value > max {
                visibleTrees[i][j] = 1
                max = value
            }
        }
        for (i, row) in visibleTrees.enumerated() {
            max = rows[i + 1].first!
            for (j, _) in row.enumerated() { test(i, j) }
            max = rows[i + 1].last!
            for (j, _) in row.enumerated().reversed() { test(i, j) }
        }
        for (j, _) in visibleTrees[0].enumerated() {
            max = columns[j + 1].first!
            for (i, _) in visibleTrees.enumerated() { test(i, j) }
            max = columns[j + 1].last!
            for (i, _) in visibleTrees.enumerated().reversed() { test(i, j) }
        }

        score = visibleTrees.reduce(score) {
            $0 + $1.reduce(0, +)
        }

        print("Score: \(score)")
    }
    print("Elapsed Calculating: \(elapsedCalculate)")
}

print("Elapsed Total: \(elapsed)")
