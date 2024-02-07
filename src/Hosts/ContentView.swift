//
//  ContentView.swift
//  Hosts
//
//  Created by Jack Miller on 1/31/24.
//

import SwiftUI

struct WindowSizeConstants {
    static let minWindowWidth: CGFloat = 440
    static let minWindowHeight: CGFloat = 300
    static let minEditorWidth: CGFloat = minWindowWidth * 0.8
}

struct ContentView: View {
    private let hostsFilePath = "/private/etc/hosts"

    @State private var hostsFile: HostsFile?
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
                    .monospaced()
            }
            else if let hostsFile = self.hostsFile {
                HostsFileView(hostsFile: hostsFile)
            }
            else {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }
        }
        .padding()
        .frame(
            minWidth: WindowSizeConstants.minWindowWidth,
            minHeight: WindowSizeConstants.minWindowHeight)
        .onAppear(perform: {
            self.openHostsFile()
        })
    }

    private func openHostsFile() {
        do {
            self.hostsFile = try HostsFile(filePath: hostsFilePath)
        }
        catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
