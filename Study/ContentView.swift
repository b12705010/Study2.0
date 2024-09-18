//
//  ContentView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//
//
//  ContentView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//
import SwiftUI

// ContentView 是應用的主要介面，包含了學習計時器、Insights 以及科目管理功能
struct ContentView: View {
    @StateObject var subjectViewModel = SubjectViewModel() // 管理科目資料的 ViewModel
    @StateObject var sessionViewModel = StudySessionViewModel() // 管理學習會話資料的 ViewModel

    @State private var selectedSubject: Subject? // 保存使用者選擇的科目
    @State private var selectedTab = "Timer" // 保存使用者選擇的頁籤名稱，初始為 "Timer"
    @State private var startTime = Date() // 計時器開始的時間
    @State private var isTimerRunning = false // 計時器是否正在運行的狀態
    @State private var timer: Timer? // 用於控制和追蹤計時器
    @State private var midnightChecker: Timer? // 用於檢查午夜的定時器
    @State private var elapsedTime: String = "00:00:00" // 顯示當天的累計學習時間
    @State private var subjectElapsedTime: String = "00:00:00" // 顯示當前科目的累計學習時間
    @State private var totalAccumulatedTime: TimeInterval = 0 // 當天累計的總學習時間（以秒為單位）
    @State private var subjectAccumulatedTime: TimeInterval = 0 // 當前科目累計的學習時間（以秒為單位）

