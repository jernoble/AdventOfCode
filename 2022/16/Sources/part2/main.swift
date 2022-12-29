import Algorithms
import Foundation

class Node: CustomStringConvertible, Hashable, Equatable {
    var name: String
    var score = 0
    var visit = 0
    var connections = [Node]()
    var parentConnections = [Node]()

    init(named name: String) {
        self.name = name
    }

    func add(connection: Node) {
        if !connections.contains(connection) {
            connections.append(connection)
        }
    }

    func add(parent: Node) {
        if !parentConnections.contains(parent) {
            parentConnections.append(parent)
        }
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public var description: String { return "Node \(name), score:\(score), connections:\(names(of: connections))" }
}

struct NodePair: Hashable, Equatable {
    var first: Node
    var second: Node

    static func == (lhs: NodePair, rhs: NodePair) -> Bool {
        return lhs.first == rhs.first && lhs.second == rhs.second
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(first)
        hasher.combine(second)
    }
}

struct Map: CustomStringConvertible {
    var nodes = Set<Node>()
    var start: Node?

    mutating func construct() {
        while var line = readLine() {
            guard line.hasPrefix("Valve ") else { continue }
            line.removeFirst(6)

            guard let nextSpace = line.firstIndex(of: " ") else { continue }
            let name = String(line[..<nextSpace])
            line.removeSubrange(..<nextSpace)

            guard line.hasPrefix(" has flow rate=") else { continue }
            line.removeFirst(15)

            guard let nextSemicolon = line.firstIndex(of: ";") else { continue }
            guard let score = Int(line[..<nextSemicolon]) else { continue }
            line.removeSubrange(..<nextSemicolon)

            if line.hasPrefix("; tunnels lead to valves ") { line.removeFirst(25) }
            else if line.hasPrefix("; tunnel leads to valve ") { line.removeFirst(24) }
            else { print("bad connection: \"\(line)\""); break }

            let destinationNames = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            let destinations = destinationNames.map { nodes.insert(Node(named: $0)).memberAfterInsert }

            let node = nodes.insert(Node(named: name)).memberAfterInsert

            node.connections = destinations

            if score > 0 {
                let subnodeName = name + "'"
                let subnode = nodes.insert(Node(named: subnodeName)).memberAfterInsert
                subnode.score = score
                subnode.connections = destinations
                subnode.parentConnections = [node]

                subnode.connections.append(node)
                subnode.connections.forEach { $0.add(parent: subnode) }

                node.connections.append(subnode)
            }

            node.connections.forEach { $0.add(parent: node) }
        }
        start = nodes.first(where: { $0.name == "AA" })
    }

    var shortestPathCache = [NodePair: [Node]]()

    mutating func shortestPath(from: Node, to: Node) -> [Node] {
        let nodePair = NodePair(first: from, second: to)
        if let existingPath = shortestPathCache[nodePair] {
            return existingPath
        }

        nodes.forEach { $0.visit = -1 }
        from.visit = 0
        var visited = Set<Node>()
        visited.insert(from)
        var round = 1
        while true {
            var newNodes = Set<Node>()
            for node in visited {
                newNodes.formUnion(node.connections)
            }
            newNodes.subtract(visited)
            if newNodes.isEmpty { break }
            newNodes.forEach { $0.visit = round }
            visited.formUnion(newNodes)
            if newNodes.contains(to) { break }
            round += 1
        }
        if to.visit == -1 { return [] }

        var nextNode: Node? = to
        var pathNodes = [nextNode!]
        repeat {
            nextNode = nextNode!.parentConnections.first(where: { $0.visit == nextNode!.visit - 1 })
            if nextNode == nil { break }
            pathNodes.append(nextNode!)
        } while nextNode != nil
        pathNodes.reverse()

        shortestPathCache.updateValue(pathNodes, forKey: nodePair)

        return Array(pathNodes)
    }

    mutating func constructPath(from root: Node, through nodes: [Node]) -> [Node] {
        var path = [root]
        var lastNode = root
        for node in nodes {
            let nextPath = shortestPath(from: lastNode, to: node)
            path.append(contentsOf: nextPath.dropFirst())
            lastNode = node
        }
        return path
    }

    func node(named name: String) -> Node? {
        return nodes.first(where: { $0.name == name })
    }

    func path(named: String) -> [Node] {
        return named.split(separator: " ").map { node(named: String($0)) ?? Node(named: String($0)) }
    }

