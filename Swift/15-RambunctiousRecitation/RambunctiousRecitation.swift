#!/usr/bin/swift

// Rambunctious Recitation
// https://adventofcode.com/2020/day/15

import Foundation

func add(_ number: Int, turn: Int) {
    if let entry = spoken[number] {
        spoken[number] = (entry.1, turn)
        return
    }
    spoken[number] = (nil, turn)
}

func value(for number: Int) -> Int {
    guard let entry = spoken[number], let oldest = entry.0, let last = entry.1 else {
        return 0
    }
    return last - oldest
}

func value(onTurn finalTurn: Int, startingWith: [Int]) -> Int {
    guard finalTurn > startingNumbers.count else { return 0 }

    var lastSpoken = 0
    var turn = 1
    for number in startingNumbers {
        add(number, turn: turn)
        lastSpoken = number
        turn += 1
    }

    while true {
        let number = value(for: lastSpoken)
        add(number, turn: turn)
        if turn == finalTurn {
            return number
        }
        lastSpoken = number
        turn += 1
    }
}

let startingNumbers = [ 18, 8, 0, 5, 4, 1, 20 ]
var spoken = [Int: (Int?, Int?)]()
let part1Value = value(onTurn: 2020, startingWith: startingNumbers)
print("The final value on turn 2020 is \(part1Value)")

spoken = [Int: (Int?, Int?)]()
let part2Value = value(onTurn: 30000000, startingWith: startingNumbers)
print("The final value on turn 30000000 is \(part2Value)")