    let tabs = ["Timer", "Insights", "Subjects"] // 定義頁籤名稱的陣列

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab)
                        .font(.custom("Times New Roman", size: 18))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300)
            .padding(.horizontal, 20)

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

            // 載入當天的累計學習時間
            loadTodayAccumulatedTime()

            // 如果有選擇的科目，則載入該科目的累計學習時間
            if let selectedSubject = selectedSubject {
                subjectAccumulatedTime = selectedSubject.accumulatedTime
                subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime)
            }

            // 設置午夜檢查器，每分鐘檢查一次時間，看看是否已到午夜
            midnightChecker = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                checkForMidnightReset()
            }
        }
        .onDisappear {
            // 當畫面消失時，停止午夜檢查器
            midnightChecker?.invalidate()
        }
    }

    var timerView: some View {
        VStack {
            HStack {
                Spacer()
                Picker("", selection: $selectedSubject) {
                    ForEach(subjectViewModel.subjects, id: \.self) { subject in
                        Text(subject.name ?? "New Subject").tag(subject as Subject?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)
                .onChange(of: selectedSubject) { newSubject in
                    if let subject = newSubject {
                        subjectAccumulatedTime = subject.accumulatedTime
                        subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime)
                    } else {
                        subjectAccumulatedTime = 0
                        subjectElapsedTime = "00:00:00"
                    }
                }
            }
            .padding([.top, .trailing], 10)

            Spacer()

            HStack {
                VStack {
                    Text("Total")
                        .font(.custom("Times New Roman", size: 16))
                    Text(elapsedTime)
                        .font(.custom("Times New Roman", size: 48))
                        .padding(.bottom, -5)
                }
                .padding(.horizontal, 15)

                VStack {
                    Text(selectedSubject?.name ?? "General")
                        .font(.custom("Times New Roman", size: 16))
                    Text(subjectElapsedTime)
                        .font(.custom("Times New Roman", size: 48))
                        .padding(.bottom, -5)
                }
                .padding(.horizontal, 15)
            }
            .padding(.top, -20)

            Spacer()

            Text(isTimerRunning ? "stop" : "start")
                .font(.custom("Times New Roman", size: 18))
                .frame(width: 70, height: 24)
                .foregroundColor(.white)
                .background(isTimerRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                .cornerRadius(8)
                .onTapGesture {
                    startOrStopTimer()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isTimerRunning ? Color.red : Color.green, lineWidth: 1)
                )
                .padding(.bottom, 20)

            Spacer()
        }
    }

    var insightsView: some View {
        Text("Insights View")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }

    var subjectsView: some View {
        ZStack {
            List {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    HStack {
                        TextField("subject", text: Binding(
                            get: { subject.name ?? "" },
                            set: { newValue in
                                subject.name = newValue
                                subjectViewModel.saveContext()
                            }
                        ))
                        .textFieldStyle(PlainTextFieldStyle())
                        .background(Color.clear)

                        Spacer()

                        Text(formatTimeInterval(subject.accumulatedTime))
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            subjectViewModel.deleteSubject(subject: subject)
                        } label: {
                            Label("delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .padding(.horizontal, -10)
            .padding(.top, 15)
            .padding(.bottom, -10)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("+")
                        .font(.custom("Times New Roman", size: 24))
                        .onTapGesture {
                            subjectViewModel.addSubject(name: "new subject")
                        }
                        .padding(.bottom, 15)
                        .padding(.trailing, 20)
                }
            }
        }
    }

    func loadTodayAccumulatedTime() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date

        if let lastDate = lastSavedDate, Calendar.current.isDateInToday(lastDate) {
            totalAccumulatedTime = UserDefaults.standard.double(forKey: "todayAccumulatedTime")
        } else {
            totalAccumulatedTime = 0
            UserDefaults.standard.set(today, forKey: "lastSavedDate")
        }

        elapsedTime = formatTimeInterval(totalAccumulatedTime)
    }

    func saveTodayAccumulatedTime() {
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(totalAccumulatedTime, forKey: "todayAccumulatedTime")
        UserDefaults.standard.set(today, forKey: "lastSavedDate")
    }

    func startOrStopTimer() {
        if isTimerRunning {
            timer?.invalidate()
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(startTime)

            totalAccumulatedTime += timeInterval
            subjectAccumulatedTime += timeInterval

            if let selectedSubject = selectedSubject {
                selectedSubject.accumulatedTime += timeInterval
                subjectViewModel.saveContext()
            }

            saveTodayAccumulatedTime()
            sessionViewModel.addStudySession(
                subjectName: selectedSubject?.name ?? "未知科目",
                descriptionText: "",
                startTime: startTime,
                endTime: currentTime
            )

            isTimerRunning = false
        } else {
            startTime = Date()
            isTimerRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateElapsedTime()
            }
        }
    }

    func updateElapsedTime() {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(startTime)

        let totalTodayTime = totalAccumulatedTime + timeInterval
        elapsedTime = formatTimeInterval(totalTodayTime)

        let subjectTime = subjectAccumulatedTime + timeInterval
        subjectElapsedTime = formatTimeInterval(subjectTime)
    }

    // 每分鐘檢查是否到達午夜，若到達則重置時間
    func checkForMidnightReset() {
        let calendar = Calendar.current
        let now = Date()
        let targetTimeComponents = calendar.dateComponents([.hour, .minute], from: now)
        
        // 檢查是否為午夜
        if targetTimeComponents.hour == 0 && targetTimeComponents.minute == 0 {
            let today = Date() // 獲取當前日期
            
            // 使用 Core Data 保存當天的學習時間
            let context = PersistenceController.shared.container.viewContext // 獲取 Core Data 上下文
            let newRecord = DailyStudyRecord(context: context) // 創建一個新的 DailyStudyRecord 實體
            
            newRecord.date = today
            newRecord.totalTime = totalAccumulatedTime
            
            do {
                try context.save() // 保存資料到 Core Data
            } catch {
                print("儲存失敗: \(error)")
            }

            // 重置當天的總學習時間
            totalAccumulatedTime = 0
            elapsedTime = "00:00:00"
            
            // 重置所有科目的累計學習時間
            for subject in subjectViewModel.subjects {
                subject.accumulatedTime = 0
            }
            subjectViewModel.saveContext()

            // 重置當前選中的科目累計學習時間顯示
            subjectAccumulatedTime = 0
            subjectElapsedTime = "00:00:00"
        }
    }
   
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
