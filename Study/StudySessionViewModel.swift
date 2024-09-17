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
    // @Published 修飾的 studySessions 用於儲存所有學習會話，並自動更新 UI
    @Published var studySessions: [StudySession] = []
    // 透過 PersistenceController 取得 Core Data 的上下文
    private let context = PersistenceController.shared.container.viewContext
    
    // 計算當天的總學習時間，返回值為 TimeInterval (以秒為單位)
    func getTodayStudyTime() -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date()) // 取得當天的 00:00
        
        // 過濾出今天的學習會話，會話開始時間需在今天 00:00 之後
        let todaySessions = studySessions.filter { session in
            guard let startTime = session.startTime else { return false } // 確保會話有開始時間
            return startTime >= startOfDay // 檢查會話是否發生於今天
        }
        
        // 使用 reduce 函數計算當天所有會話的總學習時間
        let totalTime = todaySessions.reduce(0) { total, session in
            // 確保會話有開始和結束時間，並計算該會話的時間長度
            guard let startTime = session.startTime, let endTime = session.endTime else { return total }
            return total + endTime.timeIntervalSince(startTime) // 累加每個會話的時間
        }
        
        return totalTime // 返回當天的總學習時間
    }
    
    // 新增學習會話，參數包括科目名稱、描述、開始時間與結束時間
    func addStudySession(subjectName: String, descriptionText: String, startTime: Date, endTime: Date) {
        let newSession = StudySession(context: context) // 創建一個新的 StudySession 實例
        newSession.subjectName = subjectName // 設置科目名稱
        newSession.descriptionText = descriptionText // 設置描述文字
        newSession.startTime = startTime // 設置學習會話的開始時間
        newSession.endTime = endTime // 設置學習會話的結束時間
        saveContext() // 將新會話保存至 Core Data
    }
    
    // 載入所有學習會話，從 Core Data 中取回資料
    func loadStudySessions() {
        let fetchRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest() // 創建取回請求
        do {
            studySessions = try context.fetch(fetchRequest) // 執行取回請求，取得學習會話資料
        } catch {
            print("Failed to fetch study sessions: \(error)") // 如果取回失敗，輸出錯誤信息
        }
    }
    
    // 保存上下文中的變更
    func saveContext() {
        do {
            try context.save() // 嘗試保存上下文中的變更至 Core Data
        } catch {
            print("Failed to save context: \(error)") // 如果保存失敗，輸出錯誤信息
        }
    }
}
