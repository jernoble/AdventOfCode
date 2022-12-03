struct Rucksack {
    let left: String
    let right: String

    static func construct(with input: String) -> Rucksack? {
        if input.count % 2 == 1 { return nil }
        let midpoint = input.index(input.startIndex, offsetBy: input.count / 2)
        let left = input[...midpoint]
        let right = input[midpoint...]
        return Rucksack(left: String(left), right: String(right))
    }

    func findCommonItem() -> Character? {
        for item in left {
            if right.contains(item) { return item }
        }
        print("Couldn't find common item!")
        return nil
    }

    static func valueOf(_ item: Character?) -> Int {
        if item == nil { return 0 }
        let firstLowerCharacter = Int(Character("a").asciiValue!)
        let firstUpperCharacter = Int(Character("A").asciiValue!)
        let itemValue = Int(item!.asciiValue!)
        if itemValue >= firstLowerCharacter { return itemValue - firstLowerCharacter + 1 }
        else { return itemValue - firstUpperCharacter + 27 }
    }
}

let elapsed = ContinuousClock().measure {
    var rucksacks: [Rucksack] = Array()
    while true {
        if let line = readLine() {
            if let rucksack = Rucksack.construct(with: line) {
                rucksacks.append(rucksack)
            }
        } else { break }
    }

    print("Found: \(rucksacks.count) rucksacks")

    let total = rucksacks.reduce(0) { score, rucksack in score + Rucksack.valueOf(rucksack.findCommonItem()) }
    print("Total: \(total)")
}

print("Elapsed: \(elapsed)")
