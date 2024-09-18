//
//  StudyApp.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import SwiftUI

@main
struct StudyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

