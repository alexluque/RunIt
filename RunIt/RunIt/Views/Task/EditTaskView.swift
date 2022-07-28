//
//  EditTaskView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 13/7/22.
//

import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var dataController: DataController
    let task: Task
    
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var creationDate = Date.now
    @State private var length: Int16 = 0
    @State private var areStepsOrdered = false
    @State private var steps = [Step]()
    
    @State private var canBeDeleted = false
    
    init(task: Task) {
        self.task = task
        
        _name = State(wrappedValue: task.taskName)
        _creationDate = State(wrappedValue: task.creationDate)
        _length = State(wrappedValue: task.length)
        _areStepsOrdered = State(wrappedValue: task.areStepsOrdered)
        _steps = State(wrappedValue: task.taskSteps)
    }
    
    var deleteTaskButton: some View {
        Button("Delete task") {
            canBeDeleted.toggle()
        }
        .padding()
        .foregroundColor(.red)
        .alert("Do you want to delete the task?", isPresented: $canBeDeleted) {
            Button("Delete", role: .destructive) {
                dataController.delete(task)
                dismiss()
            }
        }
        .textCase(.none)
    }
    
    var body: some View {
        VStack {
            TaskTopButtons(
                name: $name,
                steps: $steps,
                areStepsOrdered: $areStepsOrdered,
                task: task,
                isNew: false
            )
            
            Form {
                TaskBasicSettings(name: $name, areStepsOrdered: $areStepsOrdered)
                
                Section(
                    header: TaskStepsHeader(name: $name, steps: $steps)
                ) {
                    TaskSteps(steps: $steps)
                }
            }
            
            deleteTaskButton
        }
    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        EditTaskView(task: Task.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
