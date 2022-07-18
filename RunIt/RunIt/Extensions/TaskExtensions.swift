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
}
