//
//  WildliferApp.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/26/25.
//

import SwiftUI

@main
struct WildliferApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
