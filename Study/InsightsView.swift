//
//  InsightsView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/19.
//
import SwiftUI
import CoreData

struct InsightsView: View {
    @FetchRequest(
        entity: DailyStudyRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyStudyRecord.date, ascending: true)]
    ) var studyRecords: FetchedResults<DailyStudyRecord> // 從 Core Data 中取得 DailyStudyRecord 資料

    // 顏色對應學習時間的層次
    let colorLevels: [Color] = [.gray, .green.opacity(0.5), .green, .blue.opacity(0.8), .blue]

    var body: some View {
        VStack {
            // 統計訊息區域
            HStack {
                VStack(alignment: .leading) {
                    Text("Total active days: \(totalActiveDays())")
                    Text("Max streak: \(maxStreak())")
                    Text("Number of records: \(studyRecords.count)")
                }
                .font(.headline)
                .padding()
                Spacer()
            }

            // ScrollView 裡分月份顯示學習記錄
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(generateMonths(), id: \.self) { month in
                        VStack(alignment: .leading) {
                            Text(monthName(from: month)) // 顯示月份名稱
                                .font(.headline)
                                .padding(.leading)

                            // 用 LazyVGrid 顯示每個月的天數
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                                ForEach(daysInMonth(month), id: \.self) { date in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red)  // 測試顏色顯示
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding([.leading, .bottom])
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400) // 強制 ScrollView 高度
        }
    }

    // 生成過去一年的月份
    func generateMonths() -> [Date] {
        var months: [Date] = []
        let today = Date()
        if let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) {
            var date = oneYearAgo
            while date <= today {
                if Calendar.current.component(.day, from: date) == 1 {
                    months.append(date) // 每個月的第一天
                }
                date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
            }
        }
        return months
    }

    // 獲取某個月的所有日期
    func daysInMonth(_ date: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: date) {
                dates.append(date)
            }
        }
        return dates
    }

    // 獲取月份名稱
    func monthName(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: date)
    }

    // 計算總活躍天數
    func totalActiveDays() -> Int {
        return studyRecords.filter { $0.totalTime > 0 }.count
    }

    // 計算最長連續天數
    func maxStreak() -> Int {
        var streak = 0
        var maxStreak = 0
        var lastDate: Date? = nil

        for record in studyRecords {
            if let date = record.date {
                if let last = lastDate, Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: last)!) {
                    streak += 1
                } else {
                    streak = 1
                }
                maxStreak = max(streak, maxStreak)
                lastDate = date
            }
        }
        return maxStreak
    }
}
