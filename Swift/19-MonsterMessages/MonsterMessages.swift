#!/usr/bin/swift

// Monster Messages
// https://adventofcode.com/2020/day/19

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
        "0: 4 1 5",
        "1: 2 3 | 3 2",
        "2: 4 4 | 5 5",
        "3: 4 5 | 5 4",
        "4: \"a\"",
        "5: \"b\"",
        "",
        "ababbb",
        "bababa",
        "abbbab",
        "aaabbb",
        "aaaabbb",
    ]
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

enum PartialRule: CustomStringConvertible {
    case literal(_ value: String)
    case rule(_ index: Int)

    var description: String {
        switch self {
        case .literal(let value):
            return value
        case .rule(let index):
            return "\(index)"
        }
    }

    var isRulesReference: Bool {
        if case .rule = self {
            return true
        }
        return false
    }

    var ruleIndex: Int? {
        if case let .rule(index) = self {
            return index
        }
        return nil
    }

    var isLiteral: Bool {
        if case .literal = self {
            return true
        }
        return false
    }

    var literalValue: String? {
        if case let .literal(value) = self {
            return value
        }
        return nil
    }
}

typealias Rules = [Int: [[PartialRule]]]

func parse(_ input: [String]) -> (Rules, [String]) {
    let components = input.split(separator: "").map { Array($0) }
    return (parse(ruleStrings: components[0]), components[1])
}

func parse(ruleStrings: [String]) -> Rules {
    return ruleStrings.reduce(into: Rules()) { rules, ruleString in
        let components = ruleString.components(separatedBy: ": ")
        let index = Int(components[0])!
        let partialRulesString = components[1].trimmingCharacters(in: .whitespaces)
        let partialRules = parse(partialRulesString: partialRulesString)
        rules[index] = partialRules
    }
}

func parse(partialRulesString: String) -> [[PartialRule]] {
    if partialRulesString.first! == "\"" {
        return [[.literal(String(partialRulesString[1]))]]
    }
    let components = partialRulesString.components(separatedBy: " | ")
    return components.map {
        let indexComponents = $0.components(separatedBy: " ")
        return indexComponents.map { .rule(Int($0)!) }
    }
}

func print(_ rules: Rules) {
    for index in rules.keys.sorted() {
        print("\(index): \(rules[index]!)")
    }
}

func joinLiterals(partialRules: [PartialRule]) -> PartialRule? {
    var joinedLiteralValues = ""
    for partialRule in partialRules {
        guard let literalValue = partialRule.literalValue else { return nil }
        joinedLiteralValues.append(literalValue)
    }
    return .literal(joinedLiteralValues)
}

func joinLiterals(partialRulesList: [[PartialRule]]) -> [[PartialRule]] {
    return partialRulesList.map {
        guard let joinedLiterals = joinLiterals(partialRules: $0) else {
            return $0
        }
        return [joinedLiterals]
    }
}

func permutations(of partialRules: [PartialRule], prefix: [PartialRule], from rules: Rules) -> [[PartialRule]] {
    guard let partialRule = partialRules.first else { return [prefix] }
    guard let ruleIndex = partialRule.ruleIndex else {
        // Replacement is a literal so simply replace it.
        let newPrefix = prefix + [partialRule]
        return permutations(of: Array(partialRules.dropFirst()), prefix: newPrefix, from: rules)
    }

    let replacementRules = rules[ruleIndex]!
    if replacementRules.count == 1 {
        // Replacement is a single list of rules so replace the single rule with the list and recurse.
        let newPartialRules = replacementRules[0] + partialRules.dropFirst()
        return permutations(of: Array(newPartialRules), prefix: prefix, from: rules)
    }

    var thePermutations = [[PartialRule]]()
    for replacementPartialRules in replacementRules {
        // Replacement is a list of subrules so create the permutations and recurse.
        let newPartialRules = replacementPartialRules.map { $0 } + partialRules.dropFirst()
        thePermutations.append(Array(newPartialRules))
    }
    return Array(thePermutations.map { permutations(of: $0, prefix: prefix, from: rules) }.joined())
}

//let input = mockData()
let input = readFile(named: "19-input")
let (rules, messages) = parse(input)

let rule0 = permutations(of: rules[0]![0], prefix: [], from: rules)
let rule0Joined = joinLiterals(partialRulesList: rule0)
let rule0Strings = Set(rule0Joined.compactMap { $0.first?.literalValue } )

let matches = messages.filter { rule0Strings.contains($0) }.count
print("\(matches) messages completely match rule 0")
