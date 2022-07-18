//
//  DateExtensions.swift
//  RunIt
//
//  Created by Àlex G. Luque on 12/7/22.
//

import Foundation

extension Date {
    
    func format() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMy")
        
        return formatter.string(from: self)
    }
}
