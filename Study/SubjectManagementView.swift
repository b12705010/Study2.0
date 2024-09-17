//
//  SubjectManagementView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import SwiftUI

// SubjectManagementView 是管理科目的視圖，允許使用者新增及顯示科目
struct SubjectManagementView: View {
    @StateObject var subjectViewModel = SubjectViewModel() // 使用 @StateObject 管理科目的 ViewModel
    @State private var subjectName = "" // 儲存使用者輸入的新科目名稱
    @State private var color = Color.red // 儲存科目對應的顏色，初始值為紅色

    var body: some View {
        VStack {
            // 科目名稱輸入框，讓使用者輸入新科目名稱
            TextField("科目名稱", text: $subjectName)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // 使用圓角邊框樣式的文字框
                .padding() // 設定內部邊距

            // 顏色選擇器，讓使用者選擇科目對應的顏色
            ColorPicker("選擇顏色", selection: $color)
                .padding() // 設定內部邊距

            // 新增科目按鈕，點擊後會呼叫 addSubject() 方法
            Button(action: addSubject) {
                Text("新增科目") // 按鈕顯示文字
                    .font(.title) // 設置按鈕文字為標題大小
                    .frame(minWidth: 200) // 設定按鈕的最小寬度
                    .padding() // 設定內部邊距
                    .background(Color.blue) // 設置按鈕背景顏色為藍色
                    .foregroundColor(.white) // 設置按鈕文字顏色為白色
                    .cornerRadius(10) // 設置按鈕的圓角半徑
            }

            // 列表顯示所有已新增的科目
            List(subjectViewModel.subjects, id: \.self) { subject in
                HStack {
                    // 顯示科目名稱，若無名稱則顯示 "未命名"
                    Text(subject.name ?? "未命名")
                    Spacer() // 空間分配器，將顏色方塊推到右側
                    Rectangle() // 顏色方塊，應該顯示該科目對應的顏色
                        .fill(Color.clear) // 目前顯示透明色，應改為綁定的顏色
                        .frame(width: 20, height: 20) // 設置顏色方塊的大小
                }
            }
        }
        .onAppear {
            // 當視圖出現時，從 ViewModel 中加載所有科目
            subjectViewModel.loadSubjects()
        }
    }

    // 新增科目功能
    func addSubject() {
        // 呼叫 ViewModel 的 addSubject 方法，將新科目名稱添加進去
        subjectViewModel.addSubject(name: subjectName)
        // 清空輸入框的科目名稱
        subjectName = ""
    }
}