    var description: String {
        return nodes.map { $0.description }.joined(separator: "\n")
    }
}

func score(path: [Node], limit: Int) -> Int {
    if limit <= 0 { return 0 }
    var score = 0
    for (round, node) in path.enumerated() {
        if round >= limit { break }
        score += (limit - round) * node.score
    }
    return score
}

func names(of nodes: any Collection<Node>) -> String {
    return "[" + nodes.map { $0.name }.joined(separator: " ") + "]"
}

func upperLimit(from: [Node], targets: [Node], limit: Int) -> Int {
    // construct a fake path with empty nodes between scoring nodes
    let fakePath = from + targets.flatMap { [Node(named: "fake"), $0] }
    return score(path: fakePath, limit: limit)
}

let elapsed = ContinuousClock().measure {
    var map = Map()
    let elapsedParse = ContinuousClock().measure {
        map.construct()
        map.nodes.forEach { print($0) }
    }
    print("Elapsed parsing: \(elapsedParse)")

    let valves = map.nodes.filter { $0.score > 0 }.sorted(by: { $0.score > $1.score })

    var fullComparisons = 0
    var abortedComparisons = 0

    func pathFinder(rootPath: [Node], rootLimit: Int, targets: [Node], limit: Int) -> [Node] {
        var targets = targets
        var localScore = 0
        var bestSubPath = [Node]()
        guard let newRoot = rootPath.last else { return [Node]() }

        for target in targets {
            let localTargets = targets.filter { $0 != target }
            let localPath = map.shortestPath(from: newRoot, to: target)
            let localRootScore = score(path: localPath, limit: limit)
            let localLimit = limit - localPath.count + 1

            if localTargets.isEmpty, localRootScore > localScore {
                localScore = localRootScore
                bestSubPath = localPath
                continue
            }

            // Only do a depth-first search if the best-possible case would return
            // a score that is better than the current score
            let upperLimit = upperLimit(from: localPath, targets: localTargets, limit: limit)
            if upperLimit <= localScore {
                abortedComparisons += 1
                continue
            }
            fullComparisons += 1

            let localBestSubPath = pathFinder(rootPath: localPath, rootLimit: rootLimit, targets: localTargets, limit: localLimit)
            let localSubpathScore = score(path: localBestSubPath, limit: limit)

            if localSubpathScore < localScore {
                continue
            }
            localScore = localSubpathScore
            bestSubPath = localBestSubPath
        }

        return rootPath + bestSubPath.dropFirst()
    }

    // Finding the best path using two traversals requires permuting the targets and
    // distributing them among the workers. It also requires distributing each permutation
    // differently to each worker. So the runtime for this should increase by
    // permute(valves).count * valves.count

    // No, it should only require all the combinations(valves) + the inverse of those combinations
    // Each side of that combination is tested separately and the scores combined.

    // No, it should only require half of the combinanations(valves); the other half is tested
    // implicitly by the second worker.

    var bestTwoPaths = [[Node]]()
    var bestScore = 0
    let rootLimit = 26
    for count in 1 ... valves.count / 2 {
        for combination in valves.combinations(ofCount: count) {
            let antiCombination = valves.filter { !combination.contains($0) }

            let upperLimit = upperLimit(from: [map.start!], targets: combination, limit: rootLimit) +
                upperLimit(from: [map.start!], targets: antiCombination, limit: rootLimit)
            if upperLimit <= bestScore {
                abortedComparisons += 1
                continue
            }
            fullComparisons += 1

            let bestCombinationPath = pathFinder(rootPath: [map.start!], rootLimit: rootLimit, targets: combination, limit: rootLimit)
            let bestAntiCombinationPath = pathFinder(rootPath: [map.start!], rootLimit: rootLimit, targets: antiCombination, limit: rootLimit)

            let localBestScore = score(path: bestCombinationPath, limit: rootLimit) + score(path: bestAntiCombinationPath, limit: rootLimit)

            if localBestScore > bestScore {
                bestTwoPaths = [bestCombinationPath, bestAntiCombinationPath]
                bestScore = localBestScore
            }
        }
    }

    print("Best path: \(names(of: bestTwoPaths[0])) & \(names(of: bestTwoPaths[1])), score:\(bestScore)")
    print("Full comparisons: \(fullComparisons), aborted comparisons: \(abortedComparisons)")
}

print("Elapsed Total: \(elapsed)")
