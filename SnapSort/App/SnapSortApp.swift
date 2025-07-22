//
//  SnapSortApp.swift
//  SnapSort
//
//  Created by Jie Lu on 22.6.2025.
//

import SwiftUI
import SwiftData

@main
struct SnapSortApp: App {
    //database container of SwiftData
    /* var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }() */
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Theme.self, ClassifiedScreenShot.self])
    }
}
