//
//  HistoryView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("History View")
            }
            .navigationTitle("History of tasks")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
