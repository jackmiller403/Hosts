//
//  HostsFileEntry.swift
//  Hosts
//
//  Created by Jack Miller on 1/31/24.
//

import Foundation

class HostsFileEntry: Equatable, Identifiable, ObservableObject {
    let id: UUID
    let originalLine: String?
    let lineNumber: Int?

    @Published var enabled: Bool
    @Published var ipAddress: String
    @Published var host: String
    @Published var comment: String

    static func == (lhs: HostsFileEntry, rhs: HostsFileEntry) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
        && lhs.host == rhs.host
        && lhs.comment == rhs.comment
        && lhs.enabled == rhs.enabled
    }

    init(line: String?, lineNumber: Int?, enabled: Bool, ipAddress: String, host: String, comment: String = "") {
        self.id = UUID()
        self.originalLine = line
        self.lineNumber = lineNumber
        self.enabled = enabled
        self.ipAddress = ipAddress
        self.host = host
        self.comment = comment
    }

    convenience init(enabled: Bool, ipAddress: String, host: String, comment: String = "") {
        self.init(
            line: nil,
            lineNumber: nil,
            enabled: enabled,
            ipAddress: ipAddress,
            host: host,
            comment: comment)
    }

    convenience init() {
        self.init(enabled: false, ipAddress: "", host: "")
    }

    func toString() -> String {
        var line = "\(self.enabled ? "" : "# ")\(self.ipAddress) \(self.host)"
        if !comment.isEmpty {
            line += " #\(comment)"
        }
        return line
    }

    func clone() -> HostsFileEntry {
        return HostsFileEntry(
            line: self.originalLine,
            lineNumber: self.lineNumber,
            enabled: self.enabled,
            ipAddress: self.ipAddress,
            host: self.host,
            comment: self.comment)
    }
}
