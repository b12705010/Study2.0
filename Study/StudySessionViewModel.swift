//
//  StudySessionViewModel.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData
import SwiftUI

class StudySessionViewModel: ObservableObject {
    @Published var studySessions: [StudySession] = []
    private let context = PersistenceController.shared.container.viewContext
    
    // 記錄當天總學習時間
    func getTodayStudyTime() -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let todaySessions = studySessions.filter { session in
            guard let startTime = session.startTime else { return false }
            return startTime >= startOfDay
        }
        
        let totalTime = todaySessions.reduce(0) { total, session in
            guard let startTime = session.startTime, let endTime = session.endTime else { return total }
            return total + endTime.timeIntervalSince(startTime)
        }
        
        return totalTime
    }
    
    func addStudySession(subjectName: String, descriptionText: String, startTime: Date, endTime: Date) {
        let newSession = StudySession(context: context)
        newSession.subjectName = subjectName
        newSession.descriptionText = descriptionText
        newSession.startTime = startTime
        newSession.endTime = endTime
        saveContext()
    }
    
    func loadStudySessions() {
        let fetchRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        do {
            studySessions = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch study sessions: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
