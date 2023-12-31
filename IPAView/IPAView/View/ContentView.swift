//
//  ContentView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/23.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @StateObject var sharedModel = SharedModel()
    
    var body: some View {
        NavigationSplitView {
            List(sharedModel.items, selection: $sharedModel.selectedItem) { item in
                Label(item.name, systemImage: item.directory ? "folder" : "file")
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            if let itemId = sharedModel.selectedItem {
                DetailView(item: sharedModel.items.first { $0.id == itemId}! )
            } else {
                DropView()
            }
        }
        .environmentObject(sharedModel)
        .onChange(of: sharedModel.selectedItem, { oldValue, newValue in
            if oldValue == nil {
                print("initial load")
            }
            if let itemId = newValue {
                sharedModel.openFile(itemID: itemId)
            }
        })
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: showFeedback) {
                    Label("Feedback", systemImage: "questionmark.circle")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: showInspector) {
                    Label("Inspector", systemImage: "sidebar.right")
                }
            }
        }
        .searchable(text: $sharedModel.fileSearchText, placement: .toolbar) {
            // suggestions, todo future versions
        }
        .onChange(of: sharedModel.fileSearchText) { oldValue, newValue in
            print("on search confirm :  new value \(newValue)")
        }
        .inspectorColumnWidth(min: 100,ideal: 200, max: 500)
        .inspector(isPresented: $sharedModel.showInspector) {
            InspectorView()
                .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
                .environmentObject(sharedModel)
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 300, idealHeight: 550, maxHeight: .infinity)
        .toast(isShowing: $sharedModel.showToast, text: sharedModel.toastMessage)

    }
    
    private func showFeedback() {
        // Your feedback action here
        print("Feedback button tapped")
        
        Utils.openURL("https://github.com/IPAView/ipaview.github.io/issues")
    }
    
    private func showInspector() {
        sharedModel.showInspector.toggle()
    }
}

#Preview {
    ContentView()
}
