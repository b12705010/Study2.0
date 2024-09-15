//
//  ContentView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//
import SwiftUI

struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow  // 可以修改這個參數來改變效果
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        // 不需要進行更新
    }
}



import SwiftUI

struct ContentView: View {
    @StateObject var subjectViewModel = SubjectViewModel()
    @StateObject var sessionViewModel = StudySessionViewModel()

    @State private var selectedSubject: Subject?
    @State private var selectedTab = "Timer"
    @State private var startTime = Date()
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var elapsedTime: String = "00:00:00"
    @State private var subjectElapsedTime: String = "00:00:00"
    @State private var totalAccumulatedTime: TimeInterval = 0 // 用來追蹤當天總學習時間
    @State private var subjectAccumulatedTime: TimeInterval = 0 // 用來追蹤當前科目累計時間

    let tabs = ["Timer", "Insights", "Subjects"]

    var body: some View {
        VStack {
            // 上方橫向欄位
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // 根據選擇的頁面顯示不同內容
            if selectedTab == "Timer" {
                timerView
            } else if selectedTab == "Insights" {
                insightsView
            } else if selectedTab == "Subjects" {
                subjectsView
            }
        }
        .padding()
        .onAppear {
            subjectViewModel.loadSubjects()
            sessionViewModel.loadStudySessions()
        }
    }

    // Timer 的內容
    var timerView: some View {
        VStack {
            HStack {
                Spacer()
                Picker("選擇科目", selection: $selectedSubject) {
                    ForEach(subjectViewModel.subjects, id: \.self) { subject in
                        Text(subject.name ?? "未命名").tag(subject as Subject?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)
                Spacer()
            }
            .padding()

            // 顯示兩個碼錶：左側為一天的累計，右側為當前科目的累計
            HStack {
                VStack {
                    Text("今日累計時間")
                    Text(elapsedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .padding()
                }
                
                VStack {
                    Text("科目累計時間")
                    Text(subjectElapsedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .padding()
                }
            }

            Button(action: startOrStopTimer) {
                Text(isTimerRunning ? "停止" : "開始")
                    .font(.title)
                    .frame(width: 120, height: 40)
                    .background(isTimerRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            }
            .padding()

            Spacer()
        }
    }

    // Insights 頁面的內容
    var insightsView: some View {
        Text("Insights View")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }

    // Subjects 頁面的內容
    var subjectsView: some View {
        ZStack {
            List {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    HStack {
                        TextField("科目名稱", text: Binding(
                            get: { subject.name ?? "" },
                            set: { newValue in
                                subject.name = newValue
                                subjectViewModel.saveContext()
                            }
                        ))
                        .textFieldStyle(PlainTextFieldStyle())
                        
                        Spacer()

                        Text("00:00:00")
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            subjectViewModel.deleteSubject(subject: subject)
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
                }
            }

            // 右下角「+」號按鈕
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        subjectViewModel.addSubject(name: "新科目")
                    }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }

    // 計時器控制功能
    func startOrStopTimer() {
        if isTimerRunning {
            // 停止計時並累積時間
            timer?.invalidate()
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(startTime)
            
            totalAccumulatedTime += timeInterval
            subjectAccumulatedTime += timeInterval
            
            // 儲存學習紀錄
            sessionViewModel.addStudySession(
                subjectName: selectedSubject?.name ?? "未知科目",
                descriptionText: "",  // 可以根據需要進一步修改
                startTime: startTime,
                endTime: currentTime
            )
            
            isTimerRunning = false
        } else {
            // 開始計時
            startTime = Date()
            isTimerRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateElapsedTime()
            }
        }
    }

    // 更新計時效果
    func updateElapsedTime() {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(startTime)
        
        // 更新今日累計時間
        let totalTodayTime = totalAccumulatedTime + timeInterval
        elapsedTime = formatTimeInterval(totalTodayTime)
        
        // 更新當前科目的累計時間
        let subjectTime = subjectAccumulatedTime + timeInterval
        subjectElapsedTime = formatTimeInterval(subjectTime)
    }

    // 格式化時間顯示
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
