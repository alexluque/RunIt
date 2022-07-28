//
//  TaskView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 24/7/22.
//

import SwiftUI

struct TaskTopButtons: View {
    @EnvironmentObject var dataController: DataController
    @Binding var name: String
    @Binding var steps: [Step]
    @Binding var areStepsOrdered: Bool
    let task: Task?
    let isNew: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            
            Spacer()
            
            if !name.isEmpty && steps.count > 0 {
                Button(isNew ? "Create" : "Update") {
                    save()
                }
            }
        }
        .padding()
        .textCase(.none)
    }
    
    func save() {
        if isNew {
            saveTask(Task(context: dataController.container.viewContext))
        } else {
            saveTask(task!)
        }
        
        dismiss()
    }
    
    private func saveTask(_ task: Task) {
        task.objectWillChange.send()
        
        task.name = name
        task.steps = NSSet(array: steps)
        task.length = task.taskSteps.map({ $0.length }).reduce(0, +)
        task.creation = task.creation == nil ? Date.now : task.creationDate
        task.areStepsOrdered = areStepsOrdered
    }
}

struct TaskBasicSettings: View {
    @Binding var name: String
    @Binding var areStepsOrdered: Bool
    
    var body: some View {
        Section(header: Text("Basic settings")) {
            TextField("Task name", text: $name)
                .padding(5)
                .border(name.isEmpty ? Color.red : Color.clear)
            
            Toggle("Should run steps in order?", isOn: $areStepsOrdered)
        }
    }
}

struct TaskStepsHeader: View {
    @Binding var name: String
    @Binding var steps: [Step]
    
    @State private var canAddSteps = false
    
    var body: some View {
        HStack {
            Text("Task steps")
            
            Spacer()
            
            Button {
                canAddSteps.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $canAddSteps) {
                StepsView(stepsInTask: $steps, taskName: name)
            }
        }
    }
}

struct TaskSteps: View {
    @Binding var steps: [Step]
    
    var body: some View {
        List {
            if steps.isEmpty {
                Text("A task should have at least 1 step")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(steps) { step in
                    HStack {
                        Text(step.stepName)
                        
                        Spacer()
                        
                        Text("\(Int(step.length)) Sec")
                            .autocapitalization(.none)
                    }
                }
                .onDelete { value in
                    steps.remove(atOffsets: value)
                }
            }
        }
    }
}
