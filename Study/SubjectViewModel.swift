//
//  SubjectViewModel.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import CoreData
import SwiftUI

class SubjectViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    private let context = PersistenceController.shared.container.viewContext
    
    func addSubject(name: String) {
        let newSubject = Subject(context: context)
        newSubject.name = name
        saveContext()
        loadSubjects() // 新增後重新加載，保證列表會更新
    }
    
    func deleteSubject(subject: Subject) {
        context.delete(subject)
        saveContext()
        loadSubjects() // 刪除後重新加載
    }
    
    func loadSubjects() {
        let fetchRequest: NSFetchRequest<Subject> = Subject.fetchRequest()
        do {
            subjects = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch subjects: \(error)")
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
