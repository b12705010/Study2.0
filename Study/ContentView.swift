//
//  ContentView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//
import SwiftUI

struct ContentView: View {
    @StateObject var subjectViewModel = SubjectViewModel()
    @StateObject var sessionViewModel = StudySessionViewModel()

    @State private var selectedSubject: Subject?
    @State private var descriptionText = ""
    @State private var startTime = Date()
    @State private var isTimerRunning = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text("讀書計時器")
                .font(.largeTitle)
                .padding()

            Picker("選擇科目", selection: $selectedSubject) {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    Text(subject.name ?? "未命名").tag(subject as Subject?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            TextField("簡述", text: $descriptionText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: startOrStopTimer) {
                Text(isTimerRunning ? "停止" : "開始")
                    .font(.title)
                    .frame(minWidth: 200)
                    .padding()
                    .background(isTimerRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            subjectViewModel.loadSubjects()
            sessionViewModel.loadStudySessions()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                NavigationLink("科目管理", destination: SubjectManagementView())
            }
        }
    }

    // 開始或停止計時
    func startOrStopTimer() {
        if isTimerRunning {
            // 停止計時並保存紀錄
            timer?.invalidate()
            sessionViewModel.addStudySession(
                subjectName: selectedSubject?.name ?? "未知科目",
                descriptionText: descriptionText,
                startTime: startTime,
                endTime: Date()
            )
            isTimerRunning = false
        } else {
            // 開始計時
            startTime = Date()
            isTimerRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                // 每秒更新，如果有需要可以更新計時顯示
            }
        }
    }
}
