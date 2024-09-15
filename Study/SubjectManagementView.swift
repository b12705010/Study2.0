//
//  SubjectManagementView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import SwiftUI

// 這是管理科目的視圖，允許新增和顯示科目
struct SubjectManagementView: View {
    @StateObject var subjectViewModel = SubjectViewModel() // 這是科目的 ViewModel，管理科目的數據
    @State private var subjectName = "" // 儲存新增科目的名稱
    @State private var color = Color.red // 儲存科目對應的顏色

    var body: some View {
        VStack {
            // 科目名稱輸入框
            TextField("科目名稱", text: $subjectName)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // 使用圓角邊框的樣式
                .padding()

            // 顏色選擇器
            ColorPicker("選擇顏色", selection: $color)
                .padding()

            // 新增科目按鈕
            Button(action: addSubject) {
                Text("新增科目")
                    .font(.title) // 設置按鈕字體為標題大小
                    .frame(minWidth: 200) // 設置按鈕的最小寬度
                    .padding()
                    .background(Color.blue) // 設置按鈕背景顏色
                    .foregroundColor(.white) // 設置按鈕文字顏色
                    .cornerRadius(10) // 設置按鈕的圓角半徑
            }

            // 列表顯示科目
            List(subjectViewModel.subjects, id: \.self) { subject in
                HStack {
                    Text(subject.name ?? "未命名") // 顯示科目名稱
                    Spacer()
                    Rectangle() // 顏色方塊（目前顏色未綁定）
                        .fill(Color.clear) // 顯示透明方塊，應該改成顏色
                        .frame(width: 20, height: 20) // 設置顏色方塊的大小
                }
            }
        }
        .onAppear {
            subjectViewModel.loadSubjects() // 當畫面出現時加載所有科目
        }
    }

    // 新增科目功能
    func addSubject() {
        subjectViewModel.addSubject(name: subjectName) // 新增科目到 ViewModel
    }
}
