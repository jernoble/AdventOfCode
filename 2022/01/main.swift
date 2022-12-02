struct Elf {
    var calories: [UInt32] = Array()
    func sum() -> UInt32 { return calories.reduce(0) { x, y in x + y } }
}

func constructElf() -> Elf? {
    var elf = Elf()
    while true {
        let maybeLine: String? = readLine()
        if maybeLine == nil {
            return nil
        }
        let line = maybeLine!
        if line.isEmpty {
            break
        }
        if let calorieValue = UInt32(line) {
            elf.calories.append(calorieValue)
        } else {
            return nil
        }
    }
    return elf
}

var elves: [Elf] = Array()
while let elf = constructElf() {
    elves.append(elf)
}

print("Found \(elves.count) elves")

elves.sort { x, y in x.sum() > y.sum() }

let topThree = elves[0 ..< 3].map { $0.sum() }

print("topThree: \(topThree.reduce(0) { x, y in x + y })")
