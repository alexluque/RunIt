//
//  StepExtensions.swift
//  RunIt
//
//  Created by Àlex G. Luque on 14/7/22.
//

import Foundation

extension Step {
    
    var stepName: String {
        name ?? ""
    }
    
    var stepTasks: [Task] {
        tasks?.allObjects as? [Task] ?? []
    }
}
