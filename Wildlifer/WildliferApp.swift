//
//  WildliferApp.swift
//  WildliferApp
//
//  Created by Benjamin Olea on 8/14/25
//

import SwiftUI
import GoogleMaps

@main
struct WildliferApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        GMSServices.provideAPIKey(googleK)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
