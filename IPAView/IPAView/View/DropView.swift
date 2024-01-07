//
//  DropView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/24.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine



struct DropView: View {
    @EnvironmentObject var sharedModel: SharedModel
    
    var body: some View {
        VStack {
            if sharedModel.unzipExecuting {
                ProgressView("Extracting...", value: sharedModel.unzipProgress * 100, total: 100)
                               .padding()
            } else {
                Spacer()
                HStack {
                    Text("Drop an IPA file here or ")
                    Button("Select an IPA file") {
                        selectFile()
                    }
                }
                Spacer()
                
                Divider()
                HStack {
                    RecentFilesView()
                    DownloadsFilesView()
                }
                .frame(maxHeight: 150)
            }

            Text(sharedModel.unzipStatus)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
            handleFileDrop(providers: providers)
            return true
        }
    }
    func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        if panel.runModal() != .OK {
            print("No file selected")
        }
        if let url = panel.url {
            print("File selected: \(url.path)")
            
            unzipFile(fileURL: url)
        }
    }

    
    private func unzipFile(fileURL : URL) {
        sharedModel.unzipFile(at: fileURL)
        
        recentFileManager.addFile(filePath: fileURL.path(percentEncoded: false))
    }
    
    private func loadDir(dir: URL) {
        sharedModel.loadInitialPath(dir: dir)

        recentFileManager.addFile(filePath: dir.path(percentEncoded: false))
    }
    
    private func handleFileDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    // Handle the dropped file URL
                    
                    if error != nil {
                        // error
                        print("error = \(String(describing: error))")
                        return
                    }
                    
                    guard let url = url else {
                        // there must be error
                        print("url = \(String(describing: url))")
                        print("error = \(String(describing: error))")
                        return
                    }

                    // try open the file
                    print("url = \(url)")
                    
                    var isDirectory: ObjCBool = false
                    if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                        // The path does not exist
                        print("The path does not exist : \(url)")
                        return
                    }
                    
                    if isDirectory.boolValue {
                        // The URL is a directory
                        print("The URL is a directory.")
                        
                        // open dir
                        loadDir(dir: url)
                    } else {
                        // The URL is a file
                        let fileExtension = url.pathExtension.lowercased()
                        print("The URL is a file : extension = \(fileExtension)")
                        
                        if fileExtension.lowercased() == "ipa" {
                            print("got ipa file path : \(url)")
                            unzipFile(fileURL: url)
                            return
                        }
                        
                        if fileExtension.lowercased() == "zip" {
                            print("got ipa file path : \(url)")
                            unzipFile(fileURL: url)
                            return
                        }
                        
                        // other kinds of file , may not support
                        print("not support file type : \(fileExtension)")
                    }

                }
            }
        }
    }
    
}

#Preview {
    DropView()
        .environmentObject(SharedModel())
}
