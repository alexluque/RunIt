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
            
            if areStepsOrdered {
                Spacer()
                
                EditButton()
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
                
        task.steps = NSSet()
        for step in steps {
            // The for loop allow us to keep the order of steps stablished by the user
            task.addToSteps(step)
        }
        
        task.name = name
        task.length = task.taskSteps.map({ $0.length }).reduce(0, +)
        task.creation = task.creation == nil ? Date.now : task.creationDate
        task.areStepsOrdered = areStepsOrdered
    }
}

struct TaskBasicSettings: View {
    @Binding var name: String
    @Binding var areStepsOrdered: Bool
    
    var body: some View {
        Section {
            TextField("Task name", text: $name)
                .padding(5)
                .border(name.isEmpty ? Color.red : Color.clear)
            
            Toggle("Should run steps in order?", isOn: $areStepsOrdered)
        } header: {
            Text("Basic settings")
        } footer: {
            if areStepsOrdered {
                Text("Steps order tip")
            }
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
                        
                        Text(step.length.naturalLength())
                            .autocapitalization(.none)
                    }
                }
                .onDelete { value in
                    steps.remove(atOffsets: value)
                }
                .onMove { source, destination in
                    steps.move(fromOffsets: source, toOffset: destination)
                }
            }
        }
    }
}
