//
//  RecentFilesView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/30.
//

import SwiftUI

struct RecentFilesView: View {
    @EnvironmentObject var sharedModel: SharedModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Recent files")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading)
            
            List(sharedModel.recentFiles, id: \.self) { filePath in
                Text(filePath)
                    .onTapGesture {
                        handleFileTap(filePath)
                    }
            }
            .onAppear(perform: {
                sharedModel.loadRecentFiles()
            })
        }
        
        
    }
    
    private func handleFileTap(_ filePath: String) {
        // Define what happens when a file is tapped
        print("File tapped: \(filePath)")
        // For example, open the file or show details
        
        let url = URL(filePath: filePath)
        
        if Utils.directoryExists(at: url) {
            sharedModel.loadInitialPath(dir: url)
            recentFileManager.addFile(filePath: url.path(percentEncoded: false))
            return
        }
        
        if Utils.fileExists(at: url) {
            sharedModel.unzipFile(at: url)
            recentFileManager.addFile(filePath: url.path(percentEncoded: false))
            return
        }
        
        // not exist
        print("file not existed : \(filePath)")
        sharedModel.removeRecentFile(filePath: filePath)
        
        sharedModel.showToastMessage("File not existed : \(filePath)")
    }
}

#Preview {
    RecentFilesView()
        .environmentObject(SharedModel())
}
