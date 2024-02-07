//
//  HostsFileView.swift
//  Hosts
//
//  Created by Jack Miller on 2/2/24.
//

import SwiftUI

struct HostsFileView: View {
    @ObservedObject var hostsFile: HostsFile

    @State private var selectedEntryId: UUID?

    // Error dialog state
    @State private var errorMessage: String?
    @State private var showErrorAlert: Bool = false

    // Permissions Dialog State
    @State private var showPermissionDeniedAlert: Bool = false

    // Existing entry edit sheet state
    @State private var editEntryId: UUID?
    @State private var showEditEntrySheet: Bool = false

    // New entry edit sheet state
    @State private var showNewEntryEditor: Bool = false
    @State private var newEntry: HostsFileEntry = HostsFileEntry()

    var body: some View {
        VStack(alignment: .leading) {
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            List(hostsFile.getEntries(), selection: $selectedEntryId) { entry in
                HostsFileEntryView(
                    entry: entry,
                    onToggle: { _ in
                        saveHostsFile()
                    },
                    onEdit: { editEntry in
                        selectedEntryId = editEntry.id
                        showEditEntrySheet = true
                    },
                    onDuplicate: { duplicateEntry in
                        let newEntry = duplicateEntry.clone()
                        newEntry.enabled = false
                        self.hostsFile.addEntry(entry: newEntry)
                    },
                    onDelete: { deleteEntry in
                        removeEntry(id: deleteEntry.id)
                    })
            }
            .onChange(of: selectedEntryId) { newSelectedEntryId in
                if let newSelectedEntryId = newSelectedEntryId {
                    editEntryId = newSelectedEntryId
                    // Clear the edit entry immediately. The edit sheet will appear on selection
                    selectedEntryId = nil
                }
            }
        }
        .toolbar {
            Button(
                action: {
                    self.reloadHostsFile()
                },
                label: {
                    Image(systemName: "arrow.clockwise")
                })
            Button(
                action: {
                    newEntry = HostsFileEntry()
                    self.showNewEntryEditor = true
                },
                label: {
                    Image(systemName: "plus")
                })
        }
        .onChange(of: editEntryId) { newEditEntryId in
            showEditEntrySheet = editEntryId != nil
        }
        .sheet(
            isPresented: $showEditEntrySheet,
            onDismiss: {
                editEntryId = nil
            },
            content: {
                let selectedEntry = hostsFile.getEntry(id: editEntryId!)
                if let selectedEntry = selectedEntry {
                    HostsFileEntryEditor(
                        entry: selectedEntry,
                        onSave: { _ in
                            saveHostsFile()
                            showEditEntrySheet = false
                        },
                        onCancel: { entry in
                            showEditEntrySheet = false
                        },
                        onDelete: { entry in
                            removeEntry(id: entry.id)
                            showEditEntrySheet = false
                        })
                    .padding()
                }
            }
        )
        .sheet(
            isPresented: $showNewEntryEditor,
            onDismiss: {
                self.showNewEntryEditor = false
            },
            content: {
                HostsFileEntryEditor(
                    entry: newEntry,
                    onSave: { entry in
                        self.hostsFile.addEntry(entry: entry)
                        saveHostsFile()
                    },
                    onCancel: { _ in })
            }
        )
        .alert(isPresented: $showErrorAlert) {
            return Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "(nil)"),
                dismissButton: Alert.Button.cancel({
                    DispatchQueue.main.async {
                        showErrorAlert = false
                        errorMessage = nil
                    }
                }));
        }
        .alert(isPresented: $showPermissionDeniedAlert) {
            let command = "sudo /bin/chmod +a 'user:\(NSUserName()):allow write' \(self.hostsFile.filePath)"
            return Alert(
                title: Text("Permission Denied"),
                message: Text("Run the following command to add write permissions to the file \n\n\(command)"),
                primaryButton: Alert.Button.default(Text("Retry"), action: {
                    saveHostsFile()
                }),
                secondaryButton: Alert.Button.cancel({
                    reloadHostsFile()
                }))
        }
    }

    private func reloadHostsFile() {
        self.tryHostsFileAction {
            try self.hostsFile.reload()
        }
    }

    private func saveHostsFile() {
        self.tryHostsFileAction {
            try self.hostsFile.save()
        }
    }

    private func removeEntry(id: UUID) {
        self.hostsFile.removeEntry(id: id)
        self.saveHostsFile()
    }

    private func tryHostsFileAction(action: @escaping () throws -> Void) {
        DispatchQueue.main.async {
            self.showPermissionDeniedAlert = false
            self.showErrorAlert = false
            self.errorMessage = nil

            do {
                try action()
            }
            catch let error as NSError {
                // TODO: Move code to a const
                if error.domain == NSCocoaErrorDomain && error.code == 513 {
                    self.showPermissionDeniedAlert = true
                }
                else {
                    self.setError(error: error)
                }
            }
            catch {
                self.setError(error: error)
            }
        }
    }

    private func setError(error: Error) {
        self.errorMessage = error.localizedDescription
        self.showErrorAlert = true
    }
}
