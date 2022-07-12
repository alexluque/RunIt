//
//  BadgesView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import SwiftUI

struct BadgesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Badges View")
            }
            .navigationTitle("Badges")
        }
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
