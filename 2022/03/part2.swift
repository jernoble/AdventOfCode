struct Rucksack {
    let itemsBitfield: UInt64

    static func construct(with input: String?) -> Rucksack? {
        if input == nil { return nil }
        let stringArray = Array(input!.utf8)
        var items: UInt64 = 0

        // Get the "value" of each input character, which will be a number from 1 -> 52.
        // Then, "store" this value by setting the Nth bit in a 64-bit integer, where N
        // is equal to the character's "value". This allows each value to appear multiple
        // times in the input string, and only costs 8-bytes to store.
        for character in stringArray {
            let itemBitPosition = Rucksack.valueOf(character)
            items |= 1 << itemBitPosition
        }
        return Rucksack(itemsBitfield: items)
    }

    static let firstLowerCharacter: UInt8 = Character("a").asciiValue!
    static let firstUpperCharacter: UInt8 = Character("A").asciiValue!

    static func valueOf(_ item: UInt8) -> Int {
        if item >= firstLowerCharacter { return Int(item - firstLowerCharacter + 1) }
        else { return Int(item - firstUpperCharacter + 27) }
    }
}

struct Group {
    let rucksacks: [Rucksack]

    func score() -> Int {
        // Storing each Rucksack's `items` as a bitfield makes comparisons between as cheap
        // as bitwise-and'ing the `items` against each other, and extracting the number
        // of trailing zeros from the result.
        // NOTE: this does not validate that there is exactly one "item" in the result.
        // In the case of invalid input, this will return a "score" of 64.
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
