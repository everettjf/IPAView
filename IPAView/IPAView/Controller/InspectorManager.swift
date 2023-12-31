//
//  InspectorManager.swift
//  IPAView
//
//  Created by everettjf on 2023/12/31.
//

import Foundation

class InspectorManager {

    static func analyzeDirectory(at url: URL) -> [InspectItemInfo] {
        let fileManager = FileManager.default
        var results: [InspectItemInfo] = []
        
        var totalSize: UInt64 = 0
        var extensionSizes: [String: UInt64] = [:]
        var frameworkCount = 0
        var dylibCount = 0
        var fileCount = 0
        var directoryCount = 0
        var lprojCount = 0
        var languages: Set<String> = []

        let keys: [URLResourceKey] = [.isDirectoryKey, .totalFileSizeKey, .nameKey]

        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) else {
            return [InspectItemInfo(name: "Error", value: "Unable to enumerate files at the provided URL.")]
        }

        for case let fileURL as URL in enumerator {
            if fileCount > 100000 {
                return [InspectItemInfo(name: "Error", value: "file count more than 100000")]
            }
            
            if directoryCount > 100000 {
                return [InspectItemInfo(name: "Error", value: "directory count more than 100000")]
            }
            
            
            guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(keys)) else { continue }

            if resourceValues.isDirectory == true {
                directoryCount += 1

                if fileURL.pathExtension == "lproj" {
                    lprojCount += 1
                    if let languageName = fileURL.deletingPathExtension().lastPathComponent.split(separator: "/").last {
                        languages.insert(String(languageName))
                    }
                }

                if fileURL.pathExtension == "framework" {
                    frameworkCount += 1
                }
            } else {
                
                if fileURL.pathExtension == "dylib" {
                    dylibCount += 1
                }
                
                
                fileCount += 1
                let fileSize = resourceValues.totalFileSize ?? 0
                totalSize += UInt64(fileSize)
                let fileExtension = fileURL.pathExtension
                extensionSizes[fileExtension, default: 0] += UInt64(fileSize)
            }
        }
        
        results.append(InspectItemInfo(name: "Total files", value: "\(fileCount)"))
        results.append(InspectItemInfo(name: "Total directories", value: "\(directoryCount)"))
        results.append(InspectItemInfo(name: "File extensions count", value: "\(extensionSizes.count)"))
        results.append(InspectItemInfo(name: "Frameworks count", value: "\(frameworkCount)"))
        results.append(InspectItemInfo(name: "Dylib extension files count", value: "\(dylibCount)"))
        results.append(InspectItemInfo(name: ".lproj count", value: "\(lprojCount)"))
        results.append(InspectItemInfo(name: "Languages in .lproj folders", value: "\(languages.joined(separator: ", "))"))
        results.append(InspectItemInfo(name: "Total size of all files", value: "\(Utils.formatBytes(totalSize)) (\(totalSize) bytes)"))
        
        for (ext, size) in extensionSizes.sorted(by: {$0.value > $1.value }) {
            results.append(InspectItemInfo(name: "- Size for .\(ext)", value: Utils.formatBytes(size)))
        }

        return results
    }

    
    
}
