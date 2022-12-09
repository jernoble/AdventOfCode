struct Round {
    enum Throw {
        case Rock, Paper, Scissors
    }

    enum Winner {
        case Left, Right, Tie
    }

    let left: Throw
    let right: Throw

    func winner() -> Winner {
        if left == right { return Winner.Tie }
        switch left {
        case Throw.Rock: return right == Throw.Scissors ? Winner.Left : Winner.Right
        case Throw.Paper: return right == Throw.Rock ? Winner.Left : Winner.Right
        case Throw.Scissors: return right == Throw.Paper ? Winner.Left : Winner.Right
        }
    }

    func winnerScore() -> Int {
        switch winner() {
        case Winner.Left: return 0
        case Winner.Tie: return 3
        case Winner.Right: return 6
        }
    }

    func throwScore() -> Int {
        switch right {
        case Throw.Rock: return 1
        case Throw.Paper: return 2
        case Throw.Scissors: return 3
        }
    }

    func score() -> Int {
        return winnerScore() + throwScore()
    }

    static func construct(with input: String) -> Round? {
        let throwValues = input.split(separator: " ")
        if throwValues.count != 2 { return nil }
        var leftThrow: Throw
        switch throwValues[0] {
        case "A": leftThrow = Throw.Rock
        case "B": leftThrow = Throw.Paper
        case "C": leftThrow = Throw.Scissors
        default: return nil
        }
        var winner: Winner
        switch throwValues[1] {
        case "X": winner = Winner.Left
        case "Y": winner = Winner.Tie
        case "Z": winner = Winner.Right
        default: return nil
        }
        var rightThrow: Throw
        if winner == Winner.Tie { rightThrow = leftThrow } else {
            switch leftThrow {
            case Throw.Rock: rightThrow = winner == Winner.Left ? Throw.Scissors : Throw.Paper
            case Throw.Paper: rightThrow = winner == Winner.Left ? Throw.Rock : Throw.Scissors
            case Throw.Scissors: rightThrow = winner == Winner.Left ? Throw.Paper : Throw.Rock
            }
        }
        return Round(left: leftThrow, right: rightThrow)
    }
}

let elapsed = ContinuousClock().measure {
    var rounds: [Round] = Array()
    while true {
        if let line = readLine() {
            if let round = Round.construct(with: line) {
                rounds.append(round)
            }
            continue
        }
        break
    }

    let total = rounds.reduce(0) { score, round in score + round.score() }
    print("Total: \(total)")
}

print("Elapsed: \(elapsed)")
