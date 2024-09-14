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
