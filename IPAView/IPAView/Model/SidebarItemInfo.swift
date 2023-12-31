//
//  Item.swift
//  IPAView
//
//  Created by everettjf on 2023/12/23.
//

import Foundation
import SwiftUI

struct SidebarItemInfo: Identifiable {
    let id = UUID()
    let name: String
    let path: URL
    let directory: Bool
}
