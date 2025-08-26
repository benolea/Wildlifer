//
//  WildliferApp.swift
//  WildliferApp
//
//  Created by Benjamin Olea on 8/14/25.
//

import SwiftUI

@main
struct FinAiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
