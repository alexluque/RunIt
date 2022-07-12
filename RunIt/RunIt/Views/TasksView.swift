//
//  TasksView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var dataController: DataController
    let tasks: FetchRequest<Task>
    
    init() {
        tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.name, ascending: true)]
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks.wrappedValue) { task in
                    Section(header: Text(task.name ?? "")) {
                        ForEach(task.steps?.allObjects as? [Step] ?? []) { step in
                            Text(step.name ?? "")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        TasksView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
