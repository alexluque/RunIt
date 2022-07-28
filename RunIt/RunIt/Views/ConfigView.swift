//
//  ConfigView.swift
//  RunIt
//
//  Created by Àlex G. Luque on 7/7/22.
//

import SwiftUI

struct ConfigView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Configuration View")
            }
            .navigationTitle("Configuration")
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}
