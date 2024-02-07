//
//  HostsFileEntryView.swift
//  Hosts
//
//  Created by Jack Miller on 2/2/24.
//

import SwiftUI

struct HostsFileEntryView: View {
    typealias Callback = (HostsFileEntry) -> Void

    @ObservedObject var entry: HostsFileEntry
    var onToggle: Callback
    var onEdit: Callback
    var onDuplicate: Callback
    var onDelete: Callback

    var body: some View {
        Toggle(isOn: $entry.enabled) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text($entry.host.wrappedValue)
                        .font(.headline)
                    Text($entry.ipAddress.wrappedValue)
                        .font(.subheadline)
                }
                Spacer()
                if !$entry.comment.wrappedValue.isEmpty {
                    Text($entry.comment.wrappedValue)
                        .font(.body)
                }
            }
        }
        .toggleStyle(.switch)
        .onChange(of: entry.enabled) { _ in
            onToggle(entry)
        }
        .contextMenu(menuItems: {
            Button("Edit") {
                onEdit(entry)
            }
            Button("Duplicate") {
                onDuplicate(entry)
            }
            Button("Delete") {
                onDelete(entry)
            }
        })
    }
}
