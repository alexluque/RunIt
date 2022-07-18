//
//  DataController.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        
        return dataController
    }()
    
    func createSampleData() throws {
        let viewContext = container.viewContext
        
        for taskNumber in 1...4 {
            let task = Task(context: viewContext)
            task.name = "Task \(taskNumber)"
            task.length = 0
            task.steps = []
            task.runs = []
            task.areStepsOrdered = Bool.random()
            task.creation = Date.now
            
            let stepsLimit = taskNumber == 4 ? 1 : 3
            for stepNumber in 1...stepsLimit {
                let step = Step(context: viewContext)
                step.name = "Step \(stepNumber)"
                step.length = taskNumber == 4 ? 0 : Int16(stepNumber * 10)
                step.tasks = [task]
                step.lastStepIn = nil
                
                task.length += step.length
            }
            
            for runNumber in 1...5 {
                let run = Run(context: viewContext)
                run.task = task
                run.length = Int16(runNumber * 25)
                run.date = Date.now
                run.lastRanStep = nil
            }
        }
        
        try viewContext.save()
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Step.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
        
        let fetchRequest3: NSFetchRequest<NSFetchRequestResult> = Run.fetchRequest()
        let batchDeleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        _ = try? container.viewContext.execute(batchDeleteRequest3)
    }
}
