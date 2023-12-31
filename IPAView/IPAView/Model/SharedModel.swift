//
//  SharedModel.swift
//  IPAView
//
//  Created by everettjf on 2023/12/29.
//

import Foundation
import SwiftUI

class SharedModel: ObservableObject {
    // toast
    @Published var showToast = false
    @Published var toastMessage = ""
    
    // extracting
    @Published var unzipExecuting: Bool = false
    @Published var unzipProgress: Double = 0
    @Published var unzipStatus: String = ""
    
    // sidebar items
    @Published var items: [SidebarItemInfo] = []
    @Published var selectedItem: SidebarItemInfo.ID?
    
    // files
    @Published var files: [FileItemInfo] = []
    @Published var selectedFiles = Set<FileItemInfo.ID>()
    @Published var fileSearchText = ""
    @Published var currentPath: URL = URL(filePath: "")
    
    // inspector
    @Published var showInspector = false
    @Published var inspectItems: [InspectItemInfo] = []
    @Published var selectedInspectItems = Set<InspectItemInfo.ID>()
    
    // for the initial root url
    var rootUrl: URL = URL(filePath: "")
    
    // list stuff
    func loadInitialPath(dir: URL) {
        DispatchQueue.main.async {
            print("load path : \(dir)")
            self.listInitialFiles(atPath: dir.path())
        }
    }
    
    private func listInitialFiles(atPath path: String) {
        // items
        self.rootUrl = URL(filePath: path)
        items = ExploreManager.listKeyItems(path: rootUrl)
        // select the app
        let appItemId = items.first { $0.name.hasSuffix(".app")}?.id
        if let appItemId = appItemId {
            selectedItem = appItemId
        } else {
            if let firstItemId = items.first?.id {
                selectedItem = firstItemId
            }
        }
        
        // inspector
        showInspector = true
        DispatchQueue.global().async {
            let results = InspectorManager.analyzeDirectory(at: self.rootUrl)
            DispatchQueue.main.async {
                self.inspectItems = results
            }
        }
    }
    
    private func loadFilesFromPath(path: URL) {
        self.currentPath = path
        self.files = ExploreManager.listFiles(path: path)
        self.selectedFiles = []
    }
    
    func openDirectory(path: URL) {
        print("open path : \(path)")
        loadFilesFromPath(path: path)
    }
    
    func openFile(itemID: SidebarItemInfo.ID) {
        let item = self.items.first { $0.id == itemID }
        guard let item = item else {
            return
        }
        
        if item.directory {
            loadFilesFromPath(path: item.path)
        } else {
            print("can not open file now")
        }
    }
    
    func revealInFinder(fileID: FileItemInfo.ID) {
        let file = self.files.first {$0.id == fileID}
        guard let file = file else {
            return
        }
        
        print("open file : \(file.name)")
        
        Utils.revealInFinder(fileURL: file.path)
    }
    
    func searchFileName(fileID: FileItemInfo.ID, engine: String) {
        let file = self.files.first {$0.id == fileID}
        guard let file = file else {
            return
        }
        
        print("search file : \(file.name)")
        Utils.searchWithDefaultBrowser(query: file.name, searchEngine: engine)
    }
    
    func openFile(fileID: FileItemInfo.ID) {
        let file = self.files.first {$0.id == fileID}
        guard let file = file else {
            return
        }
        
        print("open file : \(file.name)")
        
        if file.directory {
            loadFilesFromPath(path: file.path)
        } else {
            Utils.openFile(file.path)
        }
    }
    
    // unzip stuff
    private var unzipManager = UnzipManager()
    
    func unzipFile(at sourceURL: URL) {
        if self.unzipExecuting {
            print("unzip executing, ignore")
            return
        }
        
        unzipManager.progressHandler = { [weak self] progress in
            DispatchQueue.main.async {
                self?.unzipProgress = progress
                self?.unzipStatus = "Progress \(Int(progress * 100))%"
            }
        }
        
        self.unzipExecuting = true
        unzipManager.unzipFile(at: sourceURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.unzipExecuting = false
                switch result {
                case .success(let directoryURL):
                    self?.unzipStatus = "Extracted to: \(directoryURL.path)"
                    self?.listInitialFiles(atPath: directoryURL.path())
                case .failure(let error):
                    self?.unzipStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func showToastMessage(_ message: String) {
        self.toastMessage = message
        withAnimation {
            showToast = true
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showToast = false
                self.toastMessage = ""
            }
        }
        
    }
}
