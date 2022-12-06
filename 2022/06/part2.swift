func isUnique(_ s: Substring) -> Bool {
    var i = s.startIndex
    let lastIndex = s.index(before: s.endIndex)
    while i != lastIndex {
        let nextIndex = s.index(after: i)
        if s[nextIndex ..< s.endIndex].contains(s[i]) { return false }
        i = s.index(after: i)
    }
    return true
}

let elapsed = ContinuousClock().measure {
    guard let line = readLine() else { return }

    let endIndex = line.index(line.endIndex, offsetBy: -14)
    for i in line.indices[line.startIndex ..< endIndex] {
        let substringEnd = line.index(i, offsetBy: 14)
        let substring = line[i ..< substringEnd]
        if isUnique(substring) {
            print("Found: \(substringEnd.utf16Offset(in: line)) - \(substring)")
            return
        }
    }

    print("ERROR: Found nothing")
}

print("Elapsed: \(elapsed)")
