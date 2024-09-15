//
//  SubjectManagementView.swift
//  Study
//
//  Created by 賴楠天 on 2024/9/15.
//

import SwiftUI

struct SubjectManagementView: View {
    @StateObject var subjectViewModel = SubjectViewModel()
    @State private var subjectName = ""
    @State private var color = Color.red

    var body: some View {
        VStack {
            TextField("科目名稱", text: $subjectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            ColorPicker("選擇顏色", selection: $color)
                .padding()

            Button(action: addSubject) {
                Text("新增科目")
                    .font(.title)
                    .frame(minWidth: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            List(subjectViewModel.subjects, id: \.self) { subject in
                HStack {
                    Text(subject.name ?? "未命名")
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .onAppear {
            subjectViewModel.loadSubjects()
        }
    }

    func addSubject() {
        subjectViewModel.addSubject(name: subjectName)
    }
}


