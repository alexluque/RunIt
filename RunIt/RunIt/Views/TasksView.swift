//
//  TasksView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import CoreData
import SwiftUI

struct TasksView: View {
    @EnvironmentObject var dataController: DataController
    let tasks: FetchRequest<Task>
    
    @State var sortByName = true
    @State var sortAscending = true
    @State var canCreateTask = false
    @State var searchedTaskName = ""
    
    var searchedTasks: [Task] {
        var sortedTasks = tasks.wrappedValue.sorted(by: {
            if sortByName {
                return $0.taskName < $1.taskName
            } else {
                return $0.creationDate < $1.creationDate
            }
        })
        
        sortedTasks = sortAscending ? sortedTasks : sortedTasks.reversed()
        
        if searchedTaskName.isEmpty {
            return sortedTasks.map({ $0 })
        } else {
            return sortedTasks.filter({ $0.taskName.contains(searchedTaskName) })
        }
    }
    
    init() {
        tasks = FetchRequest<Task>(
            entity: Task.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Task.name, ascending: true)]
        )
    }
    
    var newTaskButton: some View {
        Button {
            canCreateTask.toggle()
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $canCreateTask) {
            NewTaskView()
        }
    }
    
    var sortingSelector: some View {
        HStack {
            Picker("Sorted by", selection: $sortByName) {
                Text("Name").tag(true)
                Text("Creation date").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            Button {
                sortAscending.toggle()
            } label: {
                Image(systemName: sortAscending ? "arrow.down" : "arrow.up")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sorted by:")
                        .font(.caption)
                    
                    sortingSelector
                }
                .padding()
                
                List {
                    ForEach(searchedTasks) { task in
                        Section(header: TaskHeader(task: task)) {
                            TaskBody(task: task)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchedTaskName, prompt: "Type the name of the task")
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem {
                    newTaskButton
                }
            }
        }
    }
}

struct TaskHeader: View {
    @ObservedObject var task: Task
    
    @State private var canEditTask = false
    
    var body: some View {
        HStack(alignment: .top) {
            Text(task.taskName)
            
            Spacer()
            
            Button {
                canEditTask.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .sheet(isPresented: $canEditTask) {
                EditTaskView(task: task)
            }
            .padding(.trailing)
            
            Button {
                
            } label: {
                Image(systemName: "play.fill")
            }
        }
    }
}

struct TaskBody: View {
    @ObservedObject var task: Task
    
    var body: some View {
        HStack {
            let stepsCount = task.taskSteps.count
            let form = stepsCount == 1 ? "Step" : "Steps"
            Text("\(stepsCount) \(form)")
            
            Spacer()
            
            let length = Int16(task.taskSteps.map({ $0.length }).reduce(0, +))
            Text(length.naturalLength())
            
            Spacer()
            
            Text(task.creationDate.format())
        }
        .font(.footnote)
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
