//
//  NavigationBarView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/30.
//

import SwiftUI


struct FileSystemNavigationBarAction {
    let onActionOpenPath: (_ path: URL) -> Void
}

struct FileSystemNavigationBarButton: View {
    let image: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: image)
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width:20,height:25)
    }
}

struct FileSystemNavigationBarPathComponentView: View {
    let text: String
    let action: () -> Void
    
    @State var hover = false
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .fontWeight(hover ? .bold : .regular)
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(height:25)
        .onHover { hover in
            self.hover = hover
        }
    }
}

struct NavigationBarView: View {
    @EnvironmentObject var sharedModel: SharedModel

    struct Item : Identifiable{
        let id = UUID()
        let name: String
        let path: URL
    }
    
    let rootUrl: URL
    let path: URL
    let items: [Item]
    let action: FileSystemNavigationBarAction
    
    init(rootUrl: URL, path: URL, action: FileSystemNavigationBarAction) {
        self.rootUrl = rootUrl
        self.path = path
        self.action = action
        
        var items = [Item]()
        
        var current = path
        var currentName = current.lastPathComponent
        
        while !currentName.isEmpty && currentName != ".."{
            let name = currentName
            let path = current
            items.append(Item(name: "\(name) /", path: path))
            
            current = current.deletingLastPathComponent()
            currentName = current.lastPathComponent
            
            if path.path(percentEncoded: false).trimmingCharacters(in: CharacterSet(charactersIn: "/")) == rootUrl.path(percentEncoded: false).trimmingCharacters(in: CharacterSet(charactersIn: "/")) {
                break;
            }
        }
        
        self.items = items.reversed()
    }
    
    var body: some View {
        HStack (alignment: .center, spacing: 2) {
            ScrollView (.horizontal, showsIndicators: true) {
                LazyHStack (alignment:.center, spacing: 2) {
                    ForEach(items) { item in
                        FileSystemNavigationBarPathComponentView(text: item.name) {
                            self.action.onActionOpenPath(item.path)
                        }
                        .contextMenu {
                            Button {
                                Utils.revealInFinder(fileURL: item.path)
                            } label: {
                                Text("Reveal in Finder")
                            }
                            Button {
                                sharedModel.copyFileItemInfoToPasteboard(path: item.path, field: "relative-path")
                            } label: {
                                Text("Copy Relative Path")
                            }
                            Button {
                                sharedModel.copyFileItemInfoToPasteboard(path: item.path, field: "full-path")
                            } label: {
                                Text("Copy Full Path")
                            }
                            Button {
                                sharedModel.copyFileItemInfoToPasteboard(path: item.path, field: "file-name")
                            } label: {
                                Text("Copy Name")
                            }
                        }
                    }
                }
            }
            Spacer()
            
        }
        .frame(height: 30)
    }
}

#Preview {
    NavigationBarView(rootUrl: URL(filePath: "/Users/everettjf/Downloads/folder/"), path: URL(filePath: "/Users/everettjf/Downloads/folder/Payload"), action: FileSystemNavigationBarAction(onActionOpenPath: { path in

    }))
}
