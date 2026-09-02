//
//  FileLogTests.swift
//  AirNameTests
//

import Foundation
import Testing
@testable import AirName

struct FileLogTests {

    private func temporaryLogPath() -> String {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FileLogTests-\(UUID().uuidString)", isDirectory: true)
        return directory.appendingPathComponent("tool.log").path
    }

    private func removeDirectory(of path: String) {
        try? FileManager.default.removeItem(atPath: (path as NSString).deletingLastPathComponent)
    }

    @Test func formatLinePadsLevelAndFlattensNewlines() {
        let stamp = "2026-01-02 03:04:05"
        #expect(FileLog.formatLine(level: .debug, message: "m", timestamp: stamp) == "[\(stamp)] DEBUG  m\n")
        #expect(FileLog.formatLine(level: .info, message: "m", timestamp: stamp) == "[\(stamp)]  INFO  m\n")
        #expect(FileLog.formatLine(level: .warn, message: "m", timestamp: stamp) == "[\(stamp)]  WARN  m\n")
        #expect(FileLog.formatLine(level: .error, message: "m", timestamp: stamp) == "[\(stamp)] ERROR  m\n")
        #expect(FileLog.formatLine(level: .info, message: "a\nb\r\nc", timestamp: stamp) == "[\(stamp)]  INFO  a b c\n")
    }

    @Test func writeCreatesDirectoryAndUsesLocalTimestamp() throws {
        let path = temporaryLogPath()
        defer { removeDirectory(of: path) }
        let log = FileLog(path: path)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        log.write(.info, "hello", date: date)
        log.write(.error, "boom", date: date)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stamp = formatter.string(from: date)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        #expect(contents == "[\(stamp)]  INFO  hello\n[\(stamp)] ERROR  boom\n")

        let pattern = #"^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] (DEBUG| INFO| WARN|ERROR)  .+$"#
        for line in contents.split(separator: "\n") {
            #expect(line.range(of: pattern, options: .regularExpression) != nil, "unexpected line: \(line)")
        }

        let directory = (path as NSString).deletingLastPathComponent
        let attributes = try FileManager.default.attributesOfItem(atPath: directory)
        #expect(((attributes[.posixPermissions] as? Int) ?? 0) & 0o777 == 0o755)
    }

    @Test func rotationKeepsFiveGenerationsNewestFirst() throws {
        let path = temporaryLogPath()
        defer { removeDirectory(of: path) }
        let maxBytes = 120
        let log = FileLog(path: path, maxBytes: maxBytes, generations: 5)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        for index in 0..<60 {
            log.write(.info, String(format: "line %03d", index), date: date)
        }

        let manager = FileManager.default
        #expect(manager.fileExists(atPath: path))
        for generation in 1...5 {
            #expect(manager.fileExists(atPath: "\(path).\(generation)"), "missing generation \(generation)")
        }
        #expect(!manager.fileExists(atPath: "\(path).6"))

        var paths = [path]
        paths += (1...5).map { "\(path).\($0)" }
        var previousFirstIndex = Int.max
        for candidate in paths {
            let size = (try manager.attributesOfItem(atPath: candidate)[.size] as? Int) ?? 0
            #expect(size <= maxBytes, "\(candidate) exceeds the size limit")
            let contents = try String(contentsOfFile: candidate, encoding: .utf8)
            let first = contents.split(separator: "\n").first.map(String.init) ?? ""
            let number = Int(first.suffix(3)) ?? -1
            #expect(number < previousFirstIndex, "\(candidate) is not older than the file before it")
            previousFirstIndex = number
        }
    }

    @Test func defaultPathForUnprivilegedUser() {
        if FileLog.isRoot {
            #expect(FileLog.defaultPath(tool: "tool") == "/Library/Managed Utilities/logs/tool.log")
        } else {
            #expect(FileLog.defaultPath(tool: "tool").hasSuffix("/Library/Logs/tool.log"))
            #expect(!FileLog.defaultPath(tool: "tool").hasPrefix("/Library/"))
        }
    }
}
