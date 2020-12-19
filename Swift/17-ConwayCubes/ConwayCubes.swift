#!/usr/bin/swift

// Conway Cubes
// https://adventofcode.com/2020/day/17

import Foundation

func readFile(named name: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: name + ".txt", relativeTo: currentDirectoryURL)
    guard let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name)")
        print("Current directory: \(currentDirectoryURL)")
        return []
    }
    return content.components(separatedBy: .newlines)
}

func mockData() -> [String] {
    return [
        ".#.",
        "..#",
        "###",
    ]
}

struct Coordinate3D: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

typealias ActiveCells = Set<Coordinate3D>

// func update(min: Int, max: Int, value: Int) -> (Int, Int) {
//     if value <= min { return (value, max) }
//     if value >= max { return (min, value) }
//     return (min, max)
// }

struct ConwayCube: CustomStringConvertible {
    let activeCells: ActiveCells
    let minX: Int, maxX: Int
    let minY: Int, maxY: Int
    let maxZ: Int

    var description: String {
        var description = ""
        for z in -maxZ ... maxZ {
            description.append("z=\(z)\n")
            for y in minY ... maxY {
                var row = ""
                for x in minX ... maxX {
                    let char = cellIsActive(x, y, abs(z)) ? "#" : "."
                    row.append(char)
                }
                row.append("\n")
                description.append(row)
            }
            description.append("\n")
        }
        description.append("count: \(count)\n")
        return description
    }

    var count: Int {
        return activeCells.reduce(0) { result, coordinate in
            return result + (coordinate.z == 0 ? 1 : 2)
        }
    }

    init(input: [String]) {
        var cells = ActiveCells()
        input.enumerated().forEach { y, rowString in
            rowString.enumerated().forEach { x, char in
                if char == "#" {
                    cells.insert(Coordinate3D(x: x, y: y, z: 0))
                }
            }
        }
        activeCells = cells
        (minX, maxX) = (0, (input.first?.count ?? 0) - 1)
        (minY, maxY) = (0, input.count - 1)
        maxZ = 0
    }

    init(activeCells: ActiveCells, xRange: (Int, Int), yRange: (Int, Int), maxZ: Int) {
        self.activeCells = activeCells
        (self.minX, self.maxX) = xRange
        (self.minY, self.maxY) = yRange
        self.maxZ = maxZ
    }

    func runCycle() -> ConwayCube {
        var cells = ActiveCells()
        let (newMinX, newMaxX) = (minX-1, maxX+1)
        let (newMinY, newMaxY) = (minY-1, maxY+1)
        let newMaxZ = maxZ+1
        for z in 0 ... maxZ+2 {
            for y in minY-2 ... maxY+2 {
                for x in minX-2 ... maxX+2 {
                    if cellIsActive(x, y, z) {
                        let neighbors = activeNeighborCount(x, y, z)
                        //print("Cell (\(x), \(y), \(z)) has \(neighbors) neighbors")
                        if neighbors == 2 || neighbors == 3 {
                            //print("  cell became active")
                            cells.insert(Coordinate3D(x: x, y: y, z: z))
                            // (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                            // (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                            // newMaxZ = max(newMaxZ, z)
                        }
                    } else {
                        let neighbors = activeNeighborCount(x, y, z)
                        //print("Cell (\(x), \(y), \(z)) has \(neighbors) neighbors")
                        if neighbors == 3 {
                            //print("  cell became active")
                            cells.insert(Coordinate3D(x: x, y: y, z: z))
                            // (newMinX, newMaxX) = update(min: newMinX, max: newMaxX, value: x)
                            // (newMinY, newMaxY) = update(min: newMinY, max: newMaxY, value: y)
                            // newMaxZ = max(newMaxZ, z)
                        }
                    }
                }
            }
        }
        //print("new ranges: (\(newMinX), \(newMaxX)) (\(newMinY), \(newMaxY))) (\(-newMaxZ), \(newMaxZ)))")
        return ConwayCube(activeCells: cells, xRange: (newMinX, newMaxX), yRange: (newMinY, newMaxY), maxZ: newMaxZ)
    }

    func cellIsActive(_ x: Int, _ y: Int, _ z: Int) -> Bool {
        return activeCells.contains(Coordinate3D(x: x, y: y, z: z))
    }

    func activeNeighborCount(_ x: Int, _ y: Int, _ z: Int) -> Int {
        var count = 0
        for neighborZ in z-1 ... z+1 {
            for neighborY in y-1 ... y+1 {
                for neighborX in x-1 ... x+1 {
                    guard (x, y, z) != (neighborX, neighborY, neighborZ) else { continue }
                    if cellIsActive(neighborX, neighborY, abs(neighborZ)) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
}

//let input = mockData()
let input = readFile(named: "17-input")
var cube = ConwayCube(input: input)
//print(cube)

for _ in 1...6 {
    cube = cube.runCycle()
    //print("after cycle \(i)")
    //print(cube)
}
print("After 6 cycles, there are \(cube.count) active cubes")