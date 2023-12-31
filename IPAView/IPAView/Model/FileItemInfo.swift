//
//  FileInfo.swift
//  IPAView
//
//  Created by everettjf on 2023/12/24.
//

import Foundation
import SwiftUI

struct FileItemInfo: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let size: Int64
    let description: String
    let directory: Bool
    let macho: Bool
    let path: URL
    
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
