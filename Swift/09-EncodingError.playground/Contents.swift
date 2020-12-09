// Encoding Error
// https://adventofcode.com/2020/day/9

import Foundation

func readFile(named name: String) -> [String] {
    guard let fileURL = Bundle.main.url(forResource: name, withExtension: "txt"),
          let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name).txt")
        return []
    }
    return content.components(separatedBy: .newlines)
}

func mockData() -> [String] {
    return [
        "35",
        "20",
        "15",
        "25",
        "47",
        "40",
        "62",
        "55",
        "65",
        "95",
        "102",
        "117",
        "150",
        "182",
        "127",
        "219",
        "299",
        "277",
        "309",
        "576",
    ]
}

func findInvalidValue(in data: [Int], windowSize: Int) -> Int? {
    for index in windowSize ..< data.count {
        let current = data[index]
        let window = Set(data[index-windowSize ..< index])
        let matches = window.filter { value1 in
            let value2 = current - value1
            return value2 != value1 && window.contains(value2)
        }
        if matches.isEmpty {
            return current
        }
    }
    return nil
}

func findWeaknessRange(in data: [Int], target: Int) -> (lower: Int, upper: Int)? {
    // Assume the values that sum to the target occur before the target
    // itself. This isn't guaranteed but seems likely and is true for the
    // dataset I was given. This optimization greatly reduces the number
    // of iterations through the inner loop.
    guard let targetIndex = data.firstIndex(of: target) else { return nil }
    for upperIndex in stride(from: targetIndex-1, through: 0, by: -1) {
        var sum = data[upperIndex]
        var lowerIndex = upperIndex
        while sum < target && lowerIndex > 0 {
            lowerIndex -= 1
            sum += data[lowerIndex]
        }
        if sum == target {
            return (lower: lowerIndex, upper: upperIndex)
        }
    }
    return nil
}

func findWeakness(in data: [Int], target: Int) -> Int? {
    guard let (lowerIndex, upperIndex) = findWeaknessRange(in: data, target: target) else {
        return nil
    }
    let sumData = data[lowerIndex...upperIndex]
    guard let min = sumData.min(), let max = sumData.max() else { return nil }
    return min + max
}

let data = readFile(named: "09-input").compactMap { Int($0) }
let invalidValue = findInvalidValue(in: data, windowSize: 25)!
print("The first number that does not match the pattern is \(invalidValue)")

let weakness = findWeakness(in: data, target: invalidValue)!
print("The encryption weakness is \(weakness)")
