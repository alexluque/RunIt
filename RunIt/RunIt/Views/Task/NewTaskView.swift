//
//  NewTaskView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 23/7/22.
//

import SwiftUI

struct NewTaskView: View {
    @EnvironmentObject var dataController: DataController

    @State private var name = ""
    @State private var creationDate = Date.now
    @State private var length: Int16 = 0
    @State private var areStepsOrdered = false
    @State private var steps = [Step]()
    
    @State private var canAddSteps = false
    
    init() {
        _name = State(wrappedValue: "")
        _creationDate = State(wrappedValue: Date.now)
        _length = State(wrappedValue: 0)
        _areStepsOrdered = State(wrappedValue: false)
        _steps = State(wrappedValue: [])
    }
    
    var body: some View {
        VStack {
            TaskTopButtons(
                name: $name,
                steps: $steps,
                areStepsOrdered: $areStepsOrdered,
                task: nil,
                isNew: true
            )
            
            Form {
                TaskBasicSettings(name: $name, areStepsOrdered: $areStepsOrdered)
                
                Section(
                    header: TaskStepsHeader(name: $name, steps: $steps)
                ) {
                    TaskSteps(steps: $steps)
                }
            }
        }
    }
}

struct NewTaskView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        NewTaskView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
