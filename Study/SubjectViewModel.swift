//
//  SubjectViewModel.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData
import SwiftUI

// SubjectViewModel 負責管理科目資料
class SubjectViewModel: ObservableObject {
    @Published var subjects: [Subject] = [] // 儲存所有科目，當資料變動時自動更新 UI
    private let context = PersistenceController.shared.container.viewContext // Core Data 上下文，用來進行資料操作
    
    // 新增科目
    func addSubject(name: String) {
        let newSubject = Subject(context: context) // 創建新的科目物件，並指定其上下文
        newSubject.name = name // 設定科目的名稱
        newSubject.accumulatedTime = 0 // 初始化累積時間為 0
        saveContext() // 儲存上下文中的變更
        loadSubjects() // 新增後重新載入科目列表，保證顯示更新
    }
    
    // 更新科目累積時間
    func updateAccumulatedTime(for subject: Subject, additionalTime: TimeInterval) {
        subject.accumulatedTime += additionalTime // 累加新的學習時間
        saveContext() // 儲存變更
    }
    
    // 刪除科目
    func deleteSubject(subject: Subject) {
        context.delete(subject) // 刪除指定的科目
        saveContext() // 儲存上下文中的變更
        loadSubjects() // 刪除後重新載入科目列表
    }
    
    // 載入所有科目
    func loadSubjects() {
        let fetchRequest: NSFetchRequest<Subject> = Subject.fetchRequest() // 創建取回請求，指定要取回 Subject 物件
        do {
            subjects = try context.fetch(fetchRequest) // 從 Core Data 中取回科目
        } catch {
            print("Failed to fetch subjects: \(error)") // 如果取回失敗，打印錯誤訊息
        }
    }
    
    // 儲存上下文中的變更
    func saveContext() {
        do {
            try context.save() // 將上下文中的變更儲存到 Core Data
        } catch {
            print("Failed to save context: \(error)") // 如果儲存失敗，打印錯誤訊息
        }
    }
}
