//
//  HostsApp.swift
//  Hosts
//
//  Created by Jack Miller on 1/31/24.
//

import SwiftUI

@main
struct HostsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Disable tabbing on the window
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            // Remove the "File > New" menu item
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }
    }
}
