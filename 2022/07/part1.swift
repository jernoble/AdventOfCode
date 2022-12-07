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
    var sizeLessThan100k = 0
    root.walk { let totalSize = $0.totalSize(); if totalSize <= 100_000 { sizeLessThan100k += totalSize } }
    print("Score: \(sizeLessThan100k)")
}

print("Elapsed: \(elapsed)")
