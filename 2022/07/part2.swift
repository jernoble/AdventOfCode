class Dir {
    var parent: Dir?
    var name: String
    var next: Dir?
    var firstChild: Dir?
    var size: Int = 0
    func totalSize() -> Int {
        var size = 0
        walk { size += $0.size }
        return size
    }

    init(parent: Dir?, name: String, next: Dir? = nil) {
        self.parent = parent
        self.name = name
        self.next = next
    }

    func walk(_ closure: (_ dir: Dir) -> Void) {
        closure(self)
        var child: Dir? = firstChild
        while child != nil {
            child?.walk(closure)
            child = child?.next
        }
    }
}

let elapsed = ContinuousClock().measure {
    let root = Dir(parent: nil, name: "/")
    root.parent = root
    var cwd: Dir = root
    var savedLine: String?
    outer: while true {
        guard let line = savedLine ?? readLine() else { break }
        savedLine = nil
        let input = line.split(separator: " ")
        if input.count == 0 { continue }
        if input[0] == "$" {
            if input[1] == "cd" {
                if input[2] == "/" { cwd = root }
                else if input[2] == ".." { cwd = cwd.parent! }
                else {
                    let newDir = Dir(parent: cwd, name: String(input[2]), next: cwd.firstChild)
                    cwd.firstChild = newDir
                    cwd = newDir
                }
            } else if input[1] == "ls" {
                ls: while true {
                    guard let lsLine = readLine() else { break }
                    let lsInput = lsLine.split(separator: " ")
                    if lsInput.count == 0 { continue ls }
                    if lsInput[0] == "$" {
                        savedLine = lsLine
                        continue outer
                    }
                    if lsInput[0] == "dir" { continue ls }
                    if let size = Int(lsInput[0]) { cwd.size += size }
                }
            }
        }
    }
    let capacity = 70_000_000
    let spaceRequired = 30_000_000
    let freeSpace = capacity - root.totalSize()
    let spaceNeeded = spaceRequired - freeSpace
    var smallestDirBigEnough: Dir?

    root.walk {
        let localTotalSize = $0.totalSize()
        if localTotalSize <= spaceNeeded { return }
        if smallestDirBigEnough == nil || localTotalSize < smallestDirBigEnough!.totalSize() { smallestDirBigEnough = $0 }
    }
    if smallestDirBigEnough == nil {
        print("Could not find directory big enough")
    } else {
        print("SmallestDirBigEnough: \(smallestDirBigEnough!.name) \(smallestDirBigEnough!.totalSize())")
    }
}

print("Elapsed: \(elapsed)")
