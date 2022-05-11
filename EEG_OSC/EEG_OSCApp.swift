//
//  EEG_OSCApp.swift
//  EEG_OSC
//
//  Created by Allan Frederick on 5/10/22.
//

import SwiftUI

@main
struct EEG_OSCApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
