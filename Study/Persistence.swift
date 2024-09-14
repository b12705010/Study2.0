//
//  Persistence.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 創建 10 個測試 StudySession
        for _ in 0..<10 {
            let newSession = StudySession(context: viewContext)
            newSession.subjectName = "測試科目"
            newSession.startTime = Date()
            newSession.endTime = Date()
            newSession.descriptionText = "測試描述"
        }
        
        do {
            try viewContext.save()
        } catch {
            // 替換此實作以處理錯誤
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Study")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // 替換此實作以處理錯誤
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
