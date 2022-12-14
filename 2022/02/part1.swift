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
        var rightThrow: Throw
        switch throwValues[1] {
        case "X": rightThrow = Throw.Rock
        case "Y": rightThrow = Throw.Paper
        case "Z": rightThrow = Throw.Scissors
        default: return nil
        }
        return Round(left: leftThrow, right: rightThrow)
    }
}

let elapsed = ContinuousClock().measure {
    var rounds: [Round] = Array()
    while true {
        let maybeLine: String? = readLine()
        if maybeLine == nil {
            break
        }
        let line = maybeLine!
        if let round = Round.construct(with: line) {
            rounds.append(round)
        }
    }

    let total = rounds.reduce(0) { score, round in score + round.score() }
    print("Total: \(total)")
}

print("Elapsed: \(elapsed)")
