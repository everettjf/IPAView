//
//  RecentFileManager.swift
//  IPAView
//
//  Created by everettjf on 2023/12/30.
//

import Foundation

class RecentFileManager {
    private let maxRecentFiles: Int
    private let userDefaultsKey: String
    private var recentFiles: [String] {
        didSet {
            // Save changes to UserDefaults
            UserDefaults.standard.set(recentFiles, forKey: userDefaultsKey)
        }
    }

    init(maxRecentFiles: Int = 10, userDefaultsKey: String = "RecentFiles") {
        self.maxRecentFiles = maxRecentFiles
        self.userDefaultsKey = userDefaultsKey
        self.recentFiles = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
    }

    func addFile(filePath: String) {
        // Remove the file if it already exists to avoid duplicates
        recentFiles.removeAll { $0 == filePath }

        // Add the file to the beginning of the array
        recentFiles.insert(filePath, at: 0)

        // Trim the array to the maximum number of recent files
        if recentFiles.count > maxRecentFiles {
            recentFiles.removeLast()
        }
    }
    
    func removeFile(filePath: String) {
        recentFiles.removeAll { $0 == filePath }
    }

    func getRecentFiles() -> [String] {
        return recentFiles
    }
}

let recentFileManager = RecentFileManager()


