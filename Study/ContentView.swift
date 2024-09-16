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
                        .font(.custom("Times New Roman", size: 18)) // 使用 Times New Roman 顯示標籤文字
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // 使用分段選擇樣式
            .frame(width: 300) // 控制寬度，可以根據需要調整
            .padding(.horizontal, 20) // 減少水平 padding
          

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

            // 載入今日累計時間
            loadTodayAccumulatedTime()

            // 如果有選中的科目，從 Core Data 中載入科目的累計時間
            if let selectedSubject = selectedSubject {
                subjectAccumulatedTime = selectedSubject.accumulatedTime
                subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime)
            }
        }
    }

    // 計時器頁面內容
    var timerView: some View {
        VStack {
            HStack {
                Spacer() // 推動 Picker 到右側
                // 選擇科目
                Picker("", selection: $selectedSubject) {
                    ForEach(subjectViewModel.subjects, id: \.self) { subject in
                        Text(subject.name ?? "New Subject").tag(subject as Subject?)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // 使用選單樣式
                .frame(width: 200)
                .onChange(of: selectedSubject) { newSubject in
                    // 當科目變更時，更新科目累計時間
                    if let subject = newSubject {
                        subjectAccumulatedTime = subject.accumulatedTime
                        subjectElapsedTime = formatTimeInterval(subjectAccumulatedTime)
                    } else {
                        subjectAccumulatedTime = 0
                        subjectElapsedTime = "00:00:00"
                    }
                }
            }
            .padding([.top, .trailing], 10) // 調整 padding 放置到最右上方

            Spacer() // 移動到最頂後立即增加 Spacer()

            // 顯示今日累計時間和當前科目累計時間
            HStack {
                VStack {
                    Text("Total")
                        .font(.custom("Times New Roman", size: 16)) // 使用 Times New Roman
                    Text(elapsedTime)
                        .font(.custom("Times New Roman", size: 48)) // 使用 Times New Roman
                        .padding(.bottom, -5) // 往上移動一點點
                }
                .padding(.horizontal, 15) // 增加 Total 和 Subject 與屏幕邊緣的距離，調整更靠近
                
                VStack {
                    Text(selectedSubject?.name ?? "General")
                        .font(.custom("Times New Roman", size: 16)) // 使用 Times New Roman
                    Text(subjectElapsedTime)
                        .font(.custom("Times New Roman", size: 48)) // 使用 Times New Roman
                        .padding(.bottom, -5) // 往上移動一點點
                }
                .padding(.horizontal, 15) // 增加 Total 和 Subject 與屏幕邊緣的距離，調整更靠近
            }
            .padding(.top, -20) // 整體時間顯示向上移動
            

            Spacer() // 增加空間將按鈕推動到底部

            // 開始或停止按鈕
            Text(isTimerRunning ? "stop" : "start")
                .font(.custom("Times New Roman", size: 18)) // 使用 Times New Roman
                .frame(width: 70, height: 24) // 設定尺寸
                .foregroundColor(.white) // 設定文字顏色
                .background(isTimerRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9)) // 在匡線內部上色
                .cornerRadius(8) // 確保背景與邊框的圓角一致
                .onTapGesture {
                    startOrStopTimer() // 添加點擊動作
                }
                .overlay( // 添加自定義邊框
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isTimerRunning ? Color.red : Color.green, lineWidth: 1) // 自定義邊框顏色和寬度
                )
                .padding(.bottom, 20) // 將按鈕進一步向下移動
            
            Spacer() // 增加 Spacer() 來確保按鈕位於底部
        }
    }
    

    // Insights頁面內容
    var insightsView: some View {
        Text("Insights View")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }

    var subjectsView: some View {
        ZStack {
            // 調整左右的邊界
            List {
                ForEach(subjectViewModel.subjects, id: \.self) { subject in
                    HStack {
                        // 科目名稱編輯
                        TextField("subject", text: Binding(
                            get: { subject.name ?? "" },
                            set: { newValue in
                                subject.name = newValue
                                subjectViewModel.saveContext() // 科目名稱修改後儲存
                            }
                        ))
                        .textFieldStyle(PlainTextFieldStyle())
                        .background(Color.clear) // 清除背景色

                        Spacer()

                        Text(formatTimeInterval(subject.accumulatedTime)) // 顯示學習時間
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        // 刪除科目
                        Button(role: .destructive) {
                            subjectViewModel.deleteSubject(subject: subject)
                        } label: {
                            Label("delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // 移除方框樣式
            .background(Color.clear) // 清除列表背景色
            .padding(.horizontal, -10) // 調整左右間距
            .padding(.top, 15) // 往下移動列表
            .padding(.bottom, -10) // 往上收起底部距離

            VStack {
                Spacer() // 推動內容到下方
                HStack {
                    Spacer() // 推動內容到右側
                    Text("+")
                        .font(.custom("Times New Roman", size: 24)) // 使用 Times New Roman
                        .foregroundColor(.white) // 設定文字顏色
                        .onTapGesture {
                            subjectViewModel.addSubject(name: "new subject") // 點擊後新增新科目
                        }
                        .padding(.bottom, 15) // 底部距離
                        .padding(.trailing, 20) // 右側距離
                }
            }
        }
    }
    
    // 載入今日累計時間
        func loadTodayAccumulatedTime() {
            let today = Calendar.current.startOfDay(for: Date()) // 今天的 00:00
            let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date

            if let lastDate = lastSavedDate, Calendar.current.isDateInToday(lastDate) {
                // 如果今天有保存累積時間，載入它
                totalAccumulatedTime = UserDefaults.standard.double(forKey: "todayAccumulatedTime")
            } else {
                // 新的一天，重置累積時間
                totalAccumulatedTime = 0
                UserDefaults.standard.set(today, forKey: "lastSavedDate")
            }

            elapsedTime = formatTimeInterval(totalAccumulatedTime) // 更新顯示
        }

        // 保存今日累計時間
        func saveTodayAccumulatedTime() {
            let today = Calendar.current.startOfDay(for: Date())
            UserDefaults.standard.set(totalAccumulatedTime, forKey: "todayAccumulatedTime")
            UserDefaults.standard.set(today, forKey: "lastSavedDate")
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
                selectedSubject.accumulatedTime += timeInterval
                subjectViewModel.saveContext() // 保存至 Core Data
            }
            
            // 儲存今日的學習紀錄
            saveTodayAccumulatedTime()
            
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

        // 檢查是否過了午夜，若過了午夜則重置今日累計時間
        let today = Calendar.current.startOfDay(for: Date())
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date
        if let lastDate = lastSavedDate, !Calendar.current.isDateInToday(lastDate) {
            // 如果已經過了午夜，重置今日累計時間
            totalAccumulatedTime = 0
            UserDefaults.standard.set(today, forKey: "lastSavedDate")
        }

        // 更新今日累計時間
        let totalTodayTime = totalAccumulatedTime + timeInterval
        elapsedTime = formatTimeInterval(totalTodayTime)

        // 更新當前科目累計時間
        let subjectTime = subjectAccumulatedTime + timeInterval
        subjectElapsedTime = formatTimeInterval(subjectTime)
    }

    // 格式化時間顯示 (時:分:秒)
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds) // 格式化顯示
    }
    
}
