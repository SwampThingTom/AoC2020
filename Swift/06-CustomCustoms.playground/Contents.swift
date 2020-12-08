// Custom Customs
// https://adventofcode.com/2020/day/6

import Foundation

func readFile(named name: String) -> [String] {
    guard let fileURL = Bundle.main.url(forResource: name, withExtension: "txt"),
          let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name).txt")
        return []
    }
    return content.components(separatedBy: .newlines)
}

func mockCustomsDeclarations() -> [String] {
    return [
        "abc",
        "",
        "a",
        "b",
        "c",
        "",
        "ab",
        "ac",
        "",
        "a",
        "a",
        "a",
        "a",
        "",
        "b"
    ]
}

func questionsAnyoneAnswered(declarations: ArraySlice<String>) -> Set<Character> {
    declarations.reduce([]) { (result, declaration) -> Set<Character> in
        result.union(declaration)
    }
}

func questionsAllAnswered(declarations: ArraySlice<String>) -> Set<Character> {
    declarations.reduce(Set<Character>("abcdefghijklmnopqrstuvwxyz")) { (result, declaration) -> Set<Character> in
        result.intersection(declaration)
    }
}

let declarationsStrings = readFile(named: "06-input")
let groups = declarationsStrings.split(separator: "")

let anyAnswers = groups.map { questionsAnyoneAnswered(declarations: $0) }
let sumOfAnyQuestionCounts = anyAnswers.map { $0.count }.reduce(0, +)
print("The sum of the counts of any yes answers is \(sumOfAnyQuestionCounts)")

let allAnswers = groups.map { questionsAllAnswered(declarations: $0) }
let sumOfAllQuestionCounts = allAnswers.map { $0.count }.reduce(0, +)
print("The sum of the counts of all yes answers is \(sumOfAllQuestionCounts)")