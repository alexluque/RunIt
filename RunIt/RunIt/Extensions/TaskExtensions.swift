//
//  TaskExtensions.swift
//  RunIt
//
//  Created by Àlex G. Luque on 14/7/22.
//

import Foundation

extension Task {
    
    var creationDate: Date {
        creation ?? Date()
    }
    
    var taskName: String {
        name ?? ""
    }
    
    var taskRuns: [Run] {
        runs?.allObjects as? [Run] ?? []
    }
    
    var taskSteps: [Step] {
        steps?.allObjects as? [Step] ?? []
    }
    
    static var example: Task {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let task = Task(context: viewContext)
        task.name = "Example task"
        task.areStepsOrdered = Bool.random()
        task.creation = Date.now
        task.steps = []
        task.length = 0
        
        for stepNumber in 1...4 {
            let step = Step(context: viewContext)
            step.name = "Step \(task.taskName)-\(stepNumber)"
            step.length = stepNumber == 4 ? 0 : Int16(stepNumber * 10)
            step.tasks = [task]
            step.lastStepIn = nil
            
            task.length += step.length
        }
        
        return task
    }
}
