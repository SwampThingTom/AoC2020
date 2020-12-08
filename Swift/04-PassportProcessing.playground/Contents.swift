// Passport Processing
// https://adventofcode.com/2020/day/4

import Foundation

func readFile(named name: String) -> [String] {
    guard let fileURL = Bundle.main.url(forResource: name, withExtension: "txt"),
          let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name).txt")
        return []
    }
    return content.components(separatedBy: .newlines)
}

func mockPassportBatch() -> [String] {
    return [
        "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd",
        "byr:1937 iyr:2017 cid:147 hgt:183cm",
        "",
        "iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884",
        "hcl:#cfa07d byr:1929",
        "",
        "hcl:#ae17e1 iyr:2013",
        "eyr:2024",
        "ecl:brn pid:760753108 byr:1931",
        "hgt:179cm",
        "",
        "hcl:#cfa07d eyr:2025 pid:166559648",
        "iyr:2011 ecl:brn hgt:59in"
    ]
}

func parsePassports(lines: [String]) -> [[String : String]] {
    var passports = [[String : String]]()
    var passport = [String : String]()
    for line in lines {
        guard !line.isEmpty else {
            passports.append(passport)
            passport = [String : String]()
            continue
        }
        let fields = parseFields(line: line)
        passport.merge(fields) { (_, new) in new }
    }
    return passports
}

func parseFields(line: String) -> [String : String] {
    var fields = [String : String]()
    let fieldsString = line.split(separator: " ")
    for field in fieldsString {
        let values = field.split(separator: ":")
        guard values.count == 2 else {
            continue
        }
        let key = String(values[0])
        let value = String(values[1])
        fields[key] = value
    }
    return fields
}

func hasRequiredFields(passport: [String : String]) -> Bool {
    let requiredFieldKeys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
    let requiredFields = requiredFieldKeys.compactMap { passport[$0] }
    return requiredFields.count == requiredFieldKeys.count
}

func hasValidRequiredFields(passport: [String : String]) -> Bool {
    let requiredFields = [
        ("byr", { value in isValidYear(value, min: 1920, max: 2002) }),
        ("iyr", { value in isValidYear(value, min: 2010, max: 2020) }),
        ("eyr", { value in isValidYear(value, min: 2020, max: 2030) }),
        ("hgt", isValidHeight),
        ("hcl", isValidHairColor),
        ("ecl", isValidEyeColor),
        ("pid", isValidPassportId)]
    let hasValidFields = requiredFields.reduce(true) { (result, keyValidator) in
        let (key, isValid) = keyValidator
        return result && isValid(passport[key])
    }
    return hasValidFields
}

func isValidYear(_ string: String?, min: Int, max: Int) -> Bool {
    guard let string = string else { return false }
    guard let year = Int(string) else { return false }
    return min...max ~= year
}

func isValidHeight(_ string: String?) -> Bool {
    guard let string = string else { return false }
    guard let value = Int(string.dropLast(2)) else { return false }
    let validInches = 59...76
    let validCentimeters = 150...193
    return
        (string.hasSuffix("in") && validInches ~= value) ||
        (string.hasSuffix("cm") && validCentimeters ~= value)
}

func isValidHairColor(_ string: String?) -> Bool {
    guard let string = string else { return false }
    guard string.hasPrefix("#") else { return false }
    let value = string.dropFirst()
    let valid = CharacterSet(charactersIn: "0123456789abcdef")
    return value.unicodeScalars.allSatisfy { valid.contains($0) }
}

func isValidEyeColor(_ string: String?) -> Bool {
    guard let string = string else { return false }
    let valid: Set = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    return valid.contains(string)
}

func isValidPassportId(_ string: String?) -> Bool {
    guard let string = string else { return false }
    guard string.count == 9 else { return false }
    let valid = CharacterSet.decimalDigits
    return string.unicodeScalars.allSatisfy { valid.contains($0) }
}

let passportStrings = readFile(named: "04-input")
let passports = parsePassports(lines: passportStrings)
let passportsWithRequiredFields = passports.filter { hasRequiredFields(passport: $0) }
print("There are \(passportsWithRequiredFields.count) passports with all of the required fields")

let validPassports = passports.filter { hasValidRequiredFields(passport: $0) }
print("There are \(validPassports.count) valid passports")
