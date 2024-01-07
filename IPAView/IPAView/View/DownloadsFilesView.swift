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
        VStack {
            HStack {
                Text("~/Downloads")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    sharedModel.loadUserDownloadsFiles()
                } label: {
                    Label("Load IPA files in ~/Downloads", systemImage: "arrow.clockwise")
                }
                .padding(.trailing)

            }
            .padding(.leading)
            
            List(sharedModel.filesInDownloads, id:\.self) { fileURL in
                Text("~/Downloads/\(fileURL.lastPathComponent.removingPercentEncoding ?? fileURL.lastPathComponent)")
                    .onTapGesture {
                        handleFileTap(fileURL)
                    }
            }
        }
        .onAppear(perform: {
            let permissionReady = UserDefaults.standard.bool(forKey: "PermissionReadyDownloads")
            if permissionReady {
                sharedModel.loadUserDownloadsFiles()
            }
        })
    }
    
    
    private func handleFileTap(_ url: URL) {
        
        // Define what happens when a file is tapped
        print("File tapped: \(url)")
        // For example, open the file or show details
        
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
        print("file not existed : \(url)")
        sharedModel.showToastMessage("File not existed : \(url)")
    }
}

#Preview {
    DownloadsFilesView()
        .environmentObject(SharedModel())

}
