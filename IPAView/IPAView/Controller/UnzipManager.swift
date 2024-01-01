//
//  UnzipManager.swift
//  IPAView
//
//  Created by everettjf on 2023/12/24.
//
import Foundation
import ZIPFoundation

class UnzipManager : NSObject {
    var progressHandler: ((Double) -> Void)?
    
    var registered = false


    func getUnzipDirectory()-> URL {
        let dir = Utils.getCacheDirectory()
        if !Utils.directoryExists(at: dir) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    func getEmptyUnzipDirectoryForFile(path: URL) -> URL {
        let name = path.lastPathComponent
        let dir = getUnzipDirectory()
        
        let target = dir.appending(path: name)
        if Utils.directoryExists(at: target) {
            try? FileManager.default.removeItem(at: target)
        }
        
        try? FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
        return target
    }

    func unzipFile(at sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileManager = FileManager.default

        let tempDirectoryURL = getEmptyUnzipDirectoryForFile(path: sourceURL)
        
        print("temp dir : \(tempDirectoryURL)")

        let progress = Progress(totalUnitCount: 1)
        progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)
        registered = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try fileManager.unzipItem(at: sourceURL, to: tempDirectoryURL, progress: progress)
                DispatchQueue.main.async {
                    completion(.success(tempDirectoryURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Progress.fractionCompleted), let progress = object as? Progress {
            self.progressHandler?(progress.fractionCompleted)
        }
    }

    deinit {
        if registered {
            self.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
        }
    }
}
