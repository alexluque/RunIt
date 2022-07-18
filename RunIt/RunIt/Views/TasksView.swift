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
    
    @State var sortByName = true
    @State var sortAscending = true
    @State var canCreateTask = false
    @State var searchedTaskName = ""
    @State var canBeDeleted = false
    
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
    
    var newTaskButton: some View {
        Button {
            canCreateTask.toggle()
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $canCreateTask) {
            TaskView()
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
                    .onDelete { _ in
                        canBeDeleted = true
                    }
                    .alert("Do you want to delete the task?", isPresented: $canBeDeleted) {
                        Button("Delete", role: .destructive) {
                            
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
    let task: Task
    
    @State var canEditTask = false
    
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
                TaskView(task: task)
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
    let task: Task
    
    var body: some View {
        HStack {
            let stepsCount = task.taskSteps.count
            let form = stepsCount == 1 ? "Step" : "Steps"
            Text("\(stepsCount) \(form)")
            
            Spacer()
            
            let length = task.taskSteps.map({ $0.length }).reduce(0, +)
            Text(length == 0 ? "No length set" : "\(length) Sec.")
            
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
