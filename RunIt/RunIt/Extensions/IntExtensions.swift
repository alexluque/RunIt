//
//  IntExtensions.swift
//  RunIt
//
//  Created by Àlex G. Luque on 30/7/22.
//

import SwiftUI

extension Int16 {
    
    func naturalLength() -> LocalizedStringKey {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = (self % 3600) % 60
        
        if hours == 0 && minutes == 0 && seconds == 0 {
            return "No length set"
        } else if hours == 0 && minutes == 0 && seconds > 0 {
            return "\(seconds)s"
        } else if hours == 0 && minutes > 0 && seconds == 0 {
            return "\(minutes)m"
        } else if hours > 0 && minutes == 0 && seconds == 0 {
            return "\(hours)h"
        } else if hours == 0 && minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if hours > 0 && minutes > 0 && seconds > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if hours > 0 && minutes == 0 && seconds > 0 {
            return "\(hours)h \(seconds)s"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
}
