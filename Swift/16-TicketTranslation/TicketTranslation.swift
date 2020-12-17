#!/usr/bin/swift

// Ticket Translation
// https://adventofcode.com/2020/day/16

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

func mockFile2() -> [String] {
    return [
        "class: 0-1 or 4-19",
        "row: 0-5 or 8-19",
        "seat: 0-13 or 16-19",
        "",
        "your ticket:",
        "11,12,13",
        "",
        "nearby tickets:",
        "3,9,18",
        "15,1,5",
        "5,14,19",
    ]
}

typealias RulesMap = [String: Set<Int>]

func parse(_ input: [String]) -> (RulesMap, [Int], [[Int]]) {
    let components = input.split(separator: "")
    let rules = parse(rules: components[0])
    let myTicket = parse(ticket: components[1].last!)
    let otherTickets = parse(otherTickets: components[2].dropFirst())
    return (rules, myTicket, otherTickets)
}

func parse(rules: ArraySlice<String>) -> RulesMap {
    return rules.reduce(into: RulesMap()) { result, rule in
        let components = rule.components(separatedBy: ": ")
        let name = components[0]
        let validRanges = parse(ranges: components[1])
        result[name] = validRanges
    }
}

func parse(ranges: String) -> Set<Int> {
    let components = ranges.components(separatedBy: " or ")
    return components.reduce(into: Set<Int>()) { result, range in
        let minMax = range.components(separatedBy: "-")
        let (min, max) = (Int(minMax[0])!, Int(minMax[1])!)
        result.formUnion(Set(min...max))
    }
}

func parse(ticket: String) -> [Int] {
    return ticket.components(separatedBy: ",").map { Int($0)! }
}

func parse(otherTickets: ArraySlice<String>) -> [[Int]] {
    return otherTickets.map { parse(ticket: $0) }
}

func invalidValues(forTickets tickets: [[Int]], rules: RulesMap) -> [Int] {
    return tickets.flatMap { invalidValues(forTicket: $0, rules: rules) }
}

func invalidValues(forTicket ticket: [Int], rules: RulesMap) -> [Int] {
    return ticket.reduce(into: [Int]()) { result, value in
        if (!rules.values.contains { validValues in validValues.contains(value) }) {
            result.append(value)
        }
    }
}

func isValid(forTicket ticket: [Int], rules: RulesMap) -> Bool {
    return ticket.allSatisfy { value in
        return rules.values.contains { validValues in validValues.contains(value) }
    }
}

// TODO: Finish part 2.
// Original implementation looped over every position to find rules that matched.
// Becaase it didn't accouont for the possibility of multiple rules matching, it
// failed (and returned different "matches" for each run).
//
// New implementations loops over rules trying to find the column(s) that matches.
// It assumes that there will be some set of rules that match only a single column.
//
// Currently ends up in an infinite loop.
func findRulePositions(rules: RulesMap, validTickets: [[Int]]) -> [(Int, String)] {
    var results = [(Int, String)]()
    var rulesFound = Set<String>()
    while rulesFound.count < rules.count {
        for rule in rules {
            guard !rulesFound.contains(rule.0) else { continue }
            if let position = findMatchingPosition(for: rule.1, in: validTickets) {
                results.append((position, rule.0))
                rulesFound.insert(rule.0)
                //print("Position \(position) = \(rule)")
            }
        }
    }
    return results
}

func findMatchingPosition(for validValues: Set<Int>, in tickets: [[Int]]) -> Int? {
    var matches = [Int]()
    for position in 0 ..< tickets[0].count {
        let match = tickets.allSatisfy { validValues.contains($0[position]) }
        if match {
            matches.append(position)
        }
    }
    return matches.count == 1 ? matches[0] : nil
}

//let input = mockFile2()
let input = readFile(named: "16-input")
let (rules, myTicket, otherTickets) = parse(input)

let invalid = invalidValues(forTickets: otherTickets, rules: rules)
let invalidSum = invalid.reduce(0, +)
print("The sum of the invalid ticket values is \(invalidSum)")

let validTickets = otherTickets.filter { isValid(forTicket: $0, rules: rules) }
let rulePositions = findRulePositions(rules: rules, validTickets: validTickets)
let departureRulePositions = rulePositions.filter { $0.1.hasPrefix("departure") }
print(departureRulePositions)
print(myTicket)
let departureProducts = departureRulePositions.reduce(1.0) { $0 * Double(myTicket[$1.0]) }
print("Thhe product of the departure fields is \(departureProducts)")
