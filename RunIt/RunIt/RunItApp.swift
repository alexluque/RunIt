//
//  RunItApp.swift
//  RunIt
//
//  Created by Àlex G. Luque on 6/7/22.
//

import SwiftUI

@main
struct RunItApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
