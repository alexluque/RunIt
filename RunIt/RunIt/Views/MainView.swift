//
//  MainView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 6/7/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            BadgesView()
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Badges")
                }
            
            ConfigView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Configuration")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
