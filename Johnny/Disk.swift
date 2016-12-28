//
//  Disk.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation

class Disk {
    
    fileprivate let cachePath = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("io.johhny")
    fileprivate let libraryPath = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("io.johhny")
    fileprivate var size: UInt64 = 0
    fileprivate var capacity = UINT64_MAX
    fileprivate var diskQueue = DispatchQueue(label: "io.johhny.disk")
    
    
    // MARK: - Init
    init() {
        createDirectory()
        
        diskQueue.async {
            self.calculateSize()
        }
        
        #if UIKIT_COMPATIBLE && !WATCHKIT
            NotificationCenter.default.addObserver(self, selector: #selector(nuke), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        #endif
    }
    
    
    // MARK: - Operations
    subscript(key: String) -> Data? {
        get { return get(key) }
        set(newValue) {
            diskQueue.async {
                if newValue != nil { self.add(key, newValue: newValue!) }
                else { self.remove(key) }
            }
        }
    }
    
    subscript(key: String, library: Bool) -> Data? {
        get { return get(key, library: library) }
        set(newValue) {
            diskQueue.async {
                if newValue != nil { self.add(key, newValue: newValue!, library: library) }
                else { self.remove(key, library: library) }
            }
        }
    }
    
    
    fileprivate func get(_ key: String, library: Bool = false) -> Data? {
        let path = getPath(key, library: library)
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions())
        updateAccessDate(path)
        return data
    }
    
    
    fileprivate func add(_ key: String, newValue: Data, library: Bool = false) {
        createDirectory()
        
        let path = getPath(key, library: library)
        let pastAttributes = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary
        do {
            try newValue.write(to: URL(fileURLWithPath: path), options: .atomicWrite)
            if let attributes = pastAttributes {
                self.substractSize(attributes.fileSize())
            }
            size += UInt64(newValue.count)
            controlSize()
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("Failed to write key \(key)", error) }
        }
    }
    
    fileprivate func remove(_ key: String, library: Bool = false) {
        
        // Only proceed if file exists, otherwise, the whole containing dir will be removed
        guard FileManager.default.fileExists(atPath: getPath(key, library: library), isDirectory: nil) == true else {
            return
        }
        
        do {
            let attributes : NSDictionary =  try FileManager.default.attributesOfItem(atPath: library ? libraryPath : cachePath) as NSDictionary
            let fileSize = attributes.fileSize()
            print("JOHNNY REMOVING PATH: ", getPath(key, library: library))
            try FileManager.default.removeItem(atPath: getPath(key, library: library))
            substractSize(fileSize)
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("File remove error", error) }
        }
    }

    
    @objc func nuke(libraryToo: Bool = false, _ completion: (()->Void)? = nil) {
        diskQueue.async {
            
            if libraryToo {
                let contents = try? FileManager.default.contentsOfDirectory(atPath: self.libraryPath)
                contents?.forEach({ (fileName) in
                    let filePath = (self.libraryPath as NSString).appendingPathComponent(fileName)
                    _ = try? FileManager.default.removeItem(atPath: filePath)
                })
            }
            
            let contents = try? FileManager.default.contentsOfDirectory(atPath: self.cachePath)
            contents?.forEach({ (fileName) in
                let filePath = (self.cachePath as NSString).appendingPathComponent(fileName)
                _ = try? FileManager.default.removeItem(atPath: filePath)
            })
            
            self.calculateSize()
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    
    
    // MARK: - Maintenance
    func getPath(_ key: String, library: Bool = false) -> String {
        let escapedFilename = [ "\0":"%00", ":":"%3A", "/":"%2F" ]
            .reduce(key.components(separatedBy: "%").joined(separator: "%25")) {
                str, m in str.components(separatedBy: m.0).joined(separator: m.1) }
        return ((library ? libraryPath : cachePath) as NSString).appendingPathComponent(escapedFilename)
    }
    
    fileprivate func createDirectory() {
        
        // Cache
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: cachePath, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            try! FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Library
        var isDirLib: ObjCBool = false
        let existsLib = FileManager.default.fileExists(atPath: libraryPath, isDirectory: &isDirLib)
        if !existsLib || !isDirLib.boolValue {
            try! FileManager.default.createDirectory(atPath: libraryPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    fileprivate func calculateSize() {
        size = 0

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: cachePath)
            for fileName in contents {
                let p = (cachePath as NSString).appendingPathComponent(fileName)
                do {
                    let attributes : NSDictionary = try FileManager.default.attributesOfItem(atPath: p) as NSDictionary
                    size += attributes.fileSize()
                } catch {
                    if self.isNoSuchFileError(error as NSError) { Log.log("Failed to read file size of \(p)", error) }
                }
            }
        } catch {
            if self.isNoSuchFileError(error as NSError) { Log.log("Failed to list directory", error) }
        }
    }
    
    
    fileprivate func controlSize() {
        
        if size <= capacity { return }
        
        let fileManager = FileManager.default
        fileManager.enumerateContentsOfDirectoryAtPath(cachePath, orderedByProperty: URLResourceKey.contentModificationDateKey.rawValue, ascending: true) { (URL : Foundation.URL, _, stop : inout Bool) -> Void in
            
            self[(URL.path as NSString).deletingLastPathComponent] = nil
            stop = self.size <= self.capacity
        }
    }
    
    
    fileprivate func substractSize(_ s : UInt64) {
        size = size >= s ? size-s : 0
    }

    
    fileprivate func updateAccessDate(_ path: String) {
        diskQueue.async {
            let now = Date()
            do {
                try FileManager.default.setAttributes([FileAttributeKey.modificationDate : now], ofItemAtPath: path)
            } catch {
                if self.isNoSuchFileError(error as NSError) { Log.log("Failed to update access date", error) }
            }
        }
    }
    
    
    fileprivate func isNoSuchFileError(_ error : NSError?) -> Bool {
        if let error = error {
            return NSCocoaErrorDomain == error.domain && error.code == NSFileReadNoSuchFileError
        }
        return false
    }
}
