struct Rucksack {
    let itemsBitfield: UInt64

    static func construct(with input: String?) -> Rucksack? {
        if input == nil { return nil }
        var items: UInt64 = 0
        for character in input! {
            let itemBitPosition = Rucksack.valueOf(character)
            var itemBinaryValue: UInt64 = 1
            itemBinaryValue &<<= itemBitPosition
            items |= 1 << itemBitPosition
        }
        return Rucksack(itemsBitfield: items)
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

struct Group {
    let rucksacks: [Rucksack]

    func score() -> Int {
        if rucksacks.isEmpty { return 0 }
        var itemsBitfield = rucksacks[0].itemsBitfield
        for rucksack in rucksacks[1...] {
            itemsBitfield &= rucksack.itemsBitfield
        }
        return itemsBitfield.trailingZeroBitCount
    }
}

let elapsed = ContinuousClock().measure {
    var groups: [Group] = Array()
    while true {
        let one = Rucksack.construct(with: readLine())
        let two = Rucksack.construct(with: readLine())
        let three = Rucksack.construct(with: readLine())
        if one == nil || two == nil || three == nil { break }
        groups.append(Group(rucksacks: [one!, two!, three!]))
    }

    print("Found: \(groups.count) groups")

    let total = groups.reduce(0) { score, group in score + group.score() }
    print("Total: \(total)")
}

print("Elapsed: \(elapsed)")
