//
//  InspectorView.swift
//  IPAView
//
//  Created by everettjf on 2023/12/31.
//

import SwiftUI
import AppKit

struct InspectorView: View {
    @EnvironmentObject var sharedModel: SharedModel

    var body: some View {
        VStack {
            Table(sharedModel.inspectItems, selection: $sharedModel.selectedInspectItems) {
                TableColumn("Inspect Item", value: \.name)
                    .width(min: 100, ideal: 150)
                TableColumn("Description", value: \.value)
                    .width(min: 100, ideal: 200)
            }
            .contextMenu(forSelectionType: InspectItemInfo.ID.self, menu: { items in
                if items.count == 1 {
                    Button("Copy") {
                        self.onCopyItems(items: items)
                    }
                }
                if items.count > 1 {
                    Button("Copy") {
                        self.onCopyItems(items: items)
                    }
                }
            }) { items in
                print("double click")
            }
        }
        .padding(.leading, 2)
        .padding(.trailing, 2)
    }
    
    private func onCopyItems(items: Set<InspectItemInfo.ID>) {
        let filterObjects = sharedModel.inspectItems.filter { items.contains($0.id)}
        var content = ""
        for obj in filterObjects {
            content += "\(obj.name) : \(obj.value)\n"
        }
        Utils.copyToPasteboard(string: content)
        
        sharedModel.showToastMessage("\(filterObjects.count) items copied 😊")
    }
}

#Preview {
    InspectorView()
        .environmentObject(SharedModel())
}
