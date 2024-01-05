//
//  DownloadsFilesView.swift
//  IPAView
//
//  Created by everettjf on 2024/1/5.
//

import SwiftUI

struct DownloadsFilesView: View {
    @EnvironmentObject var sharedModel: SharedModel

    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    DownloadsFilesView()
        .environmentObject(SharedModel())

}
