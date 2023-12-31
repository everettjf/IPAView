//
//  ExploreManager.swift
//  IPAView
//
//  Created by everettjf on 2023/12/30.
//

import Foundation


class ExploreManager {
    
    static func listKeyItems(path: URL) -> [SidebarItemInfo] {
        
        let rootName = path.lastPathComponent
        
        var items: [SidebarItemInfo] = [];
        items.append(SidebarItemInfo(name: rootName, path: path, directory: true))
        
        // payload
        let payloadPath = path.appending(path: "Payload")
        if Utils.directoryExists(at: payloadPath) {
            items.append(SidebarItemInfo(name: "Payload", path: payloadPath, directory: true))
        }
        
        // app
        if let appPath = Utils.findFirstAppDirectory(at: payloadPath) {
            items.append(SidebarItemInfo(name: appPath.lastPathComponent, path: appPath, directory: true))
            
            // framework
            let frameworkPath = appPath.appending(path: "Frameworks")
            if Utils.isURLDirectory(url: frameworkPath) {
                items.append(SidebarItemInfo(name: "Frameworks", path: frameworkPath, directory: true))
            }
        }
        
        return items
    }
    
    static func listFiles(path: URL) -> [FileItemInfo]{
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path())
            print("items : \(items)")
            var files = try items.compactMap { filename -> FileItemInfo? in
                if filename == ".DS_Store" {
                    return nil
                }
                
                let fullPath = path.appending(path: filename)
                var isDir: ObjCBool = false
                guard fileManager.fileExists(atPath: fullPath.path(), isDirectory: &isDir) else {
                    return nil
                }
                // macho
                var isMacho = false
                if !isDir.boolValue {
                    isMacho = Utils.isMachOFile(atPath: fullPath)
                }
                
                // attributes
                let attributes = try fileManager.attributesOfItem(atPath: fullPath.path())
                let fileSize = attributes[.size] as? Int64 ?? 0
                let fileDescription = ""
                
                // type
                var fileType = ""
                if isDir.boolValue {
                    fileType = "Directory"
                } else if isMacho {
                    fileType = "MachO"
                } else {
                    fileType = fullPath.pathExtension
                }

                return FileItemInfo(name: filename, type: fileType, size: fileSize, description: fileDescription,directory: isDir.boolValue, macho: isMacho, path: fullPath)
            }
            
            // sort
            files = files.sorted(by: { first, second in

                if first.directory && !second.directory {
                    return true
                } else if !first.directory && second.directory {
                    return false
                }
                
                // If both are directories or both are not, then prioritize .plist files
                if first.type == "plist" && second.type != "plist" {
                    return true
                } else if first.type != "plist" && second.type == "plist" {
                    return false
                }
                
                if first.type != second.type {
                    return first.type < second.type
                }
                
                // Finally, if both are .plist or both are not, sort by another criterion, e.g., name
                return first.name < second.name
            })
            
            
            return files
        } catch {
            print("Error listing files at \(path): \(error)")
            return []
        }
    }
    
}
