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
    private lazy var diskQueue = dispatch_queue_create("io.johhny.disk", nil)

    
    // MARK: - Init
    init() {
        let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let johhny = "io.johhny"
        path = (cachesPath as NSString).stringByAppendingPathComponent(johhny)

        createDirectory()
        
        Async.customQueue(diskQueue) {
            self.calculateSize()
        }
        
        #if UIKIT_COMPATIBLE && !WATCHKIT
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(nuke), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        #endif
    }
    
    
    // MARK: - Operations
    subscript(key: String) -> NSData? {
        get { return get(key) }
        set(newValue) {
            Async.customQueue(diskQueue) {
                if newValue != nil { self.add(key, newValue: newValue!) }
                else { self.remove(key) }
            }
        }
    }
    
    subscript(key: String, directory: String) -> NSData? {
        get { return get(directory+"/"+key) }
        set(newValue) {
            Async.customQueue(diskQueue) {
                let extendedKey = directory+"/"+key
                if newValue != nil { self.add(extendedKey, newValue: newValue!) }
                else { self.remove(extendedKey) }
            }
        }
    }
    
    
    private func get(key: String) -> NSData? {
        let path = getPath(key)
        let data = try? NSData(contentsOfFile: path, options: NSDataReadingOptions())
        updateAccessDate(path)
        return data
    }
    
    
    private func add(key: String, newValue: NSData) {
        let pastAttributes: NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath(path)
        do {
            try newValue.writeToFile(getPath(key), options: NSDataWritingOptions.AtomicWrite)
            if let attributes = pastAttributes {
                self.substractSize(attributes.fileSize())
            }
            size += UInt64(newValue.length)
            controlSize()
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("Failed to write key \(key)", error) }
        }
    }
    
    private func remove(key: String) {
        
        // Only proceed if file exists, otherwise, the whole containing dir will be removed
        guard NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: nil) == true else {
            return
        }
        
        do {
            let attributes : NSDictionary =  try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            let fileSize = attributes.fileSize()
            print("JOHNNY REMOVING PATH: ", path)
            try NSFileManager.defaultManager().removeItemAtPath(path)
            substractSize(fileSize)
        } catch {
            if isNoSuchFileError(error as NSError) { Log.log("File remove error", error) }
        }
    }

    
    @objc func nuke(completion: (()->Void)? = nil) {
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
    func getPath(key: String) -> String {
        let escapedFilename = [ "\0":"%00", ":":"%3A", "/":"%2F" ]
            .reduce(key.componentsSeparatedByString("%").joinWithSeparator("%25")) {
                str, m in str.componentsSeparatedByString(m.0).joinWithSeparator(m.1) }
        return (path as NSString).stringByAppendingPathComponent(escapedFilename)
    }
    
    private func createDirectory() {
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
        if !exists || !isDir {
            try! NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func calculateSize() {
        size = 0

        do {
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            for fileName in contents {
                let p = (path as NSString).stringByAppendingPathComponent(fileName)
                do {
                    let attributes : NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(p)
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
        
        let fileManager = NSFileManager.defaultManager()
        fileManager.enumerateContentsOfDirectoryAtPath(path, orderedByProperty: NSURLContentModificationDateKey, ascending: true) { (URL : NSURL, _, inout stop : Bool) -> Void in
            
            if let p = URL.path {
                self[(p as NSString).stringByDeletingLastPathComponent] = nil
                stop = self.size <= self.capacity
            }
        }
    }
    
    
    private func substractSize(s : UInt64) {
        size = size >= s ? size-s : 0
    }

    
    private func updateAccessDate(path: String) {
        Async.customQueue(diskQueue) {
            let now = NSDate()
            do {
                try NSFileManager.defaultManager().setAttributes([NSFileModificationDate : now], ofItemAtPath: path)
            } catch {
                if self.isNoSuchFileError(error as NSError) { Log.log("Failed to update access date", error) }
            }
        }
    }
    
    
    private func isNoSuchFileError(error : NSError?) -> Bool {
        if let error = error {
            return NSCocoaErrorDomain == error.domain && error.code == NSFileReadNoSuchFileError
        }
        return false
    }
}