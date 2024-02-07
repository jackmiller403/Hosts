//
//  HostsFileEntryEditor.swift
//  Hosts
//
//  Created by Jack Miller on 2/2/24.
//

import SwiftUI

struct HostsFileEntryEditor: View {
    @ObservedObject var entry: HostsFileEntry
    var onSave: (HostsFileEntry) -> ()
    var onCancel: (HostsFileEntry) -> ()
    var onDelete: ((HostsFileEntry) -> ())?

    var body: some View {
        VStack(alignment: .center) {
            Text("Entry Editor")
                .font(.title)
            Divider()
            Form {
                TextField("Host", text: $entry.host)
                TextField("IP Address", text: $entry.ipAddress)
                TextField("Comment", text: $entry.comment)
                Toggle("Enabled", isOn: $entry.enabled)
            }
            HStack {
                if let onDelete = self.onDelete {
                    Button("Delete") {
                        onDelete(self.entry)
                    }
                }
                Spacer()
                Button("Cancel") {
                    onCancel(self.entry)
                }
                Button("Save") {
                    onSave(self.entry)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: WindowSizeConstants.minEditorWidth)
    }
}

#Preview {
    HostsFileEntryEditor(
        entry: HostsFileEntry(enabled: true, ipAddress: "192.168.0.42", host: "example.com", comment: "This is a test entry"),
        onSave: { _ in
            print("Save")
        },
        onCancel: { _ in
            print("Cancel")
        },
        onDelete: { _ in
            print("Delete")
        })
}
