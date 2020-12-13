#!/usr/bin/Swift

import Foundation

func mkdir(_ path: String) {
    guard !FileManager.default.fileExists(atPath: path) else {
        print("Directory already exists: \(path)")
        return
    }
    print("mkdir \(path)")
    do {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print(error.localizedDescription);
    }
}

func mv(from source: String, to dest: String) {
    guard FileManager.default.fileExists(atPath: source) else {
        print("File does not exist: \(source)")
        return
    }
    print("mv \(source) \(dest)")
    do {
        try FileManager.default.moveItem(atPath: source, toPath: dest)
    } catch {
        print(error.localizedDescription)
    }
}

let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
    exit(0)
}

let playgroundURLs = fileURLs.filter { $0.pathExtension == "playground" }
playgroundURLs.forEach {
    let newDirectoryURL = $0.deletingPathExtension()
    let newDirectory = newDirectoryURL.lastPathComponent
    mkdir(newDirectory)

    let sourcePath = $0.appendingPathComponent("Contents.swift").path
    let newSourceName = String(newDirectory.dropFirst(3) + ".swift")
    let newSourcePath = newDirectoryURL.appendingPathComponent(newSourceName).path
    mv(from: sourcePath, to: newSourcePath)

    let inputName = String(newDirectory.prefix(3) + "input.txt")
    let inputPath = $0.appendingPathComponent("Resources").appendingPathComponent(inputName).path
    let newInputPath = newDirectoryURL.appendingPathComponent(inputName).path
    mv(from: inputPath, to: newInputPath)
}