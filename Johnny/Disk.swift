//
//  Disk.swift
//  Johnny
//
//  Created by Zolo on 6/26/16.
//  Copyright © 2016 Zoltán Matók. All rights reserved.
//

import Foundation
import Async

class Disk {
    
    private let path: String
    private var size: UInt64 = 0
    private var capacity = UINT64_MAX
    private lazy var diskQueue = DispatchQueue(label: "io.johhny.disk", attributes: [])

    
    // MARK: - Init
    init() {
        let cachesPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let johhny = "io.johhny"
        path = (cachesPath as NSString).appendingPathComponent(johhny)

        createDirectory()
        
        Async.customQueue(diskQueue) {
            self.calculateSize()
        }
    }
    
    
    // MARK: - Operations
    subscript(key: String) -> Data? {
        get { return get(key) }
        set(newValue) {
            Async.customQueue(diskQueue) {
                if newValue != nil { self.add(key, newValue: newValue!) }
                else { self.remove(key) }
            }
        }
    }
    
    subscript(key: String, directory: String) -> Data? {
        get { return get(directory+"/"+key) }
        set(newValue) {
            Async.customQueue(diskQueue) {
                let extendedKey = directory+"/"+key
                if newValue != nil { self.add(extendedKey, newValue: newValue!) }
                else { self.remove(extendedKey) }
            }
        }
    }
    
    
    private func get(_ key: String) -> Data? {
        let path = getPath(key)
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions())
        updateAccessDate(path)
        return data
    }
    
    
    private func add(_ key: String, newValue: Data) {
        let pastAttributes: NSDictionary? = try? FileManager.default().attributesOfItem(atPath: path)
        do {
            try newValue.write(to: URL(fileURLWithPath: getPath(key)), options: NSData.WritingOptions.atomicWrite)
            if let attributes = pastAttributes {
                self.substractSize(attributes.fileSize())
            }
            size += UInt64(newValue.count)
            controlSize()
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("Failed to write key \(key)", error) }
        }
    }
    
    private func remove(_ key: String) {
        do {
            let attributes : NSDictionary =  try FileManager.default().attributesOfItem(atPath: path)
            let fileSize = attributes.fileSize()
            try FileManager.default().removeItem(atPath: path)
            substractSize(fileSize)
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("File remove error", error) }
        }
    }

    
    func nuke(_ completion: (()->Void)?) {
        Async.customQueue(diskQueue) { 
            let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.path)
            contents?.forEach({ (fileName) in
                let filePath = (self.path as NSString).stringByAppendingPathComponent(fileName)
                _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
            })
            self.calculateSize()
        }.main { 
            completion?()
        }
    }
    
    
    
    // MARK: - Maintenance
    func getPath(_ key: String) -> String {
        let escapedFilename = [ "\0":"%00", ":":"%3A", "/":"%2F" ]
            .reduce(key.components(separatedBy: "%").joined(separator: "%25")) {
                str, m in str.components(separatedBy: m.0).joined(separator: m.1) }
        return (path as NSString).appendingPathComponent(escapedFilename)
    }
    
    private func createDirectory() {
        var isDir: ObjCBool = false
        let exists = FileManager.default().fileExists(atPath: path, isDirectory: &isDir)
        if !exists || !isDir {
            try! FileManager.default().createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    private func calculateSize() {
        size = 0

        do {
            let contents = try FileManager.default().contentsOfDirectory(atPath: path)
            for fileName in contents {
                let p = (path as NSString).appendingPathComponent(fileName)
                do {
                    let attributes : NSDictionary = try FileManager.default().attributesOfItem(atPath: p)
                    size += attributes.fileSize()
                } catch {
                    if self.isNoSuchFileError(error as NSError) { Log.log("Failed to read file size of \(path)", error) }
                }
            }
        } catch {
            if self.isNoSuchFileError(error as NSError) { Log.log("Failed to list directory", error) }
        }
    }
    
    
    private func controlSize() {
        
        if size <= capacity { return }
        
        let fileManager = FileManager.default()
        fileManager.enumerateContentsOfDirectoryAtPath(path, orderedByProperty: URLResourceKey.contentModificationDateKey, ascending: true) { (URL : Foundation.URL, _, stop : inout Bool) -> Void in
            
            if let p = URL.path {
                self[(p as NSString).deletingLastPathComponent] = nil
                stop = self.size <= self.capacity
            }
        }
    }
    
    
    private func substractSize(_ s : UInt64) {
        size = size >= s ? size-s : 0
    }

    
    private func updateAccessDate(_ path: String) {
        Async.customQueue(diskQueue) {
            let now = NSDate()
            do {
                try NSFileManager.defaultManager().setAttributes([NSFileModificationDate : now], ofItemAtPath: path)
            } catch {
                if self.isNoSuchFileError(error as NSError) { Log.log("Failed to update access date", error) }
            }
        }
    }
    
    
    private func isNoSuchFileError(_ error : NSError?) -> Bool {
        if let error = error {
            return NSCocoaErrorDomain == error.domain && error.code == NSFileReadNoSuchFileError
        }
        return false
    }
}
