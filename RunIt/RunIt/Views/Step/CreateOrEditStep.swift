//
//  CreateOrEditStep.swift
//  RunIt
//
//  Created by Àlex G. Luque on 1/8/22.
//

import Foundation
import SwiftUI

struct NewStep: View {
    @EnvironmentObject var dataController: DataController
    @Binding var canCreateNewStep: Bool
    @Binding var newStepName: String
    @Binding var newStepLengthHours: Int16
    @Binding var newStepLengtMinutes: Int16
    @Binding var newStepLengthSeconds: Int16
    @Binding var steps: [Step]
    var geoWidth: CGFloat
    
    @State private var canPickLength = false
    @FocusState private var canWriteName: Bool
    
    var body: some View {
        Section(
            header: NewOrEditStepHeader(
                canAlterSteps: $canCreateNewStep,
                title: "New Step"
            )
        ) {
            NewOrEditStepName(stepName: $newStepName, canWriteName: _canWriteName)
            
            NewOrEditStepBody(
                canPickLength: $canPickLength,
                newStepLengthHours: $newStepLengthHours,
                newStepLengtMinutes: $newStepLengtMinutes,
                newStepLengthSeconds: $newStepLengthSeconds,
                geoWidth: geoWidth
            )
            
            Button("Add") {
                saveNewStep()
            }
            .disabled(newStepName.isEmpty)
        }
    }
    
    private func saveNewStep() {
        if !steps.contains(where: { $0.stepName == newStepName }) {
            let step = Step(context: dataController.container.viewContext)
            
            step.objectWillChange.send()
            
            let hours = (newStepLengthHours * 60) * 60
            let minutes = newStepLengtMinutes * 60
            step.length = Int16(hours + minutes + newStepLengthSeconds)
            step.name = newStepName
            
            steps.append(step)
        }
        
        canCreateNewStep.toggle()
    }
}

struct NewOrEditStepHeader: View {
    @Binding var canAlterSteps: Bool
    let title: LocalizedStringKey
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Button("Cancel") {
                canAlterSteps.toggle()
            }
        }
    }
}

struct NewOrEditStepName: View {
    @Binding var stepName: String
    @FocusState var canWriteName: Bool
    
    var body: some View {
        TextField("Step name", text: $stepName)
            .padding(5)
            .border(stepName.isEmpty ? Color.red : Color.clear)
            .focused($canWriteName)
    }
}

struct NewOrEditStepBody: View {
    @Binding var canPickLength: Bool
    @Binding var newStepLengthHours: Int16
    @Binding var newStepLengtMinutes: Int16
    @Binding var newStepLengthSeconds: Int16
    let geoWidth: CGFloat
    
    var body: some View {
        VStack {
            Button {
                canPickLength.toggle()
            } label: {
                HStack {
                    Text("\(newStepLengthHours)h")
                    Text("\(newStepLengtMinutes)m")
                    Text("\(newStepLengthSeconds)s")
                    
                    Spacer()
                }
            }
            
            if canPickLength {
                HStack(spacing: 0) {
                    Picker("Step's length in hours", selection: $newStepLengthHours) {
                        ForEach(0...24, id: \.self) { hour in
                            Text("\(hour)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .overlay(Text("hrs").padding(.leading, 50))
                    .frame(width: geoWidth / 3.5)
                    .clipped()
                    .compositingGroup()
                    .onChange(of: newStepLengthHours) { _ in
                        setMinSeconds()
                    }
                    
                    Picker("Step's length in minutes", selection: $newStepLengtMinutes) {
                        ForEach(0...60, id: \.self) { minute in
                            Text("\(minute)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .overlay(Text("min").padding(.leading, 55))
                    .frame(width: geoWidth / 3.5)
                    .clipped()
                    .compositingGroup()
                    .onChange(of: newStepLengtMinutes) { _ in
                        setMinSeconds()
                    }
                    
                    Picker("Step's length in seconds", selection: $newStepLengthSeconds) {
                        let seconds = newStepLengthHours > 0 || newStepLengtMinutes > 0 ? 0...60 : 10...60
                        ForEach(seconds, id: \.self) { second in
                            Text("\(second)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .overlay(Text("sec").padding(.leading, 55))
                    .frame(width: geoWidth / 3.5)
                    .clipped()
                    .compositingGroup()
                    .onChange(of: newStepLengthSeconds) { _ in
                        setMinSeconds()
                    }
                }
            }
            
        }
    }
    
    private func setMinSeconds() {
        if newStepLengthHours == 0
            && newStepLengtMinutes == 0
            && (newStepLengthSeconds > 0 && newStepLengthSeconds < 10) {
            newStepLengthSeconds = 10
        }
    }
}

struct EditStep: View {
    @EnvironmentObject var dataController: DataController
    @Binding var canEditStep: Bool
    @Binding var steps: [Step]
    var geoWidth: CGFloat
    let step: Step
    
    @State private var canPickLength = false
    @State private var newStepLengthHours: Int16 = 0
    @State private var newStepLengtMinutes: Int16 = 0
    @State private var newStepLengthSeconds: Int16 = 0
    @State private var stepName = ""
    @FocusState private var canWriteName: Bool
    
    private var hours: Int16 {
        step.length / 3600
    }
    private var minutes: Int16 {
        (step.length % 3600) / 60
    }
    private var seconds: Int16 {
        (step.length % 3600) % 60
    }
    
    var body: some View {
        Section(
            header: NewOrEditStepHeader(
                canAlterSteps: $canEditStep,
                title: "Edit Step"
            )
        ) {
            NewOrEditStepName(stepName: $stepName, canWriteName: _canWriteName)
            
            NewOrEditStepBody(
                canPickLength: $canPickLength,
                newStepLengthHours: $newStepLengthHours,
                newStepLengtMinutes: $newStepLengtMinutes,
                newStepLengthSeconds: $newStepLengthSeconds,
                geoWidth: geoWidth
            )
            
            Button("Update") {
                updateStep()
            }
            .disabled(step.stepName.isEmpty)
        }
        .onAppear {
            newStepLengthHours = hours
            newStepLengtMinutes = minutes
            newStepLengthSeconds = seconds
            stepName = step.stepName
        }
    }
    
    private func updateStep() {
        step.objectWillChange.send()
        
        let hours = (newStepLengthHours * 60) * 60
        let minutes = newStepLengtMinutes * 60
        step.length = Int16(hours + minutes + newStepLengthSeconds)
        step.name = stepName
        
        canEditStep.toggle()
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }
}
