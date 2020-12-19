#!/usr/bin/swift

// OperationOrder
// https://adventofcode.com/2020/day/18

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

func isSingleLiteral(_ partialRulesList: [[PartialRule]]) -> Bool {
    return partialRulesList.count == 1 && partialRulesList[0].count == 1 && partialRulesList[0][0].isLiteral
}

func isMultipleLiteral(_ partialRulesList: [[PartialRule]]) -> Bool {
    return partialRulesList.allSatisfy { $0.allSatisfy { $0.isLiteral } }
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

func update(_ rules: Rules, replacing ruleIndexToReplace: Int, with newPartialRule: PartialRule) -> Rules {
    let updatedRules = rules.map { (ruleIndex, partialRulesList) -> (Int, [[PartialRule]]) in
        let updatedPartialRulesList = partialRulesList.map { (partialRules) -> [PartialRule] in
            partialRules.map { (partialRule) -> PartialRule in
                guard case let .rule(index) = partialRule else { return partialRule }
                return index == ruleIndexToReplace ? newPartialRule : partialRule
            }
        }
        let flattenedRulesList = joinLiterals(partialRulesList: updatedPartialRulesList)
        return (ruleIndex, flattenedRulesList)
    }
    return Dictionary(uniqueKeysWithValues: updatedRules)
}

func update(_ rules: Rules, replacing ruleIndexToReplace: Int, with newPartialRules: [[PartialRule]]) -> Rules {
    let updatedRules = rules.map { (ruleIndex, rulesList) -> (Int, [[PartialRule]]) in
        var newRulesList = [[PartialRule]]()
        for ruleIndices in rulesList {
            for (index, partialRule) in ruleIndices.enumerated() {
                if case let .rule(ruleIndex) = partialRule, ruleIndex == ruleIndexToReplace {
                    let prefix = ruleIndices.prefix(upTo: index)
                    let suffix = ruleIndices.suffix(from: index+1)
                    let permutations = newPartialRules.map {
                        Array(prefix + $0 + suffix)
                    }
                    newRulesList.append(contentsOf: permutations)
                }
            }
        }
        let flattenedRulesList = joinLiterals(partialRulesList: newRulesList)
        let updatedRules = flattenedRulesList.count > 0 ? flattenedRulesList : rulesList
        return (ruleIndex, updatedRules)
    }
    return Dictionary(uniqueKeysWithValues: updatedRules)
}

func reduce(rules: Rules) -> Rules {
    var newRulesList = rules

    var rulesToReduce = Set(rules.keys)
    while let singleLiteralRule = rulesToReduce.first(where: { isSingleLiteral(newRulesList[$0]!) }) {
        let literal = newRulesList[singleLiteralRule]![0][0]
        newRulesList = update(newRulesList, replacing: singleLiteralRule, with: literal)
        rulesToReduce.remove(singleLiteralRule)
    }

    while let multipleLiteralRule = rulesToReduce.first(where: { isMultipleLiteral(newRulesList[$0]!) }) {
        let literals = newRulesList[multipleLiteralRule]!
        newRulesList = update(newRulesList, replacing: multipleLiteralRule, with: literals)
        rulesToReduce.remove(multipleLiteralRule)
    }

    // while !rulesToReduce.isEmpty {

    // }

    if !rulesToReduce.isEmpty {
        print("Rules remaining:")
        for rule in rulesToReduce {
            print("  \(rule): \(newRulesList[rule]!)")
        }
    }
    //assert(rulesToReduce.isEmpty)

    return newRulesList
}

func print(_ rules: Rules) {
    for index in rules.keys.sorted() {
        print("\(index): \(rules[index]!)")
    }
}

//let input = mockData()
let input = readFile(named: "19-input")
let (rules, messages) = parse(input)
print(rules)
print()

let reducedRules = reduce(rules: rules)
print(reducedRules)
// print()

let rule0Values = Set(reducedRules[0]!.compactMap { $0.first?.literalValue })
print(rule0Values)

let matches = messages.filter { rule0Values.contains($0) }.count
print(matches)
