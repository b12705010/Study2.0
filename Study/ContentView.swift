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
    // 使用 @StateObject 創建兩個 ViewModel 來管理科目和學習會話的資料
    @StateObject var subjectViewModel = SubjectViewModel() // 管理科目資料的 ViewModel
    @StateObject var sessionViewModel = StudySessionViewModel() // 管理學習會話資料的 ViewModel

    @State private var selectedSubject: Subject? // 保存使用者選擇的科目
    @State private var selectedTab = "Timer" // 保存使用者選擇的頁籤名稱，初始為 "Timer"
    @State private var startTime = Date() // 計時器開始的時間
    @State private var isTimerRunning = false // 計時器是否正在運行的狀態
    @State private var timer: Timer? // 用於控制和追蹤計時器
    @State private var elapsedTime: String = "00:00:00" // 顯示當天的累計學習時間
    @State private var subjectElapsedTime: String = "00:00:00" // 顯示當前科目的累計學習時間
    @State private var totalAccumulatedTime: TimeInterval = 0 // 當天累計的總學習時間（以秒為單位）
    @State private var subjectAccumulatedTime: TimeInterval = 0 // 當前科目累計的學習時間（以秒為單位）

    let tabs = ["Timer", "Insights", "Subjects"] // 定義頁籤名稱的陣列

    var body: some View {
        VStack {
            // 橫向頁籤選擇器，用於切換不同的功能頁面
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab) // 顯示每個頁籤名稱
                        .font(.custom("Times New Roman", size: 18)) // 使用 Times New Roman 字體顯示
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // 使用分段樣式的選擇器
            .frame(width: 300) // 設定選擇器的寬度
            .padding(.horizontal, 20) // 設定水平內間距

            // 根據選擇的頁籤顯示對應的內容
            if selectedTab == "Timer" {
                timerView // 顯示計時器頁面
            } else if selectedTab == "Insights" {
                insightsView // 顯示 Insights 頁面
            } else if selectedTab == "Subjects" {
                subjectsView // 顯示科目管理頁面
            }
        }
        .padding()
        .onAppear {
            // 當頁面出現時，載入科目和學習會話資料
            subjectViewModel.loadSubjects() // 載入科目資料
            sessionViewModel.loadStudySessions() // 載入學習會話資料

            // 載入當天的累計學習時間
            loadTodayAccumulatedTime()

            // 如果有選擇的科目，則載入該科目的累計學習時間
            if let selectedSubject = selectedSubject {
                subjectAccumulatedTime = selectedSubject.accumulatedTime // 取得科目累計時間
                subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime) // 格式化時間顯示
            }
        }
    }

    // 計時器頁面的內容
    var timerView: some View {
        VStack {
            HStack {
                Spacer() // 將科目選擇器推到右側
                // Picker 用於選擇學習科目
                Picker("", selection: $selectedSubject) {
                    ForEach(subjectViewModel.subjects, id: \.self) { subject in
                        // 如果科目名稱為 nil，則顯示 "New Subject"
                        Text(subject.name ?? "New Subject").tag(subject as Subject?)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // 使用選單樣式的選擇器
                .frame(width: 200) // 設定選擇器的寬度
                .onChange(of: selectedSubject) { newSubject in
                    // 當選擇的科目改變時，更新顯示的科目累計學習時間
                    if let subject = newSubject {
                        subjectAccumulatedTime = subject.accumulatedTime // 更新科目累計時間
                        subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime) // 格式化顯示
                    } else {
                        subjectAccumulatedTime = 0 // 如果沒有選擇科目，重置累計時間
                        subjectElapsedTime = "00:00:00"
                    }
                }
            }
            .padding([.top, .trailing], 10) // 設定選擇器的上方和右方內間距

            Spacer() // 增加空間以將內容向上推

            // 顯示總累計學習時間和當前科目的累計學習時間
            HStack {
                VStack {
                    Text("Total") // 顯示「總時間」標題
                        .font(.custom("Times New Roman", size: 16))
                    Text(elapsedTime) // 顯示當天累計學習時間
                        .font(.custom("Times New Roman", size: 48))
                        .padding(.bottom, -5) // 調整顯示的文字位置
                }
                .padding(.horizontal, 15) // 設定水平內間距

                VStack {
                    Text(selectedSubject?.name ?? "General") // 顯示當前選擇科目的名稱
                        .font(.custom("Times New Roman", size: 16))
                    Text(subjectElapsedTime) // 顯示當前科目的累計學習時間
                        .font(.custom("Times New Roman", size: 48))
                        .padding(.bottom, -5)
                }
                .padding(.horizontal, 15) // 設定水平內間距
            }
            .padding(.top, -20) // 調整文字的垂直位置

            Spacer() // 增加空間以將按鈕推向底部

            // 計時開始或停止按鈕
            Text(isTimerRunning ? "stop" : "start") // 根據計時狀態顯示不同文字
                .font(.custom("Times New Roman", size: 18))
                .frame(width: 70, height: 24) // 設定按鈕的大小
                .foregroundColor(.white) // 設定文字顏色為白色
                .background(isTimerRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9)) // 根據計時狀態變更背景色
                .cornerRadius(8) // 設定按鈕的圓角
                .onTapGesture {
                    startOrStopTimer() // 當按鈕被點擊時，啟動或停止計時器
                }
                .overlay( // 添加自定義的邊框
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isTimerRunning ? Color.red : Color.green, lineWidth: 1) // 設定邊框顏色和寬度
                )
                .padding(.bottom, 20) // 調整按鈕與底部的距離

            Spacer() // 增加空間以將按鈕推向底部
        }
    }

    // Insights 頁面的內容
    var insightsView: some View {
        Text("Insights View")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }

    // 科目管理頁面的內容
    var subjectsView: some View {
        ZStack {
            // 列表顯示所有科目及其累計時間
            List {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    HStack {
                        // 可編輯的科目名稱欄位
                        TextField("subject", text: Binding(
                            get: { subject.name ?? "" },
                            set: { newValue in
                                subject.name = newValue // 更新科目名稱
                                subjectViewModel.saveContext() // 保存到 Core Data
                            }
                        ))
                        .textFieldStyle(PlainTextFieldStyle()) // 使用無邊框的文字欄位樣式
                        .background(Color.clear) // 清除背景色

                        Spacer()

                        // 顯示科目的累計學習時間
                        Text(formatTimeInterval(subject.accumulatedTime))
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        // 刪除科目
                        Button(role: .destructive) {
                            subjectViewModel.deleteSubject(subject: subject) // 刪除科目
                        } label: {
                            Label("delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // 移除方框樣式
            .background(Color.clear) // 清除列表背景色
            .padding(.horizontal, -10) // 調整列表的左右間距
            .padding(.top, 15) // 列表距離頂部的間距
            .padding(.bottom, -10) // 調整底部的間距

            VStack {
                Spacer() // 將新增按鈕推到頁面下方
                HStack {
                    Spacer() // 將新增按鈕推到右側
                    Text("+")
                        .font(.custom("Times New Roman", size: 24))
                        .onTapGesture {
                            subjectViewModel.addSubject(name: "new subject") // 點擊後新增新科目
                        }
                        .padding(.bottom, 15) // 調整按鈕與底部的距離
                        .padding(.trailing, 20) // 調整按鈕與右側的距離
                }
            }
        }
    }

    // 載入當天的累計學習時間
    func loadTodayAccumulatedTime() {
        let today = Calendar.current.startOfDay(for: Date()) // 獲取今天的 00:00
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date

        if let lastDate = lastSavedDate, Calendar.current.isDateInToday(lastDate) {
            // 如果今天已經有保存的累計時間，則從 UserDefaults 中載入
            totalAccumulatedTime = UserDefaults.standard.double(forKey: "todayAccumulatedTime")
        } else {
            // 如果是新的一天，重置累計時間
            totalAccumulatedTime = 0
            UserDefaults.standard.set(today, forKey: "lastSavedDate")
        }

        elapsedTime = formatTimeInterval(totalAccumulatedTime) // 更新顯示的總累計時間
    }

    // 保存當天的累計學習時間
    func saveTodayAccumulatedTime() {
        let today = Calendar.current.startOfDay(for: Date()) // 獲取今天的 00:00
        UserDefaults.standard.set(totalAccumulatedTime, forKey: "todayAccumulatedTime") // 保存累計時間
        UserDefaults.standard.set(today, forKey: "lastSavedDate") // 保存當天的日期
    }

    // 計時器開始或停止的功能
    func startOrStopTimer() {
        if isTimerRunning {
            // 如果計時器正在運行，停止計時並累積學習時間
            timer?.invalidate() // 停止計時器
            let currentTime = Date() // 當前時間
            let timeInterval = currentTime.timeIntervalSince(startTime) // 計算計時器運行的時間

            totalAccumulatedTime += timeInterval // 增加當天累計學習時間
            subjectAccumulatedTime += timeInterval // 增加當前科目的學習時間

            // 更新選擇的科目累計時間
            if let selectedSubject = selectedSubject {
                selectedSubject.accumulatedTime += timeInterval
                subjectViewModel.saveContext() // 保存到 Core Data
            }

            saveTodayAccumulatedTime() // 保存當天學習時間

            // 添加新的學習會話紀錄
            sessionViewModel.addStudySession(
                subjectName: selectedSubject?.name ?? "未知科目", // 如果科目名稱為 nil，顯示「未知科目」
                descriptionText: "", // 可根據需求添加描述
                startTime: startTime, // 計時開始時間
                endTime: currentTime // 計時結束時間
            )

            isTimerRunning = false // 停止計時器
        } else {
            // 如果計時器未運行，則開始計時
            startTime = Date() // 設置當前時間為開始時間
            isTimerRunning = true // 設定計時狀態為運行中
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateElapsedTime() // 每秒更新顯示的時間
            }
        }
    }

    // 每秒更新時間顯示的功能
    func updateElapsedTime() {
        let currentTime = Date() // 獲取當前時間
        let timeInterval = currentTime.timeIntervalSince(startTime) // 計算計時器運行的時間

        // 檢查是否過了午夜，如果是，重置當天的累計時間
        let today = Calendar.current.startOfDay(for: Date())
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date
        if let lastDate = lastSavedDate, !Calendar.current.isDateInToday(lastDate) {
            totalAccumulatedTime = 0 // 重置當天累計學習時間
            UserDefaults.standard.set(today, forKey: "lastSavedDate")
        }

        // 更新顯示的當天總學習時間
        let totalTodayTime = totalAccumulatedTime + timeInterval
        elapsedTime = formatTimeInterval(totalTodayTime)

        // 更新顯示的當前科目學習時間
        let subjectTime = subjectAccumulatedTime + timeInterval
        subjectElapsedTime = formatTimeInterval(subjectTime)
    }

    // 格式化時間間隔為時:分:秒的格式
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600 // 計算小時數
        let minutes = (Int(interval) % 3600) / 60 // 計算分鐘數
        let seconds = Int(interval) % 60 // 計算秒數
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds) // 格式化為 00:00:00 格式
    }
}
