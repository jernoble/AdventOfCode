struct Rucksack {
    let itemsBitfield: UInt64

    static func construct(with input: String?) -> Rucksack? {
        if input == nil { return nil }
        let stringArray = Array(input!.utf8)
        var items: UInt64 = 0
        for character in stringArray {
            let itemBitPosition = Rucksack.valueOf(character)
            items |= 1 << itemBitPosition
        }
        return Rucksack(itemsBitfield: items)
    }

    static let firstLowerCharacter: UInt8 = Character("a").asciiValue!
    static let firstUpperCharacter: UInt8 = Character("A").asciiValue!

    static func valueOf(_ item: UInt8?) -> Int {
        if item == nil { return 0 }
        let itemValue = item!
        if itemValue >= firstLowerCharacter { return Int(itemValue - firstLowerCharacter + 1) }
        else { return Int(itemValue - firstUpperCharacter + 27) }
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
    var total = 0
    while true {
        let one = Rucksack.construct(with: readLine())
        let two = Rucksack.construct(with: readLine())
        let three = Rucksack.construct(with: readLine())
        if one == nil || two == nil || three == nil { break }
        let group = Group(rucksacks: [one!, two!, three!])
        total += group.score()
    }
    print("Score: \(total)")
}

print("Elapsed: \(elapsed)")
