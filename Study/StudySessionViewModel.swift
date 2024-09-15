//
//  StudySessionViewModel.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData
import SwiftUI

// StudySessionViewModel 負責管理學習會話的邏輯
class StudySessionViewModel: ObservableObject {
    @Published var studySessions: [StudySession] = [] // 儲存所有學習會話，當變動時自動更新 UI
    private let context = PersistenceController.shared.container.viewContext // 取得 Core Data 的上下文
    
    // 計算當天總學習時間
    func getTodayStudyTime() -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date()) // 取得當天的開始時間（00:00）
        
        // 過濾出當天的學習會話
        let todaySessions = studySessions.filter { session in
            guard let startTime = session.startTime else { return false } // 檢查開始時間是否為 nil
            return startTime >= startOfDay // 如果學習開始時間是今天的，則返回 true
        }
        
        // 計算當天所有學習會話的總時間
        let totalTime = todaySessions.reduce(0) { total, session in
            guard let startTime = session.startTime, let endTime = session.endTime else { return total }
            return total + endTime.timeIntervalSince(startTime) // 累計每個會話的時間長度
        }
        
        return totalTime // 返回當天總學習時間
    }
    
    // 新增學習會話
    func addStudySession(subjectName: String, descriptionText: String, startTime: Date, endTime: Date) {
        let newSession = StudySession(context: context) // 創建一個新的 StudySession 物件
        newSession.subjectName = subjectName // 設定科目名稱
        newSession.descriptionText = descriptionText // 設定描述文字
        newSession.startTime = startTime // 設定開始時間
        newSession.endTime = endTime // 設定結束時間
        saveContext() // 儲存變更至 Core Data
    }
    
    // 載入所有學習會話
    func loadStudySessions() {
        let fetchRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest() // 創建一個取回請求
        do {
            studySessions = try context.fetch(fetchRequest) // 從 Core Data 中取回學習會話
        } catch {
            print("Failed to fetch study sessions: \(error)") // 如果取回失敗，打印錯誤信息
        }
    }
    
    // 儲存上下文中的變更
    func saveContext() {
        do {
            try context.save() // 儲存上下文中的變更到 Core Data
        } catch {
            print("Failed to save context: \(error)") // 如果儲存失敗，打印錯誤信息
        }
    }
}
