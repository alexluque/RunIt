//
//  TaskView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 13/7/22.
//

import SwiftUI

struct TaskView: View {
    let task: Task
    
    init(task: Task = Task()) {
        self.task = task
    }
    
    var body: some View {
        NavigationView {
            
        }
        .navigationTitle("Task")
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
