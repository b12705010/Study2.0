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

// 創建視覺效果模糊背景的結構
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow  // 可以修改這個參數來改變效果類型
        view.blendingMode = .withinWindow // 設置模糊效果的混合模式
        view.state = .active // 啟用模糊效果
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        // 不需要在這裡更新
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject var subjectViewModel = SubjectViewModel() // 科目資料的ViewModel
    @StateObject var sessionViewModel = StudySessionViewModel() // 學習會話的ViewModel

    @State private var selectedSubject: Subject? // 儲存選擇的科目
    @State private var selectedTab = "Timer" // 選擇的頁籤
    @State private var startTime = Date() // 計時開始時間
    @State private var isTimerRunning = false // 是否計時中
    @State private var timer: Timer? // 用來追蹤計時器
    @State private var elapsedTime: String = "00:00:00" // 當天的累計時間顯示
    @State private var subjectElapsedTime: String = "00:00:00" // 當前科目的累計時間顯示
    @State private var totalAccumulatedTime: TimeInterval = 0 // 當天總學習時間
    @State private var subjectAccumulatedTime: TimeInterval = 0 // 當前科目的累計學習時間

    let tabs = ["Timer", "Insights", "Subjects"] // 定義可選頁籤

    var body: some View {
        VStack {
            // 橫向頁籤選擇器
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab) // 顯示每個頁籤的名稱
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // 使用分段選擇樣式
            .padding()

            // 根據選擇的頁籤顯示不同內容
            if selectedTab == "Timer" {
                timerView // 計時器頁面
            } else if selectedTab == "Insights" {
                insightsView // Insights頁面
            } else if selectedTab == "Subjects" {
                subjectsView // 科目管理頁面
            }
        }
        .padding()
        .onAppear {
            subjectViewModel.loadSubjects() // 頁面加載時，載入科目
            sessionViewModel.loadStudySessions() // 頁面加載時，載入學習會話

            // 如果有選中的科目，從 Core Data 中載入累計時間
            if let selectedSubject = selectedSubject {
                totalAccumulatedTime = selectedSubject.accumulatedTime // 載入總學習時間
                subjectAccumulatedTime = selectedSubject.accumulatedTime // 載入該科目的累計學習時間
            }
        }
    }

    // 計時器頁面內容
    var timerView: some View {
        VStack {
            HStack {
                Spacer()
                // 選擇科目
                Picker("選擇科目", selection: $selectedSubject) {
                    ForEach(subjectViewModel.subjects, id: \.self) { subject in
                        Text(subject.name ?? "未命名").tag(subject as Subject?)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // 使用選單樣式
                .frame(width: 200)
                Spacer()
            }
            .padding()

            // 顯示今日累計時間和當前科目累計時間
            HStack {
                VStack {
                    Text("今日累計時間")
                    Text(elapsedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced)) // 使用等寬字體顯示時間
                        .padding()
                }
                
                VStack {
                    Text("科目累計時間")
                    Text(subjectElapsedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .padding()
                }
            }

            // 開始或停止按鈕
            Button(action: startOrStopTimer) {
                Text(isTimerRunning ? "停止" : "開始") // 根據狀態切換按鈕文字
                    .font(.title)
                    .frame(width: 120, height: 40)
                    .background(isTimerRunning ? Color.red : Color.green) // 根據狀態切換按鈕顏色
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            }
            .padding()

            Spacer()
        }
    }

    // Insights頁面內容
    var insightsView: some View {
        Text("Insights View")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }

    // 科目管理頁面內容
    var subjectsView: some View {
        ZStack {
            List {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    HStack {
                        // 科目名稱編輯
                        TextField("科目名稱", text: Binding(
                            get: { subject.name ?? "" },
                            set: { newValue in
                                subject.name = newValue
                                subjectViewModel.saveContext() // 科目名稱修改後儲存
                            }
                        ))
                        .textFieldStyle(PlainTextFieldStyle())
                        
                        Spacer()

                        Text("00:00:00") // 顯示學習時間（目前為靜態）
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        // 刪除科目
                        Button(role: .destructive) {
                            subjectViewModel.deleteSubject(subject: subject)
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
                }
            }

            // 右下角的加號按鈕，新增科目
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        subjectViewModel.addSubject(name: "新科目") // 點擊後新增新科目
                    }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle()) // 使用圓形按鈕
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }

    // 計時器開始或停止功能
    func startOrStopTimer() {
        if isTimerRunning {
            // 停止計時並累積時間
            timer?.invalidate() // 停止計時器
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(startTime)
            
            totalAccumulatedTime += timeInterval // 累積當天總時間
            subjectAccumulatedTime += timeInterval // 累積科目學習時間

            // 更新當前選中科目的累計時間
            if let selectedSubject = selectedSubject {
                selectedSubject.accumulatedTime += subjectAccumulatedTime
                subjectViewModel.saveContext() // 保存至 Core Data
            }
            
            // 儲存學習紀錄
            sessionViewModel.addStudySession(
                subjectName: selectedSubject?.name ?? "未知科目",
                descriptionText: "",  // 可以根據需求新增描述
                startTime: startTime,
                endTime: currentTime
            )
            
            isTimerRunning = false
        } else {
            // 開始計時
            startTime = Date() // 設定開始時間
            isTimerRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateElapsedTime() // 每秒更新顯示時間
            }
        }
    }

    // 更新時間顯示功能
    func updateElapsedTime() {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(startTime)
        
        // 更新今日累計時間
        let totalTodayTime = totalAccumulatedTime + timeInterval
        elapsedTime = formatTimeInterval(totalTodayTime)
        
        // 更新當前科目累計時間
        let subjectTime = subjectAccumulatedTime + timeInterval
        subjectElapsedTime = formatTimeInterval(subjectTime)
        
        // 每次更新時，同步更新科目累計時間
        if let selectedSubject = selectedSubject {
            selectedSubject.accumulatedTime += timeInterval
            subjectViewModel.saveContext() // 將變更保存到 Core Data
        }
    }

    // 格式化時間顯示 (時:分:秒)
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds) // 格式化顯示
    }
}
