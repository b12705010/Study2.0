//
//  Persistence.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData

// PersistenceController 用來管理 Core Data 的持久化控制
struct PersistenceController {
    // 單例模式，讓其他地方可以通過 shared 訪問 PersistenceController
    static let shared = PersistenceController()

    // @MainActor 保證這個屬性會在主線程上運行，方便在預覽模式下使用
    @MainActor
    static let preview: PersistenceController = {
        // 創建一個內存中的 PersistenceController，僅用於測試或預覽
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 創建 10 個測試用的 StudySession 物件，模擬學習會話資料
        for _ in 0..<10 {
            let newSession = StudySession(context: viewContext)
            newSession.subjectName = "測試科目" // 設置科目名稱
            newSession.startTime = Date() // 設置開始時間為當前時間
            newSession.endTime = Date() // 設置結束時間為當前時間
            newSession.descriptionText = "測試描述" // 設置描述文字
        }
        
        // 嘗試將測試資料保存到 Core Data 中（僅在內存中，不會實際儲存到磁碟）
        do {
            try viewContext.save() // 保存資料
        } catch {
            // 處理保存時發生的錯誤，這裡使用 fatalError 來中止程序並顯示錯誤訊息
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result // 返回已配置的 PersistenceController 結果
    }()

    // NSPersistentContainer 是 Core Data 的容器，負責管理儲存和取出資料
    let container: NSPersistentContainer

    // 初始化 PersistenceController，根據參數決定是否僅儲存於內存中
    init(inMemory: Bool = false) {
        // 創建 NSPersistentContainer，並指定數據模型的名稱 "Study"
        container = NSPersistentContainer(name: "Study")
        
        // 如果使用內存儲存模式，將儲存位置設置為 /dev/null，這樣資料不會真正寫入到磁碟
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // 加載持久化儲存，這個過程可能會發生錯誤
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // 發生錯誤時，使用 fatalError 終止程序並顯示詳細錯誤訊息
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
