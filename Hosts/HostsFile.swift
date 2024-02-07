//
//  HostsFile.swift
//  Hosts
//
//  Created by Jack Miller on 1/31/24.
//

import Foundation
import Network

enum HostsFileLine {
    case entry(HostsFileEntry)
    case other(String)
}

class HostsFile: ObservableObject {
    private static let commentCharacter = "#"

    let filePath: String
    @Published var lines: [HostsFileLine]

    init(filePath: String) throws {
        self.filePath = filePath
        self.lines = []
        try self.parseFile()
    }

    private func parseFile() throws {
        self.lines = try HostsFile.parseLines(filePath: self.filePath)
    }

    private static func parseLines(filePath: String) throws -> [HostsFileLine] {
        try String(contentsOfFile: filePath)
            .components(separatedBy: .newlines)
            .enumerated()
            .map(parseLine)
    }

    private static func parseLine(lineNumber: Int, lineContent: String) -> HostsFileLine {
        var line = lineContent.trimmingCharacters(in: .whitespaces)

        let enabled = !line.starts(with: commentCharacter)
        line.trimPrefix(commentCharacter)

        let entryCommentSplit = lineContent.split(separator: commentCharacter, maxSplits: 1)
        if entryCommentSplit.count == 0 {
            return .other(lineContent)
        }

        let ipAddressAndHost = String(entryCommentSplit[0])
        let ipAddressAndHostComponents = ipAddressAndHost
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        if ipAddressAndHostComponents.count < 2 {
            return .other(lineContent)
        }
        let ipAddress: String = ipAddressAndHostComponents[0]
        if (!validIPAddress(string: ipAddress)) {
            return .other(lineContent)
        }

        let ipAddressRange = ipAddressAndHost.range(of: ipAddress)!
        let host = ipAddressAndHost[ipAddressRange.upperBound...]
            .trimmingCharacters(in: .whitespaces)

        let comment = if entryCommentSplit.count > 1 { String(entryCommentSplit[1]) } else { "" }

        let entry = HostsFileEntry(
            line: lineContent,
            lineNumber: lineNumber,
            enabled: enabled,
            ipAddress: ipAddress,
            host: host,
            comment: comment)

        return .entry(entry)
    }

    private static func validIPAddress(string: String) -> Bool {
        if IPv4Address(string) != nil {
            return true
        }
        else if IPv6Address(string) != nil {
            return true
        }
        else {
            return false;
        }
    }

    func getEntries() -> [HostsFileEntry] {
        return self.lines.compactMap { line in
            switch line {
            case .entry(let entry):
                return entry
            default:
                return nil
            }
        }
    }

    private func getLineIdxForEntry(id: UUID) -> Int? {
        return self.lines.firstIndex(where: { line in
                switch line {
                case .entry(let entry):
                    return entry.id == id
                default:
                    return false
                }
            })
    }

    func getEntry(id: UUID) -> HostsFileEntry? {
        if let idx = getLineIdxForEntry(id: id) {
            if case .entry(let entry) = self.lines[idx] {
                return entry
            }
        }

        return nil
    }

    func addEntry(entry: HostsFileEntry) {
        self.lines.append(HostsFileLine.entry(entry))
    }

    func removeEntry(id: UUID) {
        if let idx = getLineIdxForEntry(id: id) {
            self.lines.remove(at: idx)
        }
    }

    func reload() throws {
        try self.parseFile()
    }

    func save() throws {
        try self.lines
            .map(hostsFileLineToString)
            .joined(separator: "\n")
            .appending("\n")
            .write(to: URL(filePath: self.filePath), atomically: false, encoding: .utf8)
    }

    private func hostsFileLastWriteTime() throws -> Date {
        let fileAttrs = try FileManager.default.attributesOfItem(atPath: self.filePath)
        return fileAttrs[.modificationDate] as! Date
    }

    private func hostsFileLineToString(line: HostsFileLine) -> String {
        switch line {
        case .entry(let entry):
            return entry.toString()
        case .other(let content):
            return content
        }
    }
}
