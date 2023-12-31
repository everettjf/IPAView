//
//  DetailView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/24.
//

import SwiftUI


struct DetailView: View {
    @EnvironmentObject var sharedModel: SharedModel
    
    var item: SidebarItemInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.leading)
                .padding(.trailing)
            content
        }
    }
    
    var header: some View {
        NavigationBarView(rootUrl: sharedModel.rootUrl, path: sharedModel.currentPath, action: FileSystemNavigationBarAction(onActionOpenPath: { path in
            sharedModel.openDirectory(path: path)
        }))
    }
    
    var content: some View {
        Table(sharedModel.files, selection: $sharedModel.selectedFiles) {
            TableColumn("Name", value: \.name)
                .width(min: 100, ideal: 200)
            TableColumn("Type", value: \.type)
                .width(min: 100, ideal: 100)
            TableColumn("Size", value: \.formattedSize)
                .width(min: 100, ideal: 100)
        }
        .frame(minHeight: 300)
        .contextMenu(forSelectionType: FileItemInfo.ID.self, menu: { items in
            if items.count == 1 { // Single item menu.
                Button("Open") {
                    print("menu click : open item \(items)")
                    sharedModel.openFile(fileID: items.first!)
                }
                Button("Reveal in Finder") {
                    sharedModel.revealInFinder(fileID: items.first!)
                }
                Button("Search with Google") {
                    sharedModel.searchFileName(fileID: items.first!, engine: "google")
                }
                Button("Search with Bing") {
                    sharedModel.searchFileName(fileID: items.first!, engine: "bing")
                }
                Button("Search with Baidu") {
                    sharedModel.searchFileName(fileID: items.first!, engine: "baidu")
                }
            }
        }) { items in
            print("double click")
            if items.count == 1 {
                // single item
                sharedModel.openFile(fileID: items.first!)
            }
        }
    }
    
}


#Preview {
    DetailView(item: SidebarItemInfo(name: "folder", path: URL(filePath: "/Users/everettjf/Downloads/folder/"), directory: true))
        .environmentObject(SharedModel())
}
