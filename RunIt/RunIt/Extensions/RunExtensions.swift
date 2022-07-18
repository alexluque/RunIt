//
//  RunExtensions.swift
//  RunIt
//
//  Created by Àlex G. Luque on 14/7/22.
//

import Foundation

extension Run {
    
    var lastRan: Date {
        date ?? Date()
    }
    
    var runLastStep: Step {
        lastRanStep ?? Step()
    }
    
    var runTask: Task {
        task ?? Task()
    }
}
