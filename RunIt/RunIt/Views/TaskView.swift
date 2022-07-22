//
//  TaskView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 13/7/22.
//

import SwiftUI

struct TaskView: View {
    @EnvironmentObject var dataController: DataController
    let task: Task
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var creationDate: Date
    @State private var length: Int16
    @State private var areStepsOrdered: Bool
    @State private var steps: [Step]
    
    @State private var canBeDeleted: Bool
    @State private var canAddSteps: Bool
    
    init(task: Task) {
        self.task = task
        
        _name = State(wrappedValue: task.taskName)
        _creationDate = State(wrappedValue: task.creationDate)
        _length = State(wrappedValue: task.length)
        _areStepsOrdered = State(wrappedValue: task.areStepsOrdered)
        _steps = State(wrappedValue: task.taskSteps)
        
        _canBeDeleted = State(wrappedValue: false)
        _canAddSteps = State(wrappedValue: false)
    }
    
    var topButtons: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            
            Spacer()
            
            Button("Save") {
                save()
            }
            .disabled(name.isEmpty && steps.count < 1)
        }
        .padding()
    }
    var basicSettings: some View {
        Section(header: Text("Basic settings")) {
            TextField("Task name", text: $name)
                .padding(5)
                .border(name.isEmpty ? Color.red : Color.clear)
            
            Toggle("Should run steps in order?", isOn: $areStepsOrdered)
        }
    }
    var stepsHeader: some View {
        HStack {
            Text("Task steps")
            
            Spacer()
            
            Button {
                canAddSteps.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $canAddSteps) {
                StepsView(stepsInTask: $steps)
            }
        }
    }
    var stepList: some View {
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
                        
                        Text("\(step.length) Secs.")
                    }
                }
                .onDelete { value in
                    steps.remove(atOffsets: value)
                }
            }
        }
    }
    var deleteTaskButton: some View {
        Button("Delete task") {
            canBeDeleted.toggle()
        }
        .padding()
        .foregroundColor(.red)
        .alert("Do you want to delete the task?", isPresented: $canBeDeleted) {
            Button("Delete", role: .destructive) {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {
            topButtons
            
            Form {
                basicSettings
                
                Section(header: stepsHeader) {
                    stepList
                }
            }
            
            deleteTaskButton
        }
    }
    
    func save() {
        task.objectWillChange.send()
        
        task.name = name
        task.steps = NSSet(array: steps)
        task.length = task.taskSteps.map({ $0.length }).reduce(0, +)
        task.creation = task.creation == nil ? Date.now : task.creationDate
        task.areStepsOrdered = areStepsOrdered
        
        dismiss()
    }
}

struct TaskView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        TaskView(task: Task.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
